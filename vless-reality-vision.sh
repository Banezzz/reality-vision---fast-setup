#!/usr/bin/env bash
set -euo pipefail
export LANG=en_US.UTF-8

# =========================
# VLESS TCP REALITY Vision 自动化脚本
# 改进版：动态SNI选择 + 二维码展示
# =========================

ENV_FILE="/root/reality_vision.env"
XRAY_BIN="/usr/local/bin/xray"
XRAY_CONF="/usr/local/etc/xray/config.json"
SERVICE="xray"

PORT_MIN=10000
PORT_MAX=65535

# SNI 域名列表（用于延迟测试）
SNI_LIST=(
    "www.tesla.com"
    "digitalassets.tesla.com"
    "location-services-prd.tesla.com"
    "www.apple.com"
    "apps.apple.com"
    "xp.apple.com"
    "ocsp2.apple.com"
    "iosapps.itunes.apple.com"
    "fpinit.itunes.apple.com"
    "se-edge.itunes.apple.com"
    "downloaddispatch.itunes.apple.com"
    "amp-api-edge.apps.apple.com"
    "gsp-ssl.ls.apple.com"
    "configuration.ls.apple.com"
    "apps.mzstatic.com"
    "is1-ssl.mzstatic.com"
    "statici.icloud.com"
    "www.icloud.com"
    "www.microsoft.com"
    "azure.microsoft.com"
    "visualstudio.microsoft.com"
    "devblogs.microsoft.com"
    "c.s-microsoft.com"
    "store-images.s-microsoft.com"
    "res.public.onecdn.static.microsoft"
    "cdn-dynmedia-1.microsoft.com"
    "res-1.cdn.office.net"
    "img-prod-cms-rt-microsoft-com.akamaized.net"
    "aadcdn.msftauth.net"
    "acctcdn.msftauth.net"
    "www.bing.com"
    "r.bing.com"
    "th.bing.com"
    "ts2.tc.mm.bing.net"
    "ts3.tc.mm.bing.net"
    "ts4.tc.mm.bing.net"
    "aws.com"
    "aws.amazon.com"
    "vs.aws.amazon.com"
    "d2c.aws.amazon.com"
    "s0.awsstatic.com"
    "d1.awsstatic.com"
    "t0.m.awsstatic.com"
    "d0.m.awsstatic.com"
    "a.b.cdn.console.awsstatic.com"
    "prod.pa.cdn.uis.awsstatic.com"
    "prod.us-east-1.ui.gcr-chat.marketing.aws.dev"
    "prod.log.shortbread.aws.dev"
    "d3agakyjgjv5i8.cloudfront.net"
    "intel.com"
    "www.intel.com"
    "amd.com"
    "www.amd.com"
    "download.amd.com"
    "drivers.amd.com"
    "www.nvidia.com"
    "images.nvidia.com"
    "www.sony.com"
    "electronics.sony.com"
    "www.xbox.com"
    "assets-www.xbox.com"
    "assets-xbxweb.xbox.com"
    "sisu.xboxlive.com"
    "catalog.gamepass.com"
    "www.oracle.com"
    "d.oracleinfinity.io"
    "lpcdn.lpsnmedia.net"
    "publisher.liveperson.net"
    "tag-logger.demandbase.com"
    "tag.demandbase.com"
    "tags.tiqcdn.com"
    "cdn.userway.org"
    "cdn77.api.userway.org"
    "s7mbrstream.scene7.com"
    "api.company-target.com"
    "s.company-target.com"
    "gray-config-prod.api.arc-cdn.net"
    "gray-config-prod.api.cdn.arcpublishing.com"
    "gray.video-player.arcpublishing.com"
    "gray-wowt-prod.gtv-cdn.com"
    "beacon.gtv-pub.com"
    "www.wowt.com"
    "rum.hlx.page"
    "s.go-mpulse.net"
    "ms-python.gallerycdn.vsassets.io"
    "ms-vscode.gallerycdn.vsassets.io"
    "vscjava.gallerycdn.vsassets.io"
    "i7158c100-ds-aksb-a.akamaihd.net"
    "d.impactradius-event.com"
    "consent.trustarc.com"
    "munchkin.marketo.net"
    "logx.optimizely.com"
    "static.cloud.coveo.com"
    "mscom.demdex.net"
    "j.6sc.co"
    "b.6sc.co"
    "c.6sc.co"
    "ipv6.6sc.co"
    "cdn.bizibly.com"
    "cdn.bizible.com"
    "cdnssl.clicktale.net"
    "assets.adobedtm.com"
    "snap.licdn.com"
    "www.xilinx.com"
    "ce.mf.marsflag.com"
    "s.mp.marsflag.com"
)

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

is_root() { [[ "${EUID}" -eq 0 ]]; }

is_port_free() {
    ! ss -lnt | awk '{print $4}' | grep -qE "[:.]$1$"
}

