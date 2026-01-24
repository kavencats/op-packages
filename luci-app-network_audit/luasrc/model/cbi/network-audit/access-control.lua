m = Map("network-audit", translate("Access Control"),
    translate("Configure access control rules and filtering."))

s = m:section(NamedSection, "access", "access", translate("Access Control Settings"))

o = s:option(Flag, "enable_filtering", translate("Enable Filtering"),
    translate("Enable network access filtering"))
o.default = "0"

o = s:option(Flag, "block_by_default", translate("Block by Default"),
    translate("Block all traffic by default, allow only specified rules"))
o.default = "0"
o:depends("enable_filtering", "1")

-- IP黑名单
s2 = m:section(TypedSection, "blacklist", translate("IP Blacklist"),
    translate("IP addresses to block"))
s2.template = "cbi/tblsection"
s2.addremove = true
s2.anonymous = true

o = s2:option(Value, "ip", translate("IP Address"))
o.datatype = "ipaddr"
o.rmempty = false

o = s2:option(Value, "comment", translate("Description"))
o.rmempty = true

-- 端口限制
s3 = m:section(TypedSection, "port_restrict", translate("Port Restrictions"),
    translate("Restrict access to specific ports"))
s3.template = "cbi/tblsection"
s3.addremove = true
s3.anonymous = true

o = s3:option(Value, "port", translate("Port"))
o.datatype = "portrange"
o.rmempty = false

o = s3:option(ListValue, "action", translate("Action"))
o:value("allow", translate("Allow"))
o:value("deny", translate("Deny"))
o.default = "deny"

o = s3:option(Value, "protocol", translate("Protocol"))
o:value("tcp", "TCP")
o:value("udp", "UDP")
o:value("tcpudp", "TCP/UDP")
o.default = "tcpudp"

o = s3:option(Value, "comment", translate("Description"))
o.rmempty = true

-- 时间限制
s4 = m:section(TypedSection, "time_restrict", translate("Time Restrictions"),
    translate("Restrict access during specific time periods"))
s4.template = "cbi/tblsection"
s4.addremove = true
s4.anonymous = true

o = s4:option(Value, "start_time", translate("Start Time (HH:MM)"))
o.datatype = "timehhmm"
o.rmempty = false

o = s4:option(Value, "end_time", translate("End Time (HH:MM)"))
o.datatype = "timehhmm"
o.rmempty = false

o = s4:option(MultiValue, "days", translate("Days of Week"))
o:value("mon", translate("Monday"))
o:value("tue", translate("Tuesday"))
o:value("wed", translate("Wednesday"))
o:value("thu", translate("Thursday"))
o:value("fri", translate("Friday"))
o:value("sat", translate("Saturday"))
o:value("sun", translate("Sunday"))
o.widget = "checkbox"
o.rmempty = false

o = s4:option(Value, "comment", translate("Description"))
o.rmempty = true

return m