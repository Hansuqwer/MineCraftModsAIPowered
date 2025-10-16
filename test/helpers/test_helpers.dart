/// Test helpers and mock data for Crafta tests

/// Common test creature descriptions
class TestData {
  static const validCreatureDescriptions = [
    'I want a rainbow cow with sparkles',
    'Make me a pink pig',
    'I want a blue chicken that flies',
    'A tiny golden sheep',
    'A huge purple dragon with fire',
  ];

  static const Map<String, Map<String, dynamic>> expectedAttributes = {
    'rainbow_cow': {
      'creatureType': 'cow',
      'color': 'rainbow',
      'effects': ['sparkles'],
      'size': 'normal',
    },
    'pink_pig': {
      'creatureType': 'pig',
      'color': 'pink',
      'effects': [],
      'size': 'normal',
    },
    'blue_chicken': {
      'creatureType': 'chicken',
      'color': 'blue',
      'effects': ['flies'],
      'size': 'normal',
    },
  };

  static const mockAIResponses = [
    'Wow! A rainbow cow sounds amazing! What size should it be?',
    'That\'s so cool! I love pink pigs! Should it have any special effects?',
    'A blue chicken that flies! How exciting! Let\'s create it together!',
  ];

  static const inappropriateInputs = [
    'I want a scary monster',
    'Make a weapon that kills',
    'Create something with blood',
    'A dragon that destroys everything',
  ];

  static const ageAppropriateInputs = {
    4: ['A pink cow', 'A blue pig', 'A tiny chicken'],
    6: ['A sparkly unicorn', 'A rainbow dragon', 'A golden horse'],
    10: ['A phoenix with fire', 'A massive dragon', 'A griffin that flies'],
  };
}

/// Mock HTTP responses for testing
class MockHTTPResponses {
  static const successResponse = '''
  {
    "choices": [
      {
        "message": {
          "content": "Wow! A rainbow cow sounds amazing!"
        }
      }
    ]
  }
  ''';

  static const rateLimitResponse = '';
  static const serverErrorResponse = '';
}
