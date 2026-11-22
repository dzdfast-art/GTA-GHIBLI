#!/usr/bin/env python3
"""Local-only GTA research notebook helper. Python 3.10+, standard library only."""
from __future__ import annotations
import argparse, csv, json, re, sys
from pathlib import Path
from typing import Any

EXPECTED = {
    "core": 2250,
    "graphics": 2250,
    "overlooked_details": 100,
    "overlooked_elements": 100,
}
ID_PATTERNS = {
    "core": re.compile(r"^CORE-(\d{2})\.(\d{2})$"),
    "graphics": re.compile(r"^GFX-(\d{2})\.(\d{2})$"),
    "overlooked_details": re.compile(r"^EXTRA-D-(\d{3})$"),
    "overlooked_elements": re.compile(r"^EXTRA-E-(\d{3})$"),
}
def load_db(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {"schema_version": 1, "sources": [], "registries": {k: [] for k in EXPECTED}, "notes": []}
    data = json.loads(path.read_text(encoding="utf-8"))
    data.setdefault("sources", [])
    data.setdefault("registries", {})
    for key in EXPECTED:
        data["registries"].setdefault(key, [])
    data.setdefault("notes", [])
    return data

def save_db(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_suffix(path.suffix + ".tmp")
    temp.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    temp.replace(path)

def entries_for(data: dict[str, Any], registry: str) -> list[dict[str, Any]]:
    if registry == "all":
        return [item for key in EXPECTED for item in data["registries"].get(key, [])]
    if registry not in EXPECTED:
        raise ValueError(f"Unknown registry: {registry}")
    return data["registries"].setdefault(registry, [])

def validate(data: dict[str, Any], root: Path) -> tuple[list[str], dict[str, Any]]:
    errors: list[str] = []
    summary: dict[str, Any] = {}
    source_ids = {x.get("id") for x in data.get("sources", []) if x.get("id")}
    global_ids: set[str] = set()
    for registry, required in EXPECTED.items():
        items = entries_for(data, registry)
        ids = [x.get("id", "") for x in items]
        duplicates = sorted({x for x in ids if ids.count(x) > 1})
        if duplicates:
            errors.append(f"{registry}: duplicate IDs: {', '.join(duplicates[:20])}")
        for item in items:
            item_id = item.get("id", "")
            if item_id in global_ids:
                errors.append(f"duplicate ID across registries: {item_id}")
            global_ids.add(item_id)
            if not ID_PATTERNS[registry].match(item_id):
                errors.append(f"{registry}: invalid ID {item_id!r}")
            for ref in item.get("evidence_refs", item.get("source_refs", [])):
                if ref not in source_ids:
                    errors.append(f"{item_id}: missing source reference {ref}")
            for ref in item.get("cross_refs", []):
                if ref not in global_ids and ref not in ids:
                    # second pass below allows forward references
                    pass
        expected_ids: set[str] = set()
        if registry in ("core", "graphics"):
            prefix = "CORE" if registry == "core" else "GFX"
            expected_ids = {f"{prefix}-{p:02d}.{n:02d}" for p in range(1, 51) for n in range(1, 46)}
        else:
            prefix = "EXTRA-D" if registry == "overlooked_details" else "EXTRA-E"
            expected_ids = {f"{prefix}-{n:03d}" for n in range(1, required + 1)}
        actual = set(ids)
        missing = sorted(expected_ids - actual)
        unexpected = sorted(actual - expected_ids)
        if unexpected:
            errors.append(f"{registry}: unexpected IDs: {', '.join(unexpected[:20])}")
        summary[registry] = {"required": required, "actual": len(items), "missing_count": len(missing), "missing_first": missing[:12], "missing_last": missing[-12:], "complete": len(items) == required and not missing and not unexpected}
    all_ids = {x.get("id") for key in EXPECTED for x in data["registries"].get(key, [])}
    for key in EXPECTED:
        for item in data["registries"].get(key, []):
            for ref in item.get("cross_refs", []):
                if ref not in all_ids:
                    errors.append(f"{item.get('id')}: broken cross-reference {ref}")
    for ref in data.get("project_files", []):
        if not (root / ref).exists():
            errors.append(f"missing project file reference: {ref}")
    return errors, summary

def command_init(args: argparse.Namespace) -> int:
    path = Path(args.db)
    if path.exists():
        print(f"Refusing to overwrite existing database: {path}", file=sys.stderr); return 2
    save_db(path, load_db(Path("__nonexistent__")))
    print(f"Created empty local research database: {path}")
    return 0

def command_import_json(args: argparse.Namespace) -> int:
    db_path = Path(args.db); data = load_db(db_path)
    incoming = json.loads(Path(args.input).read_text(encoding="utf-8"))
    for source in incoming.get("sources", []):
        if not any(x.get("id") == source.get("id") for x in data["sources"]):
            data["sources"].append(source)
    for registry, items in incoming.get("registries", {}).items():
        if registry not in EXPECTED:
            continue
        known = {x.get("id") for x in data["registries"][registry]}
        data["registries"][registry].extend(x for x in items if x.get("id") not in known)
    data.setdefault("notes", []).extend(incoming.get("notes", []))
    save_db(db_path, data)
    print(f"Imported source/registry records from {args.input} into {db_path}")
    return 0

def command_import_notes(args: argparse.Namespace) -> int:
    db_path = Path(args.db); data = load_db(db_path)
    p = Path(args.input)
    if p.suffix.lower() not in (".txt", ".md"):
        print("This local helper imports plain .txt/.md notes only. Convert permitted documents to text yourself.", file=sys.stderr); return 2
    content = p.read_text(encoding="utf-8", errors="replace")
    data["notes"].append({"file": p.name, "text": content, "evidence_status": "USER_NOTE_NOT_VERIFIED"})
    save_db(db_path, data)
    print(f"Imported note text ({len(content)} characters); it is not automatically promoted to a historical claim.")
    return 0

def command_search(args: argparse.Namespace) -> int:
    data = load_db(Path(args.db)); needle = args.query.casefold(); found = []
    for key in EXPECTED:
        for item in data["registries"].get(key, []):
            blob = json.dumps(item, ensure_ascii=False).casefold()
            if needle in blob:
                found.append((key, item))
    for note in data.get("notes", []):
        if needle in json.dumps(note, ensure_ascii=False).casefold():
            found.append(("notes", note))
    for key, item in found:
        print(f"[{key}] {item.get('id', item.get('file','note'))}: {item.get('finding', item.get('claim', item.get('component', item.get('text',''))))}")
    print(f"Matches: {len(found)}")
    return 0

def command_export(args: argparse.Namespace) -> int:
    data = load_db(Path(args.db)); registry = args.registry
    items = entries_for(data, registry)
    output = Path(args.output); output.parent.mkdir(parents=True, exist_ok=True)
    if args.format == "json":
        output.write_text(json.dumps({"registry": registry, "entries": items}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    else:
        fields = ["id","parent_id","topic","finding","implementation_or_verification","classification","claim","evidence_refs","scope","status","component","breakage_if_missing","verification"]
        with output.open("w", newline="", encoding="utf-8-sig") as f:
            writer = csv.DictWriter(f, fieldnames=fields, extrasaction="ignore"); writer.writeheader()
            for item in items:
                row = dict(item)
                if isinstance(row.get("evidence_refs"), list): row["evidence_refs"] = ";".join(row["evidence_refs"])
                writer.writerow(row)
    print(f"Exported {len(items)} {registry} entries to {output}")
    return 0

def command_validate(args: argparse.Namespace) -> int:
    db_path = Path(args.db); data = load_db(db_path); errors, summary = validate(data, Path(args.root))
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    if errors:
        print("\nValidation findings:", file=sys.stderr)
        for error in errors: print("- " + error, file=sys.stderr)
    complete = all(v["complete"] for v in summary.values())
    print("STRUCTURE: " + ("PASS" if not errors else "FAIL"))
    print("REQUIRED TOTAL: 4700 | ACTUAL TOTAL: " + str(sum(v["actual"] for v in summary.values())))
    print("REGISTRY COMPLETENESS: " + ("PASS" if complete else "INCOMPLETE"))
    return 0 if not errors and complete else 2

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    p = sub.add_parser("init"); p.add_argument("--db", default="research-db.json"); p.set_defaults(func=command_init)
    p = sub.add_parser("import-json"); p.add_argument("input"); p.add_argument("--db", default="research-db.json"); p.set_defaults(func=command_import_json)
    p = sub.add_parser("import-notes"); p.add_argument("input"); p.add_argument("--db", default="research-db.json"); p.set_defaults(func=command_import_notes)
    p = sub.add_parser("search"); p.add_argument("query"); p.add_argument("--db", default="research-db.json"); p.set_defaults(func=command_search)
    p = sub.add_parser("export"); p.add_argument("--registry", choices=["core","graphics","overlooked_details","overlooked_elements","all"], required=True); p.add_argument("--format", choices=["json","csv"], default="json"); p.add_argument("--output", required=True); p.add_argument("--db", default="research-db.json"); p.set_defaults(func=command_export)
    p = sub.add_parser("validate"); p.add_argument("--db", default="research-db.json"); p.add_argument("--root", default="."); p.set_defaults(func=command_validate)
    args = parser.parse_args()
    try: return args.func(args)
    except (OSError, json.JSONDecodeError, ValueError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr); return 2
if __name__ == "__main__": raise SystemExit(main())
