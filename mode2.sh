#!/bin/sh
# MODE2 - Ethernet WAN (eth0) - Hotel/Lab/NBN
# SSH: WiFi only

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

logger "MODE2: Activating RJ45 WAN"

# Read GPIO2 predefined config
PROTO=$(getcfg GPIO2 PROTO)
IP=$(getcfg GPIO2 IP)
NETMASK=$(getcfg GPIO2 NETMASK)
GATEWAY=$(getcfg GPIO2 GATEWAY)
DNS=$(getcfg GPIO2 DNS)

# Stop other WANs
ifdown wan_usb 2>/dev/null
ifdown wan_wifi 2>/dev/null

# Disable WiFi client
uci set wireless.external_wwan.disabled='1'
uci commit wireless
wifi reload >/dev/null 2>&1
sleep 2

# Apply static or DHCP config to wan_eth
if [ "$PROTO" = "static" ] && [ -n "$IP" ]; then
    logger "MODE2: Applying static IP $IP"
    uci set network.wan_eth.proto='static'
    uci set network.wan_eth.ipaddr="$IP"
    uci set network.wan_eth.netmask="$NETMASK"
    uci set network.wan_eth.gateway="$GATEWAY"
    uci set network.wan_eth.dns="$DNS"
else
    logger "MODE2: Using DHCP"
    uci set network.wan_eth.proto='dhcp'
fi
uci commit network

# Bring up Ethernet WAN
ifup wan_eth

# SSH: WiFi only
uci set dropbear.@dropbear[0].Interface='wlan'
uci commit dropbear
/etc/init.d/dropbear restart >/dev/null 2>&1

echo MODE2 > /tmp/current_mode
logger "MODE2 applied"
