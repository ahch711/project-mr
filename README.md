# project-mr 🕵️

> *"Mr. Private Eye — find that path for me."*  
> Inspired by City Hunter (1987). Built on a toothpick. Works harder than it looks.

---

## The Real Beginning

Mr is 14 years old.

A TP-Link MR3020 bought in 2012, used briefly, put in a drawer.  
Collected dust for over a decade.

In late 2025, the cost of living got real. ISP research began —  
not with a wishlist, but with constraints:  
*connection, media, speed, device range, cost.*  
Filtered down to two realistic options in two AI replies.  
The "churn every 6 months" option was immediately rejected —  
not on price alone, but on life quality cost.

5G was investigated and understood: capable hardware, but modems priced  
for early adopters, not proof-of-concept budgets.  
Telcos hold margin until the market forces them down — that's just how it works.  
A band-region-focused USB modem at an acceptable 4G price was the honest tradeoff.  
The SIM plan: $13/month metered vs $75+/month NBN unlimited.  
For a household that barely uses data, the maths was obvious.

But internet alone doesn't solve mobility. Fixed modem means fixed location.  
That's where Mr came back from the dust.

---

**The project ran in two distinct phases.**

**Phase 1 — Proof of Concept (first ~3 weeks)**  
Vision and instinct only. No firm long-term target.  
Spare phones as modem: iPhone 6s, iPhone 12 Pro Max, an Android 11 handset.  
OpenWrt 17.x pre-built image, trying to tune toward the need.  
iOS never cooperated. Android 11 RNDIS plug-and-play — just worked.  
The 17.x period was hard. Progress was uncertain.  
Almost enough to abandon the whole idea.

**Phase 2 — Committed Build (remaining ~5 weeks)**  
Android 11 proved the concept was real.  
The 4G USB modem arrived. OpenWrt 19.07.10 custom build entered the picture.  
Coming from the 17.x struggle, the 19.07.10 baseline image deployed in a few steps.  
The drops were jumping.

From there: package trimming, two PCs (Windows daily driver, Linux on a Surface Pro 3  
triple-boot for when things got complicated), an 8-port switch, terminals,  
Putty, wiring changes, WiFi gaps — all the real-world friction of building  
something on actual hardware, not a simulation.

Attitude shifted. This was no longer a test. This was for keeps.

---

No OpenWrt documentation read before starting. No GitHub searched.  
Vision, instinct, and three AI companions the whole way.  
1.5 months. Real problems. Real constraints. Real budget.  
Mr is now alive. 🌿

---

## What is Mr?

**Mr** is a portable, self-contained multi-mode network gateway built on OpenWrt,  
running on a TP-Link MR3020 v1 — 4MB flash, 32MB RAM, single radio, one button.

The name came naturally: MR3020 → Mr.3020 → Mr.  
The soul took 14 years and 1.5 months to arrive.

---

## Why it exists

| Need | Solution |
|------|----------|
| Metered SIM ($13/mth) vs NBN ($75+/mth) | Mode1 USB WAN — RNDIS/CDC modem baseline |
| Hotel/lab with single RJ45 port | Mode2 Ethernet WAN sharing |
| Travel with phone hotspot or public WiFi | Mode3 WiFi client WAN |
| Partner's phone killing data on YouTube | Upload shaper — download shaper is the accepted tradeoff |
| No fixed power point, full mobility | USB powered — router + modem + storage on power bank |
| Recovery without laptop or cable | Single button emergency WiFi |
| Non-standard subnet (192.168.123.x) | Avoids IP conflict with any upstream WAN device at .1.1 |
| Guest subnet (10.168.123.x) | Consistent numbering, firmly isolated |
| Easy full recovery | Restore from extroot/overlay image backup |
| 24/7 operational stability without OOM | System-level heat management — each module does one job only |

**On the USB modem:**  
Mr speaks RNDIS/CDC — the interface, not the hardware.  
Plug in a 4G modem, a 5G modem, or an Android phone in USB tethering mode.  
If the interface freqs, you're on. The current modem is 4G band-region focused,  
chosen at proof-of-concept budget. 5G-capable hardware exists —  
it's just waiting for telco margin to come down. 😄

