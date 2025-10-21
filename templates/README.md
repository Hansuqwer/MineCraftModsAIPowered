# 🧱 Minecraft Bedrock Templates

This folder contains JSON template files for generating Minecraft Bedrock Edition mods.

---

## 📁 Structure

```
templates/
├── entities/          # Creature/mob templates
│   ├── cow_template.json
│   ├── pig_template.json
│   └── chicken_template.json
├── items/             # Item templates (future)
└── blocks/            # Block templates (future)
```

---

## 🎯 How Templates Work

Each JSON file contains placeholders (marked with `{{PLACEHOLDER}}`) that get replaced with actual values when a child creates something in Crafta.

### Common Placeholders

| Placeholder | Description | Example Values |
|-------------|-------------|----------------|
| `{{CREATURE_ID}}` | Unique identifier for the creature | `rainbow_cow_001`, `sparkle_pig_042` |
| `{{MOVEMENT_SPEED}}` | How fast the creature moves | `0.15` (tiny), `0.25` (normal), `0.35` (big) |
| `{{SIZE_WIDTH}}` | Width of collision box | `0.45` (tiny), `0.9` (normal), `1.4` (big) |
| `{{SIZE_HEIGHT}}` | Height of collision box | `0.7` (tiny), `1.4` (normal), `2.1` (big) |
| `{{EFFECT_EVENT}}` | Special effect to apply | `crafta:add_sparkles`, `crafta:add_glow`, `none` |

---

## 🌈 Entity Templates (MVP)

### Cow Template
- **Base:** Minecraft cow behavior
- **Modifications:** Size, speed, effects (sparkles, glow, flying)
- **Attributes:** Friendly, can be leashed, tempted with wheat

### Pig Template
- Coming soon...

### Chicken Template
- Coming soon...

---

## ⚙️ Template Processing

When Crafta generates a mod:

1. **Select Template** - Choose based on creature type (cow, pig, chicken)
2. **Replace Placeholders** - Fill in values based on child's choices
3. **Generate JSON** - Create final behavior file
4. **Package** - Zip into `.mcaddon` format
5. **Export** - Share to Minecraft app

---

## 🔧 Development Notes

### Creating New Templates

1. Start with vanilla Minecraft entity structure
2. Add Crafta-specific component groups
3. Mark variable sections with `{{PLACEHOLDER}}` syntax
4. Test in Minecraft Bedrock Edition
5. Document all placeholders

### Testing Templates

```bash
# After generating a test mod:
1. Open generated .mcaddon in Minecraft
2. Create new world with behavior pack enabled
3. Use /summon command to spawn creature
4. Verify behavior matches expectations
```

### Template Validation

Before adding a new template:
- [ ] Valid JSON syntax
- [ ] Compatible with Bedrock 1.20+
- [ ] No violent or scary behaviors
- [ ] Child-safe attributes only
- [ ] Tested in-game

---

## 📝 Version Compatibility

**Minecraft Bedrock Format:** `1.20.0`

These templates are designed for Minecraft Bedrock Edition 1.20 and above. They may work with older versions but haven't been tested.

**Compatibility Notes:**
- iOS Minecraft Bedrock fully supported
- Android/Windows compatible (not primary target)
- Java Edition NOT compatible (different format)

---

## 🚫 What Templates DON'T Include

To keep it simple for MVP:
- ❌ Custom textures (uses vanilla)
- ❌ Custom animations
- ❌ Custom sounds (uses vanilla cow/pig/chicken sounds)
- ❌ Complex AI behaviors
- ❌ Attack/combat behaviors (child-safe only)
- ❌ Redstone interactions
- ❌ Complex loot tables

All of these can be added in future versions if needed.

---

## 🎨 Example: Creating a Rainbow Cow

**Child's Request:**
"I want a rainbow cow that sparkles!"

**Template Processing:**
```json
{
  "identifier": "crafta:rainbow_cow_042",  // Generated unique ID
  "movement": 0.25,                        // Normal speed
  "size_width": 0.9,                       // Normal size
  "size_height": 1.4,
  "effect_event": "crafta:add_sparkles"    // Sparkle effect
}
```

**Result:**
A cow with vanilla texture that emits particle sparkles as it moves.

---

## 🔮 Future Expansions

### Phase 2: Items
- Wands, tools, decorative items
- Non-violent "weapons" (sparkle shooters, builders' hammers)
- Food items with fun effects

### Phase 3: Blocks
- Colored blocks
- Glowing blocks
- Simple decorative blocks

### Phase 4: Advanced Entities
- Flying creatures (proper wing animations)
- Underwater creatures
- Custom creature models

---

## 📚 Resources

### Minecraft Bedrock Documentation
- [Official Bedrock Wiki](https://wiki.bedrock.dev)
- [Entity Documentation](https://wiki.bedrock.dev/entities/entity-intro-bp)
- [Component Reference](https://wiki.bedrock.dev/entities/entity-components)

### Community Resources
- Bedrock OSS Discord
- Minecraft Creator Portal
- Bedrock Addons subreddit

---

## ⚠️ Important Notes

1. **Always test generated mods** before showing to kids
2. **Keep backups** of working templates
3. **Version control** template changes carefully
4. **Document** any deviations from vanilla behavior
5. **Safety first** - no scary or violent modifications

---

*Last Updated: October 15, 2025*
*Part of the Crafta Project*
