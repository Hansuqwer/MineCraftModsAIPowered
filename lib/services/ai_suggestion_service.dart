import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/enhanced_creature_attributes.dart';
import 'speech_service.dart';
import 'tts_service.dart';
import 'language_service.dart';

/// AI Suggestion Service for providing improvements and funny changes
/// Handles voice interaction for yes/no responses from kids
class AISuggestionService {
  final SpeechService _speechService = SpeechService();
  final TTSService _ttsService = TTSService();
  final Random _random = Random();

  /// Generate AI suggestion for a created item
  Future<String> generateSuggestion(EnhancedCreatureAttributes attributes) async {
    final currentLanguage = await LanguageService.getCurrentLanguage();
    final isSwedish = currentLanguage.languageCode == 'sv';
    
    // Generate contextual suggestions based on the created item
    final suggestions = _getContextualSuggestions(attributes, isSwedish);
    final selectedSuggestion = suggestions[_random.nextInt(suggestions.length)];
    
    return selectedSuggestion;
  }

  /// Get contextual suggestions based on creature attributes
  List<String> _getContextualSuggestions(EnhancedCreatureAttributes attributes, bool isSwedish) {
    if (isSwedish) {
      return _getSwedishSuggestions(attributes);
    } else {
      return _getEnglishSuggestions(attributes);
    }
  }

  /// English suggestions
  List<String> _getEnglishSuggestions(EnhancedCreatureAttributes attributes) {
    final baseType = attributes.baseType.toLowerCase();
    final personality = attributes.personality;
    final effects = attributes.effects;
    
    List<String> suggestions = [];
    
    // Base type specific suggestions
    if (baseType.contains('sword') || baseType.contains('weapon')) {
      suggestions.addAll([
        "What if we made it glow with magic sparkles?",
        "Should we add fire breathing to make it more powerful?",
        "How about making it fly like a magic sword?",
        "What if we gave it a funny name like 'Swordy McSwordface'?",
      ]);
    } else if (baseType.contains('dragon')) {
      suggestions.addAll([
        "What if we made it tiny and super cute?",
        "Should we give it rainbow wings that sparkle?",
        "How about making it friendly and cuddly?",
        "What if it could turn into a tiny pet?",
      ]);
    } else if (baseType.contains('furniture') || baseType.contains('chair')) {
      suggestions.addAll([
        "What if we made it super bouncy and fun?",
        "Should we add wheels so it can move around?",
        "How about making it glow in the dark?",
        "What if it could talk and tell jokes?",
      ]);
    } else if (baseType.contains('armor')) {
      suggestions.addAll([
        "What if we made it invisible so you can hide?",
        "Should we add wings so you can fly?",
        "How about making it change colors like a rainbow?",
        "What if it made you super strong?",
      ]);
    } else {
      suggestions.addAll([
        "What if we made it super colorful and bright?",
        "Should we add magic powers to make it special?",
        "How about making it tiny and adorable?",
        "What if we gave it a funny personality?",
      ]);
    }
    
    // Personality-based suggestions
    switch (personality) {
      case PersonalityType.friendly:
        suggestions.add("What if we made it even more friendly and helpful?");
        break;
      case PersonalityType.playful:
        suggestions.add("Should we make it super bouncy and playful?");
        break;
      case PersonalityType.brave:
        suggestions.add("What if we gave it super powers to be even braver?");
        break;
      case PersonalityType.curious:
        suggestions.add("How about making it able to explore everywhere?");
        break;
      case PersonalityType.shy:
        suggestions.add("What if we made it super cute and cuddly?");
        break;
    }
    
    // Effect-based suggestions
    if (effects.contains(GlowEffect.none)) {
      suggestions.add("Should we add some magical sparkles and glow?");
    }
    if (!effects.contains(GlowEffect.wings)) {
      suggestions.add("What if we gave it wings so it can fly?");
    }
    
    return suggestions;
  }

