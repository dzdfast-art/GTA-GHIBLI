# GTA GHIBLI

> **© 2026 GTA GHIBLI — All rights reserved.** This is an original project under development. No separate open-source or commercial reuse licence is granted. The repository remains public; GitHub's Terms still permit viewing and forking within GitHub. See [COPYRIGHT.md](COPYRIGHT.md) for the full rights notice and limitations.

An original third-person 3D open-world adventure for modern browsers, built with Godot 4.7 Web. The current repository is an **early playable-systems prototype**, not the finished game.

## Current verified status

Implemented in the prototype:
- Godot project configured with the Compatibility renderer.
- Third-person capsule placeholder, camera-relative movement and third-person camera orbit.
- Browser keyboard controls (WASD), right-mouse camera drag, and a shared contextual interaction action.
- A reusable player interaction router that detects nearby registered interaction areas and dispatches the nearest target's `interact()` method; Mira is the first integrated target.
- An animated garden gate that opens and closes, plus a physics basket that can be picked up, carried and dropped with the interaction button.
- Initial graphics pass: filmic tonemapping, sky-based ambient lighting, distance fog, subtle glow, directional shadows, layered tree canopies and small wildflower/stone details.
- Procedural Willow Village greybox with a square, placeholder houses, paths, garden, trees, well and sign.
- Mira NPC prototype with proximity detection and Arabic dialogue text/emotion metadata.
- First tutorial mission tracking: reach the square → talk to Mira → visit the garden, with local save/restore for its three progress flags.
- First drivable road-car prototype: enter/exit, forward/reverse throttle, steering, braking, collision toggling and a contextual mobile BRAKE/EXIT HUD. Its vehicle art is still procedural placeholder geometry.

