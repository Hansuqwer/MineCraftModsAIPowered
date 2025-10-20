# Crafta Roadmap: Path to Feature Parity with ChatGPT

**Goal**: Make Crafta generate addons as good as ChatGPT's reference implementations
**Current Status**: Core mechanics working, missing advanced features
**Timeline**: 3-4 weeks with focused effort

---

## Current State Assessment

### What Works ✅
- [x] Voice input (Kids Mode tested)
- [x] AI understanding (EnhancedAIService exists)
- [x] Basic addon generation
- [x] Export to .mcpack
- [x] Minecraft launcher integration
- [x] Color texture generation (STEP 5 fixed)

### What's Broken/Missing ❌
- [ ] Item format for weapons/tools (generates as creatures)
- [ ] Hierarchical geometry (flat structure only)
- [ ] Customizable behaviors
- [ ] Event system
- [ ] Sound integration
- [ ] Advanced textures (patterns, procedural)
- [ ] 3D preview capability
- [ ] Kid Mode uses keyword matching (not AI)

---

## Phase Architecture

```
┌─────────────────────────────────────────────────────┐
│         USER REQUEST (Voice Input)                  │
│    "Make me a grey-white cat with a long tail"     │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│    PHASE A: AI Understanding (Existing)             │
│  ✅ Parse request                                   │
│  ✅ Extract attributes (color, size, behavior)      │
│  ⚠️  Currently: Local keyword matching              │
│  ✓ Needed: Connect EnhancedAIService               │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│  PHASE B: Attribute Processing (To Build)          │
│  ✅ Parse base type (creature vs item)              │
│  ⚠️  Currently: Treats everything as creature       │
│  ✓ Needed: Add item detection & routing            │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│  PHASE C: Addon Generation (To Build)              │
│  ✅ Basic addon structure (manifests, files)        │
│  ⚠️  Currently: Simple/generic components           │
│  ✓ Needed: Advanced geometry, behaviors, events    │
│                                                     │
│  Sub-phases:                                        │
│    C1: Geometry hierarchy (3-4 hrs)                 │
│    C2: Behaviors system (2-3 hrs)                   │
│    C3: Events system (2-3 hrs)                      │
│    C4: Advanced textures (1-2 hrs)                  │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│  PHASE D: Preview Generation (To Build)             │
│  ❌ Currently: No preview                            │
│  ✓ Needed: 3D preview (PNG + rotating GIF)         │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│  PHASE E: Export & Testing (Existing)              │
│  ✅ Export as .mcpack/mcaddon                       │
│  ✅ Minecraft launcher integration                  │
│  ✓ Needed: Full testing with advanced features     │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│   RESULT: Production-Ready Addon                    │
│   Ready to import and use in Minecraft             │
└─────────────────────────────────────────────────────┘
```

---

## Detailed Implementation Plan

### PHASE 0: Foundation (Prerequisite - 2-3 hours)
**Goal**: Fix immediate issues before building advanced features

#### 0.1: AI Integration (1-2 hours)
**Current Problem**: Kid Mode uses keyword matching, not AI
**Solution**: Connect EnhancedAIService

```dart
// BEFORE (kid_voice_service.dart)
Map<String, dynamic> parseKidVoice(String input) {
  // Just keyword matching
  for (final item in _kidCommands['items']) {
    if (input.contains(item)) {
      return {baseType: item};
    }
  }
}

// AFTER (kid_voice_service.dart)
Map<String, dynamic> parseKidVoice(String input) async {
  try {
    // Use actual AI
    final attributes = await EnhancedAIService
      .parseEnhancedCreatureRequest(input);
    return attributes.toMap();
  } catch (e) {
    // Fallback to keyword matching
    return fallbackParse(input);
  }
}
```

**Time**: 1-2 hours
**Benefit**: Full AI understanding instead of limited keywords

#### 0.2: Item Detection & Routing (1 hour)
**Current Problem**: All items treated as creatures
**Solution**: Add routing to separate generators

```dart
// BEFORE (quick_minecraft_export_service.dart)
exportCreature(attributes) {
  // Everything goes through entity generator
}

// AFTER (new services)
if (isItem(attributes)) {
  return ItemExportService.exportItem(attributes);
} else {
  return EntityExportService.exportEntity(attributes);
}
```

**Time**: 1 hour
**Benefit**: Proper format for items vs creatures

---

### PHASE A: Geometry System (3-4 hours)
**Goal**: Support hierarchical geometry with bones

