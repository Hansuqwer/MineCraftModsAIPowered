import 'dart:convert';
import 'dart:math';

/// 🗣️ Conversational AI Service
/// Enables natural back-and-forth conversations about creating items
class ConversationalAIService {
  // Conversation memory
  final List<ConversationTurn> _conversationHistory = [];
  String _currentTopic = '';
  String _currentItem = '';
  Map<String, dynamic> _currentAttributes = {};
  
  // Items that can be created (Minecraft-compatible)
  final Set<String> _creatableItems = {
    // Creatures
    'dragon', 'cat', 'dog', 'unicorn', 'phoenix', 'dinosaur', 'monster', 'robot',
    'bird', 'fish', 'horse', 'cow', 'pig', 'sheep', 'chicken', 'wolf', 'bear',
    'elephant', 'lion', 'tiger', 'panda', 'rabbit', 'fox', 'deer', 'owl',
    
    // Weapons
    'sword', 'shield', 'bow', 'arrow', 'magic wand', 'staff', 'hammer', 'axe',
    'spear', 'dagger', 'crossbow', 'mace', 'flail', 'katana', 'rapier',
    
    // Vehicles
    'car', 'truck', 'boat', 'plane', 'rocket', 'spaceship', 'train', 'bike',
    'motorcycle', 'helicopter', 'submarine', 'sailboat', 'hot air balloon',
    
    // Buildings
    'house', 'castle', 'tower', 'bridge', 'tunnel', 'cave', 'tent', 'fort',
    'palace', 'mansion', 'cottage', 'treehouse', 'lighthouse', 'windmill',
    
    // Characters
    'princess', 'knight', 'wizard', 'pirate', 'superhero', 'ninja', 'robot',
    'prince', 'queen', 'king', 'warrior', 'mage', 'archer', 'thief',
    
    // Objects
    'crown', 'ring', 'gem', 'crystal', 'key', 'treasure', 'coin', 'star',
    'book', 'scroll', 'potion', 'chest', 'lamp', 'mirror', 'clock'
  };
  
  // Items that cannot be created (with explanations)
  final Map<String, String> _nonCreatableItems = {
    // Real-world items that don't fit Minecraft
    'iphone': 'I can\'t create real phones, but I can make a magical communication device!',
    'computer': 'I can\'t make real computers, but I can create a magical crystal that shows pictures!',
    'television': 'I can\'t make real TVs, but I can create a magical mirror that shows moving pictures!',
    'refrigerator': 'I can\'t make real fridges, but I can create a magical ice chest that keeps things cold!',
    'microwave': 'I can\'t make real microwaves, but I can create a magical heating crystal!',
    'airplane': 'I can make flying vehicles, but not real airplanes. How about a magical flying ship?',
    'helicopter': 'I can make flying vehicles, but not real helicopters. How about a magical flying machine?',
    
    // Abstract concepts
    'love': 'I can\'t create feelings, but I can make a magical heart that glows with warmth!',
    'happiness': 'I can\'t create emotions, but I can make a magical gem that sparkles with joy!',
    'friendship': 'I can\'t create relationships, but I can make a magical bond crystal!',
    'peace': 'I can\'t create peace itself, but I can make a magical dove that brings calm!',
    
    // Dangerous items
    'gun': 'I can\'t create real weapons that hurt people, but I can make a magical blaster that shoots light!',
    'bomb': 'I can\'t create dangerous explosives, but I can make a magical firework that explodes with colors!',
    'knife': 'I can\'t create sharp weapons, but I can make a magical blade that glows with light!',
    
    // Inappropriate content
    'monster': 'I can make friendly creatures, but not scary monsters. How about a cute dragon friend?',
    'ghost': 'I can\'t create scary things, but I can make a friendly spirit that glows with light!',
    'zombie': 'I can\'t create scary creatures, but I can make a friendly undead that loves flowers!',
    
    // Too complex items
    'universe': 'I can\'t create entire universes, but I can make a magical world with stars and planets!',
    'galaxy': 'I can\'t create galaxies, but I can make a magical star cluster!',
    'time machine': 'I can\'t create time machines, but I can make a magical clock that shows different times!',
    
    // Living things that are too complex
    'human': 'I can\'t create real people, but I can make a friendly character or companion!',
    'baby': 'I can\'t create real babies, but I can make a cute baby creature!',
    'mom': 'I can\'t create real people, but I can make a caring mother figure!',
    'dad': 'I can\'t create real people, but I can make a protective father figure!'
  };
  
