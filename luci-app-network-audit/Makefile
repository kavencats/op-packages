include $(TOPDIR)/rules.mk

LUCI_TITLE:=Network Audit and Monitoring
LUCI_DEPENDS:=+lua +luci-compat +luci-lib-ip +luci-lib-nixio +kmod-nfnetlink +kmod-nfnetlink-log
LUCI_PKGARCH:=all
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_NAME:=luci-app-network-audit
PKG_MAINTAINER:=OpenWRT Developer
PKG_LICENSE:=Apache-2.0

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature