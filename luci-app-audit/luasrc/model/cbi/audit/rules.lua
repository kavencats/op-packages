m = Map("audit", translate("Audit Rules"),
    translate("Configure specific audit rules and event monitoring criteria"))

s = m:section(TypedSection, "rule", translate("Audit Rules"))
s.template = "cbi/tblsection"
s.anonymous = true
s.addremove = true

o = s:option(Value, "name", translate("Rule Name"))
o.placeholder = "Enter rule name"
o.rmempty = false

o = s:option(ListValue, "action", translate("Action"))
o:value("log", translate("Log Only"))
o:value("alert", translate("Generate Alert"))
o:value("block", translate("Block and Log"))
o.default = "log"

o = s:option(ListValue, "target", translate("Target"))
o:value("system", translate("System Events"))
o:value("network", translate("Network Events"))
o:value("authentication", translate("Authentication"))
o:value("file", translate("File System"))
o.default = "system"

o = s:option(MultiValue, "events", translate("Events to Monitor"))
o:value("package_install", translate("Package Installation"))
o:value("service_change", translate("Service Changes"))
o:value("config_modification", translate("Configuration Changes"))
o:value("nftables_rule_change", translate("nftables Rule Changes"))
o:value("port_scan", translate("Port Scanning"))
o:value("connection_attempt", translate("Connection Attempts"))
o:value("login_success", translate("Successful Logins"))
o:value("login_failure", translate("Failed Logins"))
o:value("privilege_escalation", translate("Privilege Escalation"))
o.widget = "checkbox"
o.size = 5

o = s:option(Value, "severity", translate("Severity Level"))
o:value("low", translate("Low"))
o:value("medium", translate("Medium"))
o:value("high", translate("High"))
o:value("critical", translate("Critical"))
o.default = "medium"

return m