import '../models/item_type.dart';
import '../models/enhanced_creature_attributes.dart';
import 'dart:convert';

/// Enhanced Item Creation Service
/// Handles creation of weapons, armor, furniture, tools, etc.
class EnhancedItemCreationService {
  /// Generate AI prompt for specific item type
  static String generatePromptForItemType({
    required ItemType itemType,
    required String userInput,
    ItemMaterialType? material,
    String? subtype,
  }) {
    final basePrompt = '''
You are Crafta, a friendly AI assistant helping kids (ages 4-10) create items for Minecraft.
The child wants to create: ${itemType.displayName}

IMPORTANT RULES:
- Be warm, encouraging, and kid-friendly
- Keep it safe and appropriate for children
- Make items realistic and balanced for Minecraft
- Include fun details but stay practical

''';

    switch (itemType) {
      case ItemType.weapon:
        return _generateWeaponPrompt(basePrompt, userInput, material, subtype);
      case ItemType.armor:
        return _generateArmorPrompt(basePrompt, userInput, material, subtype);
      case ItemType.furniture:
        return _generateFurniturePrompt(basePrompt, userInput, material, subtype);
      case ItemType.tool:
        return _generateToolPrompt(basePrompt, userInput, material, subtype);
      case ItemType.decoration:
        return _generateDecorationPrompt(basePrompt, userInput, material, subtype);
      case ItemType.vehicle:
        return _generateVehiclePrompt(basePrompt, userInput, material, subtype);
      case ItemType.creature:
        return _generateCreaturePrompt(basePrompt, userInput);
    }
  }

  static String _generateWeaponPrompt(
    String base,
    String input,
    ItemMaterialType? material,
    String? subtype,
  ) {
    return '''
$base
Child's request: "$input"
Material: ${material?.displayName ?? 'Not specified'}
Weapon Type: ${subtype ?? 'Any'}

CREATE A WEAPON with these specifications:
1. Type: (sword, bow, axe, spear, or staff)
2. Material: ${material?.displayName ?? 'appropriate material'}
3. Color: Based on material or user's preference
4. Damage: 1-10 (balanced for Minecraft)
5. Attack Speed: 0.5-4.0 (swords are fast, axes are slow)
6. Range: 1-20 blocks
7. Special Abilities: Up to 2 cool but balanced abilities
8. Enchantments: Optional glow or particle effects

EXAMPLE OUTPUT:
{
  "itemType": "weapon",
  "weaponType": "sword",
  "customName": "Diamond Flame Sword",
  "material": "diamond",
  "primaryColor": "cyan",
  "damage": 8,
  "attackSpeed": 1.6,
  "range": 3,
  "specialAbilities": ["Fire damage", "Light source"],
  "enchanted": true,
  "effects": ["flames", "glow"],
  "description": "A beautiful cyan diamond sword with flames dancing along the blade!"
}

Respond ONLY with valid JSON matching this format.
''';
  }

  static String _generateArmorPrompt(
    String base,
    String input,
    ItemMaterialType? material,
    String? subtype,
  ) {
    return '''
$base
Child's request: "$input"
Material: ${material?.displayName ?? 'Not specified'}
Armor Type: ${subtype ?? 'Any'}

CREATE ARMOR with these specifications:
1. Type: (helmet, chestplate, leggings, boots, or shield)
2. Material: ${material?.displayName ?? 'appropriate material'}
3. Color: Based on material or user's preference
4. Protection: 1-10 (balanced for Minecraft)
5. Durability: 50-1000 uses
6. Special Abilities: Up to 2 defensive abilities
7. Enchantments: Optional glow or effects

EXAMPLE OUTPUT:
{
  "itemType": "armor",
  "armorType": "chestplate",
  "customName": "Dragon Scale Chestplate",
  "material": "netherite",
  "primaryColor": "black",
  "protection": 9,
  "durability": 500,
  "specialAbilities": ["Fire resistance", "Knockback resistance"],
  "enchanted": true,
  "effects": ["glow"],
  "description": "A strong black chestplate made from dragon scales!"
}

Respond ONLY with valid JSON matching this format.
''';
  }

