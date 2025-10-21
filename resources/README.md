# 🎨 Resources Folder

This folder contains all assets and content used in the Crafta iOS app.

---

## 📁 Structure

```
resources/
├── images/          # Visual assets (icons, creature previews, UI elements)
├── sounds/          # Audio files (sound effects, optional music)
└── prompts/         # Text files with AI prompt templates
```

---

## 🖼️ Images Folder

### What Goes Here
- **Creature Previews:** 2D illustrations of cow, pig, chicken
- **Effect Overlays:** Sparkle, glow, flying wing effects
- **UI Icons:** Buttons, badges, navigation elements
- **Crafta Avatar:** The friendly AI companion character
- **Loading Animations:** Progress indicators
- **Achievement Badges:** Reward icons

### File Format Guidelines
- **Format:** PNG with transparency preferred
- **Size:** Various (documented per asset type below)
- **Color Space:** sRGB
- **Compression:** Optimize for iOS (use ImageOptim or similar)

### Asset Specifications

| Asset Type | Size (px) | Format | Notes |
|-----------|-----------|--------|-------|
| Creature Base | 512x512 | PNG | Transparent background, centered |
| Effect Overlay | 512x512 | PNG | Blend modes: screen, multiply |
| App Icon | 1024x1024 | PNG | No transparency, rounded by iOS |
| UI Button | 88x88 | PNG | @2x and @3x variants |
| Badge Icon | 256x256 | PNG | Circular or shield shape |
| Crafta Avatar | 512x512 | PNG | Multiple expressions optional |

### Naming Convention
```
creature_cow_base.png
creature_pig_base.png
effect_sparkles.png
effect_glow.png
ui_button_mic.png
ui_button_mic@2x.png
badge_rainbow_creator.png
crafta_avatar_happy.png
```

### Design Style Guide
- **Colors:** Soft pastels (pink, mint, lavender, yellow)
- **Shapes:** Rounded corners, no sharp edges
- **Mood:** Playful, safe, inviting
- **Inspiration:** Animal Crossing meets Minecraft
- **Child-Safe:** No scary faces, dark themes, or complex details

---

## 🔊 Sounds Folder

### What Goes Here
- **UI Sounds:** Button taps, confirmations, errors
- **Celebration:** Success fanfares, confetti sounds
- **Ambient:** Optional background music (subtle)
- **Voice Cues:** Optional audio feedback

### File Format Guidelines
- **Format:** M4A or WAV
- **Sample Rate:** 44.1kHz
- **Bit Depth:** 16-bit minimum
- **Duration:** Keep UI sounds under 1 second
- **Volume:** Normalize to -3dB peak

### Sound Specifications

| Sound Type | Duration | Format | Notes |
|------------|----------|--------|-------|
| Button Tap | 0.1-0.3s | M4A | Soft "bloop" or click |
| Success | 1-2s | M4A | Rising chime, magical |
| Error | 0.5s | M4A | Gentle "bonk", not harsh |
| Celebration | 2-3s | M4A | Sparkle twinkle + soft fanfare |
| Ambient BG | Loop | M4A | Optional, very subtle |

### Naming Convention
```
ui_tap.m4a
ui_success.m4a
ui_error.m4a
celebration_badge_earned.m4a
ambient_background_loop.m4a
```

### Audio Guidelines
- **Never Jarring:** All sounds should be gentle
- **Kid-Friendly:** No loud, sharp, or scary sounds
- **Accessible:** Consider users with hearing sensitivity
- **Optional:** All audio must have a mute option

---

## 📝 Prompts Folder

### What Goes Here
- **System Prompts:** Instructions for GPT conversation flow
- **Response Templates:** Pre-written Crafta dialogue
- **Safety Filters:** Content moderation rules
- **Example Conversations:** Training/testing data

### File Structure
```
prompts/
├── system_prompt.txt          # Main AI personality prompt
├── creature_questions.txt     # Clarifying questions for attributes
├── celebration_phrases.txt    # Success/encouragement messages
├── safety_guidelines.txt      # Content filtering rules
└── examples/
    ├── conversation_001.txt   # Sample dialogue flows
    └── conversation_002.txt
```

### System Prompt Template
See: `docs/Crafta_Prompt_Library.md` for complete prompt templates.

### Example: creature_questions.txt
```
Should it be tiny, normal size, or huge?
What color should it be?
Should it have sparkles or glow in the dark?
Do you want it to be friendly or shy?
Should it make a special sound?
```

---

## 🚫 What NOT to Include

### Never Add:
- ❌ Copyrighted images or sounds
- ❌ Personal photos or data
- ❌ Large files (> 5MB per asset)
- ❌ Source files (keep .psd, .sketch in separate working folder)
- ❌ Unused assets (clean up regularly)
- ❌ Scary, violent, or inappropriate content

---

## 🎨 Asset Creation Workflow

### For Images:

1. **Concept** - Sketch or describe the idea
2. **Generate** - Use AI image tools (Leonardo, Midjourney, DALL-E)
   - Prompt: "Soft 3D render, pastel colors, kid-friendly [subject], rounded edges, Minecraft-inspired"
3. **Edit** - Clean up in design tool (Figma, Affinity Designer)
4. **Optimize** - Compress for iOS
5. **Test** - View on actual iOS device
6. **Commit** - Add to git with descriptive name

### For Sounds:

1. **Source** - Create or use royalty-free libraries
   - Recommended: Epidemic Sound, Art List, freesound.org
2. **Edit** - Trim and adjust in audio editor (Audacity, GarageBand)
3. **Normalize** - Set consistent volume
4. **Export** - M4A format, 44.1kHz
5. **Test** - Listen on iPhone speaker (not just headphones)
6. **Commit** - Add to git

### For Prompts:

1. **Draft** - Write initial version
2. **Test** - Try with GPT in playground
3. **Refine** - Adjust based on responses
4. **Validate** - Check against Crafta Constitution
5. **Document** - Add usage notes
6. **Commit** - Version control

---

## 📊 Asset Inventory (Planning Phase)

### MVP Assets Needed:

**Images:**
- [ ] 3 creature base images (cow, pig, chicken)
- [ ] 3 effect overlays (sparkles, glow, wings)
- [ ] 5 UI button icons (mic, back, settings, export, help)
- [ ] 1 Crafta avatar
- [ ] 3 achievement badges
- [ ] 1 app icon
- [ ] Loading spinner

**Sounds:**
- [ ] Button tap sound
- [ ] Success chime
- [ ] Gentle error sound
- [ ] Celebration fanfare
- [ ] Badge earned sound

**Prompts:**
- [ ] Main system prompt
- [ ] Creature attribute questions
- [ ] 20 celebration phrases
- [ ] Safety filter rules
- [ ] 5 example conversations

**Total Estimated:** ~20 images, ~5 sounds, ~5 text files

---

## 🔄 Version Control

### What to Commit:
- ✅ Final, optimized assets only
- ✅ README files and documentation
- ✅ Prompt templates

### What to Ignore (see .gitignore):
- ❌ Source files (.psd, .sketch, .fig)
- ❌ Working files
- ❌ Very large files
- ❌ Generated test content

---

## 📝 Attribution

### If Using Third-Party Assets:
1. Create `ATTRIBUTION.txt` in each folder
2. List source, license, and creator
3. Ensure license permits commercial use
4. Give proper credit

Example:
```
File: button_tap.m4a
Source: freesound.org
Creator: UserName123
License: CC0 (Public Domain)
URL: https://freesound.org/example
```

---

## 🎯 Quality Checklist

Before adding any asset:
- [ ] Appropriate for ages 4-10
- [ ] Matches Crafta's visual/audio style
- [ ] Optimized file size
- [ ] Tested on iOS device
- [ ] Properly named
- [ ] Licensed for use
- [ ] Documented if needed

---

## 🚀 Future Expansion

### Phase 2:
- More creature variations
- Animation sprite sheets
- Localized prompts (multi-language)
- Seasonal theme assets

### Phase 3:
- AR models for preview
- Custom sound effects per creature
- Voice packs for Crafta
- Themed UI skins

---

## 📞 Questions?

If you need to create or source assets, refer to:
- `docs/CONCEPT_DOCUMENT.md` for visual style guide
- `docs/Crafta_AI_Rules.md` for content safety rules
- `docs/Crafta_Prompt_Library.md` for AI prompts

---

*Last Updated: October 15, 2025*
*Part of the Crafta Project*
