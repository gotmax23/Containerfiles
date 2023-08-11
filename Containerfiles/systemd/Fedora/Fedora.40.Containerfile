#
# Ansible managed
#

FROM registry.fedoraproject.org/fedora:40
LABEL maintainer="Maxwell G <gotmax23@github>"


RUN echo "**** Installing packages and updating if necessary ****" \
    && dnf upgrade -y --nodoc && dnf install -y --nodoc \
        systemd python3 sudo ca-certificates \
    && echo "**** Cleaning package cache ****" \
    && dnf clean all \
    && echo "**** Masking systemd services ****" \
    && systemctl mask \
        systemd-remount-fs.service dev-hugepages.mount sys-fs-fuse-connections.mount getty.target console-getty.service systemd-udev-trigger.service systemd-udevd.service systemd-random-seed.service systemd-machine-id-commit.service

CMD ["/sbin/init"]
STOPSIGNAL SIGRTMIN+3

# vim: set filetype=dockerfile:
