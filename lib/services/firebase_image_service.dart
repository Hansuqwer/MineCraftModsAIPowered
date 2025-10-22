import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/enhanced_creature_attributes.dart';

/// Firebase Image Service - Generates Minecraft-style 3D preview images
/// Uses Vertex AI Imagen API with OAuth 2.0 authentication
class FirebaseImageService {
  static String? _projectId;
  static String? _clientId;
  static GoogleSignIn? _googleSignIn;
  static bool _isInitialized = false;
  static const String _baseUrl = 'https://us-central1-aiplatform.googleapis.com/v1/projects';

  /// Initialize the Vertex AI Imagen service with OAuth
  static Future<void> initialize() async {
    if (_isInitialized) return;

    print('🔧 [FIREBASE_IMAGE] Initializing Vertex AI Imagen service with OAuth...');

    try {
      // Load configuration from .env file
      _projectId = dotenv.env['GOOGLE_CLOUD_PROJECT_ID'];
      _clientId = dotenv.env['GOOGLE_CLOUD_CLIENT_ID'];

      if (_projectId == null || _projectId!.isEmpty) {
        print('❌ [FIREBASE_IMAGE] No GOOGLE_CLOUD_PROJECT_ID found in .env');
        print('💡 [FIREBASE_IMAGE] Please add GOOGLE_CLOUD_PROJECT_ID=your_project_id to .env file');
        return;
      }

      if (_clientId == null || _clientId!.isEmpty) {
        print('❌ [FIREBASE_IMAGE] No GOOGLE_CLOUD_CLIENT_ID found in .env');
        print('💡 [FIREBASE_IMAGE] Please add GOOGLE_CLOUD_CLIENT_ID=your_client_id to .env file');
        return;
      }

      // Initialize Google Sign-In
      _googleSignIn = GoogleSignIn(
        scopes: [
          'https://www.googleapis.com/auth/cloud-platform',
        ],
        clientId: _clientId,
      );

      print('✅ [FIREBASE_IMAGE] OAuth configured for project: $_projectId');

      _isInitialized = true;
      print('✅ [FIREBASE_IMAGE] Vertex AI Imagen service initialized successfully');
      print('🔍 [FIREBASE_IMAGE] Project ID: $_projectId');
      print('🔍 [FIREBASE_IMAGE] Client ID: ${_clientId!.substring(0, 20)}...');
    } catch (e) {
      print('❌ [FIREBASE_IMAGE] Error initializing: $e');
    }
  }

