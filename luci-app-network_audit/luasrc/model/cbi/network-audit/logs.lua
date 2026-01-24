m = Map("network-audit", translate("Audit Logs"),
    translate("Configure logging and log viewing settings."))

s = m:section(NamedSection, "logs", "logs", translate("Log Settings"))

o = s:option(Flag, "enable_logging", translate("Enable Logging"),
    translate("Enable audit log recording"))
o.default = "1"

o = s:option(Value, "log_file", translate("Log File Path"))
o.default = "/var/log/network-audit.log"
o.rmempty = false

o = s:option(Flag, "log_connections", translate("Log New Connections"),
    translate("Log all new network connections"))
o.default = "1"

o = s:option(Flag, "log_dropped", translate("Log Dropped Packets"),
    translate("Log all dropped/blocked packets"))
o.default = "1"

o = s:option(Flag, "log_bandwidth", translate("Log Bandwidth Usage"),
    translate("Log periodic bandwidth usage statistics"))
o.default = "0"

o = s:option(Value, "log_interval", translate("Log Interval (minutes)"))
o.datatype = "uinteger"
o.default = "5"
o:depends("log_bandwidth", "1")

o = s:option(Flag, "syslog", translate("Send to System Log"),
    translate("Also send audit events to system log (syslog)"))
o.default = "0"

o = s:option(Flag, "log_rotate", translate("Auto Rotate Logs"),
    translate("Automatically rotate log files when they get too large"))
o.default = "1"

o = s:option(Value, "keep_logs", translate("Keep Logs (days)"))
o.datatype = "uinteger"
o.default = "7"

s2 = m:section(SimpleSection)
s2.template = "network-audit/log_viewer"

return m