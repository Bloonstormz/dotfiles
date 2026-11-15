#!/usr/bin/env python3

from __future__ import annotations

import curses
import itertools
import os
import pathlib
import re
import subprocess
import sys
from enum import Enum
from typing import Any

if os.name == "nt":
    print("Not runnable on Windows!")
    sys.exit(1)


class Action(Enum):
    IGNORE = 0
    HOST_DOWNLOAD = 1
    NIX_DOWNLOAD = 2

    DISABLED = 3  # Requires host installation, but no sudo access


WILL_INSTALL = (Action.HOST_DOWNLOAD, Action.NIX_DOWNLOAD)

CFG_REGEX = re.compile(r'(?P<type>[^_]+)_(?P<name>[^=]+)=(?P<value>.*)$')

class Config:
    config: dict[str, list[Package]]

    all_packages: list[Package]
    all_package_configs: list[PackageConfig]

    def __init__(self, config: dict[str, list[Package]]) -> None:
        self.config = config

        self.all_packages = list(itertools.chain(*self.config.values()))
        self.all_package_configs = list(itertools.chain(*(pkg.package_configs for pkg in self.all_packages)))

    def write_config(self, file: pathlib.Path):
        res: list[str] = ["HOST_INSTALL=()", "NIX_INSTALL=()"]
        host_install: list[str] = []
        nix_install: list[str] = []

        for package in self.all_packages:
            pkg_type="false"
            if package.install in WILL_INSTALL:
                if package.package_configs:
                    for config in package.package_configs:
                        res.append(f"CFG_{config.name}={config.chosen}")

                if package.install == Action.HOST_DOWNLOAD:
                    host_install.append(package.host_name)
                    pkg_type="host"
                elif package.install == Action.NIX_DOWNLOAD:
                    nix_install.append(package.nix_name)
                    pkg_type="nix"

            res.append(f"BIN_{package.name}={pkg_type}")

        res.append(f"HOST_INSTALL+=( {' '.join(f'"{pkg}"' for pkg in host_install)} )")
        res.append(f"NIX_INSTALL+=( {' '.join(f'"{pkg}"' for pkg in nix_install)} )")

        with open(file, "w") as f:
            f.write("\n".join(res))

    def load_config(self, file: pathlib.Path):
        with open(file, "r") as f:
            for line in f.readlines():
                m = CFG_REGEX.match(line)
                if m is None:
                    continue
                match m.group("type"):
                    case "CFG":
                        for pkg_cfg in self.all_package_configs:
                            if pkg_cfg.name == m.group("name"):
                                pkg_cfg.chosen = m.group("value")
                    case "BIN":
                        for pkg in self.all_packages:
                            if pkg.install != Action.DISABLED and pkg.name == m.group("name"):
                                match m.group("value"):
                                    case "false":
                                        pkg.install = Action.IGNORE
                                    case "host":
                                        pkg.install = Action.HOST_DOWNLOAD
                                    case "nix":
                                        pkg.install = Action.NIX_DOWNLOAD



class Package:
    name: str
    depends: list[Package]

    install: Action
    allow_nix: bool = True
    allow_host: bool = True

    nix_name: str
    host_name: str

    package_configs: list[PackageConfig]

    def __init__(
        self,
        name: str,
        depends_on: list[Package] | None = None,
        allow_nix: bool = True,
        nix_name: str | None = None,
        void_name: str | None = None,
        binary: str | None = None,
        allow_host: bool = True,
        default_install: bool = True,
        package_configs: list[PackageConfig] | None = None,
    ) -> None:
        self.name = name.replace(" ", "_").replace("-", "_")
        self.depends = depends_on if depends_on is not None else []
        self.allow_nix = allow_nix
        self.allow_host = allow_host

        self.nix_name = nix_name if nix_name is not None else name
        if HOST_INSTALL == "xbps-install":
            self.host_name = void_name if void_name is not None else name
        else:
            raise ValueError(f"Unexpected host installer: '{HOST_INSTALL}'")

        if not ((CAN_SUDO and allow_host) or allow_nix):
            self.install = Action.DISABLED
        elif (
            not command_exists(binary if binary is not None else name)
            and default_install
        ):
            if CAN_SUDO and allow_host:
                self.install = Action.HOST_DOWNLOAD
            elif allow_nix:
                self.install = Action.NIX_DOWNLOAD
        else:
            self.install = Action.IGNORE

        self.package_configs = [] if package_configs is None else package_configs

    def set_action(self, action: Action) -> bool:
        if (
            action == Action.HOST_DOWNLOAD
            and self.allow_host
            or action == Action.NIX_DOWNLOAD
            and self.allow_nix
            or action in (Action.DISABLED, Action.IGNORE)
        ):
            self.install = action
            return True
        return False

    def cycle_action(self):
        options = [Action.IGNORE]
        if self.allow_host:
            options.append(Action.HOST_DOWNLOAD)
        if self.allow_nix:
            options.append(Action.NIX_DOWNLOAD)
        self.install = options[(options.index(self.install) + 1) % len(options)]

