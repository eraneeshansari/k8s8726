##  execute this on every nodes
#!/bin/bash
sudo swapoff -a

sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl
sudo mkdir -p -m 755 /etc/apt/keyrings
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
sudo cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

sudo lsmod | grep br_netfilter
sudo lsmod | grep overlay

sudo sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward


# Define your desired CRI-O version
export CRIO_VERSION=v1.28

# Create keyrings directory if it does not exist
sudo mkdir -p -m 755 /etc/apt/keyrings

# Download GPG key and add repository
curl -fsSL https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key | gpg --dearmor | sudo tee /etc/apt/keyrings/cri-o-apt-keyring.gpg > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/cri-o.list

sudo apt update
sudo apt install -y cri-o


sudo systemctl start crio.service


sudo systemctl enable crio.service


sudo systemctl status crio.service