  // AI personality types
  final Map<String, AIPersonality> _personalities = {
    'friendly_teacher': AIPersonality(
      name: 'Friendly Teacher',
      greeting: 'Hi there! I\'m your friendly teacher! What would you like to create today?',
      encouragement: 'That\'s a wonderful idea! Let\'s make it even better!',
      questions: [
        'What color should it be?',
        'How big do you want it?',
        'What special powers should it have?',
        'Where will it live?',
        'What does it like to do?'
      ],
      responses: [
        'Great choice!',
        'I love that idea!',
        'That sounds amazing!',
        'Perfect! Let\'s add that!',
        'Wonderful! What else?'
      ]
    ),
    'playful_friend': AIPersonality(
      name: 'Playful Friend',
      greeting: 'Hey buddy! Ready to create something awesome together?',
      encouragement: 'You\'re so creative! This is going to be amazing!',
      questions: [
        'What\'s your favorite color?',
        'Should it be super big or tiny?',
        'What cool abilities should it have?',
        'Does it have a special home?',
        'What makes it happy?'
      ],
      responses: [
        'Awesome!',
        'That\'s so cool!',
        'I love it!',
        'Yes! Let\'s do that!',
        'You\'re the best!'
      ]
    ),
    'wise_mentor': AIPersonality(
      name: 'Wise Mentor',
      greeting: 'Greetings, young creator! I\'m here to guide you in your creative journey.',
      encouragement: 'Your imagination knows no bounds! Let\'s explore it together.',
      questions: [
        'What colors speak to your heart?',
        'What size would serve it best?',
        'What gifts should it possess?',
        'What realm shall it call home?',
        'What brings it joy and purpose?'
      ],
      responses: [
        'Excellent choice, young one.',
        'Your wisdom shines through.',
        'A noble decision.',
        'You show great insight.',
        'Your creativity inspires me.'
      ]
    ),
    'creative_artist': AIPersonality(
      name: 'Creative Artist',
      greeting: 'Hello, fellow artist! Let\'s create something beautiful together!',
      encouragement: 'Your artistic vision is incredible! Let\'s bring it to life!',
      questions: [
        'What palette calls to you?',
        'What scale would showcase its beauty?',
        'What artistic flair should it have?',
        'What environment would complement it?',
        'What aesthetic brings it joy?'
      ],
      responses: [
        'Beautiful choice!',
        'That\'s pure artistry!',
        'I\'m inspired!',
        'Magnificent vision!',
        'You\'re a true artist!'
      ]
    ),
    'encouraging_coach': AIPersonality(
      name: 'Encouraging Coach',
      greeting: 'Hey there, champion! Ready to create something amazing?',
      encouragement: 'You\'ve got this! Your creativity is unstoppable!',
      questions: [
        'What color represents your strength?',
        'What size shows your power?',
        'What abilities make you proud?',
        'What home reflects your values?',
        'What brings you the most joy?'
      ],
      responses: [
        'That\'s the spirit!',
        'You\'re doing great!',
        'Keep it up!',
        'You\'re amazing!',
        'I\'m proud of you!'
      ]
    )
  };
  
  String _currentPersonality = 'friendly_teacher';
  
  /// Start a new conversation about creating an item
  Future<String> startConversation(String initialRequest) async {
    _conversationHistory.clear();
    _currentTopic = '';
    _currentItem = '';
    _currentAttributes = {};
    
    // Parse the initial request
    final parsed = _parseInitialRequest(initialRequest);
    _currentItem = parsed['item'] ?? 'creature';
    _currentTopic = 'creating_${_currentItem}';
    
    // Add to conversation history
    _conversationHistory.add(ConversationTurn(
      speaker: 'user',
      message: initialRequest,
      timestamp: DateTime.now(),
    ));
    
    // Check if the item can be created
    if (!_canCreateItem(_currentItem)) {
      final response = _getCannotCreateResponse(_currentItem);
      _conversationHistory.add(ConversationTurn(
        speaker: 'ai',
        message: response,
        timestamp: DateTime.now(),
      ));
      return response;
    }
    
    // Generate AI response
    final response = await _generateConversationalResponse(initialRequest);
    
    _conversationHistory.add(ConversationTurn(
      speaker: 'ai',
      message: response,
      timestamp: DateTime.now(),
    ));
    
    return response;
  }
  
  /// Continue the conversation with user input
  Future<String> continueConversation(String userInput) async {
    // Add user input to history
    _conversationHistory.add(ConversationTurn(
      speaker: 'user',
      message: userInput,
      timestamp: DateTime.now(),
    ));
    
    // Update attributes based on user input
    _updateAttributesFromInput(userInput);
    
    // Generate AI response
    final response = await _generateConversationalResponse(userInput);
    
    _conversationHistory.add(ConversationTurn(
      speaker: 'ai',
      message: response,
      timestamp: DateTime.now(),
    ));
    
    return response;
  }
  
