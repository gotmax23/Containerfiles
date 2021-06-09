# Systemd Containers for Ansible Testing

I built these containers for use with Molecule and Podman to test Ansible roles and playbooks. They are also compatible with Docker. However, I recommend using Podman because it has better support for running systemd inside containers, requiring no special configuration. Naturally, it is more secure, as it doesn't require a daemon. However, as long as your distro does not use Cgroups V2/Unified Hierarchy, you can run these images with Docker, as well.

In order to ease maintenance, these Containerfiles are templated by an Ansible playbook located in [`src/systemd`](https://github.com/gotmax23/Containerfiles/tree/main/src/systemd). I am still working on finalizing the code and writing documentation for possible contributors.

## Repos and Tags

As you will see below, I have listed the values for a couple major Ansible variables for each image, as well as [the platforms and versions that Ansible Galaxy uses](https://galaxy.ansible.com/api/v1/platforms/). I tried to name the Containers like this: `"quay.io/gotmax23{{ galaxy_platform | lower }}/{{ galaxy_version | lower }}-systemd"`.

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
| latest         | any              | NA                                   |

### [Debian](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/Debian)

```yaml
ansible_os_family: Debian
ansible_distribution: Debian

# These aren't actually Ansible variables
galaxy_platform: Debian
container_repo: quay.io/gotmax23/debian-systemd
```

| Available Tags          | `galaxy_version` | `ansible_distribution_major_verison` |
| ----------------------- | ---------------- | ------------------------------------ |
| latest,buster,10,stable | buster           | buster                               |
| bullseye,testing        | bullseye         | testing                              |

### [RedHat](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/RedHat)

```yaml
ansible_os_family: RedHat
ansible_distribution: RedHat

# These aren't actually Ansible variables
galaxy_platform: RedHat
container_repo: quay.io/gotmax23/redhat-systemd
```

| Available Tags | `galaxy_version` | `ansible_distribution_major_verison` |
| -------------- | ---------------- | ------------------------------------ |
| 7              | 7                | 7                                    |
| 8,latest       | 8                | 8                                    |

### [Fedora](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/Fedora)

```yaml
ansible_os_family: RedHat
ansible_distribution: Fedora

# These aren't actually Ansible variables
galaxy_platform: Fedora
container_repo: quay.io/gotmax23/fedora-systemd
```

| Available Tags | `galaxy_version` | `ansible_distribution_major_verison` |
| -------------- | ---------------- | ------------------------------------ |
| 33             | 33[^1]           | 33                                   |
| 34,latest      | 34[^1]           | 34                                   |
| 35,rawhide     | 35[^1]           | 35                                   |

### [opensuse](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/opensuse)

```yaml
ansible_os_family: Suse
ansible_distribution: "openSUSE Leap"

# These aren't actually Ansible variables
galaxy_platform: opensuse
container_repo: quay.io/gotmax23/opensuse-systemd
```

Due to a discrepancy between `galaxy_platform` and `ansible_os_family`, these images (with the same tags) are also available at `quay.io/gotmax23/opensuse-leap-systemd`.

| Available Tags | `galaxy_version` | `ansible_distribution_major_verison` |
| -------------- | ---------------- | ------------------------------------ |
| 15.2           | 15.2             | 15                                   |
| 15.3,latest    | 15.3[^1]         | 15                                   |

### [Ubuntu](https://github.com/gotmax23/Containerfiles/tree/main/Containerfiles/systemd/Debian)

```yaml
ansible_os_family: Debian
ansible_distribution: Debian

# These aren't actually Ansible variables
galaxy_platform: Debian
container_repo: quay.io/gotmax23/debian-systemd
```

| Available Tags   | `galaxy_version` | `ansible_distribution_major_verison` |
| ---------------- | ---------------- | ------------------------------------ |
| bionic,18,18.04  | bionic           | 18                                   |
| focal,20,20.04   | focal            | 20                                   |
| hirsute,21,21.04 | hirsute[^1]      | 21                                   |


