# vim: set filetype=dockerfile:
FROM registry.access.redhat.com/ubi8/ubi-init

# Update packages and install python requirements
RUN dnf -y update && \
dnf -y install python3 python3-pip python3-setuptools python3-wheel python3-devel && \
dnf clean all

# Update pip and install ansible and related
RUN python3 -m pip install -U pip && \
python3 -m pip install ansible
