#!/bin/sh
cd open-saber/
./configure-dependencies.sh
cd java
mvn clean install

cd registry 
mvn clean install