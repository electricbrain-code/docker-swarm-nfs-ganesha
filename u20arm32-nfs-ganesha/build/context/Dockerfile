FROM registry:5000/ubuntu:20.04
maintainer phillb <phillb@electricbrain.com.au>

# Add startup script
COPY nfs-ganesha_3.5-ubuntu1~focal3_armhf.deb     /
COPY nfs-ganesha-vfs_3.5-ubuntu1~focal3_armhf.deb /
COPY libntirpc3_3.5-ubuntu1~focal1_armhf.deb      /

run DEBIAN_FRONTEND=noninteractive   && apt-get update   && apt-get --no-install-recommends -y upgrade   && apt-get install --no-install-recommends -y netbase nfs-common dbus /libntirpc3_3.5-ubuntu1~focal1_armhf.deb /nfs-ganesha_3.5-ubuntu1~focal3_armhf.deb /nfs-ganesha-vfs_3.5-ubuntu1~focal3_armhf.deb   && apt-get clean   && rm -f /libntirpc3_3.5-ubuntu1~focal1_armhf.deb /nfs-ganesha_3.5-ubuntu1~focal3_armhf.deb /nfs-ganesha-vfs_3.5-ubuntu1~focal3_armhf.deb   && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*   && mkdir -p /run/rpcbind /export /var/run/dbus   && touch /run/rpcbind/rpcbind.xdr /run/rpcbind/portmap.xdr   && chmod 755 /run/rpcbind/*   && chown messagebus:messagebus /var/run/dbus

# Add startup script
COPY start.sh /

# NFS ports and portmapper
EXPOSE 2049 38465-38467 662 111/udp 111

# Start Ganesha NFS daemon by default
CMD ["/start.sh"]