class HostPackage(Package):
    def __init__(self, name: str, **opts) -> None:
        maybe_set_dict(opts, "default_install", False)
        maybe_set_dict(opts, "allow_nix", False)
        super().__init__(name, **opts)


class PackageConfig:
    name: str
    choices: list[str]
    display_name: str

    chosen: str

    def __init__(self, name: str, choices: list[str], display_name: str|None = None) -> None:
        self.name = name
        self.choices = choices
        self.display_name = display_name if display_name is not None else name

        self.chosen = choices[0]

def command_exists(command: str) -> bool:
    return not subprocess.run(
        ["which", command],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    ).returncode


sudo_check = subprocess.run(
    ["sudo", "-nv"], check=False, text=True, capture_output=True
)
CAN_SUDO = sudo_check.returncode == 0 or sudo_check.stderr.startswith("sudo:")

if command_exists("xbps-install"):
    HOST_INSTALL = "xbps-install"
elif command_exists("nixos-rebuild"):
    raise NotImplementedError("TODO: Nix support")
else:
    raise NotImplementedError("Unsupported Host")

def maybe_set_dict(dict: dict[str, Any], key: str, value: Any):
    if key not in dict:
        dict[key] = value


def create_packages(package_names: list[str | Package], **opts) -> list[Package]:
    res: list[Package] = []
    for name in package_names:
        if isinstance(name, str):
            res.append(Package(name, **opts))
        else:
            res.append(name)

    return res


zsh = Package("zsh")
omz = Package("oh-my-zsh", allow_host=False, depends_on=[zsh])
p10k = Package(
    "powerlevel10k", allow_host=False, depends_on=[zsh], nix_name="zsh-powerlevel10k"
)
payRespects = Package("pay-respects", allow_host=False)

# Display Packages
niri = HostPackage("niri", package_configs=[
    PackageConfig("DISPLAY_THEME", ["Light", "Dark"], "Theme")
])
waybar = HostPackage("waybar")

# Launchers
wofi = HostPackage("wofi")
walker = HostPackage("walker")


swaync = HostPackage("Sway Notification Centre", void_name="SwayNotificationCenter", binary="swaync")

Install_Config = Config(
    {
        "Shell": create_packages(["bash", zsh, payRespects]) + [omz, p10k],
        "Terminal Utilities": create_packages(
            [
                "bat",
                "delta",
                "fd",
                "fzf",
                "git",
                "lazygit",
                Package("ripgrep", binary="rg"),
                "tmux",
                "unzip",
                "yazi",
            ],
        ),
        "Apps": create_packages(["firefox", "ghostty"], default_install=False),
        "Editors": create_packages([Package("neovim", binary="nvim")]),
        "Display": [
            niri, waybar, swaync
        ],
    }
)


# Taken from Kconfiglib: https://github.com/ulfalizer/Kconfiglib/blob/master/menuconfig.py#L3139
def getch_compat(win):
    # Uses get_wch() if available (Python 3.3+) and getch() otherwise.
    #
    # Also falls back on getch() if get_wch() raises curses.error, to work
    # around an issue when resizing the terminal on at least macOS Catalina.
    # See https://github.com/ulfalizer/Kconfiglib/issues/84.
    #
    # Also handles a PDCurses resizing quirk.

    try:
        c = win.get_wch()
    except (AttributeError, curses.error):
        c = win.getch()
        if 0 <= c <= 255:
            c = chr(c)

    # Decent resizing behavior on PDCurses requires calling resize_term(0, 0)
    # after receiving KEY_RESIZE, while ncurses (usually) handles terminal
    # resizing automatically in get(_w)ch() (see the end of the
    # resizeterm(3NCURSES) man page).
    #
    # resize_term(0, 0) reliably fails and does nothing on ncurses, so this
    # hack gives ncurses/PDCurses compatibility for resizing. I don't know
    # whether it would cause trouble for other implementations.
    if c == curses.KEY_RESIZE:
        try:
            curses.resize_term(0, 0)
        except curses.error:
            pass

    return c


