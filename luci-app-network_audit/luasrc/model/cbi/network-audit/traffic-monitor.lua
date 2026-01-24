m = Map("network-audit", translate("Traffic Monitoring"),
    translate("Configure traffic monitoring and bandwidth usage tracking."))

s = m:section(NamedSection, "traffic", "traffic", translate("Traffic Settings"))

o = s:option(Flag, "monitor_all", translate("Monitor All Interfaces"),
    translate("Monitor traffic on all network interfaces"))
o.default = "1"

o = s:option(DynamicList, "interfaces", translate("Interfaces to Monitor"),
    translate("Network interfaces to monitor (if not monitoring all)"))
local net = require "luci.model.network".init()
net:foreach("interface", "interface",
    function(section)
        if section[".name"] ~= "loopback" then
            o:value(section[".name"])
        end
    end)

o = s:option(Flag, "track_bandwidth", translate("Track Bandwidth Usage"),
    translate("Track historical bandwidth usage"))
o.default = "1"

o = s:option(Value, "bandwidth_history", translate("History Duration (hours)"))
o:value("1", "1 " .. translate("hour"))
o:value("6", "6 " .. translate("hours"))
o:value("12", "12 " .. translate("hours"))
o:value("24", "24 " .. translate("hours"))
o:value("168", "7 " .. translate("days"))
o.default = "24"

o = s:option(Flag, "alert_threshold", translate("Enable Bandwidth Alerts"),
    translate("Send alerts when bandwidth exceeds threshold"))
o.default = "0"

o = s:option(Value, "threshold_mbps", translate("Bandwidth Threshold (Mbps)"))
o.datatype = "ufloat"
o.default = "100"
o:depends("alert_threshold", "1")

o = s:option(Flag, "track_protocols", translate("Track Protocol Usage"),
    translate("Track traffic by protocol (TCP/UDP/ICMP/etc)"))
o.default = "1"

o = s:option(Flag, "track_countries", translate("Track Geographic Locations"),
    translate("Attempt to track traffic by country (requires GeoIP database)"))
o.default = "0"

return m