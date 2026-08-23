# Systemd Containers for Ansible Testing

## Description

I built these containers for use with Molecule and Podman to test Ansible roles and playbooks. I recommend using Podman over Docker because it has better support for running systemd inside containers, requiring no special configuration. Naturally, it is more secure, as it doesn't require a daemon. However, as long as your distro does not use Cgroups V2/Unified Hierarchy[^3] (or you manually disable it), you can run these images with Docker, as well.

To ease maintenance, the Containerfiles and GitHub Actions workflow shims are generated from Jinja templates by the Python generator in [`src/systemd`](https://github.com/gotmax23/Containerfiles/tree/main/src/systemd).

## Repos and Tags

The tables below list the available image tags and corresponding Ansible facts. Primary images use names in the form `quay.io/gotmax23/<distribution>-systemd:<version>`. Some images also publish compatibility aliases described below.

### [Archlinux](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/Archlinux)

```yaml
ansible_os_family: Archlinux
ansible_distribution: Archlinux

container_repo: quay.io/gotmax23/archlinux-systemd
```

| Available Tags | `ansible_distribution_major_version` |
| -------------- | ------------------------------------ |
| any,latest     | "NA"                                 |

### [Debian](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/Debian)

```yaml
ansible_os_family: Debian
ansible_distribution: Debian

container_repo: quay.io/gotmax23/debian-systemd
```

| Available Tags            | `ansible_distribution_major_version` | `ansible_distribution_release` |
| ------------------------- | ------------------------------------ | ------------------------------ |
| bullseye,11               | "11"                                 | "bullseye"                     |
| bookworm,12,oldstable     | "12"                                 | "bookworm"                     |
| trixie,13,stable,latest   | "13"                                 | "trixie"                       |
| forky,14,testing          | "14"                                 | "forky"                        |

For Debian, `ansible_distribution_major_version` and `ansible_distribution_version` are the same.

### [RedHat](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/RedHat)

These images are based on RedHat's UBI (Universal Base Image). UBI and images based on it are free to use without a RedHat subscription. However, if they are not used on a registered RedHat system, the package selection is limited. For example, it is not possible to install the dependencies needed for many EPEL packages without a RedHat subscription[^2]. Therefore, I recommend using the CentOS and AlmaLinux based images, instead.

```yaml
ansible_os_family: RedHat
ansible_distribution: RedHat

container_repo: quay.io/gotmax23/redhat-systemd
```

| Available Tags | `ansible_distribution_major_version` |
| -------------- | ------------------------------------ |
| 8,latest       | "8"                                  |

### [AlmaLinux](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/AlmaLinux)

```yaml
ansible_os_family: RedHat
ansible_distribution: AlmaLinux

container_repo: quay.io/gotmax23/almalinux-systemd
```

| Available Tags | `ansible_distribution_major_version` |
| -------------- | ------------------------------------ |
| 8              | "8"                                  |
| 9              | "9"                                  |
| 10, latest     | "10"                                 |

### [CentOS](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/CentOS)

```yaml
ansible_os_family: RedHat
ansible_distribution: CentOS

container_repo: quay.io/gotmax23/centos-systemd
```

| Available Tags   | `ansible_distribution_major_version` | `ansible_distribution_version` | `ansible_distribution_release` | EOL[^4] |
| ---------------- | ------------------------------------ | ------------------------------ | ------------------------------ | ------- |
| stream9          | "9"                                  | "9"                            | "Stream"                       |         |
| stream10, latest | "10"                                 | "10"                           | "Stream"                       |         |

### quay.io/gotmax23/el-systemd repo

The `quay.io/gotmax23/el-systemd` tags use the corresponding AlmaLinux images.

### [Fedora](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/Fedora)

```yaml
ansible_os_family: RedHat
ansible_distribution: Fedora

container_repo: quay.io/gotmax23/fedora-systemd
```

| Available Tags | `ansible_distribution_major_version` | State[^4] |
| -------------- | ------------------------------------ | --------- |
| 44, latest     | "44"                                 | Stable    |
| 45             | "45"                                 | Stable    |
| 46, rawhide    | "46"                                 | Rawhide   |

### [opensuse](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/opensuse)

```yaml
ansible_os_family: Suse
ansible_distribution: "openSUSE Leap"

container_repo: quay.io/gotmax23/opensuse-systemd
```

For compatibility with existing consumers, these images are also available with the same tags at `quay.io/gotmax23/opensuse-leap-systemd`.

| Available Tags | `ansible_distribution_major_version` | `ansible_distribution_version` |
| -------------- | ------------------------------------ | ------------------------------ |
| 16,latest      | "16"                                 | "16.0"                         |

There is also an image for Tumbleweed.

```yaml
ansible_os_family: Suse
ansible_distribution: "openSUSE Tumbleweed"
ansible_distribution_major_version: "20210710"  # Changes Daily, it seems
ansible_distribution_version: "20210710"  # Changes Daily, it seems

tags:
  - quay.io/gotmax23/opensuse-systemd:tumbleweed
  - quay.io/gotmax23/opensuse-tumbleweed-systemd:latest
```

### [SLES](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/SLES) (SUSE Linux Enterprise Server)

```yaml
ansible_os_family: Suse
ansible_distribution: "SLES"

container_repo: quay.io/gotmax23/sles-systemd
```

| Available Tags | `ansible_distribution_major_version` | `ansible_distribution_version` | `ansible_distribution_release` |
| -------------- | ------------------------------------ | ------------------------------ | ------------------------------ |
| 15.7,15        | "15"                                 | "15.7"                         | 7                              |
| 16.0,16,latest | "16"                                 | "16.0"                         | 0                              |

### [Ubuntu](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/Ubuntu)

```yaml
ansible_os_family: Debian
ansible_distribution: Ubuntu

container_repo: quay.io/gotmax23/ubuntu-systemd
```

| Available Tags        | `ansible_distribution_major_version` | `ansible_distribution_version` | `ansible_distribution_release` |
| --------------------- | ------------------------------------ | ------------------------------ | ------------------------------ |
| jammy,22.04           | "22"                                 | "22.04"                        | "jammy"                        |
| noble,24.04,latest    | "24"                                 | "24.04"                        | "noble"                        |
| resolute,26.04        | "26"                                 | "26.04"                        | "resolute"                     |

## Contributing

If you want to contribute to the project, please check [`CONTRIBUTING.md`](CONTRIBUTING.md) for more details.

## Credits

These images are inspired by `geerlingguy` and `robertdebock`'s Ansible images

## Footnotes

[^2]: See [https://developers.redhat.com/articles/ubi-faq#community](https://developers.redhat.com/articles/ubi-faq#community).

[^3]: EL 7 comes with a very old version of systemd that is not compatible with Cgroups V2 at all (even with Podman).

[^4]: EOL Containerfiles are kept in the repository but don't receive image updates.
