#!/bin/sh

MONIT_GROUP="{{ group_names }}"
MONIT_IP="{{ inventory_hostname }}"
COLOR=$1
/usr/bin/curl \
    -X POST \
    -s \
    --data-urlencode "payload={ \
        \"channel\": \"#{{ slack_channel }}\", \
        \"username\": \"{{ slack_user }}\", \
        \"pretext\": \"$MONIT_IP | $MONIT_GROUP | $MONIT_DATE\", \
        \"color\": \"$COLOR\", \
        \"icon_emoji\": \":bangbang:\", \
        \"text\": \"$MONIT_SERVICE - $MONIT_DESCRIPTION\" \
    }" \
    {{ slack_web_hook }}
