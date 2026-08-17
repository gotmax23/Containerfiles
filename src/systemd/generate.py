#!/usr/bin/env python3
"""Generate systemd Containerfiles and GitHub Actions workflow shims."""

from __future__ import annotations

import argparse
import difflib
import sys
from collections.abc import Mapping, Sequence
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

import yaml
from jinja2 import Environment, FileSystemLoader, StrictUndefined


class ConfigError(ValueError):
    """Raised when the generator configuration is invalid."""


STRING_VARS = {
    "python_version",
    "docker_cmd",
    "docker_stopsignal",
    "baseimage_repo",
    "package_mgr_name",
    "package_mgr_install_cmd",
    "package_mgr_clean_cmd",
    "build_cron",
}
OPTIONAL_STRING_VARS = {"baseimage"}
STRING_LIST_VARS = {
    "docker_platforms",
    "default_packages",
    "packages",
    "extra_ci_image_tags",
    "extra_ci_image_repos",
    "masked_services",
    "extra_masked_services",
    "extra_commands",
}
BOOL_VARS = {"update_ms", "gha_workflow"}
KNOWN_VARS = STRING_VARS | OPTIONAL_STRING_VARS | STRING_LIST_VARS | BOOL_VARS


@dataclass(frozen=True)
class Output:
    """Configuration for one generated distro version."""

    baseimage_version: str
    vars: dict[str, Any]


@dataclass(frozen=True)
class Distro:
    """Configuration shared by all outputs for a distribution."""

    name: str
    distro_family: str
    vars: dict[str, Any]
    outputs: tuple[Output, ...]


@dataclass(frozen=True)
class Config:
    """Validated top-level generator configuration."""

    image_type: str
    defaults: dict[str, Any]
    distro_families: dict[str, dict[str, Any]]
    distros: tuple[Distro, ...]


@dataclass(frozen=True)
class ResolvedImage:
    """Fully resolved values used to render one image and workflow."""

    image_type: str
    distro_name: str
    distro_family: str
    baseimage_version: str
    python_version: str
    docker_cmd: str
    docker_stopsignal: str
    docker_platforms: tuple[str, ...]
    baseimage_repo: str
    baseimage: str
    package_mgr_name: str
    package_mgr_install_cmd: str
    package_mgr_clean_cmd: str
    all_packages: tuple[str, ...]
    build_cron: str
    update_ms: bool
    masked_services: tuple[str, ...]
    extra_commands: tuple[str, ...]
    gha_workflow: bool
    ci_image_repo: str
    all_ci_image_tags: tuple[str, ...]
    extra_ci_image_repos: tuple[str, ...]
    containerfile_dir: str
    containerfile_path: str
    workflow_path: str


def _mapping(value: Any, path: str) -> dict[str, Any]:
    """Return a mapping value or raise an error identifying its config path."""

    if not isinstance(value, Mapping):
        raise ConfigError(f"{path}: expected a mapping")
    return dict(value)


def _sequence(value: Any, path: str) -> list[Any]:
    """Return a non-string sequence or raise a path-aware config error."""

    if not isinstance(value, Sequence) or isinstance(value, (str, bytes)):
        raise ConfigError(f"{path}: expected a list")
    return list(value)


def _only_keys(value: Mapping[str, Any], allowed: set[str], path: str) -> None:
    """Reject keys outside the allowed set for a configuration block."""

    unknown = set(value) - allowed
    if unknown:
        key = min(unknown)
        hint = ""
        if key.lower() in KNOWN_VARS:
            hint = f"; did you mean vars.{key.lower()}?"
        raise ConfigError(f"{path}.{key}: unknown key{hint}")


def _string(value: Any, path: str, *, allow_empty: bool = False) -> str:
    """Validate and return a string configuration value."""

    if not isinstance(value, str) or (not allow_empty and not value):
        qualifier = "a string" if allow_empty else "a non-empty string"
        raise ConfigError(f"{path}: expected {qualifier}")
    return value


def _vars(value: Any, path: str) -> dict[str, Any]:
    """Validate a variables mapping and its value types."""

    result = _mapping(value, path)
    _only_keys(result, KNOWN_VARS, path)
    for key, item in result.items():
        item_path = f"{path}.{key}"
        if key in STRING_VARS:
            _string(item, item_path, allow_empty=key == "baseimage_repo")
        elif key in OPTIONAL_STRING_VARS:
            if item is not None:
                _string(item, item_path)
        elif key in STRING_LIST_VARS:
            values = _sequence(item, item_path)
            for index, element in enumerate(values):
                _string(element, f"{item_path}[{index}]")
        elif key in BOOL_VARS and not isinstance(item, bool):
            raise ConfigError(f"{item_path}: expected a boolean")
    return result