  /// Generate a conversational response
  Future<String> _generateConversationalResponse(String userInput) async {
    final personality = _personalities[_currentPersonality]!;
    final context = _getConversationContext();
    
    // Determine response type based on conversation flow
    if (_isAskingForMoreDetails()) {
      return _generateDetailQuestion(personality);
    } else if (_isReadyToCreate()) {
      return _generateCreationConfirmation(personality);
    } else if (_isExpressingExcitement(userInput)) {
      return _generateEncouragement(personality);
    } else if (_isAskingForHelp(userInput)) {
      return _generateHelpResponse(personality);
    } else {
      return _generateFollowUpResponse(personality, userInput);
    }
  }
  
  /// Check if we need more details about the item
  bool _isAskingForMoreDetails() {
    final requiredDetails = ['color', 'size', 'abilities', 'home', 'personality'];
    final currentDetails = _currentAttributes.keys.toList();
    
    for (final detail in requiredDetails) {
      if (!currentDetails.contains(detail)) {
        return true;
      }
    }
    return false;
  }
  
  /// Check if we have enough details to create the item
  bool _isReadyToCreate() {
    return _currentAttributes.length >= 3; // At least 3 attributes
  }
  
  /// Check if user is expressing excitement
  bool _isExpressingExcitement(String input) {
    final excitementWords = ['yes', 'awesome', 'cool', 'amazing', 'love', 'great', 'wow', 'fantastic'];
    final lowerInput = input.toLowerCase();
    return excitementWords.any((word) => lowerInput.contains(word));
  }
  
  /// Check if user is asking for help
  bool _isAskingForHelp(String input) {
    final helpWords = ['help', 'how', 'what', 'can you', 'show me', 'tell me'];
    final lowerInput = input.toLowerCase();
    return helpWords.any((word) => lowerInput.contains(word));
  }
  
  /// Generate a question asking for more details
  String _generateDetailQuestion(AIPersonality personality) {
    final missingDetails = _getMissingDetails();
    if (missingDetails.isEmpty) return personality.encouragement;
    
    final detail = missingDetails.first;
    final question = _getQuestionForDetail(detail, personality);
    return question;
  }
  
  /// Generate creation confirmation
  String _generateCreationConfirmation(AIPersonality personality) {
    final itemDescription = _generateItemDescription();
    return '${personality.encouragement} I love your $itemDescription! Should we create it now?';
  }
  
  /// Generate encouragement response
  String _generateEncouragement(AIPersonality personality) {
    final responses = personality.responses;
    return responses[Random().nextInt(responses.length)];
  }
  
  /// Generate help response
  String _generateHelpResponse(AIPersonality personality) {
    return 'I\'m here to help you create amazing things! We can make creatures, weapons, vehicles, buildings, and so much more! What would you like to create?';
  }
  
  /// Generate follow-up response
  String _generateFollowUpResponse(AIPersonality personality, String userInput) {
    // Analyze user input for specific details
    final details = _extractDetailsFromInput(userInput);
    if (details.isNotEmpty) {
      final detail = details.keys.first; // Fixed: get first key from map
      final value = details[detail];
      return '${personality.responses[Random().nextInt(personality.responses.length)]} I\'ll make it $value! What else should we add?';
    }
    
    return personality.responses[Random().nextInt(personality.responses.length)];
  }
  
  /// Parse initial request to extract item type
  Map<String, dynamic> _parseInitialRequest(String request) {
    final lowerRequest = request.toLowerCase();
    final items = ['dragon', 'cat', 'dog', 'sword', 'car', 'house', 'castle', 'princess', 'knight'];
    
    for (final item in items) {
      if (lowerRequest.contains(item)) {
        return {'item': item};
      }
    }
    
    return {'item': 'creature'};
  }
  
