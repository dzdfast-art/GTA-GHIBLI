# Video-reference world integration | ربط عناصر العالم

## Added to the live world

- **Bicycle / الدراجة:** `StarterBicycle` is spawned beside the player and uses the existing bicycle controller and contextual mobile controls.
- **Caretaker house / منزل الحارسة:** `CaretakerHousePortal` is attached just outside the caretaker house in Willow Village. Its existing entry/exit areas route the player into the furnished interior and back.
- **Red bridge / الجسر الأحمر:** the original red steel bridge scene is placed in Amber Valley. It loads the original ravine terrain mesh as a visual backdrop and provides a scaled deck collision surface.

## Validation

The Godot workflow now parses the bicycle and house-portal scripts and runs the existing bicycle and house tests plus:

```sh
godot --headless --path . --script res://tests/video_reference_world_flow_test.gd
```

The integration test instantiates the actual main-world script and verifies that the bicycle, house portal, bridge mesh, ravine mesh, and bridge-deck collision are present.

## Prototype limits | حدود النسخة الأولية

- The ravine mesh is currently a visual backdrop; the large world floor has not yet been carved away beneath it.
- The bridge deck has a collision surface, but approach roads, terrain collision baking, final material tuning, and Android-device visual/touch testing remain future work.
- These are original project assets and blockout geometry, not copied commercial-game assets.

## الحالة

هذا الربط يجعل العناصر الثلاثة جزءاً من مشهد العالم الذي ينشئه `main.gd`. نجاح فحص Godot أو بناء APK لا يثبت وحده أن المشهد شوهد أو لُعب على هاتف فعلي.
