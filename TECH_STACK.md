# 🛠️ Tech Stack & Architecture

**Crafta iOS App - Technical Foundation**

---

## 🎯 Design Principles

1. **iOS-Native First** - Leverage Apple's frameworks
2. **Offline-First** - Work without internet when possible
3. **Simple & Maintainable** - Solo developer friendly
4. **Safe by Default** - Privacy and security built-in
5. **Fast Iteration** - Choose tools that enable quick changes

---

## 📱 Core Technology Stack

### Frontend / App Framework
**Choice: SwiftUI**

**Why:**
- Native iOS performance
- Modern, declarative syntax (easier to maintain)
- Built-in accessibility features
- Excellent voice/speech API integration
- Rapid prototyping and iteration
- Small app bundle size

**Alternatives Considered:**
- ❌ React Native: Adds JavaScript bridge overhead, less native feel
- ❌ Flutter: Extra learning curve, larger app size
- ❌ UIKit: More code, older patterns

**Decision:** SwiftUI for all UI components

---

### Voice Input
**Choice: Apple Speech Framework (offline mode)**

**Why:**
- Native iOS speech-to-text
- Works offline (privacy!)
- Optimized for kids' voices with proper setup
- No API costs
- Real-time recognition
- Built-in error handling

**Implementation:**
```swift
import Speech

// Request authorization
SFSpeechRecognizer.requestAuthorization()

// Use on-device recognition
let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
recognizer?.supportsOnDeviceRecognition = true
```

**Fallback:**
- If offline fails, optionally use Whisper.cpp (local model)
- Or OpenAI Whisper API (requires internet)

**MVP Decision:** Apple Speech only, offline-first

---

### AI Conversation Brain
**Choice: OpenAI GPT-4o-mini API**

**Why:**
- Excellent at child-friendly conversation
- Fast response times (< 2 seconds)
- Affordable ($0.15 per 1M input tokens)
- Easy to implement safety filters
- JSON mode for structured outputs
- Can run locally for testing with mock responses

**Configuration:**
```
Model: gpt-4o-mini
Temperature: 0.7 (creative but consistent)
Max Tokens: 150 (short, focused responses)
System Prompt: Loaded from Crafta_AI_Rules.md
```

**API Management:**
- Store API key in Xcode secrets (not in code)
- Implement retry logic (3 attempts)
- Graceful fallback to pre-written responses if offline

**Cost Estimate:**
- 1,000 conversations/month ≈ $0.50 USD
- Very affordable for MVP testing

**Alternatives Considered:**
- ❌ Claude API: Good but more expensive for this use case
- ❌ Local LLM (Core ML): Too large, slow on device
- ❌ Gemini: Less consistent personality in testing

---

### Voice Output
**Choice: OpenAI Text-to-Speech API**

**Why:**
- High quality, natural voices
- "Nova" or "Shimmer" voices perfect for Crafta
- Affordable ($15 per 1M characters)
- Fast streaming
- Can cache common phrases

**Configuration:**
```
Voice: "nova" or "shimmer" (warm, friendly)
Model: tts-1 (faster, lower latency)
Speed: 0.9x (slightly slower for clarity)
```

**Alternative for MVP:**
- Apple AVSpeechSynthesizer (free, offline)
- Less natural but good enough for testing
- Switch to OpenAI TTS later

**Decision:** Start with Apple TTS, upgrade to OpenAI if budget allows

---

### Mod Generation
**Choice: Swift + embedded JSON templates**

**Why:**
- Keep everything in Swift (no Python subprocess)
- JSON templates as embedded resources
- Simple string interpolation for attributes
- Easy to debug and test

**Architecture:**
```
ModGenerator.swift
├── Templates/
│   ├── entity_cow.json
│   ├── entity_pig.json
│   └── entity_chicken.json
├── Attributes/
│   ├── Colors.swift
│   └── Effects.swift
└── Exporter.swift (creates .mcaddon zip)
```

