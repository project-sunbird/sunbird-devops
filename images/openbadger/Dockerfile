FROM alpine:3.7
MAINTAINER Rajesh Rajendran<rjshrjndrn@gmail.com>

# Installing and configuring packages
COPY ./configure.sh /tmp/
RUN /tmp/configure.sh

# Application running on 8000
EXPOSE 8000
WORKDIR /badger

ENTRYPOINT ["/badger/code/manage.py", "runserver", "0.0.0.0:8000"]
