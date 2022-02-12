# Systemd Containers for Ansible Testing

## Description

I built these containers for use with Molecule and Podman to test Ansible roles and playbooks. I recommend using Podman over Docker because it has better support for running systemd inside containers, requiring no special configuration. Naturally, it is more secure, as it doesn't require a daemon. However, as long as your distro does not use Cgroups V2/Unified Hierarchy[^3] (or you manually disable it), you can run these images with Docker, as well.

In order to ease maintenance, these Containerfiles are templated by an Ansible playbook located in [`src/systemd`](https://github.com/gotmax23/Containerfiles/tree/main/src/systemd). I am still working on finalizing the code and writing documentation for possible contributors.

## Repos and Tags

As you will see below, I have listed the values for a couple major Ansible variables for each image, as well as [the platforms and versions that Ansible Galaxy uses](https://galaxy.ansible.com/api/v1/platforms/). I tried to name the Containers like this: `"quay.io/gotmax23{{ galaxy_platform | lower }}/{{ galaxy_version | lower }}-systemd"`.

Github does not properly display markdown footnotes. `[^1]` is an example. Please manually scroll to the [`## Footnotes`](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/#Footnotes) section.

### [Archlinux](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/Archlinux)

```yaml
ansible_os_family: Archlinux
ansible_distribution: Archlinux

# These aren't actually Ansible variables
galaxy_platform: Archlinux
container_repo: quay.io/gotmax23/archlinux-systemd
```

| Available Tags | `galaxy_version` | `ansible_distribution_major_verison` |
| -------------- | ---------------- | ------------------------------------ |
| latest         | any              | "NA"                                 |

### [Debian](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/Debian)

```yaml
ansible_os_family: Debian
ansible_distribution: Debian

# These aren't actually Ansible variables
galaxy_platform: Debian
container_repo: quay.io/gotmax23/debian-systemd
```

| Available Tags            | `galaxy_version` | `ansible_distribution_major_verison` | `ansible_distribution_release` |
| ------------------------- | ---------------- | ------------------------------------ | ------------------------------ |
| buster,10,oldstable       | buster           | "10"                                 | "buster"                       |
| latest,bullseye,11,stable | bullseye         | "11"                                 | "bullseye"                     |
| bookworm,12,testing       | bookworm         | "NA"                                 | "NA"                           |

For Debian, `ansible_distribution_major_version` and `ansible_distribution_version` are the same.

### [RedHat](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/RedHat)

These images are based on RedHat's UBI (Universal Base Image). UBI and images based on it are free to use without a RedHat subscription. However, if they are not used on a registered RedHat system, the package selection is limited. For example, it is not possible to install the dependencies needed for many EPEL packages without a RedHat subscription[^2]. Therefore, I recommend using the CentOS and AlmaLinux based images, instead.

```yaml
ansible_os_family: RedHat
ansible_distribution: RedHat

# These aren't actually Ansible variables
galaxy_platform: EL
container_repo: quay.io/gotmax23/redhat-systemd
```

| Available Tags | `galaxy_version` | `ansible_distribution_major_verison` |
| -------------- | ---------------- | ------------------------------------ |
| 7              | 7                | "7"[^3]                              |
| 8,latest       | 8                | "8"                                  |

### [AlmaLinux](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/AlmaLinux)

```yaml
ansible_os_family: RedHat
ansible_distribution: AlmaLinux

# These aren't actually Ansible variables
galaxy_platform: EL
container_repo: quay.io/gotmax23/almalinux-systemd
```

| Available Tags | `galaxy_version` | `ansible_distribution_major_verison` |
| -------------- | ---------------- | ------------------------------------ |
| 8,latest       | 8                | "8"                                  |

### [CentOS](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/CentOS)

```yaml
ansible_os_family: RedHat
ansible_distribution: CentOS

# These aren't actually Ansible variables
galaxy_platform: EL
container_repo: quay.io/gotmax23/centos-systemd
```

| Available Tags | `galaxy_version` | `ansible_distribution_major_verison` |
| -------------- | ---------------- | ------------------------------------ |
| 7              | 7                | "7"[^3]                              |
| 8,latest       | 8                | "8"                                  |

### quay.io/gotmax23/el-systemd repo

The quay.io/gotmax23/el-systemd:latest and quay.io/gotmax23/el-systemd:8 tags use the [AlmaLinux 8 Containerfile](https://github.com/gotmax23/Containerfiles/blob/main/Containerfiles/systemd/AlmaLinux/AlmaLinux.8.Containerfile).

The quay.io/gotmax23/el-systemd:7 tag uses the [CentOS 7 Containerile](https://github.com/gotmax23/Containerfiles/blob/main/Containerfiles/systemd/CentOS/CentOS.7.Containerfile).

This solves two problems:

1. EL containers follow the `"quay.io/gotmax23{{ galaxy_platform | lower }}/{{ galaxy_version | lower }}-systemd"` rule I set earlier.
2. It will still be possible to test on both EL 7 and EL 8 after [CentOS 8's early EOL](https://blog.centos.org/2020/12/future-is-centos-stream/).

### [Fedora](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/Fedora)

```yaml
ansible_os_family: RedHat
ansible_distribution: Fedora

# These aren't actually Ansible variables
galaxy_platform: Fedora
container_repo: quay.io/gotmax23/fedora-systemd
```

| Available Tags | `galaxy_version` | `ansible_distribution_major_verison` | State[^4] |
| -------------- | ---------------- | ------------------------------------ | --------- |
| ~~33~~         | 33               | "33"                                 | EOL       |
| 34             | 34               | "34"                                 | Stable    |
| 35,latest      | 35               | "35"                                 | Stable    |
| 36             | 36               | "36"                                 | Beta      |
| 37,rawhide     | 37               | "37"                                 | Rawhide   |

### [opensuse](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/opensuse)

```yaml
ansible_os_family: Suse
ansible_distribution: "openSUSE Leap"

# These aren't actually Ansible variables
galaxy_platform: opensuse
container_repo: quay.io/gotmax23/opensuse-systemd
```

Due to a discrepancy between `galaxy_platform` and `ansible_os_family`, these images (with the same tags) are also available at `quay.io/gotmax23/opensuse-leap-systemd`.

| Available Tags | `galaxy_version` | `ansible_distribution_major_verison` | `ansible_distribution_version` |
| -------------- | ---------------- | ------------------------------------ | ------------------------------ |
| 15.2           | 15.2             | "15"                                 | "15.2"                         |
| 15.3,latest    | 15.3             | "15"                                 | "15.3"                         |

There is also an image for Tumbleweed.

```yaml
ansible_os_family: Suse
ansible_distribution: "openSUSE Tumbleweed"
ansible_distribution_major_version: "20210710"  # Changes Daily, it seems
ansible_distribution_version: "20210710"  # Changes Daily, it seems

# There is no `galaxy_platform` for Tumbleweed
tags:
  - quay.io/gotmax23/opensuse-systemd:tumbleweed
  - quay.io/gotmax23/opensuse-tumbleweed-systemd:latest
```

### [SLES](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/SLES) (SUSE Linux Enterprise Server)

```yaml
ansible_os_family: Suse
ansible_distribution: "SLES"

# These aren't actually Ansible variables
galaxy_platform: SLES
container_repo: quay.io/gotmax23/sles-systemd
```

| Available Tags | `galaxy_version` | `ansible_distribution_major_verison` | `ansible_distribution_version` | `ansible_distribution_release` |
| -------------- | ---------------- | ------------------------------------ | ------------------------------ | ------------------------------ |
| 15.3,latest    | 15.3             | "15"                                 | "15.3"                         | 3                              |

### [Ubuntu](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/Ubuntu)

```yaml
ansible_os_family: Debian
ansible_distribution: Ubuntu

# These aren't actually Ansible variables
galaxy_platform: Ubuntu
container_repo: quay.io/gotmax23/debian-systemd
```

| Available Tags        | `galaxy_version` | `ansible_distribution_major_verison` | `ansible_distribution_version` | `ansible_distribution_release` | EOL[^4] |
| --------------------- | ---------------- | ------------------------------------ | ------------------------------ | ------------------------------ | ------- |
| bionic,18,18.04       | bionic           | "18"                                 | "18.04"                        | "bionic"                       |         |
| focal,20,20.04,latest | focal            | "20"                                 | "20.04"                        | "focal"                        |         |
| hirsute,21,21.04      | hirsute          | "21"                                 | "21.04"                        | "hirsute"                      | Yes     |
| impish,21.10,rolling  | impish           | "21"                                 | "21.10"                        | "impish"                       |         |
| jammy,22.04,devel     | jammy[^1]        | "22"                                 | "22.04"                        | "jammy"                        |         |

## Credits

These images are inspired by `geerlingguy` and `robertdebock`'s Ansible images

## Footnotes

[^1]: This distro version is not listed at [https://galaxy.ansible.com/api/v1/platforms/](https://galaxy.ansible.com/api/v1/platforms/). Unfortunately, Ansible Galaxy has not updated its platform list in a while, and certain newer distros versions are missing. The `galaxy_version`s that link to this footnote are simply a reflection of what the platform version *should* be based on the existing pattern. Please see [ansible/galaxy#2533](https://github.com/ansible/galaxy/issues/2533) for more information.

[^2]: See [https://developers.redhat.com/articles/ubi-faq#community](https://developers.redhat.com/articles/ubi-faq#community).

[^3]: EL 7 comes with a very old version of Systemd that is not compatible with Cgroups V2 at all (even with Podman).

[^4]: EOL Containerfiles are kept in the repository but don't receive image updates.
