#!/bin/sh
# mode3_watchdog.sh
# Connect and keep ext WiFi WAN alive for MODE3
# If WiFi drops: retry, fallback to USB WAN
# Checks every INTERVAL period - light on CPU and data
# v2.0 Mar 2026

#prevent double up watchdog
MYPID=$$
OLDEST=$(pgrep -f mode3_watchdog.sh | sort -n | head -1)
if [ "$OLDEST" != "$MYPID" ]; then
    logger "MODE3 WATCHDOG: duplicate detected, exiting. My PID=$MYPID PPID=$PPID, keeping=$OLDEST"
    exit 0
fi

INTERVAL=1  #initial waiting

while true
do
    sleep $INTERVAL

    # Only run if still in MODE3
    MODE=$(cat /tmp/current_mode 2>/dev/null)
    [ "$MODE" = "MODE3" ] || { logger "MODE3!=$MODE <-MODE3 WATCHDOG STOPPED"; exit 0;}
    [ ! -f "/tmp/mode3_running" ] || { logger "Mode3_Running <-MODE3 WATCHDOG Standby"; INTERVAL=5; continue;}

    # Check connectivity
    if ifstatus wan_wifi | grep -q '"address"'; then   
        INTERVAL=30
        continue
    fi
    sleep 10

    logger "MODE3 WATCHDOG: WiFi lost, retrying..."

    # Attempt reconnect
    ifdown wan_wifi 2>/dev/null
    wifi down >/dev/null 2>&1
    sleep 10

    # Only run if still in MODE3
    MODE=$(cat /tmp/current_mode 2>/dev/null) 
    [ "$MODE" = "MODE3" ] || { logger "MODE3!=$MODE <-MODE3 WATCHDOG STOPPED"; exit 0;}
    [ ! -f "/tmp/mode3_running" ] || { logger "Mode3_Running <-MODE3 WATCHDOG Standby"; INTERVAL=5; continue;}

    uci set wireless.external_wwan.disabled='0'
    uci commit wireless
    wifi reload >/dev/null 2>&1
    sleep 10
    ifup wan_wifi
    sleep 10

    # Only run if still in MODE3
    MODE=$(cat /tmp/current_mode 2>/dev/null) 
    [ "$MODE" = "MODE3" ] || { logger "MODE3!=$MODE <-MODE3 WATCHDOG STOPPED"; exit 0;}
    [ ! -f "/tmp/mode3_running" ] || { logger "Mode3_Running <-MODE3 WATCHDOG Standby"; INTERVAL=5; continue;}

    if ifstatus wan_wifi | grep -q '"address"'; then
        ifdown wan_usb 2>/dev/null
        logger "MODE3 WATCHDOG: ext WiFi Connected, USB WAN disabled"
    else
        logger "MODE3 WATCHDOG: ext WiFi not found, falling back to USB WAN"
        uci set wireless.external_wwan.disabled='1'                          
        uci commit wireless                                                 
        wifi reload >/dev/null 2>&1  
        ifup wan_usb
    fi
    INTERVAL=10
done
