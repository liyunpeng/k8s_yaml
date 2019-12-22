go mod在1.10版本还不支持， 用apt-get install安装的是比较老的版本，这里是1.10
所以手动下载go安装包，进行手动安装，go安装包解压后，需要三个命令即可:
sudo cp go /usr/local/bin/ 
$echo "export GOROOT=/home/master/go/go/" >> ~/.bashrc
$source ~/.bashrc

上面三个步骤完成go的安装，$go mod init dockerimage
