#
# Ansible managed
#

FROM quay.io/centos/centos:7 as update
LABEL maintainer="Maxwell G <gotmax23@github>"


RUN echo "**** Installing packages and updating if necessary ****" \
    && yum update -y && yum -y --setopt=tsflags=nodoc install \
        systemd python2 sudo ca-certificates \
    && echo "**** Cleaning package cache ****" \
    && yum clean all \
    && echo "**** Masking systemd services ****" \
    && systemctl mask \
        systemd-remount-fs.service dev-hugepages.mount sys-fs-fuse-connections.mount getty.target console-getty.service systemd-udev-trigger.service systemd-udevd.service systemd-random-seed.service systemd-machine-id-commit.service

FROM scratch
COPY --from=update / /
CMD ["/sbin/init"]
STOPSIGNAL SIGRTMIN+3

# vim: set filetype=dockerfile:
