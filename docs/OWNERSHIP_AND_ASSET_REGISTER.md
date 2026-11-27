# GTA GHIBLI — Ownership Evidence and Asset Register

Use this register to document provenance before any asset is included in a public release.

## Project identity

- Project name: GTA GHIBLI
- Public repository: https://github.com/dzdfast-art/GTA-GHIBLI
- Maintainer attribution: `dzdfast-art`
- Rights notice: [../COPYRIGHT.md](../COPYRIGHT.md)
- Repository visibility: Public (intentionally retained)

## Asset provenance register

Add one row for every externally sourced, commissioned, generated, or contributor-created asset. Do not mark an asset as cleared until its terms have been checked.

| Asset / file path | Type | Creator / source | Creation or acquisition date | Licence / written permission | Evidence link or record | Release cleared? |
|---|---|---|---|---|---|---|
| `web-edition/scripts/world/world_builder.gd` — Harbor Market noticeboard | Procedural 3D scene geometry and text labels | Original in-repository Godot code; no external model or texture imported | 2026-11-26 | Original project source; maintainer review required before release | Mission 002 implementation commit and source script | No |
| `web-edition/scripts/world/world_builder.gd` — Harbor Market interior, counter, shelves, crates and wall/floor collision | Procedural 3D environment geometry and text labels | Original in-repository Godot code; primitive meshes and materials only; no external model or texture imported | 2026-11-27 | Original project source; maintainer review required before release | Mission 003 implementation branch and source script | No |
| `web-edition/scripts/ui/game_hud.gd` — Harbor Market buy/sell panel | In-game interface controls and labels | Original in-repository Godot code; no external UI asset imported | 2026-11-27 | Original project source; maintainer review required before release | Mission 003 implementation branch and source script | No |
| Example: `assets/characters/hero.glb` | 3D model | Project creator / named artist | YYYY-MM-DD | Original / contract / licence name | Commit, source file, contract reference | No |

## Evidence to preserve

- Original editable source files (not only exported PNG, GLB, WAV or OGG files).
- Dated sketches, story drafts, scripts, design documents and reference boards.
- Git commits and release tags showing the development timeline.
- Contracts, invoices, written permissions and contributor agreements.
- The exact source URL and licence version for every third-party dependency or asset.
- AI-generation records and the tool/service terms applicable on the generation date, where relevant.

## Review checklist before release

- [ ] Every included asset has an identified creator or source.
- [ ] Every third-party asset has a recorded licence or written permission.
- [ ] No extracted GTA San Andreas assets, maps, audio, models, scripts or branding are included.
- [ ] Contributor permissions and attribution requirements are documented.
- [ ] The release contains the current [copyright notice](../COPYRIGHT.md).
- [ ] The project maintainer has retained a dated backup of source and evidence.

## Important

This register is an internal evidence-management aid, not proof of ownership by itself and not a substitute for contracts, official deposits, trademark registration, or legal advice. Do not enter passwords, private keys, identity numbers, or other secrets here.
