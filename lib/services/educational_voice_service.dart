import 'dart:math';
import 'enhanced_voice_ai_service.dart';

/// Educational content structure
class EducationalContent {
  final List<String> facts;
  final List<String> questions;
  final List<String> stories;

  EducationalContent({
    required this.facts,
    required this.questions,
    required this.stories,
  });
}

/// Story template structure
class StoryTemplate {
  final String title;
  final String opening;
  final List<String> choices;
  final String ending;

  StoryTemplate({
    required this.title,
    required this.opening,
    required this.choices,
    required this.ending,
  });
}

/// Interactive story class
class InteractiveStory {
  final StoryTemplate template;
  int currentStep;
  final List<String> userChoices;

  InteractiveStory({
    required this.template,
    required this.currentStep,
    required this.userChoices,
  });

  bool get isComplete => currentStep >= template.choices.length;
}

/// Personalized learning class
class PersonalizedLearning {
  final String childName;
  final List<String> interests;
  String currentTopic;
  LearningLevel learningLevel;
  final List<String> achievements;

  PersonalizedLearning({
    required this.childName,
    required this.interests,
    required this.currentTopic,
    required this.learningLevel,
    required this.achievements,
  });
}

/// Learning level enum
enum LearningLevel {
  beginner,
  intermediate,
  advanced,
}

/// Service for providing educational content and interactive storytelling
class EducationalVoiceService {
  static final EducationalVoiceService _instance = EducationalVoiceService._internal();
  factory EducationalVoiceService() => _instance;
  EducationalVoiceService._internal();

  final Random _random = Random();

  // Educational content database organized by topic
  final Map<String, EducationalContent> _educationalContent = {
    'animals': EducationalContent(
      facts: [
        'Animals are living creatures that can move, eat, and grow!',
        'Some animals live on land, some in water, and some can fly!',
        'Animals need food, water, and a safe place to live.',
        'Many animals are very smart and can learn new things!',
        'Animals help keep our world balanced and beautiful.'
      ],
      questions: [
        'What\'s your favorite animal and why?',
        'If you could be any animal, which would you choose?',
        'What do you think animals dream about?',
        'How do you think animals talk to each other?',
        'What superpower would you give to your favorite animal?'
      ],
      stories: [
        'Once upon a time, there was a little animal who discovered they had a special power...',
        'In a magical forest, all the animals worked together to solve a big problem...',
        'A brave little creature went on an adventure to find their true home...',
        'There was once an animal who was different from all the others, but that made them special...',
        'In a land far away, animals and humans became the best of friends...'
      ]
    ),
    'colors': EducationalContent(
      facts: [
        'Colors are made by light bouncing off objects!',
        'Red, blue, and yellow are called primary colors.',
        'When you mix colors together, you can make new colors!',
        'Colors can make us feel different emotions.',
        'Rainbows show us all the beautiful colors of light!'
      ],
      questions: [
        'What\'s your favorite color and why?',
        'If you could invent a new color, what would it be?',
        'What color makes you feel happy?',
        'How do you think colors got their names?',
        'What would the world look like without colors?'
      ],
      stories: [
        'In a world where colors had feelings, each color had its own personality...',
        'A little artist discovered that mixing colors could create magic...',
        'There was once a town where everything was gray until a child brought colors...',
        'A rainbow lost its colors and needed help to get them back...',
        'In a magical paint box, the colors came to life and had adventures...'
      ]
    ),
    'creativity': EducationalContent(
      facts: [
        'Creativity is using your imagination to make something new!',
        'Everyone is creative in their own special way.',
        'There are no wrong answers when you\'re being creative.',
        'Creativity helps us solve problems and express ourselves.',
        'The best ideas often come from trying new things!'
      ],
      questions: [
        'What\'s the most creative thing you\'ve ever made?',
        'If you could create anything in the world, what would it be?',
        'What inspires you to be creative?',
        'How do you come up with new ideas?',
        'What would you create to make the world more beautiful?'
      ],
      stories: [
        'A young inventor discovered that the best creations come from the heart...',
        'In a world where creativity was magic, one child learned to paint with dreams...',
        'There was once a town where everyone forgot how to be creative until...',
        'A magical art studio where everything you drew came to life...',
        'A little dreamer learned that their imagination was the most powerful tool...'
      ]
    ),
    'friendship': EducationalContent(
      facts: [
        'Friends are people who care about you and make you happy!',
        'Good friends listen to you and help you when you need it.',
        'You can be friends with people who are different from you.',
        'Friendship means sharing, caring, and being kind.',
        'The best friendships are built on trust and understanding.'
      ],
      questions: [
        'What makes someone a good friend?',
        'How do you show your friends that you care about them?',
        'What\'s the nicest thing a friend has ever done for you?',
        'How do you make new friends?',
        'What would you do if your friend was feeling sad?'
      ],
      stories: [
        'Two unlikely friends discovered that differences make friendship stronger...',
        'A lonely creature found friendship in the most unexpected place...',
        'A group of friends worked together to solve a big problem...',
        'There was once a friendship so strong it could move mountains...',
        'A little hero learned that helping friends is the greatest adventure...'
      ]
    ),
    'nature': EducationalContent(
      facts: [
        'Nature is all the living things around us like plants and animals!',
        'Trees give us oxygen to breathe and help clean the air.',
        'Bees help flowers grow by carrying pollen from flower to flower.',
        'Every living thing in nature has an important job to do.',
        'We should take care of nature so it can take care of us.'
      ],
      questions: [
        'What\'s your favorite thing about nature?',
        'If you could be any part of nature, what would you be?',
        'How do you think we can help protect nature?',
        'What\'s the most amazing thing you\'ve seen in nature?',
        'If you could talk to animals, what would you ask them?'
      ],
      stories: [
        'A little seed grew into the most magical tree in the forest...',
        'In a garden where everything could talk, the plants shared their secrets...',
        'A brave little animal protected their home from harm...',
        'There was once a forest where the trees could dance...',
        'A child discovered that nature was the greatest teacher of all...'
      ]
    )
  };

