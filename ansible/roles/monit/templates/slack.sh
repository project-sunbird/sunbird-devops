#!/bin/sh

MONIT_GROUP="{{ group_names }}"
MONIT_IP="{{ inventory_hostname }}"

/usr/bin/curl \
    -X POST \
    -s \
    --data-urlencode "payload={ \
        \"channel\": \"#{{ monit_slack_channel }}\", \
        \"username\": \"{{ monit_slack_user }}\", \
        \"pretext\": \"$MONIT_IP | $MONIT_DATE\", \
        \"color\": \"danger\", \
        \"icon_emoji\": \":bangbang:\", \
        \"text\": \"$MONIT_SERVICE - $MONIT_DESCRIPTION\" \
    }" \
    {{ monit_slack_webhook_url }}
