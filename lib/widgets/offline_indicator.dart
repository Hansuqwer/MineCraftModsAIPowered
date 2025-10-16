import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

/// Widget that shows offline/online status
class OfflineIndicator extends StatefulWidget {
  final bool showWhenOnline;
  final Duration animationDuration;

  const OfflineIndicator({
    super.key,
    this.showWhenOnline = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator>
    with SingleTickerProviderStateMixin {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isOnline = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Check initial connectivity
    _checkConnectivity();

    // Listen to connectivity changes
    _connectivityService.connectivityStream.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
          if (isOnline) {
            _controller.reverse();
          } else {
            _controller.forward();
          }
        });
      }
    });

    // Start periodic checks
    _connectivityService.startPeriodicChecks();
  }

  Future<void> _checkConnectivity() async {
    final isOnline = await _connectivityService.checkConnectivity();
    if (mounted) {
      setState(() {
        _isOnline = isOnline;
        if (!isOnline) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show if online and showWhenOnline is false
    if (_isOnline && !widget.showWhenOnline) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isOnline ? Colors.green : Colors.orange[700],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isOnline ? Icons.cloud_done : Icons.cloud_off,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isOnline
                  ? 'Back online!'
                  : 'Working offline - using cached responses',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact offline badge
class OfflineBadge extends StatelessWidget {
  final bool isOnline;

  const OfflineBadge({
    super.key,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    if (isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.cloud_off, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            'Offline',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Connectivity quality indicator
class ConnectivityQualityIndicator extends StatefulWidget {
  const ConnectivityQualityIndicator({super.key});

  @override
  State<ConnectivityQualityIndicator> createState() =>
      _ConnectivityQualityIndicatorState();
}

class _ConnectivityQualityIndicatorState
    extends State<ConnectivityQualityIndicator> {
  final ConnectivityService _connectivityService = ConnectivityService();
  ConnectivityQuality _quality = ConnectivityQuality.good;

  @override
  void initState() {
    super.initState();
    _checkQuality();
  }

  Future<void> _checkQuality() async {
    final quality = await _connectivityService.getConnectivityQuality();
    if (mounted) {
      setState(() {
        _quality = quality;
      });
    }
  }

  Color _getColor() {
    switch (_quality) {
      case ConnectivityQuality.good:
        return Colors.green;
      case ConnectivityQuality.fair:
        return Colors.yellow[700]!;
      case ConnectivityQuality.poor:
        return Colors.orange[700]!;
      case ConnectivityQuality.none:
        return Colors.red;
    }
  }

  int _getBarCount() {
    switch (_quality) {
      case ConnectivityQuality.good:
        return 3;
      case ConnectivityQuality.fair:
        return 2;
      case ConnectivityQuality.poor:
        return 1;
      case ConnectivityQuality.none:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final barCount = _getBarCount();

    return Tooltip(
      message: _quality.message,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (index) => Container(
            width: 4,
            height: 8 + (index * 4),
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: index < barCount ? color : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
