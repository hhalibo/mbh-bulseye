#!/bin/bash


echo
echo "Docker install script for Hassbian"
echo


echo "Running apt-get preparation"
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc


echo "Add the Docker repository to APT sources"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


echo "Redo apt update"
sudo apt update

sleep 5

echo "Install Docker now"
#sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo apt-get install docker-ce=5:27.3.1-1~debian.11~bullseye docker-ce-cli=5:27.3.1-1~debian.11~bullseye containerd.io
apt-mark hold docker-ce docker-ce-cli

echo
echo "Installation done."
echo
