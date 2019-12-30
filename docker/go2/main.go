 package main  
  import(   
  "net/http"  
  "fmt"  
  )  
  func main() {  
      http.HandleFunc("/zc",hello)  
      http.ListenAndServe(":5005",nil)  
  }  
  func hello(w http.ResponseWriter, r *http.Request) {  
      fmt.Fprintf(w,"Hello Docker Form Golang!")  
 }  