install_deps() {
    log_info "安装依赖..."
    apt-get update -y >/dev/null 2>&1
    apt-get install -y curl unzip openssl ca-certificates iproute2 qrencode >/dev/null 2>&1
}

install_xray() {
    log_info "安装 Xray..."
    bash <(curl -Ls https://github.com/XTLS/Xray-install/raw/main/install-release.sh) >/dev/null 2>&1
}

gen_uuid() {
    UUID="${uuid:-$(cat /proc/sys/kernel/random/uuid)}"
}

choose_port() {
    if [[ -n "${vlpt:-}" ]]; then
        PORT="$vlpt"
    else
        while true; do
            PORT="$(shuf -i ${PORT_MIN}-${PORT_MAX} -n 1)"
            if is_port_free "$PORT"; then
                break
            fi
        done
    fi
}

gen_reality_keys() {
    log_info "生成 Reality 密钥..."
    local KEYS
    KEYS="$("$XRAY_BIN" x25519)"
    PRIVATE_KEY="$(echo "$KEYS" | awk -F'[: ]+' '/PrivateKey|Private key/ {print $2}')"
    PUBLIC_KEY="$(echo "$KEYS" | awk -F'[: ]+' '/PublicKey|Public key/ {print $2}')"
    SHORT_ID="$(openssl rand -hex 4)"
}

# 测试单个域名延迟
test_domain_latency() {
    local domain="$1"
    local t1 t2
    t1=$(date +%s%3N)
    if timeout 2 openssl s_client -connect "${domain}:443" -servername "$domain" </dev/null &>/dev/null; then
        t2=$(date +%s%3N)
        echo "$((t2 - t1))"
    else
        echo "9999"
    fi
}

# 动态选择最低延迟的 SNI
select_best_sni() {
    log_info "测试 SNI 域名延迟（从 ${#SNI_LIST[@]} 个域名中选择最优）..."

    local best_domain=""
    local best_latency=9999
    local tested=0
    local sample_size=20  # 随机抽样测试数量，加快速度

    # 随机打乱数组并取前 sample_size 个
    local shuffled_domains
    shuffled_domains=$(printf '%s\n' "${SNI_LIST[@]}" | shuf | head -n "$sample_size")

    echo -e "${CYAN}测试中...${NC}"

    while IFS= read -r domain; do
        tested=$((tested + 1))
        printf "\r测试进度: %d/%d - 当前: %s                    " "$tested" "$sample_size" "$domain"

        local latency
        latency=$(test_domain_latency "$domain")

        if [[ "$latency" -lt "$best_latency" && "$latency" -ne 9999 ]]; then
            best_latency="$latency"
            best_domain="$domain"
        fi
    done <<< "$shuffled_domains"

    printf "\n"

    if [[ -z "$best_domain" ]]; then
        log_warn "所有测试域名均超时，使用默认 SNI: www.tesla.com"
        SNI="www.tesla.com"
    else
        log_info "选择最优 SNI: ${best_domain} (延迟: ${best_latency}ms)"
        SNI="$best_domain"
    fi
}

write_config() {
    mkdir -p /usr/local/etc/xray
    cat > "$XRAY_CONF" <<JSON
{
  "inbounds": [{
    "listen": "0.0.0.0",
    "port": $PORT,
    "protocol": "vless",
    "settings": {
      "clients": [{ "id": "$UUID", "flow": "xtls-rprx-vision" }],
      "decryption": "none"
    },
    "streamSettings": {
      "network": "tcp",
      "security": "reality",
      "realitySettings": {
        "dest": "$SNI:443",
        "serverNames": ["$SNI"],
        "privateKey": "$PRIVATE_KEY",
        "shortIds": ["$SHORT_ID"]
      }
    }
  }],
  "outbounds": [{ "protocol": "freedom" }]
}
JSON
}

save_env() {
    cat > "$ENV_FILE" <<ENV
SERVER_IP=$SERVER_IP
PORT=$PORT
UUID=$UUID
SNI=$SNI
PUBLIC_KEY=$PUBLIC_KEY
SHORT_ID=$SHORT_ID
ENV
    chmod 600 "$ENV_FILE"
}

get_share_link() {
    source "$ENV_FILE"
    echo "vless://${UUID}@${SERVER_IP}:${PORT}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${SNI}&fp=chrome&pbk=${PUBLIC_KEY}&sid=${SHORT_ID}&type=tcp#RV-Reality-Vision"
}

show_qrcode() {
    local link="$1"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                    节点二维码（扫码导入）${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    qrencode -t ANSIUTF8 "$link"
    echo ""
    echo -e "${YELLOW}提示: 二维码仅显示一次，可运行 'bash $0 qr' 重新生成${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
}

show_info() {
    source "$ENV_FILE"
    local link
    link=$(get_share_link)

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                     VLESS Reality Vision 节点信息${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${BLUE}服务器地址:${NC} $SERVER_IP"
    echo -e "  ${BLUE}端口:${NC}       $PORT"
    echo -e "  ${BLUE}UUID:${NC}       $UUID"
    echo -e "  ${BLUE}Flow:${NC}       xtls-rprx-vision"
    echo -e "  ${BLUE}SNI:${NC}        $SNI"
    echo -e "  ${BLUE}PublicKey:${NC}  $PUBLIC_KEY"
    echo -e "  ${BLUE}ShortID:${NC}    $SHORT_ID"
    echo -e "  ${BLUE}Fingerprint:${NC} chrome"
    echo ""
    echo -e "${CYAN}───────────────────────────────────────────────────────────────${NC}"
    echo -e "${GREEN}分享链接:${NC}"
    echo -e "${YELLOW}$link${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
}

cmd_install() {
    if ! is_root; then
        log_error "请使用 root 用户运行此脚本"
        exit 1
    fi

    log_info "开始安装 VLESS TCP REALITY Vision..."

    install_deps
    install_xray

    # 如果用户指定了 reym，使用用户的选择；否则动态测试
    if [[ -n "${reym:-}" ]]; then
        SNI="$reym"
        log_info "使用指定 SNI: $SNI"
    else
        select_best_sni
    fi

    gen_uuid
    choose_port
    gen_reality_keys

    SERVER_IP="$(curl -s --max-time 10 https://api.ipify.org || curl -s --max-time 10 https://ifconfig.me || echo "YOUR_SERVER_IP")"

    write_config

    systemctl enable xray >/dev/null 2>&1
    systemctl restart xray

    save_env

    log_info "安装完成！"

    # 显示节点信息
    show_info

    # 显示二维码
    local link
    link=$(get_share_link)
    show_qrcode "$link"

    echo ""
    log_info "常用命令:"
    echo "  查看节点信息: bash $0 info"
    echo "  显示二维码:   bash $0 qr"
    echo "  卸载:         bash $0 uninstall"
}

cmd_info() {
    if [[ ! -f "$ENV_FILE" ]]; then
        log_error "未找到配置文件，请先运行 install"
        exit 1
    fi
    show_info
}

cmd_qr() {
    if [[ ! -f "$ENV_FILE" ]]; then
        log_error "未找到配置文件，请先运行 install"
        exit 1
    fi

    # 确保 qrencode 已安装
    if ! command -v qrencode &>/dev/null; then
        log_info "安装 qrencode..."
        apt-get update -y >/dev/null 2>&1
        apt-get install -y qrencode >/dev/null 2>&1
    fi

    local link
    link=$(get_share_link)
    show_qrcode "$link"
}

cmd_uninstall() {
    log_info "开始卸载..."
    systemctl stop xray 2>/dev/null || true
    systemctl disable xray 2>/dev/null || true
    rm -f "$XRAY_CONF" "$ENV_FILE"
    curl -Ls https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s -- remove >/dev/null 2>&1
    log_info "卸载完成"
}

cmd_test_sni() {
    log_info "测试所有 SNI 域名延迟..."
    echo ""

    declare -A results

    for domain in "${SNI_LIST[@]}"; do
        local latency
        latency=$(test_domain_latency "$domain")
        if [[ "$latency" -eq 9999 ]]; then
            echo -e "${RED}$domain: timeout${NC}"
        else
            echo -e "${GREEN}$domain: ${latency}ms${NC}"
            results["$domain"]=$latency
        fi
    done

    echo ""
    log_info "测试完成"
}

show_help() {
    echo ""
    echo -e "${CYAN}VLESS TCP REALITY Vision 脚本${NC}"
    echo ""
    echo "用法: bash $0 <命令> [参数]"
    echo ""
    echo "命令:"
    echo "  install     安装并配置节点（自动选择最优 SNI）"
    echo "  info        显示当前节点信息"
    echo "  qr          显示节点二维码"
    echo "  uninstall   卸载节点"
    echo "  test-sni    测试所有 SNI 域名延迟"
    echo ""
    echo "可选参数（install 时使用）:"
    echo "  reym=xxx    指定 SNI 域名（不指定则自动选择最优）"
    echo "  vlpt=xxx    指定端口（不指定则随机）"
    echo "  uuid=xxx    指定 UUID（不指定则随机生成）"
    echo ""
    echo "示例:"
    echo "  bash $0 install                           # 自动选择最优 SNI"
    echo "  reym=www.tesla.com vlpt=443 bash $0 install  # 指定参数安装"
    echo "  bash $0 qr                                # 显示二维码"
    echo ""
}

# 主入口
case "${1:-}" in
    install)
        cmd_install
        ;;
    info)
        cmd_info
        ;;
    qr)
        cmd_qr
        ;;
    uninstall)
        cmd_uninstall
        ;;
    test-sni)
        cmd_test_sni
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        ;;
esac
