import 'package:speech_to_text/speech_to_text.dart';
import 'dart:io';
import 'dart:async';
import 'language_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enhanced speech service with kid-voice optimization and VAD
class EnhancedSpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  String _lastWords = '';
  double _currentSoundLevel = 0.0;

  // Voice Activity Detection (VAD) settings
  Timer? _vadTimer;
  DateTime? _lastSpeechTime;
  final Duration _silenceThreshold = const Duration(milliseconds: 1500);

  // Kid-voice optimization settings
  VoiceSettings _voiceSettings = VoiceSettings.defaultSettings();

  // Callbacks for real-time feedback
  Function(double)? onSoundLevelChange;
  Function(String)? onPartialResult;
  Function(bool)? onListeningStateChange;

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  String get lastWords => _lastWords;
  double get currentSoundLevel => _currentSoundLevel;
  VoiceSettings get voiceSettings => _voiceSettings;

  /// Initialize speech recognition with kid-voice optimization
  Future<bool> initialize() async {
    // On desktop platforms, speech recognition is not available
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      print('Speech recognition not available on desktop platforms');
      _isAvailable = false;
      return false;
    }

    try {
      // Load saved voice settings
      await _loadVoiceSettings();

      _isAvailable = await _speech.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
          _stopVAD();
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
          final isListening = status == 'listening';
          if (_isListening != isListening) {
            _isListening = isListening;
            onListeningStateChange?.call(_isListening);
          }
        },
      );

      print('Speech recognition initialized: $_isAvailable');
      print('Kid-voice optimization enabled: ${_voiceSettings.kidVoiceOptimization}');

      return _isAvailable;
    } catch (e) {
      print('Speech initialization error: $e');
      _isAvailable = false;
      return false;
    }
  }

  /// Load voice settings from storage
  Future<void> _loadVoiceSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _voiceSettings = VoiceSettings(
        kidVoiceOptimization: prefs.getBool('voice_kid_optimization') ?? true,
        noiseReduction: prefs.getBool('voice_noise_reduction') ?? true,
        autoStopEnabled: prefs.getBool('voice_auto_stop') ?? true,
        confidenceThreshold: prefs.getDouble('voice_confidence_threshold') ?? 0.3,
        listenDuration: prefs.getInt('voice_listen_duration') ?? 15,
        pauseDuration: prefs.getInt('voice_pause_duration') ?? 2,
        isCalibrated: prefs.getBool('voice_calibrated') ?? false,
        calibrationLevel: prefs.getDouble('voice_calibration_level') ?? 0.5,
      );

      print('Voice settings loaded: ${_voiceSettings.toString()}');
    } catch (e) {
      print('Error loading voice settings: $e');
      _voiceSettings = VoiceSettings.defaultSettings();
    }
  }

  /// Save voice settings to storage
  Future<void> saveVoiceSettings(VoiceSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('voice_kid_optimization', settings.kidVoiceOptimization);
      await prefs.setBool('voice_noise_reduction', settings.noiseReduction);
      await prefs.setBool('voice_auto_stop', settings.autoStopEnabled);
      await prefs.setDouble('voice_confidence_threshold', settings.confidenceThreshold);
      await prefs.setInt('voice_listen_duration', settings.listenDuration);
      await prefs.setInt('voice_pause_duration', settings.pauseDuration);
      await prefs.setBool('voice_calibrated', settings.isCalibrated);
      await prefs.setDouble('voice_calibration_level', settings.calibrationLevel);

      _voiceSettings = settings;
      print('Voice settings saved: ${settings.toString()}');
    } catch (e) {
      print('Error saving voice settings: $e');
    }
  }

  /// Enhanced listen method with VAD and kid-voice optimization
  Future<String?> listen() async {
    if (!_isAvailable) {
      print('Speech recognition not available');
      return null;
    }

    try {
      _isListening = true;
      onListeningStateChange?.call(true);
      print('Starting enhanced speech recognition...');

      // Get current language for speech recognition
      final currentLocale = await LanguageService.getCurrentLanguage();
      final localeId = currentLocale.languageCode == 'sv' ? 'sv_SE' : 'en_US';
      print('Using speech recognition locale: $localeId');

      String? result;
      bool isComplete = false;

      // Start Voice Activity Detection
      _startVAD();

      await _speech.listen(
        onResult: (speechResult) {
          // Update sound level for visual feedback
          _currentSoundLevel = speechResult.hasConfidenceRating
              ? speechResult.confidence
              : 0.5;
          onSoundLevelChange?.call(_currentSoundLevel);

          print('Speech result: ${speechResult.recognizedWords} (confidence: ${speechResult.confidence})');
          _lastWords = speechResult.recognizedWords;

          // Notify partial results for real-time feedback
          if (!speechResult.finalResult) {
            onPartialResult?.call(_lastWords);
          }

          // Update last speech time for VAD
          _lastSpeechTime = DateTime.now();

          // Kid-voice optimization: lower confidence threshold
          final threshold = _voiceSettings.kidVoiceOptimization
              ? _voiceSettings.confidenceThreshold * 0.8  // 20% more lenient for kids
              : _voiceSettings.confidenceThreshold;

          if (speechResult.confidence > threshold || !speechResult.hasConfidenceRating) {
            if (speechResult.finalResult) {
              print('Final result: $_lastWords (confidence: ${speechResult.confidence})');
              result = _lastWords;
              isComplete = true;
              _stopVAD();
            }
          } else {
            print('Low confidence result ignored: ${speechResult.confidence}');
          }
        },
        listenFor: Duration(seconds: _voiceSettings.listenDuration),
        pauseFor: Duration(seconds: _voiceSettings.pauseDuration),
        partialResults: true,
        localeId: localeId,
        listenMode: ListenMode.confirmation,
        cancelOnError: false,
        // Kid-voice optimization: enable sound level feedback
        onSoundLevelChange: (level) {
          _currentSoundLevel = level;
          onSoundLevelChange?.call(level);
        },
      );

      // Wait for completion or VAD timeout
      while (_isListening && !isComplete) {
        await Future.delayed(const Duration(milliseconds: 100));

        // Check VAD auto-stop
        if (_voiceSettings.autoStopEnabled && _shouldAutoStop()) {
          print('VAD: Auto-stopping due to silence');
          isComplete = true;
          result = _lastWords.isNotEmpty ? _lastWords : null;
        }
      }

      _isListening = false;
      _stopVAD();
      onListeningStateChange?.call(false);

      return result;
    } catch (e) {
      print('Speech listening error: $e');
      _isListening = false;
      _stopVAD();
      onListeningStateChange?.call(false);
      return null;
    }
  }

  /// Start listening with enhanced features
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    Function(String)? onPartial,
    Function(double)? onSoundLevel,
  }) async {
    if (!_isAvailable) {
      onError('Speech recognition not available');
      return;
    }

    // Set callbacks
    this.onPartialResult = onPartial;
    this.onSoundLevelChange = onSoundLevel;

    try {
      _isListening = true;
      onListeningStateChange?.call(true);
      print('Starting enhanced speech recognition...');

      final currentLocale = await LanguageService.getCurrentLanguage();
      final localeId = currentLocale.languageCode == 'sv' ? 'sv_SE' : 'en_US';
      print('Using speech recognition locale: $localeId');

      // Start VAD
      _startVAD();

      await _speech.listen(
        onResult: (speechResult) {
          _currentSoundLevel = speechResult.hasConfidenceRating
              ? speechResult.confidence
              : 0.5;
          onSoundLevel?.call(_currentSoundLevel);

          print('Speech result: ${speechResult.recognizedWords} (confidence: ${speechResult.confidence})');
          _lastWords = speechResult.recognizedWords;
          _lastSpeechTime = DateTime.now();

          // Partial results for live feedback
          if (!speechResult.finalResult) {
            onPartial?.call(_lastWords);
          }

          // Kid-voice optimization
          final threshold = _voiceSettings.kidVoiceOptimization
              ? _voiceSettings.confidenceThreshold * 0.8
              : _voiceSettings.confidenceThreshold;

          if (speechResult.confidence > threshold || !speechResult.hasConfidenceRating) {
            if (speechResult.finalResult) {
              print('Final result: $_lastWords (confidence: ${speechResult.confidence})');
              onResult(_lastWords);
              _isListening = false;
              _stopVAD();
              onListeningStateChange?.call(false);
            }
          } else {
            print('Low confidence result ignored: ${speechResult.confidence}');
          }
        },
        listenFor: Duration(seconds: _voiceSettings.listenDuration),
        pauseFor: Duration(seconds: _voiceSettings.pauseDuration),
        partialResults: true,
        localeId: localeId,
        listenMode: ListenMode.confirmation,
        cancelOnError: false,
        onSoundLevelChange: (level) {
          _currentSoundLevel = level;
          onSoundLevel?.call(level);
        },
      );
    } catch (e) {
      print('Speech listening error: $e');
      onError('Speech listening failed: $e');
      _isListening = false;
      _stopVAD();
      onListeningStateChange?.call(false);
    }
  }

  /// Voice Activity Detection - Start monitoring
  void _startVAD() {
    _lastSpeechTime = DateTime.now();
    _vadTimer?.cancel();

    if (!_voiceSettings.autoStopEnabled) return;

    _vadTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_shouldAutoStop()) {
        print('VAD: Detected silence, stopping...');
        stopListening();
      }
    });
  }

  /// Voice Activity Detection - Stop monitoring
  void _stopVAD() {
    _vadTimer?.cancel();
    _vadTimer = null;
    _lastSpeechTime = null;
  }

  /// Check if we should auto-stop due to silence
  bool _shouldAutoStop() {
    if (_lastSpeechTime == null) return false;

    final silenceDuration = DateTime.now().difference(_lastSpeechTime!);
    return silenceDuration > _silenceThreshold && _lastWords.isNotEmpty;
  }

  /// Stop listening
  Future<void> stopListening() async {
    try {
      await _speech.stop();
      print('Speech recognition stopped');
      _stopVAD();
    } catch (e) {
      print('Error stopping speech: $e');
    }
    _isListening = false;
    onListeningStateChange?.call(false);
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    try {
      await _speech.cancel();
      print('Speech recognition cancelled');
      _stopVAD();
    } catch (e) {
      print('Error cancelling speech: $e');
    }
    _isListening = false;
    onListeningStateChange?.call(false);
  }

  /// Calibrate voice for kid-specific optimization
  Future<VoiceCalibrationResult> calibrateVoice({
    required Function(String) onInstruction,
    required Function(double) onProgress,
  }) async {
    if (!_isAvailable) {
      return VoiceCalibrationResult(
        success: false,
        message: 'Speech recognition not available',
        calibrationLevel: 0.5,
      );
    }

    try {
      onInstruction('Let\'s set up your voice! Say "Hello Crafta!" when you\'re ready.');
      await Future.delayed(const Duration(seconds: 2));

      // Test 1: Volume calibration
      onProgress(0.1);
      onInstruction('Say "Hello Crafta!" loudly!');
      final loudResult = await listen();

      if (loudResult == null || loudResult.isEmpty) {
        return VoiceCalibrationResult(
          success: false,
          message: 'Could not hear you. Please try again in a quieter place.',
          calibrationLevel: 0.5,
        );
      }

      onProgress(0.3);
      await Future.delayed(const Duration(milliseconds: 500));

      // Test 2: Clarity calibration
      onInstruction('Great! Now say "I love creating creatures!"');
      final clarityResult = await listen();

      onProgress(0.6);
      await Future.delayed(const Duration(milliseconds: 500));

      // Test 3: Speed calibration
      onInstruction('Awesome! Now say it slowly: "Purple... Dragon... With... Wings"');
      final speedResult = await listen();

      onProgress(0.9);
      await Future.delayed(const Duration(milliseconds: 500));

      // Calculate calibration level based on results
      double calibrationLevel = 0.5;
      if (loudResult.isNotEmpty && clarityResult != null && speedResult != null) {
        calibrationLevel = 0.8; // Good calibration
      } else if (loudResult.isNotEmpty) {
        calibrationLevel = 0.6; // Basic calibration
      }

      // Save calibration
      final calibratedSettings = _voiceSettings.copyWith(
        isCalibrated: true,
        calibrationLevel: calibrationLevel,
        confidenceThreshold: 0.3 * calibrationLevel, // Adjust based on calibration
      );
      await saveVoiceSettings(calibratedSettings);

      onProgress(1.0);
      onInstruction('Perfect! Your voice is all set up! 🎉');

      return VoiceCalibrationResult(
        success: true,
        message: 'Voice calibration complete! 🎉',
        calibrationLevel: calibrationLevel,
      );

    } catch (e) {
      print('Voice calibration error: $e');
      return VoiceCalibrationResult(
        success: false,
        message: 'Calibration failed: $e',
        calibrationLevel: 0.5,
      );
    }
  }

  /// Check if voice calibration is needed
  bool needsCalibration() {
    return !_voiceSettings.isCalibrated;
  }
}

