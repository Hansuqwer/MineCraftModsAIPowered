import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'dart:convert';

/// Enhanced Minecraft 3D Preview with Gestures, Animations & Environment
/// Fixes the "blue floating model" issue and adds interactive features
class EnhancedMinecraft3DPreview extends StatefulWidget {
  final Map<String, dynamic> creatureAttributes;
  final double size;
  final bool enableGestures;
  final bool enableAnimations;
  final bool showEnvironment;
  final bool showSizeReference;

  const EnhancedMinecraft3DPreview({
    super.key,
    required this.creatureAttributes,
    this.size = 400.0,
    this.enableGestures = true,
    this.enableAnimations = true,
    this.showEnvironment = true,
    this.showSizeReference = true,
  });

  @override
  State<EnhancedMinecraft3DPreview> createState() => _EnhancedMinecraft3DPreviewState();
}

class _EnhancedMinecraft3DPreviewState extends State<EnhancedMinecraft3DPreview> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    // Skip WebView on desktop
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      setState(() => _isLoading = false);
      return;
    }

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView Error: ${error.description}');
            setState(() {
              _errorMessage = 'Failed to load 3D preview';
              _isLoading = false;
            });
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          print('3D Preview: ${message.message}');
        },
      )
      ..loadHtmlString(_generateEnhancedHTML());
  }

  String _generateEnhancedHTML() {
    final creatureType = widget.creatureAttributes['creatureType'] ?? 'creature';
    final color = widget.creatureAttributes['color'] ?? 'purple';
    final effects = widget.creatureAttributes['effects'] ?? [];
    final hasFlames = effects.contains('flames') || effects.contains('fire');
    final hasGlow = effects.contains('glow') || effects.contains('magic');
    final hasWings = effects.contains('wings') || effects.contains('flying');
    final size = widget.creatureAttributes['size'] ?? 'normal';

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>Enhanced 3D Preview</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { width: 100%; height: 100%; overflow: hidden; }
        body { background: linear-gradient(to bottom, #87CEEB 0%, #E0F6FF 50%, #C2E5FF 100%); }
        #renderCanvas { width: 100%; height: 100%; touch-action: none; display: block; }
        #loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            text-align: center;
            color: white;
            font-family: 'Minecraft', Arial, sans-serif;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
        }
        #loading .spinner {
            width: 50px;
            height: 50px;
            border: 4px solid rgba(255,255,255,0.3);
            border-top-color: white;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 16px;
        }
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        #info {
            position: absolute;
            bottom: 10px;
            left: 10px;
            color: white;
            font-size: 12px;
            text-shadow: 1px 1px 2px rgba(0,0,0,0.7);
            font-family: Arial, sans-serif;
        }
    </style>
