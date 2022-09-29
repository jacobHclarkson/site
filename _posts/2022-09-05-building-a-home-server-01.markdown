---
layout: post
title:  "Building a Home Server - Part 1: The Build"
date:   2022-09-05 10:00:00 +0200
categories: projects home-server
---

# Why

I decided to build a home server for a few reasons:
- I want some sort of NAS to store media and backups of files
- I want to run a few services ([Pi-hole][pi-hole], [Plex][plex], etc.)
- I want a "homelab": a segregated environment to experiment and learn
- I love building computers

I didn't want to buy an off-the-shelf NAS, since they are not very cost
effective, and less versatile than just-a-linux-box. I didn't want to use
multiple Raspberry Pis, since there's a lot of extra faff involved with not much
upside. And I didn't want to try and use some combination of third-party cloud
solutions, either, as that wouldn't address the last point on the list.

Building a small PC, then, seems like it will be a reasonably cost-effective,
and fun way of satisfying these requirements.

# The Parts

![parts](/assets/components.jpg)

Part selection was based on a combination of value, availability, and energy
efficiency. I went with the Mini-ITX form-factor so that the final product can
be easily tucked away. For the initial build, I omitted HDDs that will
eventually be used for bulk storage. These will come later. The "G" series Ryzen
processors are the ones with integrated graphics. I chose one of these so that
I'll be able to connect a monitor to the box if/when I need to, without having
the added cost/power-draw of a discrete GPU.

| Component | Part |
|-------|--------|
| CPU | AMD Ryzen 5 4600G |
| Motherboard | Gigabyte A520I |
| RAM | G.Skill DDR4-3200MHz CL16 (32GB) |
| PSU | Antec Atom G650 |
| Case | Thermaltake Core V1 Mini ITX Cube |
| Disk | Mushkin Tempest 256GB M.2 SSD|

These parts only cost a little bit more than a 4-bay QNAP NAS, and about the
same as a Synology 4-bay NAS. The result is a more powerful and flexible
machine.

# The Build

![build](/assets/box.jpg)

The Thermaltake Mini Cube was lovely to build in. I've never built a small
form-factor PC before, and it went surprisingly smoothly. The only irritating
part was getting the system panel on the case (power button, reset button, LEDs)
connected to the motherboard. This is always a pain in the ass, though, so I
don't hold it against this particular motherboard or case.

Now that everything is put together, it's time to choose and install an
operating system.

[pi-hole]: https://pi-hole.net/
[plex]: https://www.plex.tv/
