# GTA GHIBLI — Uploaded Video Reference Integration

**Source:** user-supplied `1000208059.mp4`  
**Container metadata:** 1280×644, 127 seconds, H.264 video with AAC audio, 74,389,686 bytes.  
**Review method:** visual samples taken at two-second intervals throughout the clip, then key frames inspected. Times below are approximate positions in the source recording, not its in-game clock.

## Actions observed in the supplied recording

| Approx. time | What the recording shows |
|---|---|
| 00:00–00:06 | Third-person character stands in a residential lane beside a bicycle; a prompt directs the player to approach/use the bicycle. |
| 00:06–00:15 | The character mounts the bicycle. A selection panel presents three steering methods: **ANALOG**, **BUTTONS**, and **FLICK**. |
| 00:15–00:28 | The rider pedals through residential streets toward a railway corridor. An instruction explains braking and holding the brake to reverse once stopped. |
| 00:28–00:40 | The rider follows the track-side route and crosses a distinctive red steel/truss bridge. |
| 00:40–00:50 | The rider returns to ordinary roads and uses a contextual action to dismount. |
| 00:50–01:03 | The character returns to on-foot movement and running, approaches a house with a red entrance marker, and enters. Pedestrians are visible around the neighbourhood. |
| 01:03–02:07 | The recording transitions to an indoor house/interior view with furniture and a changed camera composition. |

## Implemented on the development branch

| Video interaction | GTA GHIBLI change | What still needs verification |
|---|---|---|
| Approach and mount the bicycle | Original procedural bicycle controller and starter scene, using the existing shared interaction contract | Test execution and physical phone touch feel |
| Pedal, steer, brake and reverse | Separate pedal, left/right steering and brake/reverse actions | Handling tuning, bicycle-specific collision response and rider animation |
| ANALOG steering | Existing virtual joystick supplies bicycle steering while mounted | Test on real Android screen |
| BUTTONS steering | Dedicated left/right touch buttons | Test touch target positions on device |
| FLICK steering | Horizontal touch drag in the left area controls steering | Test multi-touch interaction on device |
| Contextual prompts | On-foot prompt changes to RIDE near a bicycle, ENTER near a road vehicle, and house entrance/exit near the room portal | Visual check in the running game |
| Contextual HUD states | On-foot RUN, bicycle PEDAL/BRAKE/EXIT BIKE, and car BRAKE/EXIT are separate states | Test all transitions on phone |
| Red railway bridge | Original procedural Red Willow Crossing with red truss bars, track rails and sleepers | Scene appearance, road connection and collision on device |
| Red house entrance marker | Red illuminated marker at the Baker House entrance | Visual check and prompt distance |
| Enter/leave house | Separate furnished room below the outdoor scene; entrance stores the player's outside transform and exit restores it | Camera fade, multiple rooms and persistent interior state |
| Return to on-foot running | RUN touch control and Shift keyboard action increase movement speed while held | Movement animation and speed tuning |

## Originality and legal boundary

The source recording contains footage from a commercial game. This branch adopts only the broad interaction sequence and steering concepts. It does not import the source video, the commercial game's protagonist, proprietary map geometry, UI artwork, or extracted models/audio. The bicycle, crossing, room, prompt text and interface implementation are original lightweight prototypes.

## Explicitly not complete yet

- Final bicycle and character models, rig, riding/pedal animations, suspension and refined collision handling.
- Full, navigable road and railway network with traffic, pedestrians and safe pathfinding.
- Finished bridge landscape/river valley art and destination links beyond the current route blockout.
- Production-quality interiors, multiple room types, door animations, fade transitions and saved room state.
- Real Android multi-touch testing of ANALOG, BUTTONS and FLICK steering.
- Final dialogue/ambient audio and production art.
- Android APK build from this branch and installation/performance test on the target Infinix SMART 8.

Automated tests are added to the Godot workflow. A passing headless test proves only the coded assertions it actually exercises; it does not establish visual fidelity, touch comfort or performance on a physical device.
