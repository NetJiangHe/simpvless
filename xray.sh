#!/bin/sh

# 1. 严格的系统环境识别
if [ -f /etc/alpine-release ]; then
    OS="alpine"
    apk add --no-cache curl openssl jq ca-certificates
elif [ -f /etc/debian_version ]; then
    OS="debian"
    apt-get update && apt-get install -y curl openssl jq
else
    echo "Unsupported OS" && exit 1
fi

# 2. 安装 Xray 核心
# 使用官方脚本安装二进制文件
curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s -- install

# 3. 【针对 Alpine】手动配置 OpenRC 服务
if [ "$OS" = "alpine" ]; then
    cat <<EOF > /etc/init.d/xray
#!/sbin/openrc-run
description="Xray Service"
command="/usr/local/bin/xray"
command_args="run -c /usr/local/etc/xray/config.json"
pidfile="/run/xray.pid"
command_background=true
depend() {
    need net
}
EOF
    chmod +x /etc/init.d/xray
    rc-update add xray default >/dev/null 2>&1
fi

# 4. 【针对 Alpine 优化】提取密钥
# 关键修复：使用 tr 过滤掉所有非打印字符和 ANSI 颜色代码
KEYS=$(/usr/local/bin/xray x25519)
PRIV_KEY=$(echo "$KEYS" | grep -i "Private" | awk '{print $NF}' | tr -d '\r' | sed 's/\x1b\[[0-9;]*m//g')
PUB_KEY=$(echo "$KEYS" | grep -E "Public|Password" | awk '{print $NF}' | tr -d '\r' | sed 's/\x1b\[[0-9;]*m//g')
SHORT_ID=$(openssl rand -hex 4)

# 5. 交互式选择伪装域名
echo "--------------------------------------------------"
echo "请选择 REALITY 伪装域名:"
echo "1) Apple (gateway.icloud.com)"
echo "2) Microsoft (www.microsoft.com)"
echo "3) Google DL (dl.google.com)"
echo "4) LoL CDN (lol.secure.dyn.riotcdn.net)"
echo "5) Tesla (www.tesla.com)"
echo "6) NVIDIA (www.nvidia.com)"
echo "7) 自定义输入"
read -p "请输入序号 [1-7, 默认 1]: " DOMAIN_CHOICE

case $DOMAIN_CHOICE in
    2) DEST="www.microsoft.com" ;;
    3) DEST="dl.google.com" ;;
    4) DEST="lol.secure.dyn.riotcdn.net" ;;
    5) DEST="www.tesla.com" ;;
    6) DEST="www.nvidia.com" ;;
    7) read -p "请输入自定义域名: " DEST ;;
    *) DEST="gateway.icloud.com" ;;
esac

# 6. 端口设置
read -p "内网监听端口 (默认 443): " LISTEN_PORT
LISTEN_PORT=${LISTEN_PORT:-443}

# 7. 写入配置文件
mkdir -p /usr/local/etc/xray
cat <<EOF > /usr/local/etc/xray/config.json
{
    "log": {"loglevel": "warning"},
    "inbounds": [{
        "port": $LISTEN_PORT,
        "protocol": "vless",
        "settings": {
            "clients": [{"id": "$UUID", "flow": "xtls-rprx-vision"}],
            "decryption": "none"
        },
        "streamSettings": {
            "network": "tcp",
            "security": "reality",
            "realitySettings": {
                "show": false,
                "dest": "$DEST:443",
                "xver": 0,
                "serverNames": ["$DEST"],
                "privateKey": "$PRIV_KEY",
                "shortIds": ["$SHORT_ID"]
            }
        }
    }],
    "outbounds": [{"protocol": "freedom"}]
}
EOF

# 8. 启动服务
if [ "$OS" = "alpine" ]; then
    rc-service xray restart
else
    systemctl restart xray
fi

# 9. 生成链接
PUBLIC_IP=$(curl -s https://api.ipify.org || curl -s https://ipv4.icanhazip.com)
echo "--------------------------------------------------"
echo "检测到公网 IP: $PUBLIC_IP"
read -p "请输入公网映射端口 (直接回车默认使用 $LISTEN_PORT): " PUBLIC_PORT
PUBLIC_PORT=${PUBLIC_PORT:-$LISTEN_PORT}

VLESS_LINK="vless://$UUID@$PUBLIC_IP:$PUBLIC_PORT?type=tcp&security=reality&flow=xtls-rprx-vision&sni=$DEST&fp=chrome&pbk=$PUB_KEY&sid=$SHORT_ID#NAT_REALITY"

echo "--------------------------------------------------"
echo -e "\033[32m安装成功！您的 VLESS 链接如下:\033[0m"
echo ""
echo -e "\033[33m$VLESS_LINK\033[0m"
echo ""
echo "--------------------------------------------------"
