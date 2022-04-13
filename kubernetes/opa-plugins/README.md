# opa-plugins

> OPA version - 0.34.2
#### Build opa binary
```
export today=$(date --iso-8601=seconds)
go mod tidy
go mod vendor
go build -o opa -ldflags "-X 'github.com/open-policy-agent/opa/version.Version=0.34.2' -X 'github.com/open-policy-agent/opa/version.Vcs=9f11f21' -X 'github.com/open-policy-agent/opa/version.Timestamp=$today' -X 'github.com/open-policy-agent/opa/version.Hostname=sunbird'" cmd/main.go
```


#### Build Docker Image
- To build the docker image run
```
docker build -t docker_user_name/opa:0.34.2-envoy --build-arg BASE=gcr.io/distroless/cc -f Dockerfile .
```
