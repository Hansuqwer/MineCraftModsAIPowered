import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for checking and handling app updates
class UpdaterService {
  // TODO: Replace with actual repository URLs when GitHub repository is created
  static const String _versionCheckUrl = 'https://api.github.com/repos/crafta-app/crafta/releases/latest';
  static const String _downloadUrl = 'https://github.com/crafta-app/crafta/releases/latest';
  static const String _lastCheckKey = 'last_update_check';
  static const String _skipVersionKey = 'skip_version';
  
  /// Check for updates on app startup
  static Future<UpdateInfo?> checkForUpdates({bool forceCheck = false}) async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final buildNumber = packageInfo.buildNumber;
      
      print('🔍 Checking for updates... Current version: $currentVersion ($buildNumber)');
      
      // Check if we should skip this check
      if (!forceCheck && await _shouldSkipCheck()) {
        print('⏭️ Skipping update check (recently checked)');
        return null;
      }
      
      // Make API request to check latest version
      final response = await http.get(
        Uri.parse(_versionCheckUrl),
        headers: {'User-Agent': 'Crafta-Updater/1.0'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['tag_name']?.replaceAll('v', '') ?? '';
        final releaseNotes = data['body'] ?? '';
        final publishedAt = data['published_at'] ?? '';
        
        print('📦 Latest version: $latestVersion');
        
        // Compare versions
        if (_isNewerVersion(latestVersion, currentVersion)) {
          print('🆕 Update available: $latestVersion > $currentVersion');
          
          // Save check timestamp
          await _saveLastCheckTime();
          
          return UpdateInfo(
            currentVersion: currentVersion,
            latestVersion: latestVersion,
            releaseNotes: releaseNotes,
            publishedAt: publishedAt,
            downloadUrl: _downloadUrl,
            isUpdateAvailable: true,
          );
        } else {
          print('✅ App is up to date');
          await _saveLastCheckTime();
          return UpdateInfo(
            currentVersion: currentVersion,
            latestVersion: latestVersion,
            isUpdateAvailable: false,
          );
        }
      } else if (response.statusCode == 404) {
        print('📝 Repository not found - update checking disabled until repository is created');
        return null;
      } else {
        print('❌ Failed to check for updates: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Update check failed: $e');
      return null;
    }
  }
  
  /// Check if we should skip the update check
  static Future<bool> _shouldSkipCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      const oneDayInMs = 24 * 60 * 60 * 1000; // 24 hours
      
      return (now - lastCheck) < oneDayInMs;
    } catch (e) {
      return false;
    }
  }
  
  /// Save the last check time
  static Future<void> _saveLastCheckTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('❌ Failed to save check time: $e');
    }
  }
  
  /// Skip this version update
  static Future<void> skipVersion(String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_skipVersionKey, version);
    } catch (e) {
      print('❌ Failed to skip version: $e');
    }
  }
  
  /// Check if this version was skipped
  static Future<bool> isVersionSkipped(String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final skippedVersion = prefs.getString(_skipVersionKey);
      return skippedVersion == version;
    } catch (e) {
      return false;
    }
  }
  
  /// Launch download URL
  static Future<void> downloadUpdate(String downloadUrl) async {
    try {
      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('❌ Cannot launch download URL');
      }
    } catch (e) {
      print('❌ Failed to launch download URL: $e');
    }
  }
  
  /// Compare version strings
  static bool _isNewerVersion(String latest, String current) {
    try {
      final latestParts = latest.split('.').map(int.parse).toList();
      final currentParts = current.split('.').map(int.parse).toList();
      
      // Pad with zeros if needed
      while (latestParts.length < 3) latestParts.add(0);
      while (currentParts.length < 3) currentParts.add(0);
      
      for (int i = 0; i < 3; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      
      return false; // Versions are equal
    } catch (e) {
      print('❌ Version comparison failed: $e');
      return false;
    }
  }
}

/// Update information model
class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String? releaseNotes;
  final String? publishedAt;
  final String? downloadUrl;
  final bool isUpdateAvailable;
  
  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    this.releaseNotes,
    this.publishedAt,
    this.downloadUrl,
    required this.isUpdateAvailable,
  });
  
  /// Get formatted release date
  String get formattedDate {
    if (publishedAt == null) return '';
    try {
      final date = DateTime.parse(publishedAt!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
  
  /// Get short release notes (first 200 characters)
  String get shortReleaseNotes {
    if (releaseNotes == null) return '';
    return releaseNotes!.length > 200 
        ? '${releaseNotes!.substring(0, 200)}...'
        : releaseNotes!;
  }
}
