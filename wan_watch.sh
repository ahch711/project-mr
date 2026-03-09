#!/bin/sh
###########################################
#Replace full reboot with staged recovery:
#1.Ping fails
#2.ifdown wan
#3.sleep 10
#4.ifup wan
#5.Only reboot if still broken
###########################################
#X. future version: power cycle via wifi/usb controlled power source, but not MR3020 power source
###########################################

PING_TARGET="8.8.8.8"
MAX_FAIL=2
COUNTER_FILE="/tmp/wan_failcount"

if ping -c 3 -W 3 $PING_TARGET >/dev/null; then
    rm -f $COUNTER_FILE
    exit 0
fi

COUNT=0
[ -f $COUNTER_FILE ] && COUNT=$(cat $COUNTER_FILE)

COUNT=$((COUNT+1))
echo $COUNT > $COUNTER_FILE

if [ "$COUNT" -eq 1 ]; then
    logger "WAN ping failed. Restarting interface."
    ifdown wan
    sleep 10
    ifup wan
    exit 0
fi

if [ "$COUNT" -ge "$MAX_FAIL" ]; then
    logger "WAN still down. Rebooting."
    reboot     #replace reboot to a future power_cycle_modem.sh, to script control power source cycling
fi

