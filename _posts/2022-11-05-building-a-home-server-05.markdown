---
layout: post
title:  "Building a Home Server - Part 5: First Steps with K3S"
date:   2022-11-05 09:00:00 +0200
categories: projects home-server
---

TODO some intro

## K3S

- what is k3s
- installation
- access from other machines
- k9s

## Persistent Volume and Persistent Volume Claim

- how does storage work?
- what are PV and PVC?
- example: yamls for mounting our NFS share (link back to last post)

## Testing
- create a pod that mounts the drive


[part-4]: {% post_url 2022-10-16-building-a-home-server-04.markdown %}]
[k3s]: https://k3s.io/
[k9s]: https://k9scli.io/
[pv-example]: https://github.com/kubernetes/examples/blob/master/staging/volumes/nfs/nfs-pv.yaml
[pvc-example]: https://github.com/kubernetes/examples/blob/master/staging/volumes/nfs/nfs-pvc.yaml
[mounting-pvc-to-pod]: https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/
