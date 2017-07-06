# Echo server

A simple echo server using python alpine image to echo the request path

### How to run

```
docker run -p 9090:9090 sunbird/echo-server:latest
```

### Test

```
curl localhost:9090/hello
```