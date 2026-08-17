# Contributing to the project

This document provides guidelines for contributing, with a focus on the process of managing built images.

## Adding a new image

The Containerfiles and GitHub Actions workflow shims in this repository are generated from templates using Python, Jinja, and uv. This makes it easier to manage multiple distributions and versions. To add a new OS image, follow these steps.

### 1. Modify `src/systemd/matrix.yml`

The [`src/systemd/matrix.yml`](../../src/systemd/matrix.yml) file is the heart of the generation process. It defines all the distributions, versions, and variables used to create the `Containerfile`s and CI configuration files.

#### Adding a new version to an existing distribution

To add a new version (e.g., a new release) to a distribution that is already in the `matrix.yml` file, find the distribution under the `distros` list and add a new item to its `outputs` list.

For example, to add Debian "sid", you would add the following to the `outputs` under `Debian`:

```yaml
      - baseimage_version: sid
        vars:
          extra_ci_image_tags:
            - "unstable"
```

#### Adding a new distribution

To add a completely new distribution, you'll need to add a new entry to the `distros` list. You will need to define its `name`, `distro_family`, and at least one version under `outputs`.

You may also need to add a new `distro_family` if it doesn't exist (e.g., for a Gentoo-based distro).

Here is an example of adding a new distribution `MyOS`:

```yaml
distros:
  # ... other distros
  - name: MyOS
    distro_family: RedHat # Or Debian, Suse, Archlinux, or a new one
    vars:
      baseimage_repo: docker.io/library/myos
    outputs:
      - baseimage_version: 1.0
        vars:
          extra_ci_image_tags:
            - "latest"
```

Make sure to check the variables under `distro_families` and `defaults.vars` to see if you need to override any for your new OS.

### 2. Generate the Files

After modifying [`src/systemd/matrix.yml`](../../src/systemd/matrix.yml), run the Python generator to generate the `Containerfile`s and associated CI workflow shims.

From the root of the repository, execute the following command:

```bash
cd src/systemd
uv run generate.py
```

This creates or updates files in two locations:
*   `Containerfiles/systemd/<DistroName>/`
*   `.github/workflows/`

Run the Ruff, mypy, generated-file, and workflow checks with:

```bash
cd src/systemd
uv run --group nox nox
```

To check whether generated files are current without modifying them, run:

```bash
cd src/systemd
uv run generate.py --check
```

### 3. Update `Containerfiles/systemd/README.md`

The final step is to manually update the documentation to reflect the changes you've made. Please edit [`Containerfiles/systemd/README.md`](README.md) to include information about the new image.

Add a new section for the distribution if it's new, or add a new row to the table for an existing distribution. Make sure to include the available tags and any other relevant information.

### Submitting your contribution

Once you have completed these steps, commit your changes and open a pull request. Please include:

1.  Changes to `src/systemd/matrix.yml`.
2.  The newly generated/updated `Containerfile`s and CI files.
3.  The updated `Containerfiles/systemd/README.md`.


## Removing an image

Once image reaches its EOL, we remove such image from regular build to save CI cycles and avoid potential CI failures once image mirrors become unavailable.

The process is almost a reverse to adding a new image, except we leave previously buiilt Containerfiles in the repository.

### 1. Modify `src/systemd/matrix.yml`

In the [`src/systemd/matrix.yml`](../../src/systemd/matrix.yml) file we need to remove EOLed version of distribution. For example, to remove Debian "buster", you would remove the following from the `outputs` under `Debian`:

```yaml
      - baseimage_version: buster
        vars:
          extra_ci_image_tags:
            - "10"
```

### 2. Generate the Files

Run `cd src/systemd && uv run generate.py`. The generator removes the obsolete workflow shim while retaining the historical Containerfile.

### 3. Update `Containerfiles/systemd/README.md`

You need to manually update the documentation to reflect the changes you've made. Please edit [`Containerfiles/systemd/README.md`](README.md) to remove information about the EOLed distribution version.

### Submitting your contribution

Once you have completed these steps, commit your changes and open a pull request. Please include:

1.  Changes to `src/systemd/matrix.yml`.
2.  Regenerated `.github/workflows/` files.
3.  The updated `Containerfiles/systemd/README.md`.
