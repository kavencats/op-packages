m = Map("netaudit", translate("Advanced Settings"))

s = m:section(TypedSection, "settings", translate("Log Settings"))
s.anonymous = true
s.addremove = false

rotation = s:option(ListValue, "log_rotation", translate("Log Rotation"))
rotation:value("hourly", "Hourly")
rotation:value("daily", "Daily")
rotation:value("weekly", "Weekly")
rotation.default = "daily"

max_size = s:option(Value, "max_log_size", translate("Max Log Size (MB)"))
max_size.datatype = "uinteger"
max_size.default = "10"

store_days = s:option(Value, "store_days", translate("Store Days"))
store_days.datatype = "uinteger"
store_days.default = "30"

s = m:section(TypedSection, "monitor", translate("Network Interfaces"))
s.anonymous = true
s.addremove = false

track_local = s:option(Flag, "track_local", translate("Track Local Traffic"))
track_local.default = "1"
track_local.rmempty = false

track_wan = s:option(Flag, "track_wan", translate("Track WAN Traffic"))
track_wan.default = "1"
track_wan.rmempty = false

track_lan = s:option(Flag, "track_lan", translate("Track LAN Traffic"))
track_lan.default = "1"
track_lan.rmempty = false

s = m:section(TypedSection, "alerts", translate("Notifications"))
s.anonymous = true
s.addremove = false

syslog_alerts = s:option(Flag, "syslog_alerts", translate("Syslog Alerts"))
syslog_alerts.default = "1"

email_alerts = s:option(Flag, "email_alerts", translate("Email Alerts"))
email_alerts.default = "0"

alert_interval = s:option(Value, "alert_interval", translate("Alert Interval (seconds)"))
alert_interval.datatype = "uinteger"
alert_interval.default = "300"

return m
