"""CLI contract tests, with no live herdr session or machine-local config.

Run: python3 -m unittest discover -s tests -v
"""

import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]


class SessionizerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name).resolve()
        self.bin = self.base / "bin"
        self.bin.mkdir()
        self.root = self.base / "project with spaces"
        self.root.mkdir()
        self.home = self.base / "home"
        self.home.mkdir()
        self.log = self.base / "calls.jsonl"
        self.snapshot = self.base / "snapshot.json"
        self.set_snapshot([], [])
        self.script = self.bin / "herdr-sessionizer"
        shutil.copy2(REPO / "bin/.local/bin/herdr-sessionizer", self.script)
        self.env = dict(os.environ, HOME=str(self.home),
                        PATH=f"{self.bin}:{os.environ['PATH']}",
                        TEST_LOG=str(self.log), TEST_SNAPSHOT=str(self.snapshot),
                        TEST_CANDIDATES=str(self.base / "candidates"))
        self.executable("herdr", '''
import json, os, sys
from pathlib import Path
args = sys.argv[1:]
log = Path(os.environ["TEST_LOG"])
with log.open("a") as f:
    f.write(json.dumps(args) + "\\n")
if os.environ.get("TEST_API_FAIL"):
    sys.exit(1)
kind = args[:2]
if kind == ["api", "snapshot"]:
    print(Path(os.environ["TEST_SNAPSHOT"]).read_text())
    sys.exit(0)
n = len(log.read_text().splitlines())
if kind == ["workspace", "create"]:
    result = {"workspace": {"workspace_id": "new"},
              "tab": {"tab_id": "edit-tab"}, "root_pane": {"pane_id": "edit-pane"}}
elif kind == ["tab", "create"]:
    label = args[args.index("--label") + 1]
    result = {"tab": {"tab_id": label + "-tab"}, "root_pane": {"pane_id": label + "-pane"}}
elif kind == ["pane", "split"]:
    result = {"pane": {"pane_id": "split-" + str(n)}}
else:
    result = {}
print(json.dumps({"result": result}))
''')
        self.executable("fzf", '''
import os, sys
from pathlib import Path
candidates = sys.stdin.read()
Path(os.environ["TEST_CANDIDATES"]).write_text(candidates)
if "TEST_PICK" in os.environ:
    print(os.environ["TEST_PICK"])
sys.exit(int(os.environ.get("TEST_FZF_EXIT", "0")))
''')

    def executable(self, name, content):
        path = self.bin / name
        path.write_text(f"#!{sys.executable}\n" + content)
        path.chmod(0o755)

    def set_snapshot(self, workspaces, panes):
        self.snapshot.write_text(json.dumps({"id": "test", "result": {
            "snapshot": {"workspaces": workspaces, "panes": panes}}}))

    def run_script(self, *args, code=0):
        result = subprocess.run([str(self.script), *map(str, args)], env=self.env,
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, code, result.stdout + result.stderr)
        if code == 0:
            self.assertEqual(result.stderr, "")
        return result

    def calls(self, *prefix):
        calls = [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []
        return [call for call in calls if call[:len(prefix)] == list(prefix)]

    def test_non_repo_build_has_explicit_cwds_and_final_focus(self):
        self.run_script(self.root)
        creates = self.calls("workspace", "create") + self.calls("tab", "create") + self.calls("pane", "split")
        self.assertEqual(len(creates), 6)
        for call in creates:
            self.assertEqual(call[call.index("--cwd") + 1], str(self.root))
            self.assertIn("--no-focus", call)
        self.assertEqual(self.calls("pane", "run"), [["pane", "run", "edit-pane", "nvim"]])
        self.assertEqual(self.calls()[-2:], [["workspace", "focus", "new"], ["tab", "focus", "edit-tab"]])

    def test_git_subdirectory_is_not_promoted_to_repo_root(self):
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)
        subdir = self.root / "nested"
        subdir.mkdir()
        link = self.base / "link"
        link.symlink_to(subdir)
        self.run_script(link)
        call = self.calls("workspace", "create")[0]
        self.assertEqual(call[call.index("--cwd") + 1], str(subdir))
        self.assertEqual(call[call.index("--label") + 1], "nested")

    def test_reuse_exits_without_building_or_restarting_commands(self):
        for no_focus in (False, True):
            with self.subTest(no_focus=no_focus):
                self.log.unlink(missing_ok=True)
                self.set_snapshot([{"workspace_id": "existing", "label": self.root.name}],
                                  [{"workspace_id": "existing", "cwd": str(self.root / "nested")}])
                result = self.run_script(self.root, *(["--no-focus"] if no_focus else []))
                self.assertIn("already open", result.stdout)
                expected = [["api", "snapshot"]]
                if not no_focus:
                    expected.append(["workspace", "focus", "existing"])
                self.assertEqual(self.calls(), expected)

    def test_basename_collision_and_path_prefix_do_not_reuse(self):
        self.set_snapshot([
            {"workspace_id": "other", "label": self.root.name},
            {"workspace_id": "prefix", "label": self.root.name},
            {"workspace_id": "renamed", "label": "different"}], [
            {"workspace_id": "other", "cwd": str(self.base / "elsewhere" / self.root.name)},
            {"workspace_id": "prefix", "cwd": str(self.root) + "-other"},
            {"workspace_id": "renamed", "cwd": str(self.root)}])
        self.run_script(self.root)
        self.assertEqual(len(self.calls("workspace", "create")), 1)

    def test_agent_count_server_override_and_no_focus(self):
        self.run_script(self.root, "--agents", "1", "--server", "printf 'hello world'", "--no-focus")
        self.assertEqual(len(self.calls("pane", "split")), 1)
        self.assertEqual(self.calls("pane", "run")[-1][-1], "printf 'hello world'")
        self.assertFalse(self.calls("workspace", "focus"))
        self.assertFalse(self.calls("tab", "focus"))

    def test_server_detection_and_explicit_skip(self):
        fixtures = [
            ({"package.json": '{"scripts":{"dev":"vite"}}', "pnpm-lock.yaml": ""}, "pnpm dev"),
            ({"justfile": "dev:\n  echo dev\n", "package.json": '{"scripts":{"dev":"vite"}}'}, "just dev"),
            ({"mix.exs": "{:phoenix, \"~> 1.0\"}"}, "mix phx.server"),
            ({"go.mod": "module example", "cmd/one/main.go": "package main"}, "go run ./cmd/one"),
            ({"go.mod": "module example", "cmd/one/main.go": "", "cmd/two/main.go": ""}, None),
        ]
        for files, expected in fixtures:
            with self.subTest(files=files):
                self.log.unlink(missing_ok=True)
                shutil.rmtree(self.root)
                self.root.mkdir()
                for name, contents in files.items():
                    path = self.root / name
                    path.parent.mkdir(parents=True, exist_ok=True)
                    path.write_text(contents)
                self.run_script(self.root)
                commands = [call[-1] for call in self.calls("pane", "run")]
                self.assertEqual(commands, ["nvim"] + ([expected] if expected else []))
        (self.root / "manage.py").touch()
        self.log.unlink()
        self.run_script(self.root, "--server", "")
        self.assertEqual(len(self.calls("pane", "run")), 1)

    def test_picker_defaults_and_cancellation(self):
        child = self.home / "one"
        child.mkdir()
        (child / "too deep").mkdir()
        for rc in (0, 1, 130):
            with self.subTest(rc=rc):
                self.env["TEST_FZF_EXIT"] = str(rc)
                result = self.run_script()
                self.assertEqual(result.stdout, "")
                self.assertFalse(self.calls())
                candidates = (self.base / "candidates").read_text().splitlines()
                self.assertIn(str(child), candidates)
                self.assertTrue(all(Path(path).parent == self.home for path in candidates))
        self.env["TEST_FZF_EXIT"] = "2"
        self.run_script(code=2)
        self.assertFalse(self.calls())

    def test_picker_config_and_selection(self):
        nested = self.root / "nested"
        nested.mkdir()
        (self.bin / "sessionizer.conf").write_text(
            f"SESSIONIZER_DIRS=('{self.root}')\nMIN_DEPTH=1\nMAX_DEPTH=1\n")
        self.env["TEST_PICK"] = str(nested)
        self.run_script("--no-focus")
        self.assertEqual((self.base / "candidates").read_text().splitlines(), [str(nested)])
        self.assertIn(str(nested), self.calls("workspace", "create")[0])

    def test_invalid_input_and_api_failure_do_not_create(self):
        for args, code in [([self.root, "--agents", "0"], 2),
                           ([self.root, "--agents", "nope"], 2),
                           ([self.root, "--wat"], 2),
                           ([self.root, self.root], 2),
                           ([self.root / "missing"], 1)]:
            with self.subTest(args=args):
                self.run_script(*args, code=code)
                self.assertFalse(self.calls())
        self.env["TEST_API_FAIL"] = "1"
        self.run_script(self.root, code=1)
        self.assertFalse(self.calls("workspace", "create"))


if __name__ == "__main__":
    unittest.main()
