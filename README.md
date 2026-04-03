# project-mr — MR3020 OpenWrt Travel Router
### "The Modular Fortress" — v2.0

**Hardware:** TP-Link TL-MR3020 v1 | OpenWrt 19.07.10 | 4MB Flash / 32MB RAM  
**GitHub:** github.com/ahch711/project-mr  
**Version:** v2.0 — April 2026

---

## Overview

A constrained-hardware state machine built on a TP-Link TL-MR3020 v1.
Three physical switch positions map to three distinct network modes,
each with defined WAN source, firewall boundaries, and SSH access policy.

Not a travel router anymore — a modular fortress.

---

## Architecture

### Network Topology
Physical Switch → GPIO Detection → modeboot → mode_manager → modeX.sh
Internal Networks:
br-lan       192.168.x.1    — Management LAN (eth0, RJ45)
br-wifi_iso  192.168.y.1    — Isolated WiFi clients (wlan0-1, AP)
guest        10.168.z.1     — Guest WiFi (isolated, internet only)
WAN Sources:
wan_usb   usb0    — USB modem / RNDIS tethering (Mode1)
wan_eth   eth0    — RJ45 Ethernet WAN (Mode2)
wan_wifi  wlan0   — External WiFi client / hotspot (Mode3)

### Bridge Isolation (v2 key feature)
br-lan (eth0)
└── management subnet — SSH in Mode1 via RJ45
br-wifi_iso (wlan0-1)
└── isolated client subnet — all WiFi clients
└── Shaper applied here — subnet /28 aware
└── SSH controllable per mode via iptables

---

## Three Modes

### Mode1 — USB WAN (Daily Driver)
- **WAN:** usb0 (USB modem or Android RNDIS)
- **SSH:** LAN only (RJ45, management subnet)
- **WiFi clients:** br-wifi_iso, internet via NAT
- **Security:** br-wifi_iso SSH blocked via iptables

### Mode1 + no SSID (Mode3 overlap)
- **WAN:** usb0 (same as Mode1)
- **SSH:** LAN + WiFi both open
- **Use case:** RNDIS tethering, SSH from phone without cable
- **How:** Mode3 switch position, blank SSID in GPIO-Predefined

### Mode2 — RJ45 WAN (Hotel/Lab)
- **WAN:** eth0 (RJ45, DHCP or static via GPIO-Predefined)
- **SSH:** br-wifi_iso only (phone access)
- **eth0:** removed from br-lan, dedicated to WAN
- **WiFi clients:** br-wifi_iso, true NAT routing
- **Note:** eth0 bridge manipulation required — not seamless toggle

### Mode3 — External WiFi WAN (Hotspot)
- **WAN:** wlan0 (connects to phone hotspot)
- **SSH:** LAN + WiFi both open
- **Watchdog:** mode3_watchdog.sh monitors, auto-fallback to USB WAN
- **Hotspot swap:** WPS 3-7sec hold swaps between two predefined SSIDs

---

## WPS Button Timing

| Hold Duration | Action |
|---|---|
| 3–7 sec | Hotspot swap (Mode3 SSID/KEY swap) |
| 8–16 sec | Guest WiFi toggle |
| 17–28 sec | Reboot |
| 29–48 sec | Emergency mode (passwordless SSH, emergency AP) |
| 49–70 sec | Factory reset (20sec countdown, cut power to abort) |
| >70 sec | Cancelled |

---

## Boot Sequence
procd → S95modeboot
→ GPIO read (pins 18, 20)
→ Guest+Emergency WiFi disabled
→ mode_manager → modeX.sh
→ network restart
→ led_daemon spawned
→ modeboot_mode_exec written (MODE + timestamp)
→ modeboot_running cleared
→ trap - EXIT (normal completion)
Toggle buttons during boot:
→ modeboot_running check → ignored
→ toggle_normal + AGE check → ghost bounce suppressed
→ real user press after boot → mode switch enabled

---

## Traffic Shaping

- **Interface:** br-wifi_iso (bridge egress)
- **Method:** HTB + fq_codel, subnet /28 mask
- **Target:** configurable via GPIO-Predefined [SHAPER]
- **Goal:** Force YouTube auto-resolution to 360-480p on metered SIM
- **RAM impact:** Negligible — bridge module already loaded
- **Toggle:** mr menu option 3

---

## SSH Access Policy

| Mode | br-lan (RJ45) | br-wifi_iso (WiFi) |
|---|---|---|
| Mode1 | ✅ open | ❌ blocked |
| Mode2 | ❌ blocked | ✅ open |
| Mode3 | ✅ open | ✅ open |
| Mode3 no-SSID | ✅ open | ✅ open |

Toggle SSH via WiFi anytime: mr menu option 7 (blocked in Mode2).

---

## mr Menu

Toggle Guest WiFi
System Status (RAM / WAN IP / Mode)
Toggle Shaper (Limit 480p Video)
Show Devices + Shaper Config
Enter Device Details for Shaper
Check Shaper tc Details
Toggle SSH via WiFi (blocked in MODE2)
Toggle wan_watch (cron)
Backup extroot/overlay (ready to scp)
q) Exit


---

## File Structure
/root/
mode_manager.sh       — mode dispatcher
mode3_watchdog.sh     — WiFi WAN monitor + fallback
led_daemon.sh         — LED state controller
hotspot_swap.sh       — WPS hotspot SSID swap
wan_watch.sh          — WAN ping watchdog (cron)
modes/
mode1.sh            — USB WAN setup
mode2.sh            — RJ45 WAN + eth0 bridge isolation
mode3.sh            — WiFi WAN env setup
/etc/
toggle_resolve.sh     — button event → mode resolution
init.d/modeboot       — boot GPIO detection + sequencing
init.d/shaper         — HTB traffic shaper
rc.button/wps         — WPS button action handler
/usr/bin/
mr                    — management menu

---

## Excluded from Repo
GPIO-Predefined     — SSID, keys, shaper config (personal)
hotspot_sets        — hotspot credentials (personal)
/etc/config/        — wireless, network, dhcp, firewall (personal)


Add to .gitignore:
GPIO-Predefined
hotspot_sets

---

## RAM Profile
Boot completed:    ~2.2MB free
Settled (cached):  ~6MB effective free
CPU idle:          ~92%
Shaper overhead:   negligible
br-wifi_iso:       negligible (kernel bridge)

---

## Known Limitations

- Mode2 requires eth0 bridge manipulation — not seamless toggle
- 4MB flash limits package installation
- mwan3 multi-WAN routing too heavy for 4/32 (v3 consideration)
- Simultaneous 3-WAN routing policy = v3 future

---

## Round Table

Built collaboratively across multiple AI sessions:

- **Sai (ChatGPT)** — foundation, extroot, initial mode scripts
- **Cloud (Claude)** — boot hardening, daemon dedup, toggle logic
- **Bigger Cat (Claude Opus)** — br-wifi_iso architecture, SSH policy
- **Jan (Gemini)** — context holding, session continuity
- **Little Cat** — quick lookups, package research

Human directed. AI advised. Constraints treated as design signals.

---

## Version History

- **v1.0** — Basic 3-mode switching, extroot, GPIO detection
- **v2.0** — Bridge isolation, boot hardening, hotspot swap,
             subnet shaper, mode3_watchdog v2, mr menu v2
- **v3.0** — Routing policy switching, seamless WAN toggle (planned)
