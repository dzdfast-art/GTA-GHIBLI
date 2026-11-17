# Willow Village — Surface Material Library

## Original 4K SVG albedo surfaces
The project includes 32 original, tileable 4096×4096 SVG surface materials for Willow Village, the market lane, and the outer district plots. The procedural village binds these SVG materials to the matching mesh colors as the visible base albedo.

## High-detail raster roughness maps
Fourteen original procedurally generated 512×512 BMP maps provide fine surface-response variation for asphalt, cobblestone, terracotta roofing, pine-forest ground, weathered timber, granite curb, market mosaic, olive-grove ground, marble plaza, red sandstone, river mud, wet stone, painted metal, and harbor paving. Each raster map is connected to a matching village/district material color as its roughness texture (red channel), preserving the original 4K SVG albedo rather than replacing it.

## Validation
The Godot regression test checks all 32 SVG textures for 4K import and exact albedo binding, then checks all 14 BMP maps for 512×512 import and exact roughness-map binding.

Run:
`godot --headless --editor --path . --quit`
`godot --headless --path . --script res://tests/village_surface_texture_test.gd`

## العربية
يحتوي المشروع على 32 خامة SVG أصلية بدقة 4096×4096 تُستخدم كلون أساسي ظاهر لمواد القرية والسوق والمناطق الخارجية. وأُضيفت 14 خريطة BMP أصلية بدقة 512×512 لتفاصيل استجابة السطح والخشونة: الإسفلت والحجارة والقرميد وأرض الغابة والخشب والجرانيت وفسيفساء السوق وبستان الزيتون والرخام والحجر الرملي وطين النهر والحجر المبلل والمعدن ورصيف الميناء.

تُربط الخرائط الأربع عشرة بقناة الخشونة الحمراء للمواد المطابقة، مع الحفاظ على خامات SVG الأصلية كطبقة اللون الأساسية. ويتحقق اختبار Godot من استيراد وربط جميع الخامات والخرائط الـ46.
