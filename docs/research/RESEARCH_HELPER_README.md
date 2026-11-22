# GTA GHIBLI — Local Research Registry Helper

## Purpose

`web-edition/tools/research_helper.py` is a **local-only** helper for working with the San Andreas research registry and user-supplied notes. It can initialize a database, import the machine-readable registry, preserve .txt/.md notes, search local records, export registry data to JSON/CSV, and audit fixed ID/count requirements.

It does **not** access the internet, search Rockstar archives, inspect a live game, identify the exact PS2 executable build, or guarantee exhaustive historical coverage. Imported personal notes remain marked `USER_NOTE_NOT_VERIFIED` until a researcher independently checks and links evidence.

## Requirements

- Windows 10/11 or another OS with a terminal.
- Python 3.10 or newer.
- No pip packages or credentials are required.

Check Python from Windows Command Prompt:

```cmd
py --version
```

If the command is unavailable, install Python 3.10+ from the official Python website and enable the Python launcher. The helper uses only the Python standard library.

## Windows CMD — one complete workflow

Run these commands from the repository root. Replace the folder path with the actual location on your computer.

```cmd
cd /d "C:\Games\GTA-GHIBLI"
py --version
py "web-edition\tools\research_helper.py" init --db "docs\research\local-research-db.json"
py "web-edition\tools\research_helper.py" import-json "docs\research\gtasa_registry.json" --db "docs\research\local-research-db.json"
py "web-edition\tools\research_helper.py" import-notes "docs\research\sample_source_note.md" --db "docs\research\local-research-db.json"
py "web-edition\tools\research_helper.py" search "waypoint" --db "docs\research\local-research-db.json"
py "web-edition\tools\research_helper.py" export --registry core --format csv --output "docs\research\core-export.csv" --db "docs\research\local-research-db.json"
py "web-edition\tools\research_helper.py" export --registry all --format json --output "docs\research\all-registries-export.json" --db "docs\research\local-research-db.json"
py "web-edition\tools\research_helper.py" validate --db "docs\research\local-research-db.json" --root "."
echo Validator exit code: %ERRORLEVEL%
```

The last command is **expected to return exit code 2** while the four fixed registries are incomplete. That code means the structural audit ran and the required 4,700-entry registry is not complete; it is not a claim that 4,700 entries exist.

## Commands

### Initialize a database

```cmd
py "web-edition\tools\research_helper.py" init --db "research-db.json"
```

The helper refuses to overwrite an existing database.

### Import research registry

```cmd
py "web-edition\tools\research_helper.py" import-json "docs\research\gtasa_registry.json" --db "research-db.json"
```

Existing source and entry IDs are not duplicated during import. The current source registry and partial entries are imported as data, not magically upgraded to verified evidence.

### Import local notes

```cmd
py "web-edition\tools\research_helper.py" import-notes "docs\research\sample_source_note.md" --db "research-db.json"
```

Only UTF-8 .txt and .md files are accepted. PDF, DOCX, scanned image and archive parsing are not implemented. Convert legally accessible documents to text separately, keep page references, and label the result as unverified until checked.

### Search local records

```cmd
py "web-edition\tools\research_helper.py" search "RenderWare" --db "research-db.json"
```

Search is a local text match over imported registry records and notes. It is not a web search.

### Export JSON or CSV

```cmd
py "web-edition\tools\research_helper.py" export --registry graphics --format json --output "graphics.json" --db "research-db.json"
py "web-edition\tools\research_helper.py" export --registry overlooked_details --format csv --output "details.csv" --db "research-db.json"
```

Use `--registry core|graphics|overlooked_details|overlooked_elements|all`.

### Validate counts and references

```cmd
py "web-edition\tools\research_helper.py" validate --db "research-db.json" --root "."
```

The validator checks syntax of IDs, expected ID ranges, duplicates, source references, cross-references and optional project file references. It cannot prove historical accuracy, resolve source conflicts, identify semantic duplicates or verify that a source actually supports a claim. Those require human/source review.

## Current expected audit

The committed registry presently has:
- CORE: 50 / 2,250 elements.
- GFX: 50 / 2,250 elements.
- EXTRA-D: 20 / 100.
- EXTRA-E: 20 / 100.
- Combined fixed-registry total: 140 / 4,700.
- Physics: 19 proposed systems.
- Character records: 4 PS2-manual-listed names; not a full census.

The correct validator result is therefore **STRUCTURE: PASS** and **REGISTRY COMPLETENESS: INCOMPLETE**, with exit code 2.

## Research quality rules

1. Use a unique source ID for each reference (for example `SRC-003`).
2. Record title, author/publisher, date, exact version/build scope, URL, page/timestamp and access status.
3. Separate [CONFIRMED], [OBSERVED], [SECONDARY], [INFERRED], [PROPOSED] and [UNKNOWN].
4. Do not label PC/mobile/remaster behavior as original 2004 PS2 evidence without independent version confirmation.
5. Never fill a missing ID with a heading, duplicate, guess or unsupported claim.
6. Keep Rockstar proprietary assets out of GTA GHIBLI; research the design principles and author original/licensed replacements.