  static String _generateFurniturePrompt(
    String base,
    String input,
    ItemMaterialType? material,
    String? subtype,
  ) {
    return '''
$base
Child's request: "$input"
Material: ${material?.displayName ?? 'Wood'}
Furniture Type: ${subtype ?? 'Any'}

CREATE FURNITURE with these specifications:
1. Type: (chair, table, bed, couch, shelf, or lamp)
2. Material: ${material?.displayName ?? 'wood'}
3. Color: Natural material color or painted
4. Size: Width x Height x Depth in blocks
5. Functional: Can it be used? (sit, sleep, store items)
6. Style: (modern, classic, rustic, fancy)
7. Details: Fun decorative elements

EXAMPLE OUTPUT:
{
  "itemType": "furniture",
  "furnitureType": "chair",
  "customName": "Royal Throne",
  "material": "gold",
  "primaryColor": "golden",
  "width": 1.0,
  "height": 2.0,
  "depth": 1.0,
  "functional": true,
  "style": "fancy",
  "description": "A majestic golden throne fit for a king!"
}

Respond ONLY with valid JSON matching this format.
''';
  }

  static String _generateToolPrompt(
    String base,
    String input,
    ItemMaterialType? material,
    String? subtype,
  ) {
    return '''
$base
Child's request: "$input"
Material: ${material?.displayName ?? 'Not specified'}
Tool Type: ${subtype ?? 'Any'}

CREATE A TOOL with these specifications:
1. Type: (pickaxe, shovel, axe, hoe, or fishing rod)
2. Material: ${material?.displayName ?? 'appropriate material'}
3. Color: Based on material
4. Mining Speed: 1-10 (how fast it works)
5. Durability: 50-2000 uses
6. Minable Blocks: What can it mine/dig?
7. Enchantments: Optional efficiency boost

EXAMPLE OUTPUT:
{
  "itemType": "tool",
  "toolType": "pickaxe",
  "customName": "Super Pickaxe",
  "material": "diamond",
  "primaryColor": "cyan",
  "miningSpeed": 9,
  "durability": 1500,
  "minableBlocks": ["stone", "ores", "obsidian"],
  "enchanted": true,
  "effects": ["glow"],
  "description": "A powerful cyan pickaxe that mines super fast!"
}

Respond ONLY with valid JSON matching this format.
''';
  }

  static String _generateDecorationPrompt(
    String base,
    String input,
    ItemMaterialType? material,
    String? subtype,
  ) {
    return '''
$base
Child's request: "$input"
Decoration Type: ${subtype ?? 'Any'}

CREATE A DECORATION with these specifications:
1. Type: (statue, painting, flag, flower pot, or ornament)
2. Material: Any appropriate material
3. Color: Vibrant and appealing
4. Size: Small, Medium, or Large
5. Theme: What does it represent?
6. Details: Fun visual elements

EXAMPLE OUTPUT:
{
  "itemType": "decoration",
  "decorationType": "statue",
  "customName": "Dragon Statue",
  "material": "stone",
  "primaryColor": "gray",
  "size": "medium",
  "theme": "dragon",
  "description": "A cool gray stone statue of a dragon!"
}

Respond ONLY with valid JSON matching this format.
''';
  }

  static String _generateVehiclePrompt(
    String base,
    String input,
    ItemMaterialType? material,
    String? subtype,
  ) {
    return '''
$base
Child's request: "$input"
Vehicle Type: ${subtype ?? 'Any'}

NOTE: Vehicles are DECORATIVE ONLY in Minecraft (no actual movement)

CREATE A VEHICLE DECORATION with these specifications:
1. Type: (car, boat, plane, bike, or spaceship)
2. Material: Iron, wood, or gold
3. Color: Fun and vibrant
4. Size: Small, Medium, or Large
5. Style: (modern, classic, futuristic, fantasy)
6. Details: Cool decorative features (wheels, wings, etc.)

EXAMPLE OUTPUT:
{
  "itemType": "vehicle",
  "vehicleType": "car",
  "customName": "Rainbow Race Car",
  "material": "iron",
  "primaryColor": "rainbow",
  "size": "medium",
  "style": "modern",
  "description": "A colorful rainbow race car that looks super fast!"
}

Respond ONLY with valid JSON matching this format.
''';
  }

