import 'language_service.dart';

/// Swedish export service for Swedish-specific export messages
class SwedishExportService {
  /// Get Swedish export success message
  static String getExportSuccessMessage() {
    return '🎉 Din skapelse har exporterats framgångsrikt! 🎉';
  }
  
  /// Get Swedish export error message
  static String getExportErrorMessage() {
    return '😅 Exporten misslyckades. Försök igen! 😅';
  }
  
  /// Get Swedish sharing success message
  static String getSharingSuccessMessage() {
    return '📤 Din skapelse har delats framgångsrikt! 📤';
  }
  
  /// Get Swedish sharing error message
  static String getSharingErrorMessage() {
    return '😅 Delningen misslyckades. Försök igen! 😅';
  }
  
  /// Get Swedish world creation message
  static String getWorldCreationMessage() {
    return '🌍 Skapar ny värld med din skapelse... 🌍';
  }
  
  /// Get Swedish addon installation message
  static String getAddonInstallationMessage() {
    return '📦 Installerar addon i din befintliga värld... 📦';
  }
  
  /// Get Swedish export progress message
  static String getExportProgressMessage() {
    return '⏳ Exporterar din skapelse... ⏳';
  }
  
  /// Get Swedish export complete message
  static String getExportCompleteMessage() {
    return '✅ Export slutförd! Din skapelse är redo för Minecraft! ✅';
  }
  
  /// Get Swedish creature saved message
  static String getCreatureSavedMessage() {
    return '💾 Din skapelse har sparats lokalt! 💾';
  }
  
  /// Get Swedish creature loaded message
  static String getCreatureLoadedMessage() {
    return '📂 Din skapelse har laddats från lokalt lagring! 📂';
  }
  
  /// Get Swedish share code generated message
  static String getShareCodeGeneratedMessage() {
    return '🔗 Delningskod genererad! Dela denna kod med dina vänner! 🔗';
  }
  
  /// Get Swedish share code copied message
  static String getShareCodeCopiedMessage() {
    return '📋 Delningskod kopierad till urklipp! 📋';
  }
  
  /// Get Swedish creature discovered message
  static String getCreatureDiscoveredMessage() {
    return '🔍 Ny skapelse upptäckt! Vill du ladda ner den? 🔍';
  }
  
  /// Get Swedish creature downloaded message
  static String getCreatureDownloadedMessage() {
    return '⬇️ Skapelse nedladdad framgångsrikt! ⬇️';
  }
  
  /// Get Swedish creature favorited message
  static String getCreatureFavoritedMessage() {
    return '⭐ Skapelse tillagd till favoriter! ⭐';
  }
  
  /// Get Swedish creature unfavorited message
  static String getCreatureUnfavoritedMessage() {
    return '💔 Skapelse borttagen från favoriter! 💔';
  }
  
  /// Get Swedish export location message
  static String getExportLocationMessage() {
    return '📁 Din skapelse har sparats i Downloads-mappen! 📁';
  }
  
  /// Get Swedish export instructions message
  static String getExportInstructionsMessage() {
    return '📖 Instruktioner: Öppna Minecraft, gå till Inställningar > Globala resurser > My Packs och aktivera din addon! 📖';
  }
}
