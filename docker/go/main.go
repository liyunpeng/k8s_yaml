package main

import (
    "fmt"
    "io/ioutil"
    "log"
    "time"

    "crypto/tls"
    "crypto/x509"

    "go.etcd.io/etcd/clientv3"
    "golang.org/x/net/context"
)

var (
    dialTimeout    = 5 * time.Second
    requestTimeout = 4 * time.Second
    endpoints      = []string{"https://192.168.0.204:2379"}
)

func main() {

    log.Println("----Start running-----------")
    var etcdCert = "../ca/etcd-client.pem"
    var etcdCertKey = "../ca/etcd-client-key.pem"
    var etcdCa = "../ca/ca.pem"

    cert, err := tls.LoadX509KeyPair(etcdCert, etcdCertKey)
    if err != nil {
        log.Fatal("LoadX509KeyPair failed")
        return
    }

    caData, err := ioutil.ReadFile(etcdCa)
    if err != nil {
        log.Fatal("ReadFile(etcdCa) failed")
        return
    }

    pool := x509.NewCertPool()
    pool.AppendCertsFromPEM(caData)

    _tlsConfig := &tls.Config{
        Certificates: []tls.Certificate{cert},
        RootCAs:      pool,
    }

    cfg := clientv3.Config{
        Endpoints: endpoints,
        TLS:       _tlsConfig,
    }

    cli, err := clientv3.New(cfg)

    if err != nil {
        log.Fatal(err)
    }

    defer cli.Close()

    done := make(chan bool)

    key1 := "testkey1"

    go func() {
        log.Println("----Start putting value-----------")
        for cnt := 0; cnt < 65535; cnt++ {
            log.Println(cnt)
            value := fmt.Sprintf("%s%d", "value", cnt)
            _, err = cli.Put(context.Background(), key1, value)
            if err != nil {
                log.Println("Put failed. ", err)
            } else {
                log.Printf("Put {%s:%s} succeed\n", key1, value)
            }
        }
        done <- true
    }()

    <-done

    log.Println("Done!")
}
