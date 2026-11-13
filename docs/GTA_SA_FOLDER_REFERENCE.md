# GTA San Andreas Folder Reference for GTA GHIBLI

## Purpose

The user-provided Windows Explorer screenshot shows an installed Grand Theft Auto: San Andreas folder. It is useful as a high-level reminder that a large open-world game separates models, animation, audio, data, scripts, text, and cinematic media into distinct content families.

This document uses those visible folder names as an organizational reference only. GTA GHIBLI is an original Godot project. Do not copy, extract, redistribute, or depend on proprietary GTA San Andreas game assets, archives, executable files, sounds, dialogue, textures, models, or scripts.

## What the screenshot suggests

| Visible folder or item | General content family | GTA GHIBLI direction |
|---|---|---|
| `anim` | Character and object animation data | Keep animation resources with character/vehicle assets or in a dedicated animation library |
| `audio` | Music, dialogue, ambient sound, effects | Separate Arabic character voice, music, ambience, and sound effects |
| `data` | Game configuration and structured gameplay data | Keep missions, dialogue, world regions, character definitions, and balance data in JSON/Resources |
| `models` | 3D models and related resources | Store original optimized meshes, materials, and props under `assets/` |
| `movies` | Pre-rendered or cinematic media | Store original in-game cutscene video only when needed; prefer real-time Godot scenes on Android |
| `scripts` | Gameplay and engine logic | Keep Godot scripts grouped by responsibility |
| `text` | UI text, subtitles, and localization | Use localization files, Arabic RTL UI, and subtitle resources |
| `SAMP`, `CLEO`, `rcon`, and related files | Multiplayer/modding or supporting tools visible in this installation | Not part of the core GTA GHIBLI architecture; add online/mod support only after a separate design and security review |

The screenshot is a folder listing, not a complete technical specification of the original game's internal file formats. The descriptions above are broad categories, not claims about every file stored in those folders.

## Recommended Godot project organization

Keep the current working project small and add directories as real assets and systems are produced. Do not create large empty folders or placeholder files merely to imitate another game's installation.

```text
GTA-GHIBLI/
├── assets/
│   ├── characters/
│   ├── vehicles/
│   ├── world/
│   ├── props/
│   ├── materials/
│   ├── animations/
│   ├── audio/
│   │   ├── voices/ar/
│   │   ├── music/
│   │   ├── ambience/
│   │   └── sfx/
│   ├── cinematics/
│   └── fonts/
├── data/
│   ├── characters/
│   ├── dialogue/ar/
│   ├── missions/
│   ├── vehicles/
│   ├── world/
│   └── localization/
├── scenes/
│   ├── characters/
│   ├── vehicles/
│   ├── world/
│   ├── interiors/
│   ├── ui/
│   └── cinematics/
├── scripts/
│   ├── core/
│   ├── ai/
│   ├── characters/
│   ├── dialogue/
│   ├── audio/
│   ├── missions/
│   ├── player/
│   ├── vehicles/
│   ├── ui/
│   └── world/
├── docs/
└── project.godot
```

## Arabic voice and emotion pipeline

- Store each original Arabic voice line as an individual compressed audio asset, grouped by character and scene.
- Keep the spoken Arabic transcript and emotion/delivery metadata in `data/dialogue/ar/`.
- Each dialogue entry should identify the speaker, line ID, Arabic text, emotion, delivery direction, and optional audio resource path.
- The game should show Arabic subtitles while playing the matching voice clip; if a voice clip is missing, subtitles must still work.
- Avoid loading every voice clip into memory at once. Load dialogue audio on demand and release it when no longer needed.
- Use distinct original voices for characters. Do not imitate a real actor or reuse copyrighted game voice recordings.

## Android storage and performance rules

The project's previously defined 4 GiB target is a planning budget, not the current repository size or a measured export size. Track actual imported asset and Android export sizes as content is added.

- Prefer compressed Ogg Vorbis or another Godot-supported compressed format for dialogue and ambience; verify the platform import settings.
- Use compressed textures and appropriately sized 3D meshes.
- Stream long music and ambient tracks rather than keeping all audio in memory.
- Keep optional cinematic files out of the base install unless they are needed.
- Record source size, imported size, and exported size separately.
- Profile on a real Android device before increasing asset quality or world density.

## Current project status

The repository currently has a small Godot prototype with a player, a blockout village, an initial Mira NPC/dialogue implementation, structured mission/world data, and validation workflow. This reference document does not mean the full directory layout, all content categories, voice assets, vehicle systems, cinematics, or a 4 GiB game have been implemented.

## Next implementation sequence

1. Make the Arabic dialogue data the authoritative source for subtitles and voice metadata.
2. Generate and review a short original Arabic voice sample for Mira.
3. Add the approved audio file to the project and connect it to the dialogue playback path.
4. Add a fallback for missing audio and a simple way to replay/advance dialogue.
5. Validate the scene with Godot CI, then test playback and touch controls on a real Android device.
6. Expand the same pipeline to the next character only after Mira's complete dialogue flow works.
