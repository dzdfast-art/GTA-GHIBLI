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
| Example: `assets/characters/hero.glb` | 3D model | Project creator / named artist | YYYY-MM-DD | Original / contract / licence name | Commit, source file, contract reference | No |
| `assets/ui/gta_ghibli_icon.svg` | Application icon (SVG) | Original project-authored vector artwork | 2026-11-20 | Original project asset | Repair branch commit `9d14c8119c01d04e83cf6094fa942d073267ddc1` | Pending final release review |
| `assets/environment/props/public_drinking_fountain.obj` + `.mtl` | Original low-poly 3D world prop | Project-authored geometry and material definitions | 2026-11-20 | Original project asset; no external source | Commit on `fix/comprehensive-stability-2026-11-20`; instantiated in Harbor City and covered by `tests/public_drinking_fountain_test.gd` | Pending final release review |
| `assets/environment/props/vehicle_service_garage.obj` + `.mtl` | Original six-material low-poly automotive workshop with service lift and tool equipment | Project-authored geometry and material definitions | 2026-11-20 | Original project asset; no external source | Loaded by `scenes/world/vehicle_service_garage.tscn` in Amber Valley; covered by `tests/vehicle_service_garage_test.gd` and world-region integration checks | Pending final release review |

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

| `assets/environment/props/seafood_display.obj` + `.mtl` | Original low-poly fish, ice, trays and weighing-scale display mesh | Project-authored geometry and material definitions | 2026-11-20 | Original project asset; no external source | Loaded by `scenes/world/seafood_market.tscn` in Sapphire Coast; tested by `tests/seafood_market_test.gd` | Pending final release review |
| `assets/environment/props/coastal_lighthouse.obj` + `.mtl` + two local SVG maps | Original 19.8 m seven-material lighthouse with brass lantern, balcony and copper roof | Project-authored geometry, materials and vector textures | 2026-11-20 | Original project asset; no external source | Loaded by `scenes/world/coastal_lighthouse.tscn` in Sapphire Coast; tested by `tests/coastal_lighthouse_test.gd` and `tests/open_world_regions_test.gd` | Pending final release review |


## 2026-11-21 asset-register review

No new binary, model, texture, sound or other game asset was added in this save/navigation/Web reliability pass. The changes are scripts and regression tests only, so no new asset provenance row is required. Existing assets remain subject to the release-clearance review above; no licence or ownership status is upgraded by this code-only change.


## Verification note — 2026-11-21

The latest code-only reliability changes add no assets. Godot validation #798 and Android Debug APK #561 passed on code head ab9e707; the later 1c8da7 change is documentation-only. Existing asset rows remain pending final release review, and no new asset licence/ownership clearance is implied.


## 2026-11-22 provenance update

No new models, textures, audio clips, fonts, icons or other binary assets were added in the side-activity save-recovery pass. Changes are limited to scripts, tests and documentation. Existing asset provenance and release-clearance states are unchanged; no licence status is upgraded by this code-only change.
