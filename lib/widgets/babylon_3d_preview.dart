import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:io';

/// 🎨 Babylon.js 3D Preview Widget
///
/// Shows real 3D rotating models of Minecraft items
/// - Swords, helmets, dragons, chairs, etc.
/// - Touch to rotate/zoom
/// - Glow effects
/// - Requires online connectivity (CDN loading)
/// - FREE forever
///
/// This is MUCH better than:
/// - 2D emoji placeholders (boring)
/// - OAuth/Vertex AI ($$$)
/// - Complex setup
class Babylon3DPreview extends StatefulWidget {
  final Map<String, dynamic> creatureAttributes;
  final double height;

  const Babylon3DPreview({
    super.key,
    required this.creatureAttributes,
    this.height = 300,
  });

  @override
  State<Babylon3DPreview> createState() => _Babylon3DPreviewState();
}

class _Babylon3DPreviewState extends State<Babylon3DPreview> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasNetworkError = false;

  @override
  void initState() {
    super.initState();
    _checkNetworkAndInitialize();
  }

  Future<void> _checkNetworkAndInitialize() async {
    // Initialize WebView directly - no network check needed
    _initializeWebView();
  }

  void _initializeWebView() async {
    print('🎨 [BABYLON] Initializing 3D preview...');

    // Add timeout to prevent hanging forever
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _isLoading) {
        print('⏱️ [BABYLON] Loading timeout - dismissing loading indicator');
        setState(() {
          _isLoading = false;
        });
      }
    });

    // Extract attributes
    print('🔍 [BABYLON] Received creatureAttributes: ${widget.creatureAttributes}');
    final type = widget.creatureAttributes['creatureType'] ??
                 widget.creatureAttributes['baseType'] ??
                 'cube';
    final color = widget.creatureAttributes['color'] ?? 'blue';
    final size = widget.creatureAttributes['size'] ?? 'medium';
    print('🔍 [BABYLON] Extracted - type: $type, color: $color, size: $size');

    // Detect glow
    String glow = 'none';
    final customName = (widget.creatureAttributes['customName'] ?? '').toLowerCase();
    if (customName.contains('glow')) {
      glow = 'bright';
    } else if (customName.contains('shimmer') || customName.contains('sparkle')) {
      glow = 'soft';
    }

    print('🔍 [BABYLON] Type: $type, Color: $color, Size: $size, Glow: $glow');

    // Use embedded HTML with dynamic attributes
    _initializeWebViewWithHTML();
  }

  void _initializeWebViewWithHTML() async {
    print('🎨 [BABYLON] Initializing 3D preview with embedded HTML...');

    // Add timeout to prevent hanging forever
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _isLoading) {
        print('⏱️ [BABYLON] Loading timeout - dismissing loading indicator');
        setState(() {
          _isLoading = false;
        });
      }
    });

    // Extract attributes
    print('🔍 [BABYLON] Received creatureAttributes: ${widget.creatureAttributes}');
    final type = widget.creatureAttributes['creatureType'] ??
                 widget.creatureAttributes['baseType'] ??
                 'cube';
    final color = widget.creatureAttributes['color'] ?? 'blue';
    final size = widget.creatureAttributes['size'] ?? 'medium';
    print('🔍 [BABYLON] Extracted - type: $type, color: $color, size: $size');

    // Detect glow
    String glow = 'none';
    final customName = (widget.creatureAttributes['customName'] ?? '').toLowerCase();
    if (customName.contains('glow')) {
      glow = 'bright';
    } else if (customName.contains('shimmer') || customName.contains('sparkle')) {
      glow = 'soft';
    }

    print('🔍 [BABYLON] Type: $type, Color: $color, Size: $size, Glow: $glow');

    // Create HTML with parameters embedded (properly escaped)
    final html = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <title>3D Preview</title>
    <style>
        html, body {
            width: 100%;
            height: 100%;
            margin: 0;
            padding: 0;
            overflow: hidden;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        #renderCanvas {
            width: 100%;
            height: 100%;
            touch-action: none;
        }
    </style>
    <script src="https://cdn.babylonjs.com/babylon.js" onerror="loadFallbackBabylon()"></script>
    <script>
        function loadFallbackBabylon() {
            console.log('⚠️ [BABYLON] Primary CDN failed, trying fallback...');
            const script = document.createElement('script');
            script.src = 'https://cdnjs.cloudflare.com/ajax/libs/babylonjs/6.0.0/babylon.js';
            script.onerror = function() {
                console.log('❌ [BABYLON] All CDNs failed, using offline mode');
                createOfflinePreview();
            };
            script.onload = function() {
                console.log('✅ [BABYLON] Fallback CDN loaded successfully');
                initializeBabylon();
            };
            document.head.appendChild(script);
        }
        
        function createOfflinePreview() {
            console.log('🔄 [BABYLON] Creating offline preview...');
            const canvas = document.getElementById("renderCanvas");
            const ctx = canvas.getContext("2d");
            
            // Create a simple 2D preview
            ctx.fillStyle = "#1a1a2e";
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            
            ctx.fillStyle = "#ff6b6b";
            ctx.font = "24px Arial";
            ctx.textAlign = "center";
            ctx.fillText("🐉 " + itemType.toUpperCase(), canvas.width/2, canvas.height/2 - 20);
            ctx.fillText(itemColor.toUpperCase() + " COLOR", canvas.width/2, canvas.height/2 + 20);
            ctx.fillText("3D Preview Offline", canvas.width/2, canvas.height/2 + 50);
        }
    </script>
