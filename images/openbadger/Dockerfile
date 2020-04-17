FROM ubuntu:18.04
MAINTAINER Rajesh Rajendran<rjshrjndrn@gmail.com>

# Installing and configuring packages
RUN apt update && apt install -y python-psycopg2
COPY ./images/openbadger/configure.sh /tmp
RUN /tmp/configure.sh

# Application running on 8000
EXPOSE 8004
WORKDIR /badger
COPY ./images/openbadger/entrypoint.sh /badger/
RUN chmod 755 /badger/entrypoint.sh
ENTRYPOINT ["/badger/entrypoint.sh"]
