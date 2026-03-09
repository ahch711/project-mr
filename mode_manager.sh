#!/bin/sh

MODE="$1"

logger "MODE MANAGER: switching to $MODE"

case "$MODE" in
    MODE1)
        logger "Applying USB WAN baseline"
        /root/modes/mode1.sh
        ;;
    MODE2)
        logger "Applying RJ45 WAN mode"
        /root/modes/mode2.sh
        ;;
    MODE3)
        logger "Applying External WiFi WAN mode"
        /root/modes/mode3.sh
        ;;
    *)
        logger "Unknown mode"
        ;;
esac