  // Interactive story templates
  final List<StoryTemplate> _storyTemplates = [
    StoryTemplate(
      title: 'The Magic Creature',
      opening: 'Once upon a time, in a land far away, there lived a special creature...',
      choices: [
        'What did this creature look like?',
        'What special power did it have?',
        'What was its name?',
        'Where did it live?'
      ],
      ending: 'And that\'s how the magic creature became the most beloved friend in all the land!'
    ),
    StoryTemplate(
      title: 'The Colorful Adventure',
      opening: 'In a world where colors had feelings, a young artist discovered something amazing...',
      choices: [
        'What did the artist discover?',
        'What happened when they mixed colors?',
        'Who did they meet on their adventure?',
        'What problem did they solve?'
      ],
      ending: 'And from that day forward, the world was filled with even more beautiful colors!'
    ),
    StoryTemplate(
      title: 'The Brave Little Hero',
      opening: 'A small but brave creature set out on a journey to help their friends...',
      choices: [
        'What challenge did they face?',
        'How did they solve the problem?',
        'Who did they help along the way?',
        'What did they learn about themselves?'
      ],
      ending: 'And they learned that being brave means caring about others!'
    )
  ];


  /// Get educational fact based on context
  String getEducationalFact(String topic, {String? creatureType}) {
    final content = _educationalContent[topic.toLowerCase()];
    if (content == null || content.facts.isEmpty) {
      return 'Learning new things is so much fun!';
    }

    // If creature type is specified, try to find a relevant fact
    if (creatureType != null) {
      final creatureContent = _educationalContent['animals'];
      if (creatureContent != null) {
        return creatureContent.facts[_random.nextInt(creatureContent.facts.length)];
      }
    }

    return content.facts[_random.nextInt(content.facts.length)];
  }

  /// Get educational question based on context
  String getEducationalQuestion(String topic, {String? creatureType}) {
    final content = _educationalContent[topic.toLowerCase()];
    if (content == null || content.questions.isEmpty) {
      return 'What would you like to learn about today?';
    }

    return content.questions[_random.nextInt(content.questions.length)];
  }

  /// Get educational story based on context
  String getEducationalStory(String topic, {String? creatureType}) {
    final content = _educationalContent[topic.toLowerCase()];
    if (content == null || content.stories.isEmpty) {
      return 'Let me tell you a story about creativity and imagination...';
    }

    return content.stories[_random.nextInt(content.stories.length)];
  }

  /// Start an interactive story session
  InteractiveStory startInteractiveStory() {
    final template = _storyTemplates[_random.nextInt(_storyTemplates.length)];
    return InteractiveStory(
      template: template,
      currentStep: 0,
      userChoices: [],
    );
  }

  /// Continue interactive story with user choice
  String continueInteractiveStory(InteractiveStory story, String userChoice) {
    story.userChoices.add(userChoice);
    story.currentStep++;

    if (story.currentStep < story.template.choices.length) {
      // Ask next question
      return story.template.choices[story.currentStep];
    } else {
      // End the story
      return '${story.template.ending} Thank you for helping me tell this story!';
    }
  }

  /// Get random educational topic
  String getRandomEducationalTopic() {
    final topics = _educationalContent.keys.toList();
    return topics[_random.nextInt(topics.length)];
  }

  /// Get all available educational topics
  List<String> getAllEducationalTopics() {
    return _educationalContent.keys.toList();
  }

  /// Get educational content for a specific topic
  EducationalContent? getEducationalContent(String topic) {
    return _educationalContent[topic.toLowerCase()];
  }

  /// Create a personalized learning experience
  PersonalizedLearning createPersonalizedLearning(String childName, List<String> interests) {
    return PersonalizedLearning(
      childName: childName,
      interests: interests,
      currentTopic: interests.isNotEmpty ? interests.first : 'creativity',
      learningLevel: LearningLevel.beginner,
      achievements: [],
    );
  }

  /// Get next learning suggestion
  String getNextLearningSuggestion(PersonalizedLearning learning) {
    // Rotate through interests
    final currentIndex = learning.interests.indexOf(learning.currentTopic);
    final nextIndex = (currentIndex + 1) % learning.interests.length;
    learning.currentTopic = learning.interests[nextIndex];

    return 'Let\'s learn about ${learning.currentTopic}! ${getEducationalQuestion(learning.currentTopic)}';
  }

  /// Award learning achievement
  void awardAchievement(PersonalizedLearning learning, String achievement) {
    if (!learning.achievements.contains(achievement)) {
      learning.achievements.add(achievement);
    }
  }

  /// Get learning progress
  Map<String, dynamic> getLearningProgress(PersonalizedLearning learning) {
    return {
      'childName': learning.childName,
      'currentTopic': learning.currentTopic,
      'learningLevel': learning.learningLevel.toString(),
      'achievements': learning.achievements,
      'totalAchievements': learning.achievements.length,
      'interests': learning.interests,
    };
  }
}
