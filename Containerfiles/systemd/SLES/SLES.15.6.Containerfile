#
# Ansible managed
#

FROM registry.suse.com/suse/sle15:15.6
LABEL maintainer="Maxwell G <gotmax23@github>"


RUN echo "**** Installing packages and updating if necessary ****" \
    && zypper update -y && zypper install -y \
        systemd python3 sudo ca-certificates \
    && echo "**** Cleaning package cache ****" \
    && zypper clean \
    && echo "**** Masking systemd services ****" \
    && systemctl mask \
        systemd-remount-fs.service dev-hugepages.mount sys-fs-fuse-connections.mount getty.target console-getty.service systemd-udev-trigger.service systemd-udevd.service systemd-random-seed.service systemd-machine-id-commit.service

CMD ["/sbin/init"]
STOPSIGNAL SIGRTMIN+3

# vim: set filetype=dockerfile:
