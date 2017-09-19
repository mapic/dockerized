#!/bin/bash
webhook_url=$MAPIC_SLACK_WEBHOOK
channel=mapic-monitor
text=$1
json="{\"channel\": \"$channel\", \"text\": \"$text\" }"
RESULT=$(curl -s -d "payload=$json" "$webhook_url")