  /// Swedish suggestions
  List<String> _getSwedishSuggestions(EnhancedCreatureAttributes attributes) {
    final baseType = attributes.baseType.toLowerCase();
    final personality = attributes.personality;
    final effects = attributes.effects;
    
    List<String> suggestions = [];
    
    // Base type specific suggestions in Swedish
    if (baseType.contains('sword') || baseType.contains('weapon')) {
      suggestions.addAll([
        "Vad sägs om att göra den glödande med magiska gnistor?",
        "Ska vi ge den eldandning för att göra den mer kraftfull?",
        "Vad sägs om att låta den flyga som ett magiskt svärd?",
        "Vad sägs om att ge den ett roligt namn som 'Svärd McSvärd'?",
      ]);
    } else if (baseType.contains('dragon')) {
      suggestions.addAll([
        "Vad sägs om att göra den liten och super söt?",
        "Ska vi ge den regnbågsvingar som glittrar?",
        "Vad sägs om att göra den vänlig och mysig?",
        "Vad sägs om att den kunde bli till ett litet husdjur?",
      ]);
    } else if (baseType.contains('furniture') || baseType.contains('chair')) {
      suggestions.addAll([
        "Vad sägs om att göra den super studsande och rolig?",
        "Ska vi lägga till hjul så den kan röra sig?",
        "Vad sägs om att låta den lysa i mörkret?",
        "Vad sägs om att den kunde prata och berätta skämt?",
      ]);
    } else if (baseType.contains('armor')) {
      suggestions.addAll([
        "Vad sägs om att göra den osynlig så du kan gömma dig?",
        "Ska vi lägga till vingar så du kan flyga?",
        "Vad sägs om att låta den byta färg som en regnbåge?",
        "Vad sägs om att den gjorde dig super stark?",
      ]);
    } else {
      suggestions.addAll([
        "Vad sägs om att göra den super färgglad och ljus?",
        "Ska vi lägga till magiska krafter för att göra den speciell?",
        "Vad sägs om att göra den liten och bedårande?",
        "Vad sägs om att ge den en rolig personlighet?",
      ]);
    }
    
    return suggestions;
  }

  /// Ask for voice response (yes/no) from the user
  Future<bool> askForVoiceResponse(String suggestion) async {
    try {
      // Speak the suggestion
      await _ttsService.speak(suggestion);
      
      // Wait a moment for the user to process
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Ask for yes/no response
      final currentLanguage = await LanguageService.getCurrentLanguage();
      final isSwedish = currentLanguage.languageCode == 'sv';
      
      final question = isSwedish 
        ? "Vill du att jag gör denna förändring? Säg ja eller nej."
        : "Do you want me to make this change? Say yes or no.";
      
      await _ttsService.speak(question);
      
      // Listen for response
      final response = await _speechService.listen();
      
      if (response != null) {
        final responseText = response.toLowerCase().trim();
        
        // Check for yes/no in both languages
        if (responseText.contains('yes') || responseText.contains('ja') || 
            responseText.contains('yeah') || responseText.contains('ok') ||
            responseText.contains('sure') || responseText.contains('absolut')) {
          return true;
        } else if (responseText.contains('no') || responseText.contains('nej') ||
                   responseText.contains('nope') || responseText.contains('inte')) {
          return false;
        }
      }
      
      // If unclear, ask again
      final clarification = isSwedish
        ? "Jag hörde inte tydligt. Kan du säga ja eller nej?"
        : "I didn't hear clearly. Can you say yes or no?";
      
      await _ttsService.speak(clarification);
      
      // Try one more time
      final secondResponse = await _speechService.listen();
      if (secondResponse != null) {
        final responseText = secondResponse.toLowerCase().trim();
        return responseText.contains('yes') || responseText.contains('ja') ||
               responseText.contains('yeah') || responseText.contains('ok') ||
               responseText.contains('sure') || responseText.contains('absolut');
      }
      
      return false; // Default to no if unclear
      
    } catch (e) {
      print('Error in voice response: $e');
      return false;
    }
  }

