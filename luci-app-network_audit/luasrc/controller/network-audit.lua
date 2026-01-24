module("luci.controller.network-audit", package.seeall)

function index()
    entry({"admin", "services", "network-audit"}, firstchild(), _("Network Audit"), 60).dependent = false
    
    entry({"admin", "services", "network-audit", "overview"}, 
          template("network-audit/overview"), 
          _("Overview"), 10)
    
    entry({"admin", "services", "network-audit", "settings"}, 
          cbi("network-audit/general"), 
          _("Settings"), 20)
    
    entry({"admin", "services", "network-audit", "logs"}, 
          call("action_logs"), 
          _("Logs"), 30)
    
    entry({"admin", "services", "network-audit", "rules"}, 
          call("action_rules"), 
          _("Rules"), 40)
    
    entry({"admin", "services", "network-audit", "status"}, 
          call("action_status")).leaf = true
    
    entry({"admin", "services", "network-audit", "start"}, 
          call("action_start")).leaf = true
    
    entry({"admin", "services", "network-audit", "stop"}, 
          call("action_stop")).leaf = true
    
    entry({"admin", "services", "network-audit", "restart"}, 
          call("action_restart")).leaf = true
    
    entry({"admin", "services", "network-audit", "get_logs"}, 
          call("action_get_logs")).leaf = true
    
    entry({"admin", "services", "network-audit", "clear_logs"}, 
          call("action_clear_logs")).leaf = true
end

function action_status()
    local uci = require "luci.model.uci".cursor()
    local sys = require "luci.sys"
    
    local status = {
        running = (sys.call("pidof network-audit >/dev/null") == 0),
        enabled = (uci:get("network-audit", "general", "enabled") or "0") == "1",
        version = "1.0.0"
    }
    
    luci.http.prepare_content("application/json")
    luci.http.write_json(status)
end

function action_start()
    local sys = require "luci.sys"
    sys.call("/etc/init.d/network-audit start >/dev/null 2>&1")
    luci.http.prepare_content("application/json")
    luci.http.write_json({success = true})
end

function action_stop()
    local sys = require "luci.sys"
    sys.call("/etc/init.d/network-audit stop >/dev/null 2>&1")
    luci.http.prepare_content("application/json")
    luci.http.write_json({success = true})
end

function action_restart()
    local sys = require "luci.sys"
    sys.call("/etc/init.d/network-audit restart >/dev/null 2>&1")
    luci.http.prepare_content("application/json")
    luci.http.write_json({success = true})
end

function action_logs()
    local template = require "luci.template"
    template.render("network-audit/logs", {})
end

function action_rules()
    local template = require "luci.template"
    template.render("network-audit/rules", {})
end

function action_get_logs()
    local fs = require "nixio.fs"
    local log_file = "/var/log/network-audit.log"
    local logs = ""
    
    if fs.access(log_file, "r") then
        logs = fs.readfile(log_file) or ""
    end
    
    luci.http.prepare_content("text/plain")
    luci.http.write(logs)
end

function action_clear_logs()
    local sys = require "luci.sys"
    sys.call("echo '' > /var/log/network-audit.log 2>/dev/null")
    luci.http.prepare_content("application/json")
    luci.http.write_json({success = true})
end