



master@etcd0:~/k8s_yaml/pod$ kubectl get svc
webapps         ClusterIP   10.108.64.186   <none>        8081/TCP                     129m

$ curl 10.108.64.186:8081
可以访问到网址内容
