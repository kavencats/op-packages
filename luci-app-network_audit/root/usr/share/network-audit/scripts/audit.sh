#!/bin/sh
# Network Audit Daemon Script
# 修复：使用正确的命令路径和处理边界情况

CONFIG_FILE="/etc/config/network-audit"
LOG_FILE="/var/log/network-audit.log"
PID_FILE="/var/run/network-audit.pid"
RULES_DIR="/usr/share/network-audit/rules"
STATE_DIR="/var/run/network-audit"

# 确保目录存在
mkdir -p "$STATE_DIR"
mkdir -p "/var/log"
echo $$ > "$PID_FILE"

# 查找命令的完整路径
CONNTRACK_BIN=$(which conntrack 2>/dev/null || echo "conntrack")
IPTABLES_BIN=$(which iptables 2>/dev/null || echo "iptables")
LOGGER_BIN=$(which logger 2>/dev/null || echo "logger")

log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # 写入日志文件
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    # 同时写入系统日志
    [ "$level" = "ERROR" -o "$level" = "WARN" ] && {
        $LOGGER_BIN -t network-audit "[$level] $message"
    }
    
    # 控制日志文件大小
    local max_size_mb=${LOG_SIZE:-10}
    local max_size=$((max_size_mb * 1024 * 1024))
    if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0) -gt $max_size ]; then
        mv "$LOG_FILE" "${LOG_FILE}.old" 2>/dev/null
    fi
}

load_config() {
    # 加载配置
    . /lib/functions.sh
    config_load "network-audit" || {
        log_message "ERROR" "Failed to load network-audit configuration"
        return 1
    }
    
    config_get_bool ENABLED "general" "enabled" "0"
    config_get LOG_LEVEL "general" "log_level" "info"
    config_get LOG_SIZE "general" "log_size" "10"
    config_get INTERFACES "general" "interfaces"
    config_get PROTOCOLS "general" "protocols" "tcp udp"
    config_get_bool PORT_MONITOR "general" "port_monitor" "0"
    config_get SUSPICIOUS_PORTS "general" "suspicious_ports"
    config_get_bool RATE_LIMIT "general" "rate_limit" "0"
    config_get MAX_CONNECTIONS "general" "max_connections" "100"
    config_get ALERT_EMAIL "general" "alert_email"
    
    config_get BLOCK_COUNTRIES "rules" "block_countries"
    config_get WHITELIST_IPS "rules" "whitelist_ips"
    config_get BLACKLIST_IPS "rules" "blacklist_ips"
    
    export ENABLED LOG_LEVEL LOG_SIZE INTERFACES PROTOCOLS PORT_MONITOR \
           SUSPICIOUS_PORTS RATE_LIMIT MAX_CONNECTIONS ALERT_EMAIL \
           BLOCK_COUNTRIES WHITELIST_IPS BLACKLIST_IPS
    
    return 0
}

cleanup_iptables() {
    # 清理现有的 iptables 规则
    $IPTABLES_BIN -D INPUT -j NETWORK_AUDIT_INPUT 2>/dev/null
    $IPTABLES_BIN -D FORWARD -j NETWORK_AUDIT_FORWARD 2>/dev/null
    $IPTABLES_BIN -D OUTPUT -j NETWORK_AUDIT_OUTPUT 2>/dev/null
    
    $IPTABLES_BIN -F NETWORK_AUDIT_INPUT 2>/dev/null
    $IPTABLES_BIN -F NETWORK_AUDIT_FORWARD 2>/dev/null
    $IPTABLES_BIN -F NETWORK_AUDIT_OUTPUT 2>/dev/null
    
    $IPTABLES_BIN -X NETWORK_AUDIT_INPUT 2>/dev/null
    $IPTABLES_BIN -X NETWORK_AUDIT_FORWARD 2>/dev/null
    $IPTABLES_BIN -X NETWORK_AUDIT_OUTPUT 2>/dev/null
}

