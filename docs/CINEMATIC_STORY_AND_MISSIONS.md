# GTA GHIBLI — Cinematic Story & Mission Plan

## Creative direction
The story is an original, character-led open-world crime-adventure drama. GTA San Andreas is a reference for cinematic pacing, mission variety, player freedom and a lived-in world—not for copied characters, dialogue, maps, scenes, music or missions.

## Opening chapter
The opening sequence is stored in `data/story/chapter_01_opening.json` and presented by `scripts/missions/cinematic_director.gd`. It uses in-engine letterbox bars, chapter cards, Arabic subtitles, timed beats and touch/keyboard advance. The opening introduces Leo Bennett, Mira, the mysterious radio signal and the threat approaching Willow Village.

**Honest implementation status:** this is a first cinematic presentation layer over the live game view. It does not yet include authored camera rails, bespoke character animation, voice recording, or final music. Arabic voice lines remain pending real recorded/generated audio assets; subtitles are not described as dubbing.

## Main story mission concepts
| Mission | Style | Core gameplay |
|---|---|---|
| The Old Road: Rescue Operation | Rescue + driving chase | Timed drive, blockade, rescue, escape |
| Shadows over the Harbor | Stealth + investigation | Infiltration, evidence photography, patrol avoidance, branching trust |
| The Last Train | Escort + timed action | Protect Mia, stop alarm, choose escape route, survive pursuit |

These mission records are authored designs, not playable missions yet. Mission 002 and mission 003 now have lightweight runtime blockouts. Other mission concepts must be connected to runtime objectives, actors, checkpoints, failure/retry, rewards and save progression before being called playable.

## Cinematic mission craft
- Establish stakes with a short visual beat before control is handed to the player.
- Keep dialogue character-specific, Arabic-first and emotionally directed.
- Use varied mission verbs: drive, rescue, evade, investigate, infiltrate, escort, protect, choose and escape.
- Let choices affect trust, available information, allies and later dialogue.
- Avoid filler objectives and repeated fetch loops.
- Keep cutscenes skippable and short on mobile.

## Production order
1. Validate the opening presentation and the first tutorial transition.
2. Build the rescue/chase mission as the first fully playable action mission.
3. Add the harbor investigation after stealth and evidence systems exist.
4. Add the train rescue after escort and branching mission support exists.
5. Record and integrate Arabic character voices and cinematic sound design.


## Mission 002 runtime status — 2026-11-14

Mission 002 now has a lightweight playable blockout runtime in `scripts/missions/mission_002_runtime.gd`. It unlocks after the first village mission is completed and includes vehicle entry, a checkpoint, a physical road blockade with a narrow central passage, an on-foot witness rescue, two scripted pursuing vehicles, a 90-second escape phase, failure/retry, and a local completion save. The headless regression test is `tests/mission_002_runtime_test.gd`.

This is not a finished cinematic mission: the witness is a placeholder actor and both pursuers use simple scripted movement at different speeds. The chase now includes a basic vehicle-health indicator and damage when either pursuer gets dangerously close, but it does not yet include physical deformation, repair stations, advanced AI, voiced Arabic dialogue, animated camera shots, final art/audio, or Android device playtesting. Missions 003 and 004 remain design-only.


## Mission 003 runtime status — 2026-11-14

Mission 003 now has a playable stealth/investigation blockout in `scripts/missions/mission_003_runtime.gd`. It unlocks after mission 002 is saved as complete. The player meets Nora at a marked contact point, enters the harbor blockout, collects three evidence markers, avoids three simple moving guard placeholders, and returns to the contact point. Three separate guard detection events fail the mission; retry resets evidence and alerts. Guards now use a 100-degree forward field of view and a 3.2-meter detection radius. A physics ray checks whether collision-layer-1 geometry (including the harbor containers) blocks the guard's view. The headless regression test checks the objective sequence and verifies that a player in front is visible while a player behind is not.

This remains a prototype: guards still use simple scripted patrol movement rather than navigation/pathfinding; there are no advanced alert propagation, disguises, takedowns, sound propagation, voiced dialogue, final harbor art, or Android device playtesting.


## Mission 004 runtime status — 2026-11-14

Mission 004, “القطار الأخير”, now has a lightweight playable escort blockout in `scripts/missions/mission_004_runtime.gd`. It unlocks after Mission 003 is saved complete. The player meets Mia at the station, reaches the train, disables two alarm panels, stays near a moving train for a timed escort segment, and chooses a north or south route. The two choices save distinct route IDs and rewards (350 / 400). The station includes a primitive train mesh, platform, sleepers, rails, markers, HUD, failure timer and retry flow.

The runtime is integrated from `main.gd`; data is in `data/missions/mission_004.json`; a headless progression test is `tests/mission_004_runtime_test.gd`; and the Godot validation workflow now parses and runs this test. This is still a blockout: Mia and train art are primitive placeholders; there are no train animations, physical train interactions, voiced dialogue, route-specific story consequences, advanced threats, final audio, or Android device testing. CI status must be checked after the workflow run; adding the test to the workflow is not proof that it passed.
