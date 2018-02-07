FROM resin/raspberry-pi-alpine
LABEL maintainer "Gerard Hollemans"
LABEL source "https://github.com/gerardhollemans/nfs-server-alpine"
LABEL branch "master"
COPY Dockerfile /Dockerfile

RUN apk add --update --verbose nfs-utils bash iproute2 && \
    rm -rf /var/cache/apk/* /tmp/* && \
    rm -f /sbin/halt /sbin/poweroff /sbin/reboot && \
    mkdir -p /var/lib/nfs/rpc_pipefs && \
    mkdir -p /var/lib/nfs/v4recovery && \
    echo "rpc_pipefs    /var/lib/nfs/rpc_pipefs rpc_pipefs      defaults        0       0" >> /etc/fstab && \
    echo "nfsd  /proc/fs/nfsd   nfsd    defaults        0       0" >> /etc/fstab

COPY exports /etc/exports

COPY nfsd.sh /usr/bin/nfsd.sh
COPY .bashrc /root/.bashrc

RUN chmod +x /usr/bin/nfsd.sh

ENTRYPOINT ["/usr/bin/nfsd.sh"]
