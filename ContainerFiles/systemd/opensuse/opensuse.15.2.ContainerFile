#
# Ansible managed
#

# vim: set filetype=jinja.dockerfile:

FROM registry.opensuse.org/opensuse/leap:15.2

LABEL maintainer="Maxwell G <gotmax23@github>"


# Install systemd and python requirements and clean up
RUN zypper install -y \
    systemd python3 sudo systemd-sysvinit \
&& zypper clean \
&& rm -rf /usr/share/doc /usr/share/man

CMD [/sbin/init]
STOPSIGNAL SIGRTMIN+3
