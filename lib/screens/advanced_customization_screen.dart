import 'package:flutter/material.dart';
import '../models/enhanced_creature_attributes.dart';

/// Advanced creature customization screen
class AdvancedCustomizationScreen extends StatefulWidget {
  final EnhancedCreatureAttributes initialAttributes;
  final Function(EnhancedCreatureAttributes) onAttributesChanged;

  const AdvancedCustomizationScreen({
    super.key,
    required this.initialAttributes,
    required this.onAttributesChanged,
  });

  @override
  State<AdvancedCustomizationScreen> createState() => _AdvancedCustomizationScreenState();
}

class _AdvancedCustomizationScreenState extends State<AdvancedCustomizationScreen>
    with TickerProviderStateMixin {
  late EnhancedCreatureAttributes _attributes;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _attributes = widget.initialAttributes;
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateAttributes(EnhancedCreatureAttributes newAttributes) {
    setState(() {
      _attributes = newAttributes;
    });
    widget.onAttributesChanged(newAttributes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Your Creature'),
        backgroundColor: const Color(0xFF98D8C8),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.palette), text: 'Colors'),
            Tab(icon: Icon(Icons.straighten), text: 'Size'),
            Tab(icon: Icon(Icons.psychology), text: 'Personality'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'Abilities'),
            Tab(icon: Icon(Icons.accessibility), text: 'Accessories'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildColorsTab(),
          _buildSizeTab(),
          _buildPersonalityTab(),
          _buildAbilitiesTab(),
          _buildAccessoriesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context, _attributes);
        },
        backgroundColor: const Color(0xFF98D8C8),
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text('Done', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildColorsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Primary Color'),
          _buildColorPicker(
            _attributes.primaryColor,
            (color) => _updateAttributes(_attributes.copyWith(primaryColor: color)),
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Secondary Color'),
          _buildColorPicker(
            _attributes.secondaryColor,
            (color) => _updateAttributes(_attributes.copyWith(secondaryColor: color)),
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Accent Color'),
          _buildColorPicker(
            _attributes.accentColor,
            (color) => _updateAttributes(_attributes.copyWith(accentColor: color)),
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Patterns'),
          _buildPatternSelector(),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Texture'),
          _buildTextureSelector(),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Glow Effect'),
          _buildGlowEffectSelector(),
        ],
      ),
    );
  }

  Widget _buildSizeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Creature Size'),
          _buildSizeSlider(),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Animation Style'),
          _buildAnimationStyleSelector(),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Size Preview'),
          _buildSizePreview(),
        ],
      ),
    );
  }

  Widget _buildPersonalityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Personality Type'),
          _buildPersonalitySelector(),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Custom Name'),
          _buildNameInput(),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Description'),
          _buildDescriptionInput(),
        ],
      ),
    );
  }

  Widget _buildAbilitiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Special Abilities'),
          _buildAbilitiesSelector(),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Selected Abilities'),
          _buildSelectedAbilities(),
        ],
      ),
    );
  }

  Widget _buildAccessoriesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Accessories'),
          _buildAccessoriesSelector(),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Selected Accessories'),
          _buildSelectedAccessories(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildColorPicker(Color currentColor, Function(Color) onColorChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          // Current color display
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: currentColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
          ),
          const SizedBox(height: 12),
          
          // Color grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _getColorOptions().length,
            itemBuilder: (context, index) {
              final color = _getColorOptions()[index];
              final isSelected = color == currentColor;
              
              return GestureDetector(
                onTap: () => onColorChanged(color),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Size: ${_attributes.size.name.toUpperCase()}'),
              Text('${(_attributes.sizeMultiplier * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _attributes.size.index.toDouble(),
            min: 0,
            max: CreatureSize.values.length - 1,
            divisions: CreatureSize.values.length - 1,
            onChanged: (value) {
              final newSize = CreatureSize.values[value.round()];
              _updateAttributes(_attributes.copyWith(size: newSize));
            },
            activeColor: const Color(0xFF98D8C8),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: CreatureSize.values.map((size) {
              return Text(
                size.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: _attributes.size == size 
                      ? const Color(0xFF98D8C8) 
                      : Colors.grey,
                  fontWeight: _attributes.size == size 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalitySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: PersonalityType.values.map((personality) {
          final isSelected = _attributes.personality == personality;
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected 
                  ? const Color(0xFF98D8C8) 
                  : Colors.grey.shade200,
              child: Text(
                personality.name[0].toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              personality.name.toUpperCase(),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF98D8C8) : Colors.black,
              ),
            ),
            subtitle: Text(_attributes.personalityDescription),
            trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF98D8C8)) : null,
            onTap: () {
              _updateAttributes(_attributes.copyWith(personality: personality));
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAbilitiesSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: SpecialAbility.values.map((ability) {
          final isSelected = _attributes.abilities.contains(ability);
          
          return ListTile(
            leading: Text(
              ability.icon,
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(
              ability.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF98D8C8) : Colors.black,
              ),
            ),
            subtitle: Text(ability.description),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (value) {
                List<SpecialAbility> newAbilities = List.from(_attributes.abilities);
                if (value == true) {
                  newAbilities.add(ability);
                } else {
                  newAbilities.remove(ability);
                }
                _updateAttributes(_attributes.copyWith(abilities: newAbilities));
              },
              activeColor: const Color(0xFF98D8C8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAccessoriesSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 3,
        ),
        itemCount: Accessory.allAccessories.length,
        itemBuilder: (context, index) {
          final accessory = Accessory.allAccessories[index];
          final isSelected = _attributes.accessories.contains(accessory);
          
          return GestureDetector(
            onTap: () {
              List<Accessory> newAccessories = List.from(_attributes.accessories);
              if (isSelected) {
                newAccessories.remove(accessory);
              } else {
                newAccessories.add(accessory);
              }
              _updateAttributes(_attributes.copyWith(accessories: newAccessories));
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF98D8C8) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? const Color(0xFF98D8C8) : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(accessory.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      accessory.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPatternSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: Pattern.values.map((pattern) {
          final isSelected = _attributes.patterns.contains(pattern);
          
          return GestureDetector(
            onTap: () {
              List<Pattern> newPatterns = List.from(_attributes.patterns);
              if (isSelected) {
                newPatterns.remove(pattern);
              } else {
                newPatterns.add(pattern);
              }
              _updateAttributes(_attributes.copyWith(patterns: newPatterns));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF98D8C8) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF98D8C8) : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(pattern.icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    pattern.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextureSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: TextureType.values.map((texture) {
          final isSelected = _attributes.texture == texture;
          
          return ListTile(
            title: Text(
              texture.name.toUpperCase(),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF98D8C8) : Colors.black,
              ),
            ),
            trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF98D8C8)) : null,
            onTap: () {
              _updateAttributes(_attributes.copyWith(texture: texture));
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGlowEffectSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: GlowEffect.values.map((glow) {
          final isSelected = _attributes.glowEffect == glow;
          
          return ListTile(
            title: Text(
              glow.name.toUpperCase(),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF98D8C8) : Colors.black,
              ),
            ),
            trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF98D8C8)) : null,
            onTap: () {
              _updateAttributes(_attributes.copyWith(glowEffect: glow));
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnimationStyleSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: CreatureAnimationStyle.values.map((style) {
          final isSelected = _attributes.animationStyle == style;
          
          return ListTile(
            title: Text(
              style.name.toUpperCase(),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF98D8C8) : Colors.black,
              ),
            ),
            trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF98D8C8)) : null,
            onTap: () {
              _updateAttributes(_attributes.copyWith(animationStyle: style));
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNameInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Creature Name',
          hintText: 'Enter a name for your creature',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          _updateAttributes(_attributes.copyWith(customName: value));
        },
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextField(
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Description',
          hintText: 'Describe your creature',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          _updateAttributes(_attributes.copyWith(description: value));
        },
      ),
    );
  }

  Widget _buildSizePreview() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Center(
        child: Container(
          width: 50 * _attributes.sizeMultiplier,
          height: 50 * _attributes.sizeMultiplier,
          decoration: BoxDecoration(
            color: _attributes.primaryColor,
            shape: BoxShape.circle,
            border: Border.all(color: _attributes.secondaryColor, width: 3),
          ),
          child: Center(
            child: Text(
              _attributes.size.name[0].toUpperCase(),
              style: TextStyle(
                color: _attributes.accentColor,
                fontSize: 20 * _attributes.sizeMultiplier,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedAbilities() {
    if (_attributes.abilities.isEmpty) {
      return const Text('No abilities selected');
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _attributes.abilities.map((ability) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF98D8C8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(ability.icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                ability.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectedAccessories() {
    if (_attributes.accessories.isEmpty) {
      return const Text('No accessories selected');
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _attributes.accessories.map((accessory) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF98D8C8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(accessory.icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                accessory.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Color> _getColorOptions() {
    return [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.brown,
      Colors.black,
      Colors.white,
      Colors.cyan,
      Colors.indigo,
    ];
  }
}
