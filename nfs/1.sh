#！/bin/bash

set -x 

count=`grep -c "/nfsroot \*(rw,sync,no_root_squash)"  /etc/exports` 

echo $count

#if [ $count -eq '1' ]; then
if [ $count -ge '1' ]; then
	echo "found"
else
  echo 'no error find in file.txt'
fi


local_host="`hostname --fqdn`"

local_ips=`host $local_host 2>/dev/null | awk '{print $NF}'`

echo $local_ips

local_ens33_ip=`ip addr show ens33 |grep -w inet |awk '{print $2}' |awk -F '/' '{print $1}'`

echo $local_ens33_ip
