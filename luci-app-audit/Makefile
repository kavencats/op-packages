include $(TOPDIR)/rules.mk

LUCI_TITLE:=Audit Function Plugin for OpenWrt
LUCI_DESCRIPTION:=A comprehensive audit system for monitoring and logging system events with nftables support
LUCI_DEPENDS:=+luci-base +lua +nftables-json +logd +ubus-utils
LUCI_PKGARCH:=all
LUCI_LANG:=zh-cn en

PKG_NAME:=luci-app-audit
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Audit Developer <audit@example.com>

include $(TOPDIR)/feeds/luci/luci.mk

define Package/luci-app-audit/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
    # Apply nftables rules
    /etc/init.d/nftables reload >/dev/null 2>&1
    # Enable audit service
    /etc/init.d/audit enable >/dev/null 2>&1
    # Restart rpcd for ACL
    /etc/init.d/rpcd restart >/dev/null 2>&1
}
exit 0
endef

# call BuildPackage - OpenWrt buildroot signature