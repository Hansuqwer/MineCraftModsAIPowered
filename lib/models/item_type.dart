/// Item type enumeration for Crafta
/// Defines all creatable item categories
enum ItemType {
  creature,
  weapon,
  armor,
  furniture,
  tool,
  decoration,
  vehicle,
}

/// Item category for grouping
enum ItemCategory {
  living,      // Creatures, pets, mobs
  combat,      // Weapons, armor
  utility,     // Tools, furniture
  decorative,  // Decorations, vehicles
}

extension ItemTypeExtension on ItemType {
  String get displayName {
    switch (this) {
      case ItemType.creature:
        return 'Creature';
      case ItemType.weapon:
        return 'Weapon';
      case ItemType.armor:
        return 'Armor';
      case ItemType.furniture:
        return 'Furniture';
      case ItemType.tool:
        return 'Tool';
      case ItemType.decoration:
        return 'Decoration';
      case ItemType.vehicle:
        return 'Vehicle';
    }
  }

  String get emoji {
    switch (this) {
      case ItemType.creature:
        return '🐲';
      case ItemType.weapon:
        return '⚔️';
      case ItemType.armor:
        return '🛡️';
      case ItemType.furniture:
        return '🪑';
      case ItemType.tool:
        return '⛏️';
      case ItemType.decoration:
        return '🎨';
      case ItemType.vehicle:
        return '🚗';
    }
  }

  String get description {
    switch (this) {
      case ItemType.creature:
        return 'Create magical creatures, pets, and friendly monsters';
      case ItemType.weapon:
        return 'Design swords, bows, axes, and powerful weapons';
      case ItemType.armor:
        return 'Craft protective helmets, chestplates, and shields';
      case ItemType.furniture:
        return 'Make chairs, tables, beds, and decorations';
      case ItemType.tool:
        return 'Build pickaxes, shovels, and useful tools';
      case ItemType.decoration:
        return 'Design statues, paintings, and ornaments';
      case ItemType.vehicle:
        return 'Create cars, boats, planes (decorative)';
    }
  }

  ItemCategory get category {
    switch (this) {
      case ItemType.creature:
        return ItemCategory.living;
      case ItemType.weapon:
      case ItemType.armor:
        return ItemCategory.combat;
      case ItemType.furniture:
      case ItemType.tool:
        return ItemCategory.utility;
      case ItemType.decoration:
      case ItemType.vehicle:
        return ItemCategory.decorative;
    }
  }

  List<String> get subtypes {
    switch (this) {
      case ItemType.creature:
        return ['Dragon', 'Pet', 'Monster', 'Bird', 'Fish', 'Fantasy'];
      case ItemType.weapon:
        return ['Sword', 'Bow', 'Axe', 'Pickaxe', 'Spear', 'Staff'];
      case ItemType.armor:
        return ['Helmet', 'Chestplate', 'Leggings', 'Boots', 'Shield'];
      case ItemType.furniture:
        return ['Chair', 'Table', 'Bed', 'Couch', 'Shelf', 'Lamp'];
      case ItemType.tool:
        return ['Pickaxe', 'Shovel', 'Axe', 'Hoe', 'Fishing Rod'];
      case ItemType.decoration:
        return ['Statue', 'Painting', 'Flag', 'Flower Pot', 'Ornament'];
      case ItemType.vehicle:
        return ['Car', 'Boat', 'Plane', 'Bike', 'Spaceship'];
    }
  }
}

/// Material type for items
enum ItemMaterialType {
  wood,
  stone,
  iron,
  gold,
  diamond,
  netherite,
  leather,
  chain,
  glass,
  wool,
}

extension ItemMaterialTypeExtension on ItemMaterialType {
  String get displayName {
    switch (this) {
      case ItemMaterialType.wood:
        return 'Wood';
      case ItemMaterialType.stone:
        return 'Stone';
      case ItemMaterialType.iron:
        return 'Iron';
      case ItemMaterialType.gold:
        return 'Gold';
      case ItemMaterialType.diamond:
        return 'Diamond';
      case ItemMaterialType.netherite:
        return 'Netherite';
      case ItemMaterialType.leather:
        return 'Leather';
      case ItemMaterialType.chain:
        return 'Chain';
      case ItemMaterialType.glass:
        return 'Glass';
      case ItemMaterialType.wool:
        return 'Wool';
    }
  }

  String get emoji {
    switch (this) {
      case ItemMaterialType.wood:
        return '🪵';
      case ItemMaterialType.stone:
        return '🪨';
      case ItemMaterialType.iron:
        return '⚙️';
      case ItemMaterialType.gold:
        return '✨';
      case ItemMaterialType.diamond:
        return '💎';
      case ItemMaterialType.netherite:
        return '🌑';
      case ItemMaterialType.leather:
        return '🧤';
      case ItemMaterialType.chain:
        return '⛓️';
      case ItemMaterialType.glass:
        return '🔷';
      case ItemMaterialType.wool:
        return '🧶';
    }
  }

