#!/bin/sh
# v2.0 Mar 2026

logger "+++Toggle Resolved REPORTING!+++"

# Ignore button events while modeboot is running
[ ! -f "/tmp/modeboot_running" ] || { logger "Toggle Resolved: ignore during modeboot"; exit 0;}

LOCK="/tmp/toggle.lock"
[ -f "$LOCK" ] && exit 0
touch "$LOCK"

sleep 3   #toggle switch triggered, wait on user settle before chk BTN_0+BTN_1 state to set Mode

LAST0=$(cat /tmp/last_btn0 2>/dev/null | cut -d= -f2)
LAST1=$(cat /tmp/last_btn1 2>/dev/null | cut -d= -f2)

logger "Toggle Resolved: BTN0=$LAST0 BTN1=$LAST1"

if [ "$LAST0" = "pressed" ] && [ "$LAST1" = "released" ]; then
    MODE="MODE1"
elif [ "$LAST0" = "released" ] && [ "$LAST1" = "pressed" ]; then
    MODE="MODE2"
elif [ "$LAST0" = "pressed" ] && [ "$LAST1" = "pressed" ]; then
    MODE="MODE3"
else
    logger "Toogle Resolved Unknown state, ignoring"
    rm -f "$LOCK"
    exit 0
fi

logger "Toggle Resolved: mode = $MODE"


if [ ! -f /tmp/toggle_normal ]; then
    touch /tmp/toggle_normal  # always touch, own the process

    BOOT_INFO=$(cat /tmp/modeboot_mode_exec 2>/dev/null)
    if [ -z "$BOOT_INFO" ]; then
        logger "Toggle Resolved: first run, no modeboot reference, skipping safely"
        rm -f "$LOCK"
        exit 0
    fi

    BOOT_MODE=$(echo $BOOT_INFO | cut -d' ' -f1)
    BOOT_TIME=$(echo $BOOT_INFO | cut -d' ' -f2)
    NOW=$(date +%s)
    AGE=$((NOW - BOOT_TIME))

    if [ "$AGE" -le 30 ] && [ "$MODE" = "$BOOT_MODE" ]; then
        logger "Toggle Resolved: first run, same as modeboot within ${AGE}sec, skipping"
        rm -f "$LOCK"
        exit 0
    fi
fi

# 2nd run onwards — or first run that passed all checks
logger "Toggle Resolved mode: $MODE"
/root/mode_manager.sh "$MODE"
rm -f "$LOCK"

