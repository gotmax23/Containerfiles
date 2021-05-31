# vim: set filetype=jinja.dockerfile:

FROM docker.io/library/ubuntu:focal

LABEL maintainer="Maxwell G <gotmax23@github>"

ENV DEBIAN_FRONTEND=noninteractive

# Install systemd and python requirements and clean up
RUN apt-get update && apt-get install -y --no-install-recommends \
    systemd-sysv \
    systemd python3 sudo \
&& apt-get clean \
&& rm -rf /usr/share/doc /usr/share/man /var/lib/apt/lists/*
CMD [/sbin/init]
STOPSIGNAL SIGRTMIN+3
