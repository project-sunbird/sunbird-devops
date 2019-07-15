#!/bin/sh

#apk update curl
#apk add curl
#apk update jq
#apk add jq
outpt1=$(curl -s content-service:5000/health | jq '.result.healthy')
outpt2=$(curl -s player_player:3000/health| jq '.result.healthy')
outpt3=$(curl -s learner-service:9000/health | jq '.result.response.checks[0].healthy')
outpt4=$(curl -s lms-service:9005/health | jq '.result.response.checks[0].healthy')
echo ""
echo ""
if [ "$outpt1" == "true" ];then
        echo "content service is Healthy"
else
        echo "content service is unhealthy"
fi

echo ""
echo ""

if [ "$outpt2" == "true" ];then
        echo "Player Service is Healthy"
else
        echo "Player Service is unhealthy"
fi

echo ""
echo ""

if [ "$outpt3" == "true" ];then
        echo "Learner Service is Healthy"
else
        echo "Learner Service is unhealthy"
fi

echo ""
echo ""

if [ "$outpt4" == "true" ];then
        echo "Lms Service is Healthy"
else
        echo "Lms Service is unhealthy"
fi
