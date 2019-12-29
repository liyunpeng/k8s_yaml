#! /bin/bash

set -v

sudo cat << EOF > /tmp/exports 
/usr/local/k8s/redis/pv1 192.168.0.211(rw,sync,no_root_squash)
/usr/local/k8s/redis/pv2 192.168.0.211(rw,sync,no_root_squash)
/usr/local/k8s/redis/pv3 192.168.0.211(rw,sync,no_root_squash)
/usr/local/k8s/redis/pv4 192.168.0.211(rw,sync,no_root_squash)
/usr/local/k8s/redis/pv5 192.168.0.211(rw,sync,no_root_squash)
/usr/local/k8s/redis/pv6 192.168.0.211(rw,sync,no_root_squash)
EOF
sudo cp  /tmp/exports /etc/exports

sudo apt-get install nfs-kernel-server -y  # 安装 NFS服务器端
sudo apt-get install nfs-common   -y      # 安装 NFS客户端
sudo apt-get install rpcbind -y

sudo mkdir -p /usr/local/k8s/redis/pv{1..6}

sudo systemctl restart rpcbind
#sudo systemctl restart nfs
#sudo systemctl enable nfs

sudo /etc/init.d/nfs-kernel-server restart

sudo exportfs -v
