module("luci.controller.netaudit", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/netaudit") then
        return
    end

    entry({"admin", "services", "netaudit"}, alias("admin", "services", "netaudit", "overview"), _("Network Audit"), 60).dependent = true
    
    entry({"admin", "services", "netaudit", "overview"}, cbi("netaudit/overview"), _("Overview"), 10)
    entry({"admin", "services", "netaudit", "monitoring"}, cbi("netaudit/monitoring"), _("Traffic Monitoring"), 20)
    entry({"admin", "services", "netaudit", "filtering"}, cbi("netaudit/filtering"), _("Domain Filtering"), 30)
    entry({"admin", "services", "netaudit", "settings"}, cbi("netaudit/settings"), _("Settings"), 40)
    
    entry({"admin", "services", "netaudit", "status"}, call("action_status")).leaf = true
    entry({"admin", "services", "netaudit", "logs"}, call("action_logs")).leaf = true
    entry({"admin", "services", "netaudit", "clear_logs"}, post("action_clear_logs")).leaf = true
    entry({"admin", "services", "netaudit", "get_stats"}, call("action_get_stats")).leaf = true
end

function action_status()
    local uci = require("luci.model.uci").cursor()
    local sys = require("luci.sys")
    
    local enabled = uci:get("netaudit", "settings", "enabled") or "0"  -- 修改这里
    local running = sys.call("pgrep -f '/usr/lib/lua/netaudit/analyzer.lua' >/dev/null") == 0
    
    luci.http.prepare_content("application/json")
    luci.http.write_json({
        enabled = enabled == "1",
        running = running,
        service = running and "Running" or "Stopped"
    })
end

function action_logs()
    local http = require "luci.http"
    local sys = require "luci.sys"
    
    local log_file = "/var/log/netaudit.log"
    local logs = ""
    
    if nixio.fs.access(log_file) then
        logs = sys.exec("tail -100 " .. log_file)
    end
    
    http.prepare_content("text/plain")
    http.write(logs)
end

function action_clear_logs()
    local sys = require "luci.sys"
    sys.call("> /var/log/netaudit.log")
    
    luci.http.redirect(luci.dispatcher.build_url("admin/services/netaudit/settings"))
end

function action_get_stats()
    local http = require "luci.http"
    local sys = require "luci.sys"
    
    local stats = {
        traffic = {
            total = sys.exec("cat /proc/net/dev | awk 'NR>2{sum+=$2+$10}END{print sum}'") or "0",
            incoming = sys.exec("cat /proc/net/dev | awk 'NR>2{sum+=$2}END{print sum}'") or "0",
            outgoing = sys.exec("cat /proc/net/dev | awk 'NR>2{sum+=$10}END{print sum}'") or "0"
        },
        connections = {
            tcp = sys.exec("netstat -tn 2>/dev/null | grep '^tcp' | wc -l") or "0",
            udp = sys.exec("netstat -un 2>/dev/null | grep '^udp' | wc -l") or "0"
        },
        top_clients = sys.exec("cat /proc/net/ip_conntrack 2>/dev/null | awk '{print $7}' | cut -d= -f2 | sort | uniq -c | sort -rn | head -5") or ""
    }
    
    http.prepare_content("application/json")
    http.write_json(stats)

end
