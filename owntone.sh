#!/bin/bash

# 定义日志文件
LOG_FILE="/var/log/install_owntone.log"

# 记录日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# 需要 root 权限
if [[ $EUID -ne 0 ]]; then
   log "错误：请使用 root 权限运行此脚本 (sudo bash install_owntone.sh)"
   exit 1
fi

log "=== 开始执行安装脚本 ==="

# 创建 Zigbee2MQTT external_converters 目录
log "创建目录：/usr/share/hassio/homeassistant/zigbee2mqtt/external_converters"
mkdir -p /usr/share/hassio/homeassistant/zigbee2mqtt/external_converters

# 下载 Owntone GPG 密钥
log "下载并存储 Owntone GPG 密钥..."
if wget -q -O - http://www.gyfgafguf.dk/raspbian/owntone.gpg | gpg --dearmor --output /usr/share/keyrings/owntone-archive-keyring.gpg; then
    log "Owntone GPG 密钥下载成功"
else
    log "错误：无法下载 Owntone GPG 密钥"
    exit 1
fi

# 添加 Owntone APT 源
log "添加 Owntone APT 源..."
if wget -q -O /etc/apt/sources.list.d/owntone.list http://www.gyfgafguf.dk/raspbian/owntone-bullseye.list; then
    log "Owntone APT 源添加成功"
else
    log "错误：无法添加 Owntone APT 源"
    exit 1
fi

# 更新 APT 并安装 Owntone
log "更新 APT 软件包索引并安装 Owntone..."
if apt update && apt install owntone -y; then
    log "Owntone 安装成功"
else
    log "错误：Owntone 安装失败"
    exit 1
fi

# 创建 Home Assistant 的 music 目录
log "创建目录：/usr/share/hassio/media/music"
mkdir -p /usr/share/hassio/media/music

# **检查 OwnTone systemd 服务状态**
log "检查 Owntone systemd 服务状态..."
systemctl is-active --quiet owntone

if [[ $? -ne 0 ]]; then
    log "Owntone 进程未运行，尝试启动..."
    systemctl start owntone
    sleep 3
    systemctl is-active --quiet owntone
    if [[ $? -eq 0 ]]; then
        log "Owntone 进程启动成功 ✅"
    else
        log "⚠️ Owntone 进程启动失败，请手动检查 systemctl 状态"
    fi
else
    log "Owntone 进程已在运行 ✅"
fi

log "=== 安装和进程检查完成 ==="
exit 0
