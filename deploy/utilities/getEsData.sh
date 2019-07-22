#!/bin/bash
####################################################
#  Author S M Y ALTAMASH <smy.altamash@gmail.com>  #
# Script gets the Latest Logs of proxy from Log-es #
####################################################
# NOTE: Have jq installed before running this script
for index in $(curl -s localhost:9200/_cat/indices | grep -v kibana | awk '{print $3}' | tr "\n" " ");
do
        echo "Index:$index"
        # Get the Total Hits for the Proxy Container
        hits=$(curl -s -X GET "http://localhost:9200/$index/_search?pretty" -H 'Content-Type: application/json' -d'{"query":{"match":{"program":"proxy_proxy*"}}}' | jq '.hits.total')

        # Increase the query size
        curl -XPUT "http://localhost:9200/$index/_settings" -d "{ \"index\" : { \"max_result_window\" : \"$hits\" } }" -H "Content-Type: application/json"

        # Save the Logs in the file
        curl -s -X GET "http://localhost:9200/$index/_search?size=$hits" -H 'Content-Type: application/json' -d'{"query":{"match":{"program":"proxy_proxy*"}}}' > $index.json
        echo "################################"
done

