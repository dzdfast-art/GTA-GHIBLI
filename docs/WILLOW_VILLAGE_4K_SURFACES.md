# Willow Village — Original 4K Surface Library

## English
The project includes 32 original, tileable 4096×4096 SVG surface materials for the village, market lane, and outer district plots. The procedural village binds the materials to matching mesh colors; twelve additional walkable district plots extend the environment with alley brick, dry grass, granite curb, industrial concrete, mosaic tile, olive grove, plaza marble, red sandstone, river mud, road markings, roof slate, and wet stone. The regression test checks all 32 source textures for 4K import dimensions and verifies that each material sample resolves to its expected texture.

Run the checks with:
`godot --headless --editor --path . --quit`
`godot --headless --path . --script res://tests/village_surface_texture_test.gd`

## العربية
يضم المشروع 32 خامة سطح أصلية قابلة للتكرار بدقة 4096×4096 بصيغة SVG للقرية والسوق والمناطق الخارجية. يربط نظام المواد الخامات بالألوان المطابقة لمجسمات العالم. وأُضيفت 12 مساحة أرضية قابلة للمشي بخامات الطوب الجانبي والعشب الجاف والجرانيت والخرسانة الصناعية والفسيفساء وبستان الزيتون ورخام الساحة والحجر الرملي الأحمر وطين النهر وعلامات الطريق وأردواز الأسقف والحجر المبلل.

يفحص اختبار الانحدار استيراد الخامات الـ32 بدقة 4K، ويتحقق من أن كل عينة مادة تستخدم الخامة الصحيحة.

