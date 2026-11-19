# Bicycle audio feedback | مؤثرات صوت الدراجة

## Gameplay use
- The live `StarterBicycle` controller loads `audio/vehicles/bicycle_bell.wav` into a spatial `AudioStreamPlayer3D` child named `BicycleBellAudio`.
- While mounted, the rider can ring it with the mobile **BELL** control or keyboard **B**. The control is hidden on foot and in cars.
- Playback is spatial and short-range; it does not request microphone access or any Android media permission.

## Asset provenance
- Original synthesized WAV PCM (22,050 Hz, mono, 16-bit), generated for this project from inharmonic bell partials and a short strike transient.
- No third-party recording, game rip, or commercial-game sound is used.

## Validation
- `tests/bicycle_controller_test.gd` checks that the stream loads, the mobile control appears only while riding, and pressing it starts playback.
- The Godot validation workflow parses both modified scripts, imports the WAV, validates this manifest as JSON, and runs the bicycle regression test.
- Headless CI confirms resource loading and playback start only; it does not replace listening on an Android phone.
