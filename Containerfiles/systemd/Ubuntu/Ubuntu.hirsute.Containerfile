#
# Ansible managed
#

FROM docker.io/library/ubuntu:hirsute
LABEL maintainer="Maxwell G <gotmax23@github>"

ENV DEBIAN_FRONTEND=noninteractive

RUN echo "**** Installing packages and updating if necessary ****" \
    && apt-get update && apt-get install -y --no-install-recommends \
        systemd python3 sudo systemd-sysv python3-apt \
    && echo "**** Cleaning package cache ****" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo "**** Masking systemd services ****" \
    && systemctl mask \
        systemd-remount-fs.service dev-hugepages.mount sys-fs-fuse-connections.mount getty.target console-getty.service systemd-udev-trigger.service systemd-udevd.service systemd-random-seed.service systemd-machine-id-commit.service

CMD ["/sbin/init"]
STOPSIGNAL SIGRTMIN+3

# vim: set filetype=dockerfile:
