m = Map("netaudit", translate("Traffic Monitoring"),
    translate("Configure network traffic monitoring settings"))

s = m:section(TypedSection, "monitoring", translate("Monitoring Settings"))
s.anonymous = true
s.addremove = false

enable = s:option(Flag, "enabled", translate("Enable Monitoring"),
    translate("Enable network traffic monitoring"))
enable.default = "1"

interval = s:option(Value, "interval", translate("Update Interval (seconds)"))
interval.datatype = "range(1,3600)"
interval.default = "5"
interval:depends({enabled = "1"})

log_level = s:option(ListValue, "log_level", translate("Log Level"))
log_level:value("0", translate("Disabled"))
log_level:value("1", translate("Minimal"))
log_level:value("2", translate("Normal"))
log_level:value("3", translate("Verbose"))
log_level.default = "2"

monitor_protocols = s:option(MultiValue, "protocols", translate("Monitor Protocols"))
monitor_protocols:value("tcp", "TCP")
monitor_protocols:value("udp", "UDP")
monitor_protocols:value("icmp", "ICMP")
monitor_protocols.default = "tcp udp"

log_connections = s:option(Flag, "log_connections", translate("Log New Connections"),
    translate("Log all new network connections"))
log_connections.default = "1"

max_connections = s:option(Value, "max_connections", translate("Max Connections Log"),
    translate("Maximum connections to log (0 for unlimited)"))
max_connections.datatype = "uinteger"
max_connections.default = "1000"

s = m:section(TypedSection, "threshold", translate("Traffic Thresholds"))
s.template = "cbi/tblsection"
s.addremove = true
s.anonymous = true

interface = s:option(ListValue, "interface", translate("Interface"))
local net = require "luci.model.network".init()
net:foreach("interface", "interface",
    function(section)
        if section[".name"] ~= "loopback" then
            interface:value(section[".name"], section[".name"])
        end
    end)

threshold_type = s:option(ListValue, "type", translate("Threshold Type"))
threshold_type:value("bandwidth", translate("Bandwidth"))
threshold_type:value("connections", translate("Connections"))

threshold_value = s:option(Value, "value", translate("Threshold Value"))
threshold_value.datatype = "uinteger"

action = s:option(ListValue, "action", translate("Action"))
action:value("log", translate("Log Only"))
action:value("alert", translate("Send Alert"))
action:value("limit", translate("Limit Bandwidth"))

return m