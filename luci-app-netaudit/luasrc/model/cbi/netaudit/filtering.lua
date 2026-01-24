m = Map("netaudit", translate("Domain Filtering"),
    translate("Configure domain and URL filtering rules"))

s = m:section(TypedSection, "filtering", translate("Filtering Settings"))
s.anonymous = true
s.addremove = false

enable_filter = s:option(Flag, "enabled", translate("Enable Filtering"),
    translate("Enable domain and URL filtering"))
enable_filter.default = "0"

filter_mode = s:option(ListValue, "mode", translate("Filtering Mode"))
filter_mode:value("blacklist", translate("Blacklist (block listed)"))
filter_mode:value("whitelist", translate("Whitelist (allow only listed)"))
filter_mode.default = "blacklist"
filter_mode:depends({enabled = "1"})

s = m:section(TypedSection, "domain", translate("Domain Rules"))
s.template = "cbi/tblsection"
s.addremove = true
s.anonymous = true

domain = s:option(Value, "domain", translate("Domain"))
domain.datatype = "hostname"

description = s:option(Value, "description", translate("Description"))

action = s:option(ListValue, "action", translate("Action"))
action:value("block", translate("Block"))
action:value("log", translate("Log Only"))
action:value("redirect", translate("Redirect"))

redirect_url = s:option(Value, "redirect", translate("Redirect URL"))
redirect_url:depends({action = "redirect"})
redirect_url.datatype = "url"

s = m:section(TypedSection, "category", translate("Category Filtering"))
s.template = "cbi/tblsection"
s.addremove = true
s.anonymous = true

category_name = s:option(ListValue, "name", translate("Category"))
category_name:value("social", translate("Social Media"))
category_name:value("gaming", translate("Gaming"))
category_name:value("shopping", translate("Shopping"))
category_name:value("streaming", translate("Video Streaming"))
category_name:value("p2p", translate("P2P File Sharing"))
category_name:value("adult", translate("Adult Content"))

category_action = s:option(ListValue, "action", translate("Action"))
category_action:value("block", translate("Block"))
category_action:value("limit", translate("Limit Access"))
category_action:value("schedule", translate("Schedule Block"))

schedule = s:option(Value, "schedule", translate("Schedule"))
schedule:depends({action = "schedule"})
schedule.placeholder = "e.g., 08:00-17:00"

return m