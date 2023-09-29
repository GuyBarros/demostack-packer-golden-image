#!/usr/bin/env bash
set -x

echo "==> Base"

echo "==> libc6 issue workaround"
echo 'libc6 libraries/restart-without-asking boolean true' | sudo debconf-set-selections


function install_from_url {
  cd /tmp && {
    curl -sfLo "$${1}.zip" "$${2}"
    unzip -qq "$${1}.zip"
    sudo mv "$${1}" "/usr/local/bin/$${1}"
    sudo chmod +x "/usr/local/bin/$${1}"
    rm -rf "$${1}.zip"
  }
}

source /etc/profile.d/ips.sh

echo "--> Updating apt-cache"
ssh-apt update

echo "--> Setting iptables for bridge networking"
echo 1 > /proc/sys/net/bridge/bridge-nf-call-arptables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables

echo "--> Making iptables settings for bridge networking config change"
sudo tee /etc/sysctl.d/nomadtables > /dev/null <<EOF
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

echo "--> Adding Hashicorp repo"
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list



echo "--> updated version of Nodejs"
url -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list


sudo apt update

echo "--> Installing common dependencies"
sudo apt-get install -y \
  build-essential \
  nodejs \
  curl \
  emacs \
  git \
  jq \
  tmux \
  unzip \
  vim \
  wget \
  tree \
  nfs-kernel-server \
  nfs-common \
  python3-pip \
  ruby-full \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common \
  openjdk-17-jdk \
  prometheus-node-exporter \
  golang-go \
  alien \
  qemu-kvm \
  virt-manager \
  virtinst \
  libvirt-clients \
  bridge-utils \
  libvirt-daemon-system \
  waypoint \
  &>/dev/null


echo "--> Disabling checkpoint"
sudo tee /etc/profile.d/checkpoint.sh > /dev/null <<"EOF"
export CHECKPOINT_DISABLE=1
EOF
source /etc/profile.d/checkpoint.sh


echo "--> Install Envoy"
sudo apt update
sudo apt install apt-transport-https gnupg2 curl lsb-release
curl -sL 'https://deb.dl.getenvoy.io/public/gpg.8115BA8E629CC074.key' | sudo gpg --dearmor -o /usr/share/keyrings/getenvoy-keyring.gpg
Verify the keyring - this should yield "OK"
echo a077cb587a1b622e03aa4bf2f3689de14658a9497a9af2c427bba5f4cc3c4723 /usr/share/keyrings/getenvoy-keyring.gpg | sha256sum --check
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/getenvoy-keyring.gpg] https://deb.dl.getenvoy.io/public/deb/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/getenvoy.list
sudo apt update
sudo apt install -y getenvoy-envoy
envoy --version


echo "--> Docker"
echo "==> Docker

#uninstall all conflicting packages
# for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done"

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "==> Docker is done!"