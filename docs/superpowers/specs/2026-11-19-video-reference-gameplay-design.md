# Video-reference gameplay integration design

## Intent
Recreate the gameplay sequence shown in the user-supplied 127-second Android gameplay reference inside GTA GHIBLI, using original project-owned assets and Godot systems.

## Source-derived requirements
The reference shows third-person on-foot movement, a live mini-radar, clock/cash/health HUD, contextual touch actions, a bicycle approach and mount sequence, selectable ANALOG / BUTTONS / FLICK steering, bicycle riding through a neighborhood and over a railway bridge, dismounting, a red destination marker, and entering a furnished house.

## Current project baseline
The main branch already contains a third-person player controller and touch camera, contextual on-foot/bicycle/car controls, a rideable procedural bicycle with mount/dismount/pedal/steer/brake/reverse, saved ANALOG / BUTTONS / FLICK bicycle steering preference, a red bridge landmark, a caretaker-house portal with a simple furnished interior, a world clock, and a persistent player wallet. Headless tests cover bicycle riding, touch/camera separation, house entry/exit, and the bicycle/house/bridge world integration.

## Gaps verified on main
- There is no in-game mini-radar overlay in the main branch; the existing world map is a pause-menu page.
- The main branch does not show the reference's always-visible clock/cash/health status HUD.
- The player health component is not attached to the player in main.
- The default player visual is still a capsule rather than a finished animated humanoid.
- The current bicycle/house/bridge are separate playable elements; the complete reference route/tutorial and traffic sequence are not yet demonstrated as one continuous mission.
- No physical Android touch/visual test has been completed.

## Goals
1. Add a compact live radar overlay with player direction, nearby vehicle/bicycle/landmark/house markers, and optional active objective marker.
2. Add a unified runtime HUD for world clock, wallet balance, player health, and the unarmed fist indicator.
3. Attach a real player-health component and bind the HUD to the player without duplicating or replacing the existing mobile controls, pause menu, world map, wallet, or clock.
4. Add focused Godot regression tests and CI parsing/test steps.
5. Preserve the existing bicycle, camera, mission, pause, and world systems.

## Non-goals for this phase
- Do not copy proprietary GTA source code, artwork, sounds, names, or extracted assets.
- Do not redesign the already-implemented bicycle steering preference or rewrite vehicle physics.
- Do not claim a finished animated player model, traffic AI, route tutorial, or physical Android validation in this phase.
- Do not change the main branch directly or merge unrelated prior draft branches.

## Approaches considered
1. Merge the old HUD/integration draft branch wholesale. Rejected because it contains many unrelated and diverged commits and creates avoidable regression risk.
2. Port only the isolated HUD, radar, and health components onto a new branch from current main. Selected because it adds the missing visible HUD while preserving the current bicycle, house, bridge, and settings systems.
3. Rebuild all mobile controls and gameplay flow from scratch. Rejected because the current controls and video-reference elements already exist and have regression coverage.

## Selected implementation
Create a feature branch from current main. Add focused radar, HUD, and health components; add them as children of the existing mobile HUD; attach PlayerHealth and bind the player from main.gd. Add a test that asserts the in-game HUD exists and reads live wallet/clock/health values. Run the Godot validation and Android debug build workflows. Keep the branch as a draft PR until checks and a later physical-device review are complete.

## Follow-on phases
After this HUD phase, implement the continuous bicycle tutorial/route as a separate mission slice, then replace the capsule player with a licensed/original rigged character and add traffic/road behavior, validating each slice separately.
