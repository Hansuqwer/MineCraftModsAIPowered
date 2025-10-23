import 'dart:io';

void main() async {
  print('🧪 Testing Export Functionality');
  print('==============================');
  
  // Test 1: Directory access
  print('\n1. Testing directory access...');
  await testDirectoryAccess();
  
  // Test 2: File creation
  print('\n2. Testing file creation...');
  await testFileCreation();
  
  print('\n✅ Export tests completed!');
}

Future<void> testDirectoryAccess() async {
  try {
    // Test application documents directory
    final appDir = Directory('/home/rickard/MineCraftModsAIPowered/crafta');
    if (await appDir.exists()) {
      print('   ✅ Application directory accessible');
    } else {
      print('   ❌ Application directory not accessible');
    }
    
    // Test downloads directory
    final downloadsDir = Directory('/home/rickard/Downloads');
    if (await downloadsDir.exists()) {
      print('   ✅ Downloads directory accessible');
    } else {
      print('   ❌ Downloads directory not accessible');
    }
    
  } catch (e) {
    print('   ❌ Directory access error: $e');
  }
}

Future<void> testFileCreation() async {
  try {
    // Test creating a simple file
    final testFile = File('/home/rickard/Downloads/test_export.txt');
    await testFile.writeAsString('Test export file created successfully!');
    
    if (await testFile.exists()) {
      print('   ✅ File creation successful');
      print('   📁 File location: ${testFile.path}');
      
      // Clean up
      await testFile.delete();
      print('   🧹 Test file cleaned up');
    } else {
      print('   ❌ File creation failed');
    }
    
  } catch (e) {
    print('   ❌ File creation error: $e');
  }
}
