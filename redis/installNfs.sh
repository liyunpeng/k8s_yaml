#! /bin/bash

set -v

sudo cat << EOF > /etc/exports
/usr/local/k8s/redis/pv1 192.168.0.0/211(rw,sync,no_root_squash)
/usr/local/k8s/redis/pv2 192.168.0.0/211(rw,sync,no_root_squash)
/usr/local/k8s/redis/pv3 192.168.0.0/211(rw,sync,no_root_squash)
/usr/local/k8s/redis/pv4 192.168.0.0/211(rw,sync,no_root_squash)
/usr/local/k8s/redis/pv5 192.168.0.0/211(rw,sync,no_root_squash)
/usr/local/k8s/redis/pv6 192.168.0.0/211(rw,sync,no_root_squash)
EOF

sudo apt-get install nfs-utils -y
sudo apt-get install rpcbind -y

mkdir -p /usr/local/k8s/redis/pv{1..6}

systemctl restart rpcbind
systemctl restart nfs
systemctl enable nfs


exportfs -v