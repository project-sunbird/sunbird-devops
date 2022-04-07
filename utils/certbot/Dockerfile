FROM certbot/certbot:v1.24.0
RUN apk add --update coreutils curl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
CMD ["/usr/local/bin/kubectl"]