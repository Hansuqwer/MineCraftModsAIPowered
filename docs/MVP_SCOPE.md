# 🎯 MVP Scope - Crafta v1.0

**Keep It Simple. Ship Something Magical.**

---

## 🎨 Philosophy

**MVP Goal:** Prove the core concept works - kids can talk to Crafta and get a working Minecraft mod.

**NOT the goal:** Build every feature from the vision document.

**Mantra:** "One magical experience, done well."

---

## ✅ What's IN the MVP (Must-Have)

### 1. Core Voice Interaction ⭐
**The Magic Moment**
- [ ] Kid taps microphone button
- [ ] Says: "I want a rainbow cow"
- [ ] Crafta responds: "Cool! Should it moo sparkles?"
- [ ] Kid answers: "Yes!"
- [ ] Crafta generates the mod

**Technical Requirements:**
- Apple Speech API for voice-to-text (offline)
- Simple GPT-4o-mini API call for conversation
- 2-3 round conversation max
- Text display + voice output (OpenAI TTS or local)

**Limits for MVP:**
- Only **3 creature types** supported: Cow, Pig, Chicken (familiar to kids)
- Only **5 attributes** to modify:
  - Color (rainbow, pink, blue, gold)
  - Special effect (sparkles, glows, flies)
  - Size (tiny, normal, big)
  - Friendly/Neutral behavior
  - Sound (custom moo/oink/cluck variants)

---

### 2. Simple Visual Preview 🎨
**What Kids See:**
- A cartoon-style 2D or simple 3D representation
- Shows their creature with chosen colors/effects
- Not a full 3D viewer - just a static or gently animated image

**Technical:**
- Pre-made art assets for the 3 base creatures
- Color filters/overlays for variations
- Sparkle/glow effects as image layers
- SceneKit OR just SwiftUI with images (simpler!)

**MVP Limit:**
- **Static images only** with overlays
- No interactive 3D rotation
- Pre-rendered variations (not procedural)

---

### 3. Mod Generation & Export 📦
**The Delivery:**
- Generate a `.mcaddon` file
- "Send to Minecraft" button
- iOS share sheet → direct import to Minecraft

**Technical:**
- JSON template library for each creature type
- Python script (or Swift) to fill in attributes
- Zip file creation with proper folder structure
- Behavior pack only (no custom textures in MVP)

**MVP Limit:**
- Uses **vanilla Minecraft textures** with modifications
- No custom 3D models
- Pre-built JSON templates with variable substitution

---

### 4. Minimal UI (3 Screens) 🖼️
**Screen 1: Welcome**
- Big "Start Creating" button
- Crafta's welcome message (voice + text)
- Parent settings icon (small, top corner)

**Screen 2: Creator**
- Large microphone button (center)
- Crafta's face/avatar with speech bubble
- Visual preview area (top)
- Simple "Start Over" button

**Screen 3: Complete**
- Preview of creation
- "Send to Minecraft" button
- "Make Another" button
- Optional: Share button (with parental gate)

**MVP Design:**
- SwiftUI stock components styled nicely
- Pastel color palette
- Large, kid-friendly buttons
- Minimal text, maximum clarity

---

### 5. Parent Controls (Bare Minimum) 🛡️
**What Parents Need:**
- Toggle: Allow/block AI internet access
- Toggle: Voice recognition on/off
- View: List of created mods
- Button: Clear all data

**MVP Limit:**
- Settings accessible via passcode (simple 4-digit)
- No analytics, no usage tracking
- No cloud sync
- All local storage

---

## ❌ What's OUT of MVP (Save for v2+)

### Features to Defer:
- ❌ Custom textures/skins
- ❌ Blocks, items, biomes (creatures only)
- ❌ "Surprise Me" feature
- ❌ Achievement/badge system
- ❌ Story mode / quests
- ❌ Multi-child profiles
- ❌ Social sharing features
- ❌ Advanced 3D previewer
- ❌ In-app testing sandbox
- ❌ More than 3 creature types
- ❌ Animations beyond basic overlays
- ❌ "Remix This" feature
- ❌ Voice customization for Crafta
- ❌ Multiple languages (English only for MVP)
- ❌ iPad-specific layouts (iPhone-first)
- ❌ Learn Mode (educational layer)
- ❌ Collaboration features

### Technical Debt OK for MVP:
- Hardcoded JSON templates (not procedural)
- Simple file storage (not database)
- Basic error handling (not comprehensive)
- No undo/redo functionality
- Limited voice command vocabulary
- No conversation memory beyond current session

---

## 📊 MVP Success Metrics

**Qualitative:**
1. Can a 5-year-old complete the flow with minimal adult help?
2. Does the generated mod actually work in Minecraft?
3. Do kids smile/get excited when they see their creation?
4. Do parents feel it's safe?

**Quantitative:**
1. < 2 minutes from start to exported mod
2. 90%+ accuracy in voice recognition (common requests)
3. Zero crashes during core flow
4. 100% of generated mods successfully import

---

## 🚀 Development Phases

### Phase 1: Foundation (Week 1-2)
- [ ] Set up Xcode project with SwiftUI
- [ ] Implement Apple Speech API
- [ ] Create basic UI skeleton (3 screens)
- [ ] Connect to OpenAI API (GPT + TTS)
- [ ] Test basic "Hello Crafta" voice loop

### Phase 2: Conversation Engine (Week 3-4)
- [ ] Build conversation flow logic
- [ ] Create prompt templates for 3 creatures
- [ ] Implement attribute selection (color, effect, size)
- [ ] Test with sample voice inputs
- [ ] Refine GPT prompts for kid-friendly responses

