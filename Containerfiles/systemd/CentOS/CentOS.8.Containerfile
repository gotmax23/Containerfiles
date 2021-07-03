#
# Ansible managed
#

# vim: set filetype=jinja.dockerfile:

FROM docker.io/library/centos:8 as update
LABEL maintainer="Maxwell G <gotmax23@github>"


# Install systemd and python requirements and clean up
RUN dnf update -y && dnf -y --setopt=tsflags=nodoc install \
    systemd python3 sudo \
&& dnf clean all \
&& rm -rf /usr/share/doc /usr/share/man

FROM scratch
COPY --from=update / /
CMD ["/sbin/init"]
STOPSIGNAL SIGRTMIN+3
