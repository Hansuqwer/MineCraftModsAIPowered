import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/enhanced_creature_attributes.dart';

/// Simple 3D Preview Widget
/// Uses Flutter's built-in 3D transforms for mobile-optimized rendering
class Simple3DPreview extends StatefulWidget {
  final EnhancedCreatureAttributes creatureAttributes;
  final String creatureName;
  final double size;
  final bool enableRotation;
  final bool enableZoom;
  final bool enableEffects;

  const Simple3DPreview({
    super.key,
    required this.creatureAttributes,
    required this.creatureName,
    this.size = 300.0,
    this.enableRotation = true,
    this.enableZoom = true,
    this.enableEffects = true,
  });

  @override
  State<Simple3DPreview> createState() => _Simple3DPreviewState();
}

class _Simple3DPreviewState extends State<Simple3DPreview>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    if (widget.enableRotation) {
      _rotationController.repeat();
    }
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _build3DContent(),
      ),
    );
  }

  Widget _build3DContent() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: widget.enableRotation ? _rotationAnimation.value : 0,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: _buildModel(),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildModel() {
    final baseType = widget.creatureAttributes.baseType.toLowerCase();
    final size = widget.creatureAttributes.size;
    final primaryColor = widget.creatureAttributes.primaryColor;
    final secondaryColor = widget.creatureAttributes.secondaryColor;
    final hasWings = widget.creatureAttributes.abilities.contains(SpecialAbility.flying);
    final hasFlames = widget.creatureAttributes.glowEffect == GlowEffect.flames;
    final hasGlow = widget.creatureAttributes.glowEffect != GlowEffect.none;

    // DEBUG: Print what we're trying to detect
    print('🔍 3D Preview Debug:');
    print('  baseType: "$baseType"');
    print('  size: $size');
    print('  primaryColor: $primaryColor');
    print('  secondaryColor: $secondaryColor');

    // COMPREHENSIVE MODEL DETECTION - ALL POSSIBLE TYPES
    
    // WEAPONS & SWORDS
    if (_isWeapon(baseType)) {
      print('  ✅ Detected as WEAPON');
      return _buildWeaponModel(baseType, size, primaryColor, hasFlames, hasGlow);
    }
    
    // CREATURES & ANIMALS
    else if (_isCreature(baseType)) {
      print('  ✅ Detected as CREATURE');
      return _buildCreatureModel(baseType, size, primaryColor, secondaryColor, hasWings, hasFlames);
    }
    
    // FURNITURE & DECORATION
    else if (_isFurniture(baseType)) {
      print('  ✅ Detected as FURNITURE');
      return _buildFurnitureModel(baseType, size, primaryColor, secondaryColor);
    }
    
    // ARMOR & CLOTHING
    else if (_isArmor(baseType)) {
      print('  ✅ Detected as ARMOR');
      return _buildArmorModel(baseType, size, primaryColor, hasGlow);
    }
    
    // TOOLS & EQUIPMENT
    else if (_isTool(baseType)) {
      print('  ✅ Detected as TOOL');
      return _buildToolModel(baseType, size, primaryColor, hasGlow);
    }
    
    // VEHICLES & TRANSPORT
    else if (_isVehicle(baseType)) {
      print('  ✅ Detected as VEHICLE');
      return _buildVehicleModel(baseType, size, primaryColor, secondaryColor);
    }
    
    // FOOD & CONSUMABLES
    else if (_isFood(baseType)) {
      print('  ✅ Detected as FOOD');
      return _buildFoodModel(baseType, size, primaryColor, secondaryColor);
    }
    
    // BLOCKS & BUILDING MATERIALS
    else if (_isBlock(baseType)) {
      print('  ✅ Detected as BLOCK');
      return _buildBlockModel(baseType, size, primaryColor, secondaryColor);
    }
    
    // MAGICAL ITEMS
    else if (_isMagical(baseType)) {
      print('  ✅ Detected as MAGICAL');
      return _buildMagicalModel(baseType, size, primaryColor, secondaryColor, hasGlow);
    }
    
    // DEFAULT FALLBACK - IMPROVED
    else {
      print('  ❌ No specific model detected, using GENERIC');
      print('  🔧 This is why you see a blue object!');
      return _buildImprovedGenericModel(baseType, size, primaryColor, secondaryColor);
    }
  }
  
  // COMPREHENSIVE TYPE DETECTION METHODS
  
  bool _isWeapon(String baseType) {
    final weapons = [
      'sword', 'weapon', 'blade', 'knife', 'dagger', 'axe', 'mace', 'club',
      'spear', 'lance', 'bow', 'crossbow', 'gun', 'rifle', 'pistol', 'cannon',
      'staff', 'wand', 'scythe', 'halberd', 'trident', 'hammer', 'flail'
    ];
    return weapons.any((weapon) => baseType.contains(weapon));
  }
  
  bool _isCreature(String baseType) {
    final creatures = [
      'dragon', 'creature', 'animal', 'beast', 'monster', 'pet',
      'cat', 'dog', 'cow', 'pig', 'chicken', 'sheep', 'horse', 'unicorn',
      'bird', 'eagle', 'owl', 'parrot', 'penguin', 'duck', 'goose',
      'bear', 'wolf', 'fox', 'rabbit', 'mouse', 'rat', 'hamster',
      'lion', 'tiger', 'leopard', 'cheetah', 'panther', 'jaguar',
      'elephant', 'rhino', 'hippo', 'giraffe', 'zebra', 'deer', 'elk',
      'monkey', 'ape', 'gorilla', 'chimpanzee', 'sloth', 'koala',
      'snake', 'lizard', 'gecko', 'iguana', 'turtle', 'tortoise',
      'frog', 'toad', 'salamander', 'newt', 'fish', 'shark', 'whale',
      'dolphin', 'seal', 'walrus', 'otter', 'beaver', 'squirrel',
      'chipmunk', 'hedgehog', 'porcupine', 'skunk', 'raccoon', 'opossum',
      'kangaroo', 'wallaby', 'wombat', 'platypus', 'echidna',
      'dinosaur', 'dino', 't-rex', 'triceratops', 'stegosaurus',
      'pterodactyl', 'pterosaur', 'raptor', 'velociraptor'
    ];
    return creatures.any((creature) => baseType.contains(creature));
  }
  
  bool _isFurniture(String baseType) {
    final furniture = [
      'furniture', 'chair', 'couch', 'sofa', 'table', 'desk', 'bed',
      'wardrobe', 'closet', 'cabinet', 'shelf', 'bookcase', 'dresser',
      'stool', 'bench', 'seat', 'cushion', 'pillow', 'mattress',
      'lamp', 'light', 'chandelier', 'mirror', 'frame', 'painting',
      'rug', 'carpet', 'curtain', 'blind', 'shade', 'screen',
      'door', 'window', 'gate', 'fence', 'wall', 'floor', 'ceiling'
    ];
    return furniture.any((item) => baseType.contains(item));
  }
  
  bool _isArmor(String baseType) {
    final armor = [
      'armor', 'armour', 'helmet', 'hat', 'cap', 'crown', 'tiara',
      'chestplate', 'breastplate', 'vest', 'jacket', 'coat', 'robe',
      'pants', 'trousers', 'leggings', 'shorts', 'skirt', 'dress',
      'boots', 'shoes', 'sneakers', 'sandals', 'slippers', 'socks',
      'gloves', 'gauntlets', 'mittens', 'bracelet', 'watch', 'ring',
      'necklace', 'pendant', 'amulet', 'charm', 'talisman', 'medallion',
      'shield', 'buckler', 'armguard', 'greaves', 'pauldrons'
    ];
    return armor.any((item) => baseType.contains(item));
  }
  
  bool _isTool(String baseType) {
    final tools = [
      'tool', 'pickaxe', 'axe', 'shovel', 'hoe', 'rake', 'fork',
      'hammer', 'mallet', 'sledgehammer', 'chisel', 'file', 'rasp',
      'saw', 'drill', 'screwdriver', 'wrench', 'pliers', 'clamp',
      'scissors', 'shears', 'knife', 'blade', 'cutter', 'slicer',
      'scraper', 'brush', 'broom', 'mop', 'sponge', 'cloth',
      'bucket', 'pail', 'container', 'box', 'crate', 'barrel',
      'bag', 'sack', 'pouch', 'purse', 'wallet', 'backpack'
    ];
    return tools.any((tool) => baseType.contains(tool));
  }
  
  bool _isVehicle(String baseType) {
    final vehicles = [
      'vehicle', 'car', 'truck', 'bus', 'van', 'jeep', 'suv',
      'motorcycle', 'bike', 'bicycle', 'scooter', 'skateboard',
      'boat', 'ship', 'yacht', 'canoe', 'kayak', 'raft', 'submarine',
      'plane', 'airplane', 'helicopter', 'jet', 'rocket', 'spaceship',
      'train', 'locomotive', 'tram', 'subway', 'metro', 'trolley',
      'tank', 'tractor', 'bulldozer', 'excavator', 'crane', 'forklift'
    ];
    return vehicles.any((vehicle) => baseType.contains(vehicle));
  }
  
  bool _isFood(String baseType) {
    final food = [
      'food', 'fruit', 'apple', 'banana', 'orange', 'grape', 'berry',
      'vegetable', 'carrot', 'potato', 'tomato', 'onion', 'lettuce',
      'meat', 'beef', 'pork', 'chicken', 'fish', 'salmon', 'tuna',
      'bread', 'cake', 'cookie', 'pie', 'pizza', 'sandwich', 'burger',
      'soup', 'stew', 'salad', 'pasta', 'rice', 'noodle', 'spaghetti',
      'drink', 'juice', 'soda', 'water', 'milk', 'coffee', 'tea',
      'candy', 'chocolate', 'candy', 'lollipop', 'gum', 'mint'
    ];
    return food.any((item) => baseType.contains(item));
  }
  
  bool _isBlock(String baseType) {
    final blocks = [
      'block', 'brick', 'stone', 'rock', 'pebble', 'boulder',
      'wood', 'log', 'plank', 'board', 'beam', 'post', 'pole',
      'metal', 'iron', 'steel', 'copper', 'bronze', 'brass',
      'gold', 'silver', 'platinum', 'diamond', 'gem', 'crystal',
      'glass', 'crystal', 'ice', 'snow', 'sand', 'dirt', 'mud',
      'clay', 'ceramic', 'porcelain', 'marble', 'granite', 'limestone'
    ];
    return blocks.any((block) => baseType.contains(block));
  }
  
  bool _isMagical(String baseType) {
    final magical = [
      'magic', 'magical', 'spell', 'enchant', 'enchantment', 'curse',
      'potion', 'elixir', 'potion', 'philter', 'brew', 'concoction',
      'wand', 'staff', 'rod', 'scepter', 'orb', 'crystal', 'gem',
      'amulet', 'talisman', 'charm', 'relic', 'artifact', 'treasure',
      'scroll', 'book', 'tome', 'grimoire', 'spellbook', 'manual',
      'rune', 'symbol', 'sigil', 'mark', 'seal', 'emblem', 'badge'
    ];
    return magical.any((item) => baseType.contains(item));
  }

  Widget _buildWeaponModel(String baseType, CreatureSize size, Color primaryColor, bool hasFlames, bool hasGlow) {
    final scale = _getSizeScale(size);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Sword blade
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0.0, -scale * 40)
            ..scale(scale),
          child: Container(
            width: 8,
            height: 80,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(4),
              boxShadow: hasGlow ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.8),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
          ),
        ),
        // Sword handle
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0.0, scale * 20)
            ..scale(scale),
          child: Container(
            width: 12,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513), // Brown
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        // Sword guard
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0.0, -scale * 10)
            ..scale(scale),
          child: Container(
            width: 20,
            height: 4,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Flame effect
        if (hasFlames)
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(0.0, -scale * 60)
              ..scale(scale),
            child: Container(
              width: 16,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.orange, Colors.red],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCreatureModel(String baseType, CreatureSize size, Color primaryColor, Color secondaryColor, bool hasWings, bool hasFlames) {
    final scale = _getSizeScale(size);
    
    // Different body shapes for different creatures
    double bodyWidth = 60;
    double bodyHeight = 40;
    double headSize = 30;
    
    if (baseType.contains('cat') || baseType.contains('dog')) {
      bodyWidth = 50;
      bodyHeight = 35;
      headSize = 25;
    } else if (baseType.contains('cow') || baseType.contains('horse')) {
      bodyWidth = 70;
      bodyHeight = 45;
      headSize = 35;
    } else if (baseType.contains('chicken') || baseType.contains('pig')) {
      bodyWidth = 45;
      bodyHeight = 30;
      headSize = 20;
    }
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Creature body
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(scale),
          child: Container(
            width: bodyWidth,
            height: bodyHeight,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(bodyHeight / 2),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
        // Creature head
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(-scale * (bodyWidth / 2 + 10), -scale * 10)
            ..scale(scale),
          child: Container(
            width: headSize,
            height: headSize * 0.8,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(headSize / 2),
            ),
          ),
        ),
        // Creature tail
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(scale * (bodyWidth / 2 + 5), scale * 5)
            ..scale(scale),
          child: Container(
            width: 15,
            height: 25,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        // Ears for cats/dogs
        if (baseType.contains('cat') || baseType.contains('dog')) ...[
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(-scale * (bodyWidth / 2 + 15), -scale * 20)
              ..scale(scale),
            child: Container(
              width: 8,
              height: 12,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(-scale * (bodyWidth / 2 + 5), -scale * 20)
              ..scale(scale),
            child: Container(
              width: 8,
              height: 12,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
        // Wings for flying creatures
        if (hasWings) ...[
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(-scale * 25, -scale * 5)
              ..scale(scale),
            child: Container(
              width: 35,
              height: 15,
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(scale * 25, -scale * 5)
              ..scale(scale),
            child: Container(
              width: 35,
              height: 15,
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
        // Flame effect
        if (hasFlames)
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(-scale * (bodyWidth / 2 + 20), -scale * 25)
              ..scale(scale),
            child: Container(
              width: 12,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.orange, Colors.red],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFurnitureModel(String baseType, CreatureSize size, Color primaryColor, Color secondaryColor) {
    final scale = _getSizeScale(size);
    
    if (baseType.contains('couch') || baseType.contains('sofa')) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // Couch seat
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(scale),
            child: Container(
              width: 80,
              height: 20,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Couch back
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(0, -scale * 15)
              ..scale(scale),
            child: Container(
              width: 80,
              height: 30,
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          // Left arm
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(-scale * 35, -scale * 5)
              ..scale(scale),
            child: Container(
              width: 15,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Right arm
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(scale * 35, -scale * 5)
              ..scale(scale),
            child: Container(
              width: 15,
              height: 40,
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      );
    } else if (baseType.contains('chair')) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // Chair seat
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(scale),
            child: Container(
              width: 40,
              height: 15,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Chair back
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(0, -scale * 20)
              ..scale(scale),
            child: Container(
              width: 40,
              height: 25,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Chair legs
          ...List.generate(4, (index) {
            final angle = (index * math.pi / 2);
            final x = math.cos(angle) * 15;
            final y = math.sin(angle) * 15;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(x * scale, y * scale + scale * 10)
                ..scale(scale),
              child: Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ],
      );
    } else if (baseType.contains('table') || baseType.contains('desk')) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // Table top
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(0, -scale * 15)
              ..scale(scale),
            child: Container(
              width: 80,
              height: 8,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Table legs
          ...List.generate(4, (index) {
            final angle = (index * math.pi / 2);
            final x = math.cos(angle) * 25;
            final y = math.sin(angle) * 25;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(x * scale, y * scale + scale * 5)
                ..scale(scale),
              child: Container(
                width: 6,
                height: 30,
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ],
      );
    }
    
    return _buildGenericModel(baseType, size, primaryColor, secondaryColor);
  }

  Widget _buildArmorModel(String baseType, CreatureSize size, Color primaryColor, bool hasGlow) {
    final scale = _getSizeScale(size);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Helmet
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0, -scale * 20)
            ..scale(scale),
          child: Container(
            width: 50,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: hasGlow ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.8),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
          ),
        ),
        // Chestplate
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(scale),
          child: Container(
            width: 60,
            height: 50,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolModel(String baseType, CreatureSize size, Color primaryColor, bool hasGlow) {
    final scale = _getSizeScale(size);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Tool head
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0, -scale * 20)
            ..scale(scale),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: hasGlow ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.8),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
          ),
        ),
        // Tool handle
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0, scale * 15)
            ..scale(scale),
          child: Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513), // Brown
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImprovedGenericModel(String baseType, CreatureSize size, Color primaryColor, Color secondaryColor) {
    final scale = _getSizeScale(size);
    
    // Try to make a better guess based on the baseType
    if (baseType.contains('cat') || baseType.contains('animal') || baseType.contains('creature')) {
      return _buildCreatureModel(baseType, size, primaryColor, secondaryColor, false, false);
    } else if (baseType.contains('table') || baseType.contains('chair') || baseType.contains('furniture')) {
      return _buildFurnitureModel(baseType, size, primaryColor, secondaryColor);
    } else if (baseType.contains('sword') || baseType.contains('weapon')) {
      return _buildWeaponModel(baseType, size, primaryColor, false, false);
    }
    
    // Create a more realistic generic model with textures
    return Stack(
      alignment: Alignment.center,
      children: [
        // Main body with gradient texture
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(scale),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                  primaryColor.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
        ),
        // Add texture details
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0, -scale * 20)
            ..scale(scale),
          child: Container(
            width: 30,
            height: 20,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  // VEHICLE MODEL BUILDER
  Widget _buildVehicleModel(String baseType, CreatureSize size, Color primaryColor, Color secondaryColor) {
    final scale = _getSizeScale(size);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Vehicle body
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(scale),
          child: Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        // Wheels
        ...List.generate(4, (index) {
          final angle = (index * math.pi / 2);
          final x = math.cos(angle) * 25;
          final y = math.sin(angle) * 15;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(x * scale, y * scale)
              ..scale(scale),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ],
    );
  }
  
  // FOOD MODEL BUILDER
  Widget _buildFoodModel(String baseType, CreatureSize size, Color primaryColor, Color secondaryColor) {
    final scale = _getSizeScale(size);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Food item
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(scale),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        // Food details
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0, -scale * 10)
            ..scale(scale),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
  
  // BLOCK MODEL BUILDER
  Widget _buildBlockModel(String baseType, CreatureSize size, Color primaryColor, Color secondaryColor) {
    final scale = _getSizeScale(size);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Block
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(scale),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
        // Block texture
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(scale),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
  
  // MAGICAL MODEL BUILDER
  Widget _buildMagicalModel(String baseType, CreatureSize size, Color primaryColor, Color secondaryColor, bool hasGlow) {
    final scale = _getSizeScale(size);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Magical item
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(scale),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: hasGlow ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.8),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ] : null,
            ),
          ),
        ),
        // Magical aura
        if (hasGlow)
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(scale * 1.5),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
      ],
    );
  }

  double _getSizeScale(CreatureSize size) {
    switch (size) {
      case CreatureSize.tiny:
        return 0.5;
      case CreatureSize.small:
        return 0.75;
      case CreatureSize.medium:
        return 1.0;
      case CreatureSize.large:
        return 1.5;
      case CreatureSize.giant:
        return 2.0;
    }
  }
}