def display(_win: curses.window):
    """Interactively choose which packages to install."""
    win = _win
    collapsed: set[str] = set()
    selected = 0
    scroll = 0

    def rows():
        result: list[tuple[str, str, Package | PackageConfig | None]] = []
        for category, packages in Install_Config.config.items():
            result.append(("category", category, None))
            if category not in collapsed:
                for package in packages:
                    if package.install == Action.DISABLED or not can_install(package):
                        continue
                    result.append(("package", category, package))
                    if package.install in WILL_INSTALL:
                        result.extend(
                            ("config", category, config)
                            for config in package.package_configs
                        )
        return result

    def can_install(package: Package) -> bool:
        return not package.depends or any(
            dep.install in WILL_INSTALL for dep in package.depends
        )

    while True:
        height, width = win.getmaxyx()
        try:
            win.erase()
            win.addnstr(
                0,
                0,
                "Package configuration  ↑/↓ move  Space select  ←/→ change value  q save",
                max(0, width - 1),
                curses.A_BOLD,
            )
            visible_rows = rows()
            if visible_rows:
                selected = max(0, min(selected, len(visible_rows) - 1))
            body_height = max(0, height - 2)
            if selected < scroll:
                scroll = selected
            elif selected >= scroll + body_height:
                scroll = selected - body_height + 1
            scroll = max(0, min(scroll, max(0, len(visible_rows) - body_height)))

            for screen_row, (kind, label, package) in enumerate(
                visible_rows[scroll : scroll + body_height], start=1
            ):
                index = scroll + screen_row - 1
                attr = curses.A_REVERSE if index == selected else curses.A_NORMAL
                if kind == "category":
                    marker = "+" if label in collapsed else "-"
                    text = f"{marker} {label}"
                    attr |= curses.A_BOLD
                elif kind == "package":
                    assert isinstance(package, Package)
                    if package.install == Action.HOST_DOWNLOAD:
                        status = "H"
                        extra = " (Host Installation)"
                    elif package.install == Action.NIX_DOWNLOAD:
                        status = "N"
                        extra = " (Nix Installation)"
                    else:
                        status = " "
                        extra = ""
                    text = f"    [{status}] {package.name.replace("_", " ")}{extra}"
                else:
                    assert isinstance(package, PackageConfig)
                    text = f"        {package.display_name}: {package.chosen}"
                win.addnstr(screen_row, 0, text, max(0, width - 1), attr)

            if height > 1:
                win.addnstr(
                    height - 1,
                    0,
                    "Space: toggle package/category or choose config | ←/→: change config | q: save and quit",
                    max(0, width - 1),
                )
            win.refresh()
        except curses.error:
            # A resize may invalidate coordinates between getmaxyx() and drawing.
            pass

        try:
            key = getch_compat(win)
        except KeyboardInterrupt:
            return 130
            key = "q"
        if key in ("q", "Q", "\x1b"):
            return 0
        if key in (curses.KEY_UP, "k"):
            selected = max(0, selected - 1)
        elif key in (curses.KEY_DOWN, "j"):
            selected = min(max(0, len(rows()) - 1), selected + 1)
        elif key == curses.KEY_PPAGE:
            selected = max(0, selected - max(1, height - 2))
        elif key == curses.KEY_NPAGE:
            selected = min(max(0, len(rows()) - 1), selected + max(1, height - 2))
        elif key in (curses.KEY_LEFT, curses.KEY_RIGHT):
            visible_rows = rows()
            if visible_rows:
                kind, _, item = visible_rows[selected]
                if kind == "config" and isinstance(item, PackageConfig):
                    current = item.choices.index(item.chosen)
                    delta = -1 if key == curses.KEY_LEFT else 1
                    item.chosen = item.choices[(current + delta) % len(item.choices)]
        elif key in (" ", "\n", "\r", curses.KEY_ENTER, "h", "H", "n", "N", "d", "D"):
            visible_rows = rows()
            if not visible_rows:
                continue
            kind, label, package = visible_rows[selected]

            if kind == "config":
                if isinstance(package, PackageConfig):
                    current = package.choices.index(package.chosen)
                    package.chosen = package.choices[(current + 1) % len(package.choices)]
            elif key in ("h", "H"):
                if isinstance(package, Package) and package.allow_host:
                    package.install = Action.HOST_DOWNLOAD
            elif key in ("n", "N"):
                if isinstance(package, Package) and package.allow_nix:
                    package.install = Action.NIX_DOWNLOAD
            elif key in ("d", "D"):
                if isinstance(package, Package):
                    package.install = Action.IGNORE
            else:
                if kind == "category":
                    if label in collapsed:
                        collapsed.remove(label)
                    else:
                        collapsed.add(label)
                elif isinstance(package, Package):
                    package.cycle_action()

    return 1


if __name__ == "__main__":
    config_file = pathlib.Path(__file__).parent.parent / ".config"

    if config_file.is_file():
        Install_Config.load_config(config_file)

    rc = curses.wrapper(display)

    if rc == 0:
        Install_Config.write_config(config_file)

    sys.exit(rc)
