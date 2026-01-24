m = Map("netaudit", translate("Plugin Settings"),
    translate("Configure general plugin settings"))

s = m:section(TypedSection, "settings", translate("General Settings"))
s.anonymous = true
s.addremove = false

data_retention = s:option(Value, "retention", translate("Data Retention (days)"))
data_retention.datatype = "range(1,365)"
data_retention.default = "30"

log_size = s:option(Value, "log_size", translate("Max Log Size (MB)"))
log_size.datatype = "range(1,1024)"
log_size.default = "10"

auto_update = s:option(Flag, "auto_update", translate("Auto Update Rules"),
    translate("Automatically update filtering rules"))
auto_update.default = "0"

update_schedule = s:option(Value, "update_schedule", translate("Update Schedule"))
update_schedule:depends({auto_update = "1"})
update_schedule.placeholder = "0 2 * * *"
update_schedule.default = "0 2 * * *"

s = m:section(TypedSection, "notification", translate("Notifications"))
s.anonymous = true

email_notify = s:option(Flag, "email_enabled", translate("Enable Email Notifications"))
email_notify.default = "0"

email_address = s:option(Value, "email", translate("Email Address"))
email_address:depends({email_enabled = "1"})
email_address.datatype = "email"

webhook_enable = s:option(Flag, "webhook_enabled", translate("Enable Webhook"))
webhook_enable.default = "0"

webhook_url = s:option(Value, "webhook_url", translate("Webhook URL"))
webhook_url:depends({webhook_enabled = "1"})
webhook_url.datatype = "url"

s = m:section(TypedSection, "advanced", translate("Advanced Settings"))
s.anonymous = true

debug_mode = s:option(Flag, "debug", translate("Debug Mode"))
debug_mode.default = "0"

flush_logs = s:option(Button, "_flush", translate("System Logs"))
flush_logs.inputtitle = translate("Clear All Logs")
flush_logs.inputstyle = "remove"
function flush_logs.write()
    os.execute("> /var/log/netaudit.log")
    luci.http.redirect(luci.dispatcher.build_url("admin/services/netaudit/settings"))
end

backup_config = s:option(Button, "_backup", translate("Configuration"))
backup_config.inputtitle = translate("Backup Configuration")
backup_config.inputstyle = "apply"
function backup_config.write()
    os.execute("uci export netaudit > /tmp/netaudit_backup.uci")
    luci.http.redirect(luci.dispatcher.build_url("admin/services/netaudit/settings"))
end

return m