</head>
<body>
    <div id="loading">
        <div class="spinner"></div>
        <div>Loading 3D Preview...</div>
    </div>
    <div id="info" style="display: none;">
        <div>🖱️ Drag to rotate</div>
        <div>🔍 Pinch to zoom</div>
        <div>👆 Tap to stop auto-rotation</div>
    </div>
    <canvas id="renderCanvas"></canvas>

    <script src="https://cdn.babylonjs.com/babylon.js"></script>
    <script>
        // Wait for Babylon.js to load
        window.addEventListener('load', function() {
            initScene();
        });

        function initScene() {
            try {
                const canvas = document.getElementById('renderCanvas');
                const engine = new BABYLON.Engine(canvas, true, {
                    preserveDrawingBuffer: true,
                    stencil: true,
                    antialias: true
                });

                const scene = new BABYLON.Scene(engine);
                scene.clearColor = new BABYLON.Color4(0, 0, 0, 0);

                // ===== CAMERA SETUP =====
                const camera = new BABYLON.ArcRotateCamera(
                    'camera',
                    -Math.PI / 2,  // alpha (horizontal rotation)
                    Math.PI / 3,   // beta (vertical rotation)
                    6,             // radius (distance)
                    BABYLON.Vector3.Zero(),
                    scene
                );
                camera.attachControls(canvas, true);
                camera.lowerRadiusLimit = 3;
                camera.upperRadiusLimit = 15;
                camera.lowerBetaLimit = 0.1;
                camera.upperBetaLimit = Math.PI / 2;

                // Smooth camera movements
                camera.inertia = 0.9;
                camera.angularSensibilityX = 1000;
                camera.angularSensibilityY = 1000;
                camera.panningSensibility = 1000;
                camera.pinchPrecision = 50;
                camera.wheelPrecision = 50;

                // Auto-rotation (can be stopped by user interaction)
                camera.useAutoRotationBehavior = true;
                const autoRotate = camera.autoRotationBehavior;
                autoRotate.idleRotationSpeed = 0.3;
                autoRotate.idleRotationWaitTime = 2000;
                autoRotate.idleRotationSpinupTime = 1000;

                // ===== LIGHTING SETUP =====
                // Hemispheric light (ambient)
                const hemiLight = new BABYLON.HemisphericLight(
                    'hemiLight',
                    new BABYLON.Vector3(0, 1, 0),
                    scene
                );
                hemiLight.intensity = 0.7;
                hemiLight.diffuse = new BABYLON.Color3(1, 1, 1);
                hemiLight.groundColor = new BABYLON.Color3(0.3, 0.3, 0.3);

                // Directional light (sun)
                const sunLight = new BABYLON.DirectionalLight(
                    'sunLight',
                    new BABYLON.Vector3(-1, -2, -1),
                    scene
                );
                sunLight.position = new BABYLON.Vector3(10, 20, 10);
                sunLight.intensity = 0.8;
                sunLight.diffuse = new BABYLON.Color3(1, 0.98, 0.9);

                // Enable shadows
                const shadowGenerator = new BABYLON.ShadowGenerator(1024, sunLight);
                shadowGenerator.useBlurExponentialShadowMap = true;
                shadowGenerator.blurKernel = 32;

                // ===== ENVIRONMENT =====
                ${widget.showEnvironment ? _generateEnvironment() : ''}

                // ===== CREATE MODEL =====
                const model = createModel();
                if (model) {
                    // Add shadows to model
                    shadowGenerator.addShadowCaster(model, true);
                    model.receiveShadows = false;

                    // Add all children to shadow caster
                    model.getChildMeshes().forEach(mesh => {
                        shadowGenerator.addShadowCaster(mesh, true);
                    });

                    // ${widget.enableAnimations ? 'startAnimations(model, scene);' : ''}
                }

                // ===== SIZE REFERENCE =====
                ${widget.showSizeReference ? _generateSizeReference() : ''}

                // Hide loading
                document.getElementById('loading').style.display = 'none';
                document.getElementById('info').style.display = 'block';

                // ===== RENDER LOOP =====
                engine.runRenderLoop(() => {
                    scene.render();
                });

                // Handle resize
                window.addEventListener('resize', () => {
                    engine.resize();
                });

                // Report success
                if (window.FlutterChannel) {
                    window.FlutterChannel.postMessage('3D Preview loaded successfully');
                }

                // ===== MODEL CREATION =====
                function createModel() {
                    const type = '${creatureType}';
                    const modelColor = '${color}';
                    const modelSize = '${size}';
                    const hasFlames = ${hasFlames};
                    const hasGlow = ${hasGlow};
                    const hasWings = ${hasWings};

                    let model;
                    const scale = modelSize === 'giant' ? 2.0 : modelSize === 'tiny' ? 0.5 : 1.0;

                    // Create different models based on type
                    if (type.includes('dragon')) {
                        model = createDragon(modelColor, hasWings, scale);
                    } else {
                        model = createCreature(modelColor, hasWings, scale);
                    }

                    // Add effects
                    if (hasFlames) {
                        addFlameEffect(model);
                    }
                    if (hasGlow) {
                        addGlowEffect(model, modelColor);
                    }

                    return model;
                }

                function createDragon(color, hasWings, scale) {
                    const parent = new BABYLON.TransformNode('dragon');

                    // Body
                    const body = BABYLON.MeshBuilder.CreateBox('body', {
                        width: 1 * scale,
                        height: 1.2 * scale,
                        depth: 2 * scale
                    }, scene);
                    body.position.y = 0.6 * scale;

                    // Head
                    const head = BABYLON.MeshBuilder.CreateBox('head', {
                        width: 0.8 * scale,
                        height: 0.7 * scale,
                        depth: 0.8 * scale
                    }, scene);
                    head.position = new BABYLON.Vector3(0, 1.5 * scale, 1.2 * scale);

                    // Snout
                    const snout = BABYLON.MeshBuilder.CreateBox('snout', {
                        width: 0.4 * scale,
                        height: 0.3 * scale,
                        depth: 0.6 * scale
                    }, scene);
                    snout.position = new BABYLON.Vector3(0, 1.4 * scale, 1.8 * scale);

                    // Tail
                    const tail = BABYLON.MeshBuilder.CreateCylinder('tail', {
                        diameterTop: 0.3 * scale,
                        diameterBottom: 0.1 * scale,
                        height: 1.5 * scale
                    }, scene);
                    tail.position = new BABYLON.Vector3(0, 0.4 * scale, -1.5 * scale);
                    tail.rotation.x = Math.PI / 6;

                    // Legs
                    const legPositions = [
                        [-0.4, 0, 0.6],
                        [0.4, 0, 0.6],
                        [-0.4, 0, -0.6],
                        [0.4, 0, -0.6]
                    ];

                    legPositions.forEach((pos, i) => {
                        const leg = BABYLON.MeshBuilder.CreateCylinder(`leg${i}`, {
                            diameter: 0.3 * scale,
                            height: 0.8 * scale
                        }, scene);
                        leg.position = new BABYLON.Vector3(
                            pos[0] * scale,
                            0.4 * scale,
                            pos[1] * scale
                        );
                        leg.parent = parent;

                        // Foot
                        const foot = BABYLON.MeshBuilder.CreateBox(`foot${i}`, {
                            width: 0.4 * scale,
                            height: 0.1 * scale,
                            depth: 0.5 * scale
                        }, scene);
                        foot.position = new BABYLON.Vector3(
                            pos[0] * scale,
                            0.05 * scale,
                            pos[1] * scale
                        );
                        foot.parent = parent;
                    });

                    // Wings
                    if (hasWings) {
                        [-1, 1].forEach((side) => {
                            const wing = BABYLON.MeshBuilder.CreateBox(`wing${side}`, {
                                width: 0.1 * scale,
                                height: 1.2 * scale,
                                depth: 1.5 * scale
                            }, scene);
                            wing.position = new BABYLON.Vector3(side * 0.6 * scale, 1 * scale, 0);
                            wing.rotation.z = side * 0.3;
                            wing.parent = parent;
                        });
                    }

                    // Parent all meshes
                    [body, head, snout, tail].forEach(mesh => mesh.parent = parent);

                    // Apply material
                    const material = createColorMaterial(color);
                    parent.getChildMeshes().forEach(mesh => mesh.material = material);

                    return parent;
                }

                function createCreature(color, hasWings, scale) {
                    const parent = new BABYLON.TransformNode('creature');

                    // Body
                    const body = BABYLON.MeshBuilder.CreateSphere('body', {
                        diameter: 1.5 * scale
                    }, scene);
                    body.position.y = 0.75 * scale;

                    // Head
                    const head = BABYLON.MeshBuilder.CreateSphere('head', {
                        diameter: 1 * scale
                    }, scene);
                    head.position.y = 1.5 * scale;

                    // Eyes
                    [-0.25, 0.25].forEach((x) => {
                        const eye = BABYLON.MeshBuilder.CreateSphere('eye', {
                            diameter: 0.15 * scale
                        }, scene);
                        eye.position = new BABYLON.Vector3(x * scale, 1.6 * scale, 0.4 * scale);
                        const eyeMat = new BABYLON.StandardMaterial('eyeMat', scene);
                        eyeMat.diffuseColor = BABYLON.Color3.Black();
                        eyeMat.emissiveColor = new BABYLON.Color3(0.1, 0.1, 0.1);
                        eye.material = eyeMat;
                        eye.parent = parent;
                    });

                    // Legs
                    [-0.4, 0.4].forEach((x) => {
                        const leg = BABYLON.MeshBuilder.CreateCylinder('leg', {
                            diameter: 0.3 * scale,
                            height: 0.8 * scale
                        }, scene);
                        leg.position = new BABYLON.Vector3(x * scale, 0.4 * scale, 0);
                        leg.parent = parent;
                    });

                    // Wings
                    if (hasWings) {
                        [-1, 1].forEach((side) => {
                            const wing = BABYLON.MeshBuilder.CreateBox('wing', {
                                width: 0.1 * scale,
                                height: 1 * scale,
                                depth: 0.8 * scale
                            }, scene);
                            wing.position = new BABYLON.Vector3(side * 0.8 * scale, 1.2 * scale, -0.2 * scale);
                            wing.rotation.z = side * 0.4;
                            wing.parent = parent;
                        });
                    }

                    // Parent main meshes
                    [body, head].forEach(mesh => mesh.parent = parent);

                    // Apply material
                    const material = createColorMaterial(color);
                    parent.getChildMeshes().forEach(mesh => {
                        if (!mesh.material) {
                            mesh.material = material;
                        }
                    });

                    return parent;
                }

                function createColorMaterial(colorName) {
                    const material = new BABYLON.StandardMaterial('creatureMat', scene);

                    const colorMap = {
                        'purple': new BABYLON.Color3(0.6, 0.2, 0.8),
                        'red': new BABYLON.Color3(0.9, 0.2, 0.1),
                        'blue': new BABYLON.Color3(0.2, 0.4, 0.9),
                        'green': new BABYLON.Color3(0.2, 0.8, 0.3),
                        'yellow': new BABYLON.Color3(0.95, 0.9, 0.2),
                        'orange': new BABYLON.Color3(1, 0.6, 0.1),
                        'pink': new BABYLON.Color3(1, 0.4, 0.7),
                        'white': new BABYLON.Color3(0.95, 0.95, 0.95),
                        'black': new BABYLON.Color3(0.1, 0.1, 0.1),
                        'golden': new BABYLON.Color3(1, 0.84, 0),
                        'rainbow': new BABYLON.Color3(0.8, 0.4, 0.9),
                    };

                    material.diffuseColor = colorMap[colorName] || colorMap['purple'];
                    material.specularColor = new BABYLON.Color3(0.3, 0.3, 0.3);
                    material.specularPower = 32;

                    return material;
                }

                function addFlameEffect(parent) {
                    const particleSystem = new BABYLON.ParticleSystem('flames', 2000, scene);
                    particleSystem.particleTexture = new BABYLON.Texture('https://www.babylonjs-playground.com/textures/flare.png', scene);
                    particleSystem.emitter = parent.position;
                    particleSystem.minEmitBox = new BABYLON.Vector3(-0.3, 0, -0.3);
                    particleSystem.maxEmitBox = new BABYLON.Vector3(0.3, 0, 0.3);
                    particleSystem.color1 = new BABYLON.Color4(1, 0.5, 0, 1);
                    particleSystem.color2 = new BABYLON.Color4(1, 0.2, 0, 0.8);
                    particleSystem.colorDead = new BABYLON.Color4(0, 0, 0, 0);
                    particleSystem.minSize = 0.1;
                    particleSystem.maxSize = 0.3;
                    particleSystem.minLifeTime = 0.3;
                    particleSystem.maxLifeTime = 1.0;
                    particleSystem.emitRate = 500;
                    particleSystem.blendMode = BABYLON.ParticleSystem.BLENDMODE_ONEONE;
                    particleSystem.gravity = new BABYLON.Vector3(0, 2, 0);
                    particleSystem.direction1 = new BABYLON.Vector3(-0.5, 1, -0.5);
                    particleSystem.direction2 = new BABYLON.Vector3(0.5, 1, 0.5);
                    particleSystem.minEmitPower = 1;
                    particleSystem.maxEmitPower = 3;
                    particleSystem.updateSpeed = 0.01;
                    particleSystem.start();
                }

                function addGlowEffect(parent, color) {
                    const gl = new BABYLON.GlowLayer('glow', scene);
                    gl.intensity = 0.8;
                    parent.getChildMeshes().forEach(mesh => {
                        if (mesh.material) {
                            mesh.material.emissiveColor = mesh.material.diffuseColor.scale(0.3);
                        }
                    });
                }

            } catch (error) {
                console.error('Error initializing scene:', error);
                document.getElementById('loading').innerHTML =
                    '<div style="color: red;">Error loading 3D preview</div>';
                if (window.FlutterChannel) {
                    window.FlutterChannel.postMessage('Error: ' + error.message);
                }
            }
        }
    </script>
