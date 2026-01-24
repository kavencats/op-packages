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
    local sys = require "luci.sys"
    local fs = require "nixio.fs"
    local uci = require "luci.model.uci"
    local cursor = uci.cursor()
    
    local status = {
        running = false,
        enabled = false,
        version = "1.0.0",
        uptime = "0s"
    }
    
    -- Check if service is running
    local pid = sys.exec("pgrep -f 'network-audit' 2>/dev/null | head -1")
    if pid and pid:match("%d+") then
        status.running = true
        
        -- Get uptime
        local uptime_cmd = string.format("ps -o etime= -p %s 2>/dev/null", pid:match("%d+"))
        local uptime = sys.exec(uptime_cmd)
        if uptime and uptime:match("%S+") then
            status.uptime = uptime:gsub("%s+", "")
        end
    end
    
    -- Check if enabled in config
    cursor:foreach("network-audit", "network-audit", 
        function(section)
            if section[".type"] == "general" then
                status.enabled = (section.enabled or "0") == "1"
            end
        end
    )
    
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
        -- Limit to last 1000 lines
        local lines = {}
        for line in logs:gmatch("[^\r\n]+") do
            table.insert(lines, line)
        end
        if #lines > 1000 then
            logs = table.concat(lines, "\n", #lines - 999)
        end
    else
        logs = translate("No log file found. Service may not be running.")
    end
    
    luci.http.prepare_content("text/plain; charset=utf-8")
    luci.http.write(logs)
end

function action_clear_logs()
    local sys = require "luci.sys"
    local fs = require "nixio.fs"
    local log_file = "/var/log/network-audit.log"
    
    if fs.access(log_file, "w") then
        fs.writefile(log_file, "")
        luci.http.prepare_content("application/json")
        luci.http.write_json({success = true, message = translate("Logs cleared successfully")})
    else
        luci.http.prepare_content("application/json")
        luci.http.write_json({success = false, error = translate("Cannot write to log file")})
    end
end

