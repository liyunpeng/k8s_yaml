#!/bin/bash
# 适用于centos8，建立k8s集群master

set -v

echo "Start"
 
export IP_ADDR=$(ip addr show ens33 | grep -Po 'inet \K[\d.]+')
echo $IP_ADDR
 
sudo su - << FOE
 
# Create Kubernetes Cluster
kubeadm init --pod-network-cidr=192.169.0.0/16 \
--apiserver-advertise-address=$IP_ADDR \
--kubernetes-version  stable-1.16 \
--ignore-preflight-errors=Swap \
--image-repository registry.aliyuncs.com/google_containers
 
FOE
sleep 10s

# Create .kube folder
if [ -f $HOME/.kube/config ]; then
  rm -rf $HOME/.kube/config  
fi
 
if [ ! -d $HOME/.kube ]; then
  mkdir $HOME/.kube 
fi
 
# Copy Kubernetes config file
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config 
sudo chown $(id -u):$(id -g) $HOME/.kube/config 
 
# Apply network plugin
result=1
while [ $result -ne 0 ]
do
	kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml 
	result=$?
	sleep 10s
done
kubectl apply -f https://docs.projectcalico.org/v3.10/manifests/calico.yaml 
 
# Taint master node
#kubectl taint nodes --all node-role.kubernetes.io/master-

#kubeadm token create --print-join-command
echo "Complete"
