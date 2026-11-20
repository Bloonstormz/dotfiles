#!/usr/bin/env python3

from __future__ import annotations

import curses
import itertools
import json
import os
import pathlib
import re
import subprocess
import sys
from enum import Enum
from typing import Any, NotRequired, TypedDict

if os.name == "nt":
    print("Not runnable on Windows!")
    sys.exit(1)

REPO_ROOT = pathlib.Path(__file__).parent.parent
NIX_REPO_ROOT = f"path:{REPO_ROOT}"
lock_file = REPO_ROOT / "flake.lock"
if lock_file.exists():
    with open(lock_file, "r") as f:
        nixpkg_rev = "/" + json.load(f)["nodes"]["nixpkgs"]["locked"]["rev"]
else:
    nixpkg_rev = ""


class Action(Enum):
    IGNORE = 0
    HOST_DOWNLOAD = 1
    NIX_DOWNLOAD = 2

    DISABLED = 3  # Requires host installation, but no sudo access


class NixOSConfig(TypedDict):
    config: str
    isSysPackage: NotRequired[bool]
    isFontPackage: NotRequired[bool]


WILL_INSTALL = (Action.HOST_DOWNLOAD, Action.NIX_DOWNLOAD)

CFG_REGEX = re.compile(r"(?P<type>[^_]+)_(?P<name>[^=]+)=(?P<value>.*)$")


class Config:
    config: dict[str, list[Package]]

    all_packages: list[Package]
    all_package_configs: list[PackageConfig]

    def __init__(self, config: dict[str, list[Package]]) -> None:
        self.config = config

        self.all_packages = []
        pkg_set = set()

        def add_pkg(pkg: Package):
            pkg_set.add(pkg)
            if pkg.sub_packages:
                for sub_pkg in pkg.sub_packages:
                    add_pkg(sub_pkg)

        for pkg in itertools.chain(*self.config.values()):
            add_pkg(pkg)

        self.all_packages = list(pkg_set)
        self.all_package_configs = list(
            itertools.chain(*(pkg.package_configs for pkg in self.all_packages))
        )

    def write_config(self, file: pathlib.Path, nixos_file: pathlib.Path):
        res: list[str] = ["HOST_INSTALL=()", "NIX_INSTALL=()"]
        nixos_config: list[str] = ["{ pkgs, ... }:", "{"]
        host_install: list[str] = []
        nix_install: list[str] = []

        nix_sys_pkgs: list[str] = []
        nix_font_pkgs: list[str] = []

        for package in self.all_packages:
            pkg_type = "false"
            if package.install in WILL_INSTALL:
                if package.package_configs:
                    for config in package.package_configs:
                        res.append(f"CFG_{config.name}={config.chosen}")

                if package.install == Action.HOST_DOWNLOAD:
                    pkg_type = "host"
                    if HOST_INSTALL == "NixOS":
                        config = package.nix_os_config
                        if config.get("isSysPackage", False):
                            nix_sys_pkgs.append(config["config"])
                        elif config.get("isFontPackage", False):
                            nix_font_pkgs.append(config["config"])
                        else:
                            nixos_config.append(f"{config['config']};")
                    else:
                        host_install.append(package.host_name)
                elif package.install == Action.NIX_DOWNLOAD:
                    nix_install.append(f"{package.nix_source}#{package.nix_name}")
                    pkg_type = "nix"

            res.append(f"BIN_{package.name}={pkg_type}")

        res.append(f"HOST_INSTALL+=( {' '.join(f'"{pkg}"' for pkg in host_install)} )")
        res.append(f"NIX_INSTALL+=( {' '.join(f'"{pkg}"' for pkg in nix_install)} )")

        with open(file, "w") as f:
            f.write("\n".join(res))

        if HOST_INSTALL == "NixOS":
            if len(nix_sys_pkgs) > 0:
                nixos_config.append("environment.systemPackages = [")
                nixos_config.extend(nix_sys_pkgs)
                nixos_config.append("];")
            if len(nix_font_pkgs) > 0:
                nix_font_pkgs.append("fonts.packages = [")
                nix_font_pkgs.extend(nix_sys_pkgs)
                nix_font_pkgs.append("];")

            nixos_config.append("}")
            with open(nixos_file, "w") as f:
                f.write("\n".join(nixos_config))

    def load_config(self, file: pathlib.Path):
        with open(file, "r") as f:
            for line in f:
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
                            if pkg.install != Action.DISABLED and pkg.name == m.group(
                                "name"
                            ):
                                match m.group("value"):
                                    case "false":
                                        pkg.install = Action.IGNORE
                                    case "host":
                                        pkg.install = Action.HOST_DOWNLOAD
                                    case "nix":
                                        pkg.install = Action.NIX_DOWNLOAD


