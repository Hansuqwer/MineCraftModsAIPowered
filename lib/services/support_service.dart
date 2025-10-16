import 'package:flutter/material.dart';
import 'dart:io';

class SupportService {
  static final SupportService _instance = SupportService._internal();
  factory SupportService() => _instance;
  SupportService._internal();

  // Support data
  bool _isSupportActive = false;
  Map<String, dynamic> _supportData = {};
  
  /// Initialize support service
  Future<void> initialize() async {
    _isSupportActive = true;
    _supportData = {
      'startTime': DateTime.now().millisecondsSinceEpoch,
      'supportRequests': 0,
      'faqViews': 0,
      'helpArticles': 0,
      'userFeedback': 0,
      'satisfactionRating': 0,
    };
    
    print('Support service initialized');
  }

  /// Track support request
  void trackSupportRequest(String category, String description) {
    if (!_isSupportActive) return;
    
    _supportData['supportRequests'] = 
        (_supportData['supportRequests'] as int) + 1;
    
    print('Support: Request tracked - $category: $description');
  }

  /// Track FAQ view
  void trackFAQView(String question) {
    if (!_isSupportActive) return;
    
    _supportData['faqViews'] = 
        (_supportData['faqViews'] as int) + 1;
    
    print('Support: FAQ view tracked - $question');
  }

  /// Track help article view
  void trackHelpArticleView(String article) {
    if (!_isSupportActive) return;
    
    _supportData['helpArticles'] = 
        (_supportData['helpArticles'] as int) + 1;
    
    print('Support: Help article tracked - $article');
  }

  /// Track user feedback
  void trackUserFeedback(String feedback, int rating) {
    if (!_isSupportActive) return;
    
    _supportData['userFeedback'] = 
        (_supportData['userFeedback'] as int) + 1;
    
    // Update satisfaction rating
    final currentRating = _supportData['satisfactionRating'] as int;
    final totalFeedback = _supportData['userFeedback'] as int;
    _supportData['satisfactionRating'] = 
        ((currentRating * (totalFeedback - 1)) + rating) ~/ totalFeedback;
    
    print('Support: Feedback tracked - Rating: $rating');
  }

  /// Get support data
  Map<String, dynamic> getSupportData() {
    return Map.from(_supportData);
  }

  /// Get support report
  String getSupportReport() {
    final data = getSupportData();
    
    return '''
Support Report:
- Support Requests: ${data['supportRequests']}
- FAQ Views: ${data['faqViews']}
- Help Articles: ${data['helpArticles']}
- User Feedback: ${data['userFeedback']}
- Satisfaction Rating: ${data['satisfactionRating']}/5
''';
  }

  /// Check if support is healthy
  bool isSupportHealthy() {
    final satisfactionRating = _supportData['satisfactionRating'] as int;
    final supportRequests = _supportData['supportRequests'] as int;
    
    return satisfactionRating >= 4 && supportRequests < 100;
  }

  /// Get FAQ data
  List<Map<String, String>> getFAQData() {
    return [
      {
        'question': 'How do I use Crafta?',
        'answer': 'Simply tap the microphone button and tell Crafta what creature you want to create!'
      },
      {
        'question': 'Is Crafta safe for children?',
        'answer': 'Yes! Crafta is designed with child safety in mind, with parental controls and safe AI responses.'
      },
      {
        'question': 'Can parents monitor their child\'s creations?',
        'answer': 'Yes! Parents can view creation history and manage exports in the Parent Settings.'
      },
      {
        'question': 'What age is Crafta suitable for?',
        'answer': 'Crafta is designed for children ages 4-10, with age-appropriate content and interactions.'
      },
      {
        'question': 'How do I export my creature?',
        'answer': 'After creating your creature, you can export it as a Minecraft mod file!'
      },
    ];
  }

  /// Get help articles
  List<Map<String, String>> getHelpArticles() {
    return [
      {
        'title': 'Getting Started with Crafta',
        'content': 'Learn how to create your first creature with Crafta!',
        'category': 'Getting Started'
      },
      {
        'title': 'Parent Safety Controls',
        'content': 'Understand how to use parental controls to keep your child safe.',
        'category': 'Safety'
      },
      {
        'title': 'Voice Interaction Guide',
        'content': 'Learn how to effectively communicate with Crafta using your voice.',
        'category': 'Voice'
      },
      {
        'title': 'Exporting Your Creations',
        'content': 'Step-by-step guide to exporting your creatures as Minecraft mods.',
        'category': 'Export'
      },
      {
        'title': 'Troubleshooting Common Issues',
        'content': 'Solutions to common problems and how to get help.',
        'category': 'Troubleshooting'
      },
    ];
  }

  /// Get user satisfaction metrics
  Map<String, dynamic> getUserSatisfactionMetrics() {
    final data = getSupportData();
    
    return {
      'averageRating': data['satisfactionRating'],
      'totalFeedback': data['userFeedback'],
      'supportRequests': data['supportRequests'],
      'faqViews': data['faqViews'],
      'helpArticleViews': data['helpArticles'],
    };
  }

  /// Generate support insights
  String generateSupportInsights() {
    final data = getSupportData();
    final satisfactionRating = data['satisfactionRating'] as int;
    final supportRequests = data['supportRequests'] as int;
    final faqViews = data['faqViews'] as int;
    
    String insights = 'Support Insights:\n';
    
    if (satisfactionRating >= 4) {
      insights += '✅ High user satisfaction (${satisfactionRating}/5)\n';
    } else {
      insights += '⚠️ User satisfaction needs improvement (${satisfactionRating}/5)\n';
    }
    
    if (supportRequests < 50) {
      insights += '✅ Low support request volume\n';
    } else {
      insights += '⚠️ High support request volume\n';
    }
    
    if (faqViews > supportRequests) {
      insights += '✅ FAQ is effective (more views than requests)\n';
    } else {
      insights += '⚠️ FAQ may need improvement\n';
    }
    
    return insights;
  }

  /// Track feature usage for support
  void trackFeatureUsageForSupport(String feature) {
    if (!_isSupportActive) return;
    
    print('Support: Feature usage tracked - $feature');
  }

  /// Track error for support
  void trackErrorForSupport(String error, String context) {
    if (!_isSupportActive) return;
    
    print('Support: Error tracked - $error in $context');
  }

  /// Get support contact information
  Map<String, String> getSupportContactInfo() {
    return {
      'email': 'support@crafta.app',
      'phone': '+1-800-CRAFTA',
      'website': 'https://crafta.app/support',
      'hours': 'Mon-Fri 9AM-6PM EST',
    };
  }

  /// Export support data
  Future<String> exportSupportData() async {
    if (!_isSupportActive) return '';
    
    final data = getSupportData();
    final report = getSupportReport();
    final insights = generateSupportInsights();
    
    // Simulate data export
    await Future.delayed(const Duration(milliseconds: 100));
    
    return '''
Support Data Export:
${report}

${insights}

Raw Data:
${data.toString()}
''';
  }

  /// Reset support data
  void resetSupportData() {
    _supportData = {
      'startTime': DateTime.now().millisecondsSinceEpoch,
      'supportRequests': 0,
      'faqViews': 0,
      'helpArticles': 0,
      'userFeedback': 0,
      'satisfactionRating': 0,
    };
    
    print('Support: Data reset');
  }
}

