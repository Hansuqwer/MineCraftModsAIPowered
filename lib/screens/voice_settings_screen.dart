import 'package:flutter/material.dart';
import '../services/enhanced_speech_service.dart';
import '../services/enhanced_tts_service.dart';
import 'voice_calibration_screen.dart';

/// Voice settings screen for adjusting voice and speech options
class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({Key? key}) : super(key: key);

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  final EnhancedSpeechService _speechService = EnhancedSpeechService();
  final EnhancedTTSService _ttsService = EnhancedTTSService();

  bool _isInitialized = false;
  VoiceSettings? _speechSettings;
  TTSSettings? _ttsSettings;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _speechService.initialize();
    await _ttsService.initialize();

    setState(() {
      _isInitialized = true;
      _speechSettings = _speechService.voiceSettings;
      _ttsSettings = _ttsService.settings;
    });
  }

  Future<void> _saveSettings() async {
    if (_speechSettings != null) {
      await _speechService.saveVoiceSettings(_speechSettings!);
    }
    if (_ttsSettings != null) {
      await _ttsService.saveSettings(_ttsSettings!);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved! ✨')),
      );
    }
  }

  Future<void> _testVoice() async {
    await _ttsService.speak('Hi! This is how Crafta sounds with your new settings!');
  }

  Future<void> _recalibrate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const VoiceCalibrationScreen()),
    );

    if (result == true) {
      // Reload settings after calibration
      await _initializeServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Voice Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // TTS Settings Section
          _buildSectionTitle('Crafta\'s Voice', Icons.record_voice_over),
          _buildTTSSettings(),
          const SizedBox(height: 24),

          // Speech Recognition Settings Section
          _buildSectionTitle('Your Voice', Icons.mic),
          _buildSpeechSettings(),
          const SizedBox(height: 24),

          // Actions Section
          _buildSectionTitle('Actions', Icons.settings),
          _buildActionButtons(),
          const SizedBox(height: 24),

          // Info Section
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTTSSettings() {
    if (_ttsSettings == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Speed Setting
            Text(
              'Speaking Speed',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildSpeedSelector(),
            const SizedBox(height: 20),

            // Pitch Slider
            Text(
              'Voice Pitch: ${_ttsSettings!.pitch.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Slider(
              value: _ttsSettings!.pitch,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: _ttsSettings!.pitch.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _ttsSettings = _ttsSettings!.copyWith(pitch: value);
                });
              },
            ),
            Text(
              'Lower = Deeper, Higher = Cheerful',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // Volume Slider
            Text(
              'Volume: ${(_ttsSettings!.volume * 100).toInt()}%',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Slider(
              value: _ttsSettings!.volume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: '${(_ttsSettings!.volume * 100).toInt()}%',
              onChanged: (value) {
                setState(() {
                  _ttsSettings = _ttsSettings!.copyWith(volume: value);
                });
              },
            ),
            const SizedBox(height: 20),

            // Personality Toggle
            SwitchListTile(
              title: const Text('Personality & Expressions'),
              subtitle: const Text('Add fun expressions and encouragement'),
              value: _ttsSettings!.personalityEnabled,
              onChanged: (value) {
                setState(() {
                  _ttsSettings = _ttsSettings!.copyWith(personalityEnabled: value);
                });
              },
            ),

            // Sound Effects Toggle
            SwitchListTile(
              title: const Text('Sound Effects'),
              subtitle: const Text('Play creature sounds and celebrations'),
              value: _ttsSettings!.soundEffectsEnabled,
              onChanged: (value) {
                setState(() {
                  _ttsSettings = _ttsSettings!.copyWith(soundEffectsEnabled: value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedSelector() {
    return SegmentedButton<TTSSpeed>(
      segments: TTSSpeed.values.map((speed) {
        return ButtonSegment<TTSSpeed>(
          value: speed,
          label: Text('${speed.emoji} ${speed.displayName}'),
        );
      }).toList(),
      selected: {_ttsSettings!.speed},
      onSelectionChanged: (Set<TTSSpeed> selection) {
        setState(() {
          _ttsSettings = _ttsSettings!.copyWith(speed: selection.first);
        });
      },
    );
  }

  Widget _buildSpeechSettings() {
    if (_speechSettings == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kid Voice Optimization
            SwitchListTile(
              title: const Text('Kid Voice Optimization'),
              subtitle: const Text('Better recognition for children\'s voices'),
              value: _speechSettings!.kidVoiceOptimization,
              onChanged: (value) {
                setState(() {
                  _speechSettings = _speechSettings!.copyWith(
                    kidVoiceOptimization: value,
                  );
                });
              },
            ),

            // Auto-stop
            SwitchListTile(
              title: const Text('Auto-Stop on Silence'),
              subtitle: const Text('Automatically stop listening when quiet'),
              value: _speechSettings!.autoStopEnabled,
              onChanged: (value) {
                setState(() {
                  _speechSettings = _speechSettings!.copyWith(
                    autoStopEnabled: value,
                  );
                });
              },
            ),

            // Noise Reduction
            SwitchListTile(
              title: const Text('Noise Reduction'),
              subtitle: const Text('Filter out background noise'),
              value: _speechSettings!.noiseReduction,
              onChanged: (value) {
                setState(() {
                  _speechSettings = _speechSettings!.copyWith(
                    noiseReduction: value,
                  );
                });
              },
            ),

            const Divider(height: 32),

            // Calibration Status
            _buildCalibrationStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationStatus() {
    final isCalibrated = _speechSettings!.isCalibrated;
    final calibrationLevel = _speechSettings!.calibrationLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calibration Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isCalibrated ? Icons.check_circle : Icons.warning,
                      color: isCalibrated ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCalibrated ? 'Calibrated' : 'Not Calibrated',
                      style: TextStyle(
                        color: isCalibrated ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isCalibrated)
              Text(
                '${(calibrationLevel * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        if (isCalibrated) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: calibrationLevel,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 8,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.volume_up, color: Theme.of(context).primaryColor),
              title: const Text('Test Voice'),
              subtitle: const Text('Hear how Crafta sounds'),
              trailing: const Icon(Icons.play_arrow),
              onTap: _testVoice,
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.mic_external_on, color: Theme.of(context).primaryColor),
              title: const Text('Recalibrate Voice'),
              subtitle: const Text('Set up your voice again'),
              trailing: const Icon(Icons.settings),
              onTap: _recalibrate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Text(
                  'Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem('🐢 Slow speed is great for younger kids (4-6 years)'),
            _buildInfoItem('🐇 Normal speed works for most kids (6-8 years)'),
            _buildInfoItem('🚀 Fast speed is perfect for older kids (8-10 years)'),
            _buildInfoItem('🎤 Recalibrate if Crafta has trouble hearing you'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
