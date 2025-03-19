#!/bin/bash

CONFIG_FILE="/etc/owntone.conf"
LOG_FILE="/var/log/modify_owntone_config.log"

# 记录日志
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# 确保以 root 权限运行
if [[ $EUID -ne 0 ]]; then
   log "错误：请使用 root 权限运行此脚本 (sudo bash modify_owntone_config.sh)"
   exit 1
fi

# 检查配置文件是否存在
if [[ ! -f "$CONFIG_FILE" ]]; then
    log "错误：文件 $CONFIG_FILE 不存在！"
    exit 1
fi

log "=== 开始修改 OwnTone 配置文件 ==="

# 替换目录路径
log "替换 'directories' 目录路径..."
sed -i 's|directories = { "/srv/music" }|directories = { "/usr/share/hassio/media/music" }|g' "$CONFIG_FILE"

# 在 'type = "alsa"' 下面添加 'type = "disabled"'
log "查找 'type = \"alsa\"' 并在下面插入 'type = \"disabled\"'..."
sed -i '/type = "alsa"/a type = "disabled"' "$CONFIG_FILE"

# 确保修改成功
if grep -q 'directories = { "/usr/share/hassio/media/music" }' "$CONFIG_FILE" && grep -q 'type = "disabled"' "$CONFIG_FILE"; then
    log "配置文件修改成功！"
else
    log "⚠️ 配置修改可能未成功，请手动检查 $CONFIG_FILE"
    exit 1
fi

# 重启 OwnTone 以应用更改
log "重启 Owntone 服务..."
systemctl restart owntone

# 确保 OwnTone 成功启动
if systemctl is-active --quiet owntone; then
    log "Owntone 服务已成功重启 ✅"
else
    log "⚠️ Owntone 服务启动失败，请检查 systemctl 状态"
fi

log "=== 修改完成 ==="
exit 0
