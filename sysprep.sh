#!/bin/bash

echo
echo "Change the Repositories to Tsinghua"
echo

#sed -i.bak 's#http://apt.armbian.com#https://mirrors.tuna.tsinghua.edu.cn/armbian#g' /etc/apt/sources.list.d/armbian.list;

mv /etc/apt/sources.list /etc/apt/sources.list.orig;

cat >> /etc/apt/sources.list <<'EOF'
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main 
EOF

apt update;
apt upgrade -y;
apt install mosquitto-clients neofetch -y;
curl -L https://github.com/docker/compose/releases/download/v2.37.0/docker-compose-linux-aarch64 -o /usr/local/bin/docker-compose;
chmod +x /usr/local/bin/docker-compose;

cat >> /root/docker.sh <<'EOF'
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
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
#sudo apt-get install docker-ce=5:26.1.4-1~debian.11~bullseye docker-ce-cli=5:26.1.4-1~debian.11~bullseye containerd.io


echo
echo "Installation done."
echo
EOF