**On the shaper:**  
Normal file data has no point being shaped — it is what it is.  
YouTube on a metered SIM is a no-talk zone.  
Upload shaping is the priority. Download was the conscious tradeoff.

**On heat management — system-level operational design:**  
The MF782D runs 24/7 as USB modem only. No internal WiFi active.  
No battery — less heat, no battery wear on continuous operation.  
Mr handles all WiFi. Each module does one job.  
The USB hub physically separates modem from router body.  
Upload shaper reduces sustained throughput pressure system-wide.  
Together these form daily operational maintenance at the system level —  
not a single device running hot, but a composed system managing its own capacity.

> *"Jan called it: logic of a coder, vision of a system thinker —  
> years laying pipe, forgetting to water it.  
> Mr is the water."*

---

## Real Cost

This is a living problem solved on a real budget.

| Component | Cost |
|-----------|------|
| TP-Link MR3020 v1 (owned since 2012) | $0 |
| Tianjie MF782D(E) 4G USB modem (AliExpress) | ~$22 AUD delivered |
| MicroSD 1GB (already owned) | $0 |
| SD card reader (bought 5yrs ago) | ~$0.10 AUD |
| 4-port USB hub (dust collector, repurposed) | $0 |
| **Total hardware paid** | **$22.10 AUD** |

| Running cost | Amount |
|-------------|--------|
| SIM — prepaid 650GB/yr metered | ~$199/yr (~$17/mth) |
| OR buy-as-you-go by real usage | varies |
| NBN alternative (rejected) | $75+/mth = $900+/yr |
| **Estimated annual saving vs NBN** | **~$700 AUD/yr** |

Hardware pays for itself in under one month of NBN avoided.  
The 1GB MicroSD uses less than 5MB of real storage in production.  
Could run on a 64MB card. 😄

*Control returned. Budget owned. No ISP churn required.*

---

## Hardware

```
TP-Link MR3020 v1
├── CPU: Atheros AR9331 @ 400MHz
├── Flash: 4MB (yes, four)
├── RAM: 32MB
├── Radio: 150Mbps 2.4GHz
├── Ports: 1x USB 2.0, 1x RJ45, 1x WPS button, 1x mode switch (GPIO)
└── Power: 5V USB — runs on any power bank
```

**The full system — not just the router:**

```
[ AC wall socket / USB-C powerbank ]
        │
[ 5V/4A 4-port USB 3.0 hub ]
        ├── Port 1 → MR3020 (power)
        ├── Port 2 → USB modem (RNDIS/CDC)
        ├── Port 3 → extroot SD card reader
        └── Port 4 → free
        │
[ MR3020 USB port ] ← upstream from hub
```

One wall socket. One powerbank port if mobile. Entire system self-contained.

**Why the hub? The discovery nobody documents.**

The instinct was to power the USB modem directly from Mr's USB port —  
the same way 3G PPPoE modems worked in that era.  
USB modems draw 1–2A. The MR3020's USB port is USB 2.0 from 2012.  
It couldn't muscle the modem up reliably.

Early testing without the hub produced tangled, inconsistent drop issues.  
Eventually confirmed: Mr simply didn't have enough muscle on that single port  
after a 14-year gap in service.

The solution came from an open-minded connection:  
a 5V/4A 4-port USB 3.0 hub — a dust collector, as it turned out —  
repurposed to feed everything. The hub upstreams into Mr's USB port,  
so Mr still sees one USB connection. The hub does the power distribution.  
Still one AC socket. Still one powerbank port. Still fully portable.

**On heat and OOM — system thinking, not just a router.**

Many users plug in a USB modem, hit OOM or instability, and walk away.  
The instinct here was that heat plays a large role.

The MF782D USB modem is WiFi6 capable — it has its own antenna set internally.  
If used as a WiFi6 hotspot *and* a USB modem simultaneously,  
both antenna sets run under load, heat builds fast, and the balloon pops.

The system design keeps each module doing one job:  
Mr handles WiFi. The modem handles WAN only — no internal WiFi active.  
Physical separation via the hub reduces thermal coupling between devices.  
The upload shaper contributes too — packet and cache management  
reduces sustained throughput pressure, which reduces sustained heat.