def load_config(path: Path) -> Config:
    """Load and validate the generator matrix at *path*."""

    raw = yaml.safe_load(path.read_text())
    root = _mapping(raw, str(path))
    _only_keys(root, {"type", "defaults", "distro_families", "distros"}, str(path))

    image_type = _string(root.get("type"), "type")
    defaults_block = _mapping(root.get("defaults"), "defaults")
    _only_keys(defaults_block, {"vars"}, "defaults")
    defaults = _vars(defaults_block.get("vars"), "defaults.vars")

    family_blocks = _mapping(root.get("distro_families"), "distro_families")
    families: dict[str, dict[str, Any]] = {}
    for name, raw_family in family_blocks.items():
        family_path = f"distro_families.{name}"
        family_config = _mapping(raw_family, family_path)
        _only_keys(family_config, {"vars"}, family_path)
        families[_string(name, family_path)] = _vars(
            family_config.get("vars"), f"{family_path}.vars"
        )

    distros: list[Distro] = []
    identities: set[tuple[str, str]] = set()
    for distro_index, raw_distro in enumerate(
        _sequence(root.get("distros"), "distros")
    ):
        distro_path = f"distros[{distro_index}]"
        distro = _mapping(raw_distro, distro_path)
        _only_keys(distro, {"name", "distro_family", "vars", "outputs"}, distro_path)
        name = _string(distro.get("name"), f"{distro_path}.name")
        family_name = _string(
            distro.get("distro_family"), f"{distro_path}.distro_family"
        )
        if family_name not in families:
            raise ConfigError(
                f"{distro_path}.distro_family: unknown family {family_name!r}"
            )
        distro_vars = _vars(distro.get("vars", {}), f"{distro_path}.vars")
        outputs: list[Output] = []
        for output_index, raw_output in enumerate(
            _sequence(distro.get("outputs"), f"{distro_path}.outputs")
        ):
            output_path = f"{distro_path}.outputs[{output_index}]"
            output = _mapping(raw_output, output_path)
            _only_keys(output, {"baseimage_version", "vars"}, output_path)
            raw_version = output.get("baseimage_version")
            if isinstance(raw_version, bool) or not isinstance(
                raw_version, (str, int, float)
            ):
                raise ConfigError(
                    f"{output_path}.baseimage_version: expected a string or number"
                )
            version = str(raw_version)
            identity = (name, version)
            if identity in identities:
                raise ConfigError(f"{output_path}: duplicate output {name}.{version}")
            identities.add(identity)
            outputs.append(
                Output(version, _vars(output.get("vars", {}), f"{output_path}.vars"))
            )
        if not outputs:
            raise ConfigError(f"{distro_path}.outputs: expected at least one output")
        distros.append(Distro(name, family_name, distro_vars, tuple(outputs)))

    return Config(image_type, defaults, families, tuple(distros))


def _unique(values: Sequence[str], path: str) -> tuple[str, ...]:
    """Return values as a tuple after rejecting duplicates."""

    seen: set[str] = set()
    result: list[str] = []
    for value in values:
        if value in seen:
            raise ConfigError(f"{path}: duplicate value {value!r}")
        seen.add(value)
        result.append(value)
    return tuple(result)


