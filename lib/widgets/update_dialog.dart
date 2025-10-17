import 'package:flutter/material.dart';
import '../services/updater_service.dart';

/// Update dialog widget
class UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;
  final VoidCallback? onSkip;
  final VoidCallback? onLater;
  
  const UpdateDialog({
    super.key,
    required this.updateInfo,
    this.onSkip,
    this.onLater,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF98D8C8), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: const Icon(
                            Icons.system_update,
                            color: Colors.white,
                            size: 48,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Update Available!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version ${widget.updateInfo.latestVersion} is now available',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Version info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current: ${widget.updateInfo.currentVersion}',
                          style: const TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Latest: ${widget.updateInfo.latestVersion}',
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Release notes
                    if (widget.updateInfo.releaseNotes != null) ...[
                      const Text(
                        'What\'s New:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.updateInfo.shortReleaseNotes,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Features
                    const Text(
                      'New Features:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _FeatureItem(
                      icon: Icons.bug_fix,
                      text: 'Bug fixes and improvements',
                    ),
                    const _FeatureItem(
                      icon: Icons.new_releases,
                      text: 'New creatures and furniture',
                    ),
                    const _FeatureItem(
                      icon: Icons.language,
                      text: 'Enhanced Swedish language support',
                    ),
                    const _FeatureItem(
                      icon: Icons.speed,
                      text: 'Better performance and stability',
                    ),
                  ],
                ),
              ),
              
              // Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    // Skip button
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          await UpdaterService.skipVersion(widget.updateInfo.latestVersion);
                          if (widget.onSkip != null) widget.onSkip!();
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Later button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          if (widget.onLater != null) widget.onLater!();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFF98D8C8)),
                        ),
                        child: const Text(
                          'Later',
                          style: TextStyle(
                            color: Color(0xFF98D8C8),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Update button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isDownloading ? null : _downloadUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isDownloading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Update Now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadUpdate() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      await UpdaterService.downloadUpdate(widget.updateInfo.downloadUrl!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open download: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }
}

/// Feature item widget
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