  /// Generate Minecraft-style 3D preview image
  /// Returns base64-encoded image or null if generation fails
  static Future<String?> generateMinecraftImage({
    required Map<String, dynamic> creatureAttributes,
  }) async {
    print('🎨 [FIREBASE_IMAGE] === IMAGE GENERATION START ===');

    // Ensure service is initialized
    if (!_isInitialized || _projectId == null || _googleSignIn == null) {
      print('⚠️ [FIREBASE_IMAGE] Service not initialized, attempting to initialize...');
      await initialize();

      if (!_isInitialized || _projectId == null || _googleSignIn == null) {
        print('❌ [FIREBASE_IMAGE] Cannot generate image - service not available');
        return null;
      }
    }

    // Get OAuth access token
    print('🔐 [FIREBASE_IMAGE] Getting OAuth access token...');
    String? accessToken;
    try {
      final account = await _googleSignIn!.signIn();
      if (account == null) {
        print('❌ [FIREBASE_IMAGE] User cancelled Google sign-in');
        return null;
      }

      final auth = await account.authentication;
      accessToken = auth.accessToken;
      
      if (accessToken == null) {
        print('❌ [FIREBASE_IMAGE] Failed to get access token');
        return null;
      }

      print('✅ [FIREBASE_IMAGE] OAuth token obtained successfully');
    } catch (e) {
      print('❌ [FIREBASE_IMAGE] OAuth authentication failed: $e');
      return null;
    }

    try {
      // Extract attributes
      final creatureType = creatureAttributes['creatureType'] ?? 'creature';
      final color = creatureAttributes['color'] ?? 'blue';
      final size = creatureAttributes['size'] ?? 'medium';
      final customName = creatureAttributes['customName'] ?? '';

      print('🔍 [FIREBASE_IMAGE] Type: $creatureType');
      print('🔍 [FIREBASE_IMAGE] Color: $color');
      print('🔍 [FIREBASE_IMAGE] Size: $size');
      print('🔍 [FIREBASE_IMAGE] Name: $customName');

      // Build Minecraft-style prompt
      final prompt = _buildMinecraftPrompt(
        type: creatureType,
        color: color,
        size: size,
        name: customName,
      );

      print('📝 [FIREBASE_IMAGE] Prompt: $prompt');
      print('⏳ [FIREBASE_IMAGE] Calling Vertex AI Imagen API...');

      // Generate image using Vertex AI Imagen API
      print('🎨 [FIREBASE_IMAGE] Generating image with Vertex AI Imagen...');
      
      try {
        // Prepare the request body for Vertex AI Imagen
        final requestBody = {
          'instances': [
            {
              'prompt': prompt,
              'parameters': {
                'sampleCount': 1,
                'aspectRatio': '1:1',
                'safetyFilterLevel': 'block_some',
                'personGeneration': 'allow_adult',
                'includeRaiReason': false,
                'seed': 0,
              }
            }
          ],
          'parameters': {
            'sampleCount': 1,
            'aspectRatio': '1:1',
            'safetyFilterLevel': 'block_some',
            'personGeneration': 'allow_adult',
            'includeRaiReason': false,
            'seed': 0,
          }
        };

        // Make the API call to Vertex AI Imagen with timeout
        final response = await http.post(
          Uri.parse('$_baseUrl/$_projectId/locations/us-central1/publishers/google/models/imagen-3.0-generate-001:predict'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        ).timeout(
          const Duration(seconds: 25),
          onTimeout: () {
            print('⏰ [FIREBASE_IMAGE] API call timed out after 25 seconds');
            throw Exception('API call timed out');
          },
        );

        print('✅ [FIREBASE_IMAGE] Vertex AI response received: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          print('🔍 [FIREBASE_IMAGE] Response data keys: ${responseData.keys}');
          
          // Extract base64 image data from response
          if (responseData['predictions'] != null && 
              responseData['predictions'].isNotEmpty &&
              responseData['predictions'][0]['bytesBase64Encoded'] != null) {
            final base64Data = responseData['predictions'][0]['bytesBase64Encoded'];
            print('🖼️ [FIREBASE_IMAGE] Image data extracted successfully!');
            return base64Data;
          } else {
            print('⚠️ [FIREBASE_IMAGE] No image data in response structure');
            print('🔍 [FIREBASE_IMAGE] Full response: $responseData');
          }
        } else if (response.statusCode == 401) {
          print('❌ [FIREBASE_IMAGE] Authentication failed - check API key');
        } else if (response.statusCode == 403) {
          print('❌ [FIREBASE_IMAGE] Access forbidden - check project permissions');
        } else if (response.statusCode == 404) {
          print('❌ [FIREBASE_IMAGE] API endpoint not found - check project ID');
        } else {
          print('❌ [FIREBASE_IMAGE] API error: ${response.statusCode} - ${response.body}');
        }
        
        print('⚠️ [FIREBASE_IMAGE] No image data in response, using fallback');
        return null;
      } catch (e) {
        print('❌ [FIREBASE_IMAGE] Image generation failed: $e');
        return null;
      }
    } catch (e) {
      print('❌ [FIREBASE_IMAGE] Error generating image: $e');
      print('💡 [FIREBASE_IMAGE] Falling back to emoji placeholder');
      return null;
    }
  }

  /// Build Minecraft-style prompt for image generation
  static String _buildMinecraftPrompt({
    required String type,
    required String color,
    required String size,
    required String name,
  }) {
    return '''
Create a Minecraft-style 3D isometric image of a $color $type:

Style: Blocky, pixelated, Minecraft Bedrock Edition aesthetic
View: 45-degree isometric perspective
Background: Simple gradient (grass green or sky blue)
Size: $size
Name: $name

Requirements:
- Blocky, cubic design (NOT smooth)
- Pixelated textures (8-bit style)
- Clear silhouette
- Kid-friendly appearance
- Vibrant, saturated colors
- High contrast and clean edges

Specific for $type:
${_getItemSpecificGuidelines(type)}

Output: 512x512 PNG image with transparent or gradient background
''';
  }

  /// Get item-specific guidelines for image generation
  static String _getItemSpecificGuidelines(String type) {
    final lowerType = type.toLowerCase();
    
    if (lowerType.contains('sword') || lowerType.contains('axe') || lowerType.contains('bow')) {
      return '- Show weapon at 45-degree angle with handle visible\n- Include blade/head details\n- Add subtle glow effect';
    } else if (lowerType.contains('helmet') || lowerType.contains('chestplate') || lowerType.contains('armor')) {
      return '- Show armor from front-quarter view\n- Include helmet details and visor\n- Add metallic shine effect';
    } else if (lowerType.contains('dragon') || lowerType.contains('cat') || lowerType.contains('dog')) {
      return '- Show full body in standing pose\n- Include facial features and details\n- Add friendly expression';
    } else if (lowerType.contains('chair') || lowerType.contains('table') || lowerType.contains('bed')) {
      return '- Show furniture from 3/4 view\n- Include structural details\n- Add wood/grain texture';
    } else if (lowerType.contains('car') || lowerType.contains('boat') || lowerType.contains('plane')) {
      return '- Show vehicle from side-angle view\n- Include wheels/wings details\n- Add motion blur effect';
    } else {
      return '- Show item clearly and recognizably\n- Include characteristic details\n- Add appropriate texture';
    }
  }

  /// Check if Firebase image generation is available
  static bool isAvailable() {
    return _isInitialized && _apiKey != null;
  }

  /// Get status message for debugging
  static String getStatus() {
    if (!_isInitialized) return 'Not initialized';
    if (_apiKey == null) return 'API key is null';
    return 'Ready';
  }
}