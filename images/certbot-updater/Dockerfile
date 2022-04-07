
FROM alpine:latest
LABEL maintainer="rjshrjndrn@gmail.com"
RUN apk update

RUN apk add --no-cache curl certbot
#Oneliner due to the use of release as variable for wget which is previously curled
RUN export release=$(curl https://storage.googleapis.com/kubernetes-release/release/stable.txt); \
    curl https://storage.googleapis.com/kubernetes-release/release/$release/bin/linux/amd64/kubectl --output /usr/local/bin/kubectl; \
    chmod +x /usr/local/bin/kubectl

ENTRYPOINT ["/usr/local/bin/kubectl"]
