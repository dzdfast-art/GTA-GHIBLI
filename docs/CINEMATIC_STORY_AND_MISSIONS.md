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

These mission records are authored designs, not playable missions yet. The current runtime mission manager still implements only the introductory village tutorial. Each new mission must be connected to runtime objectives, actors, checkpoints, failure/retry, rewards and save progression before being called playable.

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

Mission 002 now has a lightweight playable blockout runtime in `scripts/missions/mission_002_runtime.gd`. It unlocks after the first village mission is completed and includes vehicle entry, a checkpoint, a physical road blockade with a narrow central passage, an on-foot witness rescue, a scripted pursuer vehicle, a 90-second escape phase, failure/retry, and a local completion save. The headless regression test is `tests/mission_002_runtime_test.gd`.

This is not a finished cinematic mission: the witness is a placeholder actor and the pursuer uses simple scripted movement. The chase now includes a basic vehicle-health indicator and damage when the pursuer gets dangerously close, but it does not yet include physical deformation, repair stations, advanced AI, voiced Arabic dialogue, animated camera shots, final art/audio, or Android device playtesting. Missions 003 and 004 remain design-only.