</head>
<body>
    <canvas id="renderCanvas"></canvas>
    <script>
        const itemType = "${type.replaceAll('"', '\\"')}";
        const itemColor = "${color.replaceAll('"', '\\"')}";
        const itemGlow = "${glow.replaceAll('"', '\\"')}";
        const itemSize = "${size.replaceAll('"', '\\"')}";

        // Debug logging
        console.log('🔍 [BABYLON] JavaScript received:');
        console.log('   itemType:', itemType);
        console.log('   itemColor:', itemColor);
        console.log('   itemGlow:', itemGlow);
        console.log('   itemSize:', itemSize);
        console.log('   Type contains dragon:', itemType.toLowerCase().includes('dragon'));

        function initializeBabylon() {
            console.log('🎨 [BABYLON] Initializing Babylon.js...');
            const canvas = document.getElementById("renderCanvas");
            const engine = new BABYLON.Engine(canvas, true);
            const scene = new BABYLON.Scene(engine);
        scene.clearColor = new BABYLON.Color4(0, 0, 0, 0);

        // Camera (arc rotate for touch/mouse rotation)
        const camera = new BABYLON.ArcRotateCamera(
            "camera",
            Math.PI / 4,
            Math.PI / 3,
            5,
            BABYLON.Vector3.Zero(),
            scene
        );
        camera.attachControl(canvas, true);
        camera.lowerRadiusLimit = 3;
        camera.upperRadiusLimit = 10;
        camera.wheelPrecision = 50;

        // Lighting (optimized for mobile)
        const light1 = new BABYLON.HemisphericLight(
            "light1",
            new BABYLON.Vector3(0, 1, 0),
            scene
        );
        light1.intensity = 0.7;

        const light2 = new BABYLON.PointLight(
            "light2",
            new BABYLON.Vector3(2, 3, 2),
            scene
        );
        light2.intensity = 0.5;

        // Color mapping function
        function getColor(colorName) {
            const colors = {
                'black': new BABYLON.Color3(0.1, 0.1, 0.1),
                'white': new BABYLON.Color3(0.95, 0.95, 0.95),
                'red': new BABYLON.Color3(0.9, 0.1, 0.1),
                'blue': new BABYLON.Color3(0.1, 0.4, 0.9),
                'green': new BABYLON.Color3(0.1, 0.8, 0.1),
                'yellow': new BABYLON.Color3(0.95, 0.9, 0.1),
                'purple': new BABYLON.Color3(0.6, 0.2, 0.8),
                'pink': new BABYLON.Color3(0.9, 0.4, 0.7),
                'orange': new BABYLON.Color3(0.9, 0.5, 0.1),
                'brown': new BABYLON.Color3(0.4, 0.25, 0.1),
                'gold': new BABYLON.Color3(1.0, 0.84, 0.0),
                'golden': new BABYLON.Color3(1.0, 0.84, 0.0),
                'silver': new BABYLON.Color3(0.75, 0.75, 0.75),
            };
            return colors[colorName.toLowerCase()] || colors['blue'];
        }

        // Glow effect function
        function applyGlow(mesh, glowType, color) {
            if (glowType === 'none') return;

            const glowLayer = new BABYLON.GlowLayer("glow", mesh.getScene());
            glowLayer.intensity = 1.0;

            if (glowType === 'white' || glowType === 'bright') {
                mesh.material.emissiveColor = new BABYLON.Color3(1, 1, 1);
            } else if (glowType === 'soft') {
                mesh.material.emissiveColor = color.scale(0.3);
            } else if (glowType === 'pulsing') {
                mesh.material.emissiveColor = color.scale(0.5);
                scene.registerBeforeRender(() => {
                    const pulse = (Math.sin(Date.now() * 0.002) + 1) * 0.5;
                    glowLayer.intensity = 0.5 + pulse * 0.5;
                });
            }
        }

        // Create sword (blade + handle + guard)
        function createSword(scene, colorName, glow, scale) {
            const color = getColor(colorName);

            const blade = BABYLON.MeshBuilder.CreateBox("blade", {
                width: 0.2 * scale,
                height: 2.5 * scale,
                depth: 0.1 * scale
            }, scene);
            blade.position.y = 0;
            blade.rotation.z = Math.PI / 6;

            const handle = BABYLON.MeshBuilder.CreateCylinder("handle", {
                diameter: 0.2 * scale,
                height: 0.6 * scale
            }, scene);
            handle.position.y = -1.5 * scale;
            handle.rotation.z = Math.PI / 6;

            const guard = BABYLON.MeshBuilder.CreateBox("guard", {
                width: 0.8 * scale,
                height: 0.1 * scale,
                depth: 0.1 * scale
            }, scene);
            guard.position.y = -1.2 * scale;
            guard.rotation.z = Math.PI / 6;

            const bladeMat = new BABYLON.StandardMaterial("bladeMat", scene);
            bladeMat.diffuseColor = color;
            bladeMat.specularColor = new BABYLON.Color3(0.8, 0.8, 0.8);
            blade.material = bladeMat;

            const handleMat = new BABYLON.StandardMaterial("handleMat", scene);
            handleMat.diffuseColor = new BABYLON.Color3(0.3, 0.2, 0.1);
            handle.material = handleMat;
            guard.material = handleMat;

            const sword = BABYLON.Mesh.MergeMeshes([blade, handle, guard], true, true);
            sword.name = "sword";

            applyGlow(sword, glow, color);

            scene.registerBeforeRender(() => {
                sword.rotation.y += 0.01;
            });
        }

        // Create helmet (dome + visor)
        function createHelmet(scene, colorName, glow, scale) {
            const color = getColor(colorName);

            const dome = BABYLON.MeshBuilder.CreateSphere("dome", {
                diameter: 1.5 * scale,
                segments: 16
            }, scene);
            dome.position.y = 0.2 * scale;
            dome.scaling.y = 0.8;

            const visor = BABYLON.MeshBuilder.CreateBox("visor", {
                width: 1.2 * scale,
                height: 0.3 * scale,
                depth: 0.1 * scale
            }, scene);
            visor.position.y = 0 * scale;
            visor.position.z = 0.7 * scale;

            const helmetMat = new BABYLON.StandardMaterial("helmetMat", scene);
            helmetMat.diffuseColor = color;
            helmetMat.specularColor = new BABYLON.Color3(0.5, 0.5, 0.5);
            dome.material = helmetMat;
            visor.material = helmetMat;

            const helmet = BABYLON.Mesh.MergeMeshes([dome, visor], true, true);
            helmet.name = "helmet";

            applyGlow(helmet, glow, color);

            scene.registerBeforeRender(() => {
                helmet.rotation.y += 0.01;
            });
        }

        // Create detailed dragon model (enhanced procedural)
        function loadDragonModel(scene, colorName, glow, scale) {
            console.log('🐉 [BABYLON] Creating detailed dragon model');
            console.log('   - Color:', colorName);
            console.log('   - Glow:', glow);
            console.log('   - Scale:', scale);
            
            // Use the enhanced procedural dragon
            createDragon(scene, colorName, glow, scale);
        }

        // Create realistic dragon (Minecraft-style blocky dragon with green scales)
        function createDragon(scene, colorName, glow, scale) {
            const color = getColor(colorName);
            
            console.log('🐉 [BABYLON] Creating detailed dragon model');
            console.log('   - Color:', colorName);
            console.log('   - Glow:', glow);
            console.log('   - Scale:', scale);

            // Main body (larger, more dragon-like)
            const body = BABYLON.MeshBuilder.CreateBox("body", {
                width: 2.5 * scale,
                height: 2.5 * scale,
                depth: 4 * scale
            }, scene);
            body.position.y = 1.2 * scale;

            // Dragon head (more detailed with snout)
            const head = BABYLON.MeshBuilder.CreateBox("head", {
                width: 2 * scale,
                height: 2 * scale,
                depth: 2 * scale
            }, scene);
            head.position.y = 2.5 * scale;
            head.position.z = -2 * scale;

            // Dragon snout (extended nose)
            const snout = BABYLON.MeshBuilder.CreateBox("snout", {
                width: 1 * scale,
                height: 0.8 * scale,
                depth: 1.2 * scale
            }, scene);
            snout.position.y = 2.5 * scale;
            snout.position.z = -2.8 * scale;

            // Dragon horns (small pointed horns on head)
            const leftHorn = BABYLON.MeshBuilder.CreateBox("leftHorn", {
                width: 0.2 * scale,
                height: 0.4 * scale,
                depth: 0.2 * scale
            }, scene);
            leftHorn.position.x = -0.4 * scale;
            leftHorn.position.y = 2.6 * scale;
            leftHorn.position.z = -1.2 * scale;

            const rightHorn = BABYLON.MeshBuilder.CreateBox("rightHorn", {
                width: 0.2 * scale,
                height: 0.4 * scale,
                depth: 0.2 * scale
            }, scene);
            rightHorn.position.x = 0.4 * scale;
            rightHorn.position.y = 2.6 * scale;
            rightHorn.position.z = -1.2 * scale;

            // Dragon wings (larger, more imposing)
            const leftWing = BABYLON.MeshBuilder.CreateBox("leftWing", {
                width: 4 * scale,
                height: 0.3 * scale,
                depth: 3 * scale
            }, scene);
            leftWing.position.x = -2 * scale;
            leftWing.position.y = 2.5 * scale;
            leftWing.position.z = 0 * scale;

            const rightWing = BABYLON.MeshBuilder.CreateBox("rightWing", {
                width: 4 * scale,
                height: 0.3 * scale,
                depth: 3 * scale
            }, scene);
            rightWing.position.x = 2 * scale;
            rightWing.position.y = 2.5 * scale;
            rightWing.position.z = 0 * scale;

            // Dragon tail (segmented, longer)
            const tail1 = BABYLON.MeshBuilder.CreateBox("tail1", {
                width: 1 * scale,
                height: 1 * scale,
                depth: 1.5 * scale
            }, scene);
            tail1.position.y = 1.5 * scale;
            tail1.position.z = 2.5 * scale;

            const tail2 = BABYLON.MeshBuilder.CreateBox("tail2", {
                width: 0.8 * scale,
                height: 0.8 * scale,
                depth: 1.2 * scale
            }, scene);
            tail2.position.y = 1.3 * scale;
            tail2.position.z = 3.8 * scale;

            const tail3 = BABYLON.MeshBuilder.CreateBox("tail3", {
                width: 0.6 * scale,
                height: 0.6 * scale,
                depth: 1 * scale
            }, scene);
            tail3.position.y = 1.1 * scale;
            tail3.position.z = 4.8 * scale;

            // Dragon legs (four legs for stability)
            const leg1 = BABYLON.MeshBuilder.CreateBox("leg1", {
                width: 0.5 * scale,
                height: 1.5 * scale,
                depth: 0.5 * scale
            }, scene);
            leg1.position.x = -0.7 * scale;
            leg1.position.y = 0.25 * scale;
            leg1.position.z = -1 * scale;

            const leg2 = BABYLON.MeshBuilder.CreateBox("leg2", {
                width: 0.5 * scale,
                height: 1.5 * scale,
                depth: 0.5 * scale
            }, scene);
            leg2.position.x = 0.7 * scale;
            leg2.position.y = 0.25 * scale;
            leg2.position.z = -1 * scale;

            const leg3 = BABYLON.MeshBuilder.CreateBox("leg3", {
                width: 0.5 * scale,
                height: 1.5 * scale,
                depth: 0.5 * scale
            }, scene);
            leg3.position.x = -0.7 * scale;
            leg3.position.y = 0.25 * scale;
            leg3.position.z = 1 * scale;

            const leg4 = BABYLON.MeshBuilder.CreateBox("leg4", {
                width: 0.5 * scale,
                height: 1.5 * scale,
                depth: 0.5 * scale
            }, scene);
            leg4.position.x = 0.7 * scale;
            leg4.position.y = 0.25 * scale;
            leg4.position.z = 1 * scale;

            // Glowing red eyes (smaller, more intense)
            const leftEye = BABYLON.MeshBuilder.CreateBox("leftEye", {
                width: 0.15 * scale,
                height: 0.15 * scale,
                depth: 0.15 * scale
            }, scene);
            leftEye.position.x = -0.3 * scale;
            leftEye.position.y = 2.2 * scale;
            leftEye.position.z = -2.2 * scale;

            const rightEye = BABYLON.MeshBuilder.CreateBox("rightEye", {
                width: 0.15 * scale,
                height: 0.15 * scale,
                depth: 0.15 * scale
            }, scene);
            rightEye.position.x = 0.3 * scale;
            rightEye.position.y = 2.2 * scale;
            rightEye.position.z = -2.2 * scale;

            // Dragon material (dark with metallic sheen)
            const dragonMat = new BABYLON.StandardMaterial("dragonMat", scene);
            dragonMat.diffuseColor = color;
            dragonMat.specularColor = new BABYLON.Color3(0.4, 0.4, 0.4);
            dragonMat.metallicFactor = 0.3;
            dragonMat.roughnessFactor = 0.7;

            // Green scale material for accents
            const scaleMat = new BABYLON.StandardMaterial("scaleMat", scene);
            scaleMat.diffuseColor = new BABYLON.Color3(0, 0.8, 0); // Bright green
            scaleMat.specularColor = new BABYLON.Color3(0.2, 0.8, 0.2);
            scaleMat.metallicFactor = 0.4;
            scaleMat.roughnessFactor = 0.6;

            // Eye material (intensely glowing red)
            const eyeMat = new BABYLON.StandardMaterial("eyeMat", scene);
            eyeMat.diffuseColor = new BABYLON.Color3(1, 0, 0);
            eyeMat.emissiveColor = new BABYLON.Color3(1, 0, 0); // Very bright red glow

            // Apply materials
            body.material = dragonMat;
            head.material = dragonMat;
            snout.material = dragonMat;
            leftHorn.material = dragonMat;
            rightHorn.material = dragonMat;
            leftWing.material = dragonMat;
            rightWing.material = dragonMat;
            tail1.material = dragonMat;
            tail2.material = scaleMat; // Green scales on tail
            tail3.material = scaleMat; // Green scales on tail tip
            leg1.material = dragonMat;
            leg2.material = dragonMat;
            leg3.material = dragonMat;
            leg4.material = dragonMat;
            leftEye.material = eyeMat;
            rightEye.material = eyeMat;

            // Merge all parts into one dragon
            const dragon = BABYLON.Mesh.MergeMeshes([
                body, head, snout, leftHorn, rightHorn,
                leftWing, rightWing, tail1, tail2, tail3,
                leg1, leg2, leg3, leg4, leftEye, rightEye
            ], true, true);
            dragon.name = "dragon";

            applyGlow(dragon, glow, color);

            scene.registerBeforeRender(() => {
                dragon.rotation.y += 0.01;
            });
        }

        // Create chair (seat + back + 4 legs)
        function createChair(scene, colorName, glow, scale) {
            const color = getColor(colorName);

            const seat = BABYLON.MeshBuilder.CreateBox("seat", {
                width: 1.0 * scale,
                height: 0.2 * scale,
                depth: 1.0 * scale
            }, scene);
            seat.position.y = 0;

            const back = BABYLON.MeshBuilder.CreateBox("back", {
                width: 1.0 * scale,
                height: 1.2 * scale,
                depth: 0.2 * scale
            }, scene);
            back.position.y = 0.5 * scale;
            back.position.z = -0.4 * scale;

            const legPositions = [
                {x: -0.4 * scale, z: 0.4 * scale},
                {x: 0.4 * scale, z: 0.4 * scale},
                {x: -0.4 * scale, z: -0.4 * scale},
                {x: 0.4 * scale, z: -0.4 * scale}
            ];

            const legs = [];
            legPositions.forEach((pos, i) => {
                const leg = BABYLON.MeshBuilder.CreateCylinder("leg" + i, {
                    diameter: 0.15 * scale,
                    height: 0.8 * scale
                }, scene);
                leg.position.x = pos.x;
                leg.position.y = -0.5 * scale;
                leg.position.z = pos.z;
                legs.push(leg);
            });

            const chairMat = new BABYLON.StandardMaterial("chairMat", scene);
            chairMat.diffuseColor = color;
            seat.material = chairMat;
            back.material = chairMat;
            legs.forEach(leg => leg.material = chairMat);

            const chair = BABYLON.Mesh.MergeMeshes([seat, back].concat(legs), true, true);
            chair.name = "chair";

            applyGlow(chair, glow, color);

            scene.registerBeforeRender(() => {
                chair.rotation.y += 0.01;
            });
        }

        // Create cube (default fallback)
        function createCube(scene, colorName, glow, scale) {
            const color = getColor(colorName);

            const cube = BABYLON.MeshBuilder.CreateBox("cube", {
                size: 1.5 * scale
            }, scene);

            const cubeMat = new BABYLON.StandardMaterial("cubeMat", scene);
            cubeMat.diffuseColor = color;
            cube.material = cubeMat;

            applyGlow(cube, glow, color);

            scene.registerBeforeRender(() => {
                cube.rotation.y += 0.01;
                cube.rotation.x += 0.005;
            });
        }

        // Main item creation dispatcher
        function createItem(scene, type, color, glow, size) {
            const lowerType = type.toLowerCase();

            // Scale multiplier based on size
            let scale = 1.0;
            if (size === 'tiny') scale = 0.5;
            else if (size === 'small') scale = 0.75;
            else if (size === 'large') scale = 1.5;
            else if (size === 'giant') scale = 2.0;

            // Create based on type
            if (lowerType.includes('sword')) {
                createSword(scene, color, glow, scale);
            } else if (lowerType.includes('helmet') || lowerType.includes('armor')) {
                createHelmet(scene, color, glow, scale);
            } else if (lowerType.includes('dragon')) {
                loadDragonModel(scene, color, glow, scale);
            } else if (lowerType.includes('chair') || lowerType.includes('furniture')) {
                createChair(scene, color, glow, scale);
            } else {
                createCube(scene, color, glow, scale);
            }
        }

        // Create the 3D item
        createItem(scene, itemType, itemColor, itemGlow, itemSize);

        // Start render loop
        engine.runRenderLoop(() => {
            scene.render();
        });

        window.addEventListener("resize", () => {
            engine.resize();
        });

            console.log("✅ 3D preview ready:", itemType, itemColor, itemGlow, itemSize);
        }

        // Initialize Babylon.js when loaded
        if (typeof BABYLON !== 'undefined') {
            console.log('✅ [BABYLON] Babylon.js already loaded, initializing...');
            initializeBabylon();
        } else {
            console.log('⏳ [BABYLON] Waiting for Babylon.js to load...');
            window.addEventListener('load', function() {
                if (typeof BABYLON !== 'undefined') {
                    initializeBabylon();
                } else {
                    console.log('❌ [BABYLON] Babylon.js failed to load, using offline mode');
                    createOfflinePreview();
                }
            });
        }
    </script>
</body>
</html>
''';

    print('🌐 [BABYLON] Loading HTML with embedded parameters');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('🔄 [BABYLON] Page started loading...');
          },
          onPageFinished: (String url) {
            print('✅ [BABYLON] Page loaded successfully!');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ [BABYLON] Error: ${error.description}');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
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
            if (!_hasNetworkError) WebViewWidget(controller: _controller),

            // Network error indicator
            if (_hasNetworkError)
              Container(
                color: const Color(0xFF1a1a2e),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off,
                        size: 48,
                        color: Colors.red,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Internet Required',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please check your connection\nand try again',
                        style: TextStyle(
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
            if (_isLoading && !_hasNetworkError)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '✨ Loading 3D preview...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '(Requires internet connection)',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Touch hint (shows briefly)
            if (!_isLoading && !_hasNetworkError)
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
          ],
        ),
      ),
    );
  }
}
