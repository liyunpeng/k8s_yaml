#! /bin/bash
1. 添加repo文件
[centos5@68-node ~]$ cat /etc/yum.repos.d/glusterfs.repo
[glusterfs-rhel8]
name=GlusterFS is a clustered file-system capable of scaling to several petabytes.
baseurl=https://download.gluster.org/pub/gluster/glusterfs/6/LATEST/RHEL/el-$releasever/$basearch/
enabled=1
skip_if_unavailable=1
gpgcheck=1
gpgkey=https://download.gluster.org/pub/gluster/glusterfs/6/rsa.pub

[glusterfs-noarch-rhel8]
name=GlusterFS is a clustered file-system capable of scaling to several petabytes.
baseurl=https://download.gluster.org/pub/gluster/glusterfs/6/LATEST/RHEL/el-$releasever/noarch
enabled=1
skip_if_unavailable=1
gpgcheck=1
gpgkey=https://download.gluster.org/pub/gluster/glusterfs/6/rsa.pub

2.
sudo wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

3.
 dnf clean packages

 4.