#### A.1: Create Bone Class
```dart
class Bone {
  final String name;
  final List<double> pivot;
  final List<Cube> cubes;
  final String? parent;

  const Bone({
    required this.name,
    required this.pivot,
    required this.cubes,
    this.parent,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pivot': pivot,
      'cubes': cubes.map((c) => c.toJson()).toList(),
      if (parent != null) 'parent': parent,
    };
  }
}

class Cube {
  final List<double> origin;
  final List<double> size;
  final List<int> uv;

  Cube({required this.origin, required this.size, required this.uv});

  Map<String, dynamic> toJson() => {
    'origin': origin,
    'size': size,
    'uv': uv,
  };
}
```

**Time**: 1 hour
**Effort**: Low

#### A.2: Create GeometryBuilder
```dart
class GeometryBuilder {
  final List<Bone> bones = [];

  void addBone(String name, List<double> pivot, {String? parent}) {
    bones.add(Bone(
      name: name,
      pivot: pivot,
      cubes: [],
      parent: parent,
    ));
  }

  void addCube(String boneName, List<double> origin,
               List<double> size, List<int> uv) {
    final bone = bones.firstWhere((b) => b.name == boneName);
    final newCubes = [...bone.cubes, Cube(origin: origin, size: size, uv: uv)];
    // Update bone with new cube
  }

  Map<String, dynamic> build(String identifier) {
    return {
      'format_version': '1.12.0',
      'minecraft:geometry': [{
        'description': {
          'identifier': identifier,
          'texture_width': 64,
          'texture_height': 64,
        },
        'bones': bones.map((b) => b.toJson()).toList(),
      }]
    };
  }
}
```

**Time**: 1 hour
**Effort**: Medium

#### A.3: Update GeometryGenerator
Replace current simple generator:
```dart
// BEFORE
generateGeometry() {
  return simpleBox(...);
}

// AFTER
generateGeometry(attributes) {
  final builder = GeometryBuilder();

  if (attributes['baseType'] == 'cat') {
    builder.addBone('body', [0, 12, 0]);
    builder.addBone('head', [0, 14, -8], parent: 'body');
    builder.addBone('leg_fl', [2, 10, -5], parent: 'body');
    // ... more bones
    builder.addBone('tail_base', [0, 12.5, 6], parent: 'body');
    builder.addBone('tail_tip', [0, 13, 16], parent: 'tail_base');
  }

  return builder.build(identifier);
}
```

**Time**: 1-2 hours
**Effort**: High

**Total Phase A: 3-4 hours**

---

### PHASE B: Behavior System (2-3 hours)
**Goal**: Customizable behaviors (health, speed, traits)

#### B.1: Create BehaviorBuilder
```dart
class BehaviorBuilder {
  final Map<String, dynamic> components = {};

  void setHealth(int value, {int? max}) {
    components['minecraft:health'] = {
      'value': value,
      'max': max ?? value,
    };
  }

  void setMovement(double speed) {
    components['minecraft:movement'] = {'value': speed};
  }

  void addBehavior(String name, {int priority = 0}) {
    components['minecraft:behavior.$name'] = {'priority': priority};
  }

  void setTypeFamily(List<String> families) {
    components['minecraft:type_family'] = {'family': families};
  }
}
```

**Time**: 1 hour

#### B.2: Parse Attributes to Behaviors
```dart
buildBehaviors(attributes) {
  final builder = BehaviorBuilder();

  // Parse health
  final health = parseHealth(attributes['health']);
  builder.setHealth(health.value, max: health.max);

  // Parse speed
  final speed = parseSpeed(attributes['speed'] ?? 0.3);
  builder.setMovement(speed);

  // Add behaviors based on type
  if (attributes['baseType'] == 'cat') {
    builder.addBehavior('random_stroll', priority: 2);
    builder.addBehavior('random_look_around', priority: 3);
  }

  // Add type families
  builder.setTypeFamily([attributes['baseType']]);

  return builder.components;
}
```

**Time**: 1 hour

#### B.3: Update EntityBehaviorGenerator
Replace hardcoded components with dynamic building

**Time**: 1 hour
**Effort**: High

**Total Phase B: 2-3 hours**

---

### PHASE C: Event System (2-3 hours)
**Goal**: Event-driven behavior (meow, sounds, actions)

#### C.1: Create EventBuilder
```dart
class EventBuilder {
  final Map<String, dynamic> events = {};

  void addRandomEvent(String eventName,
      {required String trueEvent,
       required String falseEvent,
       int trueWeight = 1,
       int falseWeight = 3}) {
    events[eventName] = {
      'sequence': [{
        'randomize': [
          {'weight': trueWeight, 'event': trueEvent},
          {'weight': falseWeight, 'event': falseEvent},
        ]
      }]
    };
  }

  void addSoundEvent(String eventName, String sound,
      {double volume = 1.0}) {
    events[eventName] = {
      'run_command': {
        'command': ['playsound $sound @s ~~~ 1 $volume']
      }
    };
  }

  void addTimerEvent(String eventName, int minTime, int maxTime,
      {required String onTimer, bool looping = true}) {
    events[eventName] = {
      'minecraft:timer': {
        'looping': looping,
        'time': [minTime, maxTime],
        'on_timer': {'event': onTimer}
      }
    };
  }
}
```

