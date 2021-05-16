# vim: set filetype=dockerfile:
FROM registry.access.redhat.com/ubi8/ubi-init

LABEL maintainer="Maxwell G <gotmax23@github>"

# Install python requirements and clean up
RUN dnf -y --setopt=tsflags=nodoc install \
    python3 python3-pip python3-setuptools python3-wheel python3-devel sudo \
&& dnf clean all \
&& rm -rf /usr/share/doc /usr/share/man

# Update pip and install ansible and related
RUN python3 -m pip install -U --no-cache-dir pip && \
python3 -m pip install --no-cache-dir ansible
