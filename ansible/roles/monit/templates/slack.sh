#!/bin/sh

MONIT_IP="{{ inventory_hostname }}"
COLOR=${MONIT_COLOR:-$([[ $MONIT_DESCRIPTION == *"succeeded"* ]] && echo good || echo danger)}

/usr/bin/curl \
    -X POST \
    -s \
    --data-urlencode "payload={ \
        \"channel\": \"#{{ monit_slack_channel }}\", \
        \"username\": \"{{ monit_slack_user }}\", \
        \"pretext\": \"$MONIT_IP | $MONIT_DATE\", \
        \"color\": \"$COLOR\", \
        \"icon_emoji\": \":bangbang:\", \
        \"text\": \"$MONIT_SERVICE - $MONIT_DESCRIPTION\" \
    }" \
    {{ monit_slack_webhook_url }}
