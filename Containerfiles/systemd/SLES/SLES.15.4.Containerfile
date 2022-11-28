#
# Ansible managed
#

FROM registry.suse.com/suse/sle15:15.4
LABEL maintainer="Maxwell G <gotmax23@github>"


RUN echo "**** Installing packages and updating if necessary ****" \
    && zypper install -y \
        systemd python3 sudo \
    && echo "**** Cleaning package cache ****" \
    && zypper clean \
    && echo "**** Masking systemd services ****" \
    && systemctl mask \
        systemd-remount-fs.service dev-hugepages.mount sys-fs-fuse-connections.mount getty.target console-getty.service systemd-udev-trigger.service systemd-udevd.service systemd-random-seed.service systemd-machine-id-commit.service \
    && echo "**** Symlinking /usr/lib/systemd/systemd to /sbin/init due to missing systemd-sysvinit package ****" \
    && ln -s /usr/lib/systemd/systemd /sbin/init

CMD ["/sbin/init"]
STOPSIGNAL SIGRTMIN+3

# vim: set filetype=dockerfile:
