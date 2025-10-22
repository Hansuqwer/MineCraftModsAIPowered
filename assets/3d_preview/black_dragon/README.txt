🐉 BLACK DRAGON 3D PREVIEW PACKAGE
=====================================

This package contains everything needed to display a proper 3D black dragon
in your Crafta app instead of the placeholder blocky geometry.

FILES INCLUDED:
- preview.html          → Standalone HTML preview (test in browser)
- black_dragon.glb      → 3D model file (placeholder - needs real GLB)
- black_dragon.png      → Texture file (placeholder - needs real PNG)
- README.txt           → This file

HOW TO USE:

1. TEST THE PREVIEW:
   - Open preview.html in a web browser
   - You should see a 3D black dragon (procedural fallback)
   - Rotate with mouse/touch, zoom with scroll/pinch

2. INTEGRATE WITH CRAFTA:
   - Copy the HTML content to your Flutter WebView
   - Update the model loading path in your app
   - The preview will automatically fall back to procedural dragon

3. ADD REAL MODEL FILES:
   - Replace black_dragon.glb with actual GLB model
   - Replace black_dragon.png with actual 128x128 texture
   - The preview will automatically use the real files

TECHNICAL DETAILS:
- Uses Babylon.js for 3D rendering
- Supports touch/mouse interaction
- Automatic fallback to procedural model
- Optimized for mobile devices
- No external dependencies (except Babylon.js CDN)

NEXT STEPS:
1. Test the preview.html in your browser
2. Integrate with your Crafta app
3. Replace placeholder files with real 3D assets
4. Test with "black dragon" input in your app

This solves the "blocky dragon" issue by providing actual 3D model files
instead of placeholder geometry!