### Phase 3: Visual Preview (Week 5)
- [ ] Create/source base creature images
- [ ] Implement color filter overlays
- [ ] Add sparkle/glow effect layers
- [ ] Build preview display component
- [ ] Test visual variations

### Phase 4: Mod Generation (Week 6-7)
- [ ] Create JSON template library
- [ ] Build template fill-in logic
- [ ] Generate .mcaddon file structure
- [ ] Implement zip file creation
- [ ] Test imports in Minecraft Bedrock iOS

### Phase 5: Polish & Parent Features (Week 8)
- [ ] Add parent settings screen
- [ ] Implement parental gate (passcode)
- [ ] Add data clearing functionality
- [ ] Polish UI animations and sounds
- [ ] Error handling and edge cases

### Phase 6: Testing (Week 9-10)
- [ ] Internal testing (you)
- [ ] Parent tester feedback (1-2 parents)
- [ ] Kid testing (3-5 children, ages 4-10)
- [ ] Bug fixes and refinements
- [ ] Final safety review

---

## 🎯 MVP Feature Matrix

| Feature | Complexity | Priority | Status |
|---------|-----------|----------|---------|
| Voice input | Medium | P0 | Not Started |
| Basic conversation | Medium | P0 | Not Started |
| Creature selection (3 types) | Low | P0 | Not Started |
| Attribute modification (5 types) | Low | P0 | Not Started |
| Simple visual preview | Medium | P0 | Not Started |
| Mod generation | High | P0 | Not Started |
| .mcaddon export | Medium | P0 | Not Started |
| Welcome screen | Low | P0 | Not Started |
| Creator screen | Medium | P0 | Not Started |
| Complete screen | Low | P0 | Not Started |
| Parent settings | Low | P1 | Not Started |
| Voice output (TTS) | Low | P1 | Not Started |
| Error messages | Low | P1 | Not Started |

**P0** = Must have for launch
**P1** = Should have but can be basic
**P2** = Nice to have (defer if needed)

---

## 💡 Simplification Decisions

### Why Only 3 Creatures?
- Reduces JSON template work
- Easier to test thoroughly
- Kids understand familiar animals
- Can expand post-MVP once proven

### Why No Custom Textures?
- Massive complexity
- Requires art pipeline
- Vanilla textures are "safe" and work
- Parents already trust vanilla assets

### Why Static Preview?
- Full 3D viewer is weeks of work
- Kids care more about "does it work?" than pretty preview
- Can add later once core experience validated

### Why No Badges/Achievements?
- Adds database complexity
- Not core to "create and play" flow
- Can become feature creep
- Better as v2 retention feature

### Why Offline-First?
- Builds parental trust immediately
- No server costs during testing
- Simpler architecture
- Can add cloud features later

---

## 🧪 MVP Validation Questions

Before adding ANY feature, ask:

1. **Does this prove the core concept?**
   - If NO → defer

2. **Can a kid complete the experience without it?**
   - If YES → defer

3. **Will it take more than 3 days to build?**
   - If YES → simplify or defer

4. **Does it add complexity to the core flow?**
   - If YES → strong justification needed

5. **Is it required for parental trust/safety?**
   - If YES → keep, but make it simple

---

## 📝 MVP Definition of Done

### The app is ready for testing when:
- [ ] A child can speak a request and see a result
- [ ] The generated mod imports into Minecraft without errors
- [ ] The mod works as described in the conversation
- [ ] Parents can access basic settings and data controls
- [ ] No crashes during the happy path
- [ ] Voice recognition works for common phrases
- [ ] Crafta's personality feels warm and kid-friendly

### The MVP is ready to launch when:
- [ ] 3 parent testers approve safety
- [ ] 5 kid testers complete flow successfully
- [ ] All P0 features work reliably
- [ ] Mods work on at least 2 different iOS devices
- [ ] App Store requirements met (if publishing)
- [ ] Privacy policy written (even if simple)

---

## 🎬 The MVP "Movie Trailer"

**Imagine showing this to investors/friends:**

> "Meet Crafta. A 6-year-old opens the app and says, 'I want a rainbow cow that sparkles.' Crafta asks, 'Should it be tiny or huge?' The kid says 'Tiny!' Within seconds, they tap 'Send to Minecraft' and their creation is in their game. No coding. Just imagination."

**That's the MVP. That moment of magic.**

Everything else can wait.

---

## 🚦 Go/No-Go Criteria

### Proceed to Development if:
- [x] Core concept validated (this document)
- [ ] Technical feasibility confirmed (can you actually generate mods?)
- [ ] Speech API tested and working
- [ ] OpenAI API access secured
- [ ] Time commitment realistic (10 weeks part-time)

### Pause if:
- [ ] Minecraft mod import proves too complex
- [ ] Voice recognition inadequate for kids
- [ ] Parental concerns arise during early testing
- [ ] GPT costs are prohibitive

---

## 📊 Estimated MVP Timeline

**Solo Developer, Part-Time (10-20 hrs/week):**
- Foundation: 2 weeks
- Conversation: 2 weeks
- Visual: 1 week
- Mod Generation: 2 weeks
- Polish: 1 week
- Testing: 2 weeks

**Total: 10 weeks** (2.5 months)

**Full-Time Equivalent: ~4-5 weeks**

---

## 🎯 Success Looks Like...

**At the end of MVP development:**
- A parent hands their iPad to their 6-year-old
- The kid opens Crafta
- 2 minutes later, they're running around Minecraft with their creation
- The parent feels good about it
- The kid wants to make another one

**If that happens → MVP succeeded.**

---

*Version 1.0 — October 15, 2025*
*Part of the Crafta Project Planning Documents*
*Remember: Ship something magical, not something perfect.*
