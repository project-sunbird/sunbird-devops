FROM circleci/android:api-28-node8-alpha
MAINTAINER Rajesh Rajendran <rjshrjndrn@gmail.com>
WORKDIR /home/circleci
# node-sass is not installing as it's executing external scripts
RUN sudo npm install -g ionic cordova node-sass --unsafe-perm
