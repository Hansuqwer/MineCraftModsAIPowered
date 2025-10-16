import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

/// Setup function to initialize test environment
Future<void> setupTests() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Load .env file for tests
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // If .env doesn't exist, create a test environment
    dotenv.testLoad(fileInput: '''
OPENAI_API_KEY=sk-test-key-for-testing
APP_ENV=test
DEBUG_MODE=true
''');
  }
}
