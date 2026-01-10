# VLESS TCP REALITY Vision Auto-Setup

一键部署 VLESS + TCP + REALITY Vision 节点的自动化脚本，支持动态 SNI 选择、多语言界面和二维码分享。

## 特性

- **一键安装** - 自动配置 Xray + REALITY 协议
- **动态 SNI** - 自动测试 141 个域名，选择最低延迟 SNI
- **并行测试** - 30 并发测试，5-10 秒完成（原需 4+ 分钟）
- **多语言** - 支持中文/英文界面
- **二维码** - 自动生成分享二维码
- **多发行版** - 支持 Debian/Ubuntu/CentOS/RHEL/Fedora
- **IPv6 支持** - 自动检测并支持 IPv6 地址
- **健康检查** - 一键检测节点运行状态
- **备份恢复** - 配置文件备份与恢复

## 快速开始

### 一键安装

```bash
bash <(curl -Ls https://raw.githubusercontent.com/Banezzz/reality-vision---fast-setup/main/vless-reality-vision.sh)
```

### 手动安装

```bash
# 下载脚本
curl -O https://raw.githubusercontent.com/Banezzz/reality-vision---fast-setup/main/vless-reality-vision.sh

# 添加执行权限
chmod +x vless-reality-vision.sh

# 运行
./vless-reality-vision.sh
```

## 使用方法

### 交互式菜单

```bash
bash vless-reality-vision.sh
```

```
╔═══════════════════════════════════════════════════════════════╗
║         VLESS TCP REALITY Vision 管理面板                      ║
╠═══════════════════════════════════════════════════════════════╣
║   1. 安装节点                                                  ║
║   2. 查看节点信息                                              ║
║   3. 显示二维码                                                ║
║   4. 服务状态                                                  ║
║   5. 健康检查                                                  ║
║   6. 重启服务                                                  ║
║   7. 测试 SNI 延迟                                             ║
║   8. 卸载节点                                                  ║
║   9. 切换语言                                                  ║
║   0. 退出                                                      ║
╚═══════════════════════════════════════════════════════════════╝
```

### 命令行模式

```bash
bash vless-reality-vision.sh install     # 安装节点
bash vless-reality-vision.sh info        # 查看节点信息
bash vless-reality-vision.sh qr          # 显示二维码
bash vless-reality-vision.sh status      # 服务状态
bash vless-reality-vision.sh health      # 健康检查
bash vless-reality-vision.sh restart     # 重启服务
bash vless-reality-vision.sh test-sni    # 测试 SNI 延迟
bash vless-reality-vision.sh uninstall   # 卸载节点
```

### 高级参数

```bash
# 指定 SNI 域名
reym=www.microsoft.com bash vless-reality-vision.sh install

# 指定端口
vlpt=443 bash vless-reality-vision.sh install

# 指定 UUID
uuid=your-custom-uuid bash vless-reality-vision.sh install

# 自定义节点名称
node_name=MyVPN bash vless-reality-vision.sh install

# 优先使用 IPv6
prefer_ipv6=1 bash vless-reality-vision.sh install

# 组合使用
node_name=MyNode reym=www.apple.com vlpt=8443 bash vless-reality-vision.sh install
```

## 系统要求

- **操作系统**: Debian 10+, Ubuntu 18.04+, CentOS 7+, RHEL 7+, Fedora 30+
- **架构**: x86_64, aarch64
- **权限**: root 用户
- **网络**: 需要访问 GitHub 下载 Xray

## 客户端配置

安装完成后会显示以下信息：

```
服务器地址: your.server.ip
端口:       12345
UUID:       xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Flow:       xtls-rprx-vision
SNI:        www.microsoft.com
PublicKey:  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ShortID:    xxxxxxxx
Fingerprint: chrome
```

### 推荐客户端

| 平台 | 客户端 |
|------|--------|
| Windows | [v2rayN](https://github.com/2dust/v2rayN) |
| macOS | [V2rayU](https://github.com/yanue/V2rayU) |
| iOS | Shadowrocket, Quantumult X |
| Android | [v2rayNG](https://github.com/2dust/v2rayNG) |
| Linux | [Qv2ray](https://github.com/Qv2ray/Qv2ray) |

## 文件位置

| 文件 | 路径 |
|------|------|
| Xray 程序 | `/usr/local/bin/xray` |
| Xray 配置 | `/usr/local/etc/xray/config.json` |
| 节点配置 | `/root/reality_vision.env` |
| 语言设置 | `/root/reality_vision.lang` |
| SNI 缓存 | `/tmp/sni_latency_cache.txt` |
| 备份目录 | `/root/reality_backup/` |

## 常见问题

### Q: 安装后无法连接？

1. 运行 `bash vless-reality-vision.sh health` 检查节点状态
2. 确保服务器防火墙/安全组开放了对应端口
3. 检查客户端配置是否正确

### Q: SNI 测试全部超时？

- 可能是服务器网络限制，使用 `reym=www.tesla.com` 指定 SNI 跳过测试

### Q: 如何更换 SNI？

```bash
# 重新安装并指定新 SNI
reym=new.sni.com bash vless-reality-vision.sh install
```

### Q: 如何备份配置？

```bash
bash vless-reality-vision.sh backup
```

备份文件保存在 `/root/reality_backup/`

## 更新日志

### v2.0.0
- 并行 SNI 测试（30 并发，性能提升 28-56 倍）
- 并行 IP 获取（4 API 竞速）
- 多发行版支持（apt/yum/dnf）
- 健康检查功能
- 连接数显示
- 备份恢复功能
- 自定义节点名称
- IPv6 支持
- SNI 测试结果缓存

### v1.0.0
- 初始版本
- VLESS + TCP + REALITY 自动配置
- 动态 SNI 选择
- 多语言支持
- 二维码生成

## 致谢

- [Xray-core](https://github.com/XTLS/Xray-core) - 核心代理引擎
- [REALITY](https://github.com/XTLS/REALITY) - 协议实现

## License

MIT License
