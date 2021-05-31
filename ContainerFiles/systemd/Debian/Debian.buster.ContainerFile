#
# Ansible managed
#

# vim: set filetype=jinja.dockerfile:

FROM docker.io/library/debian:buster

LABEL maintainer="Maxwell G <gotmax23@github>"

ENV DEBIAN_FRONTEND=noninteractive

# Install systemd and python requirements and clean up
RUN apt-get update && apt-get install -y --no-install-recommends \
    systemd python3 sudo systemd-sysv python3-apt \
&& apt-get clean \
&& rm -rf /usr/share/doc /usr/share/man /var/lib/apt/lists/*

CMD [/sbin/init]
STOPSIGNAL SIGRTMIN+3
