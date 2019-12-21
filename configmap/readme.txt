master@etcd0:~/k8s/configmap$ kubectl create configmap config-name --from-file=~/k8s/configmap/test1.txt
error: error reading ~/k8s/configmap/test1.txt: no such file or directory

master@etcd0:~/k8s/configmap$ kubectl create configmap config-name --from-file=/home/master/k8s/configmap/test1.txt
configmap/config-name created

