#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Test Export Functionality
/// Tests if the export system is working properly
void main() async {
  print('🧪 TESTING EXPORT FUNCTIONALITY');
  print('=' * 50);
  
  // Test 1: Check if export service exists
  print('\n📁 Test 1: Export Service Files');
  final exportServiceFile = File('lib/services/ai_minecraft_export_service.dart');
  if (await exportServiceFile.exists()) {
    print('✅ Export service file exists');
  } else {
    print('❌ Export service file missing');
    return;
  }
  
  // Test 2: Check if 3D viewer has export button
  print('\n🎮 Test 2: 3D Viewer Export Button');
  final viewerFile = File('lib/screens/minecraft_3d_viewer_screen.dart');
  if (await viewerFile.exists()) {
    final content = await viewerFile.readAsString();
    if (content.contains('_exportToMinecraft') && content.contains('PUT IN GAME')) {
      print('✅ Export button exists in 3D viewer');
    } else {
      print('❌ Export button missing in 3D viewer');
    }
  } else {
    print('❌ 3D viewer file missing');
  }
  
  // Test 3: Check if .mcpack creation method exists
  print('\n📦 Test 3: .mcpack Creation');
  final exportContent = await exportServiceFile.readAsString();
  if (exportContent.contains('_createMcpackFile') && exportContent.contains('.mcpack')) {
    print('✅ .mcpack creation method exists');
  } else {
    print('❌ .mcpack creation method missing');
  }
  
  // Test 4: Check if exports directory exists
  print('\n📂 Test 4: Exports Directory');
  final exportsDir = Directory('exports');
  if (await exportsDir.exists()) {
    print('✅ Exports directory exists');
    final files = await exportsDir.list().toList();
    print('   Files in exports: ${files.length}');
  } else {
    print('⚠️ Exports directory does not exist (will be created)');
  }
  
  // Test 5: Check for existing .mcpack files
  print('\n🎯 Test 5: Existing .mcpack Files');
  final mcpackFiles = await Directory('.').list()
      .where((file) => file.path.endsWith('.mcpack'))
      .toList();
  
  if (mcpackFiles.isNotEmpty) {
    print('✅ Found .mcpack files:');
    for (final file in mcpackFiles) {
      print('   - ${file.path}');
    }
  } else {
    print('⚠️ No .mcpack files found');
  }
  
  // Test 6: Check export directory permissions
  print('\n🔐 Test 6: Directory Permissions');
  try {
    final testDir = Directory('test_export');
    await testDir.create();
    await testDir.delete();
    print('✅ Directory creation/deletion works');
  } catch (e) {
    print('❌ Directory permission issue: $e');
  }
  
  print('\n🎯 EXPORT TESTING COMPLETE');
  print('=' * 50);
  
  // Generate recommendations
  print('\n💡 RECOMMENDATIONS:');
  if (mcpackFiles.isEmpty) {
    print('1. Try creating an item in the app and use "PUT IN GAME"');
    print('2. Check if the export process completes without errors');
    print('3. Look for .mcpack files in the app directory');
  } else {
    print('1. .mcpack files exist - try importing them into Minecraft');
    print('2. Check if Minecraft recognizes the .mcpack files');
    print('3. Verify the files are in the correct location');
  }
}



