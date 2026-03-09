#!/bin/sh
# MODE1 - USB WAN (eth1) - Daily 4G driver
# SSH: LAN only

CONFIG="/root/GPIO-Predefined"

# Safe config parser - handles commented blocks
getcfg() {
    awk -F= -v sec="[$1]" -v key="$2" '
        $0==sec{f=1;next}
        /^\[/{f=0}
        f && /^#/{next}
        f && $1==key{print $2; exit}
    ' "$CONFIG"
}

logger "MODE1: Activating USB WAN"

# Stop other WANs
ifdown wan_eth 2>/dev/null
ifdown wan_wifi 2>/dev/null

# Disable WiFi client
uci set wireless.external_wwan.disabled='1'
uci commit wireless
wifi reload >/dev/null 2>&1
sleep 2

# Bring up USB WAN
ifup wan_usb

# SSH: LAN only
uci set dropbear.@dropbear[0].Interface='lan'
uci commit dropbear
/etc/init.d/dropbear restart >/dev/null 2>&1

echo MODE1 > /tmp/current_mode
logger "MODE1 applied"
