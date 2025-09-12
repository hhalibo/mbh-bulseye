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

# 创建 临时安装 目录
log "创建目录：/tmp/upload"
mkdir -p /tmp/upload

cd /tmp/upload
wget https://github.com/owntone/owntone-apt/releases/download/rpi_rev27/rpi_repo.tar.gz
tar -xzvf rpi_repo.tar.gz
dpkg -i ./publish/pool/contrib/o/owntone/owntone_28.12.137.gitb612e12-2+bullseye_arm64.deb
apt --fix-broken install -y
cd

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
