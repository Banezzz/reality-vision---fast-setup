#!/usr/bin/env bash
set -euo pipefail
export LANG=en_US.UTF-8

# =========================
# VLESS TCP REALITY Vision 自动化脚本
# 改进版：动态SNI选择 + 二维码展示 + 多语言支持
# =========================

ENV_FILE="/root/reality_vision.env"
LANG_FILE="/root/reality_vision.lang"
XRAY_BIN="/usr/local/bin/xray"
XRAY_CONF="/usr/local/etc/xray/config.json"
SERVICE="xray"

PORT_MIN=10000
PORT_MAX=65535

# 语言设置 (zh/en)
CURRENT_LANG="${CURRENT_LANG:-}"

# SNI 域名列表（完整列表，用于延迟测试）
SNI_LIST=(
    "amd.com"
    "aws.com"
    "c.6sc.co"
    "j.6sc.co"
    "b.6sc.co"
    "intel.com"
    "r.bing.com"
    "th.bing.com"
    "www.amd.com"
    "www.aws.com"
    "ipv6.6sc.co"
    "www.xbox.com"
    "www.sony.com"
    "rum.hlx.page"
    "www.bing.com"
    "xp.apple.com"
    "www.wowt.com"
    "www.apple.com"
    "www.intel.com"
    "www.tesla.com"
    "www.xilinx.com"
    "www.oracle.com"
    "www.icloud.com"
    "apps.apple.com"
    "c.marsflag.com"
    "www.nvidia.com"
    "snap.licdn.com"
    "aws.amazon.com"
    "drivers.amd.com"
    "cdn.bizibly.com"
    "s.go-mpulse.net"
    "tags.tiqcdn.com"
    "cdn.bizible.com"
    "ocsp2.apple.com"
    "cdn.userway.org"
    "download.amd.com"
    "d1.awsstatic.com"
    "s0.awsstatic.com"
    "mscom.demdex.net"
    "a0.awsstatic.com"
    "go.microsoft.com"
    "apps.mzstatic.com"
    "sisu.xboxlive.com"
    "www.microsoft.com"
    "s.mp.marsflag.com"
    "images.nvidia.com"
    "vs.aws.amazon.com"
    "c.s-microsoft.com"
    "statici.icloud.com"
    "beacon.gtv-pub.com"
    "ts4.tc.mm.bing.net"
    "ts3.tc.mm.bing.net"
    "d2c.aws.amazon.com"
    "ts1.tc.mm.bing.net"
    "ce.mf.marsflag.com"
    "d0.m.awsstatic.com"
    "t0.m.awsstatic.com"
    "ts2.tc.mm.bing.net"
    "tag.demandbase.com"
    "assets-www.xbox.com"
    "logx.optimizely.com"
    "azure.microsoft.com"
    "aadcdn.msftauth.net"
    "d.oracleinfinity.io"
    "assets.adobedtm.com"
    "lpcdn.lpsnmedia.net"
    "res-1.cdn.office.net"
    "is1-ssl.mzstatic.com"
    "electronics.sony.com"
    "intelcorp.scene7.com"
    "acctcdn.msftauth.net"
    "cdnssl.clicktale.net"
    "catalog.gamepass.com"
    "consent.trustarc.com"
    "gsp-ssl.ls.apple.com"
    "munchkin.marketo.net"
    "s.company-target.com"
    "cdn77.api.userway.org"
    "cua-chat-ui.tesla.com"
    "assets-xbxweb.xbox.com"
    "ds-aksb-a.akamaihd.net"
    "static.cloud.coveo.com"
    "api.company-target.com"
    "devblogs.microsoft.com"
    "s7mbrstream.scene7.com"
    "fpinit.itunes.apple.com"
    "digitalassets.tesla.com"
    "d.impactradius-event.com"
    "downloadmirror.intel.com"
    "iosapps.itunes.apple.com"
    "se-edge.itunes.apple.com"
    "publisher.liveperson.net"
    "tag-logger.demandbase.com"
    "services.digitaleast.mobi"
    "configuration.ls.apple.com"
    "gray-wowt-prod.gtv-cdn.com"
    "visualstudio.microsoft.com"
    "prod.log.shortbread.aws.dev"
    "amp-api-edge.apps.apple.com"
    "store-images.s-microsoft.com"
    "cdn-dynmedia-1.microsoft.com"
    "github.gallerycdn.vsassets.io"
    "prod.pa.cdn.uis.awsstatic.com"
    "a.b.cdn.console.awsstatic.com"
    "d3agakyjgjv5i8.cloudfront.net"
    "vscjava.gallerycdn.vsassets.io"
    "location-services-prd.tesla.com"
    "ms-vscode.gallerycdn.vsassets.io"
    "ms-python.gallerycdn.vsassets.io"
    "gray-config-prod.api.arc-cdn.net"
    "i7158c100-ds-aksb-a.akamaihd.net"
    "downloaddispatch.itunes.apple.com"
    "res.public.onecdn.static.microsoft"
    "gray.video-player.arcpublishing.com"
    "gray-config-prod.api.cdn.arcpublishing.com"
    "img-prod-cms-rt-microsoft-com.akamaized.net"
    "prod.us-east-1.ui.gcr-chat.marketing.aws.dev"
)

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# ============== 多语言支持 ==============

