import '../../models/minecraft/addon_file.dart';
import '../../models/minecraft/addon_metadata.dart';
import '../../models/item_type.dart';
import 'dart:convert';

/// Generates Minecraft Bedrock item JSON files for weapons, armor, tools, etc.
class ItemExportGenerator {
  /// Generate item behavior file for weapons
  static AddonFile generateWeaponBehavior({
    required Map<String, dynamic> itemAttributes,
    required AddonMetadata metadata,
  }) {
    final weaponType = itemAttributes['weaponType'] ?? 'sword';
    final itemName = itemAttributes['customName'] ?? 'Weapon';
    final damage = itemAttributes['damage'] ?? 5;
    final attackSpeed = itemAttributes['attackSpeed'] ?? 1.6;
    final material = itemAttributes['material'] ?? 'iron';

    final itemJson = {
      "format_version": "1.20.60",
      "minecraft:item": {
        "description": {
          "identifier": "${metadata.namespace}:$weaponType",
          "category": "equipment",
        },
        "components": {
          "minecraft:display_name": {
            "value": itemName,
          },
          "minecraft:icon": weaponType,
          "minecraft:max_stack_size": 1,
          "minecraft:hand_equipped": true,
          "minecraft:durability": {
            "max_durability": _getDurabilityForMaterial(material, 'weapon'),
          },
          "minecraft:damage": damage,
          "minecraft:mining_speed": 1.0,
          // Weapon-specific components
          if (itemAttributes['enchanted'] == true) ...{
            "minecraft:foil": true, // Enchanted glow
          },
          "minecraft:tags": {
            "tags": ["crafta:weapon", "crafta:$weaponType"],
          },
        },
      },
    };

    final fileName = 'items/${metadata.namespace}_$weaponType.json';
    return AddonFile.json(fileName, jsonEncode(itemJson));
  }

  /// Generate item behavior file for armor
  static AddonFile generateArmorBehavior({
    required Map<String, dynamic> itemAttributes,
    required AddonMetadata metadata,
  }) {
    final armorType = itemAttributes['armorType'] ?? 'chestplate';
    final itemName = itemAttributes['customName'] ?? 'Armor';
    final protection = itemAttributes['protection'] ?? 5;
    final material = itemAttributes['material'] ?? 'iron';

    final itemJson = {
      "format_version": "1.20.60",
      "minecraft:item": {
        "description": {
          "identifier": "${metadata.namespace}:$armorType",
          "category": "equipment",
        },
        "components": {
          "minecraft:display_name": {
            "value": itemName,
          },
          "minecraft:icon": armorType,
          "minecraft:max_stack_size": 1,
          "minecraft:wearable": {
            "slot": _getArmorSlot(armorType),
            "protection": protection,
          },
          "minecraft:armor": {
            "protection": protection,
          },
          "minecraft:durability": {
            "max_durability": _getDurabilityForMaterial(material, 'armor'),
          },
          if (itemAttributes['enchanted'] == true) ...{
            "minecraft:foil": true,
          },
          "minecraft:tags": {
            "tags": ["crafta:armor", "crafta:$armorType"],
          },
        },
      },
    };

    final fileName = 'items/${metadata.namespace}_$armorType.json';
    return AddonFile.json(fileName, jsonEncode(itemJson));
  }

  /// Generate item behavior file for tools
  static AddonFile generateToolBehavior({
    required Map<String, dynamic> itemAttributes,
    required AddonMetadata metadata,
  }) {
    final toolType = itemAttributes['toolType'] ?? 'pickaxe';
    final itemName = itemAttributes['customName'] ?? 'Tool';
    final miningSpeed = itemAttributes['miningSpeed'] ?? 5;
    final material = itemAttributes['material'] ?? 'iron';

    final itemJson = {
      "format_version": "1.20.60",
      "minecraft:item": {
        "description": {
          "identifier": "${metadata.namespace}:$toolType",
          "category": "equipment",
        },
        "components": {
          "minecraft:display_name": {
            "value": itemName,
          },
          "minecraft:icon": toolType,
          "minecraft:max_stack_size": 1,
          "minecraft:hand_equipped": true,
          "minecraft:durability": {
            "max_durability": _getDurabilityForMaterial(material, 'tool'),
          },
          "minecraft:mining_speed": miningSpeed.toDouble(),
          if (itemAttributes['enchanted'] == true) ...{
            "minecraft:foil": true,
          },
          "minecraft:tags": {
            "tags": ["crafta:tool", "crafta:$toolType"],
          },
        },
      },
    };

    final fileName = 'items/${metadata.namespace}_$toolType.json';
    return AddonFile.json(fileName, jsonEncode(itemJson));
  }

