import 'dart:convert';
import 'dart:math';

/// 🗣️ Simple Conversational AI Service
/// Basic conversational AI without complex dependencies
class SimpleConversationalAI {
  // Conversation memory
  final List<Map<String, String>> _conversationHistory = [];
  String _currentItem = '';
  Map<String, dynamic> _currentAttributes = {};
  
  // Items that can be created
  final Set<String> _creatableItems = {
    'dragon', 'cat', 'dog', 'sword', 'car', 'house', 'princess', 'knight',
    'unicorn', 'phoenix', 'robot', 'bird', 'fish', 'horse', 'cow', 'pig',
    'sheep', 'chicken', 'wolf', 'bear', 'elephant', 'lion', 'tiger', 'panda',
    'rabbit', 'fox', 'deer', 'owl', 'shield', 'bow', 'arrow', 'magic wand',
    'staff', 'hammer', 'axe', 'spear', 'dagger', 'crossbow', 'mace', 'flail',
    'truck', 'boat', 'plane', 'rocket', 'spaceship', 'train', 'bike',
    'motorcycle', 'helicopter', 'submarine', 'sailboat', 'hot air balloon',
    'castle', 'tower', 'bridge', 'tunnel', 'cave', 'tent', 'fort', 'palace',
    'mansion', 'cottage', 'treehouse', 'lighthouse', 'windmill', 'wizard',
    'pirate', 'superhero', 'ninja', 'prince', 'queen', 'king', 'warrior',
    'mage', 'archer', 'thief', 'crown', 'ring', 'gem', 'crystal', 'key',
    'treasure', 'coin', 'star', 'book', 'scroll', 'potion', 'chest', 'lamp',
    'mirror', 'clock'
  };
  
  // Items that cannot be created
  final Map<String, String> _nonCreatableItems = {
    'iphone': 'I can\'t create real phones, but I can make a magical communication device!',
    'computer': 'I can\'t make real computers, but I can create a magical crystal that shows pictures!',
    'television': 'I can\'t make real TVs, but I can create a magical mirror that shows moving pictures!',
    'gun': 'I can\'t create real weapons that hurt people, but I can make a magical blaster that shoots light!',
    'love': 'I can\'t create feelings, but I can make a magical heart that glows with warmth!',
    'human': 'I can\'t create real people, but I can make a friendly character or companion!',
  };
  
  /// Start a conversation
  Future<String> startConversation(String request) async {
    _conversationHistory.clear();
    _currentItem = '';
    _currentAttributes = {};
    
    // Parse the request
    final lowerRequest = request.toLowerCase();
    String item = 'creature';
    
    for (final creatableItem in _creatableItems) {
      if (lowerRequest.contains(creatableItem)) {
        item = creatableItem;
        break;
      }
    }
    
    _currentItem = item;
    
    // Add to history
    _conversationHistory.add({'role': 'user', 'message': request});
    
    // Check if item can be created
    if (!_canCreateItem(item)) {
      final response = _getCannotCreateResponse(item);
      _conversationHistory.add({'role': 'ai', 'message': response});
      return response;
    }
    
    // Generate response
    final response = _generateResponse(request, item);
    _conversationHistory.add({'role': 'ai', 'message': response});
    return response;
  }
  
  /// Continue conversation
  Future<String> continueConversation(String userInput) async {
    _conversationHistory.add({'role': 'user', 'message': userInput});
    
    // Parse attributes from user input
    _parseAttributes(userInput);
    
    // Generate response
    final response = _generateResponse(userInput, _currentItem);
    _conversationHistory.add({'role': 'ai', 'message': response});
    return response;
  }
  
