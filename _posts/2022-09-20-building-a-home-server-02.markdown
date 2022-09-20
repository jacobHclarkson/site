---
layout: post
title:  "Building a Home Server - Part 2"
date:   2022-09-20 20:00:00 +0200
categories: projects home-server
---

# Choosing an Operating System

For this project, I want three things from the OS (not necessarily in this
order). The OS must be:
1. **Low maintenance**: I don't want to spend too much time
   updating/fiddling/fixing.
1. **Stable**: Things should Just Work<sup>TM</sup>, and Keep
   Working<sup>TM</sup>.
1. **Minimal**: I don't want tons of cruft taking up disk space and increasing
   update sizes.
1. **Easy to use**: It should not be difficult to do things. A big part of this
   is how easy it is to find relevant information online.
1. **Something I'm likely to encounter elsewhere**: Things I do/learn here
   should preferably be transferable, so nothing too weird.

These criteria led me to a shortlist of [Arch][arch], [OpenSuse][opensuse], and
[Debian][debian].

I very briefly considered Ubuntu and Fedora too, but decided against Ubuntu
because I've used it too much, and against Fedora because I've never used it at
all.

I love Arch itself, Arch-based distros ([Manjaro][manjaro] has been my daily
driver for years now), and the all mighty [Arch Wiki][arch-wiki]. In my
experience, Arch, and the derivatives with which I'm familiar, are stable and
easy to use, are as minimal as you want them to be, and used fairly widely.
However, these distros are not "install once and forget about it" - at least
that's not how I _feel_ about them. As a desktop system that is regularly used,
with new tools constantly being installed and uninstalled for testing, and
updates being frequently run, Arch's rolling release makes total sense. But I
don't want another house-plant that I feel I need to tend to. I want a pet rock.

I have read that OpenSuse is a fantastic server distro. I tried it once as a
Desktop distro, and I can certainly see how that might be the case. They offer a
stable release, and the software is super polished. I was blown away by some of
the tooling that is set up out of the box, like automated full system
snapshotting courtesy of ZFS. However, I'm a little too unfamiliar with the
ecosystem to want to use it for this project - I found it hard to know where to
look for good info when last I used it. If my objectives were slightly
different, and I was willing to spend more time learning about the OS itself, as
well as just using it, I would probably have chosen OpenSuse.

Debian it is, then. It is very low maintenance, since there aren't really any
non-critical updates over a release's lifespan. It is very stable, because it is
so thoroughly tested, and then effectively frozen due to the (relative) lack of
updates. The "netinst" is tiny, at only ~300MB. And, finally, it is ubiquitous.

# Installation

![build](/assets/installation.jpg)

Installation of the base OS went very smoothly. The installer is super easy to
use. The only hurdle was being forced to connect the box to the internet via
ethernet because the proprietary drivers required for the motherboard's WiFi
chip are not distributed with Debian (obviously).

Setting WiFi up was not too much of a hassle. It involved adding the non-free
sources to `/etc/apt/sources.list`, installing the drivers I needed (`iwlwifi`),
and following the `nmcli` instructions [here][nmcli].

Additionally, I set up SSH and unattended upgrades. This means that the monitor
can be disconnected, and the box stuck in a corner somewhere.

Next up, we'll add some proper storage to the system.

[debian]: https://www.debian.org/
[arch]: https://archlinux.org/
[opensuse]: https://www.opensuse.org/
[manjaro]: https://manjaro.org/
[arch-wiki]: https://wiki.archlinux.org/
[nmcli]: https://linuxhint.com/3-ways-to-connect-to-wifi-from-the-command-line-on-debian/