**Minecraft Bedrock Format:**
- Behavior Pack JSON (version 1.20+)
- Standard entity format
- Uses vanilla textures with modifications
- Zipped as `.mcaddon`

**Libraries:**
- Native FileManager for zip creation
- Or use ZipFoundation (lightweight Swift package)

---

### 3D/Visual Preview
**Choice: SwiftUI + Static Images with Overlays**

**Why:**
- Simplest possible implementation
- Fast rendering
- Low memory usage
- Can upgrade to SceneKit later

**Implementation:**
```swift
ZStack {
    Image("base_cow")  // Base creature
        .colorMultiply(selectedColor)  // Color overlay

    if hasSparkles {
        Image("sparkle_effect")  // Effect layer
            .blendMode(.screen)
    }

    if hasGlow {
        Image("glow_effect")
            .blendMode(.softLight)
    }
}
```

**Assets Needed:**
- 3 base creatures (cow, pig, chicken) - PNG, transparent
- 5 effect overlays (sparkles, glow, tiny, big, flying)
- Simple, colorful, 2D art style

**Future Upgrade Path:**
- Phase 2: Add SceneKit for 3D rotation
- Phase 3: Add RealityKit for AR preview

**MVP Decision:** Static 2D images with color filters

---

## 📊 Data Storage

### Local Storage
**Choice: SwiftUI @AppStorage + FileManager**

**Why:**
- No database overhead
- Simple key-value storage for settings
- File system for created mods
- Easy to clear/reset

**Structure:**
```
App Documents/
├── creations/
│   ├── rainbow_cow_001.json
│   ├── sparkle_pig_002.json
│   └── ...
├── exports/
│   ├── rainbow_cow.mcaddon
│   └── ...
└── settings.json
```

**What to Store:**
- User preferences (parent settings)
- Creation history (name, date, attributes)
- Exported mod files (for re-sharing)

**What NOT to Store:**
- Voice recordings (privacy!)
- Personal information
- Conversation logs (unless parent opts in)

---

## 🔒 Security & Privacy

### Data Protection
- All voice processing local when possible
- API calls over HTTPS only
- No telemetry/analytics in MVP
- No third-party SDKs (except OpenAI client)

### Parent Controls
```swift
struct ParentSettings: Codable {
    var requirePasscodeForSettings: Bool = true
    var allowInternetForAI: Bool = false
    var allowSharing: Bool = false
    var passcodeHash: String? = nil
}
```

### App Permissions Required
- Microphone (for voice input)
- Files (for mod export)

**NOT Required:**
- Camera
- Location
- Contacts
- Photos (unless kid wants to save preview image)

---

## 🔌 External Dependencies

### Swift Packages
1. **OpenAI Swift** (unofficial but well-maintained)
   - API client for GPT and TTS
   - https://github.com/MacPaw/OpenAI

2. **ZipFoundation** (optional, if needed)
   - Zip file creation
   - https://github.com/weichsel/ZIPFoundation

3. **That's it!** Keep dependencies minimal

### Assets
- Creature illustrations (commission or AI-generate)
- Effect overlays (design in Figma/Affinity)
- Crafta avatar (friendly character icon)

---

## 🏗️ App Architecture

### Pattern: MVVM (Model-View-ViewModel)

**Why:**
- Perfect for SwiftUI
- Clear separation of concerns
- Testable business logic
- Apple-recommended pattern

### Structure
```
Crafta/
├── App/
│   ├── CraftaApp.swift (entry point)
│   └── ContentView.swift (navigation)
├── Views/
│   ├── WelcomeView.swift
│   ├── CreatorView.swift
│   ├── CompleteView.swift
│   └── ParentSettingsView.swift
├── ViewModels/
│   ├── ConversationViewModel.swift
│   ├── ModGeneratorViewModel.swift
│   └── VoiceRecognitionViewModel.swift
├── Models/
│   ├── Creation.swift
│   ├── Creature.swift
│   └── Attribute.swift
├── Services/
│   ├── SpeechService.swift
│   ├── AIService.swift
│   ├── TTSService.swift
│   └── ModExportService.swift
├── Templates/
│   └── JSON templates for entities
├── Resources/
│   ├── Images/
│   ├── Sounds/
│   └── Prompts/
└── Utilities/
    ├── Constants.swift
    └── Extensions.swift
```

