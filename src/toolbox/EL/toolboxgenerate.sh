#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2022 Maxwell G (@gotmax23)
# SPDX-License-Identifier: MIT

set -euo pipefail

finalize() {
    buildah run "${newcontainer}" -- dnf clean all

    buildah config \
        --env NAME=toolbox-container \
        --env VERSION="${version}" \
        --label com.github.containers.toolbox="true" \
        --label com.github.debarshiray.toolbox="true" \
        --label com.redhat.component=toolbox-container \
        --label version="${version}" \
        --label usage="This image is meant to be used with the toolbox command" \
        --label summary="Base image for creating ${fname} toolbox containers" \
        --label maintainer="Maxwell G <gotmax23@fedoraproject.org" \
        "${newcontainer}"

    buildah commit --manifest "${reg_name}" "${newcontainer}" "${reg_name}-${arch}"
    buildah rm "${newcontainer}"
    if [ "${push:-}" = "true" ]; then
        buildah manifest push --all "${reg_name}" "docker://${fqcn}"
    fi

}

build_plain() {

    newcontainer="$(buildah from --arch ${arch} "${image}")"
    echo "newcontainer: ${newcontainer}"

    buildah copy "${newcontainer}" context/README.md /

    buildah run "${newcontainer}" -- sed -i '/tsflags=nodocs/d' /etc/dnf/dnf.conf
    buildah run "${newcontainer}" -- dnf -y swap coreutils-single coreutils-full

    buildah run "${newcontainer}" -- dnf -y reinstall $(<"context/${version}/missing-docs")
    buildah run "${newcontainer}" -- dnf -y install $(<"context/${version}/extra-packages")

    finalize
}

build_epel() {
    newcontainer=$(buildah from --arch "${arch}" --pull-never "localhost/${base_name}-plain")
    echo "newcontainer: ${newcontainer}"

    buildah run "${newcontainer}" -- rpm --import "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-${version}"
    buildah run "${newcontainer}" -- sh -c 'dnf install -y --repofrompath="epel,https://dl.fedoraproject.org/pub/epel/$(rpm -E %rhel)/Everything/"\$basearch --repo=epel --nogpgcheck epel-release'
    curl -sSL https://src.fedoraproject.org/fork/gotmax23/rpms/epel-release/raw/enable-crb-epel9/f/enable-crb | buildah run "${newcontainer}" -- bash -
    finalize
}

# build_gotmax23() {
#     true
# }

build() {
    base_name="${distro}-toolbox:${version}"
    reg_name="${base_name}-${variant}"
    fqcn="quay.io/gotmax23/${reg_name}"
    case "${distro}" in
        centos-stream)
            image="quay.io/centos/centos:stream${version}"
            fname="CentOS Stream"
            ;;
        almalinux)
            image="docker.io/almalinux/${version}-base:latest"
            fname="AlmaLinux"
    esac
    if ! podman inspect "localhost/${reg_name}-${arch}" &> /dev/null; then
        build_${variant}
    else
        echo "Skipping ${reg_name} ${arch} build"
    fi
}

for distro in centos-stream almalinux; do
    for version in 8 9; do
        # for variant in plain epel gotmax23; do
        for variant in plain epel; do
            echo "distro: ${distro}"
            echo "version: ${version}"
            echo "variant: ${variant}"
            for arch in {amd64,arm64}; do
                echo "arch: ${arch}"
                build
            done
        done
    done
    echo "**********"
done
