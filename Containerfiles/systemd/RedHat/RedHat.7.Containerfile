#
# Ansible managed
#

FROM registry.access.redhat.com/ubi7:latest
LABEL maintainer="Maxwell G <gotmax23@github>"


RUN echo "**** Installing packages and updating if necessary ****" \
    && yum upgrade -y && yum install -y \
        systemd python2 sudo ca-certificates \
    && echo "**** Cleaning package cache ****" \
    && yum clean all \
    && echo "**** Masking systemd services ****" \
    && systemctl mask \
        systemd-remount-fs.service dev-hugepages.mount sys-fs-fuse-connections.mount getty.target console-getty.service systemd-udev-trigger.service systemd-udevd.service systemd-random-seed.service systemd-machine-id-commit.service

CMD ["/sbin/init"]
STOPSIGNAL SIGRTMIN+3

# vim: set filetype=dockerfile:
