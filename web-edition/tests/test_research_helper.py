"""CI tests for the local-only research helper and current source registry."""
from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HELPER = ROOT / "web-edition" / "tools" / "research_helper.py"
REGISTRY = ROOT / "docs" / "research" / "gtasa_registry.json"


class ResearchHelperCliTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.db = Path(self.temp_dir.name) / "research-db.json"

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def run_cli(self, *args: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(HELPER), *args],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

    def test_init_import_validate_reports_honest_partial_counts(self) -> None:
        self.assertTrue(HELPER.is_file())
        self.assertTrue(REGISTRY.is_file())
        initialized = self.run_cli("init", "--db", str(self.db))
        self.assertEqual(initialized.returncode, 0, initialized.stderr)

        imported = self.run_cli("import-json", str(REGISTRY), "--db", str(self.db))
        self.assertEqual(imported.returncode, 0, imported.stderr)

        validated = self.run_cli("validate", "--db", str(self.db), "--root", str(ROOT))
        self.assertEqual(validated.returncode, 2)
        self.assertIn('"actual": 50', validated.stdout)
        self.assertIn("STRUCTURE: PASS", validated.stdout)
        self.assertIn("REQUIRED TOTAL: 4700 | ACTUAL TOTAL: 140", validated.stdout)
        self.assertIn("REGISTRY COMPLETENESS: INCOMPLETE", validated.stdout)

    def test_search_and_json_csv_export(self) -> None:
        self.run_cli("init", "--db", str(self.db))
        imported = self.run_cli("import-json", str(REGISTRY), "--db", str(self.db))
        self.assertEqual(imported.returncode, 0, imported.stderr)

        searched = self.run_cli("search", "waypoint", "--db", str(self.db))
        self.assertEqual(searched.returncode, 0, searched.stderr)
        self.assertIn("EXTRA-D-002", searched.stdout)

        json_out = Path(self.temp_dir.name) / "core.json"
        exported_json = self.run_cli(
            "export", "--registry", "core", "--format", "json",
            "--output", str(json_out), "--db", str(self.db)
        )
        self.assertEqual(exported_json.returncode, 0, exported_json.stderr)
        parsed = json.loads(json_out.read_text(encoding="utf-8"))
        self.assertEqual(len(parsed["entries"]), 50)

        csv_out = Path(self.temp_dir.name) / "extras.csv"
        exported_csv = self.run_cli(
            "export", "--registry", "overlooked_details", "--format", "csv",
            "--output", str(csv_out), "--db", str(self.db)
        )
        self.assertEqual(exported_csv.returncode, 0, exported_csv.stderr)
        rows = csv_out.read_text(encoding="utf-8-sig").splitlines()
        self.assertEqual(len(rows), 21)  # header + 20 current entries

    def test_local_notes_are_marked_unverified(self) -> None:
        self.run_cli("init", "--db", str(self.db))
        note = Path(self.temp_dir.name) / "sample.md"
        note.write_text("Unverified source note for later review.\n", encoding="utf-8")
        imported = self.run_cli("import-notes", str(note), "--db", str(self.db))
        self.assertEqual(imported.returncode, 0, imported.stderr)
        saved = json.loads(self.db.read_text(encoding="utf-8"))
        self.assertEqual(saved["notes"][0]["evidence_status"], "USER_NOTE_NOT_VERIFIED")


if __name__ == "__main__":
    unittest.main(verbosity=2)
