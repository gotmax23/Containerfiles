---
title: Relations between containernames, setup and Galaxy
---
> This file is copied from https://robertdebock.nl/2019/11/07/relations-between-containernames-setup-and-galaxy.html with a couple modifications.

# Relations between containernames, setup and Galaxy

It's not easy to find the relation between container names, facts returned from setup (or `gather_facts`) and Ansible Galaxy platform names.

Here is an attempt to make life a little easier:

## Alpine

```yaml
containername: alpine
ansible_os_family: Alpine
ansible_distribution: Alpine
galaxy_platform: Alpine
```

| galaxy_version | docker_tag | ansible_distribution_major_version |
| -------------- | ---------- | ---------------------------------- |
| all            | latest     | 3                                  |
| all            | edge       | 3                                  |

## AmazonLinux

```yaml
containername: amazonlinux
ansible_os_family: RedHat
ansible_distribution: Amazon
galaxy_platform: Amazon
```

| galaxy_version | docker_tag | ansible_distribution_major_version |
| -------------- | ---------- | ---------------------------------- |
| Candidate      | latest     | 2                                  |
| 2018.03        | 1          | 2018                               |

## ArchLinux

```yaml
ansible_os_family: Archlinux
ansible_distribution: Archlinux
galaxy_platform: ArchLinux
```

| galaxy_version | docker_tag | ansible_distribution_major_version |
| -------------- | ---------- | ---------------------------------- |
| any            | latest      | NA                                 |

## CentOS

```yaml
containername: centos
ansible_os_family: RedHat
ansible_distribution: CentOS
galaxy_platform: EL
```

| galaxy_version | docker_tag | ansible_distribution_major_version |
| -------------- | ---------- | ---------------------------------- |
| 8              | latest     | 8                                  |
| 7              | 7          | 7                                  |

## Debian

```yaml
containername: debian
ansible_os_family: Debian
ansible_distribution: Debian
galaxy_platform: Debian
```

| galaxy_version | docker_tag | ansible_distribution_major_version |
| -------------- | ---------- | ---------------------------------- |
| buster         | latest     | 10                                 |
| bullseye       | bullseye   | testing                            |

## Fedora

```yaml
containername: fedora
ansible_os_family: RedHat
ansible_distribution: Fedora
galaxy_platform: Fedora
```

| galaxy_version | docker_tag | ansible_distribution_major_version |
| -------------- | ---------- | ---------------------------------- |
| 32             | 32         | 32                                 |
| 33             | latest     | 33                                 |
| 34             | rawhide    | 34                                 |

## OpenSUSE

```yaml
containername: opensuse
ansible_os_family: Suse
ansible_distribution: OpenSUSE
galaxy_platform: opensuse
```

| galaxy_version | docker_tag | ansible_distribution_major_version |
| -------------- | ---------- | ---------------------------------- |
| all            | latest     | 15                                 |

## Ubuntu

```yaml
containername: ubuntu
ansible_os_family: Debian
ansible_distribution: Ubuntu
galaxy_platform: Ubuntu
```

| galaxy_version | docker_tag | ansible_distribution_major_version |
| -------------- | ---------- | ---------------------------------- |
| focal          | latest     | 20                                 |
| bionic         | bionic     | 18                                 |
| xenial         | xenial     | 16                                 |