class Package:
    name: str  # Internal identifier - Must be a valid bash variable name
    display_name: str  # Name shown to user - any valid string
    depends: list[Package]

    install: Action
    allow_nix: bool = True
    allow_host: bool = True

    nix_name: str
    nix_source: str
    host_name: str
    nix_os_config: NixOSConfig

    package_configs: list[PackageConfig]
    sub_packages: list[Package]

    comment: str

    def __init__(
        self,
        name: str,
        depends_on: list[Package] | None = None,
        nix_name: str | None = None,
        nix_source: str = f"nixpkgs{nixpkg_rev}",
        void_name: str | None = None,
        arch_name: str | None = None,
        nix_os_config: NixOSConfig | None = None,
        binary: str | None = None,
        package_lookup: bool = False,  # Search using host package installer lookup instead of command -v
        display_name: str | None = None,
        allow_nix: bool = True,
        allow_host: bool = True,
        default_install: bool = True,
        package_configs: list[PackageConfig] | None = None,
        sub_packages: list[Package] | None = None,
        comment: str = "",
    ) -> None:
        self.name = name.replace(" ", "_").replace("-", "_")
        self.display_name = name if display_name is None else display_name
        self.depends = depends_on if depends_on is not None else []
        self.allow_nix = allow_nix
        self.allow_host = allow_host

        self.nix_name = nix_name if nix_name is not None else name
        self.nix_source = nix_source
        if HOST_INSTALL == "VoidLinux":
            self.__set_host_name(void_name)
        elif HOST_INSTALL == "ArchLinux":
            self.__set_host_name(arch_name)
        elif HOST_INSTALL == "NixOS":
            self.host_name = name
            if nix_os_config is None:
                self.nix_os_config = {"config": f"pkgs.{name}", "isSysPackage": True}
            else:
                self.nix_os_config = nix_os_config
        else:
            raise ValueError(f"Unexpected host installer: '{HOST_INSTALL}'")

        if not ((CAN_SUDO and self.allow_host) or self.allow_nix):
            self.install = Action.DISABLED
        elif default_install and (
            (
                package_lookup
                and lookup_package(arch_name=arch_name, void_name=void_name)
            )
            or (
                (not package_lookup)
                and (not command_exists(binary if binary is not None else name))
            )
        ):
            if CAN_SUDO and self.allow_host:
                self.install = Action.HOST_DOWNLOAD
            elif self.allow_nix:
                self.install = Action.NIX_DOWNLOAD
        else:
            self.install = Action.IGNORE

        self.package_configs = [] if package_configs is None else package_configs
        self.sub_packages = [] if sub_packages is None else sub_packages

        self.comment = comment

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

    def __set_host_name(self, name: str | None, default: str | None = None):
        if name is None:
            if default is not None:
                self.host_name = default
            else:
                self.host_name = self.name
        elif name == "":
            self.host_name = ""
            self.allow_host = False
        else:
            self.host_name = name

    def __hash__(self) -> int:
        return self.name.__hash__()


class HostPackage(Package):
    def __init__(self, name: str, **opts) -> None:
        maybe_set_dict(opts, "default_install", False)
        maybe_set_dict(opts, "allow_nix", False)
        super().__init__(name, **opts)


class NixPackage(Package):
    def __init__(self, name: str, **opts) -> None:
        maybe_set_dict(opts, "allow_host", False)
        super().__init__(name, **opts)