setup_iptables() {
    # 清理旧规则
    cleanup_iptables
    
    # 创建自定义链
    $IPTABLES_BIN -N NETWORK_AUDIT_INPUT 2>/dev/null
    $IPTABLES_BIN -N NETWORK_AUDIT_FORWARD 2>/dev/null
    $IPTABLES_BIN -N NETWORK_AUDIT_OUTPUT 2>/dev/null
    
    # 将链插入到标准链中
    $IPTABLES_BIN -I INPUT 1 -j NETWORK_AUDIT_INPUT
    $IPTABLES_BIN -I FORWARD 1 -j NETWORK_AUDIT_FORWARD
    $IPTABLES_BIN -I OUTPUT 1 -j NETWORK_AUDIT_OUTPUT
    
    # 允许本地回环
    $IPTABLES_BIN -A NETWORK_AUDIT_INPUT -i lo -j ACCEPT
    $IPTABLES_BIN -A NETWORK_AUDIT_OUTPUT -o lo -j ACCEPT
    
    # 白名单 IP
    for ip in $WHITELIST_IPS; do
        [ -n "$ip" ] && {
            $IPTABLES_BIN -A NETWORK_AUDIT_INPUT -s "$ip" -j ACCEPT
            $IPTABLES_BIN -A NETWORK_AUDIT_FORWARD -s "$ip" -j ACCEPT
            $IPTABLES_BIN -A NETWORK_AUDIT_OUTPUT -d "$ip" -j ACCEPT
        }
    done
    
    # 黑名单 IP
    for ip in $BLACKLIST_IPS; do
        [ -n "$ip" ] && {
            $IPTABLES_BIN -A NETWORK_AUDIT_INPUT -s "$ip" -j DROP
            $IPTABLES_BIN -A NETWORK_AUDIT_FORWARD -s "$ip" -j DROP
            $IPTABLES_BIN -A NETWORK_AUDIT_OUTPUT -d "$ip" -j DROP
            log_message "INFO" "Blocked IP: $ip"
        }
    done
    
    # 速率限制
    if [ "$RATE_LIMIT" = "1" -a -n "$MAX_CONNECTIONS" ]; then
        $IPTABLES_BIN -A NETWORK_AUDIT_INPUT -p tcp --syn \
            -m limit --limit "$MAX_CONNECTIONS/second" --limit-burst 5 \
            -j ACCEPT
        $IPTABLES_BIN -A NETWORK_AUDIT_INPUT -p tcp --syn -j DROP
        log_message "INFO" "Rate limiting enabled: $MAX_CONNECTIONS connections/sec"
    fi
    
    # 端口监控
    if [ "$PORT_MONITOR" = "1" ]; then
        for port in $SUSPICIOUS_PORTS; do
            [ -n "$port" ] && {
                $IPTABLES_BIN -A NETWORK_AUDIT_INPUT -p tcp --dport "$port" \
                    -m limit --limit 1/min -j LOG --log-prefix "SUSPICIOUS_PORT_ACCESS: "
                $IPTABLES_BIN -A NETWORK_AUDIT_INPUT -p tcp --dport "$port" -j DROP
                log_message "INFO" "Monitoring suspicious port: $port"
            }
        done
    fi
    
    # 记录其他流量（根据日志级别）
    case "$LOG_LEVEL" in
        "debug")
            $IPTABLES_BIN -A NETWORK_AUDIT_INPUT -j LOG --log-prefix "NET_AUDIT_IN: " --log-level 7
            $IPTABLES_BIN -A NETWORK_AUDIT_FORWARD -j LOG --log-prefix "NET_AUDIT_FW: " --log-level 7
            $IPTABLES_BIN -A NETWORK_AUDIT_OUTPUT -j LOG --log-prefix "NET_AUDIT_OUT: " --log-level 7
            ;;
        "info")
            $IPTABLES_BIN -A NETWORK_AUDIT_INPUT -m limit --limit 10/min -j LOG --log-prefix "NET_AUDIT_IN: " --log-level 6
            $IPTABLES_BIN -A NETWORK_AUDIT_FORWARD -m limit --limit 10/min -j LOG --log-prefix "NET_AUDIT_FW: " --log-level 6
            $IPTABLES_BIN -A NETWORK_AUDIT_OUTPUT -m limit --limit 10/min -j LOG --log-prefix "NET_AUDIT_OUT: " --log-level 6
            ;;
        *)
            # warning 和 error 级别不记录常规流量
            ;;
    esac
    
    # 默认策略
    $IPTABLES_BIN -A NETWORK_AUDIT_INPUT -j ACCEPT
    $IPTABLES_BIN -A NETWORK_AUDIT_FORWARD -j ACCEPT
    $IPTABLES_BIN -A NETWORK_AUDIT_OUTPUT -j ACCEPT
    
    log_message "INFO" "IPTables rules configured successfully"
}

monitor_connections() {
    log_message "INFO" "Starting connection monitoring"
    
    while true; do
        # 检查是否应该停止
        if [ ! -f "$PID_FILE" ] || [ "$(cat "$PID_FILE" 2>/dev/null)" != "$$" ]; then
            log_message "INFO" "PID file changed, stopping"
            break
        fi
        
        # 重新加载配置（如果配置有变化）
        if [ -f "$CONFIG_FILE" ]; then
            local config_mtime=$(stat -c %Y "$CONFIG_FILE" 2>/dev/null)
            if [ "$config_mtime" != "$LAST_CONFIG_MTIME" ]; then
                log_message "INFO" "Configuration changed, reloading"
                load_config
                if [ "$ENABLED" = "1" ]; then
                    setup_iptables
                else
                    cleanup_iptables
                fi
                LAST_CONFIG_MTIME="$config_mtime"
            fi
        fi
        
        # 监控连接
        if [ "$ENABLED" = "1" ]; then
            # 记录连接统计
            local conn_count=0
            if [ -x "$(command -v conntrack)" ]; then
                conn_count=$($CONNTRACK_BIN -L 2>/dev/null | grep -c ESTABLISHED || echo 0)
                [ "$conn_count" -gt 100 ] && \
                    log_message "WARN" "High connection count: $conn_count established connections"
            fi
        fi
        
        # 等待下一次检查
        sleep 30
    done
}

cleanup() {
    log_message "INFO" "Shutting down network audit service"
    
    # 清理 iptables 规则
    cleanup_iptables
    
    # 清理 PID 文件
    rm -f "$PID_FILE"
    
    log_message "INFO" "Network audit service stopped"
    exit 0
}

main() {
    # 设置退出处理
    trap cleanup INT TERM EXIT
    
    # 加载配置
    load_config || {
        log_message "ERROR" "Failed to load configuration"
        exit 1
    }
    
    if [ "$ENABLED" != "1" ]; then
        log_message "INFO" "Network audit is disabled in configuration"
        exit 0
    fi
    
    log_message "INFO" "Starting network audit service (PID: $$)"
    log_message "INFO" "Log level: $LOG_LEVEL"
    log_message "INFO" "Log file: $LOG_FILE"
    
    # 设置 iptables
    setup_iptables
    
    # 开始监控
    monitor_connections
}

# 运行主函数
main "$@"
