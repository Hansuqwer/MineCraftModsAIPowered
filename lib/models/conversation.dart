class ConversationMessage {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;

  ConversationMessage({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
  });

  // Add getters for compatibility
  String get content => text;
  bool get isFromAI => !isFromUser;
}

class Conversation {
  final List<ConversationMessage> messages;
  final bool isComplete;
  final Map<String, dynamic>? creatureAttributes;

  Conversation({
    required this.messages,
    this.isComplete = false,
    this.creatureAttributes,
  });

  Conversation addMessage(String text, bool isFromUser) {
    final newMessages = List<ConversationMessage>.from(messages);
    newMessages.add(ConversationMessage(
      text: text,
      isFromUser: isFromUser,
      timestamp: DateTime.now(),
    ));
    
    return Conversation(
      messages: newMessages,
      isComplete: isComplete,
      creatureAttributes: creatureAttributes,
    );
  }

  Conversation markComplete(Map<String, dynamic> attributes) {
    return Conversation(
      messages: messages,
      isComplete: true,
      creatureAttributes: attributes,
    );
  }

  String get lastUserMessage {
    final userMessages = messages.where((m) => m.isFromUser).toList();
    return userMessages.isNotEmpty ? userMessages.last.text : '';
  }

  String get lastCraftaMessage {
    final craftaMessages = messages.where((m) => !m.isFromUser).toList();
    return craftaMessages.isNotEmpty ? craftaMessages.last.text : '';
  }
}
