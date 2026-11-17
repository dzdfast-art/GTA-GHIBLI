# GTA GHIBLI — Gameplay HUD Design

Editable Figma concept: https://www.figma.com/design/7bGU7AuXFThFgg8IcNUwWL

Frame: `GTA GHIBLI — Gameplay HUD (Landscape)`, 1280 × 720.

Includes editable layers for:
- Circular minimap/radar with player and target markers.
- World clock, money, health bar and fist indicator.
- Mission objective panel.
- Left movement joystick.
- Contextual attack, interact, sprint and jump touch buttons.
- Pause control and project mark.

This is a visual design reference only. It has not yet been exported into Godot or connected to runtime controls. Keep the Godot HUD as the runtime source of truth until the design is implemented and tested in-engine.

Implementation notes:
- Preserve the existing HUD data contract and current input actions.
- Match positions responsively for common Android landscape aspect ratios; avoid hard-coded screen-edge overlap.
- Use the existing SVG action icons where appropriate.
- Add separate contextual layouts for on-foot, car and bicycle states.
- Verify multi-touch with simultaneous joystick, camera drag and action button input.
- Keep the existing pause menu order and save settings behavior.
