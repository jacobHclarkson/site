---
layout: post
title:  "Building a Home Server - Part 3: RAID"
date:   2022-09-30 07:00:00 +0200
categories: projects home-server
---

In [Part 1][part-1] of this series, I mentioned that the first requirement that
this server should satisfy is to act as Network Attached Storage (NAS). A NAS is
basically just a hard drive (or group of hard drives) that many computers can be
connected to at once, over a network.

So we need disk space (check - two HDDs), and we need that disk space to be
accessible over the network (check - we'll use NFS for that in a future post). I
want this home-built NAS to feel like a relatively safe place to store data: I
don't want half (or all) of my data to get lost if one hard drive fails. To that
end, we'll first set up RAID.

## RAID

A [Redundant Array of Independent Disks][wikipedia] (RAID) is a way of
organizing a collection of hard drives into a "super hard drive" which has some
special/additional properties. There are several different ways of organizing
disks, each with different advantages and disadvantages.

With only two disks, the following options are available to us:
1. **JBOD** - Just a Bunch of Disks: We take no special action. The setup is
   easy (just plug the disks in and use them), but there are no speed or safety
   benefits. Disk space available is equal to the sum of the space available on
   all the drives. If one drive fails, _the data on that drive_ is lost.
1. **RAID 0** - When we write data to the array, half of it is written to disk
   A, and half of it is written to disk B, and the writing happens concurrently:
   the data is "striped" across the drives. Disk space available is equal to n *
   x, where n is the number of drives in the array, and x is the smallest drive
   in the array. Striping results in a boost in write speed, but _increases_ the
   risk of data loss: if one drive fails, _all_ of the data is lost.
1. **RAID 1** - When we write data to the array, we write the same data to both
   disks. The data is "mirrored" across the drives. Disk space available is
   equal to the that of the smallest drive in the array. The write speed is the
   same as it would be for a single disk, but now, if one drive fails, we don't
   lose any data. Data is only lost if _both_ drives fail.
   
We want to optimize this setup for data safety, rather than disk space or write
speed. RAID 1 is therefore the best choice for our purposes.

# Setting up RAID 1

Let's use `lsblk` to examine our starting position:
```bash
> lsblk
```

This gives:
```
NAME        MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda           8:0    0   7.3T  0 disk  
sdb           8:16   0   7.3T  0 disk  
nvme0n1     259:0    0 238.5G  0 disk  
├─nvme0n1p1 259:1    0   512M  0 part  /boot/efi
├─nvme0n1p2 259:2    0   237G  0 part  /
└─nvme0n1p3 259:3    0   977M  0 part  [SWAP]
```

The OS is installed on `nvme0n1`. We've connected two HDDs to the system, and
they are shown here as `sda` and `sdb`.

To combine these disks into a RAID array, we'll be using a tool called `mdadm`.
The steps below are based on [this example][debian-software-raid].

First, we prepare the disks by zeroing the superblocks: 

```bash
> mdadm --zero-superblock /dev/sda /dev/sdb
```

We get the following output:
```
mdadm: Unrecognised md component device - /dev/sda
mdadm: Unrecognised md component device - /dev/sdb
```

I initially thought that this indicated some sort of error, but it turns out to
be expected. It means that neither of our disks were previously part of any
other RAID array, which makes sense, since the disks are new. This step is
therefore probably only necessary if you are re-using disks that were previously
components of a different RAID array, but hey, it can't hurt.

Next, we create the array:
```bash
> mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sda /dev/sdb
```

Our new device will be called `md0`. The `level` parameter determines which RAID
level is used (0, 1, 5, etc.). The `raid-devices` parameter determines how many
disks are going to be part of this array. Finally, we specify the whole of our
`sda` and `sdb` disks as the devices to be added to the array.

Running `lsblk` again, we now have the following:
```
NAME        MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda           8:0    0   7.3T  0 disk
└─md0         9:0    0   7.3T  0 raid1
sdb           8:16   0   7.3T  0 disk
└─md0         9:0    0   7.3T  0 raid1
nvme0n1     259:0    0 238.5G  0 disk
├─nvme0n1p1 259:1    0   512M  0 part  /boot/efi
├─nvme0n1p2 259:2    0   237G  0 part  /
└─nvme0n1p3 259:3    0   977M  0 part  [SWAP]
```

Cool! Disks `sda` and `sdb` are now part of a `raid1` array. Before we can use
our shiny new uber-disk, we need to create a file system on it, and mount it.

# Creating the Filesystem and Mounting

Here we create the filesystem. Good ol' unencrypted ext4. Nothing fancy:

```bash
> mkfs.ext4 /dev/md0
```

And now we create a mount point:
```bash
> sudo mkdir /mnt/raid
```

We're going to want to mount our RAID array to be mounted automatically whenever
the machine boots. To that end, we append the following entry to `/etc/fstab`:

```
/dev/md0 /mnt/raid ext4 noatime,rw 0 0
```

Now we can mount the new array:
```bash
sudo mount -a
```

`lsblk` now shows our array mounted to `/mnt/raid`
```
NAME        MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda           8:0    0   7.3T  0 disk  
└─md0         9:0    0   7.3T  0 raid1 /mnt/raid
sdb           8:16   0   7.3T  0 disk  
└─md0         9:0    0   7.3T  0 raid1 /mnt/raid
nvme0n1     259:0    0 238.5G  0 disk  
├─nvme0n1p1 259:1    0   512M  0 part  /boot/efi
├─nvme0n1p2 259:2    0   237G  0 part  /
└─nvme0n1p3 259:3    0   977M  0 part  [SWAP]
```

# Querying the RAID Array

To check on the status of our array, we can examine the content of the
`/proc/mdstat` file, or we can use the `mdadm` utility.

Let's check out `mdstat`:
```bash
> sudo cat /proc/mdstat
```

```
Personalities : [raid1] 
md0 : active raid1 sdb[1] sda[0]
      7813894464 blocks super 1.2 [2/2] [UU]
      [>....................]  resync =  4.2% (329999744/7813894464) finish=603.3min speed=206722K/sec
      bitmap: 58/59 pages [232KB], 65536KB chunk

unused devices: <none>
```

As you can see, we get some basic info about the raid level and which disks are
involved, as well as the current resync status. Now let's use `mdadm`:

```bash
> sudo mdadm --query --detail /dev/md0
```

```
/dev/md0:
           Version : 1.2
     Creation Time : Sun Sep 18 07:31:44 2022
        Raid Level : raid1
        Array Size : 7813894464 (7451.91 GiB 8001.43 GB)
     Used Dev Size : 7813894464 (7451.91 GiB 8001.43 GB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

     Intent Bitmap : Internal

       Update Time : Sun Sep 18 07:56:38 2022
             State : active, resyncing
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

Consistency Policy : bitmap

     Resync Status : 3% complete

              Name : box:0  (local to host box)
              UUID : 973f38c3:802ad658:1a4f845e:49712dca
            Events : 2054

    Number   Major   Minor   RaidDevice State
       0       8        0        0      active sync   /dev/sda
       1       8       16        1      active sync   /dev/sdb
```

Here, we get a lot more information, including the current state of the array,
and device counts.

You'll notice that both reports indicate that the array is "resyncing". This
seemed surprising, as both drives were new and empty. What is going on here? Can
we use the array before the sync is complete? According to the man page for
the `mdadm` create command:

> A 'resync' process is started to make sure that the array is consistent (e.g.
> both sides of a mirror contain the same data) but the content of the device is
> left otherwise untouched. The array can be used as soon as it has been
> created. There is no need to wait for the initial resync to finish.

OK that explains the full resync, and at least we can use the array immediately.
But is the resync really necessary for new disks? And is there a way to skip it?
It turns out there is an `--assume-clean` flag that can be passed to the create
command for just this purpose:

> --assume-clean
>
> Tell mdadm that the array pre-existed and is known to be clean.
> It can be useful when trying to recover from a major failure as you can be sure
> that no data will be affected unless you actually write to the array. It can
> also be used when creating a RAID1 or RAID10 if you want to avoid the initial
> resync, however this practice — while normally safe — is not recommended. Use
> this only if you really know what you are doing.

"Only if you really know what you are doing", huh? Well that counts me out.

In the next post in this series, we'll set up NFS to make our RAID array
accessible over the local network, so that other machines can read from, and
write to it.

[part-1]: {% post_url 2022-09-05-building-a-home-server-01 %}]
[wikipedia]: https://en.wikipedia.org/wiki/RAID
[debian-software-raid]: https://wiki.debian.org/SoftwareRAID