  /// Generate block behavior for furniture/decorations
  static AddonFile generateFurnitureBehavior({
    required Map<String, dynamic> itemAttributes,
    required AddonMetadata metadata,
  }) {
    final furnitureType = itemAttributes['furnitureType'] ?? itemAttributes['decorationType'] ?? 'chair';
    final itemName = itemAttributes['customName'] ?? 'Furniture';

    final blockJson = {
      "format_version": "1.20.60",
      "minecraft:block": {
        "description": {
          "identifier": "${metadata.namespace}:$furnitureType",
        },
        "components": {
          "minecraft:display_name": itemName,
          "minecraft:map_color": "#FFFFFF",
          "minecraft:destructible_by_mining": {
            "seconds_to_destroy": 1.0,
          },
          "minecraft:friction": 0.4,
          "minecraft:light_emission": 0,
          "minecraft:material_instances": {
            "*": {
              "texture": furnitureType,
              "render_method": "opaque",
            },
          },
        },
      },
    };

    final fileName = 'blocks/${metadata.namespace}_$furnitureType.json';
    return AddonFile.json(fileName, jsonEncode(blockJson));
  }

  /// Generate terrain texture definition for furniture/decorations
  static AddonFile generateTerrainTexture({
    required Map<String, dynamic> itemAttributes,
    required AddonMetadata metadata,
  }) {
    final furnitureType = itemAttributes['furnitureType'] ?? itemAttributes['decorationType'] ?? 'block';

    final terrainJson = {
      "resource_pack_name": "${metadata.name} Resources",
      "texture_name": "atlas.terrain",
      "padding": 8,
      "num_mip_levels": 4,
      "texture_data": {
        furnitureType: {
          "textures": "textures/blocks/$furnitureType",
        },
      },
    };

    return AddonFile.json('textures/terrain_texture.json', jsonEncode(terrainJson));
  }

  /// Generate item texture definition (for items that need custom textures)
  static AddonFile generateItemTexture({
    required Map<String, dynamic> itemAttributes,
    required AddonMetadata metadata,
  }) {
    final itemType = itemAttributes['weaponType'] ??
                     itemAttributes['armorType'] ??
                     itemAttributes['toolType'] ??
                     'item';

    final itemTextureJson = {
      "resource_pack_name": "${metadata.name} Resources",
      "texture_name": "atlas.items",
      "texture_data": {
        itemType: {
          "textures": "textures/items/$itemType",
        },
      },
    };

    return AddonFile.json('textures/item_texture.json', jsonEncode(itemTextureJson));
  }

  /// Get appropriate armor slot based on armor type
  static String _getArmorSlot(String armorType) {
    final type = armorType.toLowerCase();
    if (type.contains('helmet')) return 'slot.armor.head';
    if (type.contains('chestplate')) return 'slot.armor.chest';
    if (type.contains('leggings')) return 'slot.armor.legs';
    if (type.contains('boots')) return 'slot.armor.feet';
    if (type.contains('shield')) return 'slot.weapon.offhand';
    return 'slot.armor.chest'; // default
  }

  /// Get durability based on material and item category
  static int _getDurabilityForMaterial(String material, String category) {
    final materialLower = material.toLowerCase();

    // Base durability multipliers
    final multipliers = {
      'wood': 1.0,
      'stone': 2.0,
      'iron': 3.0,
      'gold': 0.5,
      'diamond': 10.0,
      'netherite': 15.0,
      'leather': 0.8,
      'chain': 2.5,
    };

    final multiplier = multipliers[materialLower] ?? 1.0;

    // Base durability by category
    switch (category) {
      case 'weapon':
        return (250 * multiplier).round();
      case 'armor':
        return (200 * multiplier).round();
      case 'tool':
        return (300 * multiplier).round();
      default:
        return (100 * multiplier).round();
    }
  }

  /// Generate recipe for crafting the item (optional)
  static AddonFile generateCraftingRecipe({
    required Map<String, dynamic> itemAttributes,
    required AddonMetadata metadata,
  }) {
    final itemType = itemAttributes['weaponType'] ??
                     itemAttributes['armorType'] ??
                     itemAttributes['toolType'] ??
                     itemAttributes['furnitureType'] ??
                     'item';
    final material = itemAttributes['material'] ?? 'iron';

    // Simple shaped recipe example (can be customized per item type)
    final recipeJson = {
      "format_version": "1.20.60",
      "minecraft:recipe_shaped": {
        "description": {
          "identifier": "${metadata.namespace}:$itemType",
        },
        "tags": ["crafting_table"],
        "pattern": [
          "###",
          " | ",
          " | ",
        ],
        "key": {
          "#": {
            "item": "minecraft:${material}_ingot",
          },
          "|": {
            "item": "minecraft:stick",
          },
        },
        "result": {
          "item": "${metadata.namespace}:$itemType",
          "count": 1,
        },
      },
    };

    final fileName = 'recipes/${metadata.namespace}_$itemType.json';
    return AddonFile.json(fileName, jsonEncode(recipeJson));
  }

  /// Generate language file translations for items
  static Map<String, String> generateItemTranslations({
    required Map<String, dynamic> itemAttributes,
    required AddonMetadata metadata,
  }) {
    final itemType = itemAttributes['weaponType'] ??
                     itemAttributes['armorType'] ??
                     itemAttributes['toolType'] ??
                     itemAttributes['furnitureType'] ??
                     itemAttributes['decorationType'] ??
                     'item';
    final itemName = itemAttributes['customName'] ?? 'Item';

    return {
      'item.${metadata.namespace}:$itemType.name': itemName,
      'block.${metadata.namespace}:$itemType': itemName,
    };
  }
}
