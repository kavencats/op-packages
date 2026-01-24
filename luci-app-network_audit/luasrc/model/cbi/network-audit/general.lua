m = Map("network-audit", translate("Network Audit Settings"), 
        translate("Configure network traffic auditing and monitoring"))

s = m:section(NamedSection, "general", "network-audit", translate("General Settings"))
s.addremove = false

enabled = s:option(Flag, "enabled", translate("Enable Network Audit"),
    translate("Enable or disable network traffic auditing"))
enabled.default = "0"

log_level = s:option(ListValue, "log_level", translate("Log Level"))
log_level:value("debug", translate("Debug"))
log_level:value("info", translate("Info"))
log_level:value("warning", translate("Warning"))
log_level:value("error", translate("Error"))
log_level.default = "info"

log_size = s:option(Value, "log_size", translate("Max Log Size (MB)"),
    translate("Maximum log file size in megabytes"))
log_size.datatype = "uinteger"
log_size.default = "10"

audit_interfaces = s:option(DynamicList, "interfaces", translate("Audit Interfaces"),
    translate("Network interfaces to monitor (leave empty for all)"))
audit_interfaces:value("lan")
audit_interfaces:value("wan")
audit_interfaces:value("wan6")

audit_protocols = s:option(MultiValue, "protocols", translate("Audit Protocols"))
audit_protocols:value("tcp", "TCP")
audit_protocols:value("udp", "UDP")
audit_protocols:value("icmp", "ICMP")
audit_protocols.default = "tcp udp"

port_monitoring = s:option(Flag, "port_monitor", translate("Port Monitoring"),
    translate("Monitor specific ports for suspicious activity"))
port_monitoring.default = "0"

suspicious_ports = s:option(DynamicList, "suspicious_ports", translate("Suspicious Ports"),
    translate("Ports to monitor for suspicious activity"))
suspicious_ports:depends("port_monitor", "1")
suspicious_ports.datatype = "portrange"
suspicious_ports.placeholder = "e.g., 22, 23, 445"

rate_limit = s:option(Flag, "rate_limit", translate("Enable Rate Limiting"),
    translate("Enable connection rate limiting"))
rate_limit.default = "0"

max_connections = s:option(Value, "max_connections", translate("Max Connections per Second"),
    translate("Maximum allowed connections per second"))
max_connections:depends("rate_limit", "1")
max_connections.datatype = "uinteger"
max_connections.default = "100"

alert_email = s:option(Value, "alert_email", translate("Alert Email"),
    translate("Email address for alerts (leave empty to disable)"))
alert_email.datatype = "string"

s2 = m:section(NamedSection, "rules", "network-audit", translate("Audit Rules"))
s2.addremove = false

block_countries = s2:option(DynamicList, "block_countries", translate("Block Countries"),
    translate("Country codes to block (e.g., CN, RU, IR)"))

whitelist_ips = s2:option(DynamicList, "whitelist_ips", translate("Whitelist IPs"),
    translate("IP addresses to exclude from auditing"))

blacklist_ips = s2:option(DynamicList, "blacklist_ips", translate("Blacklist IPs"),
    translate("IP addresses to always block"))

return m