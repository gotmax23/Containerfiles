# vim: set filetype=dockerfile:
FROM registry.opensuse.org/opensuse/tumbleweed:15.3

LABEL maintainer="Maxwell G <gotmax23@github>"

# Install systemd and python requirements and clean up
RUN zypper install -y \
    systemd-sysvinit \
    python3 python3-pip python3-setuptools python3-wheel python3-dev sudo \
&& zypper clean \
&& rm -rf /usr/share/doc /usr/share/man

# Update pip and install ansible and related
RUN python3 -m pip install -U --no-cache-dir pip && \
python3 -m pip install --no-cache-dir ansible

CMD ["/sbin/init"]
STOPSIGNAL SIGRTMIN+3
