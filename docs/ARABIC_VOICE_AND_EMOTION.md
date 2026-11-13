# GTA GHIBLI — Arabic Voice, Dialogue & Emotion Standard

## Non-negotiable direction
The game's character dialogue is Arabic-first and fully voiced in Arabic. Subtitles are available, but must not replace spoken dialogue. Each character receives a distinct, consistent voice profile.

## Performance and emotion
Every recorded line must carry a performance direction and an emotion tag. Initial emotion vocabulary:
- Joy: bright, smiling delivery.
- Sadness: quieter tone, natural pauses.
- Fear: hesitant delivery and controlled breath.
- Anger: firm, tense delivery without exaggerated shouting.
- Surprise: brief lift in pitch, then natural settling.
- Tenderness: soft, gentle and intimate delivery.

Emotion should also be reflected by facial expression, posture, and animation as character rigs become available. Do not claim these visual reactions are implemented until they exist in-game.

## Localization
- Arabic is the default spoken language.
- Use clear, natural Arabic suitable for a broad audience.
- Keep speaker names, emotion labels, and dialogue UI right-to-left.
- Keep dialogue data separate from gameplay scripts.
- Provide optional subtitles and later add other languages only as secondary choices.

## Audio asset pipeline
- Store dialogue audio under `assets/audio/dialogue/ar/<character>_<line>.ogg`.
- Keep a stable line ID and a voice profile for each character.
- Use compressed OGG for in-game dialogue; track source masters separately.
- If an audio file is not present, show Arabic subtitles without crashing.
- Generated or recorded voice assets must be reviewed for pronunciation, emotional fit, clipping, and intelligibility before being marked complete.

## First character: Mira
Mira's initial voice is a warm, gentle female voice speaking clear Modern Standard Arabic. Her greeting is happy and welcoming, with a tender middle phrase and a hopeful question.

Current implementation: Arabic dialogue text, right-to-left UI, emotion label, and optional audio playback hook. The actual voice recording and expressive facial/body animation are pending; the current character is still a simple geometric prototype.
