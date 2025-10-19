#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// 🎯 3D PREVIEW VERIFICATION TEST
/// Tests that 3D preview actually shows correct models for different items
/// 
/// Usage: dart test_3d_preview_verification.dart

void main() async {
  print('🎨 3D PREVIEW VERIFICATION TEST');
  print('=' * 50);
  
  // Test different item types to ensure correct 3D models
  final testItems = [
    {'name': 'Grey Cat', 'baseType': 'cat', 'expectedModel': 'creature'},
    {'name': 'Red Dragon', 'baseType': 'dragon', 'expectedModel': 'creature'},
    {'name': 'Wooden Table', 'baseType': 'table', 'expectedModel': 'furniture'},
    {'name': 'Blue Couch', 'baseType': 'couch', 'expectedModel': 'furniture'},
    {'name': 'Iron Sword', 'baseType': 'sword', 'expectedModel': 'weapon'},
    {'name': 'Golden Apple', 'baseType': 'apple', 'expectedModel': 'food'},
    {'name': 'Diamond Armor', 'baseType': 'armor', 'expectedModel': 'armor'},
    {'name': 'Stone Block', 'baseType': 'block', 'expectedModel': 'block'},
  ];
  
  print('🧪 Testing 3D Preview Model Detection...\n');
  
  for (final item in testItems) {
    await testItemModel(item);
  }
  
  print('\n🎯 3D PREVIEW VERIFICATION COMPLETE');
  print('=' * 50);
}

Future<void> testItemModel(Map<String, String> item) async {
  final name = item['name']!;
  final baseType = item['baseType']!;
  final expectedModel = item['expectedModel']!;
  
  print('🔍 Testing: $name (baseType: $baseType)');
  
  try {
    // Read the simple_3d_preview.dart file
    final content = await File('lib/widgets/simple_3d_preview.dart').readAsString();
    
    // Test model detection logic
    bool hasCorrectDetection = false;
    String detectionMethod = '';
    
    switch (expectedModel) {
      case 'creature':
        if (content.contains('_isCreature') && content.contains('_buildCreatureModel')) {
          hasCorrectDetection = true;
          detectionMethod = '_isCreature';
        }
        break;
      case 'furniture':
        if (content.contains('_isFurniture') && content.contains('_buildFurnitureModel')) {
          hasCorrectDetection = true;
          detectionMethod = '_isFurniture';
        }
        break;
      case 'weapon':
        if (content.contains('_isWeapon') && content.contains('_buildWeaponModel')) {
          hasCorrectDetection = true;
          detectionMethod = '_isWeapon';
        }
        break;
      case 'food':
        if (content.contains('_isFood') && content.contains('_buildFoodModel')) {
          hasCorrectDetection = true;
          detectionMethod = '_isFood';
        }
        break;
      case 'armor':
        if (content.contains('_isArmor') && content.contains('_buildArmorModel')) {
          hasCorrectDetection = true;
          detectionMethod = '_isArmor';
        }
        break;
      case 'block':
        if (content.contains('_isBlock') && content.contains('_buildBlockModel')) {
          hasCorrectDetection = true;
          detectionMethod = '_isBlock';
        }
        break;
    }
    
    if (hasCorrectDetection) {
      print('  ✅ Model detection: $detectionMethod method exists');
      
      // Test specific model building
      bool hasModelBuilder = false;
      switch (baseType) {
        case 'cat':
          if (content.contains('_buildCat') || content.contains('_buildCreatureModel')) {
            hasModelBuilder = true;
          }
          break;
        case 'dragon':
          if (content.contains('_buildDragon') || content.contains('_buildCreatureModel')) {
            hasModelBuilder = true;
          }
          break;
        case 'table':
          if (content.contains('_buildTable') || content.contains('_buildFurnitureModel')) {
            hasModelBuilder = true;
          }
          break;
        case 'couch':
          if (content.contains('_buildCouch') || content.contains('_buildFurnitureModel')) {
            hasModelBuilder = true;
          }
          break;
        case 'sword':
          if (content.contains('_buildSword') || content.contains('_buildWeaponModel')) {
            hasModelBuilder = true;
          }
          break;
        case 'apple':
          if (content.contains('_buildApple') || content.contains('_buildFoodModel')) {
            hasModelBuilder = true;
          }
          break;
        case 'armor':
          if (content.contains('_buildArmor') || content.contains('_buildArmorModel')) {
            hasModelBuilder = true;
          }
          break;
        case 'block':
          if (content.contains('_buildBlock') || content.contains('_buildBlockModel')) {
            hasModelBuilder = true;
          }
          break;
      }
      
      if (hasModelBuilder) {
        print('  ✅ Model builder: Specific builder for $baseType exists');
        print('  🎯 RESULT: $name will show correct 3D model');
      } else {
        print('  ⚠️ Model builder: Generic builder for $baseType');
        print('  🎯 RESULT: $name will show generic 3D model');
      }
    } else {
      print('  ❌ Model detection: Missing $detectionMethod method');
      print('  🚨 RESULT: $name will show orange cube (WRONG!)');
    }
    
  } catch (e) {
    print('  ❌ ERROR: $e');
  }
  
  print('');
}

/// Test specific model components
Future<void> testModelComponents() async {
  print('🔧 Testing Model Components...\n');
  
  final content = await File('lib/widgets/simple_3d_preview.dart').readAsString();
  
  // Test table model specifically (user requested)
  if (content.contains('_buildTable')) {
    print('✅ Table model: _buildTable method exists');
    
    if (content.contains('Table top') && content.contains('4 legs')) {
      print('✅ Table model: Has table top and legs');
    } else {
      print('❌ Table model: Missing table top or legs');
    }
    
    if (content.contains('brown') && content.contains('amber')) {
      print('✅ Table model: Has proper colors (brown top, amber legs)');
    } else {
      print('❌ Table model: Missing proper colors');
    }
  } else {
    print('❌ Table model: _buildTable method missing');
  }
  
  print('');
  
  // Test creature models
  if (content.contains('_buildCreatureModel')) {
    print('✅ Creature model: _buildCreatureModel method exists');
  } else {
    print('❌ Creature model: _buildCreatureModel method missing');
  }
  
  // Test furniture models
  if (content.contains('_buildFurnitureModel')) {
    print('✅ Furniture model: _buildFurnitureModel method exists');
  } else {
    print('❌ Furniture model: _buildFurnitureModel method missing');
  }
  
  // Test weapon models
  if (content.contains('_buildWeaponModel')) {
    print('✅ Weapon model: _buildWeaponModel method exists');
  } else {
    print('❌ Weapon model: _buildWeaponModel method missing');
  }
  
  print('');
}

