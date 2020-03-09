#!/bin/sh

echo "Date: $(date), Server $(hostname), User: $PAM_USER, " \
"RHost: $([ -z "$PAM_RHOST" ] && echo "N/A" || echo "$PAM_RHOST ")," \ 
"Type: $PAM_TYPE, Service: $PAM_SERVICE" >> /var/log/sentinel.log