---

## 🎨 UI/UX Technical Details

### Design System
```swift
// Colors.swift
extension Color {
    static let craftaPrimary = Color(hex: "FF6B9D") // Soft pink
    static let craftaSecondary = Color(hex: "98D8C8") // Mint
    static let craftaAccent = Color(hex: "F7DC6F") // Soft yellow
    static let craftaBackground = Color(hex: "FFF9F0") // Cream
}

// Typography.swift
extension Font {
    static let craftaTitle = Font.system(size: 32, weight: .bold, design: .rounded)
    static let craftaBody = Font.system(size: 18, weight: .medium, design: .rounded)
    static let craftaButton = Font.system(size: 20, weight: .semibold, design: .rounded)
}
```

### Animation Guidelines
- Gentle spring animations (duration: 0.3-0.5s)
- Soft haptic feedback (UIImpactFeedbackGenerator)
- Loading states: Simple spinner + encouraging text
- No jarring transitions

### Accessibility
- VoiceOver support for all buttons
- Large tap targets (min 44x44 points)
- High contrast mode support
- Adjustable text size (Dynamic Type)

---

## 🧪 Testing Strategy

### Unit Tests
```swift
// Test mod generation
func testModGeneration() {
    let attributes = CreatureAttributes(
        type: .cow,
        color: .rainbow,
        effect: .sparkles,
        size: .tiny
    )

    let mod = ModGenerator.generate(from: attributes)
    XCTAssertNotNil(mod)
    XCTAssertTrue(mod.isValid())
}
```

### UI Tests (Limited for MVP)
- Test main flow: Welcome → Creator → Complete
- Test voice button tap and recording start
- Test export button and share sheet

### Manual Testing Checklist
- [ ] Voice recognition accuracy (various phrases)
- [ ] AI response appropriateness (safety)
- [ ] Mod imports successfully in Minecraft
- [ ] Creature appears in-game correctly
- [ ] App doesn't crash on common errors
- [ ] Parent settings work as expected

---

## 📦 Build & Deployment

### Xcode Configuration
- Minimum iOS version: **iOS 16.0**
- Target devices: iPhone (iPad compatible)
- Bundle ID: `com.yourname.crafta`
- App Category: Entertainment / Education

### Environment Variables
```swift
// Config.swift
enum Config {
    static let openAIKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    static let isProduction = ProcessInfo.processInfo.environment["ENV"] == "production"

    #if DEBUG
    static let useLocalAI = true  // Mock responses for testing
    #else
    static let useLocalAI = false
    #endif
}
```

### TestFlight Distribution
- Internal testing: 1-2 parent testers
- External testing: 5-10 families
- Collect feedback via form (Google Forms)

### App Store Preparation
- App Store Connect listing
- Privacy policy (required!)
- Screenshots (iPhone + iPad)
- App preview video (optional but recommended)
- Age rating: 4+ (suitable for young children)

---

## 💰 Cost Breakdown (Monthly)

| Service | Usage | Cost |
|---------|-------|------|
| OpenAI API (GPT-4o-mini) | ~1000 conversations | $0.50 |
| OpenAI API (TTS) | ~500 voice lines | $0.08 |
| Apple Developer Account | Annual: $99 | $8.25/mo |
| **Total** | | **~$9/month** |

**Notes:**
- API costs scale with usage
- No server costs (all local/API-based)
- No database costs
- Very affordable for solo dev MVP

---

## 🚀 Performance Targets

### Speed
- Voice recognition start: < 500ms
- AI response: < 2 seconds
- Mod generation: < 1 second
- Export creation: < 3 seconds
- Total flow: < 2 minutes