/// Voice settings for kid-voice optimization
class VoiceSettings {
  final bool kidVoiceOptimization;
  final bool noiseReduction;
  final bool autoStopEnabled;
  final double confidenceThreshold; // 0.0 to 1.0
  final int listenDuration; // seconds
  final int pauseDuration; // seconds
  final bool isCalibrated;
  final double calibrationLevel; // 0.0 to 1.0

  VoiceSettings({
    required this.kidVoiceOptimization,
    required this.noiseReduction,
    required this.autoStopEnabled,
    required this.confidenceThreshold,
    required this.listenDuration,
    required this.pauseDuration,
    required this.isCalibrated,
    required this.calibrationLevel,
  });

  factory VoiceSettings.defaultSettings() {
    return VoiceSettings(
      kidVoiceOptimization: true,
      noiseReduction: true,
      autoStopEnabled: true,
      confidenceThreshold: 0.3,
      listenDuration: 15,
      pauseDuration: 2,
      isCalibrated: false,
      calibrationLevel: 0.5,
    );
  }

  VoiceSettings copyWith({
    bool? kidVoiceOptimization,
    bool? noiseReduction,
    bool? autoStopEnabled,
    double? confidenceThreshold,
    int? listenDuration,
    int? pauseDuration,
    bool? isCalibrated,
    double? calibrationLevel,
  }) {
    return VoiceSettings(
      kidVoiceOptimization: kidVoiceOptimization ?? this.kidVoiceOptimization,
      noiseReduction: noiseReduction ?? this.noiseReduction,
      autoStopEnabled: autoStopEnabled ?? this.autoStopEnabled,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      listenDuration: listenDuration ?? this.listenDuration,
      pauseDuration: pauseDuration ?? this.pauseDuration,
      isCalibrated: isCalibrated ?? this.isCalibrated,
      calibrationLevel: calibrationLevel ?? this.calibrationLevel,
    );
  }

  @override
  String toString() {
    return 'VoiceSettings(kidOptimization: $kidVoiceOptimization, '
        'noiseReduction: $noiseReduction, autoStop: $autoStopEnabled, '
        'confidence: $confidenceThreshold, calibrated: $isCalibrated, '
        'calibrationLevel: $calibrationLevel)';
  }
}

/// Result of voice calibration
class VoiceCalibrationResult {
  final bool success;
  final String message;
  final double calibrationLevel;

  VoiceCalibrationResult({
    required this.success,
    required this.message,
    required this.calibrationLevel,
  });
}
