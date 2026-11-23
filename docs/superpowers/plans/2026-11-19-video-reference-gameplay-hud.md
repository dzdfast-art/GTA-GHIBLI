# Video-reference gameplay HUD Implementation Plan

> **For agentic workers:** Implement task-by-task on `feat/video-reference-gameplay-hud-20261119`. Preserve the main branch; do not merge this draft.

**Goal:** Add the missing live mini-radar and clock/cash/health HUD from the supplied gameplay reference, and connect them to the existing Godot player and mobile HUD.

**Architecture:** Keep the existing `MobileControls` CanvasLayer as the HUD owner. Add a separate `GameplayHUD` Control with a `MinimapRadar` child, add `PlayerHealth` to the current player, and bind it through the existing mobile-controls node. Existing wallet, world clock, bicycle, camera, map, and mission systems remain the sources of truth.

**Tech Stack:** Godot 4.7, GDScript, GitHub Actions headless validation and Android ARM64 debug export.

**Spec:** `docs/superpowers/specs/2026-11-19-video-reference-gameplay-design.md`

## Global Constraints
- No direct changes to `main`; all changes stay on the new feature branch.
- Use original project-owned UI and code; do not extract proprietary game assets from the video.
- Preserve current bike steering selection and saved settings.
- Do not use duplicate wallet or world-clock state; read existing services.
- No claim of physical Android validation without a real-device test.

## Review Focus
- Player or health component missing during first frames: HUD stays valid and retries binding.
- Wallet save not present: cash display uses the wallet's actual initial/current balance.
- World clock group not ready yet: clock label remains valid and refreshes when available.
- Player health at zero or maximum changed: progress bar remains clamped and accurate.
- Paused scene: gameplay HUD and its radar stop updating with the scene's normal pause behavior.

---

### Task 1: Define the HUD integration test

**Files:**
- Create: `tests/gameplay_hud_overlay_test.gd`
- Modify: `.github/workflows/godot-validation.yml`

**Interfaces:**
- The test loads `res://main.tscn`, then locates `MobileControls/HUD/GameplayHUD`.
- The HUD exposes `LiveRadar`, `WorldClock`, `CashBalance`, `PlayerHealthBar`, and `UnarmedFistIcon` named controls.

- [ ] **Step 1: Add the failing test** asserting exactly one gameplay HUD, its radar/status children, a `PlayerHealth` component on the player, and live clock/wallet/health display.
- [ ] **Step 2: Run the test through Godot CI** and confirm it fails because the HUD/health nodes are absent on current main.
- [ ] **Step 3: Add the script parse entry and test step** to the Godot validation workflow.

### Task 2: Add player health and live radar

**Files:**
- Create: `scripts/systems/player_health.gd`
- Create: `scripts/ui/minimap_radar.gd`

**Interfaces:**
- `PlayerHealth`: `current_health`, `maximum_health`, `apply_damage(amount)`, `heal(amount)`, `restore_full()`.
- `MinimapRadar`: `set_player(player)`, `set_target_position(position, active)`.

- [ ] **Step 1: Add the player health API** with health-change, damage, heal and death signals.
- [ ] **Step 2: Add radar drawing** for player direction, nearby vehicles/bicycles/landmarks/house portals and the active objective.
- [ ] **Step 3: Verify the health and radar test assertions** with the Godot workflow.

### Task 3: Build the gameplay status HUD and bind it

**Files:**
- Create: `scripts/ui/game_hud.gd`
- Create: `assets/ui/hud/fist.svg`
- Modify: `scripts/ui/mobile_controls.gd`
- Modify: `main.gd`

**Interfaces:**
- `GameHUD.bind_player(player)`; reads `PlayerWallet.get_balance()`, `WorldClock.get_clock_text()`, and `PlayerHealth`.
- `MobileControls.bind_player(player)` forwards to `GameplayHUD`.

- [ ] **Step 1: Create the HUD layout** with live radar, world clock, cash balance, health number/bar and unarmed-fist icon.
- [ ] **Step 2: Attach PlayerHealth and bind the player** through existing main scene setup.
- [ ] **Step 3: Re-run the focused HUD test and all configured Godot tests.**

### Task 4: Documentation and workflow evidence

**Files:**
- Modify: `docs/ADAPTIVE_MOBILE_CONTROLS.md`

- [ ] **Step 1: Update documentation** to distinguish already-implemented bicycle controls from the newly-added HUD layer.
- [ ] **Step 2: Trigger/inspect Godot validation and Android debug APK workflows** on this branch.
- [ ] **Step 3: Open a draft PR only after fresh checks; report the exact commit, tests, APK size if recorded, and remaining non-device limitations.**

