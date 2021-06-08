#
# Ansible managed
#

# vim: set filetype=jinja.dockerfile:

FROM registry.access.redhat.com/ubi7:latest

LABEL maintainer="Maxwell G <gotmax23@github>"


# Install systemd and python requirements and clean up
RUN yum -y --setopt=tsflags=nodoc install \
    systemd python2 sudo \
&& yum clean all \
&& rm -rf /usr/share/doc /usr/share/man

CMD ["/sbin/init"]
STOPSIGNAL SIGRTMIN+3
