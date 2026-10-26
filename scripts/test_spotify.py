"""Offline bootstrap tests; no real Spotify, HOME or system app is changed."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import tempfile
import time
from types import SimpleNamespace
import unittest
from unittest.mock import patch

REPO = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location("spotify_bootstrap", REPO / "scripts/bootstrap-spotify.py")
bootstrap = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bootstrap)


class SpotifySetup(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name)
        self.home = self.base / "home with spaces"
        self.home.mkdir()
        self.source = self.base / "system-spotify"
        (self.source / "Apps").mkdir(parents=True)
        (self.source / "spotify").write_text("binary-original")
        (self.source / "Apps/xpui.spa").write_text("archive-original")
        self.silence = contextlib.redirect_stdout(io.StringIO())
        self.silence.__enter__()
        self.addCleanup(self.silence.__exit__, None, None, None)
        self.calls = []

    def prepare(self):
        shutil.copytree(REPO / ".config/spicetify", self.home / ".config/spicetify")
        prefs = self.home / ".config/spotify/prefs"
        prefs.parent.mkdir()
        prefs.write_text("private-session-fixture")
        cli = self.home / ".local/share/spicetify-cli/spicetify"
        cli.parent.mkdir(parents=True)
        cli.write_text("fixture")
        cli.chmod(0o755)

    def fake_run(self, args, **kwargs):
        self.calls.append(args)
        if args[0] == "pgrep":
            return SimpleNamespace(returncode=1)
        if "config" in args:
            (self.home / ".config/spicetify/config-xpui.ini").write_text("generated-state")
        elif args[-1] == "apply":
            apps = self.home / ".local/share/spotify/Apps"
            (apps / "xpui.spa").unlink(missing_ok=True)
            (apps / "xpui").mkdir(exist_ok=True)
        return SimpleNamespace(returncode=0)

    def run_setup(self, **kwargs):
        with patch.object(bootstrap.subprocess, "check_output", return_value="2.46.2\n"), \
                patch.object(bootstrap.subprocess, "run", side_effect=self.fake_run):
            bootstrap.setup(self.home, source=self.source, apply=True, **kwargs)

    def test_plan_is_read_only_without_prerequisites(self):
        bootstrap.setup(self.home, source=self.source)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_fresh_copy_and_reapply_preserve_package_and_session(self):
        self.prepare()
        self.run_setup()
        self.assertEqual(self.calls[-1][1:], ["-n", "backup", "apply"])
        config_args = self.calls[-2]
        self.assertEqual(config_args[config_args.index("spotify_path") + 1], str(self.home / ".local/share/spotify"))
        self.assertEqual(config_args[config_args.index("prefs_path") + 1], str(self.home / ".config/spotify/prefs"))
        self.run_setup()
        self.assertEqual(self.calls[-1][1:], ["-n", "apply"])
        self.assertEqual((self.source / "Apps/xpui.spa").read_text(), "archive-original")
        self.assertEqual((self.home / ".config/spotify/prefs").read_text(), "private-session-fixture")

    def test_running_spotify_stops_before_copy(self):
        self.prepare()
        with patch.object(bootstrap.subprocess, "check_output", return_value="2.46.2\n"), \
                patch.object(bootstrap.subprocess, "run", return_value=SimpleNamespace(returncode=0)), \
                self.assertRaisesRegex(ValueError, "Close Spotify"):
            bootstrap.setup(self.home, source=self.source, apply=True)
        self.assertFalse((self.home / ".local/share/spotify").exists())
        self.assertFalse((self.home / ".local/state").exists())

    def test_changed_package_requires_refresh_and_archives_previous_client(self):
        self.prepare()
        self.run_setup()
        (self.source / "spotify").write_text("binary-updated")
        with self.assertRaisesRegex(ValueError, "package changed"):
            self.run_setup()
        self.run_setup(refresh=True)
        self.assertEqual(self.calls[-1][1:], ["-n", "backup", "apply"])
        backups = list((self.home / ".local/state/dotfiles-backups").glob("spotify-*/spotify/spotify"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), "binary-original")
        self.assertEqual((self.home / ".local/share/spotify/spotify").read_text(), "binary-updated")

    def test_target_symlink_is_rejected_without_touching_package(self):
        self.prepare()
        (self.home / ".local/share/spotify").symlink_to(self.source)
        with self.assertRaisesRegex(ValueError, "real directory"):
            self.run_setup()
        self.assertEqual((self.source / "Apps/xpui.spa").read_text(), "archive-original")

    def test_desktop_launcher_expands_home_and_preserves_uris(self):
        try:
            import gi
            gi.require_version("Gio", "2.0")
            from gi.repository import Gio
        except ImportError:
            self.skipTest("Gio/PyGObject not installed")
        # Launch a fixture executable, never the real Spotify wrapper.
        wrapper = self.home / ".local/bin/spotify"
        wrapper.parent.mkdir(parents=True)
        output = self.base / "arguments.json"
        wrapper.write_text('#!/usr/bin/python3\nimport json, os, sys\n'
                           'with open(os.environ["DOTFILES_TEST_OUTPUT"], "w") as f: json.dump(sys.argv[1:], f)\n')
        wrapper.chmod(0o755)
        app = Gio.DesktopAppInfo.new_from_filename(str(REPO / ".local/share/applications/spotify.desktop"))
        self.assertIsNotNone(app)
        context = Gio.AppLaunchContext()
        context.setenv("HOME", str(self.home))
        context.setenv("DOTFILES_TEST_OUTPUT", str(output))
        uris = ["spotify:track:test123", "spotify:album:example"]
        app.launch_uris(uris, context)
        for _ in range(100):
            if output.exists():
                break
            time.sleep(0.02)
        self.assertEqual(json.loads(output.read_text()), uris)


if __name__ == "__main__":
    unittest.main()