  static String _generateCreaturePrompt(String base, String input) {
    return '''
$base
Child's request: "$input"

CREATE A CREATURE with these specifications:
1. Type: Dragon, Pet, Monster, Bird, Fish, or Fantasy creature
2. Colors: Primary and secondary colors
3. Size: Tiny, Normal, or Giant
4. Special Features: Wings, horns, tail, etc.
5. Abilities: Flying, swimming, fire-breathing, etc.
6. Personality: Friendly, playful, brave, etc.

EXAMPLE OUTPUT:
{
  "itemType": "creature",
  "creatureType": "dragon",
  "customName": "Purple Fire Dragon",
  "primaryColor": "purple",
  "secondaryColor": "red",
  "size": "giant",
  "hasWings": true,
  "abilities": ["flying", "fire-breathing"],
  "personality": "brave",
  "description": "A majestic purple dragon with red accents that breathes fire!"
}

Respond ONLY with valid JSON matching this format.
''';
  }

  /// Parse AI response into item attributes
  static Map<String, dynamic> parseItemResponse(String response, ItemType itemType) {
    try {
      // Extract JSON from response
      String jsonStr = response.trim();

      // Remove markdown code blocks if present
      if (jsonStr.startsWith('```json')) {
        jsonStr = jsonStr.substring(7);
      }
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.substring(3);
      }
      if (jsonStr.endsWith('```')) {
        jsonStr = jsonStr.substring(0, jsonStr.length - 3);
      }

      jsonStr = jsonStr.trim();

      final Map<String, dynamic> parsed = json.decode(jsonStr);

      // Add item type if not present
      parsed['itemType'] = itemType.toString().split('.').last;

      // Ensure required fields
      parsed['customName'] = parsed['customName'] ?? 'My ${itemType.displayName}';
      parsed['description'] = parsed['description'] ?? 'A cool ${itemType.displayName}!';
      parsed['primaryColor'] = parsed['primaryColor'] ?? 'purple';

      // Add creatureType for backward compatibility
      parsed['creatureType'] = parsed[_getTypeField(itemType)] ?? itemType.displayName.toLowerCase();

      // Add effects array if not present
      parsed['effects'] = parsed['effects'] ?? [];

      // Add color to effects for rendering
      parsed['color'] = parsed['primaryColor'];

      return parsed;
    } catch (e) {
      print('Error parsing item response: $e');
      return _getDefaultAttributes(itemType);
    }
  }

  static String _getTypeField(ItemType itemType) {
    switch (itemType) {
      case ItemType.weapon:
        return 'weaponType';
      case ItemType.armor:
        return 'armorType';
      case ItemType.furniture:
        return 'furnitureType';
      case ItemType.tool:
        return 'toolType';
      case ItemType.decoration:
        return 'decorationType';
      case ItemType.vehicle:
        return 'vehicleType';
      case ItemType.creature:
        return 'creatureType';
    }
  }

  static Map<String, dynamic> _getDefaultAttributes(ItemType itemType) {
    return {
      'itemType': itemType.toString().split('.').last,
      'creatureType': itemType.displayName.toLowerCase(),
      'customName': 'My ${itemType.displayName}',
      'description': 'A cool ${itemType.displayName}!',
      'primaryColor': 'purple',
      'color': 'purple',
      'effects': [],
    };
  }

  /// Get item-specific AI suggestions
  static List<String> getSuggestionsForItemType(ItemType itemType, ItemMaterialType? material) {
    switch (itemType) {
      case ItemType.weapon:
        return [
          'Make it glow with magic',
          'Add flame effects',
          'Increase damage power',
          'Make it faster',
          'Add special ability',
        ];
      case ItemType.armor:
        return [
          'Make it shinier',
          'Add more protection',
          'Make it glow',
          'Add special power',
          'Make it legendary',
        ];
      case ItemType.furniture:
        return [
          'Make it bigger',
          'Add cushions',
          'Change the color',
          'Make it fancy',
          'Add decorations',
        ];
      case ItemType.tool:
        return [
          'Make it faster',
          'Add durability',
          'Make it glow',
          'Add enchantment',
          'Make it legendary',
        ];
      case ItemType.decoration:
        return [
          'Make it colorful',
          'Add more details',
          'Make it glow',
          'Make it bigger',
          'Add effects',
        ];
      case ItemType.vehicle:
        return [
          'Add more wheels',
          'Make it colorful',
          'Add wings',
          'Make it bigger',
          'Add decorations',
        ];
      case ItemType.creature:
        return [
          'Add wings',
          'Change color',
          'Make it bigger',
          'Add fire breath',
          'Make it glow',
        ];
    }
  }
}