# 获取翻译文本
msg() {
    local key="$1"
    if [[ "$CURRENT_LANG" == "en" ]]; then
        case "$key" in
            "menu_title") echo "VLESS TCP REALITY Vision Management" ;;
            "menu_install") echo "Install Node" ;;
            "menu_info") echo "View Node Info" ;;
            "menu_qr") echo "Show QR Code" ;;
            "menu_status") echo "Service Status" ;;
            "menu_restart") echo "Restart Service" ;;
            "menu_test_sni") echo "Test SNI Latency" ;;
            "menu_uninstall") echo "Uninstall" ;;
            "menu_lang") echo "Switch Language" ;;
            "menu_exit") echo "Exit" ;;
            "menu_choice") echo "Please enter your choice" ;;
            "menu_invalid") echo "Invalid option, please try again" ;;
            "menu_press_enter") echo "Press Enter to continue..." ;;
            "lang_select") echo "Select Language / 选择语言" ;;
            "lang_zh") echo "Chinese (中文)" ;;
            "lang_en") echo "English" ;;
            "installing") echo "Installing VLESS TCP REALITY Vision..." ;;
            "install_deps") echo "Installing dependencies..." ;;
            "install_xray") echo "Installing Xray..." ;;
            "gen_keys") echo "Generating Reality keys..." ;;
            "testing_sni") echo "Testing all SNI domains for latency..." ;;
            "testing") echo "Testing..." ;;
            "test_progress") echo "Progress" ;;
            "current") echo "Current" ;;
            "sni_timeout") echo "All test domains timed out, using default SNI: www.tesla.com" ;;
            "sni_selected") echo "Selected optimal SNI" ;;
            "sni_multiple") echo "Multiple domains have the same lowest latency" ;;
            "sni_choose") echo "Please choose one" ;;
            "latency") echo "latency" ;;
            "install_complete") echo "Installation complete!" ;;
            "uninstalling") echo "Uninstalling..." ;;
            "uninstall_complete") echo "Uninstall complete" ;;
            "config_not_found") echo "Configuration not found, please install first" ;;
            "run_as_root") echo "Please run this script as root" ;;
            "node_info") echo "VLESS Reality Vision Node Info" ;;
            "server_addr") echo "Server Address" ;;
            "port") echo "Port" ;;
            "share_link") echo "Share Link" ;;
            "qr_title") echo "Node QR Code (Scan to Import)" ;;
            "qr_tip") echo "Tip: Run 'bash $0 qr' to regenerate QR code" ;;
            "common_cmds") echo "Common commands" ;;
            "view_info") echo "View node info" ;;
            "show_qr") echo "Show QR code" ;;
            "service_status") echo "Service Status" ;;
            "service_restarted") echo "Service restarted" ;;
            "test_complete") echo "Test complete" ;;
            "timeout") echo "timeout" ;;
            "using_sni") echo "Using specified SNI" ;;
            "installed") echo "Installed" ;;
            "not_installed") echo "Not Installed" ;;
            "total_domains") echo "Total domains" ;;
            "best_latency") echo "Best latency" ;;
            *) echo "$key" ;;
        esac
    else
        case "$key" in
            "menu_title") echo "VLESS TCP REALITY Vision 管理面板" ;;
            "menu_install") echo "安装节点" ;;
            "menu_info") echo "查看节点信息" ;;
            "menu_qr") echo "显示二维码" ;;
            "menu_status") echo "服务状态" ;;
            "menu_restart") echo "重启服务" ;;
            "menu_test_sni") echo "测试 SNI 延迟" ;;
            "menu_uninstall") echo "卸载节点" ;;
            "menu_lang") echo "切换语言" ;;
            "menu_exit") echo "退出" ;;
            "menu_choice") echo "请输入选项" ;;
            "menu_invalid") echo "无效选项，请重新输入" ;;
            "menu_press_enter") echo "按 Enter 键继续..." ;;
            "lang_select") echo "Select Language / 选择语言" ;;
            "lang_zh") echo "中文" ;;
            "lang_en") echo "English (英文)" ;;
            "installing") echo "开始安装 VLESS TCP REALITY Vision..." ;;
            "install_deps") echo "安装依赖..." ;;
            "install_xray") echo "安装 Xray..." ;;
            "gen_keys") echo "生成 Reality 密钥..." ;;
            "testing_sni") echo "测试所有 SNI 域名延迟..." ;;
            "testing") echo "测试中..." ;;
            "test_progress") echo "进度" ;;
            "current") echo "当前" ;;
            "sni_timeout") echo "所有测试域名均超时，使用默认 SNI: www.tesla.com" ;;
            "sni_selected") echo "选择最优 SNI" ;;
            "sni_multiple") echo "多个域名具有相同的最低延迟" ;;
            "sni_choose") echo "请选择一个" ;;
            "latency") echo "延迟" ;;
            "install_complete") echo "安装完成！" ;;
            "uninstalling") echo "开始卸载..." ;;
            "uninstall_complete") echo "卸载完成" ;;
            "config_not_found") echo "未找到配置文件，请先运行安装" ;;
            "run_as_root") echo "请使用 root 用户运行此脚本" ;;
            "node_info") echo "VLESS Reality Vision 节点信息" ;;
            "server_addr") echo "服务器地址" ;;
            "port") echo "端口" ;;
            "share_link") echo "分享链接" ;;
            "qr_title") echo "节点二维码（扫码导入）" ;;
            "qr_tip") echo "提示: 可运行 'bash $0 qr' 重新生成二维码" ;;
            "common_cmds") echo "常用命令" ;;
            "view_info") echo "查看节点信息" ;;
            "show_qr") echo "显示二维码" ;;
            "service_status") echo "服务状态" ;;
            "service_restarted") echo "服务已重启" ;;
            "test_complete") echo "测试完成" ;;
            "timeout") echo "超时" ;;
            "using_sni") echo "使用指定 SNI" ;;
            "installed") echo "已安装" ;;
            "not_installed") echo "未安装" ;;
            "total_domains") echo "域名总数" ;;
            "best_latency") echo "最低延迟" ;;
            *) echo "$key" ;;
        esac
    fi
}

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

