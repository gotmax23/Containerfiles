#
# Ansible managed
#

FROM docker.io/library/archlinux:base
LABEL maintainer="Maxwell G <gotmax23@github>"


RUN echo "**** Installing packages and updating if necessary" \
    && pacman -Syu --noconfirm && pacman -S --needed --noconfirm \
        systemd python3 sudo systemd-sysvcompat \
    && echo "**** Cleaning package cache ****" \
    && pacman -Scc \
    && echo "**** Masking systemd services ****" \
    && systemctl mask \
        systemd-remount-fs.service dev-hugepages.mount sys-fs-fuse-connections.mount systemd-logind.service getty.target console-getty.service systemd-udev-trigger.service systemd-udevd.service systemd-random-seed.service systemd-machine-id-commit.service

CMD ["/sbin/init"]
STOPSIGNAL SIGRTMIN+3

# vim: set filetype=dockerfile:
