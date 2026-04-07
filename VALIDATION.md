# VALIDATION.md
# Verification & Testing Log — project-mr
# ─────────────────────────────────────────────────────────────────────
# Embedded hardware cannot run automated test suites in the pytest sense.
# This log documents how correctness was confirmed on real hardware —
# the embedded systems equivalent of an integration test suite.
# ─────────────────────────────────────────────────────────────────────

# Validation & Testing Log

> Embedded Linux on constrained hardware (4MB flash, 32MB RAM) cannot host
> a conventional test runner. Validation here means: real hardware, real traffic,
> real failure scenarios — observed and confirmed on the production device.

---

## Mode 1 — USB WAN (RNDIS/CDC 4G Modem)

**How confirmed:**
- Plugged Tianjie MF782D(E) USB modem into hub upstream of Mr
- Rebooted — `modeboot` detected GPIO switch position, invoked `mode1.sh`
- `mr 3` confirmed: WAN IP assigned from modem's DHCP, mode = 1, RAM stable
- LED: 1-blink pattern confirmed by visual observation
- Browsed from downstream client — DNS resolved, internet reachable
- Upload shaper toggled via `mr 2` — confirmed bandwidth throttle via speedtest.net

**Edge case confirmed:**
- Android 11 phone substituted for USB modem (RNDIS) — WAN IP assigned correctly
- iOS hotspot via USB: connection not established (expected — iOS USB tethering incompatible with OpenWrt RNDIS stack on this build)

---

## Mode 2 — Ethernet WAN (Hotel / Office RJ45)

**How confirmed:**
- Connected RJ45 upstream to office switch (DHCP environment)
- GPIO switch moved to Mode 2 position, rebooted
- `mode2.sh` applied `eth0` as WAN — `mr 3` confirmed WAN IP from upstream DHCP
- LED: 2-blink pattern confirmed
- Downstream WiFi clients received IPs on 192.168.123.x subnet — no conflict with upstream 192.168.1.x

**Known constraint confirmed:**
- `wlan0` and `eth0` share `br-lan` bridge — SSH accessible from both WiFi and cable (per-mode SSH restriction not enforceable on this hardware)
- Three independent AI assessments (Sai/ChatGPT, Jan/Gemini, Cloud/Claude) confirmed same root cause independently — accepted as hardware limit, deferred to V2

---

## Mode 3 — WiFi Client WAN (Hotspot / Public WiFi)

**How confirmed:**
- SSID and KEY populated in `GPIO-Predefined [GPIO3]`
- GPIO switch moved to Mode 3, rebooted
- `mode3.sh` associated to upstream WiFi — `mr 3` confirmed WAN IP from hotspot DHCP
- LED: 3-blink pattern confirmed
- Downstream clients routed through Mr — internet reachable

**Watchdog confirmed:**
- Upstream hotspot WiFi dropped (phone screen locked, hotspot timed out)
- `mode3_watchdog.sh` detected association loss — re-attempted connection
- WAN IP re-assigned after hotspot resumed — no manual intervention required

**Fallback confirmed:**
- SSID field left blank in GPIO-Predefined — Mode 3 falls back to Mode1 behaviour + full WiFi SSH access (documented design behaviour)

---

## WPS Button Timing Functions

**How confirmed (each zone tested individually):**

| Hold duration | Function | Confirmed |
|--------------|----------|-----------|
| Release at 5s+ | Guest WiFi toggle | ✅ Guest SSID appeared/disappeared on downstream scan |
| Release at 17s+ | Reboot | ✅ System rebooted, resumed correct mode on boot |
| Release at 29s+ | Emergency WiFi | ✅ Passwordless SSID appeared, SSH accessible without credentials |
| Release at 49s+ | Factory reset (20s abort window) | ✅ Tested — power cut during countdown aborted reset successfully |

---

## Extroot Stability

**How confirmed:**
- `extroot_watch.sh` runs via cron — monitors SD card mount health
- Pulled SD card mid-operation (simulated corruption) — watchdog detected mount failure, logged
- Re-inserted SD card — system recovered without full reboot
- `/overlay` confirmed on SD card, not internal flash — `df` output verified

---

## Traffic Shaper

**How confirmed:**
- `LIMITED_IP` set to test device in GPIO-Predefined
- `mr 2` enabled shaper — YouTube on test device degraded to ~360-480p (visual confirmation)
- Other downstream devices unaffected — full speed confirmed on separate client
- `mr 2` disabled shaper — test device returned to full speed

---

## System Stability (Long-term)

| Metric | Observed result |
|--------|-----------------|
| OOM incidents | Zero since Mode 1 stable deployment |
| Modem heat | MF782D internal WiFi disabled — sustained temperature manageable |
| Uptime | Multiple multi-day continuous operation periods confirmed |
| extroot write pressure | Minimal — overlay on SD, not internal flash |

---

## Summary

All primary functions verified on physical hardware under real operating conditions.
No simulated environments. No virtual machines. No emulators.

The MR3020 is the test bench, the staging environment, and the production system simultaneously.
That is the nature of embedded systems engineering at this constraint level.

*Validation log maintained by Hikaru. Last reviewed: 2026.*
