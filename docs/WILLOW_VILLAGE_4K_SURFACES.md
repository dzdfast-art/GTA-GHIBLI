# Willow Village — Surface Material Library

## Original 4K SVG surfaces
The project includes 32 original, tileable 4096×4096 SVG surface materials for the village, market lane, and outer district plots. The procedural village binds the SVG materials to matching mesh colors, and twelve additional walkable district plots extend the environment.

## High-detail raster surfaces
Fourteen additional 512×512 BMP materials provide fine surface variation for roads, cobblestone, terracotta roofing, pine-forest ground, weathered timber, granite curbs, mosaic market tiles, olive-grove ground, marble plazas, red sandstone, river mud, wet stone, painted metal, and harbor paving. Each raster surface is connected to an existing village/district material color in `willow_village.gd`; these are runtime assets, not unused size-only files.

## Validation
The Godot regression test checks all 32 SVG textures for 4K import and exact material binding, then checks all 14 BMP textures for 512×512 import and exact binding.

Run:
`godot --headless --editor --path . --quit`
`godot --headless --path . --script res://tests/village_surface_texture_test.gd`

## العربية
يحتوي المشروع على 32 خامة SVG أصلية بدقة 4096×4096 للقرية والسوق والمناطق الخارجية. وأُضيفت 14 خامة BMP بدقة 512×512 لتفاصيل الطرق والحجارة والقرميد وأرض الغابة والخشب والجرانيت وفسيفساء السوق وبستان الزيتون والرخام والحجر الرملي وطين النهر والحجر المبلل والمعدن ورصيف الميناء.

الخامات الأربع عشرة مربوطة فعلياً بمواد أرضيات ومجسمات القرية والمناطق الخارجية، وليست ملفات غير مستخدمة لزيادة الحجم. ويتحقق اختبار Godot من استيراد الخامات الـ46 وربط كل خامة بالمادة المطابقة لها.
