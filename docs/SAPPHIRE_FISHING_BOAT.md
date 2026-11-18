# Sapphire Coast — Fishing Boat / قارب الصيد

## Purpose / الاستخدام
An original low-poly fishing boat landmark placed in the Sapphire Coast harbour water. It adds a distinct coastal silhouette, visible fishing equipment, crates, buoys, mast, cabin glazing and a net rack.

يظهر القارب في مياه ساحل الياقوت بجوار الرصيف. يضيف عنصراً ساحلياً واضحاً مع معدات صيد وصناديق وعوامات وصارية ومقصورة وشبكة.

## Runtime path / مسار الاستخدام
- Source mesh: `assets/environment/landmarks/sapphire_fishing_boat.obj`
- Materials: `assets/environment/landmarks/sapphire_fishing_boat.mtl`
- Scene: `scenes/world/sapphire_fishing_boat.tscn`
- Motion: `scripts/world/fishing_boat_idle.gd`
- World integration: `scripts/world/open_world_regions.gd`, under `SapphireCoast`
- Import and integration test: `tests/sapphire_fishing_boat_test.gd`

## Mobile constraints / قيود الهاتف
The visible model is a single imported mesh. A simplified `AnimatableBody3D` box collider follows the slow bob/roll motion; no per-triangle collision is generated. The model is original GTA GHIBLI geometry and uses no third-party or commercial-game assets.

المجسم المرئي مورد واحد، والتصادم صندوق مبسط يتحرك مع القارب لتقليل تكلفة الفيزياء على الهاتف. لا تُنشأ تصادمات لكل مثلث. المجسم أصلي للمشروع ولا يستخدم أصول ألعاب تجارية.