  /// Check if item can be created
  bool _canCreateItem(String item) {
    final lowerItem = item.toLowerCase();
    
    if (_creatableItems.contains(lowerItem)) {
      return true;
    }
    
    if (_nonCreatableItems.containsKey(lowerItem)) {
      return false;
    }
    
    // Check for partial matches
    for (final creatableItem in _creatableItems) {
      if (lowerItem.contains(creatableItem) || creatableItem.contains(lowerItem)) {
        return true;
      }
    }
    
    for (final nonCreatableItem in _nonCreatableItems.keys) {
      if (lowerItem.contains(nonCreatableItem) || nonCreatableItem.contains(lowerItem)) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Get response when item cannot be created
  String _getCannotCreateResponse(String item) {
    final lowerItem = item.toLowerCase();
    
    if (_nonCreatableItems.containsKey(lowerItem)) {
      return _nonCreatableItems[lowerItem]!;
    }
    
    for (final nonCreatableItem in _nonCreatableItems.keys) {
      if (lowerItem.contains(nonCreatableItem) || nonCreatableItem.contains(lowerItem)) {
        return _nonCreatableItems[nonCreatableItem]!;
      }
    }
    
    return 'I\'m not sure how to create a $item, but I can help you make something similar! What else would you like to create?';
  }
  
  /// Generate AI response
  String _generateResponse(String userInput, String item) {
    final lowerInput = userInput.toLowerCase();
    
    // Check for completion
    if (_currentAttributes.length >= 3) {
      return 'Your $item is ready! It has ${_currentAttributes.length} special features. Should we create it now?';
    }
    
    // Check for attributes
    if (lowerInput.contains('color') || lowerInput.contains('red') || lowerInput.contains('blue') || 
        lowerInput.contains('green') || lowerInput.contains('yellow') || lowerInput.contains('purple')) {
      return 'Great choice of color! What size should it be?';
    }
    
    if (lowerInput.contains('size') || lowerInput.contains('big') || lowerInput.contains('small') || 
        lowerInput.contains('huge') || lowerInput.contains('tiny')) {
      return 'Perfect size! What special abilities should it have?';
    }
    
    if (lowerInput.contains('ability') || lowerInput.contains('power') || lowerInput.contains('fly') || 
        lowerInput.contains('swim') || lowerInput.contains('run')) {
      return 'Awesome abilities! Where does it live?';
    }
    
    if (lowerInput.contains('live') || lowerInput.contains('home') || lowerInput.contains('forest') || 
        lowerInput.contains('castle') || lowerInput.contains('cave')) {
      return 'Wonderful home! What personality should it have?';
    }
    
    if (lowerInput.contains('personality') || lowerInput.contains('friendly') || lowerInput.contains('brave') || 
        lowerInput.contains('shy') || lowerInput.contains('funny')) {
      return 'Great personality! Your $item is almost ready! What else would you like to add?';
    }
    
    // Default response
    return 'That sounds interesting! Tell me more about your $item. What color should it be?';
  }
  
  /// Parse attributes from user input
  void _parseAttributes(String userInput) {
    final lowerInput = userInput.toLowerCase();
    
    if (lowerInput.contains('red')) _currentAttributes['color'] = 'red';
    if (lowerInput.contains('blue')) _currentAttributes['color'] = 'blue';
    if (lowerInput.contains('green')) _currentAttributes['color'] = 'green';
    if (lowerInput.contains('yellow')) _currentAttributes['color'] = 'yellow';
    if (lowerInput.contains('purple')) _currentAttributes['color'] = 'purple';
    
    if (lowerInput.contains('big') || lowerInput.contains('huge')) _currentAttributes['size'] = 'big';
    if (lowerInput.contains('small') || lowerInput.contains('tiny')) _currentAttributes['size'] = 'small';
    if (lowerInput.contains('medium')) _currentAttributes['size'] = 'medium';
    
    if (lowerInput.contains('fly')) _currentAttributes['ability'] = 'fly';
    if (lowerInput.contains('swim')) _currentAttributes['ability'] = 'swim';
    if (lowerInput.contains('run')) _currentAttributes['ability'] = 'run';
    if (lowerInput.contains('jump')) _currentAttributes['ability'] = 'jump';
    
    if (lowerInput.contains('forest')) _currentAttributes['home'] = 'forest';
    if (lowerInput.contains('castle')) _currentAttributes['home'] = 'castle';
    if (lowerInput.contains('cave')) _currentAttributes['home'] = 'cave';
    if (lowerInput.contains('mountain')) _currentAttributes['home'] = 'mountain';
    
    if (lowerInput.contains('friendly')) _currentAttributes['personality'] = 'friendly';
    if (lowerInput.contains('brave')) _currentAttributes['personality'] = 'brave';
    if (lowerInput.contains('shy')) _currentAttributes['personality'] = 'shy';
    if (lowerInput.contains('funny')) _currentAttributes['personality'] = 'funny';
  }
  
  /// Get conversation history
  List<Map<String, String>> get conversationHistory => List.unmodifiable(_conversationHistory);
  
  /// Get current item
  String get currentItem => _currentItem;
  
  /// Get current attributes
  Map<String, dynamic> get currentAttributes => Map.unmodifiable(_currentAttributes);
  
  /// Check if current item can be created
  bool get canCreateCurrentItem => _canCreateItem(_currentItem);
  
  /// Clear conversation
  void clearConversation() {
    _conversationHistory.clear();
    _currentItem = '';
    _currentAttributes = {};
  }
}




