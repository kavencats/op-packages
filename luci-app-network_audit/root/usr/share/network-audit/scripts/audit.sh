#!/bin/sh
# Network Audit Daemon Script

CONFIG_FILE="/etc/config/network-audit"
LOG_FILE="/var/log/network-audit.log"
PID_FILE="/var/run/network-audit.pid"
RULES_DIR="/usr/share/network-audit/rules"
STATE_DIR="/var/run/network-audit"

mkdir -p "$STATE_DIR"
echo $$ > "$PID_FILE"

log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    [ "$level" = "ERROR" ] && logger -t network-audit "[$level] $message"
}

load_config() {
    . /lib/functions.sh
    config_load "network-audit"
    
    config_get_bool enabled "general" "enabled" "0"
    config_get log_level "general" "log_level" "info"
    config_get log_size "general" "log_size" "10"
    config_get interfaces "general" "interfaces"
    config_get protocols "general" "protocols" "tcp udp"
    config_get_bool port_monitor "general" "port_monitor" "0"
    config_get suspicious_ports "general" "suspicious_ports"
    config_get_bool rate_limit "general" "rate_limit" "0"
    config_get max_connections "general" "max_connections" "100"
    config_get alert_email "general" "alert_email"
    
    config_get block_countries "rules" "block_countries"
    config_get whitelist_ips "rules" "whitelist_ips"
    config_get blacklist_ips "rules" "blacklist_ips"
}

rotate_logs() {
    local max_size_mb=${log_size:-10}
    local max_size=$((max_size_mb * 1024 * 1024))
    
    if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -gt $max_size ]; then
        mv "$LOG_FILE" "${LOG_FILE}.old"
        log_message "INFO" "Rotated log file (exceeded ${max_size_mb}MB)"
    fi
}

setup_iptables() {
    # Flush existing chains
    iptables -F NETWORK_AUDIT_INPUT 2>/dev/null
    iptables -F NETWORK_AUDIT_FORWARD 2>/dev/null
    iptables -F NETWORK_AUDIT_OUTPUT 2>/dev/null
    
    iptables -X NETWORK_AUDIT_INPUT 2>/dev/null
    iptables -X NETWORK_AUDIT_FORWARD 2>/dev/null
    iptables -X NETWORK_AUDIT_OUTPUT 2>/dev/null
    
    # Create chains
    iptables -N NETWORK_AUDIT_INPUT
    iptables -N NETWORK_AUDIT_FORWARD
    iptables -N NETWORK_AUDIT_OUTPUT
    
    # Insert chains
    iptables -I INPUT 1 -j NETWORK_AUDIT_INPUT
    iptables -I FORWARD 1 -j NETWORK_AUDIT_FORWARD
    iptables -I OUTPUT 1 -j NETWORK_AUDIT_OUTPUT
    
    # Whitelist IPs
    for ip in $whitelist_ips; do
        [ -n "$ip" ] && iptables -A NETWORK_AUDIT_INPUT -s "$ip" -j RETURN
        [ -n "$ip" ] && iptables -A NETWORK_AUDIT_FORWARD -s "$ip" -j RETURN
        [ -n "$ip" ] && iptables -A NETWORK_AUDIT_OUTPUT -d "$ip" -j RETURN
    done
    
    # Blacklist IPs
    for ip in $blacklist_ips; do
        [ -n "$ip" ] && iptables -A NETWORK_AUDIT_INPUT -s "$ip" -j DROP
        [ -n "$ip" ] && iptables -A NETWORK_AUDIT_FORWARD -s "$ip" -j DROP
        [ -n "$ip" ] && iptables -A NETWORK_AUDIT_OUTPUT -d "$ip" -j DROP
    done
    
    # Rate limiting
    if [ "$rate_limit" = "1" ]; then
        iptables -A NETWORK_AUDIT_INPUT -p tcp --syn -m limit --limit ${max_connections:-100}/second \
                 -j ACCEPT
        iptables -A NETWORK_AUDIT_INPUT -p tcp --syn -j DROP
    fi
    
    # Port monitoring
    if [ "$port_monitor" = "1" ]; then
        for port in $suspicious_ports; do
            [ -n "$port" ] && iptables -A NETWORK_AUDIT_INPUT -p tcp --dport "$port" \
                           -m limit --limit 1/minute -j LOG --log-prefix "SUSPICIOUS_PORT: "
            [ -n "$port" ] && iptables -A NETWORK_AUDIT_INPUT -p tcp --dport "$port" -j DROP
        done
    fi
    
    # Log all other traffic
    iptables -A NETWORK_AUDIT_INPUT -j LOG --log-prefix "NET_AUDIT_IN: " --log-level 6
    iptables -A NETWORK_AUDIT_FORWARD -j LOG --log-prefix "NET_AUDIT_FW: " --log-level 6
    iptables -A NETWORK_AUDIT_OUTPUT -j LOG --log-prefix "NET_AUDIT_OUT: " --log-level 6
}

cleanup() {
    log_message "INFO" "Shutting down network audit service"
    
    # Remove iptables chains
    iptables -D INPUT -j NETWORK_AUDIT_INPUT 2>/dev/null
    iptables -D FORWARD -j NETWORK_AUDIT_FORWARD 2>/dev/null
    iptables -D OUTPUT -j NETWORK_AUDIT_OUTPUT 2>/dev/null
    
    iptables -F NETWORK_AUDIT_INPUT 2>/dev/null
    iptables -F NETWORK_AUDIT_FORWARD 2>/dev/null
    iptables -F NETWORK_AUDIT_OUTPUT 2>/dev/null
    
    iptables -X NETWORK_AUDIT_INPUT 2>/dev/null
    iptables -X NETWORK_AUDIT_FORWARD 2>/dev/null
    iptables -X NETWORK_AUDIT_OUTPUT 2>/dev/null
    
    rm -f "$PID_FILE"
    exit 0
}

monitor_connections() {
    while true; do
        if [ -f "/tmp/network-audit.stop" ]; then
            cleanup
        fi
        
        rotate_logs
        
        # Monitor active connections
        conntrack -L -n 2>/dev/null | while read line; do
            # Add your connection analysis logic here
            echo "$line" | grep -q "ESTABLISHED" && {
                # Example: log high connection count
                :
            }
        done
        
        sleep 10
    done
}

main() {
    trap cleanup INT TERM
    
    load_config
    
    if [ "$enabled" != "1" ]; then
        log_message "INFO" "Network audit is disabled in configuration"
        cleanup
    fi
    
    log_message "INFO" "Starting network audit service"
    
    setup_iptables
    log_message "INFO" "IPTables rules configured"
    
    monitor_connections
}

# Start main function
main "$@"