### Memory
- Idle: < 50 MB
- Active (recording): < 80 MB
- Peak (mod generation): < 100 MB

### Battery
- 10 minutes of active use: < 5% battery drain
- Background usage: None (app doesn't run in background)

---

## 🔄 Future Technical Enhancements

### Phase 2 Additions
- SceneKit 3D previewer
- Core ML for local AI (privacy improvement)
- CloudKit sync (optional, parent-approved)
- More sophisticated mod templates

### Phase 3 Possibilities
- RealityKit AR preview (place creature in real world)
- Custom texture generation (AI-based)
- Multi-language support
- Apple Watch companion (quick voice creation)

### Not Planned (Complexity too high)
- Android version
- Web version
- Multiplayer features
- In-app Minecraft clone

---

## 🧩 Technical Risks & Mitigations

### Risk 1: Voice Recognition Accuracy with Kids
**Mitigation:**
- Test with real kids early
- Provide visual buttons as fallback
- Allow text input as alternative
- Use larger vocab model if needed

### Risk 2: Minecraft Format Changes
**Mitigation:**
- Target stable version (1.20.x)
- Keep templates simple and standard
- Test on real devices regularly
- Community resources for updates

### Risk 3: AI Safety (Inappropriate Responses)
**Mitigation:**
- Strong system prompts (from AI_Rules)
- Content filtering on input AND output
- Parent reporting feature
- Regular monitoring during testing

### Risk 4: API Costs Spike
**Mitigation:**
- Rate limiting (5 conversations per hour per device)
- Cache common responses
- Fallback to pre-written dialogue
- Local AI as ultimate fallback

### Risk 5: App Store Rejection
**Mitigation:**
- Follow Apple guidelines strictly
- Clear privacy policy
- Parental controls prominent
- Age rating accurate (4+)
- No data collection without consent

---

## 📚 Learning Resources

### SwiftUI
- Apple's SwiftUI Tutorials
- Hacking with Swift (Paul Hudson)
- SwiftUI Lab

### Speech Recognition
- Apple's Speech Framework Docs
- WWDC Sessions on Speech

### Minecraft Bedrock Modding
- Bedrock Wiki: https://wiki.bedrock.dev
- Minecraft Creator Portal
- Community Discord servers

### OpenAI APIs
- OpenAI Cookbook
- Official Python examples (adapt to Swift)
- GPT best practices guide

---

## ✅ Technical Readiness Checklist

Before starting development:
- [ ] Xcode installed (latest version)
- [ ] Apple Developer account active
- [ ] OpenAI API account created
- [ ] API keys secured
- [ ] Test iOS device available (iPhone)
- [ ] Minecraft Bedrock installed (for testing)
- [ ] Basic Swift/SwiftUI knowledge confirmed
- [ ] Git repository set up
- [ ] Planning documents reviewed

---

## 🎯 Success Criteria (Technical)

### MVP is technically ready when:
- [ ] Speech recognition works reliably (80%+ accuracy)
- [ ] AI responses are consistently safe and on-brand
- [ ] Generated mods import without errors
- [ ] Creatures appear correctly in-game
- [ ] App runs without crashes for 30+ minutes
- [ ] Memory usage stays under 100MB
- [ ] Parental controls prevent unintended actions
- [ ] All data stays local unless explicitly shared

---

## 📝 Technical Debt to Track

**Acceptable for MVP:**
- Hardcoded JSON templates (not procedural generation)
- Simple file storage (not database)
- Basic error messages (not comprehensive)
- Mock 3D with images (not real 3D)
- Single language support (English only)
- iPhone-optimized only (basic iPad support)

**Pay Down in V2:**
- Add proper database (Core Data or Realm)
- Implement sophisticated error handling
- Build real 3D previewer
- Add multiple languages
- Optimize for iPad layouts
- Add undo/redo functionality

---

*Version 1.0 — October 15, 2025*
*Part of the Crafta Project Planning Documents*
*Focused on iOS, Swift, and simplicity.*