</body>
</html>
    ''';
  }

  String _generateEnvironment() {
    return '''
    // Ground
    const ground = BABYLON.MeshBuilder.CreateGround('ground', {
        width: 20,
        height: 20,
        subdivisions: 10
    }, scene);
    ground.position.y = 0;
    ground.receiveShadows = true;

    const groundMat = new BABYLON.StandardMaterial('groundMat', scene);
    groundMat.diffuseColor = new BABYLON.Color3(0.4, 0.7, 0.3);  // Grass green
    groundMat.specularColor = new BABYLON.Color3(0.1, 0.1, 0.1);
    groundMat.roughness = 0.8;

    // Add texture to ground (procedural)
    const groundTexture = new BABYLON.DynamicTexture('groundTexture', 512, scene);
    const ctx = groundTexture.getContext();
    ctx.fillStyle = '#4a7c3c';
    ctx.fillRect(0, 0, 512, 512);
    // Add some grass variation
    for (let i = 0; i < 5000; i++) {
        const x = Math.random() * 512;
        const y = Math.random() * 512;
        ctx.fillStyle = Math.random() > 0.5 ? '#5a8c4c' : '#3a6c2c';
        ctx.fillRect(x, y, 2, 2);
    }
    groundTexture.update();
    groundMat.diffuseTexture = groundTexture;
    ground.material = groundMat;

    // Sky dome
    const skybox = BABYLON.MeshBuilder.CreateSphere('skybox', {
        diameter: 100,
        sideOrientation: BABYLON.Mesh.BACKSIDE
    }, scene);

    const skyMat = new BABYLON.StandardMaterial('skyMat', scene);
    skyMat.backFaceCulling = false;

    // Create gradient sky texture
    const skyTexture = new BABYLON.DynamicTexture('skyTexture', 512, scene);
    const skyCtx = skyTexture.getContext();
    const gradient = skyCtx.createLinearGradient(0, 0, 0, 512);
    gradient.addColorStop(0, '#87CEEB');      // Sky blue
    gradient.addColorStop(0.5, '#E0F6FF');    // Light blue
    gradient.addColorStop(1, '#FFFFFF');      // White (horizon)
    skyCtx.fillStyle = gradient;
    skyCtx.fillRect(0, 0, 512, 512);
    skyTexture.update();

    skyMat.diffuseTexture = skyTexture;
    skyMat.emissiveTexture = skyTexture;
    skyMat.disableLighting = true;
    skybox.material = skyMat;
    skybox.infiniteDistance = true;

    // Add some clouds
    for (let i = 0; i < 5; i++) {
        const cloud = BABYLON.MeshBuilder.CreateBox('cloud' + i, {
            width: Math.random() * 2 + 1,
            height: 0.5,
            depth: Math.random() * 1.5 + 0.5
        }, scene);
        cloud.position = new BABYLON.Vector3(
            Math.random() * 20 - 10,
            Math.random() * 5 + 5,
            Math.random() * 20 - 10
        );

        const cloudMat = new BABYLON.StandardMaterial('cloudMat' + i, scene);
        cloudMat.diffuseColor = new BABYLON.Color3(1, 1, 1);
        cloudMat.alpha = 0.7;
        cloud.material = cloudMat;
    }
    ''';
  }

  String _generateSizeReference() {
    return '''
    // Minecraft block for size reference
    const referenceBlock = BABYLON.MeshBuilder.CreateBox('refBlock', {
        size: 1
    }, scene);
    referenceBlock.position = new BABYLON.Vector3(3, 0.5, 0);

    const blockMat = new BABYLON.StandardMaterial('blockMat', scene);
    blockMat.diffuseColor = new BABYLON.Color3(0.6, 0.4, 0.2);  // Dirt brown
    referenceBlock.material = blockMat;

    // Player reference (simplified Steve)
    const player = BABYLON.MeshBuilder.CreateBox('player', {
        width: 0.6,
        height: 1.8,
        depth: 0.3
    }, scene);
    player.position = new BABYLON.Vector3(-3, 0.9, 0);

    const playerMat = new BABYLON.StandardMaterial('playerMat', scene);
    playerMat.diffuseColor = new BABYLON.Color3(0.3, 0.5, 0.8);  // Blue shirt
    player.material = playerMat;

    // Player head
    const playerHead = BABYLON.MeshBuilder.CreateBox('playerHead', {
        size: 0.8
    }, scene);
    playerHead.position = new BABYLON.Vector3(-3, 2.2, 0);
    const headMat = new BABYLON.StandardMaterial('headMat', scene);
    headMat.diffuseColor = new BABYLON.Color3(0.95, 0.8, 0.7);  // Skin tone
    playerHead.material = headMat;
    ''';
  }

  @override
  Widget build(BuildContext context) {
    // Desktop fallback
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return _buildDesktopFallback();
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            if (_errorMessage == null)
              WebViewWidget(controller: _webViewController),
            if (_errorMessage != null)
              _buildErrorWidget(),
            if (_isLoading)
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF87CEEB), Color(0xFFE0F6FF)],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Loading 3D Preview...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
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

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '3D Preview Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopFallback() {
    final color = widget.creatureAttributes['color'] ?? 'purple';
    final type = widget.creatureAttributes['creatureType'] ?? 'creature';

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF87CEEB), Color(0xFFE0F6FF)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 100,
              color: _getColorFromString(color),
            ),
            const SizedBox(height: 24),
            Text(
              _capitalize(type),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Color: ${_capitalize(color)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorFromString(String color) {
    final colorMap = {
      'purple': Colors.purple,
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'pink': Colors.pink,
      'white': Colors.white,
      'black': Colors.black87,
      'golden': Colors.amber,
      'rainbow': Colors.purpleAccent,
    };
    return colorMap[color.toLowerCase()] ?? Colors.purple;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
