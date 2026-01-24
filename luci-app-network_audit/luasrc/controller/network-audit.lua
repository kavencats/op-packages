module("luci.controller.network-audit", package.seeall)

function index()
    entry({"admin", "services", "network-audit"}, firstchild(), _("Network Audit"), 60).dependent = false
    
    entry({"admin", "services", "network-audit", "general"}, cbi("network-audit/general"), _("General Settings"), 10)
    entry({"admin", "services", "network-audit", "traffic"}, cbi("network-audit/traffic-monitor"), _("Traffic Monitor"), 20)
    entry({"admin", "services", "network-audit", "access"}, cbi("network-audit/access-control"), _("Access Control"), 30)
    entry({"admin", "services", "network-audit", "logs"}, cbi("network-audit/logs"), _("Audit Logs"), 40)
    entry({"admin", "services", "network-audit", "status"}, template("network-audit/status"), _("Real-time Status"), 50)
    
    entry({"admin", "services", "network-audit", "get_status"}, call("get_network_status"))
    entry({"admin", "services", "network-audit", "get_connections"}, call("get_active_connections"))
    entry({"admin", "services", "network-audit", "get_traffic_stats"}, call("get_traffic_statistics"))
    entry({"admin", "services", "network-audit", "clear_logs"}, call("clear_audit_logs"))
end

function get_network_status()
    local uci = require("luci.model.uci").cursor()
    local sys = require("luci.sys")
    local json = require("luci.jsonc")
    
    local status = {
        enabled = uci:get("network-audit", "general", "enabled") or "0",
        connections = get_connection_count(),
        bandwidth = get_bandwidth_usage(),
        blocked = get_blocked_count()
    }
    
    luci.http.prepare_content("application/json")
    luci.http.write_json(status)
end

function get_active_connections()
    local sys = require("luci.sys")
    local json = require("luci.jsonc")
    
    local connections = {}
    local conntrack = sys.net.conntrack() or {}
    
    for _, conn in ipairs(conntrack) do
        table.insert(connections, {
            src = conn.src or "",
            dst = conn.dst or "",
            sport = conn.sport or "",
            dport = conn.dport or "",
            proto = conn.proto or "",
            state = conn.state or "",
            bytes = conn.bytes or 0,
            packets = conn.packets or 0
        })
    end
    
    luci.http.prepare_content("application/json")
    luci.http.write_json(connections)
end

function get_traffic_statistics()
    local sys = require("luci.sys")
    local json = require("luci.jsonc")
    
    local stats = sys.exec("cat /proc/net/dev 2>/dev/null")
    local traffic = {}
    
    for line in stats:gmatch("[^\r\n]+") do
        local iface, data = line:match("^%s*(%w+):%s*(.+)$")
        if iface and not iface:match("^lo$") then
            local rx, tx = data:match("(%d+)%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+(%d+)")
            if rx and tx then
                traffic[iface] = {
                    rx = tonumber(rx),
                    tx = tonumber(tx)
                }
            end
        end
    end
    
    luci.http.prepare_content("application/json")
    luci.http.write_json(traffic)
end

function get_connection_count()
    local sys = require("luci.sys")
    local count = 0
    
    local f = io.popen("conntrack -L 2>/dev/null | wc -l")
    if f then
        count = tonumber(f:read("*a")) or 0
        f:close()
    end
    
    return count
end

function get_bandwidth_usage()
    local sys = require("luci.sys")
    local rx_total, tx_total = 0, 0
    
    local f = io.popen("cat /proc/net/dev 2>/dev/null")
    if f then
        for line in f:lines() do
            local iface, data = line:match("^%s*(%w+):%s*(.+)$")
            if iface and not iface:match("^lo$") then
                local rx, tx = data:match("(%d+)%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+(%d+)")
                if rx and tx then
                    rx_total = rx_total + tonumber(rx)
                    tx_total = tx_total + tonumber(tx)
                end
            end
        end
        f:close()
    end
    
    return {rx = rx_total, tx = tx_total}
end

function get_blocked_count()
    local sys = require("luci.sys")
    local count = 0
    
    local f = io.popen("iptables -L FORWARD -n -v 2>/dev/null | grep DROP | wc -l")
    if f then
        count = tonumber(f:read("*a")) or 0
        f:close()
    end
    
    return count
end

function clear_audit_logs()
    local sys = require("luci.sys")
    
    sys.call("echo '' > /var/log/network-audit.log 2>/dev/null")
    sys.call("logger -t network-audit 'Audit logs cleared by user'")
    
    luci.http.status(200, "Logs cleared")
end