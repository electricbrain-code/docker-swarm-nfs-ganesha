# docker-swarm-nfs-ganesha
Docker swarm nfs-ganesha server container. Super simple instant file sharing.

What is this? The build scripts build a series of 3 containers. The resulting
containers can be combined into a single "manifest". The manifest looks and 
behaves like a container image, however, it has the added advantage that the
docker repository is able to distinguish which architecture it is being
called from and provides the appropriate image. This may be important if 
your cluster is multi-architecture. 

The container architectures are for ARM32, ARM64 and AMD64 cpus.

Combining the images. Here's what worked.

    Download all the images for each architecture onto a single machine 
    (which was done with the aid of the local repo accessible from at least 
    one machine of each type. The local repo here is now using the official docker 
    repository image (which was a rabbithole upgrade of sorts).

    Use the "docker manifest create" command naming downloaded images.

    If your environment has neglected to issue local certificates and
    runs an "insecure" local repo, then as well as having the insecure
    options setup in the configuration for docker on each node, the
    commandline option --insecure must be added to the manifest commands.
    docker manifest create --insecure <manifest-name> <image.arm32> <image.arm64> <image.amd64>

    Delete the images, push the manifest
    docker manifest push --insecure <manifest-name>


In the following run example the /docker.local/nfs-ganesha/data/etc/ganesha
directory contains 2 files. Examples are shown below.

The /docker.local/nfs-ganesha/data/mysharefolder is a location of a directory
that is to be shared among other nodes in the swarm.

Running the container(s):

```
#!/bin/bash

docker run \
  --detach \
  --cap-add     SYS_ADMIN \
  --cap-add     DAC_READ_SEARCH \
  --env         "GANESHA_BOOTSTRAP_CONFIG=no" \
  --hostname    "nfs-ganesha" \
  --memory      512m \
  --memory-swap 512m \
  --name        "nfs-ganesha" \
  --publish     662:662/tcp \
  --publish     2049:2049/tcp \
  --publish     38465:38465/tcp \
  --publish     38466:38466/tcp \
  --publish     38467:38467/tcp \
  --restart     unless-stopped \
  --tmpfs       /tmp \
  --tmpfs       /run/dbus \
  --stop-signal SIGRTMIN+3 \
  --volume      /mysharefolder:/data \
    registry:5000/nfs-ganesha:3.5-u20-1.0
```

Example of the nfs-ganesha configuration file
(note the kerberos setting - i.e. it is disabled! super simple):

Example config files now in ganesha.conf and vfs.conf. (Now in the images in /etc/ganesha)

Testing your nfs-ganesha server:
```
mount -t nfs host6:/data /mnt
cd /mnt
ls
```

Gottchas:

* Note the use of --tmpfs. This puts the named directories into the hosts RAM. It can run out and kill your server dead. It you expect super high usage don't use this option.
* As noted there is no Kerberos running. All server must use the same userid:groupid numbers. This is done here with the aid of an LDAP server (recommended).
```


