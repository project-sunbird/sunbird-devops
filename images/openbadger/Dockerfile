FROM alpine:3.7
MAINTAINER Rajesh Rajendran<rjshrjndrn@gmail.com>

# Installing and configuring packages
COPY ./images/openbadger/configure.sh /tmp/
RUN /tmp/configure.sh
COPY ./images/openbadger/entrypoint.sh /badger

# Application running on 8000
EXPOSE 8000
WORKDIR /badger

ENTRYPOINT ["entrypoint.sh"]
