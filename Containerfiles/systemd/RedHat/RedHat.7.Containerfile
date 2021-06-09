#
# Ansible managed
#

# vim: set filetype=jinja.dockerfile:

FROM registry.access.redhat.com/ubi7:latest

LABEL maintainer="Maxwell G <gotmax23@github>"


# Install systemd and python requirements and clean up
RUN yum -y install \
    systemd python2 sudo \
&& yum clean all \
&& rm -rf /usr/share/doc /usr/share/man
RUN systemctl mask systemd-remount-fs.service dev-hugepages.mount sys-fs-fuse-connections.mount systemd-logind.service getty.target console-getty.service systemd-udev-trigger.service systemd-udevd.service systemd-random-seed.service systemd-machine-id-commit.service

CMD ["/sbin/init"]
STOPSIGNAL SIGRTMIN+3
