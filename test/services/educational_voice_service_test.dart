import 'package:flutter_test/flutter_test.dart';

import '../../lib/services/educational_voice_service.dart';

void main() {
  group('EducationalVoiceService', () {
    late EducationalVoiceService service;

    setUp(() {
      service = EducationalVoiceService();
    });

    group('Educational Content Retrieval', () {
      test('should provide educational facts for valid topics', () {
        final topics = ['animals', 'colors', 'creativity', 'friendship', 'nature'];
        
        for (final topic in topics) {
          final fact = service.getEducationalFact(topic);
          
          expect(fact, isNotEmpty);
          expect(fact.length, greaterThan(10));
        }
      });

      test('should provide educational questions for valid topics', () {
        final topics = ['animals', 'colors', 'creativity', 'friendship', 'nature'];
        
        for (final topic in topics) {
          final question = service.getEducationalQuestion(topic);
          
          expect(question, isNotEmpty);
          expect(question, contains('?'));
        }
      });

      test('should provide educational stories for valid topics', () {
        final topics = ['animals', 'colors', 'creativity', 'friendship', 'nature'];
        
        for (final topic in topics) {
          final story = service.getEducationalStory(topic);
          
          expect(story, isNotEmpty);
          expect(story.length, greaterThan(20));
        }
      });

      test('should handle invalid topics gracefully', () {
        final fact = service.getEducationalFact('invalid_topic');
        final question = service.getEducationalQuestion('invalid_topic');
        final story = service.getEducationalStory('invalid_topic');
        
        expect(fact, isNotEmpty);
        expect(question, isNotEmpty);
        expect(story, isNotEmpty);
      });

      test('should provide creature-specific facts', () {
        final fact = service.getEducationalFact('animals', creatureType: 'dragon');
        
        expect(fact, isNotEmpty);
        expect(fact.length, greaterThan(10));
      });
    });

    group('Interactive Stories', () {
      test('should start interactive story session', () {
        final story = service.startInteractiveStory();
        
        expect(story, isNotNull);
        expect(story.template, isNotNull);
        expect(story.currentStep, 0);
        expect(story.userChoices, isEmpty);
        expect(story.isComplete, false);
      });

      test('should continue interactive story with user choices', () {
        final story = service.startInteractiveStory();
        final firstQuestion = story.template.choices[0];
        
        expect(firstQuestion, isNotEmpty);
        
        final response = service.continueInteractiveStory(story, 'A magical dragon');
        
        expect(response, isNotEmpty);
        expect(story.currentStep, 1);
        expect(story.userChoices, contains('A magical dragon'));
      });

      test('should complete interactive story after all choices', () {
        final story = service.startInteractiveStory();
        
        // Make all choices
        for (int i = 0; i < story.template.choices.length; i++) {
          final response = service.continueInteractiveStory(story, 'Choice $i');
          
          if (i < story.template.choices.length - 1) {
            expect(story.isComplete, false);
            expect(response, isNotEmpty);
          } else {
            expect(story.isComplete, true);
            expect(response, contains('Thank you'));
          }
        }
      });

      test('should have different story templates', () {
        final stories = <EducationalVoiceService.StoryTemplate>[];
        
        // Generate multiple stories to test variety
        for (int i = 0; i < 10; i++) {
          final story = service.startInteractiveStory();
          stories.add(story.template);
        }
        
        // Should have some variety in story templates
        final uniqueTitles = stories.map((s) => s.title).toSet();
        expect(uniqueTitles.length, greaterThan(1));
      });
    });

    group('Personalized Learning', () {
      test('should create personalized learning experience', () {
        final learning = service.createPersonalizedLearning(
          'TestChild',
          ['animals', 'colors', 'creativity']
        );
        
        expect(learning.childName, 'TestChild');
        expect(learning.interests, containsAll(['animals', 'colors', 'creativity']));
        expect(learning.currentTopic, isIn(learning.interests));
        expect(learning.learningLevel, LearningLevel.beginner);
        expect(learning.achievements, isEmpty);
      });

      test('should provide next learning suggestions', () {
        final learning = service.createPersonalizedLearning(
          'TestChild',
          ['animals', 'colors', 'creativity']
        );
        
        final suggestion = service.getNextLearningSuggestion(learning);
        
        expect(suggestion, isNotEmpty);
        expect(suggestion, contains('Let\'s learn about'));
        expect(learning.currentTopic, isIn(learning.interests));
      });

      test('should rotate through interests in suggestions', () {
        final learning = service.createPersonalizedLearning(
          'TestChild',
          ['animals', 'colors', 'creativity']
        );
        
        final originalTopic = learning.currentTopic;
        
        // Get multiple suggestions
        for (int i = 0; i < learning.interests.length; i++) {
          service.getNextLearningSuggestion(learning);
        }
        
        // Should have cycled back to original topic
        expect(learning.currentTopic, originalTopic);
      });

      test('should award achievements', () {
        final learning = service.createPersonalizedLearning(
          'TestChild',
          ['animals']
        );
        
        service.awardAchievement(learning, 'Learned about animals');
        
        expect(learning.achievements, contains('Learned about animals'));
        expect(learning.achievements.length, 1);
      });

      test('should not duplicate achievements', () {
        final learning = service.createPersonalizedLearning(
          'TestChild',
          ['animals']
        );
        
        service.awardAchievement(learning, 'Learned about animals');
        service.awardAchievement(learning, 'Learned about animals');
        
        expect(learning.achievements.length, 1);
      });

      test('should provide learning progress', () {
        final learning = service.createPersonalizedLearning(
          'TestChild',
          ['animals', 'colors']
        );
        
        service.awardAchievement(learning, 'First achievement');
        
        final progress = service.getLearningProgress(learning);
        
        expect(progress['childName'], 'TestChild');
        expect(progress['interests'], containsAll(['animals', 'colors']));
        expect(progress['achievements'], contains('First achievement'));
        expect(progress['totalAchievements'], 1);
        expect(progress['learningLevel'], LearningLevel.beginner.toString());
      });
    });

    group('Topic Management', () {
      test('should provide all available topics', () {
        final topics = service.getAllEducationalTopics();
        
        expect(topics, isNotEmpty);
        expect(topics, containsAll(['animals', 'colors', 'creativity', 'friendship', 'nature']));
      });

      test('should provide random educational topic', () {
        final topic = service.getRandomEducationalTopic();
        
        expect(topic, isNotEmpty);
        expect(service.getAllEducationalTopics(), contains(topic));
      });

      test('should provide educational content for specific topic', () {
        final content = service.getEducationalContent('animals');
        
        expect(content, isNotNull);
        expect(content!.facts, isNotEmpty);
        expect(content.questions, isNotEmpty);
        expect(content.stories, isNotEmpty);
      });

      test('should return null for invalid topic', () {
        final content = service.getEducationalContent('invalid_topic');
        
        expect(content, isNull);
      });
    });

    group('Content Quality', () {
      test('should have age-appropriate content', () {
        final topics = service.getAllEducationalTopics();
        
        for (final topic in topics) {
          final content = service.getEducationalContent(topic);
          
          for (final fact in content!.facts) {
            expect(fact, isNotEmpty);
            expect(fact.length, greaterThan(10));
            expect(fact, isNot(contains('adult')));
            expect(fact, isNot(contains('scary')));
          }
          
          for (final question in content.questions) {
            expect(question, isNotEmpty);
            expect(question, contains('?'));
            expect(question.length, greaterThan(10));
          }
          
          for (final story in content.stories) {
            expect(story, isNotEmpty);
            expect(story.length, greaterThan(20));
            expect(story, isNot(contains('scary')));
            expect(story, isNot(contains('violent')));
          }
        }
      });

      test('should have engaging and positive content', () {
        final topics = service.getAllEducationalTopics();
        
        for (final topic in topics) {
          final content = service.getEducationalContent(topic);
          
          for (final fact in content!.facts) {
            expect(fact, anyOf([
              contains('amazing'),
              contains('wonderful'),
              contains('beautiful'),
              contains('fun'),
              contains('help'),
              contains('love'),
            ]));
          }
        }
      });
    });

    group('Learning Level Management', () {
      test('should start with beginner level', () {
        final learning = service.createPersonalizedLearning('TestChild', ['animals']);
        
        expect(learning.learningLevel, LearningLevel.beginner);
      });

      test('should support all learning levels', () {
        final levels = LearningLevel.values;
        
        expect(levels.length, 3);
        expect(levels, containsAll([
          LearningLevel.beginner,
          LearningLevel.intermediate,
          LearningLevel.advanced,
        ]));
      });
    });

    group('Story Template Quality', () {
      test('should have complete story templates', () {
        final story = service.startInteractiveStory();
        
        expect(story.template.title, isNotEmpty);
        expect(story.template.opening, isNotEmpty);
        expect(story.template.choices, isNotEmpty);
        expect(story.template.ending, isNotEmpty);
      });

      test('should have engaging story openings', () {
        final story = service.startInteractiveStory();
        
        expect(story.template.opening, isNotEmpty);
        expect(story.template.opening.length, greaterThan(20));
        expect(story.template.opening, anyOf([
          contains('Once upon a time'),
          contains('In a'),
          contains('There was'),
        ]));
      });

      test('should have interactive story choices', () {
        final story = service.startInteractiveStory();
        
        for (final choice in story.template.choices) {
          expect(choice, isNotEmpty);
          expect(choice, contains('?'));
          expect(choice.length, greaterThan(10));
        }
      });

      test('should have positive story endings', () {
        final story = service.startInteractiveStory();
        
        expect(story.template.ending, isNotEmpty);
        expect(story.template.ending.length, greaterThan(20));
        expect(story.template.ending, anyOf([
          contains('happy'),
          contains('wonderful'),
          contains('amazing'),
          contains('beautiful'),
          contains('success'),
        ]));
      });
    });
  });
}