def resolve_images(config: Config) -> tuple[ResolvedImage, ...]:
    """Resolve inheritance and derive render values for every configured image."""

    images: list[ResolvedImage] = []
    for distro in config.distros:
        for output in distro.outputs:
            values = (
                config.defaults
                | config.distro_families[distro.distro_family]
                | distro.vars
                | output.vars
            )
            missing = KNOWN_VARS - values.keys()
            if missing:
                raise ConfigError(
                    f"{distro.name}.{output.baseimage_version}: missing variables: {', '.join(sorted(missing))}"
                )

            python_version = values["python_version"]
            package_mgr_name = values["package_mgr_name"]
            baseimage_repo = values["baseimage_repo"]
            baseimage = (
                values["baseimage"] or f"{baseimage_repo}:{output.baseimage_version}"
            )
            if not baseimage:
                raise ConfigError(
                    f"{distro.name}.{output.baseimage_version}.baseimage: could not derive base image"
                )

            default_packages = [
                item.format(python_version=python_version)
                for item in values["default_packages"]
            ]
            all_packages = _unique(
                default_packages + values["packages"],
                f"{distro.name}.{output.baseimage_version}.packages",
            )
            if not values["docker_platforms"]:
                raise ConfigError(
                    f"{distro.name}.{output.baseimage_version}.docker_platforms: expected at least one platform"
                )
            masked_services = _unique(
                values["masked_services"] + values["extra_masked_services"],
                f"{distro.name}.{output.baseimage_version}.masked_services",
            )
            ci_image_repo = (
                f"quay.io/gotmax23/{distro.name.lower()}-{config.image_type}"
            )
            aliases = [output.baseimage_version, *values["extra_ci_image_tags"]]
            _unique(
                [
                    *(f"{ci_image_repo}:{tag}" for tag in aliases),
                    *values["extra_ci_image_repos"],
                ],
                f"{distro.name}.{output.baseimage_version}.image_tags",
            )
            containerfile_dir = f"Containerfiles/{config.image_type}/{distro.name}"
            containerfile_path = f"{containerfile_dir}/{distro.name}.{output.baseimage_version}.Containerfile"
            workflow_path = f".github/workflows/{config.image_type}-{distro.name}.{output.baseimage_version}-ci.yml"

            images.append(
                ResolvedImage(
                    image_type=config.image_type,
                    distro_name=distro.name,
                    distro_family=distro.distro_family,
                    baseimage_version=output.baseimage_version,
                    python_version=python_version,
                    docker_cmd=values["docker_cmd"],
                    docker_stopsignal=values["docker_stopsignal"],
                    docker_platforms=_unique(
                        values["docker_platforms"],
                        f"{distro.name}.{output.baseimage_version}.docker_platforms",
                    ),
                    baseimage_repo=baseimage_repo,
                    baseimage=baseimage,
                    package_mgr_name=package_mgr_name,
                    package_mgr_install_cmd=values["package_mgr_install_cmd"].rstrip(),
                    package_mgr_clean_cmd=values["package_mgr_clean_cmd"].format(
                        package_mgr_name=package_mgr_name
                    ),
                    all_packages=all_packages,
                    build_cron=values["build_cron"],
                    update_ms=values["update_ms"],
                    masked_services=masked_services,
                    extra_commands=tuple(values["extra_commands"]),
                    gha_workflow=values["gha_workflow"],
                    ci_image_repo=ci_image_repo,
                    all_ci_image_tags=tuple(aliases),
                    extra_ci_image_repos=tuple(values["extra_ci_image_repos"]),
                    containerfile_dir=containerfile_dir,
                    containerfile_path=containerfile_path,
                    workflow_path=workflow_path,
                )
            )
    return tuple(images)


def render_outputs(
    repo_root: Path,
) -> tuple[dict[Path, str], dict[Path, str]]:
    """Render configured Containerfiles and workflow shims."""

    source_dir = repo_root / "src/systemd"
    config = load_config(source_dir / "matrix.yml")
    images = resolve_images(config)
    environment = Environment(
        loader=FileSystemLoader(source_dir),
        undefined=StrictUndefined,
        keep_trailing_newline=True,
        trim_blocks=True,
        lstrip_blocks=True,
        autoescape=False,
    )
    containerfile_template = environment.get_template("Containerfile.j2")
    workflow_template = environment.get_template("ci.yml.j2")

    containerfiles: dict[Path, str] = {}
    workflows: dict[Path, str] = {}
    for image in images:
        context = asdict(image)
        containerfiles[repo_root / image.containerfile_path] = (
            containerfile_template.render(**context)
        )
        if image.gha_workflow:
            workflow_path = repo_root / image.workflow_path
            workflows[workflow_path] = workflow_template.render(**context)
    return containerfiles, workflows


def generate(repo_root: Path, *, check: bool) -> int:
    """Write generated files, or report drift when *check* is true."""

    containerfiles, workflows = render_outputs(repo_root)
    outputs = containerfiles | workflows
    stale_workflows = {
        path
        for path in (repo_root / ".github/workflows").glob("systemd-*-ci.yml")
        if path not in workflows
    }
    drift = False
    for path, expected in sorted(outputs.items()):
        actual = path.read_text() if path.exists() else ""
        if actual == expected:
            continue
        drift = True
        if check:
            print(f"out of date: {path.relative_to(repo_root)}", file=sys.stderr)
            diff = difflib.unified_diff(
                actual.splitlines(),
                expected.splitlines(),
                fromfile=str(path.relative_to(repo_root)),
                tofile=f"generated/{path.relative_to(repo_root)}",
                lineterm="",
            )
            print("\n".join(diff), file=sys.stderr)
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(expected)
            print(f"updated {path.relative_to(repo_root)}")

    for path in sorted(stale_workflows):
        drift = True
        if check:
            print(f"stale workflow: {path.relative_to(repo_root)}", file=sys.stderr)
        else:
            path.unlink()
            print(f"removed {path.relative_to(repo_root)}")
    return int(drift and check)


def main() -> int:
    """Run the command-line generator."""

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="report generated-file drift without writing files",
    )
    args = parser.parse_args()
    repo_root = Path(__file__).resolve().parents[2]
    try:
        return generate(repo_root, check=args.check)
    except ConfigError as exc:
        parser.error(str(exc))
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
