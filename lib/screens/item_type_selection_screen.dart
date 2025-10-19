import 'package:flutter/material.dart';
import '../models/item_type.dart';
import '../theme/minecraft_theme.dart';
import '../services/app_localizations.dart';

/// Item Type Selection Screen
/// Lets kids choose what type of item they want to create
class ItemTypeSelectionScreen extends StatefulWidget {
  const ItemTypeSelectionScreen({super.key});

  @override
  State<ItemTypeSelectionScreen> createState() => _ItemTypeSelectionScreenState();
}

class _ItemTypeSelectionScreenState extends State<ItemTypeSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late Animation<double> _titleAnimation;

  ItemCategory _selectedCategory = ItemCategory.living;

  @override
  void initState() {
    super.initState();

    _titleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _titleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  List<ItemType> _getItemTypesForCategory(ItemCategory category) {
    return ItemType.values.where((type) => type.category == category).toList();
  }

  Color _getCategoryColor(ItemCategory category) {
    switch (category) {
      case ItemCategory.living:
        return MinecraftTheme.grassGreen;
      case ItemCategory.combat:
        return MinecraftTheme.redstone;
      case ItemCategory.utility:
        return MinecraftTheme.oakWood;
      case ItemCategory.decorative:
        return MinecraftTheme.diamond;
    }
  }

  String _getCategoryName(ItemCategory category) {
    switch (category) {
      case ItemCategory.living:
        return 'CREATURES';
      case ItemCategory.combat:
        return 'COMBAT';
      case ItemCategory.utility:
        return 'UTILITY';
      case ItemCategory.decorative:
        return 'DECORATIVE';
    }
  }

  String _getCategoryEmoji(ItemCategory category) {
    switch (category) {
      case ItemCategory.living:
        return '🐲';
      case ItemCategory.combat:
        return '⚔️';
      case ItemCategory.utility:
        return '🔨';
      case ItemCategory.decorative:
        return '🎨';
    }
  }

  void _selectItemType(ItemType itemType) {
    Navigator.pop(context, itemType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinecraftTheme.dirtBrown,
      appBar: AppBar(
        backgroundColor: MinecraftTheme.deepStone,
        elevation: 0,
        title: MinecraftText(
          'WHAT DO YOU WANT TO CREATE?',
          fontSize: 16,
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

              // Title with animation
              AnimatedBuilder(
                animation: _titleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _titleAnimation.value,
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
                        boxShadow: [
                          BoxShadow(
                            color: MinecraftTheme.goldOre.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: MinecraftTheme.goldOre,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: MinecraftText(
                              'Choose Your Creation',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: MinecraftTheme.goldOre,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Category selector
              _buildCategorySelector(),

              const SizedBox(height: 16),

              // Item type grid
              Expanded(
                child: _buildItemTypeGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ItemCategory.values.length,
        itemBuilder: (context, index) {
          final category = ItemCategory.values[index];
          final isSelected = category == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? _getCategoryColor(category)
                    : MinecraftTheme.buttonBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? MinecraftTheme.goldOre
                      : MinecraftTheme.deepStone,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _getCategoryColor(category).withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getCategoryEmoji(category),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  MinecraftText(
                    _getCategoryName(category),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? MinecraftTheme.textLight
                        : MinecraftTheme.stoneGray,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemTypeGrid() {
    final itemTypes = _getItemTypesForCategory(_selectedCategory);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: itemTypes.length,
      itemBuilder: (context, index) {
        final itemType = itemTypes[index];
        return _buildItemTypeCard(itemType);
      },
    );
  }

  Widget _buildItemTypeCard(ItemType itemType) {
    return GestureDetector(
      onTap: () => _selectItemType(itemType),
      child: Container(
        decoration: BoxDecoration(
          color: MinecraftTheme.slotBackground.withOpacity(0.95),
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
            // Background gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getCategoryColor(_selectedCategory).withOpacity(0.2),
                    _getCategoryColor(_selectedCategory).withOpacity(0.05),
                  ],
                ),
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
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(_selectedCategory).withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getCategoryColor(_selectedCategory),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        itemType.emoji,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Name
                  MinecraftText(
                    itemType.displayName.toUpperCase(),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MinecraftTheme.textDark,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    itemType.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: MinecraftTheme.stoneGray,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
                color: MinecraftTheme.goldOre.withOpacity(0.5),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
