include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Network Audit Application
LUCI_DEPENDS:=+iptables +kmod-nf-log +rpcd +rpcd-mod-file +tc +conntrack-tools
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-network-audit
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Your Name <your.email@example.com>
PKG_LICENSE:=Apache-2.0

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature