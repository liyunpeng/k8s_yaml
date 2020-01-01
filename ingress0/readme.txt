master@ubuntu:~$ kubectl get pod -n ingress-nginx -o wide
NAME                                        READY   STATUS    RESTARTS   AGE   IP             NODE     NOMINATED NODE   READINESS GATES
nginx-ingress-controller-799dbf6fbd-ngrq4   1/1     Running   0          29m   192.169.0.21   ubuntu   <none>           <none>
master@ubuntu:~$  kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
myapp-test-7cdcb494b6-42dtk   1/1     Running   0          9m53s
myapp-test-7cdcb494b6-zdw8g   1/1     Running   0          9m36s
master@ubuntu:~$ kubectl get svc
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx   NodePort    10.105.153.150   <none>        80:32108/TCP,443:31750/TCP   26m
kubernetes      ClusterIP   10.96.0.1        <none>        443/TCP                      55m
myapp-svc       ClusterIP   10.108.110.59    <none>        80/TCP                       26m
master@ubuntu:~$ kubectl get ingress
NAME            HOSTS         ADDRESS   PORTS   AGE
ingress-myapp   www.shp.com             80      26m
master@ubuntu:~$ curl www.shp.com
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>301 Moved Permanently</title>
</head><body>
<h1>Moved Permanently</h1>
<p>The document has moved <a href="https://www.shp.com/">here</a>.</p>
</body></html>

master@ubuntu:~/k8s/gitclone/ingress$ kubectl exec -n ingress-nginx -it nginx-ingress-controller-799dbf6fbd-ngrq4 bash
www-data@nginx-ingress-controller-799dbf6fbd-ngrq4:/etc/nginx$ ls -l
total 56
-rw-r--r-- 1 root     root      1007 Sep 29 21:37 fastcgi_params
drwxr-xr-x 1 www-data www-data  4096 Sep 25 00:13 geoip
drwxr-xr-x 6 www-data www-data  4096 Sep 29 21:37 lua
-rw-r--r-- 1 root     root      5231 Sep 29 21:37 mime.types
drwxr-xr-x 2 www-data www-data  4096 Sep 25 00:16 modsecurity
lrwxrwxrwx 1 root     root        34 Sep 29 21:37 modules -> /usr/local/openresty/nginx/modules
-rw-r--r-- 1 www-data www-data 16778 Dec 20 07:42 nginx.conf
-rw-r--r-- 1 www-data www-data     2 Sep 29 21:37 opentracing.json
drwxr-xr-x 6 www-data www-data  4096 Sep 25 00:17 owasp-modsecurity-crs
drwxr-xr-x 2 www-data www-data  4096 Sep 29 21:37 template

