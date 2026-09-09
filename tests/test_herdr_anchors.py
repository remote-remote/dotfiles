"""Regression coverage for manual snapshot fallbacks and split anchor priority."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]


class AnchorTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name).resolve()
        self.root = self.base / "project's root"
        self.nested = self.root / "nested"
        self.nested.mkdir(parents=True)
        self.bin = self.base / "bin"
        self.bin.mkdir()
        self.anchors = self.base / "anchors"
        self.snapshot = self.base / "snapshot.json"
        self.log = self.base / "calls.jsonl"
        self.snapshot.write_text(json.dumps({"id": "test", "result": {"snapshot": {
            "workspaces": [{"workspace_id": "focused", "focused": True}],
            "panes": [{"pane_id": "focused:pane", "workspace_id": "focused",
                       "focused": True, "cwd": str(self.nested)}]}}}))
        self.env = {k: v for k, v in os.environ.items() if not k.startswith("HERDR_")}
        self.env.update(PATH=f"{self.bin}:{os.environ['PATH']}",
                        HERDR_ANCHOR_DIR=str(self.anchors),
                        TEST_LOG=str(self.log), TEST_SNAPSHOT=str(self.snapshot))
        fake = self.bin / "herdr"
        fake.write_text(f"#!{sys.executable}\n" + '''
import json, os, sys
from pathlib import Path
args = sys.argv[1:]
with Path(os.environ["TEST_LOG"]).open("a") as f:
    f.write(json.dumps(args) + "\\n")
if args == ["api", "snapshot"]:
    if os.environ.get("TEST_API_FAIL"):
        sys.exit(1)
    print(Path(os.environ["TEST_SNAPSHOT"]).read_text())
else:
    print(json.dumps({"result": {}}))
''')
        fake.chmod(0o755)

    def run_script(self, script, *args, code=0):
        result = subprocess.run([str(REPO / "bin/.local/bin" / script), *map(str, args)],
                                env=self.env, cwd=self.nested, capture_output=True, text=True)
        self.assertEqual(result.returncode, code, result.stdout + result.stderr)
        if code == 0:
            self.assertEqual(result.stderr, "")
        return result

    def calls(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []

    def test_manual_split_uses_snapshot_and_git_root(self):
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)
        self.run_script("herdr-split", "right")
        self.assertEqual(self.calls(), [["api", "snapshot"], [
            "pane", "split", "focused:pane", "--cwd", str(self.root), "--direction", "right", "--focus"]])

    def test_keybinding_context_and_pin_take_priority(self):
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)
        self.anchors.mkdir()
        (self.anchors / "binding").write_text(str(self.base) + "\n")
        self.env.update(HERDR_ACTIVE_WORKSPACE_ID="binding", HERDR_ACTIVE_PANE_ID="binding:pane",
                        HERDR_ACTIVE_PANE_CWD=str(self.nested))
        self.run_script("herdr-split", "down")
        self.assertEqual(self.calls(), [["pane", "split", "binding:pane", "--cwd", str(self.base),
                                       "--direction", "down", "--focus"]])

    def test_non_git_split_keeps_stock_cwd_behavior(self):
        self.run_script("herdr-split", "right")
        self.assertEqual(self.calls()[-1], ["pane", "split", "focused:pane", "--direction", "right", "--focus"])

    def test_manual_anchor_pin_show_clear_uses_snapshot(self):
        self.run_script("herdr-anchor")
        self.assertEqual((self.anchors / "focused").read_text().strip(), str(self.nested))
        result = self.run_script("herdr-anchor", "--show")
        self.assertEqual(result.stdout.strip(), str(self.nested))
        self.run_script("herdr-anchor", "--clear")
        self.assertFalse((self.anchors / "focused").exists())
        self.assertEqual(self.calls(), [["api", "snapshot"]] * 3)

    def test_anchor_prefers_active_then_caller_workspace(self):
        self.env.update(HERDR_ACTIVE_WORKSPACE_ID="binding", HERDR_WORKSPACE_ID="caller")
        self.run_script("herdr-anchor", self.root)
        self.assertTrue((self.anchors / "binding").exists())
        del self.env["HERDR_ACTIVE_WORKSPACE_ID"]
        self.run_script("herdr-anchor", self.root)
        self.assertTrue((self.anchors / "caller").exists())
        self.assertFalse(self.calls())

    def test_failed_snapshot_cannot_split_or_write_a_pin(self):
        self.env["TEST_API_FAIL"] = "1"
        self.run_script("herdr-split", "right", code=1)
        self.run_script("herdr-anchor", code=1)
        self.assertEqual(self.calls(), [["api", "snapshot"]] * 2)
        self.assertFalse(self.anchors.exists())


if __name__ == "__main__":
    unittest.main()
