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
  --volume      /docker.local/nfs-ganesha/data/etc/ganesha:/etc/ganesha \
  --volume      /docker.local/nfs-ganesha/data/mysharefolder:/data \
    registry:5000/nfs-ganesha:3.5-u20-1.0

Example of the nfs-ganesha configuration file i
(note the kerberos setting - i.e. it is disabled! super simple):

###################################################
#
# Ganesha Config
# https://www.mankier.com/8/ganesha-core-config
#
###################################################

## Configure settings for the object handle cache
#CACHEINODE {
        ## The point at which object cache entries will start being reused.
        #Entries_HWMark = 100000;
#}

# create new

## These are core parameters that affect Ganesha as a whole.
NFS_CORE_PARAM {
    # possible to mount with NFSv3 to NFSv4 Pseudo path
    mount_path_pseudo           = true;
    # NFS protocol
    Protocols                   = 3,4;
    # Disable IPv6 usage - not supported anymore
    #v6disable=true;
    # Whether tcp sockets should use SO_KEEPALIVE
    Enable_TCP_keepalive        = true;
    # Maximum number of TCP probes before dropping the connection
    TCP_KEEPCNT                 = 9;
    # Idle time before TCP starts to send keepalive probes
    TCP_KEEPIDLE                = 180;
    # Time between each keepalive probe
    TCP_KEEPINTVL               = 60;
}

## These parameters control Kerberos
NFS_KRB5 {
    # Whether to activate Kerberos 5. Defaults to true (if Kerberos support is compiled in)
    Active_krb5                 = false;
}

NFSv4 {
    # Whether to ONLY use bare numeric IDs in NFSv4 owner and group identifiers.
    Only_Numeric_Owners         = true;
}

## These are defaults for exports.  They can be overridden per-export.
EXPORT_DEFAULTS {
    # default access mode
    Access_Type                 = RW;
}

%include "vfs.conf"

=======================================================================
vfs.conf

###################################################
#
# EXPORT
#
# To function, all that is required is an EXPORT
#
# Define the absolute minimal export
#
###################################################

EXPORT
{
        # Export Id (mandatory, each EXPORT must have a unique Export_Id)
        Export_Id = 10;

        # Exported path (mandatory)
        Path = /data;

        # Pseudo Path (required for NFS v4)
        Pseudo = /data;

        # Exporting FSAL
        FSAL {
                Name = VFS;
        }

        CLIENT
        {
                Clients = myhost1,myhost2,myhost3,myhost4;
                Squash = None;
                Access_Type = RW;
        }
}


