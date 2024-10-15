#!/bin/bash

echo
echo "Install Final Step for S905L3A"
echo

apt --fix-broken install;
sudo dpkg -i  os-agent_1.6.0_linux_aarch64.deb;
wget https://github.com/home-assistant/supervised-installer/releases/download/1.8.0/homeassistant-supervised.deb;
dpkg -i homeassistant-supervised.deb
