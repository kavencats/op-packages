module("luci.controller.audit", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/audit") then
        return
    end

    entry({"admin", "services", "audit"}, firstchild(), _("Audit System"), 60).dependent = false
    
    entry({"admin", "services", "audit", "dashboard"}, template("audit/dashboard"), _("Dashboard"), 1)
    entry({"admin", "services", "audit", "settings"}, cbi("audit/settings"), _("Settings"), 2)
    entry({"admin", "services", "audit", "rules"}, cbi("audit/rules"), _("Rules"), 3)
    entry({"admin", "services", "audit", "logs"}, template("audit/log"), _("Logs"), 4)
    
    entry({"admin", "services", "audit", "status"}, call("action_status"))
    entry({"admin", "services", "audit", "get_logs"}, call("action_get_logs"))
    entry({"admin", "services", "audit", "clear_logs"}, call("action_clear_logs"))
end

function action_status()
    luci.http.prepare_content("application/json")
    
    local status = {
        running = luci.sys.call("pgrep audit-daemon >/dev/null") == 0,
        nftables = luci.sys.call("nft list table inet audit >/dev/null 2>&1") == 0,
        log_size = 0,
        last_event = "N/A"
    }
    
    local log_file = luci.model.uci.cursor():get("audit", "global", "log_file") or "/var/log/audit.log"
    if nixio.fs.access(log_file) then
        status.log_size = nixio.fs.stat(log_file).size
        -- Get last event timestamp
        local last_line = luci.sys.exec("tail -1 " .. log_file .. " 2>/dev/null")
        if last_line and #last_line > 0 then
            status.last_event = last_line:match("^[%d:-]+") or "N/A"
        end
    end
    
    luci.http.write_json(status)
end

function action_get_logs()
    luci.http.prepare_content("text/plain")
    
    local cursor = luci.model.uci.cursor()
    local log_file = cursor:get("audit", "global", "log_file") or "/var/log/audit.log"
    local lines = tonumber(luci.http.formvalue("lines")) or 100
    
    if nixio.fs.access(log_file) then
        local logs = luci.sys.exec("tail -n " .. lines .. " " .. log_file)
        luci.http.write(logs or "No log data available")
    else
        luci.http.write("Log file not found: " .. log_file)
    end
end

function action_clear_logs()
    luci.http.prepare_content("application/json")
    
    local cursor = luci.model.uci.cursor()
    local log_file = cursor:get("audit", "global", "log_file") or "/var/log/audit.log"
    
    local result = { success = false, message = "" }
    
    if nixio.fs.access(log_file) then
        if luci.sys.call("echo '' > " .. log_file) == 0 then
            result.success = true
            result.message = "Logs cleared successfully"
        else
            result.message = "Failed to clear logs"
        end
    else
        result.message = "Log file not found"
    end
    
    luci.http.write_json(result)
end