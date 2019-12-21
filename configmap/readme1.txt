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

master@etcd0:~/k8s_yaml/configmap$ kubectl get pod
NAME                          READY   STATUS             RESTARTS   AGE
busybox                       1/1     Running            0          13m
master@etcd0:~/k8s_yaml/configmap$ kubectl delete pod busybox
pod "busybox" deleted  持续了5分钟
master@etcd0:~/k8s_yaml/configmap$ kubectl get pod
NAME                          READY   STATUS             RESTARTS   AGE

kubectl logs 可以打印
master@etcd0:~/k8s_yaml/configmap$ kubectl logs busybox
KUBERNETES_PORT=tcp://10.96.0.1:443
MYAPP_SVC_PORT_80_TCP_ADDR=10.99.200.8
KUBERNETES_SERVICE_PORT=443
INGRESS_NGINX_PORT_80_TCP_ADDR=10.103.69.200
HOSTNAME=busybox
MYAPP_SVC_PORT_80_TCP_PORT=80
MYAPP_SVC_PORT_80_TCP_PROTO=tcp
SHLVL=1
INGRESS_NGINX_PORT_80_TCP_PORT=80
HOME=/root
INGRESS_NGINX_PORT_80_TCP_PROTO=tcp
MYAPP_SVC_PORT_80_TCP=tcp://10.99.200.8:80
INGRESS_NGINX_PORT_80_TCP=tcp://10.103.69.200:80
INGRESS_NGINX_PORT_443_TCP_ADDR=10.103.69.200
INGRESS_NGINX_PORT_443_TCP_PORT=443
MYSQL_PORT_3306_TCP_ADDR=10.96.173.212
INGRESS_NGINX_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
MYAPP_SVC_SERVICE_PORT_HTTP=80
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
MYSQL_PORT_3306_TCP_PORT=3306
KUBERNETES_PORT_443_TCP_PORT=443
INGRESS_NGINX_SERVICE_PORT_HTTP=80
MYSQL_PORT_3306_TCP_PROTO=tcp
MYSQL_SERVICE_HOST=10.96.173.212
KUBERNETES_PORT_443_TCP_PROTO=tcp
INGRESS_NGINX_PORT_443_TCP=tcp://10.103.69.200:443
MYAPP_SVC_SERVICE_HOST=10.99.200.8
INGRESS_NGINX_SERVICE_PORT_HTTPS=443
INGRESS_NGINX_SERVICE_HOST=10.103.69.200
MYSQL_SERVICE_PORT=3306
MYSQL_PORT=tcp://10.96.173.212:3306
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_SERVICE_PORT_HTTPS=443
MYSQL_PORT_3306_TCP=tcp://10.96.173.212:3306
KUBERNETES_SERVICE_HOST=10.96.0.1
PWD=/
MYAPP_SVC_SERVICE_PORT=80
MYAPP_SVC_PORT=tcp://10.99.200.8:80
INGRESS_NGINX_SERVICE_PORT=80
INGRESS_NGINX_PORT=tcp://10.103.69.200:80

----------------------------------------------------------------------------------
pod_busybox.yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox
  namespace: default
spec:
  containers:
  - name: busybox
    image: busybox:1.28.4
    command: [ "/bin/sh", "-c", "env" ]
    imagePullPolicy: IfNotPresent
  restartPolicy: Never
  
有些修改，并不能成功apply， 比如
busybox1.yaml
command: [ "/bin/sh", "-c", "env" ]
改为
command: [ "/bin/sh", "-c", "env | grep APP" ]
这个命令是在容器初始好后立即运行的， apply 的时候，初始化早已经结束了，不具备执行这个command的条件，
所以更新这个pod会报如下错误：
master@etcd0:~/k8s_yaml/configmap$ kubectl apply -f pod_busybox.yaml
The Pod "busybox" is invalid: spec: Forbidden: pod updates may not change fields other than `spec.containers[*].image`, `spec.initContainers[*].image`, `spec.activeDeadlineSeconds` or `spec.tolerations` (only additions to existing tolerations)
  core.PodSpec{
        Volumes:        []core.Volume{{Name: "default-token-ck48w", VolumeSource: core.VolumeSource{Secret: &core.SecretVolumeSource{SecretName: "default-token-ck48w", DefaultMode: &420}}}},
        InitContainers: nil,
        Containers: []core.Container{
                {
                        Name:  "busybox",
                        Image: "busybox:1.28.4",
                        Command: []string{
                                "/bin/sh",
                                "-c",
-                               "env | grep APP",
+                               "env",
                        },
                        Args:       nil,
                        WorkingDir: "",
                        ... // 16 identical fields
                },
        },
        RestartPolicy:                 "Never",
        TerminationGracePeriodSeconds: &30,
        ... // 21 identical fields
  }


如果pod引用的configmap里面不存在的键，apply这个pod会报这样状态错误：
master@etcd0:~/k8s_yaml/configmap$ kubectl get pod
NAME                          READY   STATUS                       RESTARTS   AGE
busybox                       0/1     CreateContainerConfigError   0          9m24s
这是因为 pod_busybox.yaml引用的名字为cf-appvars的configmap里面，没有appVersion这个Key
      - name: SPECIAL_KEY2
        valueFrom:
          configMapKeyRef:
            name: cf-appvars
            key:  appVersion
解决办法， 去config_cf-appvars.yaml增加对这个key的定义，即在
data:
  apploglevel: info
这个data里面增减一个键值对定义：
data:
  apploglevel: info
  appVersion: v1.0
更新这个configmap：
$ kubectl apply -f config_cf_appvars.yaml
查看configmap:
master@etcd0:~/k8s_yaml/configmap$ kubectl describe configmap cf-appvars
Name:         cf-appvars
Namespace:    default
Labels:       app=configmap
              project=lykops
              software=apache
              version=v1
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"v1","data":{"appVersion":"v1.0","apploglevel":"info","os":"linux"},"kind":"ConfigMap","metadata":{"annotations":{},"labels"...

Data
====
appVersion:
----
v1.0
apploglevel:
----
info
Events:  <none>
这时再去看busybox， 这时状态已经更新了，说明configmap的更新会同步到引用他的pod，
达到配置即时应用到pod的目的。
master@etcd0:~/k8s_yaml/configmap$ kubectl get pod
NAME                          READY   STATUS             RESTARTS   AGE
busybox                       1/1     Running            0          4m56s





