#!/bin/bash
svn_export() {
	# 参数1是分支名, 参数2是子目录, 参数3是目标目录, 参数4仓库地址
 	echo -e "clone $4/$2 to $3"
	TMP_DIR="$(mktemp -d)" || exit 1
 	ORI_DIR="$PWD"
	[ -d "$3" ] || mkdir -p "$3"
	TGT_DIR="$(cd "$3"; pwd)"
	git clone --depth 1 -b "$1" "$4" "$TMP_DIR" >/dev/null 2>&1 && \
	cd "$TMP_DIR/$2" && rm -rf .git >/dev/null 2>&1 && \
	cp -af . "$TGT_DIR/" && cd "$ORI_DIR"
	rm -rf "$TMP_DIR"
}

find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f

#rm -rf ./feeds/packages/lang/golang 
#git clone https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
rm -rf ./feeds/luci/applications/luci-app-adguardhome
rm -rf ./feeds/luci/applications/luci-app-passwall
rm -rf ./feeds/luci/applications/luci-app-filebrowser
rm -rf ./feeds/luci/applications/luci-app-ssr-*
rm -rf ./feeds/luci/applications/luci-app-argon-config
rm -rf ./feeds/luci/themes/luci-theme-argon
rm -rf ./feeds/packages/net/xray-core

# fix shadowsocks-rust for mipsel
curl -sfL https://github.com/sbwml/openwrt_helloworld/raw/refs/heads/v5/shadowsocks-rust/Makefile > feeds/packages/net/shadowsocks-rust/Makefile

git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
git clone --depth 1 https://github.com/fw876/helloworld package/helloworld
git clone --depth 1 https://github.com/sbwml/luci-app-openlist2 package/luci-app-openlist2
#git clone --depth 1 https://github.com/hudra0/luci-app-qosmate package/luci-app-qosmate
#git clone --depth 1 https://github.com/hudra0/qosmate package/qosmate
svn_export "v5" "luci-app-mosdns" "package/luci-app-mosdns" "https://github.com/sbwml/luci-app-mosdns"
svn_export "v5" "mosdns" "package/mosdns" "https://github.com/sbwml/luci-app-mosdns"
svn_export "v5" "v2dat" "package/v2dat" "https://github.com/sbwml/luci-app-mosdns"
svn_export "main" "easytier" "package/easytier" "https://github.com/EasyTier/luci-app-easytier"
svn_export "main" "luci-app-easytier" "package/luci-app-easytier" "https://github.com/EasyTier/luci-app-easytier"

mv ./package/adguardhome/* ./package/ && rm -rf ./package/adguardhome

sed -i 's/7a0154d2de18373e52783d1b64cf5204471049c2d2c64f0b3323d7f430aa4275/da5af052265fbfba7a11ee4195257f9bc13f44d054d8fdcbace0639360870035/g' package/helloworld/simple-obfs/Makefile

# turboacc 补丁
#curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh

# 安装插件
./scripts/feeds update -i
./scripts/feeds install -a

# 个性化设置
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ Wing build $(TZ=UTC-8 date "+%Y.%m.%d")')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")
sed -i 's/ImmortalWrt/Redmi-AX6/' package/base-files/files/bin/config_generate
sed -i "s/key='.*'/key=123456789/g" ./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
sed -i "s/country='.*'/country='CN'/g" ./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
sed -i "s/encryption='.*'/encryption='sae-mixed'/g" ./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# DNS劫持
sed -i '/dns_redirect/d' package/network/services/dnsmasq/files/dhcp.conf
cd package
# 汉化
curl -sfL -o ./convert_translation.sh https://github.com/kenzok8/small-package/raw/main/.github/diy/convert_translation.sh
chmod +x ./convert_translation.sh && bash -v ./convert_translation.sh