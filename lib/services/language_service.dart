import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Service for managing app language
class LanguageService {
  static const String _languageKey = 'selected_language';
  static const Locale _defaultLocale = Locale('en', '');
  
  /// Get the current language from storage
  static Future<Locale> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    return Locale(languageCode);
  }
  
  /// Set the app language
  static Future<void> setLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }
  
  /// Get supported locales
  static List<Locale> getSupportedLocales() {
    return [
      const Locale('en', ''), // English
      const Locale('sv', ''), // Swedish
    ];
  }
  
  /// Get localization delegates
  static List<LocalizationsDelegate> getLocalizationDelegates() {
    return [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];
  }
  
  /// Get language name for display
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'sv':
        return 'Svenska';
      default:
        return 'English';
    }
  }
  
  /// Get language flag emoji
  static String getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'sv':
        return '🇸🇪';
      default:
        return '🇺🇸';
    }
  }
}
