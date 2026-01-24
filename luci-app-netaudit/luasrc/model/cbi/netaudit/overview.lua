local sys = require "luci.sys"
local http = require "luci.http"
local uci = require "luci.model.uci".cursor()

m = Map("netaudit", translate("Network Audit - Overview"), 
    translate("Network traffic monitoring and auditing overview"))

s = m:section(TypedSection, "global", translate("Service Status"))
s.anonymous = true
s.addremove = false

status = s:option(DummyValue, "_status", translate("Service Status"))
status.template = "netaudit/status"

btn = s:option(Button, "_control", translate("Service Control"))
btn.inputtitle = translate("Restart Service")
btn.inputstyle = "apply"
function btn.write()
    sys.call("/etc/init.d/netaudit restart >/dev/null 2>&1")
    luci.http.redirect(luci.dispatcher.build_url("admin/services/netaudit/overview"))
end

s = m:section(TypedSection, "global", translate("Real-time Statistics"))
s.anonymous = true

traffic = s:option(DummyValue, "_traffic", translate("Total Traffic"))
traffic.template = "netaudit/traffic_stats"

connections = s:option(DummyValue, "_connections", translate("Active Connections"))
connections.template = "netaudit/connection_stats"

log = s:option(TextValue, "_log", translate("Recent Logs"))
log.rows = 10
log.readonly = true
function log.cfgvalue()
    local log_file = "/var/log/netaudit.log"
    if nixio.fs.access(log_file) then
        return sys.exec("tail -20 " .. log_file)
    end
    return translate("No logs available")
end

return m