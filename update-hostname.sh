#!/bin/bash

# 获取eth0网卡的MAC地址
mac_address=$(cat /sys/class/net/eth0/address)

# 检查是否成功获取MAC地址
if [ -z "$mac_address" ]; then
    echo "Unable to retrieve MAC address for eth0. Exiting."
    exit 1
fi

# 获取MAC地址的最后8位，并去掉冒号，转换为大写
new_hostname=$(echo "$mac_address" | sed 's/://g' | tail -c 9 | tr 'a-z' 'A-Z')

# 显示获取的新的主机名
echo "Setting hostname to the last 8 characters of MAC address (in uppercase): $new_hostname"

# 更新/etc/hostname和/etc/hosts文件中的主机名
current_hostname=$(cat /etc/hostname)
sudo sed -i "s/$current_hostname/$new_hostname/g" /etc/hostname
sudo sed -i "s/$current_hostname/$new_hostname/g" /etc/hosts

echo "Hostname and hosts file updated successfully."

# 询问用户是否需要重启
read -p "Do you want to reboot now? (y/n): " answer

case $answer in
    [Yy]* )
        echo "Rebooting now..."
        sudo reboot
        ;;
    [Nn]* )
        echo "Reboot canceled."
        ;;
    * )
        echo "Invalid response. Exiting without reboot."
        ;;
esac
