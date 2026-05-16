<p align="center">
  <img src="https://img.shields.io/badge/OpenWrt-LuCI-1565C0?style=for-the-badge&logo=openwrt&logoColor=white" alt="OpenWrt" />
  <img src="https://img.shields.io/badge/Theme-Argon-00BCD4?style=for-the-badge&logo=css3&logoColor=white" alt="Argon Theme" />
  <img src="https://img.shields.io/badge/Version-2.4.3-4CAF50?style=for-the-badge" alt="Version" />
  <img src="https://img.shields.io/badge/Branch-openwrt--25.12-FF5722?style=for-the-badge" alt="Branch" />
</p>

<h1 align="center">🎨 Argon Theme for OpenWrt LuCI</h1>

<p align="center">
  <strong>A clean, modern, and beautiful LuCI theme for OpenWrt</strong>
</p>

<p align="center">
  <a href="https://github.com/MomoFlora/luci-theme-argon">
    <img src="https://img.shields.io/badge/GitHub-Repository-181717?style=flat-square&logo=github" alt="GitHub" />
  </a>
  <img src="https://img.shields.io/badge/License-Apache%202.0-orange?style=flat-square" alt="License" />
  <img src="https://img.shields.io/badge/Author-jerrykuku-blue?style=flat-square" alt="Author" />
  <img src="https://img.shields.io/badge/Platform-OpenWrt-lightgrey?style=flat-square" alt="Platform" />
</p>

---

## ✨ Features

- **Modern Design** - Clean and elegant interface with Material Design inspired
- **Responsive Layout** - Perfect adaptation to desktop, tablet and mobile devices
- **Dark/Light Mode** - Switch between light and dark themes freely
- **Customizable** - Rich configuration options via LuCI app
- **High Performance** - Optimized CSS and JavaScript for smooth experience
- **Wallpaper Support** - Set custom background images
- **Multi-language** - Built-in internationalization support

## 📦 Components

### luci-theme-argon

The core theme package containing all UI assets and styles.

| Attribute | Value |
|-----------|-------|
| Version | 2.4.3 |
| Release | 20250722 |
| Dependencies | wget-any, jsonfilter |
| License | Apache License 2.0 |

### luci-app-argon-config

Configuration application for customizing the Argon theme.

| Attribute | Value |
|-----------|-------|
| Version | 1.0 |
| Release | 20230608 |
| Dependencies | luci-theme-argon |
| Config File | /etc/config/argon |

## 🚀 Installation

### Method 1: Compile from Source

```bash
# Clone to your OpenWrt package directory (openwrt-25.12 branch)
git clone -b openwrt-25.12 https://github.com/MomoFlora/luci-theme-argon.git package/luci-theme-argon

# Update feeds and compile
./scripts/feeds update -a
./scripts/feeds install -a

make menuconfig
# Navigate to: LuCI -> Themes -> luci-theme-argon
# Navigate to: LuCI -> Applications -> luci-app-argon-config

make -j$(nproc)
```

### Method 2: Install via IPK

```bash
# Upload ipk files to your router
scp *.ipk root@192.168.1.1:/tmp/

# SSH into your router and install
ssh root@192.168.1.1
cd /tmp
opkg install luci-theme-argon_*.ipk
opkg install luci-app-argon-config_*.ipk
```

## ⚙️ Configuration

After installation, access the configuration panel:

1. Log in to LuCI web interface
2. Navigate to **System** → **Argon Config**
3. Customize your preferences:
   - Theme mode (Light/Dark/Auto)
   - Background image
   - Primary color
   - Blur effect
   - Transparency settings

## 🖼️ Preview

| Light Mode | Dark Mode |
|------------|-----------|
| Clean and bright interface | Elegant dark interface |

## 📁 Project Structure

```
.
├── luci-theme-argon/           # Theme core package
│   ├── htdocs/                 # Web assets (CSS, JS, images)
│   ├── less/                   # LESS source files
│   ├── root/                   # System files
│   ├── ucode/                  # Ucode templates
│   └── Makefile                # Build configuration
│
├── luci-app-argon-config/      # Configuration application
│   ├── htdocs/                 # Web assets
│   ├── po/                     # Translation files
│   ├── root/                   # System files
│   └── Makefile                # Build configuration
│
└── README.md                   # Project documentation
```

## 📝 Changelog

### v2.4.3 (2025-07-22)
- Theme core updates and optimizations

### v1.0 (2023-06-08)
- Initial release of config application
- Russian language support

## 🤝 Credits

- **Original Author**: [jerrykuku](https://github.com/jerrykuku)
- **Current Maintainer**: [MomoFlora](https://github.com/MomoFlora)
- **Repository**: https://github.com/MomoFlora/luci-theme-argon
- **Branch**: openwrt-25.12
- **License**: Apache License, Version 2.0
- **Based on**: OpenWrt LuCI framework

## 📄 License

This project is licensed under the Apache License, Version 2.0.

```
Copyright (C) 2008-2019 Jerrykuku

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

---

<p align="center">
  Made with ❤️ by the OpenWrt Community
</p>
