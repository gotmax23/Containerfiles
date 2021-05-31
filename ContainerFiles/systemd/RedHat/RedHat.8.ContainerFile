# vim: set filetype=jinja.dockerfile:

FROM registry.access.redhat.com/ubi8:latest

LABEL maintainer="Maxwell G <gotmax23@github>"


# Install systemd and python requirements and clean up
RUN dnf --setopt=tsflags=nodoc install \
     \
    systemd python3 sudo \
&& dnf clean all \
&& rm -rf /usr/share/doc /usr/share/man
CMD [/sbin/init]
STOPSIGNAL SIGRTMIN+3