  /// Update attributes based on user input
  void _updateAttributesFromInput(String input) {
    final lowerInput = input.toLowerCase();
    
    // Color detection
    final colors = ['red', 'blue', 'green', 'yellow', 'purple', 'pink', 'orange', 'black', 'white'];
    for (final color in colors) {
      if (lowerInput.contains(color)) {
        _currentAttributes['color'] = color;
        break;
      }
    }
    
    // Size detection
    if (lowerInput.contains('big') || lowerInput.contains('huge') || lowerInput.contains('large')) {
      _currentAttributes['size'] = 'big';
    } else if (lowerInput.contains('small') || lowerInput.contains('tiny') || lowerInput.contains('little')) {
      _currentAttributes['size'] = 'small';
    } else if (lowerInput.contains('medium')) {
      _currentAttributes['size'] = 'medium';
    }
    
    // Ability detection
    final abilities = ['flying', 'swimming', 'glowing', 'magic', 'fire', 'ice', 'super'];
    for (final ability in abilities) {
      if (lowerInput.contains(ability)) {
        _currentAttributes['abilities'] = (_currentAttributes['abilities'] ?? [])..add(ability);
      }
    }
    
    // Home detection
    final homes = ['castle', 'cave', 'forest', 'mountain', 'ocean', 'sky', 'underground'];
    for (final home in homes) {
      if (lowerInput.contains(home)) {
        _currentAttributes['home'] = home;
        break;
      }
    }
    
    // Personality detection
    final personalities = ['friendly', 'brave', 'shy', 'funny', 'wise', 'playful', 'serious'];
    for (final personality in personalities) {
      if (lowerInput.contains(personality)) {
        _currentAttributes['personality'] = personality;
        break;
      }
    }
  }
  
  /// Get missing details that still need to be collected
  List<String> _getMissingDetails() {
    final requiredDetails = ['color', 'size', 'abilities', 'home', 'personality'];
    final currentDetails = _currentAttributes.keys.toList();
    return requiredDetails.where((detail) => !currentDetails.contains(detail)).toList();
  }
  
  /// Get question for specific detail
  String _getQuestionForDetail(String detail, AIPersonality personality) {
    switch (detail) {
      case 'color':
        return personality.questions[0];
      case 'size':
        return personality.questions[1];
      case 'abilities':
        return personality.questions[2];
      case 'home':
        return personality.questions[3];
      case 'personality':
        return personality.questions[4];
      default:
        return personality.questions[Random().nextInt(personality.questions.length)];
    }
  }
  
  /// Generate item description from current attributes
  String _generateItemDescription() {
    final parts = <String>[];
    
    if (_currentAttributes.containsKey('color')) {
      parts.add(_currentAttributes['color']);
    }
    
    if (_currentAttributes.containsKey('size')) {
      parts.add(_currentAttributes['size']);
    }
    
    parts.add(_currentItem);
    
    if (_currentAttributes.containsKey('abilities')) {
      final abilities = _currentAttributes['abilities'] as List;
      if (abilities.isNotEmpty) {
        parts.add('with ${abilities.join(' and ')} abilities');
      }
    }
    
    return parts.join(' ');
  }
  
  /// Get conversation context
  String _getConversationContext() {
    return _conversationHistory.map((turn) => '${turn.speaker}: ${turn.message}').join('\n');
  }
  
  /// Extract details from user input
  Map<String, String> _extractDetailsFromInput(String input) {
    final details = <String, String>{};
    final lowerInput = input.toLowerCase();
    
    // Extract color
    final colors = ['red', 'blue', 'green', 'yellow', 'purple', 'pink', 'orange', 'black', 'white'];
    for (final color in colors) {
      if (lowerInput.contains(color)) {
        details['color'] = color;
        break;
      }
    }
    
    // Extract size
    if (lowerInput.contains('big')) details['size'] = 'big';
    if (lowerInput.contains('small')) details['size'] = 'small';
    
    return details;
  }
  
  /// Get current conversation history
  List<ConversationTurn> get conversationHistory => List.unmodifiable(_conversationHistory);
  
  /// Get current attributes
  Map<String, dynamic> get currentAttributes => Map.unmodifiable(_currentAttributes);
  
  /// Get current item
  String get currentItem => _currentItem;
  
  /// Set AI personality
  void setPersonality(String personality) {
    if (_personalities.containsKey(personality)) {
      _currentPersonality = personality;
    }
  }
  
  /// Get available personalities
  List<String> get availablePersonalities => _personalities.keys.toList();
  
  /// Get current personality
  String get currentPersonality => _currentPersonality;
  
  /// Clear conversation
  void clearConversation() {
    _conversationHistory.clear();
    _currentTopic = '';
    _currentItem = '';
    _currentAttributes = {};
  }
  
