#!/bin/sh
cd open-saber/java
cp registry/src/main/resources/config-prod.properties.sample registry/src/main/resources/config-prod.properties 
cp registry/src/main/resources/application.properties.sample registry/src/main/resources//application.properties 
cp registry/src/main/resources/validations.shex.sample registry/src/main/resources//validations.shex 
cp registry/src/main/resources/schema-configuration.jsonld.sample registry/src/main/resources/schema--configuration.jsonld 
cp registry/src/main/resources/frame.json.sample registry/src/main/resources//frame.json 

mvn clean install

cd registry 
mvn clean install