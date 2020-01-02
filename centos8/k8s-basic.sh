#!/bin/bash
set -v
echo "Start"

sudo sed -i '/swap/ s/^/#/' /etc/fstab

export IP_ADDR=$(ip addr show ens33 | grep -Po 'inet \K[\d.]+')
echo $IP_ADDR


sudo su - << FOE
 
# Stop firewall and selinux
sudo systemctl disable --now firewalld
sudo /usr/sbin/setenforce 0
sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
 
# Ignore Swap Error while installing kubernetes cluster with Swap
cat<<EOF > /etc/sysconfig/kubelet
KUBELET_EXTRA_ARGS=--fail-swap-on=false
EOF
 
# Install neccessary system tools
sudo yum install -y dnf-utils
 
# Open ipvs
cat <<EOF >/etc/sysconfig/modules/ipvs.modules
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
 
sudo chmod 755 /etc/sysconfig/modules/ipvs.modules
sudo bash /etc/sysconfig/modules/ipvs.modules
sudo lsmod | grep -e ip_vs -e nf_conntrack_ipv4
sudo dnf install ipset ipvsadm -y
 
# Config iptables
echo "br_netfilter" > /etc/modules-load.d/br_netfilter.conf
cat<<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
 
sudo modprobe br_netfilter
sudo sysctl --system
 
# Add Docker Repo
sudo dnf config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# Install Docker-CE
sudo dnf makecache timer
sudo dnf -y install --nobest docker-ce
# Enable Docker
sudo systemctl enable --now docker
# Config Docker
if [ ! -d "/etc/docker" ]; then
  mkdir /etc/docker
fi
 
cat<<EOF > /etc/docker/daemon.json
{
   "exec-opts": ["native.cgroupdriver=systemd"],
   "log-driver": "json-file",
   "log-opts": {
     "max-size": "100m"
   },
   "storage-driver": "overlay2",
   "storage-opts": [
     "overlay2.override_kernel_check=true"
   ],
   "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn"]
}
EOF
 
sudo systemctl daemon-reload
sudo systemctl restart docker
 
# Add Kubernetes Repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
 
sudo dnf install -y kubeadm kubectl kubelet
sudo systemctl enable kubelet
 
FOE
 
# Add User to docker group
sudo usermod -a -G docker $(id -nu)
 
 
echo "Complete"
