#!/bin/sh
# wan_watch.sh - mode-aware WAN watchdog
# Cron: */20 * * * * (every 20min, lighter touch)
# v2.0 Mar 2026

PING_TARGET="8.8.8.8"
MAX_FAIL=2
COUNTER_FILE="/tmp/wan_failcount"

# Determine correct WAN interface by current mode
MODE=$(cat /tmp/current_mode 2>/dev/null)
case "$MODE" in
    MODE1) WAN_IF="wan_usb" ;;
    MODE2) WAN_IF="wan_eth" ;;
    MODE3) WAN_IF="wan_wifi" ;;
    *) exit 0 ;;  # unknown mode, do nothing
esac

if ping -c 3 -W 3 $PING_TARGET >/dev/null 2>&1; then
    rm -f $COUNTER_FILE
    exit 0
fi

COUNT=0
[ -f $COUNTER_FILE ] && COUNT=$(cat $COUNTER_FILE)
COUNT=$((COUNT+1))
echo $COUNT > $COUNTER_FILE

if [ "$COUNT" -eq 1 ]; then
    logger "WAN_WATCH: ping failed in $MODE, restarting $WAN_IF"
    ifdown $WAN_IF
    sleep 10
    ifup $WAN_IF
    exit 0
fi

if [ "$COUNT" -ge "$MAX_FAIL" ]; then
    logger "WAN_WATCH: $WAN_IF still down after retry, rebooting"
    reboot
fi

