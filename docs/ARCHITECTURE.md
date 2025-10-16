# Crafta Architecture Documentation

## System Architecture Overview

Crafta follows a layered architecture pattern optimized for Flutter mobile development with clear separation of concerns.

## Architecture Layers

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Screens + Widgets + UI Components)    │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│         Business Logic Layer            │
│         (Services + Controllers)        │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│         Data Layer                      │
│    (Models + Local Storage + APIs)      │
└─────────────────────────────────────────┘
```

## Layer Details

### 1. Presentation Layer

**Location**: `lib/screens/` and `lib/widgets/`

**Responsibility**: User interface and user interactions

#### Screens (7 total)

1. **WelcomeScreen** (`welcome_screen.dart`)
   - Entry point with animated logo
   - Navigation to Creator or Parent Settings
   - Rainbow animation and sparkle effects

2. **CreatorScreen** (`creator_screen.dart`)
   - Core voice interaction hub
   - Microphone button with animations
   - Real-time speech recognition display
   - AI response rendering
   - Conversation history

3. **CompleteScreen** (`complete_screen.dart`)
   - Success celebration after creature creation
   - Animated congratulations
   - Navigation to preview or create more

4. **CreaturePreviewScreen** (`creature_preview_screen.dart`)
   - 3D creature visualization
   - Interactive controls (rotate, zoom)
   - Creature attributes display
   - Export functionality

5. **ParentSettingsScreen** (`parent_settings_screen.dart`)
   - Safety controls dashboard
   - Age filter settings
   - Content moderation options
   - Privacy settings

6. **CreationHistoryScreen** (`creation_history_screen.dart`)
   - List of child's creations
   - Thumbnail previews
   - Date and time stamps
   - Quick access to re-view creatures

7. **ExportManagementScreen** (`export_management_screen.dart`)
   - Manage exported mods
   - Download history
   - File management
   - Share options

#### Widgets (3 specialized components)

1. **Creature3DPreview** (`creature_3d_preview.dart`)
   - Custom 3D renderer using vector_math
   - Real-time transformation calculations
   - Lighting and shading
   - Touch gesture handling

2. **CreaturePreview** (`creature_preview.dart`)
   - 2D creature representation
   - Attribute badges
   - Animation previews

3. **EnhancedCreaturePreview** (`enhanced_creature_preview.dart`)
   - Advanced preview with effects
   - Particle systems (sparkles, glows)
   - Animation controller integration

### 2. Business Logic Layer

**Location**: `lib/services/`

**Responsibility**: Core business logic, external integrations, and utilities

#### Core Services

1. **AIService** (`ai_service.dart`)
   - **Purpose**: OpenAI GPT-4o-mini integration
   - **Key Methods**:
     - `getCraftaResponse(String message)`: Get AI response
     - `parseCreatureAttributes(String response)`: Extract creature data
   - **Dependencies**: http package
   - **Configuration**: API key, model parameters

2. **SpeechService** (`speech_service.dart`)
   - **Purpose**: Speech-to-Text functionality
   - **Key Methods**:
     - `initialize()`: Setup speech recognition
     - `startListening(Function onResult)`: Begin recording
     - `stopListening()`: End recording
   - **Dependencies**: speech_to_text package
   - **Platform Support**: Android/iOS only

3. **TTSService** (`tts_service.dart`)
   - **Purpose**: Text-to-Speech output
   - **Key Methods**:
     - `speak(String text)`: Convert text to voice
     - `stop()`: Stop current speech
     - `setVoice()`: Configure voice parameters
   - **Dependencies**: flutter_tts package
   - **Features**: Pitch, rate, volume control

4. **3DRendererService** (`3d_renderer_service.dart`)
   - **Purpose**: 3D creature rendering
   - **Key Methods**:
     - `render(CreatureData data)`: Generate 3D model
     - `applyTransform(Matrix4 transform)`: Apply transformations
     - `updateLighting()`: Lighting calculations
   - **Dependencies**: vector_math
   - **Features**: Custom mesh generation, texture mapping

5. **AnimationService** (`animation_service.dart`)
   - **Purpose**: UI animations and effects
   - **Key Methods**:
     - `playSparkleEffect()`: Sparkle animations
     - `playSuccessAnimation()`: Celebration effects
     - `animateMicrophone()`: Mic button animation
   - **Dependencies**: Flutter Animation API, rive
   - **Features**: Tween animations, particle effects

#### Production & Support Services

6. **ProductionService** (`production_service.dart`)
   - Deployment utilities
   - Environment configuration
   - Build management

7. **MonitoringService** (`monitoring_service.dart`)
   - Analytics tracking
   - Error monitoring
   - Performance metrics
   - User session tracking

8. **PerformanceService** (`performance_service.dart`)
   - Memory optimization
   - Battery usage monitoring
   - Network efficiency
   - Frame rate tracking

9. **SecurityService** (`security_service.dart`)
   - Content filtering
   - Input validation
   - Safe AI response verification
   - Child protection measures

10. **SupportService** (`support_service.dart`)
    - User feedback collection
    - Help documentation
    - Error reporting
    - Contact management

### 3. Data Layer

**Location**: `lib/models/`

**Responsibility**: Data structures and persistence

#### Models

1. **Conversation** (`conversation.dart`)
   ```dart
   class Conversation {
     List<Message> messages;
     DateTime createdAt;
     String userId;
   }

   class Message {
     String text;
     bool isUser;
     DateTime timestamp;
   }
   ```

#### Future Models (Not Yet Implemented)
- CreatureData
- UserProfile
- CreationHistory
- ExportedMod

## Data Flow

### Voice Interaction Flow

```
User speaks
    ↓