**Time**: 1 hour

#### C.2: Parse Attributes to Events
```dart
buildEvents(attributes) {
  final builder = EventBuilder();

  // Add meow event for cats
  if (attributes['baseType'] == 'cat') {
    builder.addRandomEvent('gw:random_meow',
      trueEvent: 'gw:do_meow',
      falseEvent: 'gw:nothing',
      trueWeight: 1,
      falseWeight: 3
    );

    builder.addSoundEvent('gw:do_meow', 'mob.cat.meow');

    builder.addTimerEvent('gw:check_meow',
      minTime: 6,
      maxTime: 16,
      onTimer: 'gw:random_meow'
    );
  }

  return builder.events;
}
```

**Time**: 1-2 hours

#### C.3: Integrate into Entity Generator
Add events to entity JSON during generation

**Time**: 0.5 hour
**Effort**: High

**Total Phase C: 2-3 hours**

---

### PHASE D: Advanced Textures (1-2 hours)
**Goal**: Procedural patterns (patches, stripes, spots)

#### D.1: Create PatternTextureGenerator
```dart
class PatternTextureGenerator {
  static Future<Uint8List> generatePatchy({
    required Color baseColor,
    required Color patchColor,
    required int patchCount,
    required int size,
  }) async {
    final image = img.Image(width: size, height: size, numChannels: 4);
    final rng = Random();

    // Fill base
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        image.setPixelRgba(x, y,
          baseColor.red, baseColor.green, baseColor.blue, baseColor.alpha);
      }
    }

    // Add patches
    for (int i = 0; i < patchCount; i++) {
      final x = rng.nextInt(size - 10);
      final y = rng.nextInt(size - 10);
      final w = rng.nextInt(8) + 3;
      final h = rng.nextInt(8) + 3;

      for (int py = y; py < y + h; py++) {
        for (int px = x; px < x + w; px++) {
          image.setPixelRgba(px, py,
            patchColor.red, patchColor.green, patchColor.blue, patchColor.alpha);
        }
      }
    }

    return Uint8List.fromList(img.encodePng(image));
  }
}
```

**Time**: 1 hour

#### D.2: Update TextureGenerator
Use pattern generator for appropriate creature types

```dart
generateTexture(attributes) {
  if (attributes['pattern'] == 'patches') {
    return PatternTextureGenerator.generatePatchy(
      baseColor: extractColor(attributes['baseColor']),
      patchColor: extractColor(attributes['patchColor']),
      patchCount: 80,
      size: 64,
    );
  } else {
    return generateSimpleTexture(...);
  }
}
```

**Time**: 0.5 hour
**Effort**: Low

**Total Phase D: 1-2 hours**

---

### PHASE E: 3D Preview (3-4 hours)
**Goal**: Render geometry to PNG + rotating GIF

#### E.1: Create 3D Renderer
```dart
class CreaturePreviewRenderer {
  static Future<Uint8List> renderToPNG({
    required Map<String, dynamic> geometry,
    required Map<String, dynamic> texture,
    required String outputPath,
  }) async {
    // Use flutter_3d or similar package
    // Render geometry + texture to image
    // Return PNG bytes
  }

  static Future<Uint8List> renderToGIF({
    required Map<String, dynamic> geometry,
    required Map<String, dynamic> texture,
    required int frames,
    required String outputPath,
  }) async {
    // Render multiple frames at different angles
    // Encode as animated GIF
    // Return GIF bytes
  }
}
```

**Time**: 2-3 hours
**Effort**: High (requires 3D rendering library)

**Total Phase E: 3-4 hours**

---

## Implementation Schedule

### Week 1
- **Day 1-2**: Phase 0 (Foundation) - 2-3 hours
  - Connect AI service
  - Add item routing
- **Day 3-4**: Phase A (Geometry) - 3-4 hours
  - Create Bone/Cube classes
  - Build GeometryBuilder
  - Update generator
- **Day 5**: Phase B (Behaviors) - 2-3 hours
  - Create BehaviorBuilder
  - Parse attributes

**Total**: 7-10 hours

### Week 2
- **Day 1-2**: Phase B (Continued) - 0.5 hour
- **Day 2-3**: Phase C (Events) - 2-3 hours
  - Create EventBuilder
  - Parse events
  - Integrate
