## Usage

This application will help to debug network communication via TCP by proxying the connection while printing the data to terminal console. For example, if ApplicationA -> ApplicationB and there is some issue in the data recieved by ApplicationB, you can run ApplicationA -> tcp_proxy -> ApplicationB.

ApplicationB listens to 8080

We'll start tcp_proxy as `./tcp_proxy -l 0.0.0.0:9999 -r localhost:8080` in ApplicationB Machine. Then we'll remap, ApplicationA to point to `APplicationB machine ip address:8080`, which will proxy to applicationB while printing the data to terminal.

## Build

`CGO_ENABLED=0 go build -o tcp_proxy ./main.go`