SpeechService (Speech-to-Text)
    ↓
CreatorScreen (Display recognized text)
    ↓
AIService (Send to GPT-4o-mini)
    ↓
AIService (Parse response)
    ↓
SecurityService (Validate child-safety)
    ↓
TTSService (Convert to voice)
    ↓
CreatorScreen (Display response + play audio)
    ↓
User hears Crafta's response
```

### Creature Creation Flow

```
Voice conversation completes
    ↓
AIService extracts creature attributes
    ↓
NavigationService → CompleteScreen
    ↓
User taps "See My Creature"
    ↓
NavigationService → CreaturePreviewScreen
    ↓
3DRendererService generates 3D model
    ↓
AnimationService adds effects
    ↓
User interacts with preview
    ↓
Optional: Export to Minecraft mod
```

## State Management

### Current Approach: Stateful Widgets + Provider Pattern

- **Local State**: StatefulWidget for screen-specific state
- **Shared State**: Provider for cross-screen data
- **Animation State**: AnimationController for UI effects

### State Hierarchy

```
MaterialApp (Root)
    ↓
Provider<AppState> (Optional, not yet implemented)
    ↓
Navigator (Route management)
    ↓
Individual Screens (Local state)
```

## External Dependencies

### AI Integration

- **Service**: OpenAI API
- **Endpoint**: `https://api.openai.com/v1/chat/completions`
- **Model**: gpt-4o-mini
- **Authentication**: Bearer token (API key)

### Platform APIs

1. **Android**
   - Microphone access: `android.permission.RECORD_AUDIO`
   - Network access: `android.permission.INTERNET`

2. **iOS**
   - Microphone: `NSMicrophoneUsageDescription`
   - Speech Recognition: `NSSpeechRecognitionUsageDescription`

## Security Architecture

### Child Safety Layers

1. **Input Filtering** (SecurityService)
   - Validates user voice input
   - Detects inappropriate content

2. **AI Response Validation** (SecurityService + AIService)
   - System prompt enforces child-safe responses
   - Post-processing verification
   - Content moderation filters

3. **Parental Controls** (ParentSettingsScreen)
   - Age-appropriate content filters
   - Creation monitoring
   - Export controls

### Privacy Protection

- **No Personal Data Collection**: No names, emails, or identifiable info
- **Local Storage Only**: Conversations stored on device
- **API Privacy**: Only creature descriptions sent to OpenAI
- **COPPA/GDPR Compliance**: Privacy-first design

## Performance Considerations

### Optimization Strategies

1. **Lazy Loading**: Screens load on demand
2. **Asset Caching**: Images and 3D models cached
3. **Animation Throttling**: Limit simultaneous animations
4. **Network Optimization**: Request batching, retry logic

### Memory Management

- Dispose controllers when screens unmount
- Clear conversation history periodically
- Optimize 3D mesh complexity
- Compress exported files

## Error Handling Strategy

### Error Levels

1. **User-Facing Errors**: Friendly, child-appropriate messages
   - "Oops! Let's try that again!"
   - "I didn't quite hear that. Can you say it again?"

2. **Developer Errors**: Logged for debugging
   - Stack traces in development mode
   - Error monitoring in production

3. **Critical Errors**: Graceful degradation
   - Fallback to mock responses if AI unavailable
   - Show helpful error screen with retry option

## Testing Strategy

### Test Types

1. **Unit Tests**: Service logic
2. **Widget Tests**: UI components
3. **Integration Tests**: Complete user flows
4. **Platform Tests**: Android/iOS specific features

### Test Coverage Goals

- Services: 80%+ coverage
- Widgets: 60%+ coverage
- Screens: 40%+ coverage (UI-heavy)

## Deployment Architecture

### Build Configurations

1. **Development**
   - Debug mode enabled
   - Mock services available
   - Verbose logging

2. **Staging**
   - Release mode
   - Test API endpoints
   - Analytics enabled

3. **Production**
   - Release mode
   - Production API endpoints
   - Error monitoring
   - Performance tracking

## Future Architecture Improvements

### Recommended Enhancements

1. **State Management**: Migrate to Riverpod or BLoC for better scalability
2. **API Layer**: Create dedicated API client service
3. **Repository Pattern**: Separate data access from business logic
4. **Dependency Injection**: Use GetIt or Injectable
5. **Feature Modules**: Organize by feature instead of layer
6. **Caching Strategy**: Implement LRU cache for API responses
7. **Offline Mode**: Queue actions when offline, sync when online

### Scalability Considerations

- **User Accounts**: Backend service for cloud sync
- **Social Features**: Friend system, sharing creations
- **Analytics**: Comprehensive usage tracking
- **A/B Testing**: Feature flag system
- **Localization**: Multi-language support

---

*This architecture follows Crafta Constitution: Safe, Kind, Imaginative*
