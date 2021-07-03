#
# Ansible managed
#

# vim: set filetype=jinja.dockerfile:

FROM docker.io/library/archlinux:base
LABEL maintainer="Maxwell G <gotmax23@github>"


# Install systemd and python requirements and clean up
RUN pacman -Syu --noconfirm && pacman -S --noconfirm \
    systemd python3 sudo systemd-sysvcompat \
&& pacman -Scc \
&& rm -rf /usr/share/doc /usr/share/man

CMD ["/sbin/init"]
STOPSIGNAL SIGRTMIN+3
