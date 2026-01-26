m = Map("netaudit", translate("Network Audit Overview"), 
    translate("Real-time network traffic monitoring and analysis"))

s = m:section(TypedSection, "settings", translate("Service Status"))  -- 修改这里
s.anonymous = true
s.addremove = false

enabled = s:option(Flag, "enabled", translate("Enable Service"))
enabled.rmempty = false

log_level = s:option(ListValue, "log_level", translate("Log Level"))
log_level:value("debug", "Debug")
log_level:value("info", "Info")
log_level:value("warning", "Warning")
log_level:value("error", "Error")
log_level.default = "info"

s = m:section(TypedSection, "monitor", translate("Traffic Monitoring"))  -- 修改这里
s.anonymous = true
s.addremove = false

sampling = s:option(Value, "sampling_rate", translate("Sampling Rate"), 
    translate("Packets per second to sample (1-1000)"))
sampling.datatype = "range(1,1000)"
sampling.default = "100"

protocols = s:option(Value, "capture_protocols", translate("Protocols to Monitor"))
protocols.default = "tcp udp icmp"

s = m:section(TypedSection, "rules", translate("Security Filters"))  -- 修改这里
s.anonymous = true
s.addremove = false

block = s:option(Flag, "block_suspicious", translate("Auto-block Suspicious Traffic"))
block.rmempty = false

alert_ports = s:option(DynamicList, "alert_ports", translate("Alert Ports"),
    translate("Ports that trigger alerts when accessed"))
alert_ports.datatype = "portrange"
alert_ports.default = "22,23,3389"

return m
