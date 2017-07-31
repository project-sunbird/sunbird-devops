# Echo server

A simple echo server using python alpine image to echo the request path

### How to run

```
docker run -p 9595:9595 sunbird/echo-server:latest
```

### Test

```
curl localhost:9595/hello
```