#!/bin/bash

echo
echo "Install BlueTooth Drivers for M401A"
echo

apt update && apt install -y apt-transport-https apparmor udisks2 gpiod lrzsz avahi-daemon bluez bluetooth pulseaudio-module-bluetooth bluez-firmware;
#mv /boot/dtb/amlogic/meson-g12a-s905l3a-m401a.dtb /boot/dtb/amlogic/meson-g12a-s905l3a-m401a.dtb.orig;
#curl -L https://github.com/slznxyz/lyq-ha-install/raw/main/USB-ACM-5.14/meson-g12a-s905l3a-m401a-bt.dtb -o /boot/dtb/amlogic/meson-g12a-s905l3a-m401a.dtb;
apt-get install apparmor jq wget curl udisks2 libglib2.0-bin network-manager dbus cifs-utils systemd-journal-remote -y;
touch /etc/default/grub && echo "systemd.unified_cgroup_hierarchy=false" > /etc/default/grub;
sed -i 's/swapaccount=1$/& apparmor=1 security=apparmor systemd.unified_cgroup_hierarchy=0/' /boot/uEnv.txt;
sed -i '1s/^/#/; 1a PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"' /etc/os-release;
wget https://github.com/home-assistant/os-agent/releases/download/1.6.0/os-agent_1.6.0_linux_aarch64.deb;

cat >> ~/update-hostname.sh <<'EOF'
#!/bin/bash

# 获取eth0网卡的MAC地址
mac_address=$(cat /sys/class/net/eth0/address)

# 检查是否成功获取MAC地址
if [ -z "$mac_address" ]; then
    echo "Unable to retrieve MAC address for eth0. Exiting."
    exit 1
fi

# 获取MAC地址的最后8位，并去掉冒号，转换为大写
new_hostname=$(echo "$mac_address" | tail -c 9 | sed 's/://g' | tr 'a-z' 'A-Z')

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
EOF

chmod +x update-hostname.sh;
./update-hostname.sh