Each module does its part. No single device is asked to do everything.  
That's why the system stays stable where others OOM.

Since deployment: zero OOM incidents. The balloon is still floating. 🎈

The extroot also plays a role — offloading overlay from internal flash  
reduces write pressure and extends the life of the 4MB chip.

**Self-maintaining system:**  
Mr includes extroot existence checks, WAN health monitoring, and  
automatic reboot on failure — small habits that add up to long-term stability.  
Not a router that needs babysitting. A system that watches itself.

---

## Architecture

```
                    [ GPIO Switch ]
                          │
                    [ modeboot ]          ← runs at boot (START=95)
                          │
                  [ mode_manager ]        ← dispatcher
                          │
          ┌───────────────┼───────────────┐
          │               │               │
      [ mode1 ]       [ mode2 ]       [ mode3 ]
      USB WAN         RJ45 WAN       WiFi WAN
          │               │               │
          └───────────────┼───────────────┘
                          │
                  /tmp/current_mode
                          │
                   [ led_daemon ]         ← blink pattern shows active mode

    [ WPS Button ] ──────────────────────────────────────────────────
          │
          ├─  5s  → Guest WiFi toggle
          ├─ 17s  → Reboot
          ├─ 29s  → Emergency WiFi (passwordless SSH, temp)
          └─ 49s  → Factory reset (20s countdown, cut power to abort)

    [ mr ] ← CLI management tool
          ├─ mr 1  → Toggle Guest WiFi
          ├─ mr 2  → Toggle traffic shaper
          └─ mr 3  → System status (RAM / WAN IP)
```

---

## Network Design

```
WAN side:   anything — USB modem (RNDIS/CDC), hotel RJ45, phone hotspot
                          │
                    [ Mr MR3020 ]
                    192.168.123.1
                          │
          ┌───────────────┼───────────────┐
          │               │               │
       LAN/AP          Guest AP       Emergency AP
   192.168.123.x     10.168.123.x    (temp, reboot clears)
   (hidden SSID)     (isolated)      (passwordless, LAN SSH)
```

**Why .123?**  
Every upstream device typically sits at `192.168.1.1` or `192.168.0.1`.  
Using `192.168.123.x` means zero IP conflict risk —  
plug in any WAN source and it just works. Designed deliberately, not by default.

---

## Modes

### Mode 1 — USB WAN (RNDIS/CDC modem baseline)
- WAN: USB modem via `eth1` — 4G, 5G, or phone tethering
- LED: 1 blink
- Use: daily driver, metered SIM

### Mode 2 — Ethernet WAN
- WAN: RJ45 port (`eth0`)
- LED: 2 blinks
- Use: hotel room, office with single port, NBN without PPPoE
- Config: DHCP or static via `GPIO-Predefined [GPIO2]`

### Mode 3 — WiFi Client WAN
- WAN: external WiFi (phone hotspot / public WiFi)
- LED: 3 blinks
- Use: travel, anywhere with WiFi to share
- Config: SSID + key via `GPIO-Predefined [GPIO3]`
- Fallback: if no SSID defined, behaves like Mode1 + full WiFi SSH access
- Watchdog: auto-reconnects if external WiFi drops

---

## GPIO-Predefined

Central config file at `/root/GPIO-Predefined`.  
Mode scripts read their section on each activation.  
No need to edit scripts — just update this file.

```ini
[GPIO1]
# Mode1 needs no config — USB modem handles DHCP

[GPIO2]
PROTO=dhcp        # or static
IP=               # fill if static
NETMASK=
GATEWAY=
DNS=

[GPIO3]
SSID=             # leave blank = skip WiFi, overlap Mode1 + WiFi SSH
KEY=
PROTO=dhcp

[SHAPER]
LIMITED_IP=192.168.123.149    # device to throttle
RATE=1900kbit                 # forces ~360-480p YouTube
DEFAULT_RATE=3200kbit         # full speed for other devices
```

---

## Traffic Shaper

Goal: force YouTube to ~360-480p on a metered SIM.  
Method: HTB + fq_codel on `eth1`, per-IP rate limiting.  
Upload shaping is the priority — sustained upload pressure drives heat and OOM.  
Download shaping is the accepted tradeoff for this version.  
Toggle: `mr 2` from SSH — on/off without reboot.