is_root() { [[ "${EUID}" -eq 0 ]]; }

is_port_free() {
    ! ss -lnt | awk '{print $4}' | grep -qE "[:.]$1$"
}

# 加载语言设置
load_lang() {
    if [[ -f "$LANG_FILE" ]]; then
        CURRENT_LANG=$(cat "$LANG_FILE")
    fi
}

# 保存语言设置
save_lang() {
    echo "$CURRENT_LANG" > "$LANG_FILE"
    chmod 600 "$LANG_FILE"
}

# 语言选择界面
select_language() {
    clear
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}           ${YELLOW}Select Language / 选择语言${NC}                        ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${GREEN}1.${NC} 中文 (Chinese)                                         ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${GREEN}2.${NC} English                                                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -n "   请选择 / Please choose [1-2]: "
    read -r lang_choice

    case "$lang_choice" in
        1)
            CURRENT_LANG="zh"
            ;;
        2)
            CURRENT_LANG="en"
            ;;
        *)
            CURRENT_LANG="zh"
            ;;
    esac
    save_lang
}

install_deps() {
    log_info "$(msg install_deps)"
    apt-get update -y >/dev/null 2>&1
    apt-get install -y curl unzip openssl ca-certificates iproute2 qrencode >/dev/null 2>&1
}

install_xray() {
    log_info "$(msg install_xray)"
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
    log_info "$(msg gen_keys)"
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

# 动态选择最低延迟的 SNI（测试所有域名）
select_best_sni() {
    local total=${#SNI_LIST[@]}
    log_info "$(msg testing_sni) ($(msg total_domains): $total)"

    declare -A latency_map
    local best_latency=9999
    local tested=0

    echo ""
    echo -e "${CYAN}$(msg testing)${NC}"

    for domain in "${SNI_LIST[@]}"; do
        tested=$((tested + 1))
        local percent=$((tested * 100 / total))
        printf "\r[%-50s] %d%% (%d/%d) - %s          " \
            "$(printf '#%.0s' $(seq 1 $((percent / 2))))" \
            "$percent" "$tested" "$total" "$domain"

        local latency
        latency=$(test_domain_latency "$domain")

        if [[ "$latency" -ne 9999 ]]; then
            latency_map["$domain"]=$latency
            if [[ "$latency" -lt "$best_latency" ]]; then
                best_latency=$latency
            fi
        fi
    done

    printf "\n\n"

    # 检查是否有可用域名
    if [[ ${#latency_map[@]} -eq 0 ]]; then
        log_warn "$(msg sni_timeout)"
        SNI="www.tesla.com"
        return
    fi

    # 找出所有具有最低延迟的域名
    local best_domains=()
    for domain in "${!latency_map[@]}"; do
        if [[ "${latency_map[$domain]}" -eq "$best_latency" ]]; then
            best_domains+=("$domain")
        fi
    done

    # 如果只有一个最优域名，直接使用
    if [[ ${#best_domains[@]} -eq 1 ]]; then
        SNI="${best_domains[0]}"
        log_info "$(msg sni_selected): ${SNI} ($(msg latency): ${best_latency}ms)"
        return
    fi

    # 如果有多个相同延迟的域名，让用户选择
    echo -e "${YELLOW}$(msg sni_multiple) ($(msg best_latency): ${best_latency}ms)${NC}"
    echo -e "${CYAN}$(msg sni_choose):${NC}"
    echo ""

    local i=1
    for domain in "${best_domains[@]}"; do
        echo -e "  ${GREEN}$i.${NC} $domain"
        ((i++))
    done

    echo ""
    echo -n "  $(msg menu_choice) [1-${#best_domains[@]}]: "
    read -r choice

    # 验证输入
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#best_domains[@]} ]]; then
        SNI="${best_domains[$((choice - 1))]}"
    else
        # 默认选择第一个
        SNI="${best_domains[0]}"
    fi

    log_info "$(msg sni_selected): ${SNI} ($(msg latency): ${best_latency}ms)"
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
    echo -e "${GREEN}                    $(msg qr_title)${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    qrencode -t ANSIUTF8 "$link"
    echo ""
    echo -e "${CYAN}───────────────────────────────────────────────────────────────${NC}"
    echo -e "${GREEN}$(msg share_link):${NC}"
    echo -e "${YELLOW}$link${NC}"
    echo -e "${CYAN}───────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${MAGENTA}$(msg qr_tip)${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
}

show_info() {
    source "$ENV_FILE"
    local link
    link=$(get_share_link)

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                     $(msg node_info)${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${BLUE}$(msg server_addr):${NC} $SERVER_IP"
    echo -e "  ${BLUE}$(msg port):${NC}       $PORT"
    echo -e "  ${BLUE}UUID:${NC}       $UUID"
    echo -e "  ${BLUE}Flow:${NC}       xtls-rprx-vision"
    echo -e "  ${BLUE}SNI:${NC}        $SNI"
    echo -e "  ${BLUE}PublicKey:${NC}  $PUBLIC_KEY"
    echo -e "  ${BLUE}ShortID:${NC}    $SHORT_ID"
    echo -e "  ${BLUE}Fingerprint:${NC} chrome"
    echo ""
    echo -e "${CYAN}───────────────────────────────────────────────────────────────${NC}"
    echo -e "${GREEN}$(msg share_link):${NC}"
    echo -e "${YELLOW}$link${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
}

cmd_install() {
    if ! is_root; then
        log_error "$(msg run_as_root)"
        return 1
    fi

    log_info "$(msg installing)"

    install_deps
    install_xray

    if [[ -n "${reym:-}" ]]; then
        SNI="$reym"
        log_info "$(msg using_sni): $SNI"
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

    log_info "$(msg install_complete)"

    show_info

    local link
    link=$(get_share_link)
    show_qrcode "$link"
}

cmd_info() {
    if [[ ! -f "$ENV_FILE" ]]; then
        log_error "$(msg config_not_found)"
        return 1
    fi
    show_info
}

cmd_qr() {
    if [[ ! -f "$ENV_FILE" ]]; then
        log_error "$(msg config_not_found)"
        return 1
    fi

    if ! command -v qrencode &>/dev/null; then
        log_info "$(msg install_deps)"
        apt-get update -y >/dev/null 2>&1
        apt-get install -y qrencode >/dev/null 2>&1
    fi

    local link
    link=$(get_share_link)
    show_qrcode "$link"
}

cmd_status() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                     $(msg service_status)${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    if systemctl is-active --quiet xray 2>/dev/null; then
        echo -e "  Xray: ${GREEN}● Running${NC}"
    else
        echo -e "  Xray: ${RED}○ Stopped${NC}"
    fi

    if [[ -f "$ENV_FILE" ]]; then
        echo -e "  Config: ${GREEN}$(msg installed)${NC}"
    else
        echo -e "  Config: ${YELLOW}$(msg not_installed)${NC}"
    fi

    echo ""
    systemctl status xray --no-pager 2>/dev/null | head -10 || true
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
}

cmd_restart() {
    systemctl restart xray
    log_info "$(msg service_restarted)"
}

cmd_uninstall() {
    log_info "$(msg uninstalling)"
    systemctl stop xray 2>/dev/null || true
    systemctl disable xray 2>/dev/null || true
    rm -f "$XRAY_CONF" "$ENV_FILE" "$LANG_FILE"
    curl -Ls https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s -- remove >/dev/null 2>&1
    log_info "$(msg uninstall_complete)"
}

cmd_test_sni() {
    local total=${#SNI_LIST[@]}
    log_info "$(msg testing_sni) ($(msg total_domains): $total)"
    echo ""

    declare -A latency_map
    local tested=0

    for domain in "${SNI_LIST[@]}"; do
        tested=$((tested + 1))
        local latency
        latency=$(test_domain_latency "$domain")

        if [[ "$latency" -eq 9999 ]]; then
            printf "[%3d/%3d] ${RED}%-50s $(msg timeout)${NC}\n" "$tested" "$total" "$domain"
        else
            printf "[%3d/%3d] ${GREEN}%-50s %dms${NC}\n" "$tested" "$total" "$domain" "$latency"
            latency_map["$domain"]=$latency
        fi
    done

    echo ""

    # 显示排序结果（前10名）
    if [[ ${#latency_map[@]} -gt 0 ]]; then
        echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}                     Top 10 $(msg best_latency)${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
        echo ""

        # 排序并显示前10
        for domain in "${!latency_map[@]}"; do
            echo "${latency_map[$domain]} $domain"
        done | sort -n | head -10 | while read -r lat dom; do
            printf "  ${GREEN}%4dms${NC}  %s\n" "$lat" "$dom"
        done

        echo ""
        echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    fi

    log_info "$(msg test_complete)"
}

# ============== 主菜单 ==============

show_menu() {
    clear
    local status_icon
    if systemctl is-active --quiet xray 2>/dev/null; then
        status_icon="${GREEN}●${NC}"
    else
        status_icon="${RED}○${NC}"
    fi

    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}         ${YELLOW}$(msg menu_title)${NC}              ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${GREEN}1.${NC} $(msg menu_install)                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${GREEN}2.${NC} $(msg menu_info)                                          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${GREEN}3.${NC} $(msg menu_qr)                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${GREEN}4.${NC} $(msg menu_status)  [$status_icon]                                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${GREEN}5.${NC} $(msg menu_restart)                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${GREEN}6.${NC} $(msg menu_test_sni)                                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${GREEN}7.${NC} $(msg menu_uninstall)                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${MAGENTA}8.${NC} $(msg menu_lang)                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${RED}0.${NC} $(msg menu_exit)                                                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

main_menu() {
    while true; do
        show_menu
        echo -n "   $(msg menu_choice) [0-8]: "
        read -r choice
        echo ""

        case "$choice" in
            1)
                cmd_install
                echo ""
                read -rp "$(msg menu_press_enter)"
                ;;
            2)
                cmd_info
                echo ""
                read -rp "$(msg menu_press_enter)"
                ;;
            3)
                cmd_qr
                echo ""
                read -rp "$(msg menu_press_enter)"
                ;;
            4)
                cmd_status
                echo ""
                read -rp "$(msg menu_press_enter)"
                ;;
            5)
                cmd_restart
                echo ""
                read -rp "$(msg menu_press_enter)"
                ;;
            6)
                cmd_test_sni
                echo ""
                read -rp "$(msg menu_press_enter)"
                ;;
            7)
                cmd_uninstall
                echo ""
                read -rp "$(msg menu_press_enter)"
                ;;
            8)
                select_language
                ;;
            0)
                echo -e "${GREEN}Bye!${NC}"
                exit 0
                ;;
            *)
                log_error "$(msg menu_invalid)"
                sleep 1
                ;;
        esac
    done
}

show_help() {
    echo ""
    echo -e "${CYAN}VLESS TCP REALITY Vision${NC}"
    echo ""
    echo "Usage: bash $0 [command]"
    echo ""
    echo "Commands:"
    echo "  (none)      Show interactive menu"
    echo "  install     Install and configure node"
    echo "  info        Show node information"
    echo "  qr          Show QR code"
    echo "  status      Show service status"
    echo "  restart     Restart service"
    echo "  uninstall   Uninstall node"
    echo "  test-sni    Test all SNI latency"
    echo "  menu        Show interactive menu"
    echo "  help        Show this help"
    echo ""
    echo "Optional parameters (for install):"
    echo "  reym=xxx    Specify SNI domain"
    echo "  vlpt=xxx    Specify port"
    echo "  uuid=xxx    Specify UUID"
    echo ""
    echo "Examples:"
    echo "  bash $0                              # Interactive menu"
    echo "  bash $0 install                      # Auto-select best SNI"
    echo "  reym=www.tesla.com bash $0 install   # Specify SNI"
    echo ""
}

# ============== 主入口 ==============

# 加载语言设置
load_lang

# 如果没有语言设置且是交互模式，先选择语言
init_language_if_needed() {
    if [[ -z "$CURRENT_LANG" ]]; then
        select_language
    fi
}

case "${1:-}" in
    install)
        init_language_if_needed
        cmd_install
        ;;
    info)
        init_language_if_needed
        cmd_info
        ;;
    qr)
        init_language_if_needed
        cmd_qr
        ;;
    status)
        init_language_if_needed
        cmd_status
        ;;
    restart)
        init_language_if_needed
        cmd_restart
        ;;
    uninstall)
        init_language_if_needed
        cmd_uninstall
        ;;
    test-sni)
        init_language_if_needed
        cmd_test_sni
        ;;
    menu|"")
        init_language_if_needed
        main_menu
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        ;;
esac
