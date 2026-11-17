# Mobile terrain streaming / بث التضاريس للأجهزة المحمولة

## English

The 72 original OBJ terrain tiles already tracked under `assets/environment/terrain/expansion_150mb` and `expansion_300mb` are now loaded by proximity instead of being preloaded and attached all at once.

- Load radius: 72 world units.
- Unload radius: 96 world units (hysteresis avoids rapid load/unload at the boundary).
- Maximum active tiles: 6.
- Maximum new tile loads per refresh: 2.
- Refresh interval: 0.35 seconds.
- Each active tile receives a matching static trimesh collision body.
- `ResourceLoader.CACHE_MODE_IGNORE` is used so releasing a distant tile can release its mesh resource instead of keeping all 72 meshes in the global resource cache.
- The Android preset uses `export_filter="all_resources"`, so path-based terrain assets remain packaged even though the runtime no longer preloads them.

The existing 72 OBJ assets are reused; this feature adds no duplicate terrain files. CI validates resource paths, load/unload behavior, collision creation and district switching. Headless CI does not replace Android device profiling; frame-time, memory and touch-driven traversal still need a real-device pass.

## العربية

أصبحت قطع التضاريس الـ72 الموجودة أصلاً تُحمّل حسب قرب اللاعب بدلاً من تحميلها كلها مع التصادم عند بدء اللعبة.

- نصف قطر التحميل: 72 وحدة من وحدات العالم.
- نصف قطر التفريغ: 96 وحدة، لمنع التبديل المتكرر قرب الحد.
- الحد الأقصى للقطع النشطة: 6 قطع.
- الحد الأقصى للتحميل في كل تحديث: قطعتان.
- فترة تحديث القرب: 0.35 ثانية.
- لكل قطعة نشطة جسم تصادم ثابت مطابق للشبكة المرئية.
- يستخدم التحميل وضع تجاهل ذاكرة الموارد العامة حتى يمكن تحرير مرجع المجسم عند الابتعاد.
- إعداد تصدير Android يستخدم `all_resources`، لذلك تبقى ملفات التضاريس ذات المسارات الديناميكية ضمن الحزمة.

لم نكرر أي ملف تضاريس. يتحقق CI من وجود المسارات والتحميل والتفريغ وإنشاء التصادم والانتقال بين المناطق. لا يغني اختبار Godot headless عن قياس الذاكرة ومعدل الإطارات وتجربة التنقل باللمس على هاتف Android حقيقي.
