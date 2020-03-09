#!/bin/sh
echo "Homefield Sentinel!"

#Search pattern to look for
PATTERN="open.*password.txt"

#Account to notify
ACCOUNT="bob"

fs_usage | while read line; do
 if [[ "$line" =~ $PATTERN ]]; then
   echo "Sentinel: $line"
   su -l $ACCOUNT -c "osascript -e 'display notification \"Honeypot file accessed. Review logs.\" with title \"[Sentinel Notification]\"'"
 fi
done

echo "Done."