  /// Apply suggestion to creature attributes
  EnhancedCreatureAttributes applySuggestion(
    EnhancedCreatureAttributes originalAttributes, 
    String suggestion
  ) {
    var updatedAttributes = originalAttributes.copy();
    
    // Parse suggestion and apply changes
    final suggestionLower = suggestion.toLowerCase();
    
    // Add effects based on suggestion
    GlowEffect newGlowEffect = updatedAttributes.glowEffect;
    
    if (suggestionLower.contains('glow') || suggestionLower.contains('sparkle') || 
        suggestionLower.contains('magic') || suggestionLower.contains('glödande')) {
      newGlowEffect = GlowEffect.magical;
    }
    
    if (suggestionLower.contains('wings') || suggestionLower.contains('fly') || 
        suggestionLower.contains('vingar') || suggestionLower.contains('flyga')) {
      newGlowEffect = GlowEffect.wings;
    }
    
    if (suggestionLower.contains('fire') || suggestionLower.contains('flame') || 
        suggestionLower.contains('eld') || suggestionLower.contains('flamma')) {
      newGlowEffect = GlowEffect.flames;
    }
    
    if (newGlowEffect != updatedAttributes.glowEffect) {
      updatedAttributes = updatedAttributes.copy(glowEffect: newGlowEffect);
    }
    
    if (suggestionLower.contains('tiny') || suggestionLower.contains('small') || 
        suggestionLower.contains('liten') || suggestionLower.contains('litet')) {
      updatedAttributes = updatedAttributes.copy(size: CreatureSize.tiny);
    }
    
    if (suggestionLower.contains('rainbow') || suggestionLower.contains('colorful') || 
        suggestionLower.contains('regnbåge') || suggestionLower.contains('färgglad')) {
      updatedAttributes = updatedAttributes.copy(primaryColor: Colors.purple);
    }
    
    // Update description
    final newDescription = _generateUpdatedDescription(updatedAttributes);
    updatedAttributes = updatedAttributes.copy(description: newDescription);
    
    return updatedAttributes;
  }

  /// Generate updated description after applying suggestion
  String _generateUpdatedDescription(EnhancedCreatureAttributes attributes) {
    final effects = attributes.effects.map((e) => e.toString().split('.').last).join(', ');
    final size = attributes.size.toString().split('.').last;
    final color = attributes.primaryColor.toString().split('.').last;
    
    return "A $size $color ${attributes.baseType} with $effects effects. ${attributes.personality.toString().split('.').last} personality.";
  }

  /// Get encouraging response for when user says no
  Future<void> giveEncouragingResponse() async {
    final currentLanguage = await LanguageService.getCurrentLanguage();
    final isSwedish = currentLanguage.languageCode == 'sv';
    
    final responses = isSwedish ? [
      "Det är okej! Vi kan prova något annat roligt istället!",
      "Inga problem! Låt oss skapa något annat fantastiskt!",
      "Bra val! Vad sägs om att prova något helt annat?",
      "Perfekt! Låt oss hitta något ännu bättre!",
    ] : [
      "That's okay! We can try something else fun instead!",
      "No problem! Let's create something else amazing!",
      "Good choice! How about we try something completely different?",
      "Perfect! Let's find something even better!",
    ];
    
    final response = responses[_random.nextInt(responses.length)];
    await _ttsService.speak(response);
  }

  /// Get excited response for when user says yes
  Future<void> giveExcitedResponse() async {
    final currentLanguage = await LanguageService.getCurrentLanguage();
    final isSwedish = currentLanguage.languageCode == 'sv';
    
    final responses = isSwedish ? [
      "Fantastiskt! Låt mig göra denna förändring nu!",
      "Perfekt val! Det kommer att bli så coolt!",
      "Ja! Det kommer att bli så fantastiskt!",
      "Underbart! Låt mig uppdatera din skapelse!",
    ] : [
      "Fantastic! Let me make this change right now!",
      "Perfect choice! This is going to be so cool!",
      "Yes! This is going to be so amazing!",
      "Wonderful! Let me update your creation!",
    ];
    
    final response = responses[_random.nextInt(responses.length)];
    await _ttsService.speak(response);
  }
}
