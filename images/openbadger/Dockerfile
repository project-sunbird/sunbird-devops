FROM alpine:3.7
MAINTAINER Rajesh Rajendran<rjshrjndrn@gmail.com>

# Installing and configuring packages
COPY configure.sh /tmp
RUN /tmp/configure.sh

# Application running on 8000
EXPOSE 8000
WORKDIR /badger

# Copying custom db settings, Please note that this will be permenant 
# after image creation, though you can login and change it. 
COPY settings_local.py /badger/code/apps/mainsite/settings_local.py

# Creating DBSchema
RUN python /badger/code/manage.py migrate

# You have to login to the container and create a super user
# code/manage.py createsuperuser

ENTRYPOINT ["/badger/code/manage.py", "runserver", "0.0.0.0:8000"]