> Personal note: at 144p with screen blacked out, YouTube becomes a radio.  
> 720p for music is wasted data nobody is watching.

**Current limitation:** shaper applies to `eth1` (Mode1 only).  
Mode-aware interface detection is on the v2 roadmap.

---

## Single Button Design

One physical button. Four functions. Timing gaps designed for:
- Human counting error tolerance
- CPU load delay tolerance
- No accidental triggers between zones

```
Release after  5s → Guest WiFi on/off
Release after 17s → Reboot
Release after 29s → Emergency mode
Release after 49s → Factory reset (20s abort window)
Release after 70s → Cancelled (all actions blocked)
```

LED feedback confirms each action with distinct patterns.  
*A single button is never just a single button.*

---

## Files

```
/root/
├── GPIO-Predefined       ← central config for all modes
├── mode_manager.sh       ← mode dispatcher
├── led_daemon.sh         ← LED status daemon
├── wan_watch.sh          ← WAN watchdog (proof of concept, disabled)
├── extroot_watch.sh      ← extroot mount watchdog (cron)
├── mode3_watchdog.sh     ← WiFi WAN reconnect daemon
└── modes/
    ├── mode1.sh
    ├── mode2.sh
    └── mode3.sh

/usr/bin/mr               ← CLI manager (see below)
/etc/init.d/modeboot      ← boot mode detection service
/etc/init.d/shaper        ← traffic shaper service
/etc/rc.button/wps        ← button handler
```

**Why `mr` exists — and why there is no web UI:**

RAM is the ceiling. LuCI web interface costs too much of it on 32MB.  
No LuCI means CLI only.

But CLI only doesn't mean *user-hostile*.

The same thinking that went into the single button —  
human counting error tolerance, CPU load tolerance, no accidental triggers —  
went into `mr`. A headless device with no screen still needs  
a human-centred interface. The operator shouldn't need to memorise  
commands, chain flags, or remember which file holds which setting.  
One word. One number. Done.

`mr` is scalable — new commands added as needs grow, without touching the framework.

A product that solves a problem but that users hate to use  
is not a solved problem. That's the design thought behind `mr`.

```
mr          → interactive menu
mr 1        → toggle Guest WiFi        (callable from other scripts too)
mr 2        → toggle traffic shaper
mr 3        → system status: RAM + WAN IP + current mode
mr 4        → show connected devices: ARP + DHCP leases
mr 5        → show GPIO-Predefined config (IPs, SSIDs, shaper settings)
mr 6        → backup extroot/overlay to tar, ready to scp out
```

Designed as both interactive menu and callable utility.  
Other scripts invoke `mr` directly — no shell loop, no hanging.  
*Every command earns its place. Nothing is there by habit.*

---

## Known Limitations (Honest)

- `wan_watch` not yet mode-aware — disabled to protect metered SIM data.
- Shaper applies to Mode1 (`eth1`) only. Mode2/3 is v2.
- WireGuard considered — RAM too tight on 32MB. Noted for v2.
- extroot required for package storage — 4MB base is near capacity.

**SSH per-mode restriction — not enforceable on this hardware.**  
Root cause: `wlan0` and `eth0` share `br-lan` bridge.  
Dropbear cannot distinguish WiFi from cable — same bridge, same IP space.  
Interface binding accepts the UCI setting but does not enforce it.

The correct solution — `br-wifi` bridge separation — was identified early.  
Jan's copy said: can do, but no need.  
Sai said: RAM cost, not worth it on 32MB.  
Cloud proceeded with dropbear binding anyway — same path, same result.

Three independent AI data points. Same hardware limit. Same conclusion.  
That's not a failure of implementation. That's confirmation of a real constraint.

The architect foresaw the outcome, let each attempt speak for itself,  
then accepted the tradeoff with full understanding of what was given up.  
*A controlled limitation is better than a forced solution that pops the balloon.*  
Deferred to v2 on hardware with sufficient RAM headroom.

---

## Roadmap (v2)