  /// Check if an item can be created
  bool _canCreateItem(String item) {
    final lowerItem = item.toLowerCase();
    
    // Check if it's in the creatable items set
    if (_creatableItems.contains(lowerItem)) {
      return true;
    }
    
    // Check if it's in the non-creatable items
    if (_nonCreatableItems.containsKey(lowerItem)) {
      return false;
    }
    
    // Check for partial matches in creatable items
    for (final creatableItem in _creatableItems) {
      if (lowerItem.contains(creatableItem) || creatableItem.contains(lowerItem)) {
        return true;
      }
    }
    
    // Check for partial matches in non-creatable items
    for (final nonCreatableItem in _nonCreatableItems.keys) {
      if (lowerItem.contains(nonCreatableItem) || nonCreatableItem.contains(lowerItem)) {
        return false;
      }
    }
    
    // Default to creatable for unknown items
    return true;
  }
  
  /// Get response when item cannot be created
  String _getCannotCreateResponse(String item) {
    final lowerItem = item.toLowerCase();
    
    // Check for exact match in non-creatable items
    if (_nonCreatableItems.containsKey(lowerItem)) {
      return _nonCreatableItems[lowerItem]!;
    }
    
    // Check for partial matches
    for (final nonCreatableItem in _nonCreatableItems.keys) {
      if (lowerItem.contains(nonCreatableItem) || nonCreatableItem.contains(lowerItem)) {
        return _nonCreatableItems[nonCreatableItem]!;
      }
    }
    
    // Generic response for unknown non-creatable items
    return 'I\'m not sure how to create a $item, but I can help you make something similar! What else would you like to create?';
  }
  
  /// Get list of creatable items
  List<String> get creatableItems => _creatableItems.toList();
  
  /// Get list of non-creatable items with explanations
  Map<String, String> get nonCreatableItems => Map.unmodifiable(_nonCreatableItems);
  
  /// Check if current item can be created
  bool get canCreateCurrentItem => _canCreateItem(_currentItem);
  
  /// Get suggestions for similar creatable items
  List<String> getSimilarCreatableItems(String item) {
    final lowerItem = item.toLowerCase();
    final suggestions = <String>[];
    
    // Find items that contain the requested item or are similar
    for (final creatableItem in _creatableItems) {
      if (creatableItem.contains(lowerItem) || lowerItem.contains(creatableItem)) {
        suggestions.add(creatableItem);
      }
    }
    
    // If no direct matches, find items in the same category
    if (suggestions.isEmpty) {
      final category = _getItemCategory(item);
      for (final creatableItem in _creatableItems) {
        if (_getItemCategory(creatableItem) == category) {
          suggestions.add(creatableItem);
        }
      }
    }
    
    return suggestions.take(5).toList(); // Return top 5 suggestions
  }
  
  /// Get category of an item
  String _getItemCategory(String item) {
    final lowerItem = item.toLowerCase();
    
    if (['dragon', 'cat', 'dog', 'bird', 'fish', 'horse', 'cow', 'pig', 'sheep', 'chicken', 'wolf', 'bear', 'elephant', 'lion', 'tiger', 'panda', 'rabbit', 'fox', 'deer', 'owl', 'unicorn', 'phoenix', 'dinosaur', 'monster', 'robot'].contains(lowerItem)) {
      return 'creature';
    } else if (['sword', 'shield', 'bow', 'arrow', 'magic wand', 'staff', 'hammer', 'axe', 'spear', 'dagger', 'crossbow', 'mace', 'flail', 'katana', 'rapier'].contains(lowerItem)) {
      return 'weapon';
    } else if (['car', 'truck', 'boat', 'plane', 'rocket', 'spaceship', 'train', 'bike', 'motorcycle', 'helicopter', 'submarine', 'sailboat', 'hot air balloon'].contains(lowerItem)) {
      return 'vehicle';
    } else if (['house', 'castle', 'tower', 'bridge', 'tunnel', 'cave', 'tent', 'fort', 'palace', 'mansion', 'cottage', 'treehouse', 'lighthouse', 'windmill'].contains(lowerItem)) {
      return 'building';
    } else if (['princess', 'knight', 'wizard', 'pirate', 'superhero', 'ninja', 'robot', 'prince', 'queen', 'king', 'warrior', 'mage', 'archer', 'thief'].contains(lowerItem)) {
      return 'character';
    } else {
      return 'object';
    }
  }
}

/// Conversation turn data class
class ConversationTurn {
  final String speaker; // 'user' or 'ai'
  final String message;
  final DateTime timestamp;
  
  ConversationTurn({
    required this.speaker,
    required this.message,
    required this.timestamp,
  });
}

/// AI Personality data class
class AIPersonality {
  final String name;
  final String greeting;
  final String encouragement;
  final List<String> questions;
  final List<String> responses;
  
  AIPersonality({
    required this.name,
    required this.greeting,
    required this.encouragement,
    required this.questions,
    required this.responses,
  });
}
