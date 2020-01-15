#! /bin/bash
set -v
#wget -c http://mirror.bit.edu.cn/apache/kafka/2.4.0/kafka_2.12-2.4.0.tgz

#tar -zxvf  kafka_2.12-2.4.0.tgz
#sudo mv kafka_2.12-2.4.0  /opt/kafka_2.12
cd /opt/kafka_2.12/bin

命令记录
cp ../config/server.properties ../config/server.properties-backup
cp ../config/zookeeper.properties ../config/zookeeper.properties-backup

$./zookeeper-server-start.sh -daemon ../config/zookeeper.properties

$./kafka-server-start.sh -daemon ../config/server.properties

$./kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic MyTopic

Created topic MyTopic.

$./kafka-topics.sh --list --zookeeper localhost:2181
MyTopic
$./kafka-console-producer.sh --broker-list localhost:9092 --topic MyTopic
>[2020-01-15 09:04:56,294] WARN [Producer clientId=console-producer] Connection to node -1 (localhost/127.0.0.1:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)

解决办法：broker-list改写为PLAINTEXT方式
$./kafka-console-producer.sh --broker-list PLAINTEXT://192.168.0.220:9092  --topic MyTopic
>aaaaaa

同一台主机打开一个消费者线程消费，可以看到生产者发来的消息
$ ./kafka-console-consumer.sh --bootstrap-server PLAINTEXT://192.168.0.220:9092 --topic MyTopic --from-beginning
aaaaaa


[user1@220-node bin]$ sudo netstat -antp | grep 9092
tcp6       0      0 192.168.0.220:9092      :::*                    LISTEN      5274/java
tcp6       0      0 192.168.0.220:55644     192.168.0.220:9092      ESTABLISHED 5274/java
tcp6       0      0 192.168.0.220:9092      192.168.0.220:55652     ESTABLISHED 5274/java
tcp6       0      0 192.168.0.220:9092      192.168.0.220:53330     ESTABLISHED 5274/java
tcp6       0      0 192.168.0.220:55640     192.168.0.220:9092      ESTABLISHED 24558/java
tcp6       0      0 192.168.0.220:9092      192.168.0.220:55640     ESTABLISHED 5274/java
tcp6       0      0 192.168.0.220:55642     192.168.0.220:9092      ESTABLISHED 24558/java
tcp6       0      0 192.168.0.220:53330     192.168.0.220:9092      ESTABLISHED 14054/java
tcp6       0      0 192.168.0.220:53318     192.168.0.220:9092      TIME_WAIT   -
tcp6       0      0 192.168.0.220:55652     192.168.0.220:9092      ESTABLISHED 24558/java
tcp6       0      0 192.168.0.220:9092      192.168.0.220:55644     ESTABLISHED 5274/java
tcp6       0      0 192.168.0.220:9092      192.168.0.220:55642     ESTABLISHED 5274/java
