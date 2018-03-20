FROM ubuntu:17.10
MAINTAINER Rajesh Rajendran<rjshrjndrn@gmail.com>

# Installing and configuring packages
COPY ./images/openbadger/configure.sh /tmp
RUN /tmp/configure.sh

# Application running on 8000
EXPOSE 8004
WORKDIR /badger
COPY ./images/openbadger/entrypoint.sh /badger/
RUN chmod 755 /badger/entrypoint.sh
ENTRYPOINT ["/badger/entrypoint.sh"]
