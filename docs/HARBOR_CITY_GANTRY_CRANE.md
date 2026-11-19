# Harbor City gantry crane | رافعة ميناء المدينة

## Gameplay use
- The original crane model is loaded from `assets/environment/industrial/harbor_gantry_crane.obj` by `scenes/world/harbor_gantry_crane.tscn`.
- `open_world_regions.gd` places it at the Harbor City loading dock.
- Walk to the control point and use the existing **E / interact** action. The suspended container rises; interact again to lower it.
- The hoist cable changes length with cargo height. Four leg collision shapes protect the supports; the control Area3D joins the shared `interaction_areas` group.

## Asset provenance
The mesh, material groups and 2048×2048 SVG surface atlas are original GTA GHIBLI project content. See `assets/environment/industrial/README.md`.

## Verification
Run:
```sh
godot --headless --path . --script res://tests/harbor_gantry_crane_test.gd
```
The test checks the imported mesh, Harbor City attachment, interaction registration, and a complete raise/lower cycle. CI import/build checks do not replace visual or touch testing on a physical Android device.

## حدود النسخة
الرافعة عنصر بيئي تفاعلي أولي؛ الحاوية تتحرك بحركة مبرمجة وليست حمولة فيزيائية كاملة، ولا توجد مهمة شحن مرتبطة بها بعد.
