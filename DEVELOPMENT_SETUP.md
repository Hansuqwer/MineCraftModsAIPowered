# 🛠️ Development Setup Guide

This guide will help you set up your development environment for the Crafta iOS project.

---

## 📋 Prerequisites

### Required
- **macOS** (Monterey 12.0 or later recommended)
- **Xcode** 14.0+ ([Download from App Store](https://apps.apple.com/us/app/xcode/id497799835))
- **iOS Device** (iPhone or iPad) with iOS 16.0+ for testing
- **Git** (comes with Xcode Command Line Tools)

### Recommended
- **GitHub Account** for version control
- **OpenAI Account** for API access (when implementing AI features)
- **Minecraft Bedrock Edition** (iOS) for testing mods

---

## 🚀 Quick Start

### 1. Install Command Line Tools

```bash
# Check if already installed
xcode-select -p

# If not installed:
xcode-select --install
```

### 2. Clone the Repository

```bash
# Clone the project
git clone https://github.com/Hansuqwer/MineCraftModsAIPowered.git
cd MineCraftModsAIPowered

# Or if you forked it:
git clone https://github.com/YOUR_USERNAME/MineCraftModsAIPowered.git
cd MineCraftModsAIPowered
```

### 3. Review Planning Documents

Before writing any code, read:
- [docs/MVP_SCOPE.md](docs/MVP_SCOPE.md) - What to build
- [docs/TECH_STACK.md](docs/TECH_STACK.md) - How to build it
- [docs/Crafta_AI_Rules.md](docs/Crafta_AI_Rules.md) - Safety guidelines

---

## 📱 Setting Up Xcode

### Create the Xcode Project

**Note:** The Xcode project doesn't exist yet. When development begins:

1. Open Xcode
2. Create New Project → iOS → App
3. Settings:
   - **Product Name:** Crafta
   - **Team:** Your Apple Developer Team
   - **Organization Identifier:** com.yourname (or your domain)
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Storage:** None (we'll handle manually)
4. Save in project root directory

### Project Configuration

**Minimum Deployment Target:** iOS 16.0

**Capabilities to Enable:**
- Speech Recognition
- Microphone Access

**Don't Enable:**
- Push Notifications
- Background Modes (not needed for MVP)
- Location Services
- Camera
- Photo Library

### Folder Structure in Xcode

Create groups matching this structure:
```
Crafta/
├── App/
│   ├── CraftaApp.swift
│   └── ContentView.swift
├── Views/
├── ViewModels/
├── Models/
├── Services/
├── Resources/
└── Utilities/
```

---

## 🔑 API Keys Setup

### OpenAI API Key

1. Create account at [platform.openai.com](https://platform.openai.com)
2. Generate API key in dashboard
3. Add to Xcode as environment variable (NOT in code)

**Method 1: Xcode Scheme (Recommended for Development)**
```
1. Product → Scheme → Edit Scheme
2. Run → Arguments → Environment Variables
3. Add: OPENAI_API_KEY = your_key_here
```

**Method 2: Config File (For Production)**
```swift
// Create Config.swift (add to .gitignore)
enum Config {
    static let openAIKey = "your_key_here" // DO NOT COMMIT THIS
}
```

**⚠️ Never commit API keys to Git!**

---

## 📦 Dependencies

### Swift Package Manager

Add these packages when needed:

**OpenAI Swift Client:**
```
https://github.com/MacPaw/OpenAI
Version: Latest stable
```

**ZipFoundation (for .mcaddon creation):**
```
https://github.com/weichsel/ZIPFoundation
Version: Latest stable
```

### Adding Packages in Xcode

1. File → Add Package Dependencies
2. Paste repository URL
3. Select version (use "Up to Next Major")
4. Add to Crafta target

---

## 🧪 Testing Setup

### Enable Speech Recognition in Simulator

**Note:** Speech recognition works better on real devices.

For simulator testing:
1. Run app on simulator
2. Grant microphone permission
3. Use Xcode console for voice input simulation

### Real Device Setup

**Required for final testing:**
1. Connect iPhone/iPad via USB
2. Trust computer on device
3. Enable Developer Mode (Settings → Privacy & Security)
4. Select device as run destination in Xcode
5. Build and run (⌘R)

### Minecraft Bedrock Testing

1. Install Minecraft Bedrock on iOS device
2. Generate test .mcaddon file
3. AirDrop or share to device
4. Open with Minecraft
5. Create new world with behavior pack enabled
6. Test creature spawning

---

## 🔧 Development Tools

### Recommended Tools

**Code Editor:**
- Xcode (primary)
- VS Code (for markdown/documentation)

**Design:**
- Figma (UI mockups)
- SF Symbols App (iOS icons)

**Audio:**
- GarageBand (sound editing)
- Audacity (free alternative)

**Image Optimization:**
- ImageOptim (compress assets)

**Version Control:**
- GitHub Desktop (if you prefer GUI)
- Fork or Tower (advanced Git clients)

### Useful Xcode Shortcuts

| Action | Shortcut |
|--------|----------|
| Build | ⌘B |
| Run | ⌘R |
| Stop | ⌘. |
| Clean Build | ⌘⇧K |
| Open Quickly | ⌘⇧O |
| Jump to Definition | ⌘ Click |
| Format Code | ⌃I |
| Show Console | ⌘⇧Y |

---

## 📂 Project Organization

### File Naming Conventions

**Swift Files:**
- Views: `CreatorView.swift`, `WelcomeView.swift`
- ViewModels: `ConversationViewModel.swift`
- Models: `Creation.swift`, `Creature.swift`
- Services: `SpeechService.swift`, `AIService.swift`

**Assets:**
- Images: `creature_cow_base.png`
- Sounds: `ui_tap.m4a`
- Use lowercase with underscores

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/voice-recognition

# Make changes and commit frequently
git add .
git commit -m "Add speech recognition service"

# Push to your fork
git push origin feature/voice-recognition

# Create Pull Request on GitHub
```

---

## 🧪 Running Tests

### Unit Tests

```bash
# Run all tests
⌘U in Xcode

# Or via command line:
xcodebuild test -scheme Crafta -destination 'platform=iOS Simulator,name=iPhone 14'
```

### Manual Testing Checklist

- [ ] Voice input works
- [ ] AI responds appropriately
- [ ] Visual preview displays
- [ ] Export creates valid .mcaddon
- [ ] Mod imports to Minecraft
- [ ] Creature appears in-game
- [ ] Parent controls work
- [ ] No crashes on common actions

---

## 🐛 Debugging

### Common Issues

**Build Fails:**
```bash
# Clean build folder
⌘⇧K

# Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Update package dependencies
File → Packages → Update to Latest Package Versions
```

**Simulator Issues:**
```bash
# Reset simulator
Hardware → Erase All Content and Settings

# Or via command line:
xcrun simctl erase all
```

**Voice Recognition Not Working:**
- Check microphone permissions
- Use real device (simulator has limitations)
- Verify Speech framework is linked

### Debugging Tools

**Xcode Debugger:**
- Set breakpoints (click line number)
- View variables in debug area
- Use `po variable` in console

**Logging:**
```swift
print("Debug: \(message)")           // Development
os_log("Info: \(message)")           // Production
```

---

## 📊 Performance Monitoring

### Instruments

Profile app performance:
1. Product → Profile (⌘I)
2. Select template:
   - **Time Profiler:** CPU usage
   - **Allocations:** Memory usage
   - **Leaks:** Memory leaks
3. Record and analyze

### Memory Guidelines

Target for MVP:
- Idle: < 50 MB
- Active: < 80 MB
- Peak: < 100 MB

---

## 🔒 Security Best Practices

### API Keys
- ✅ Use environment variables
- ✅ Add to .gitignore
- ✅ Never commit to Git
- ✅ Use different keys for dev/prod

### Child Data
- ✅ Store locally only (MVP)
- ✅ No cloud sync without consent
- ✅ No analytics without consent
- ✅ Clear privacy policy

### Code Review
- ✅ Review all PRs for safety
- ✅ Test with real kids (supervised)
- ✅ Validate AI outputs
- ✅ Check for inappropriate content

---

## 📚 Learning Resources

### Swift & SwiftUI
- [Apple's SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Hacking with Swift](https://www.hackingwithswift.com)
- [Swift by Sundell](https://www.swiftbysundell.com)
- [Sean Allen YouTube](https://www.youtube.com/c/SeanAllen)

### Speech Recognition
- [Apple Speech Framework Docs](https://developer.apple.com/documentation/speech)
- WWDC Sessions on Speech

### Minecraft Bedrock
- [Bedrock Wiki](https://wiki.bedrock.dev)
- [Minecraft Creator Portal](https://learn.microsoft.com/en-us/minecraft/creator/)
- Bedrock OSS Discord

### AI & GPT
- [OpenAI API Docs](https://platform.openai.com/docs)
- [GPT Best Practices](https://platform.openai.com/docs/guides/gpt-best-practices)

---

## 🧰 Troubleshooting

### Can't Build Project

1. Check Xcode version (14.0+)
2. Clean build folder (⌘⇧K)
3. Delete derived data
4. Restart Xcode
5. Restart Mac (if all else fails)

### Package Resolution Fails

```bash
# Reset package caches
File → Packages → Reset Package Caches

# Or manually:
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### Device Not Recognized

1. Unplug and replug USB
2. Trust computer on device
3. Check cable (use official Apple cable)
4. Try different USB port
5. Window → Devices and Simulators → Check device status

---

## 🚀 Next Steps

### Ready to Code?

1. ✅ Development environment set up
2. ✅ Read all planning documents
3. ✅ Understand the architecture
4. ✅ Review safety guidelines

**Start with Phase 1:**
See [docs/MVP_SCOPE.md](docs/MVP_SCOPE.md) for Phase 1 tasks.

### Need Help?

- Open an issue on GitHub
- Check [CONTRIBUTING.md](CONTRIBUTING.md)
- Review [docs/TECH_STACK.md](docs/TECH_STACK.md)

---

## ✅ Development Environment Checklist

Before starting development:
- [ ] macOS with Xcode installed
- [ ] Command Line Tools installed
- [ ] Repository cloned
- [ ] Planning documents read
- [ ] iOS device for testing (optional but recommended)
- [ ] Minecraft Bedrock installed on test device
- [ ] OpenAI account created (for when needed)
- [ ] Git configured with your info
- [ ] GitHub account set up

---

*Last Updated: October 15, 2025*
*Ready to start building something magical!*
