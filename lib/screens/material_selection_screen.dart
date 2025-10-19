import 'package:flutter/material.dart';
import '../models/item_type.dart';
import '../theme/minecraft_theme.dart';

/// Material Selection Screen
/// Lets kids choose material for their weapon/armor/tool/furniture
class MaterialSelectionScreen extends StatefulWidget {
  final ItemType itemType;

  const MaterialSelectionScreen({
    super.key,
    required this.itemType,
  });

  @override
  State<MaterialSelectionScreen> createState() => _MaterialSelectionScreenState();
}

class _MaterialSelectionScreenState extends State<MaterialSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<ItemMaterialType> _getCompatibleMaterials() {
    return ItemMaterialType.values
        .where((material) => material.isCompatibleWith(widget.itemType))
        .toList();
  }

  Color _getMaterialColor(ItemMaterialType material) {
    switch (material) {
      case ItemMaterialType.wood:
        return MinecraftTheme.oakWood;
      case ItemMaterialType.stone:
        return MinecraftTheme.stoneGray;
      case ItemMaterialType.iron:
        return const Color(0xFFD8D8D8);
      case ItemMaterialType.gold:
        return MinecraftTheme.goldOre;
      case ItemMaterialType.diamond:
        return MinecraftTheme.diamond;
      case ItemMaterialType.netherite:
        return MinecraftTheme.coalBlack;
      case ItemMaterialType.leather:
        return const Color(0xFF8B4513);
      case ItemMaterialType.chain:
        return const Color(0xFFA9A9A9);
      case ItemMaterialType.glass:
        return const Color(0xFFE0F6FF);
      case ItemMaterialType.wool:
        return const Color(0xFFF5F5F5);
    }
  }

  void _selectMaterial(ItemMaterialType material) {
    Navigator.pop(context, material);
  }

  @override
  Widget build(BuildContext context) {
    final compatibleMaterials = _getCompatibleMaterials();

    return Scaffold(
      backgroundColor: MinecraftTheme.dirtBrown,
      appBar: AppBar(
        backgroundColor: MinecraftTheme.deepStone,
        elevation: 0,
        title: MinecraftText(
          'CHOOSE YOUR MATERIAL',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: MinecraftTheme.goldOre,
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: MinecraftTheme.minecraftButton(),
            child: Icon(
              Icons.arrow_back,
              color: MinecraftTheme.textLight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MinecraftTheme.grassGreen.withOpacity(0.2),
              MinecraftTheme.dirtBrown,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Title
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: MinecraftTheme.slotBackground.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: MinecraftTheme.goldOre,
                          width: 3,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category,
                            color: MinecraftTheme.goldOre,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          MinecraftText(
                            'Pick Your Material',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: MinecraftTheme.goldOre,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Material grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: compatibleMaterials.length,
                  itemBuilder: (context, index) {
                    final material = compatibleMaterials[index];
                    return _buildMaterialCard(material);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialCard(ItemMaterialType material) {
    final materialColor = _getMaterialColor(material);

    return GestureDetector(
      onTap: () => _selectMaterial(material),
      child: Container(
        decoration: BoxDecoration(
          color: materialColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: MinecraftTheme.deepStone,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _MaterialPatternPainter(materialColor),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        material.emoji,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Name
                  MinecraftText(
                    material.displayName.toUpperCase(),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Durability bar
                  _buildDurabilityBar(material),

                  const SizedBox(height: 4),

                  // Durability text
                  Text(
                    'Durability: ${material.durability}/10',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(1, 1),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Shine effect
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white.withOpacity(0.7),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurabilityBar(ItemMaterialType material) {
    return Container(
      width: double.infinity,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: material.durability / 10,
        child: Container(
          decoration: BoxDecoration(
            color: _getDurabilityColor(material.durability),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Color _getDurabilityColor(int durability) {
    if (durability >= 8) return Colors.green;
    if (durability >= 5) return Colors.yellow;
    return Colors.orange;
  }
}

/// Custom painter for material texture pattern
class _MaterialPatternPainter extends CustomPainter {
  final Color color;

  _MaterialPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw pixel-like pattern
    for (var i = 0; i < size.width; i += 8) {
      for (var j = 0; j < size.height; j += 8) {
        if ((i + j) % 16 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(i.toDouble(), j.toDouble(), 8, 8),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
