import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/ai_content_generator.dart';
import '../services/3d_model_generator.dart';

/// Dynamic Babylon.js 3D Preview - Renders AI-generated models
class DynamicBabylonPreview extends StatefulWidget {
  final ModelBlueprint blueprint;
  final double height;

  const DynamicBabylonPreview({
    super.key,
    required this.blueprint,
    this.height = 300,
  });

  @override
  State<DynamicBabylonPreview> createState() => _DynamicBabylonPreviewState();
}

class _DynamicBabylonPreviewState extends State<DynamicBabylonPreview> {
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
    print('🎨 [DYNAMIC_BABYLON] Initializing preview for: ${widget.blueprint.object}');
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('🔄 [DYNAMIC_BABYLON] Page started: $url');
          },
          onPageFinished: (String url) {
            print('✅ [DYNAMIC_BABYLON] Page loaded: $url');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ [DYNAMIC_BABYLON] Error: ${error.description}');
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
      ..loadHtmlString(_generateHTML());
  }

  String _generateHTML() {
    final modelCode = Model3DGenerator.generateBabylonCode(widget.blueprint);
    
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${widget.blueprint.object} Preview</title>
<script src="https://cdn.babylonjs.com/babylon.js"></script>
<script src="https://cdn.babylonjs.com/loaders/babylonjs.loaders.min.js"></script>
<style>
  html, body { margin: 0; overflow: hidden; background: #161616; }
  #renderCanvas { width:100vw; height:100vh; touch-action:none; display:block; }
  #hud {
    position: fixed; left: 8px; bottom: 8px; right: 8px;
    color: #eee; font: 12px/1.4 system-ui, sans-serif; pointer-events:none;
    max-height: 200px; overflow-y: auto;
  }
  .err { color: #ff6b6b; }
  .success { color: #4ade80; }
  .warning { color: #fbbf24; }
</style>
</head>
<body>
<canvas id="renderCanvas"></canvas>
<div id="hud"></div>
<script>
(async function () {
  const log = (msg, cls="") => {
    const el = document.getElementById('hud');
    el.innerHTML += \`<div class="\${cls}">\${msg}</div>\`;
    console.log(\`[HUD] \${msg}\`);
  };

  // Enhanced error catching
  window.addEventListener('error', e => {
    log(\`JS Error: \${e.message} at \${e.filename}:\${e.lineno}\`, 'err');
  });
  window.addEventListener('unhandledrejection', e => {
    log(\`Promise Error: \${e.reason}\`, 'err');
  });

  const canvas = document.getElementById("renderCanvas");
  const engine = new BABYLON.Engine(canvas, true, {preserveDrawingBuffer:true, stencil:true});
  const scene = new BABYLON.Scene(engine);

  const camera = new BABYLON.ArcRotateCamera("cam",
    Math.PI/4, Math.PI/3, 7, BABYLON.Vector3.Zero(), scene);
  camera.wheelPrecision = 50;
  camera.panningSensibility = 0;
  camera.attachControl(canvas, true);

  // Enhanced lighting for better visibility
  const hemi = new BABYLON.HemisphericLight("hemi", new BABYLON.Vector3(0.5, 1, 0.2), scene);
  hemi.intensity = 1.2;
  
  const dir = new BABYLON.DirectionalLight("dir", new BABYLON.Vector3(-1, -2, -1), scene);
  dir.position = new BABYLON.Vector3(5, 10, 5);
  dir.intensity = 0.8;
  
  const pointLight = new BABYLON.PointLight("point", new BABYLON.Vector3(0, 5, 0), scene);
  pointLight.intensity = 0.6;

  log("🎨 Creating ${widget.blueprint.object}...");

  // Generated model code
  $modelCode

  // Create the model
  const model = create${widget.blueprint.object[0].toUpperCase() + widget.blueprint.object.substring(1)}(scene);
  
  if (model) {
    // Center the model
    model.position = BABYLON.Vector3.Zero();
    
    // Add special effects based on features
    ${widget.blueprint.specialFeatures.contains('glowing') ? '''
    const glowLayer = new BABYLON.GlowLayer("glow", scene);
    glowLayer.intensity = 0.6;
    glowLayer.addIncludedOnlyMesh(model);
    ''' : ''}
    
    ${widget.blueprint.specialFeatures.contains('flying') ? '''
    // Flying animation
    scene.registerBeforeRender(() => {
      model.position.y += Math.sin(Date.now() * 0.001) * 0.01;
    });
    ''' : ''}
    
    log("✅ ${widget.blueprint.object} created successfully!", 'success');
  } else {
    log("❌ Failed to create ${widget.blueprint.object}", 'err');
  }

  engine.runRenderLoop(() => scene.render());
  window.addEventListener("resize", () => engine.resize());
  
  log("🎬 Render loop started");
})();
</script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // WebView with Babylon.js scene
            if (!_hasError) WebViewWidget(controller: _controller),

            // Error indicator
            if (_hasError)
              Container(
                color: const Color(0xFF1a1a2e),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '3D Preview Error',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            // Loading indicator
            if (_isLoading && !_hasError)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '🎨 Creating ${widget.blueprint.object}...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Touch hint
            if (!_isLoading && !_hasError)
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Touch to rotate',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Model info
            if (!_isLoading && !_hasError)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.blueprint.object.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.blueprint.theme,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    final colorScheme = widget.blueprint.colorScheme;
    if (colorScheme.isEmpty) return [const Color(0xFF667eea), const Color(0xFF764ba2)];
    
    final colorMap = {
      'red': const Color(0xFFff6b6b),
      'blue': const Color(0xFF4ecdc4),
      'green': const Color(0xFF45b7d1),
      'yellow': const Color(0xFFf9ca24),
      'purple': const Color(0xFF6c5ce7),
      'orange': const Color(0xFFfd79a8),
      'black': const Color(0xFF2d3436),
      'white': const Color(0xFFddd6fe),
      'gold': const Color(0xFFfdcb6e),
      'silver': const Color(0xFFa29bfe),
    };
    
    final primaryColor = colorMap[colorScheme[0]] ?? const Color(0xFF667eea);
    final secondaryColor = colorScheme.length > 1 
        ? (colorMap[colorScheme[1]] ?? const Color(0xFF764ba2))
        : primaryColor;
    
    return [primaryColor, secondaryColor];
  }
}
