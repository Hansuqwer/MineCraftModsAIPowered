import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/language_service.dart';

/// Language selector widget for changing app language
class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  Locale? _selectedLocale;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  /// Load current language from storage
  Future<void> _loadCurrentLanguage() async {
    try {
      final currentLocale = await LanguageService.getCurrentLanguage();
      setState(() {
        _selectedLocale = currentLocale;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading current language: $e');
      setState(() {
        _selectedLocale = const Locale('en', '');
        _isLoading = false;
      });
    }
  }

  /// Change language and save to storage
  Future<void> _changeLanguage(Locale locale) async {
    try {
      await LanguageService.setLanguage(locale);
      setState(() {
        _selectedLocale = locale;
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              locale.languageCode == 'sv' 
                ? 'Språk ändrat till Svenska - Starta om appen för att se ändringarna' 
                : 'Language changed to English - Restart app to see changes'
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error changing language: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              locale.languageCode == 'sv' 
                ? 'Kunde inte ändra språk' 
                : 'Could not change language'
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const Center(child: Text('Loading...'));
    }
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.language,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),
        
        // English option
        _buildLanguageOption(
          locale: const Locale('en', ''),
          flag: '🇺🇸',
          name: 'English',
          isSelected: _selectedLocale?.languageCode == 'en',
        ),
        
        const SizedBox(height: 12),
        
        // Swedish option
        _buildLanguageOption(
          locale: const Locale('sv', ''),
          flag: '🇸🇪',
          name: 'Svenska',
          isSelected: _selectedLocale?.languageCode == 'sv',
        ),
        
        const SizedBox(height: 24),
        
        // Info text
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedLocale?.languageCode == 'sv'
                    ? 'Språket kommer att ändras nästa gång du startar appen.'
                    : 'The language will change the next time you start the app.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build language option widget
  Widget _buildLanguageOption({
    required Locale locale,
    required String flag,
    required String name,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _changeLanguage(locale),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
            ? const Color(0xFF98D8C8).withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
              ? const Color(0xFF98D8C8)
              : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected 
                    ? const Color(0xFF98D8C8)
                    : const Color(0xFF333333),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF98D8C8),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
