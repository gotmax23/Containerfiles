import nox

nox.options.default_venv_backend = "uv"
nox.options.sessions = ["lint", "typing", "generated", "zizmor"]


def install(session: nox.Session, *groups: str) -> None:
    """Synchronize project and session dependencies into the Nox environment."""
    group_args = [argument for group in groups for argument in ("--group", group)]
    session.run_install(
        "uv",
        "sync",
        "--active",
        "--locked",
        "--no-default-groups",
        *group_args,
        external=True,
    )


@nox.session
def lint(session: nox.Session) -> None:
    install(session, "lint")
    session.run("ruff", "check", ".")
    session.run("ruff", "format", "--check", ".")


@nox.session
def generated(session: nox.Session) -> None:
    install(session)
    session.run("python", "generate.py", "--check")


@nox.session
def typing(session: nox.Session) -> None:
    install(session, "typing")
    session.run("mypy", "--strict", "generate.py")


@nox.session
def zizmor(session: nox.Session) -> None:
    install(session, "zizmor")
    session.run("zizmor", "../../.github/workflows")
