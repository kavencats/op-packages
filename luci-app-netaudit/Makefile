include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-netaudit
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_MAINTAINER:=OpenWrt Developer
PKG_LICENSE:=Apache-2.0

LUCI_TITLE:=Network Audit Plugin
LUCI_DESCRIPTION:=Network traffic monitoring and auditing tool
LUCI_DEPENDS:=+lua +libubus-lua +luci-compat +luci-lib-ip +luci-lib-nixio +tc +iptables-mod-filter +dnsmasq-full
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/conffiles
/etc/config/netaudit
endef

# call BuildPackage - OpenWrt buildroot signature
$(eval $(call BuildPackage,$(PKG_NAME)))