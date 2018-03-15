FROM node:9-alpine
MAINTAINER Rajesh Rajendran<rjshrjndrn@gmail.com>

# Installing and configuring packages
COPY configure.sh /tmp
RUN /tmp/configure.sh
WORKDIR code
RUN npm i
