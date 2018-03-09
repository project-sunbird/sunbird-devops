FROM alpine:3.7
MAINTAINER Rajesh Rajendran<rjshrjndrn@gmail.com>


RUN adduser -u 1001 -h /home/sunbird/ -D sunbird
WORKDIR /home/sunbird
COPY configure.sh  /home/sunbird/
RUN chown -R sunbird:sunbird /home/sunbird
USER sunbird
RUN /home/sunbird/configure.sh

# Application running on 8000
EXPOSE 8000
WORKDIR /badger

ENTRYPOINT [“/badger/code/manage.py”, “runserver”, “0.0.0.0:8000”]