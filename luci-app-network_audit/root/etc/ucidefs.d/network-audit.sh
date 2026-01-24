#!/bin/sh
# Network Audit uci-defaults script

. /lib/functions.sh

uci_defaults_network_audit() {
    # Ensure config file exists
    touch /etc/config/network-audit
    
    # Create default configuration if it doesn't exist
    uci -q get network-audit.general >/dev/null || {
        uci batch << EOF
set network-audit.general='network-audit'
set network-audit.general.enabled='0'
set network-audit.general.log_level='info'
set network-audit.general.log_size='10'
set network-audit.general.port_monitor='0'
set network-audit.general.rate_limit='0'
set network-audit.general.max_connections='100'
set network-audit.general.alert_email=''
add_list network-audit.general.protocols='tcp'
add_list network-audit.general.protocols='udp'
set network-audit.rules='network-audit'
set network-audit.rules.type='rules'
EOF
        uci commit network-audit
    }
}

boot() {
    uci_defaults_network_audit
    return 0
}

start() {
    # Ensure log directory and file exist
    mkdir -p /var/log/
    touch /var/log/network-audit.log
    chmod 644 /var/log/network-audit.log
    
    # Ensure runtime directory exists
    mkdir -p /var/run/network-audit
    chmod 755 /var/run/network-audit
    
    # Ensure scripts are executable
    [ -x /usr/share/network-audit/scripts/audit.sh ] || chmod 755 /usr/share/network-audit/scripts/audit.sh
    [ -x /usr/libexec/rpcd/network-audit ] || chmod 755 /usr/libexec/rpcd/network-audit
    
    # Create necessary directories
    mkdir -p /usr/share/network-audit/rules
    
    return 0
}

stop() {
    # Cleanup PID file
    rm -f /var/run/network-audit.pid
    return 0
}

case "$1" in
    boot)
        boot
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    *)
        echo "Usage: $0 {boot|start|stop}"
        exit 1
        ;;
esac
