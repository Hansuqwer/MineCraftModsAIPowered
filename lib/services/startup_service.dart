import 'package:flutter/material.dart';
import 'language_service.dart';
import 'updater_service.dart';
import '../widgets/update_dialog.dart';

/// Service for handling app startup tasks
class StartupService {
  /// Initialize all startup services
  static Future<void> initialize(BuildContext context) async {
    print('🚀 Starting Crafta initialization...');
    
    // Initialize language service
    await _initializeLanguage();
    
    // Check for updates (non-blocking)
    _checkForUpdates(context);
    
    print('✅ Crafta initialization complete');
  }
  
  /// Initialize language service
  static Future<void> _initializeLanguage() async {
    try {
      final currentLocale = await LanguageService.getCurrentLanguage();
      print('🌍 Language initialized: ${currentLocale.languageCode}');
    } catch (e) {
      print('❌ Language initialization failed: $e');
    }
  }
  
  /// Check for updates (non-blocking)
  static void _checkForUpdates(BuildContext context) {
    // Run update check in background
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        final updateInfo = await UpdaterService.checkForUpdates();
        
        if (updateInfo != null && updateInfo.isUpdateAvailable) {
          print('🆕 Update available: ${updateInfo.latestVersion}');
          
          // Show update dialog if context is still valid
          if (context.mounted) {
            _showUpdateDialog(context, updateInfo);
          }
        } else {
          print('✅ App is up to date');
        }
      } catch (e) {
        print('❌ Update check failed: $e');
      }
    });
  }
  
  /// Show update dialog
  static void _showUpdateDialog(BuildContext context, UpdateInfo updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateDialog(
        updateInfo: updateInfo,
        onSkip: () {
          Navigator.of(context).pop();
          UpdaterService.skipVersion(updateInfo.latestVersion);
        },
        onLater: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
