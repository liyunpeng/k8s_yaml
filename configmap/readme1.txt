master@etcd0:~/k8s_yaml/configmap$ cat << EOF > env.txt
>
> config1=xxx
>
> config2=yyy
>
> EOF
master@etcd0:~/k8s_yaml/configmap$
master@etcd0:~/k8s_yaml/configmap$ kubectl create configmap myconfigmap --from-env-file=env.txt


master@etcd0:~/k8s_yaml/configmap$ kubectl get configmap
NAME            DATA   AGE
config-name     1      4h20m
lykops-config   3      4h18m
myconfigmap     2      2m6s


master@etcd0:~/k8s_yaml/configmap$ kubectl describe configmap myconfigmap
Name:         myconfigmap
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
config1:
----
xxx
config2:
----
yyy
Events:  <none>


master@etcd0:~/k8s_yaml/configmap$ kubectl delete configmap myconfigmap
configmap "myconfigmap" deleted
master@etcd0:~/k8s_yaml/configmap$ kubectl get configmap
NAME            DATA   AGE
config-name     1      4h23m
lykops-config   3      4h21m

