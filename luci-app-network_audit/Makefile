include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Network Audit Application
LUCI_DEPENDS:=+iptables +kmod-nf-log +rpcd +rpcd-mod-file +tc +conntrack
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-network-audit
PKG_VERSION:=1.0.1
PKG_RELEASE:=2
PKG_MAINTAINER:=Your Name <your.email@example.com>
PKG_LICENSE:=Apache-2.0

include $(TOPDIR)/feeds/luci/luci.mk

# Pre-remove script
define Package/$(PKG_NAME)/prerm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
    # 在真实系统上运行时清理
    echo "Stopping network-audit service before removal..."
    /etc/init.d/network-audit stop >/dev/null 2>&1
    sleep 2
    /etc/init.d/network-audit disable >/dev/null 2>&1
}
exit 0
endef

# Post-remove script
define Package/$(PKG_NAME)/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
    # 在真实系统上运行时完全清理
    echo "Cleaning up network-audit configuration..."
    
    # 移除 iptables 规则
    iptables -D INPUT -j NETWORK_AUDIT_INPUT 2>/dev/null
    iptables -D FORWARD -j NETWORK_AUDIT_FORWARD 2>/dev/null
    iptables -D OUTPUT -j NETWORK_AUDIT_OUTPUT 2>/dev/null
    
    iptables -F NETWORK_AUDIT_INPUT 2>/dev/null
    iptables -F NETWORK_AUDIT_FORWARD 2>/dev/null
    iptables -F NETWORK_AUDIT_OUTPUT 2>/dev/null
    
    iptables -X NETWORK_AUDIT_INPUT 2>/dev/null
    iptables -X NETWORK_AUDIT_FORWARD 2>/dev/null
    iptables -X NETWORK_AUDIT_OUTPUT 2>/dev/null
    
    # 清理 PID 文件
    rm -f /var/run/network-audit.pid
    rm -rf /var/run/network-audit
    
    # 清理配置文件
    uci delete network-audit 2>/dev/null
    uci commit network-audit 2>/dev/null
    rm -f /etc/config/network-audit
    
    # 清理日志文件
    rm -f /var/log/network-audit.log
    
    echo "Network audit plugin completely removed."
}
exit 0
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	cp -pR ./luasrc/* $(1)/usr/lib/lua/luci/
	
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/network-audit $(1)/etc/config/
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/network-audit $(1)/etc/init.d/
	
	$(INSTALL_DIR) $(1)/etc/ucidefs.d
	$(INSTALL_BIN) ./root/etc/ucidefs.d/network-audit.sh $(1)/etc/ucidefs.d/
	
	$(INSTALL_DIR) $(1)/etc/network-audit
	$(INSTALL_BIN) ./root/etc/network-audit/uninstall.sh $(1)/etc/network-audit/
	$(INSTALL_BIN) ./root/etc/network-audit/pre-remove $(1)/etc/network-audit/
	$(INSTALL_BIN) ./root/etc/network-audit/post-remove $(1)/etc/network-audit/
	
	$(INSTALL_DIR) $(1)/usr/libexec/rpcd
	$(INSTALL_BIN) ./root/usr/libexec/rpcd/network-audit $(1)/usr/libexec/rpcd/
	
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_CONF) ./root/usr/share/rpcd/acl.d/luci-app-network-audit.json $(1)/usr/share/rpcd/acl.d/
	
	$(INSTALL_DIR) $(1)/usr/share/network-audit/scripts
	$(INSTALL_BIN) ./root/usr/share/network-audit/scripts/audit.sh $(1)/usr/share/network-audit/scripts/
	
	$(INSTALL_DIR) $(1)/usr/share/network-audit/rules
	$(INSTALL_CONF) ./root/usr/share/network-audit/rules/default.rules $(1)/usr/share/network-audit/rules/
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) ./po/zh_Hans/network-audit.po $(1)/usr/lib/lua/luci/i18n/
	$(INSTALL_DATA) ./po/network-audit.pot $(1)/usr/lib/lua/luci/i18n/
endef

# call BuildPackage - OpenWrt buildroot signature

