#!/bin/sh
# Network Audit Uninstall Script
# This script is called during package removal

cleanup_all() {
    echo "Starting network-audit uninstallation cleanup..."
    
    # 停止服务
    if [ -x "/etc/init.d/network-audit" ]; then
        echo "Stopping network-audit service..."
        /etc/init.d/network-audit stop
        /etc/init.d/network-audit disable
    fi
    
    # 清理 iptables 规则
    echo "Cleaning up iptables rules..."
    
    # 从标准链中移除自定义链引用
    iptables -D INPUT -j NETWORK_AUDIT_INPUT 2>/dev/null
    iptables -D FORWARD -j NETWORK_AUDIT_FORWARD 2>/dev/null
    iptables -D OUTPUT -j NETWORK_AUDIT_OUTPUT 2>/dev/null
    
    # 清空并删除自定义链
    iptables -F NETWORK_AUDIT_INPUT 2>/dev/null
    iptables -F NETWORK_AUDIT_FORWARD 2>/dev/null
    iptables -F NETWORK_AUDIT_OUTPUT 2>/dev/null
    
    iptables -X NETWORK_AUDIT_INPUT 2>/dev/null
    iptables -X NETWORK_AUDIT_FORWARD 2>/dev/null
    iptables -X NETWORK_AUDIT_OUTPUT 2>/dev/null
    
    # IPv6 规则（如果存在）
    ip6tables -D INPUT -j NETWORK_AUDIT_INPUT 2>/dev/null
    ip6tables -D FORWARD -j NETWORK_AUDIT_FORWARD 2>/dev/null
    ip6tables -D OUTPUT -j NETWORK_AUDIT_OUTPUT 2>/dev/null
    
    ip6tables -F NETWORK_AUDIT_INPUT 2>/dev/null
    ip6tables -F NETWORK_AUDIT_FORWARD 2>/dev/null
    ip6tables -F NETWORK_AUDIT_OUTPUT 2>/dev/null
    
    ip6tables -X NETWORK_AUDIT_INPUT 2>/dev/null
    ip6tables -X NETWORK_AUDIT_FORWARD 2>/dev/null
    ip6tables -X NETWORK_AUDIT_OUTPUT 2>/dev/null
    
    # 清理运行时文件
    echo "Cleaning up runtime files..."
    rm -f /var/run/network-audit.pid
    rm -rf /var/run/network-audit
    rm -rf /tmp/network-audit
    
    # 清理日志文件
    echo "Cleaning up log files..."
    rm -f /var/log/network-audit.log
    rm -f /var/log/network-audit.log.old
    
    # 清理配置文件
    echo "Cleaning up configuration..."
    uci delete network-audit 2>/dev/null
    uci commit network-audit 2>/dev/null
    rm -f /etc/config/network-audit
    
    # 清理进程
    echo "Killing remaining processes..."
    pkill -f "network-audit" 2>/dev/null
    pkill -f "audit.sh" 2>/dev/null
    
    # 等待进程结束
    sleep 2
    
    # 强制终止任何残留进程
    pkill -9 -f "network-audit" 2>/dev/null
    pkill -9 -f "audit.sh" 2>/dev/null
    
    echo "Network audit cleanup completed successfully."
    return 0
}

# 如果从命令行直接运行
if [ "$1" = "--run" ]; then
    cleanup_all
    exit $?
fi
