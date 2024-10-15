#!/bin/bash

# 定义要加入的DNS服务器列表
new_servers='["dns://8.8.8.8", "dns://1.1.1.1", "dns://223.5.5.5"]'

# 要修改的文件路径
dns_file="/usr/share/hassio/dns.json"
backup_file="/usr/share/hassio/dns.json.orig"

# 检查文件是否存在
if [ ! -f "$dns_file" ]; then
    echo "DNS configuration file not found: $dns_file"
    exit 1
fi

# 如果备份文件不存在，则备份原文件
if [ ! -f "$backup_file" ]; then
    echo "Backing up the original DNS configuration file to $backup_file"
    sudo cp "$dns_file" "$backup_file"
    if [ $? -eq 0 ]; then
        echo "Backup successful."
    else
        echo "Failed to create backup. Exiting."
        exit 1
    fi
else
    echo "Backup already exists: $backup_file"
fi

# 使用jq更新servers字段，并将结果写回文件
sudo jq --argjson servers "$new_servers" '.servers = $servers' "$dns_file" > /tmp/dns.json.tmp && sudo mv /tmp/dns.json.tmp "$dns_fi>

# 检查jq命令是否成功
if [ $? -eq 0 ]; then
    echo "DNS servers updated successfully in $dns_file."
else
    echo "Failed to update DNS servers in $dns_file."
    exit 1
fi