Not yet verified or not yet implemented:
- Final character and vehicle models, rigs, animations and production-quality art.
- Real integrated Arabic voice acting (Mira's audio is still pending).
- Advanced vehicle physics: suspension, tire grip, damage, repair, fuel, vehicle audio, passenger seats and traffic AI.
- Distinct vehicle classes and handling for motorcycles, bicycles, boats, trucks and aircraft.
- A complete reusable physics/object interaction system.
- Full main story, broad cast, varied side missions and living-world systems.
- Canonical final regions and world map/GPS.
- Complete inventory/currency and game-wide save system.
- Full browser gameplay, cross-browser visual review and completion of the remaining gameplay systems.

The first mission's currency reward is currently displayed as prototype information; it is not connected to a real wallet or inventory.

## Important product specification

The governing requirements and prototype discrepancies are recorded in [Master Requirements Alignment](docs/MASTER_REQUIREMENTS_ALIGNMENT.md). The supplied `GTA_GHIBLI_FULL_PROMPT.txt` remains the primary product brief.

The master brief names the four canonical regions **Harbor City, Sapphire Coast, Pine Highlands and Amber Valley**, plus **Marsa Al-Noor**, and the required cast **Leo Bennett, Claire Bennett, Mia Bennett and Nora Blake**. Current names such as Green Valley, Willow Village and Mira belong to the existing prototype and must not silently replace those requirements.

The project must include systemic interactions, physics, people, nature, food, varied missions and genuinely controllable vehicles. Repetition should be reviewed and reduced rather than used to inflate content counts. See [Core Gameplay Systems](docs/GAMEPLAY_SYSTEMS.md).

## Open the prototype

1. Open Godot 4.7.
2. Choose **Import** and select the repository folder.
3. Open `project.godot`.
4. Press **F6** to run the current scene, or **F5** to run the project.

## Current browser controls

- Movement: W / A / S / D.
- Camera: hold the right mouse button and move the pointer.
- Interaction: approach an interactable and press E.
- Sprint: hold Shift.
- Click the game canvas once to focus it before using the keyboard.
- Starter car: enter with USE; joystick up/down accelerates/reverses, left/right steers, BRAKE slows down, and EXIT returns to on-foot control.

## Automated validation

GitHub Actions run [43513899542](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/43513899542) completed successfully for the earlier mission milestone. The newer vehicle milestone added a dedicated enter/drive/exit test. A subsequent commit expands coverage to forward/reverse movement, steering, braking, and restoration of player collision and visibility; its CI result must be checked before treating those cases as passed.

Headless CI does not prove visual quality, real touchscreen behavior, audio playback or performance on a physical phone.

## Web preview

The current target is the Godot 4.7 Web export. GitHub Actions builds it temporarily, serves it only on 127.0.0.1 for Chromium/WebGL 2 validation, records exact export/ZIP measurements, and removes the temporary files. It does not upload a downloadable Web artifact or publish a public website. See [Web Edition](docs/WEB_VERSION.md). Android APK builds and physical-device testing are outside the current scope.

## Privacy by default

GTA GHIBLI is designed not to access the player's personal photos, videos, messages, contacts, camera, microphone or general files. No automatic device scan or background media access is part of the game. See [Privacy by Default](docs/PRIVACY_BY_DEFAULT.md). CI checks Web privacy, bundled/offline dialogue audio, external network requests and secret exposure.

## Security and ownership

- [Copyright and rights notice](COPYRIGHT.md)
- [Security policy and vulnerability reporting](SECURITY.md)
- [Public repository hardening plan](docs/REPOSITORY_HARDENING.md)
- [Ownership and asset provenance register](docs/OWNERSHIP_AND_ASSET_REGISTER.md)

The repository intentionally remains public. Automated secret scanning is configured in [Repository security audit](.github/workflows/security-audit.yml); branch protection, GitHub secret-scanning settings, account 2FA/passkeys and off-site backups require owner-side configuration. See the hardening plan for the exact checklist and current limitations.

## Project documents

- [Master requirements alignment](docs/MASTER_REQUIREMENTS_ALIGNMENT.md)
- [Project blueprint](docs/PROJECT_BLUEPRINT.md)
- [Core gameplay systems](docs/GAMEPLAY_SYSTEMS.md)
- [GTA GHIBLI world and story encyclopedia](docs/GTA_GHIBLI_ENCYCLOPEDIA.md)
- [Initial quality audit](docs/QUALITY_AUDIT.md)
- [Historical Android content-budget notes](docs/ANDROID_4GB_BUDGET.md) (not a current delivery gate)
- [Web Edition and private browser validation](docs/WEB_VERSION.md)

## Prototype scene and structured data

- [Willow Village scene](scenes/world/willow_village.tscn)
- [Willow Village generator](scripts/world/willow_village.gd)
- [World prototype data](data/world/regions.json)
- [First tutorial mission](data/missions/mission_001.json)
- [Mira Arabic dialogue data](data/dialogue/mira_intro_ar.json)

## Creative direction and ownership

Create an original, warm, hand-painted fantasy atmosphere with systemic open-world gameplay. GTA San Andreas is a high-level genre reference only. Do not copy its maps, characters, dialogue, missions, branding, music, source code or extracted assets.

## Content growth

There is no fixed final size ceiling. Increase size only through useful original or properly licensed game content. Track the Git tree, temporary Web export folder, and temporary Web ZIP separately; none is a public download artifact. Keep browser loading and runtime stability healthy.

## Quality rule

Do not describe a feature as working until it has been run and tested. Distinguish headless Godot tests from private Chromium/WebGL 2 browser tests. A public Web release requires a separate explicit owner decision.


## Latest playable prototypes (14 November 2026)

- **Mission 002 — الطريق القديم: عملية الإنقاذ:** vehicle checkpoint, blockade, witness rescue, scripted pursuit and retry.
- **Mission 003 — ظلال فوق الميناء:** harbor investigation, three evidence items, guard field of view and line-of-sight prototype.
- **Mission 004 — القطار الأخير:** meet Mia, disable two alarms, escort a moving train and choose a north/south route.
- **Optional world activities:** recover a lost delivery, help a farmer move three crates, bring a repair kit to a stranded driver, and reunite a lost dog with its owner.

These are lightweight gameplay blockouts using primitive placeholder visuals. They are not finished production art, recorded Arabic voice acting, or proof of Android device testing. The Godot validation workflow contains headless regression tests for these systems; see [Godot validation](.github/workflows/godot-validation.yml) for current results.


- **ذاكرة علاقات NPC:** الثقة والألفة يمكن حفظهما محلياً واستعادتهما بين الجلسات؛ الربط الشامل مع الحوارات والقرارات ما زال عملاً لاحقاً.
