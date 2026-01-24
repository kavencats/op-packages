#!/bin/sh

CONFIG="/etc/config/netaudit"
LOG_FILE="/var/log/netaudit.log"
PID_FILE="/var/run/netaudit.pid"
DATA_DIR="/tmp/netaudit"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
    [ "$DEBUG" = "1" ] && echo "$1"
}

get_uci() {
    uci -q get $CONFIG.$1 2>/dev/null
}

monitor_traffic() {
    local interval=$(get_uci "monitoring.@settings.interval" || echo "5")
    
    while true; do
        # 监控网络连接
        if [ "$(get_uci "monitoring.@settings.log_connections")" = "1" ]; then
            monitor_connections
        fi
        
        # 检查流量阈值
        check_thresholds
        
        # 应用过滤规则
        if [ "$(get_uci "filtering.@settings.enabled")" = "1" ]; then
            apply_filters
        fi
        
        sleep $interval
    done
}

monitor_connections() {
    local max_conn=$(get_uci "monitoring.@settings.max_connections" || echo "1000")
    
    # 监控TCP连接
    netstat -tn 2>/dev/null | grep 'ESTABLISHED' | awk '{print $5}' | cut -d: -f1 | \
        sort | uniq -c | sort -rn | head -20 | while read count ip; do
        [ $count -gt 10 ] && log "High connections from $ip: $count connections"
    done
    
    # 监控异常端口
    netstat -tn 2>/dev/null | grep -E ':(4444|5555|6666|7777|8888)' | \
        awk '{print $5}' | while read ip; do
        log "Suspicious connection from $ip"
    done
}

check_thresholds() {
    uci -q show netaudit | grep "=threshold" | while read line; do
        local section=$(echo $line | cut -d= -f1 | cut -d. -f2)
        local interface=$(get_uci "$section.interface")
        local threshold_type=$(get_uci "$section.type")
        local threshold_value=$(get_uci "$section.value")
        local action=$(get_uci "$section.action")
        
        if [ -n "$interface" ]; then
            case "$threshold_type" in
                "bandwidth")
                    check_bandwidth "$interface" "$threshold_value" "$action"
                    ;;
                "connections")
                    check_connections "$interface" "$threshold_value" "$action"
                    ;;
            esac
        fi
    done
}

check_bandwidth() {
    local iface=$1
    local threshold=$2
    local action=$3
    
    # 获取接口流量
    local rx_bytes=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo "0")
    local tx_bytes=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo "0")
    local total=$((rx_bytes + tx_bytes))
    
    if [ $total -gt $((threshold * 1024 * 1024)) ]; then
        log "Threshold exceeded on $iface: ${total} bytes"
        [ "$action" = "limit" ] && limit_bandwidth "$iface"
    fi
}

apply_filters() {
    local mode=$(get_uci "filtering.@settings.mode" || echo "blacklist")
    
    if [ "$mode" = "blacklist" ]; then
        uci -q show netaudit | grep "=domain" | while read line; do
            local section=$(echo $line | cut -d= -f1 | cut -d. -f2)
            local domain=$(get_uci "$section.domain")
            local action=$(get_uci "$section.action")
            
            [ -n "$domain" ] && block_domain "$domain" "$action"
        done
    fi
    
    # 应用分类过滤
    uci -q show netaudit | grep "=category" | while read line; do
        local section=$(echo $line | cut -d= -f1 | cut -d. -f2)
        local category=$(get_uci "$section.name")
        local action=$(get_uci "$section.action")
        
        apply_category_filter "$category" "$action"
    done
}

block_domain() {
    local domain=$1
    local action=$2
    
    # 添加到dnsmasq黑名单
    echo "address=/$domain/0.0.0.0" > /etc/dnsmasq.d/netaudit_$domain.conf
    
    case "$action" in
        "redirect")
            local redirect=$(get_uci "$section.redirect")
            [ -n "$redirect" ] && echo "address=/$domain/$redirect" > /etc/dnsmasq.d/netaudit_$domain.conf
            ;;
        "log")
            log "Domain accessed: $domain"
            ;;
    esac
}

cleanup() {
    rm -f $PID_FILE
    [ -d $DATA_DIR ] && rm -rf $DATA_DIR
    exit 0
}

main() {
    trap cleanup SIGTERM SIGINT
    
    echo $$ > $PID_FILE
    
    # 创建数据目录
    mkdir -p $DATA_DIR
    
    # 读取配置
    local enabled=$(get_uci "global.@settings.enabled" || echo "0")
    local debug=$(get_uci "advanced.@settings.debug" || echo "0")
    
    [ "$debug" = "1" ] && DEBUG=1
    
    if [ "$enabled" = "1" ]; then
        log "Network Audit service started"
        monitor_traffic
    else
        log "Service disabled in configuration"
        sleep 3600
    fi
}

case "$1" in
    start)
        main
        ;;
    stop)
        cleanup
        ;;
    restart)
        $0 stop
        sleep 2
        $0 start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac