#! /bin/bash

set -v

sudo apt-get install nfs-kernel-server -y  # 安装 NFS服务器端
sudo apt-get install nfs-common   -y      # 安装 NFS客户端

# count 返回/etc/exports文件里包含指定字符串的行数，这个字符串是/nfsroot \*(rw,sync,no_root_squash)
count=`grep -c "/nfsroot \*(rw,sync,no_root_squash)"  /etc/exports` 
echo $count
#if [ $count -eq '1' ]; then
if [ $count -ge '1' ]; then
  echo "found"
else
  echo '/nfsroot *(rw,sync,no_root_squash)' | sudo tee -a /etc/exports    # * 表示允许任何网段 IP 的系统访问该 NFS 目录
fi

sudo mkdir /nfsroot
sudo chmod -R 777 /nfsroot
sudo chown $USER.$USER /nfsroot/ -R   # ipual 为当前用户，-R 表示递归更改该目录下所有文件

sudo /etc/init.d/nfs-kernel-server restart

local_ens33_ip=`ip addr show ens33 |grep -w inet |awk '{print $2}' |awk -F '/' '{print $1}'`
echo $local_ens33_ip

# 验证

sudo mkdir /mnt/a
sudo mount -t nfs $local_ens33_ip:/nfsroot /mnt/a -o nolock
# mount挂载需要一段时间， 如果不返回错误，就成功了
sudo touch /nfsroot/aaaaa
# 在/mnt/a/出现aaaaa 文件， 说明成功
sudo ls /mnt/a
