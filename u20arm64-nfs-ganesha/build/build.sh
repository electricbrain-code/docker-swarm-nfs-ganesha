#!/bin/bash
#
# Build the NFS Ganesha server.
# https://github.com/apnar/docker-image-nfs-ganesha
#
# Settings
#
pwd

set -x
set -e
. settings-global.inc.sh
. settings.inc.sh

lcFromImage="docker.io/arm64v8/ubuntu:20.04"

# Cleanup
#
set +e
docker rmi "$gcRegistry/$gcImageName:latest"     2>/dev/null
docker rmi "$gcRegistry/$gcImageName:base"       2>/dev/null
docker rmi "$gcRegistry/$gcImageName:$gcVersion" 2>/dev/null
set -e

# Create the Dockerfile
#
cat << EOFZZZ > context/Dockerfile
FROM $lcFromImage

# Add startup script
COPY nfs-ganesha_3.5-ubuntu1~focal3_arm64.deb     /
COPY nfs-ganesha-vfs_3.5-ubuntu1~focal3_arm64.deb /
COPY libntirpc3_3.5-ubuntu1~focal1_arm64.deb      /

run DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get --no-install-recommends -y upgrade \
  && apt-get install --no-install-recommends -y netbase nfs-common dbus /libntirpc3_3.5-ubuntu1~focal1_arm64.deb /nfs-ganesha_3.5-ubuntu1~focal3_arm64.deb /nfs-ganesha-vfs_3.5-ubuntu1~focal3_arm64.deb \
  && apt-get clean \
  && rm -f /libntirpc3_3.5-ubuntu1~focal1_arm64.deb /nfs-ganesha_3.5-ubuntu1~focal3_arm64.deb /nfs-ganesha-vfs_3.5-ubuntu1~focal3_arm64.deb \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && mkdir -p /run/rpcbind /export /var/run/dbus \
  && touch /run/rpcbind/rpcbind.xdr /run/rpcbind/portmap.xdr \
  && chmod 755 /run/rpcbind/* \
  && chown messagebus:messagebus /var/run/dbus

# Add startup script
COPY start.sh     /
COPY ganesha.conf /etc/ganesha
COPY vfs.conf     /etc/ganesha

# NFS ports and portmapper
EXPOSE 2049 38465-38467 662 111/udp 111

# Start Ganesha NFS daemon by default
CMD ["/start.sh"]

EOFZZZ

# Build the image
#
docker build --no-cache -t "$gcRegistry/$gcImageName:$gcVersion" context

docker images

