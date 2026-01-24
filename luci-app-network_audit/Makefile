include $(TOPDIR)/rules.mk

LUCI_TITLE:=Network Audit and Monitoring
LUCI_DEPENDS:=+lua +luci-compat +luci-lib-ip +luci-lib-nixio +kmod-nfnetlink +kmod-nfnetlink-log +conntrack
LUCI_PKGARCH:=all
PKG_VERSION:=1.0.1
PKG_RELEASE:=1

PKG_NAME:=luci-app-network_audit
PKG_MAINTAINER:=OpenWRT Developer
PKG_LICENSE:=Apache-2.0

include $(TOPDIR)/feeds/luci/luci.mk

# 安装后设置文件权限
define Package/$(PKG_NAME)/postinst
#!/bin/sh
[ -f "$${IPKG_INSTROOT}/etc/init.d/network-audit" ] && chmod 0755 "$${IPKG_INSTROOT}/etc/init.d/network-audit" || true
[ -f "$${IPKG_INSTROOT}/usr/libexec/rpcd/network-audit" ] && chmod 0755 "$${IPKG_INSTROOT}/usr/libexec/rpcd/network-audit" || true
[ -f "$${IPKG_INSTROOT}/usr/bin/network-audit" ] && chmod 0755 "$${IPKG_INSTROOT}/usr/bin/network-audit" || true
exit 0
endef

# 卸载前停止服务
define Package/$(PKG_NAME)/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
    /etc/init.d/network-audit disable 2>/dev/null || true
    /etc/init.d/network-audit stop 2>/dev/null || true
fi
exit 0
endef

# 安装时启用服务
define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -f "$${IPKG_INSTROOT}/etc/init.d/network-audit" ]; then
    chmod 0755 "$${IPKG_INSTROOT}/etc/init.d/network-audit" || true
fi
if [ -f "$${IPKG_INSTROOT}/usr/libexec/rpcd/network-audit" ]; then
    chmod 0755 "$${IPKG_INSTROOT}/usr/libexec/rpcd/network-audit" || true
fi
if [ -f "$${IPKG_INSTROOT}/usr/bin/network-audit" ]; then
    chmod 0755 "$${IPKG_INSTROOT}/usr/bin/network-audit" || true
fi
if [ -z "$${IPKG_INSTROOT}" ]; then
    /etc/init.d/network-audit enable 2>/dev/null || true
    /etc/init.d/network-audit start 2>/dev/null || true
fi
exit 0
endef

# call BuildPackage - OpenWrt buildroot signature