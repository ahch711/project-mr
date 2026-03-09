#!/bin/sh

MAX_RETRIES=3
COUNTER_FILE="/tmp/extroot_failcount"

if mount | grep -q "/dev/sd.* on /overlay"; then
    rm -f $COUNTER_FILE
    exit 0
fi

COUNT=0
[ -f $COUNTER_FILE ] && COUNT=$(cat $COUNTER_FILE)

COUNT=$((COUNT+1))
echo $COUNT > $COUNTER_FILE

if [ "$COUNT" -ge "$MAX_RETRIES" ]; then
    logger "Extroot missing after $MAX_RETRIES attempts. STOP rebooting."
    exit 0
fi

logger "Extroot missing. Reboot attempt $COUNT"
reboot

