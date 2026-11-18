# GTA GHIBLI — Living World Audio and Performance

## Direction inspired by public GTA V sound-design practice
The public GDC session “The Sound of Grand Theft Auto V” describes an open-world audio approach built from diverse, immersive world layers and real-time synthesis/DSP. GTA GHIBLI uses that high-level design principle only; it does not copy Rockstar recordings, code, dialogue, or proprietary assets.

## Current in-game ambience
- Procedural breeze with biome-dependent strength.
- Leaf rustle in village, forest and fields.
- Rain bed plus irregular droplet transients.
- Storm-only distant low-frequency thunder events and stronger wind.
- Dawn birds, night insects and owl-like calls.
- Coast/river water layer and six looping WAV ambience themes.
- Weather/biome selection and fade-in of the selected field ambience.
- Automatic clear/rain/storm changes approximately every four minutes, with a random weighted weather choice.
- All procedural ambience is local: no microphone, personal files or runtime network access.

## Important audio-quality distinction
The WAV themes already in `audio/ambience/` and the new weather layers are prototype-generated textures, not authentic field recordings. They are useful for implementation and testing but must be replaced or layered with properly licensed field recordings for a natural AAA result. Candidate open-source reference: [foleykit](https://github.com/rudqlsdla/foleykit), which documents 335 procedural CC0 sound designs including rain, wind, water, fire, insects, birds and place ambiences. Its CC0 dedication permits reuse of its rendered sounds; GTA GHIBLI has not yet imported those binary sounds. The project currently uses its own procedural prototype layers. Do not copy any GTA game audio.

## Character acting
Every existing world dialogue line now carries an emotion ID, Arabic acting direction and a supported HeyGen-style performance tag where applicable (for example [sad], [whispers], [angry], [laughs], [gasps]). The current voice clips are still first-pass synthetic reads. An expressive retake is required; metadata alone does not make a voice sound emotional. A HeyGen generation attempt for six emotion samples returned a 502 error, so no new expressive clips are claimed as completed.

## Production mix target
- Dialogue must remain intelligible over ambience; dialogue bus is the priority.
- Keep wind, rain, insects and wildlife in separate layers so weather and region changes can rebalance them.
- Use 3D emitters for localized animals, machinery and nearby environmental sources; use a global bed only for broad environmental tone.
- Use short natural transitions between time-of-day and weather states; avoid abrupt hard cuts.
- Record or source distinct Arabic performances for joy, grief, fear, anger, surprise, tenderness, whispering and breath/pause timing.

## Mobile constraints
Use compressed OGG/MP3 for shipped long loops and short WAV only for lightweight transient events. Keep the number of simultaneous 3D emitters bounded, use mono for localized sources, and provide independent Music/SFX/Dialogue volume settings.
