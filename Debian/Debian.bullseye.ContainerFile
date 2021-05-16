# vim: set filetype=dockerfile:
FROM docker.io/library/debian:bullseye-slim

LABEL maintainer="Maxwell G <gotmax23@github>"

ENV DEBIAN_FRONTEND=noninteractive

# Install systemd and python requirements and clean up
RUN apt update \
&& apt install -y --no-install-recommends \
    systemd systemd-sysv \
    python3 python3-pip python3-setuptools python3-wheel python3-dev sudo \
&& apt clean \
&& rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man

# Update pip and install ansible and related
RUN python3 -m pip install -U --no-cache-dir pip && \
python3 -m pip --no-cache-dir install ansible

CMD ["/lib/systemd/systemd"]
STOPSIGNAL SIGRTMIN+3
