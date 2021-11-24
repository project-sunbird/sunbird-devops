// vim: set nofoldenable:
// Author: rjshrjdnrn <rjshrjndrn@gmail.com>

// This application will proxy tcp connecion while printing the logs to console.
package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"net"
	"os"
)

var localAddr *string = flag.String("l", "localhost:9999", "local address")
var remoteAddr *string = flag.String("r", "localhost:8888", "remote address")

func main() {
	flag.Parse()
	fmt.Printf("Listening: %v\nProxying: %v\n\n", *localAddr, *remoteAddr)

	listener, err := net.Listen("tcp", *localAddr)
	if err != nil {
		panic(err)
	}
	for {
		// Creating a listener
		conn, err := listener.Accept()
		log.Println("New connection", conn.RemoteAddr())
		if err != nil {
			log.Println("error accepting connection", err)
			continue
		}
		go func() {
			// Closing the listener
			defer conn.Close()
			// Creating connection to remote server, proxy connection.
			conn2, err := net.Dial("tcp", *remoteAddr)
			if err != nil {
				log.Println("error dialing remote addr", err)
				return
			}
			// Closing proxy connection
			defer conn2.Close()
			// Creating channel to copy the data
			closer := make(chan struct{}, 2)
			// Copy local data to remotet server
			go copy(closer, conn2, conn)
			// Copy proxy data to local listener
			go copy(closer, conn, conn2)
			// Waiting for the data to be written
			<-closer
			log.Println("Connection complete", conn.RemoteAddr())
		}()
	}
}

func copy(closer chan struct{}, dst io.Writer, src io.Reader) {
	io.Copy(os.Stdout, io.TeeReader(src, dst))
	closer <- struct{}{} // connection is closed, send signal to stop proxy
}