  /// Get Minecraft color for material
  String get minecraftColor {
    switch (this) {
      case ItemMaterialType.wood:
        return 'brown';
      case ItemMaterialType.stone:
        return 'gray';
      case ItemMaterialType.iron:
        return 'silver';
      case ItemMaterialType.gold:
        return 'golden';
      case ItemMaterialType.diamond:
        return 'cyan';
      case ItemMaterialType.netherite:
        return 'black';
      case ItemMaterialType.leather:
        return 'brown';
      case ItemMaterialType.chain:
        return 'gray';
      case ItemMaterialType.glass:
        return 'transparent';
      case ItemMaterialType.wool:
        return 'white';
    }
  }

  /// Durability rating (1-10)
  int get durability {
    switch (this) {
      case ItemMaterialType.wood:
        return 2;
      case ItemMaterialType.stone:
        return 3;
      case ItemMaterialType.iron:
        return 6;
      case ItemMaterialType.gold:
        return 1;
      case ItemMaterialType.diamond:
        return 9;
      case ItemMaterialType.netherite:
        return 10;
      case ItemMaterialType.leather:
        return 2;
      case ItemMaterialType.chain:
        return 4;
      case ItemMaterialType.glass:
        return 1;
      case ItemMaterialType.wool:
        return 1;
    }
  }

  /// Compatible with item types
  bool isCompatibleWith(ItemType itemType) {
    switch (itemType) {
      case ItemType.weapon:
      case ItemType.tool:
        return this != ItemMaterialType.leather &&
            this != ItemMaterialType.wool &&
            this != ItemMaterialType.glass;
      case ItemType.armor:
        return this != ItemMaterialType.wood &&
            this != ItemMaterialType.wool &&
            this != ItemMaterialType.glass;
      case ItemType.furniture:
        return this == ItemMaterialType.wood ||
            this == ItemMaterialType.stone ||
            this == ItemMaterialType.iron ||
            this == ItemMaterialType.wool;
      case ItemType.decoration:
        return true; // All materials work
      case ItemType.vehicle:
        return this == ItemMaterialType.iron ||
            this == ItemMaterialType.wood ||
            this == ItemMaterialType.gold;
      case ItemType.creature:
        return false; // Creatures don't use materials
    }
  }
}

/// Weapon-specific attributes
class WeaponAttributes {
  final String weaponType; // sword, bow, axe, etc.
  final int damage; // 1-10
  final double attackSpeed; // 0.5-4.0
  final int range; // 1-20 blocks
  final bool enchanted;
  final List<String> specialAbilities;

  WeaponAttributes({
    required this.weaponType,
    this.damage = 5,
    this.attackSpeed = 1.6,
    this.range = 3,
    this.enchanted = false,
    this.specialAbilities = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'weaponType': weaponType,
      'damage': damage,
      'attackSpeed': attackSpeed,
      'range': range,
      'enchanted': enchanted,
      'specialAbilities': specialAbilities,
    };
  }
}

/// Armor-specific attributes
class ArmorAttributes {
  final String armorType; // helmet, chestplate, leggings, boots
  final int protection; // 1-10
  final int durability; // 1-1000
  final bool enchanted;
  final List<String> specialAbilities;

  ArmorAttributes({
    required this.armorType,
    this.protection = 5,
    this.durability = 100,
    this.enchanted = false,
    this.specialAbilities = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'armorType': armorType,
      'protection': protection,
      'durability': durability,
      'enchanted': enchanted,
      'specialAbilities': specialAbilities,
    };
  }
}

/// Furniture-specific attributes
class FurnitureAttributes {
  final String furnitureType; // chair, table, bed, etc.
  final double width; // blocks
  final double height; // blocks
  final double depth; // blocks
  final bool functional; // Can sit, sleep, etc.
  final String style; // modern, classic, rustic, etc.

  FurnitureAttributes({
    required this.furnitureType,
    this.width = 1.0,
    this.height = 1.0,
    this.depth = 1.0,
    this.functional = true,
    this.style = 'classic',
  });

  Map<String, dynamic> toMap() {
    return {
      'furnitureType': furnitureType,
      'width': width,
      'height': height,
      'depth': depth,
      'functional': functional,
      'style': style,
    };
  }
}

/// Tool-specific attributes
class ToolAttributes {
  final String toolType; // pickaxe, shovel, axe, etc.
  final int miningSpeed; // 1-10
  final int durability; // 1-1000
  final List<String> minableBlocks;
  final bool enchanted;

  ToolAttributes({
    required this.toolType,
    this.miningSpeed = 5,
    this.durability = 100,
    this.minableBlocks = const ['stone', 'dirt', 'wood'],
    this.enchanted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'toolType': toolType,
      'miningSpeed': miningSpeed,
      'durability': durability,
      'minableBlocks': minableBlocks,
      'enchanted': enchanted,
    };
  }
}