class PackageConfig:
    name: str
    choices: list[str]
    display_name: str

    chosen: str

    def __init__(
        self, name: str, choices: list[str], display_name: str | None = None
    ) -> None:
        self.name = name
        self.choices = choices
        self.display_name = display_name if display_name is not None else name

        self.chosen = choices[0]


def check_rc(command: list[str]) -> bool:
    return not subprocess.run(
        command,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    ).returncode


def command_exists(command: str) -> bool:
    return check_rc(["which", command])


def lookup_package(arch_name: str | None = None, void_name: str | None = None) -> bool:
    if HOST_INSTALL == "VoidLinux":
        if void_name is None:
            return False
        return check_rc(["xbps-query", void_name])
    elif HOST_INSTALL == "ArchLinux":
        if arch_name is None:
            return False
        return check_rc(["pacman", "-Qi", arch_name])
    else:
        raise NotImplementedError("Unsupported Host")


sudo_check = subprocess.run(
    ["sudo", "-nv"], check=False, text=True, capture_output=True
)
CAN_SUDO = sudo_check.returncode == 0 or sudo_check.stderr.startswith("sudo:")

if command_exists("xbps-install"):
    HOST_INSTALL = "VoidLinux"
elif command_exists("pacman"):
    HOST_INSTALL = "ArchLinux"
elif command_exists("nixos-rebuild"):
    HOST_INSTALL = "NixOS"
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


# Utilities
networkManager = Package(
    "NetworkManager",
    display_name="Network Manager",
    allow_nix=False,
    arch_name="networkmanager",
)
nmApplet = Package(
    "networkManagerApplet",
    display_name="Network Manager Applet",
    void_name="network-manager-applet",
    arch_name="network-manager-applet",
    allow_nix=False,
    depends_on=[networkManager],
    binary="nm-applet",
)
pavucontrol = Package("pavucontrol", allow_nix=False)
playerctl = Package("playerctl", allow_nix=False)
bluez = Package("bluez", allow_nix=False, binary="bluetoothctl")
blueman = Package(
    "blueman",
    allow_nix=False,
    void_name="blueman",
    binary="blueman-manager",
    display_name="Blueman",
    depends_on=[bluez],
)

nwg_look = Package(
    "nwg_look",
    display_name="Nwg Look",
    allow_nix=False,
    void_name="nwg-look",
    arch_name="nwg-look",
    binary="nwg-look",
)

cliphist = Package("cliphist", allow_nix=False)
wlclipboard = Package(
    "wlclipboard",
    void_name="wl-clipboard",
    arch_name="wl-clipboard",
    allow_nix=False,
    binary="wl-copy",
)

zsh = Package("zsh")
omz = Package(
    "oh_my_zsh",
    allow_host=False,
    depends_on=[zsh],
    display_name="Oh My Zsh",
    nix_name="oh-my-zsh",
)
p10k = Package(
    "powerlevel10k", allow_host=False, depends_on=[zsh], nix_name="zsh-powerlevel10k"
)
payRespects = Package(
    "pay_respects",
    allow_host=False,
    display_name="Pay Respects",
    nix_name="pay-respects",
)

# Display Packages
niri = HostPackage(
    "niri",
    package_configs=[PackageConfig("DISPLAY_THEME", ["Light", "Dark"], "Theme")],
    sub_packages=[cliphist, wlclipboard],
)
waybar_auto_hide = NixPackage("waybar_auto_hide", nix_source=NIX_REPO_ROOT)
ghostty = NixPackage("ghostty", nix_source=NIX_REPO_ROOT, default_install=False)
waybar = HostPackage(
    "waybar",
    sub_packages=[
        waybar_auto_hide,
        networkManager,
        nmApplet,
        pavucontrol,
        playerctl,
        bluez,
        blueman,
    ],
    void_name="Waybar",
)

# Launchers
rofi = HostPackage("rofi")
wofi = HostPackage("wofi")

# Notifications

swaync = HostPackage(
    "Sway_Notification_Centre",
    void_name="SwayNotificationCenter",
    arch_name="swaync",
    binary="swaync",
    display_name="Sway Notification Centre",
    sub_packages=[nwg_look],
)

