m = Map("network-audit", translate("Network Audit General Settings"),
    translate("Configure general settings for network auditing and monitoring."))

s = m:section(NamedSection, "general", "general", translate("General Settings"))

o = s:option(Flag, "enabled", translate("Enable Network Audit"),
    translate("Enable network traffic auditing and monitoring"))
o.default = "0"
o.rmempty = false

o = s:option(Flag, "log_traffic", translate("Log Traffic"),
    translate("Log all network traffic information"))
o.default = "1"

o = s:option(Value, "log_level", translate("Log Level"),
    translate("Set the verbosity level for logging"))
o:value("0", translate("None"))
o:value("1", translate("Minimal"))
o:value("2", translate("Normal"))
o:value("3", translate("Detailed"))
o.default = "2"

o = s:option(Value, "log_size", translate("Maximum Log Size (MB)"),
    translate("Maximum size of audit log file"))
o.datatype = "uinteger"
o.default = "10"

o = s:option(Flag, "real_time_monitor", translate("Real-time Monitoring"),
    translate("Enable real-time network connection monitoring"))
o.default = "1"

o = s:option(ListValue, "monitor_interval", translate("Monitor Interval (seconds)"))
for i = 1, 60 do
    if i % 5 == 0 or i == 1 or i == 2 or i == 3 then
        o:value(tostring(i), tostring(i))
    end
end
o.default = "5"

o = s:option(DynamicList, "exclude_ips", translate("Exclude IP Addresses"),
    translate("IP addresses to exclude from monitoring (one per line)"))
o.datatype = "ipaddr"

o = s:option(DynamicList, "exclude_ports", translate("Exclude Ports"),
    translate("Ports to exclude from monitoring (one per line)"))
o.datatype = "portrange"

return m