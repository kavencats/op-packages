#!/bin/sh
# Network Audit uci-defaults script

. /lib/functions.sh

uci_defaults_network_audit() {
    # Create config if it doesn't exist
    uci -q get network-audit.general || {
        uci set network-audit.general=network-audit
        uci set network-audit.general.enabled='0'
        uci set network-audit.general.log_level='info'
        uci set network-audit.general.log_size='10'
        uci add_list network-audit.general.protocols='tcp'
        uci add_list network-audit.general.protocols='udp'
        uci set network-audit.general.port_monitor='0'
        uci set network-audit.general.rate_limit='0'
        uci set network-audit.general.max_connections='100'
    }
    
    uci -q get network-audit.rules || {
        uci set network-audit.rules=network-audit
        uci set network-audit.rules.@rules[-1].type='rules'
    }
    
    uci commit network-audit
}

boot() {
    uci_defaults_network_audit
}

start() {
    # Ensure log directory exists
    mkdir -p /var/log/
    touch /var/log/network-audit.log
    chmod 644 /var/log/network-audit.log
    
    # Ensure scripts are executable
    chmod 755 /usr/share/network-audit/scripts/audit.sh
    chmod 755 /usr/libexec/rpcd/network-audit
    
    # Create necessary directories
    mkdir -p /usr/share/network-audit/rules
    mkdir -p /var/run/network-audit
}

stop() {
    # Cleanup
    rm -f /var/run/network-audit.pid
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