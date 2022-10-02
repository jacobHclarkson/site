---
layout: post
title:  "Building a Home Server - Part 4: NFS"
date:   2022-10-16 09:00:00 +0200
categories: projects home-server
---


## NFS

Network File System (NFS) is a mechanism that allows data on a disk on one
machine to be accessed by other machines over a network. We can use this to turn
our computer-with-disks-attached-to-it into a NAS that all the machines on the
local network can connect to.

# Configuring the Server

We'll be roughly following the steps laid out in [this guide][nfs-how-to].

Install the `nfs-kernel-server` package. You may notice that, after
installation, the `nfs-kernel-server` service is listed as `active (exited)`.
[This is expected][active-exited], as the service is merely responsible for
launching the kernel module. To confirm that the NFS server is actually running,
you can use the following commands. If they return values, rather than
complaining the files don't exist, then you should be good to go.

```bash
> cat /proc/fs/nfsd/threads
8
> cat /proc/fs/nfsd/versions
-2 +3 +4 +4.1 +4.2
```

Now we need to create a directory in which to put things that we want to share:
```bash
> mkdir /srv/media
```

We want to "point" this shared media directory to where all the media actually
is (on our RAID disk). We'll do this using a bind mount:
```bash
> sudo mount --bind /mnt/raid/media/ /srv/media/
```

The `mount` command is commonly used to mount a device (like a disk, or flash
drive) to a directory. Using the `--bind` flag, we are mounting a directory to
another directory, effectively creating an alias for the original directory.
After running the above command, the contents of `/mnt/raid/media` and
`/srv/media` will be identical.

We also want to make sure this mount occurs automatically if the server is
restarted, so we add the following entry to `/etc/fstab`:
```
/mnt/raid/media    /srv/media      none    bind  0  0
```

Now, we add an entry to the `/etc/hosts` file:
```
127.0.1.1       box
```

With all of that out of the way, it is time to tell NFS to start serving our
files. NFS is controlled via the `/etc/exports` file. In our case, we append the
following entries to this file:

```
/srv        192.168.1.0/24(rw,fsid=0,no_subtree_check,sync)
/srv/media  192.168.1.0/24(rw,nohide,insecure,no_subtree_check,sync)
```

Restart the NFS kernel server service, and sharing will now be active.

For every new directory we want to share, we would create the directory in the
`/mnt` directory, bind mount the new directory to the `/srv` directory, append
an entry similar to the `/srv/media` one to the `/etc/exports` file, and restart
the NFS service.

Next, let's configure clients to be able to access our shared files.

# Configuring a Client (Arch)

First, add an entry to the client's hosts file that points to the IP of your NFS
server. For example:
```
192.168.1.201 box
```

While on the same network as the NFS server, you can then execute the
`showmount` command to list the available shares. For example (note that `box`
is the hostname of the NFS server machine):

```bash
> showmount -e box
```

```
Export list for box:
/srv/media 192.168.1.0/24
/srv       192.168.1.0/24
```

Great! Our shared directory is visible from the client. We can mount it like
this:

``` bash
> sudo mkdir /mnt/media
> sudo mount -t nfs4 -o vers=4 box:/media /mnt/media
```

Note that in the second command, we don't specify the full path to the shared
media directory on the server (we omit the `/srv` part). If we want this
directory to be mounted automatically when we reboot the client, then we also
need to add an entry to `/etc/fstab`. E.g. (courtesy of the [Arch
wiki][arch-nfs]):

```
box:/media   /mnt/media   nfs   defaults,timeo=900,retrans=5,_netdev	0 0
```

Now if we run `df -h` we can see that our new NFS media drive is mounted:
```
Filesystem      Size  Used Avail Use% Mounted on
dev              16G     0   16G   0% /dev
run              16G  2.4M   16G   1% /run
/dev/nvme0n1p2  904G   98G  761G  12% /
tmpfs            16G  479M   16G   4% /dev/shm
tmpfs            16G   55M   16G   1% /tmp
/dev/nvme0n1p1  300M  288K  300M   1% /boot/efi
tmpfs           3.2G  108K  3.2G   1% /run/user/1000
box:/media      7.3T     0  6.9T   0% /mnt/media
```

# Configuring a Client (Mac)

For mac, the steps to mount the NFS share were the same as they were on Arch
Linux. However, one extra option (`resvport,rw`) has to be provided to overcome
an `Operation not permitted` error (thanks to [this
guide][cyberciti-mac-mount]). The full mount command is as follows:

```
sudo mount -t nfs -o vers=4 -o resvport,rw box:/media /private/media
```

# Configuring a Client (Windows 10)

I managed to get the Windows client working based on information I found
[here][windows-nfs].

The first step was to make sure the NFS client was installed:
- Go to "Programs and Features"
- Click "Turn Windows features on or off" on the left side panel
- Check the box for "Client for NFS" and click "OK" 

After this, I was able to connect to the share with read only access by doing
the following:
- Open file explorer
- Right click in empty space, and click "Add a network location"
- Follow the prompts and enter the "windows style" (example below) address of
  the server
- Enter a name for the network location, and complete the prompt

In my case, the server address was as follows:

```
\\192.168.1.201\srv
```

Note that this time, we specify the root of the share, rather than the media
sub-directory.

At this point, the NFS share shows up as a network drive in windows file
explorer! Hooray! However, the windows client only has read access to the share
at this point. To add write access, the registry needs to be edited.

Before interfering with the registry, we need to get the UID and GID of the user
on our server who has access to the NFS directory. We can use the `id` command
to get this info. The output will contain the UID and GID:
```
uid=1000(jhc) gid=1000(jhc)...
```

Now, open regedit and browse to:

`HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default`

In this location, create two new 32-bit DWORDs: `AnonymousUid`, and
`AnonymousGid`. Set their values to the UID and GID of your user on the NFS
server (I had to put the DWORDs into decimal mode first).

After rebooting the machine, the Windows client should now have read and write
access to the NFS share.

At this point in the series, we now have the following:
- A small, relatively low-power machine...
- running a very stable OS...
- with a large amount of redundant data storage...
- which is accessible by other machines over the network

Or in other words, a perfectly serviceable home-built NAS. In the next post in
the series, we'll start experimenting with Kubernetes as a tool to manage the
services we want to add to this server.

[part-1]: {% post_url 2022-09-05-building-a-home-server-01 %}]
[nfs-how-to]: https://help.ubuntu.com/community/NFSv4Howto
[active-exited]: https://superuser.com/questions/1627335/nfs-server-active-exited
[arch-nfs]: https://wiki.archlinux.org/title/NFS#Mount_using_/etc/fstab
[cyberciti-mac-mount]: https://www.cyberciti.biz/faq/apple-mac-osx-nfs-mount-command-tutorial/
[windows-nfs]: https://graspingtech.com/mount-nfs-share-windows-10/
