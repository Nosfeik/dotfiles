#!/usr/bin/env python3
"""Prepare the user-owned Spotify copy. Default: read-only plan, no downloads."""
import argparse
import configparser
import hashlib
import os
from pathlib import Path
import platform
import shutil
import subprocess
import tempfile

from restore import check_parents


def digest(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def setup(home, source=Path("/opt/spotify"), apply=False, refresh=False):
    target = home / ".local/share/spotify"
    cli = home / ".local/share/spicetify-cli/spicetify"
    prefs = home / ".config/spotify/prefs"
    config = home / ".config/spicetify/config-xpui.ini"
    preset = home / ".config/spicetify/green-black.ini"
    for relative in (".local/share/spotify/placeholder", ".local/share/spicetify-cli/spicetify",
                     ".config/spicetify/config-xpui.ini", ".config/spotify/prefs",
                     ".local/state/dotfiles-backups/placeholder"):
        check_parents(home, Path(relative))
    print(f"{'APPLY' if apply else 'PLAN'}: {source} → {target}")
    print(f"Preferences: {preset}; runtime config: {config}")
    print("Spicetify 2.46.2; local backup; no sudo and no automatic Spotify restart.")
    if not apply:
        if refresh:
            print("Archive the previous client and rebuild from the installed Spotify package.")
        return
    if not (source / "spotify").is_file() or not (source / "Apps/xpui.spa").is_file():
        raise ValueError("Install the unmodified Spotify package in /opt/spotify first")
    if not prefs.is_file():
        raise ValueError("Open the packaged Spotify once, log in and close it before setup")
    if not preset.is_file():
        raise ValueError("Restore configs first: green-black.ini is missing")
    if config.is_symlink():
        raise ValueError(f"Review the runtime config symlink: {config}")
    if not cli.is_file() or not os.access(cli, os.X_OK):
        raise ValueError("Run scripts/manual-components.sh spicetify --apply first")
    if subprocess.check_output([str(cli), "--version"], text=True).strip() != "2.46.2":
        raise ValueError("Review compatibility before using a different Spicetify version")
    running = subprocess.run(["pgrep", "-u", str(os.getuid()), "-x", "spotify"], capture_output=True)
    if running.returncode != 1:
        raise ValueError("Close Spotify first (or check pgrep if process inspection failed)")
    settings = configparser.ConfigParser(interpolation=None)
    settings.read(preset)
    if set(settings.sections()) != {"Setting", "AdditionalOptions", "Preprocesses", "Patch"}:
        raise ValueError("Unexpected preset sections")
    if settings.items("Patch") or any(key in settings["Setting"] for key in ("spotify_path", "prefs_path")):
        raise ValueError("Keep machine paths and patches out of the declarative preset")
    theme = home / ".config/spicetify/Themes" / settings["Setting"]["current_theme"]
    for name in ("color.ini", "user.css"):
        if not (theme / name).is_file():
            raise ValueError(f"Missing theme file: {theme / name}")
    if target.exists() and not refresh:
        if not (target / "spotify").is_file() or digest(target / "spotify") != digest(source / "spotify"):
            raise ValueError("Spotify package changed; review compatibility, then use --refresh-client --apply")
    backup_base = home / ".local/state/dotfiles-backups"
    backup_base.mkdir(parents=True, exist_ok=True, mode=0o700)
    backup = Path(tempfile.mkdtemp(prefix="spotify-", dir=backup_base))
    if config.exists():
        shutil.copy2(config, backup / "config-xpui.ini")
    print(f"Backup: {backup}")
    if not target.exists() or refresh:
        target.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(prefix=".spotify-setup-", dir=target.parent) as tmp:
            staged = Path(tmp) / "spotify"
            shutil.copytree(source, staged)
            if target.exists():
                target.rename(backup / "spotify")
            staged.rename(target)
    args = [str(cli), "config", "spotify_path", str(target), "prefs_path", str(prefs)]
    for section in ("Setting", "AdditionalOptions", "Preprocesses"):
        for key, value in settings.items(section):
            args.extend((key, value))
    subprocess.run(args, check=True)
    # A pristine copy has .spa files; an applied copy has extracted Apps/xpui.
    commands = ["backup", "apply"] if (target / "Apps/xpui.spa").exists() else ["apply"]
    subprocess.run([str(cli), "-n", *commands], check=True)
    print("GreenBlack prepared. Launch Spotify from ~/.local/bin/spotify or the application menu.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--refresh-client", action="store_true", help="Archive and rebuild the local client after a package update")
    args = parser.parse_args()
    try:
        home = Path.home()
        if args.apply:
            if os.geteuid() == 0 or platform.freedesktop_os_release().get("ID") != "arch":
                raise ValueError("Run as the desktop user on Arch, without sudo")
            for key, suffix in (("XDG_CONFIG_HOME", ".config"), ("XDG_DATA_HOME", ".local/share"),
                                ("XDG_STATE_HOME", ".local/state")):
                if os.environ.get(key) and Path(os.environ[key]) != home / suffix:
                    raise ValueError(f"Review nonstandard {key} before setup")
        setup(home, apply=args.apply, refresh=args.refresh_client)
    except (OSError, ValueError, KeyError, configparser.Error, subprocess.CalledProcessError) as error:
        parser.exit(1, f"Spotify setup stopped: {error}\n")


if __name__ == "__main__":
    main()