- **Day 4-5**: Phase D (Textures) - 1-2 hours
  - Pattern generator
  - Update texture generation

**Total**: 3.5-5.5 hours

### Week 3
- **Day 1-4**: Phase E (Preview) - 3-4 hours
  - 3D rendering
  - PNG export
  - GIF generation
- **Day 5**: Testing & Polish - 2-3 hours
  - Full end-to-end testing
  - Debug issues
  - Optimize performance

**Total**: 5-7 hours

---

## Total Effort & Timeline

| Phase | Hours | Difficulty | Priority |
|-------|-------|-----------|----------|
| Phase 0: Foundation | 2-3 | Low | HIGH |
| Phase A: Geometry | 3-4 | High | HIGH |
| Phase B: Behaviors | 2-3 | Medium | HIGH |
| Phase C: Events | 2-3 | Medium | HIGH |
| Phase D: Textures | 1-2 | Low | MEDIUM |
| Phase E: Preview | 3-4 | High | MEDIUM |
| Testing & Polish | 2-3 | Medium | MEDIUM |
| **TOTAL** | **16-22 hours** | - | - |

---

## Success Criteria

### After Phase 0
- ✅ AI service connected to Kid Mode
- ✅ Item vs creature routing working
- ✅ No crashes on any input type

### After Phase A
- ✅ Hierarchical geometry generated correctly
- ✅ Multiple bones with parent/child relationships
- ✅ Exported geometry loads in Minecraft

### After Phase B
- ✅ Customizable health values
- ✅ Customizable speed
- ✅ Multiple behaviors per entity
- ✅ Entities behave realistically (wander, look)

### After Phase C
- ✅ Events triggered correctly
- ✅ Sounds play in-game
- ✅ Random behaviors working
- ✅ Timers execute properly

### After Phase D
- ✅ Patchy textures generated
- ✅ Multiple pattern types supported
- ✅ Textures match model quality

### After Phase E
- ✅ 3D preview renders to PNG
- ✅ Rotating GIF preview works
- ✅ Preview quality is high

### Final Testing
- ✅ ChatGPT-quality addon generation
- ✅ All features working end-to-end
- ✅ User experience matches ChatGPT
- ✅ Performance acceptable

---

## Decision Points

### Q: Start now or after device testing (STEP 7)?
**Recommended**: Do STEP 7 first (quick validation)
- Validates STEP 5 texture fix
- Confirms export flow works
- Takes 30 minutes
- Then start Phase 0

### Q: All phases at once or phased?
**Recommended**: Phased implementation
- Easier to debug
- Can test each phase
- Can release incrementally
- Better code quality

### Q: Use existing libraries or build from scratch?
**Recommended**: Use existing
- `flutter_3d` or `three_dart` for rendering
- `image` package already used
- `archive` already used for .zip
- Saves development time

### Q: Do all features or prioritize?
**Recommended**: Priority order:
1. Phase 0 (Foundation) - Required
2. Phase A + B + C (Core) - High value
3. Phase D + E (Polish) - Nice to have

---

## Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|-----------|
| 3D rendering complexity | HIGH | Use established library, start simple |
| JSON schema changes | MEDIUM | Validate against Minecraft 1.20.50 |
| Performance issues | MEDIUM | Profile early, optimize as needed |
| API costs (AI integration) | LOW | Use fallback keyword matching |
| Time overruns | MEDIUM | Phase incrementally, test often |

---

## Expected Outcome

### Current Crafta
```
"Make me a cat"
  ↓
Generic entity addon
  ↓
Loads in Minecraft but looks generic
```

### After Implementation
```
"Make me a grey-white cat with extra-long tail that meows"
  ↓
Complex hierarchical geometry
Custom behaviors (wander, look)
Event-driven meowing
Procedural patchy texture
3D preview (PNG + rotating GIF)
  ↓
Perfect .mcaddon ready to import
  ↓
Loads in Minecraft and looks amazing ✅
```

---

## Conclusion

Crafta can reach **feature parity with ChatGPT** by systematically implementing:
1. Better geometry systems
2. Customizable behaviors
3. Event-driven interactions
4. Advanced textures
5. 3D preview capability

**Total effort**: 16-22 hours over 3-4 weeks
**Result**: Production-quality addon generation
**Value**: Game-changer for users

The roadmap is clear, the effort is quantified, and the path is achievable.

**Let's build it.**

---

**Document Status**: Strategic roadmap complete ✅
**Ready for**: Management approval & sprint planning
**Next Step**: Approve phases and start Week 1
**Success Metric**: Feature parity with ChatGPT references