# Portals
# termfilechooser requires AUR for arch support. AUR is not supported currently
termfilechooser = HostPackage(
    "xdg-desktop-portal-termfilechooser",
    arch_name="",
    package_lookup=True,
    comment="Allows choosing your own application as a file picker",
)

Install_Config = Config(
    {
        "Shell": create_packages(["bash", zsh, payRespects]) + [omz, p10k],
        "Terminal Utilities": create_packages(
            [
                "bat",
                Package("delta", arch_name="git-delta"),
                "fd",
                "fzf",
                "git",
                "lazygit",
                Package("ripgrep", binary="rg"),
                "tmux",
                "unzip",
                Package("yazi", sub_packages=[termfilechooser]),
            ],
        ),
        "Apps": create_packages(["firefox"], default_install=False) + [ghostty],
        "Editors": create_packages(
            [
                Package(
                    "neovim",
                    binary="nvim",
                    sub_packages=[
                        Package(
                            "lolcat",
                            nix_name="lolcat-c",
                            nix_source=NIX_REPO_ROOT,
                            void_name="lolcat-c",
                            arch_name="",
                        )
                    ],
                )
            ]
        ),
        "Display": [
            niri,
            waybar,
            swaync,
            HostPackage("gammastep"),
            HostPackage("SwayOSD", binary="swayosd-client", arch_name="swayosd"),
        ],
        "Launchers": [rofi, wofi],
        "App Utilities": [HostPackage("dex")],
        "Idle": [HostPackage("hypridle"), HostPackage("hyprlock")],
        "Wallpapers": [
            HostPackage(
                "awww", display_name="An Answer to your Wayland Wallpaper Woes (awww)"
            )
        ],
        "Screenshot": [
            wlclipboard,
            HostPackage("grim"),
            HostPackage("slurp"),
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
        result: list[tuple[str, str, Package | PackageConfig | None, int]] = []

        def add_package(package: Package, category: str, depth: int) -> None:
            if package.install == Action.DISABLED or not can_install(package):
                return

            result.append(("package", category, package, depth))
            if package.install in WILL_INSTALL:
                result.extend(
                    ("config", category, config, depth + 1)
                    for config in package.package_configs
                )
            for sub_package in package.sub_packages:
                add_package(sub_package, category, depth + 1)

        for category, packages in Install_Config.config.items():
            result.append(("category", category, None, 0))
            if category not in collapsed:
                for package in packages:
                    add_package(package, category, 0)
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

            for screen_row, (kind, label, package, depth) in enumerate(
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

                    if package.comment == "":
                        comment = ""
                    else:
                        comment = f" - {package.comment}"

                    text = f"{'    ' * (depth + 1)}[{status}] {package.display_name}{extra}{comment}"
                else:
                    assert isinstance(package, PackageConfig)
                    text = f"{'    ' * (depth + 1)}{package.display_name}: {package.chosen}"
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
                kind, _, item, _ = visible_rows[selected]
                if kind == "config" and isinstance(item, PackageConfig):
                    current = item.choices.index(item.chosen)
                    delta = -1 if key == curses.KEY_LEFT else 1
                    item.chosen = item.choices[(current + delta) % len(item.choices)]
        elif key in (" ", "\n", "\r", curses.KEY_ENTER, "h", "H", "n", "N", "d", "D"):
            visible_rows = rows()
            if not visible_rows:
                continue
            kind, label, package, _ = visible_rows[selected]

            if kind == "config":
                if isinstance(package, PackageConfig):
                    current = package.choices.index(package.chosen)
                    package.chosen = package.choices[
                        (current + 1) % len(package.choices)
                    ]
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
    config_file = REPO_ROOT / ".config"
    nixos_file = REPO_ROOT / "nix/nixos/gen_config"

    if config_file.is_file():
        Install_Config.load_config(config_file)

    rc = curses.wrapper(display)

    if rc == 0:
        Install_Config.write_config(config_file, nixos_file)

    sys.exit(rc)