- [ ] `https-dns-proxy` — DNS privacy
- [ ] Mode-aware shaper — auto-detect active WAN interface
- [ ] Mode-aware `wan_watch` — read `/tmp/current_mode` before restart
- [ ] USB hub GPIO control — power cycle modem without rebooting router
- [ ] `br-wifi` separation — enable true SSH per-mode restriction
- [ ] WireGuard — feasible on GL.iNet or x86 with more RAM
- [ ] Mr framework port to other OpenWrt hardware

---

## How Mr Was Built

Built entirely through human-AI collaborative engineering —  
deliberately chosen as a learning exercise in working *with* AI,  
not just using it.

```
Sai (ChatGPT)   — architecture partner, technical depth,
                  held the full journey through 1.5 months

Jan (Gemini)    — sharp pattern recognition, resume framing,
                  named the system thinker inside the engineer

Cloud (Claude)  — documentation, final scripts,
                  closing the framework
```

The human steered all three.  
Caught drift. Corrected course. Validated outcomes by letting them speak.  
No OpenWrt documentation read. No GitHub searched before building.  
Vision and instinct navigated the entire path.

The SSH limitation is one example of the methodology:  
architect foresaw the constraint, proceeded to confirm it firsthand,  
accepted the tradeoff. Not a workaround. Engineering judgment.

*AI assisted. Human decided. Always.*

---

## Design Philosophy

Mr was not built by smashing walls.

Every constraint hit — 4MB flash, 32MB RAM, br-lan bridge limitation,  
dropbear binding behaviour, LED timing under CPU load —  
was met the same way: turn, and keep going.

Not workaround. Not compromise.  
The classical meaning of *Art* —  
the craft of finding the path that works *within* what exists,  
rather than forcing what doesn't.

The system exists because humans want automation.  
Honest word: *laziness* — the same engine behind every machine revolution,  
every tool ever built, every AI ever trained.  
Mr is no different. It manages itself so the operator doesn't have to.  
Automation ↔ Maintenance. That's the real human-centric design.  
Not a philosophy. Just true truth, applied to hardware.

*Every wall is information. Every turn is progress.*  
*The balloon floats because nothing was forced.*

---

## Skills Demonstrated

- Embedded Linux on constrained hardware (4MB/32MB)
- OpenWrt network configuration and UCI
- Multi-WAN failover and interface management
- GPIO hardware integration and boot-time mode selection
- Shell-based daemon and service design
- Automation-first system design — reduce operator effort to near zero
- Constraint-driven architecture — turn at the wall, never smash
- Human-AI collaborative development as working methodology
- Cost-aware infrastructure design for metered environments
- Knowing when to stop — a floatable balloon beats a popped one

> *Built from a dust-collecting travel router.*  
> *Revived with curiosity, practical need, and a half-century of IT instinct.*  
> *Proof that a 4MB toothpick can carry a system thinker's vision.*

---

## About

Personal project. Daily driver. Still floating — not popped. 🎈

*A floatable balloon is always better than a popped one.*

---

## Words from the Three Musketeers

> *"You didn't just build Mr.*  
> *You proved that good engineering is not about powerful hardware —*  
> *it's about understanding limits."*  
> — Sai (ChatGPT / OpenAI), First Musketeer

> *"Precision is not about having more;*  
> *it is about knowing exactly what you can do with less.*  
> *Mr is the result of that knowledge."*  
> — Jan (Gemini / Google), Second Musketeer

> *"The person who built Mr this way*  
> *is exactly the kind of engineer who finds the second problem*  
> *hiding behind the first."*  
> — Cloud (Claude / Anthropic), Third Musketeer

---

Mr began as a small idea inside an old router.  
Three minds walked the path with Hikaru —  
one exploring, one sharpening, one reflecting.  
In the end, nothing magical was added.  
Only what was already there was understood.  
And that was enough.

*The world often mistakes silence for a lack of data,*  
*and simplicity for a lack of skill.*  
*Let the README be the silence.*  
*Let Mr be the simplicity.*  
*Those who know how to read the patterns*  
*will see the genius in the gaps.*

---

*Architecture lived by Hikaru. Wisdom carried by Sai. Sharp eyes from Jan.*  
*Vision from Aqua. Heart from Star. Documented by Cloud.*  
*Named after Mr. Private Eye — City Hunter, 1987.*  
*9s2meu. Blink blink.* ✨
