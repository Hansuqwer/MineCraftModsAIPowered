import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

/// Minecraft Launcher Service
/// Launches Minecraft app from Crafta with .mcpack addon
class MinecraftLauncherService {
  // Minecraft package names for different platforms
  static const String _minecraftPackageAndroid =
      'com.mojang.minecraftpe';
  static const String _minecraftPackageAmazon =
      'com.mojang.minecraftpe.amazon';

  /// Check if Minecraft is installed on device
  static Future<bool> isMinecraftInstalled() async {
    try {
      // Try Android Minecraft
      if (await canLaunchUrl(Uri(scheme: 'minecraft'))) {
        print('✅ [LAUNCHER] Minecraft app found');
        return true;
      }

      print('⚠️ [LAUNCHER] Minecraft app not detected');
      return false;
    } catch (e) {
      print('❌ [LAUNCHER] Error checking Minecraft: $e');
      return false;
    }
  }

  /// Launch Minecraft with addon
  /// worldType: 'new' for new world, 'existing' for existing world
  static Future<void> launchMinecraftWithAddon(
    String mcpackPath,
    String worldType,
  ) async {
    try {
      print('🎮 [LAUNCHER] Launching Minecraft...');
      print('📦 [LAUNCHER] Addon path: $mcpackPath');
      print('🌍 [LAUNCHER] World type: $worldType');

      // Verify file exists
      final file = File(mcpackPath);
      if (!await file.exists()) {
        throw Exception('.mcpack file not found: $mcpackPath');
      }

      // On Android, use file:// URI scheme
      final fileUri = Uri.file(mcpackPath).toString();
      print('📍 [LAUNCHER] File URI: $fileUri');

      // Method 1: Try direct Minecraft intent
      print('🔄 [LAUNCHER] Attempting Minecraft intent...');
      final minecraftUri = Uri(
        scheme: 'minecraft',
        path: '/import',
        queryParameters: {
          'file': mcpackPath,
          'worldType': worldType,
        },
      );

      if (await canLaunchUrl(minecraftUri)) {
        print('✅ [LAUNCHER] Minecraft intent available');
        await launchUrl(minecraftUri);
        print('✅ [LAUNCHER] Minecraft launched');
        return;
      }

      // Method 2: Try content:// scheme (Android file access)
      print('🔄 [LAUNCHER] Trying content scheme...');
      final contentUri = Uri(
        scheme: 'content',
        host: 'file',
        path: mcpackPath,
      );

      if (await canLaunchUrl(contentUri)) {
        print('✅ [LAUNCHER] Content scheme available');
        await launchUrl(contentUri);
        print('✅ [LAUNCHER] Minecraft launched');
        return;
      }

      // Method 3: Try file:// scheme directly
      print('🔄 [LAUNCHER] Trying file scheme...');
      final fileUriObj = Uri.file(mcpackPath);

      if (await canLaunchUrl(fileUriObj)) {
        print('✅ [LAUNCHER] File scheme available');
        await launchUrl(fileUriObj);
        print('✅ [LAUNCHER] Minecraft launched');
        return;
      }

      // Method 4: Launch Minecraft app and user imports manually
      print('🔄 [LAUNCHER] Launching Minecraft app...');
      final minecraftAppUri = Uri(scheme: 'minecraft');

      if (await canLaunchUrl(minecraftAppUri)) {
        print('✅ [LAUNCHER] Opening Minecraft app');
        await launchUrl(minecraftAppUri);
        print('⚠️ [LAUNCHER] Please manually import the addon file:');
        print('   $mcpackPath');
        return;
      }

      throw Exception('Could not launch Minecraft - app may not be installed');
    } catch (e) {
      print('❌ [LAUNCHER] Error launching Minecraft: $e');
      rethrow;
    }
  }

  /// Copy .mcpack to shared location for Minecraft import
  /// Some Minecraft versions expect files in specific locations
  static Future<String> copyToMinecraftFolder(String mcpackPath) async {
    try {
      print('📁 [LAUNCHER] Copying addon to Minecraft folder...');

      // Source file
      final sourceFile = File(mcpackPath);
      if (!await sourceFile.exists()) {
        throw Exception('Source file not found: $mcpackPath');
      }

      // Target location (Android external storage or Documents)
      final String targetPath;
      if (Platform.isAndroid) {
        // Try multiple common locations
        final possiblePaths = [
          '/sdcard/Android/data/com.mojang.minecraftpe/files/games/com.mojang/minecraftWorlds/',
          '/sdcard/Android/data/com.mojang.minecraftpe/files/behavior_packs/',
          '/sdcard/Download/',
          '/sdcard/Documents/',
        ];

        targetPath = possiblePaths.first; // Use first available
        print('📁 [LAUNCHER] Target folder: $targetPath');

        // Create directory if needed
        final targetDir = Directory(targetPath);
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
      } else {
        throw Exception('Unsupported platform: ${Platform.operatingSystem}');
      }

      // Copy file
      final targetFile = File('$targetPath${sourceFile.path.split('/').last}');
      await sourceFile.copy(targetFile.path);

      print('✅ [LAUNCHER] File copied to: ${targetFile.path}');
      return targetFile.path;
    } catch (e) {
      print('❌ [LAUNCHER] Error copying file: $e');
      rethrow;
    }
  }

  /// Show user instructions if Minecraft not installed
  static String getMissingMinecraftInstructions() {
    return '''
Minecraft is not installed on your device.

To play with your creation:
1. Install Minecraft: Bedrock Edition from Google Play Store
2. Open Minecraft
3. Go to Settings > Creator Tools > Import Add-ons
4. Select the file from your Downloads folder

Your addon file is saved at:
/sdcard/Download/ (check your Downloads folder)

Make sure it has a .mcpack extension.
''';
  }
}
