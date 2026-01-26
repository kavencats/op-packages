local uci = require "luci.model.uci".cursor()

m = Map("audit", translate("Audit System Settings"),
    translate("Configure global audit system parameters and monitoring options"))

s = m:section(TypedSection, "global", translate("Global Settings"))
s.anonymous = true
s.addremove = false

o = s:option(Flag, "enabled", translate("Enable Audit System"))
o.default = "1"
o.rmempty = false

o = s:option(ListValue, "log_level", translate("Log Level"))
o:value("debug", translate("Debug"))
o:value("info", translate("Info"))
o:value("warn", translate("Warning"))
o:value("error", translate("Error"))
o.default = "info"

o = s:option(Value, "log_file", translate("Log File Path"))
o.datatype = "filepath"
o.default = "/var/log/audit.log"

o = s:option(Value, "max_log_size", translate("Maximum Log Size (bytes)"))
o.datatype = "uinteger"
o.default = "1000000"

o = s:option(Value, "retention_days", translate("Log Retention (days)"))
o.datatype = "uinteger"
o.default = "30"

-- Monitoring options
s = m:section(TypedSection, "global", translate("Monitoring Targets"))
s.anonymous = true

o = s:option(Flag, "monitor_system", translate("Monitor System Events"))
o.default = "1"
o.description = translate("Monitor package installations, service changes, and configuration modifications")

o = s:option(Flag, "monitor_network", translate("Monitor Network Events"))
o.default = "1"
o.description = translate("Monitor firewall changes, port scans, and connection attempts")

o = s:option(Flag, "monitor_login", translate("Monitor Authentication Events"))
o.default = "1"
o.description = translate("Monitor login attempts, privilege changes, and user activities")

-- nftables specific settings
s = m:section(TypedSection, "global", translate("Firewall Settings"))
s.anonymous = true

o = s:option(Flag, "enable_nftables_logging", translate("Enable nftables Logging"))
o.default = "1"
o.description = translate("Enable nftables-specific logging rules for enhanced network audit")

o = s:option(ListValue, "nftables_log_level", translate("nftables Log Level"))
o:value("emerg", "Emergency")
o:value("alert", "Alert")
o:value("crit", "Critical")
o:value("err", "Error")
o:value("warn", "Warning")
o:value("notice", "Notice")
o:value("info", "Info")
o:value("debug", "Debug")
o.default = "info"
o:depends("enable_nftables_logging", "1")

return m