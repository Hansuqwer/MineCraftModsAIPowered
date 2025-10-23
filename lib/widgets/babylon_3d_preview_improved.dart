import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../tts/encouragement_manager.dart';

/// 🎨 Improved Babylon.js 3D Preview Widget
///
/// Fixes all the issues identified in the code review:
/// - Proper asset loading with flutter-asset:// scheme
/// - JS bridge for model ready callbacks
/// - Clean lifecycle management
/// - Parameter handling without full reload
/// - Better camera centering and lighting
class Babylon3DPreviewImproved extends StatefulWidget {
  final Map<String, dynamic>? aiData; // CreationSpec-like
  final double height;
  
  const Babylon3DPreviewImproved({
    super.key, 
    this.aiData,
    this.height = 300,
  });

  @override
  State<Babylon3DPreviewImproved> createState() => _Babylon3DPreviewImprovedState();
}

class _Babylon3DPreviewImprovedState extends State<Babylon3DPreviewImproved> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    print('🎨 [BABYLON_IMPROVED] Initializing 3D preview...');
    print('🔍 [BABYLON_IMPROVED] AI Data: ${widget.aiData}');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'onModelReady', // Keep aligned with preview.html
        onMessageReceived: (_) {
          print('🎉 [BABYLON_IMPROVED] Model ready! Triggering celebration...');
          EncouragementManager().celebrate(); // Sparkle + TTS
        },
      )
      ..setBackgroundColor(const Color(0xFFD6F1FF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('🔄 [BABYLON_IMPROVED] Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('✅ [BABYLON_IMPROVED] Page loaded successfully: $url');
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ [BABYLON_IMPROVED] Web resource error: ${error.description}');
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
                _errorMessage = error.description;
              });
            }
          },
        ),
      )
      ..loadFlutterAsset('assets/3d_preview/preview.html');
  }

  Future<void> _applySpecToWebView(Map<String, dynamic> spec) async {
    try {
      final json = jsonEncode(spec);
      print('🔄 [BABYLON_IMPROVED] Applying spec: $json');
      // Calls window.applySpec(json) in preview.html
      await _controller.runJavaScript("window.applySpec?.(${jsonEncode(json)});");
    } catch (e) {
      print('❌ [BABYLON_IMPROVED] Failed to apply spec: $e');
    }
  }

  @override
  void didUpdateWidget(covariant Babylon3DPreviewImproved oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.aiData != null && widget.aiData != oldWidget.aiData) {
      _applySpecToWebView(widget.aiData!);
    }
  }

  @override
  void dispose() {
    // WebViewController disposes with the widget; nothing special needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFD6F1FF),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            if (_isLoading)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 16),
                    Text('Loading 3D preview...', style: TextStyle(color: Colors.blue)),
                  ],
                ),
              )
            else if (_hasError)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Preview Error: $_errorMessage', 
                         style: const TextStyle(color: Colors.red),
                         textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _hasError = false;
                        });
                        _initializeWebView();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else
              WebViewWidget(controller: _controller),
            
            // Touch instructions overlay
            if (!_isLoading && !_hasError)
              Positioned(
                bottom: 12, 
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54, 
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, size: 14, color: Colors.white), 
                      SizedBox(width: 6),
                      Text('Touch to rotate', 
                           style: TextStyle(color: Colors.white, fontSize: 12))
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
