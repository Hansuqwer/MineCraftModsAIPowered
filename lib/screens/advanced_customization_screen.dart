import 'package:flutter/material.dart';
import '../models/enhanced_creature_attributes.dart';
import '../services/app_localizations.dart';
import '../theme/minecraft_theme.dart';

/// Advanced Customization Screen - Minecraft Enchantment Table Style
class AdvancedCustomizationScreen extends StatefulWidget {
  final EnhancedCreatureAttributes initialAttributes;
  final Function(EnhancedCreatureAttributes)? onAttributesChanged;

  const AdvancedCustomizationScreen({
    super.key,
    required this.initialAttributes,
    this.onAttributesChanged,
  });

  @override
  State<AdvancedCustomizationScreen> createState() => _AdvancedCustomizationScreenState();
}

class _AdvancedCustomizationScreenState extends State<AdvancedCustomizationScreen> {
  late EnhancedCreatureAttributes _attributes;

  // Color options (Minecraft dyes)
  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Red', 'nameS': 'Röd', 'color': const Color(0xFFB02E26)},
    {'name': 'Orange', 'nameS': 'Orange', 'color': const Color(0xFFF9801D)},
    {'name': 'Yellow', 'nameS': 'Gul', 'color': const Color(0xFFFED83D)},
    {'name': 'Green', 'nameS': 'Grön', 'color': MinecraftTheme.grassGreen},
    {'name': 'Blue', 'nameS': 'Blå', 'color': const Color(0xFF3C44AA)},
    {'name': 'Purple', 'nameS': 'Lila', 'color': const Color(0xFF8932B8)},
    {'name': 'Pink', 'nameS': 'Rosa', 'color': const Color(0xFFF38BAA)},
    {'name': 'White', 'nameS': 'Vit', 'color': const Color(0xFFF9FFFE)},
    {'name': 'Black', 'nameS': 'Svart', 'color': const Color(0xFF1D1D21)},
    {'name': 'Brown', 'nameS': 'Brun', 'color': const Color(0xFF835432)},
    {'name': 'Rainbow', 'nameS': 'Regnbåge', 'color': MinecraftTheme.goldOre},
  ];

  @override
  void initState() {
    super.initState();
    _attributes = widget.initialAttributes;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSwedish = l10n.locale.languageCode == 'sv';

    return Scaffold(
      backgroundColor: MinecraftTheme.coalBlack,
      appBar: AppBar(
        backgroundColor: MinecraftTheme.netherPortal,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.auto_fix_high, color: MinecraftTheme.goldOre, size: 24),
            const SizedBox(width: 8),
            MinecraftText(
              (isSwedish ? 'FÖRTROLLNING' : 'ENCHANTMENT').toUpperCase(),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: MinecraftTheme.goldOre,
            ),
          ],
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context, _attributes),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: MinecraftTheme.minecraftButton(color: MinecraftTheme.redstone),
            child: Icon(Icons.arrow_back, color: MinecraftTheme.textLight),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MinecraftTheme.netherPortal.withOpacity(0.3),
              MinecraftTheme.deepStone,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Creature preview
                _buildCreaturePreview(isSwedish),
                const SizedBox(height: 24),

                // Primary Color
                _buildColorSection(
                  title: isSwedish ? 'PRIMÄR FÄRG' : 'PRIMARY COLOR',
                  selectedColor: _attributes.primaryColor,
                  onColorSelected: (color) {
                    setState(() {
                      _attributes = _attributes.copyWith(primaryColor: color);
                    });
                    widget.onAttributesChanged?.call(_attributes);
                  },
                  isSwedish: isSwedish,
                ),

                const SizedBox(height: 20),

                // Size
                _buildSizeSection(isSwedish),

                const SizedBox(height: 20),

                // Abilities
                _buildAbilitiesSection(isSwedish),

                const SizedBox(height: 20),

                // Effects
                _buildEffectsSection(isSwedish),

                const SizedBox(height: 32),

                // Save button
                MinecraftButton(
                  text: (isSwedish ? 'SPARA FÖRTROLLNING' : 'SAVE ENCHANTMENT').toUpperCase(),
                  onPressed: () => Navigator.pop(context, _attributes),
                  color: MinecraftTheme.emerald,
                  icon: Icons.check,
                  height: 60,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreaturePreview(bool isSwedish) {
    return MinecraftPanel(
      backgroundColor: MinecraftTheme.slotBackground.withOpacity(0.9),
      child: Column(
        children: [
          MinecraftText(
            _attributes.customName.toUpperCase(),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MinecraftTheme.goldOre,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _attributes.primaryColor,
              border: Border.all(color: MinecraftTheme.deepStone, width: 3),
            ),
            child: Icon(
              Icons.pets,
              size: 60,
              color: MinecraftTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection({
    required String title,
    required Color selectedColor,
    required Function(Color) onColorSelected,
    required bool isSwedish,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MinecraftText(
          title,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: MinecraftTheme.goldOre,
        ),
        const SizedBox(height: 12),
        MinecraftPanel(
          backgroundColor: MinecraftTheme.deepStone.withOpacity(0.8),
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colorOptions.map((colorData) {
              final color = colorData['color'] as Color;
              final isSelected = color == selectedColor;
              return GestureDetector(
                onTap: () => onColorSelected(color),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: MinecraftTheme.minecraftSlot(isSelected: isSelected),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    color: color,
                    child: isSelected
                      ? Icon(Icons.check, color: MinecraftTheme.textLight)
                      : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSection(bool isSwedish) {
    final sizes = [CreatureSize.tiny, CreatureSize.small, CreatureSize.medium, CreatureSize.large, CreatureSize.giant];
    final sizesSwedish = ['Miniatyr', 'Liten', 'Normal', 'Stor', 'Jätte'];
    final sizesEnglish = ['Tiny', 'Small', 'Normal', 'Large', 'Giant'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MinecraftText(
          isSwedish ? 'STORLEK' : 'SIZE',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: MinecraftTheme.goldOre,
        ),
        const SizedBox(height: 12),
        MinecraftPanel(
          backgroundColor: MinecraftTheme.deepStone.withOpacity(0.8),
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(sizes.length, (index) {
              final size = sizes[index];
              final sizeLabel = isSwedish ? sizesSwedish[index] : sizesEnglish[index];
              final isSelected = _attributes.size == size;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _attributes = _attributes.copyWith(size: size);
                  });
                  widget.onAttributesChanged?.call(_attributes);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: MinecraftTheme.minecraftButton(
                    color: isSelected ? MinecraftTheme.emerald : MinecraftTheme.buttonBackground,
                    isPressed: isSelected,
                  ),
                  child: MinecraftText(
                    sizeLabel.toUpperCase(),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildAbilitiesSection(bool isSwedish) {
    final abilities = [
      {'ability': SpecialAbility.flying, 'icon': Icons.flight, 'label': 'Flying', 'labelSv': 'Flygande'},
      {'ability': SpecialAbility.swimming, 'icon': Icons.water, 'label': 'Swimming', 'labelSv': 'Simmar'},
      {'ability': SpecialAbility.fireBreath, 'icon': Icons.whatshot, 'label': 'Fire Breath', 'labelSv': 'Eldandning'},
      {'ability': SpecialAbility.magic, 'icon': Icons.auto_fix_high, 'label': 'Magic', 'labelSv': 'Magi'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MinecraftText(
          isSwedish ? 'FÖRMÅGOR' : 'ABILITIES',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: MinecraftTheme.goldOre,
        ),
        const SizedBox(height: 12),
        MinecraftPanel(
          backgroundColor: MinecraftTheme.deepStone.withOpacity(0.8),
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: abilities.map((abilityData) {
              final ability = abilityData['ability'] as SpecialAbility;
              final bool isEnabled = _attributes.abilities.contains(ability);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    final newAbilities = List<SpecialAbility>.from(_attributes.abilities);
                    if (isEnabled) {
                      newAbilities.remove(ability);
                    } else {
                      newAbilities.add(ability);
                    }
                    _attributes = _attributes.copyWith(abilities: newAbilities);
                  });
                  widget.onAttributesChanged?.call(_attributes);
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: MinecraftTheme.minecraftSlot(isSelected: isEnabled),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        abilityData['icon'] as IconData,
                        color: isEnabled ? MinecraftTheme.goldOre : MinecraftTheme.stoneGray,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      MinecraftText(
                        (isSwedish ? abilityData['labelSv'] as String : abilityData['label'] as String),
                        fontSize: 10,
                        color: isEnabled ? MinecraftTheme.textLight : MinecraftTheme.stoneGray,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEffectsSection(bool isSwedish) {
    final effects = [
      {'effect': GlowEffect.soft, 'label': 'Soft Glow', 'labelSv': 'Mjuk Glöd'},
      {'effect': GlowEffect.bright, 'label': 'Bright Glow', 'labelSv': 'Ljus Glöd'},
      {'effect': GlowEffect.pulsing, 'label': 'Pulsing', 'labelSv': 'Pulserande'},
      {'effect': GlowEffect.rainbow, 'label': 'Rainbow', 'labelSv': 'Regnbåge'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MinecraftText(
          isSwedish ? 'GLÖD EFFEKT' : 'GLOW EFFECT',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: MinecraftTheme.goldOre,
        ),
        const SizedBox(height: 12),
        MinecraftPanel(
          backgroundColor: MinecraftTheme.deepStone.withOpacity(0.8),
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: effects.map((effectData) {
              final effect = effectData['effect'] as GlowEffect;
              final bool isSelected = _attributes.glowEffect == effect;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _attributes = _attributes.copyWith(glowEffect: effect);
                  });
                  widget.onAttributesChanged?.call(_attributes);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: MinecraftTheme.minecraftButton(
                    color: isSelected ? MinecraftTheme.diamond : MinecraftTheme.buttonBackground,
                    isPressed: isSelected,
                  ),
                  child: MinecraftText(
                    (isSwedish ? effectData['labelSv'] as String : effectData['label'] as String).toUpperCase(),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
