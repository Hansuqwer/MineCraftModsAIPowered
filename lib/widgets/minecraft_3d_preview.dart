import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'dart:convert';

/// Minecraft-style 3D preview widget using Babylon.js
/// Renders AI-generated models with custom textures and effects
class Minecraft3DPreview extends StatefulWidget {
  final Map<String, dynamic> creatureAttributes;
  final String modelPath;
  final String texturePath;
  final double size;
  final bool enableRotation;
  final bool enableZoom;
  final bool enableEffects;

  const Minecraft3DPreview({
    super.key,
    required this.creatureAttributes,
    required this.modelPath,
    required this.texturePath,
    this.size = 300.0,
    this.enableRotation = true,
    this.enableZoom = true,
    this.enableEffects = true,
  });

  @override
  State<Minecraft3DPreview> createState() => _Minecraft3DPreviewState();
}

class _Minecraft3DPreviewState extends State<Minecraft3DPreview> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _loadModel();
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _errorMessage = 'Failed to load 3D preview: ${error.description}';
              _isLoading = false;
            });
          },
        ),
      )
      ..loadHtmlString(_generateHTML());
  }

  String _generateHTML() {
    final creatureType = widget.creatureAttributes['creatureType'] ?? 'sword';
    final color = widget.creatureAttributes['color'] ?? 'golden';
    final effects = widget.creatureAttributes['effects'] ?? [];
    final hasFlames = effects.contains('flames') || effects.contains('fire');
    final hasGlow = effects.contains('glow') || effects.contains('magic');
    final hasWings = effects.contains('wings') || effects.contains('flying');

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Minecraft 3D Preview</title>
    <style>
        body { margin: 0; padding: 0; background: #87CEEB; overflow: hidden; }
        #renderCanvas { width: 100%; height: 100%; touch-action: none; }
        .loading { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); 
                   color: white; font-family: Arial; font-size: 18px; }
    </style>
</head>
<body>
    <div class="loading" id="loading">Loading 3D Preview...</div>
    <canvas id="renderCanvas"></canvas>
    
    <script src="https://cdn.babylonjs.com/babylon.js"></script>
    <script src="https://cdn.babylonjs.com/loaders/babylonjs.loaders.min.js"></script>
    <script src="https://cdn.babylonjs.com/materials/babylonjs.materials.min.js"></script>
    
    <script>
        // Minecraft-style 3D preview with Babylon.js
        const canvas = document.getElementById('renderCanvas');
        const engine = new BABYLON.Engine(canvas, true);
        const scene = new BABYLON.Scene(engine);
        
        // Minecraft-style lighting
        const light = new BABYLON.HemisphericLight('light', new BABYLON.Vector3(0, 1, 0), scene);
        light.intensity = 0.8;
        
        // Add directional light for better shadows
        const dirLight = new BABYLON.DirectionalLight('dirLight', new BABYLON.Vector3(-1, -1, -1), scene);
        dirLight.intensity = 0.5;
        
        // Camera setup
        const camera = new BABYLON.ArcRotateCamera('camera', 0, Math.PI / 3, 5, BABYLON.Vector3.Zero(), scene);
        camera.attachControls(canvas, true);
        camera.setTarget(BABYLON.Vector3.Zero());
        
        // Enable rotation and zoom
        camera.useBouncingBehavior = true;
        camera.useAutoRotationBehavior = true;
        camera.autoRotationBehavior.idleRotationSpeed = 0.5;
        camera.autoRotationBehavior.idleRotationWaitTime = 2000;
        camera.autoRotationBehavior.idleRotationSpinupTime = 2000;
        
        // Create ground plane (Minecraft-style)
        const ground = BABYLON.MeshBuilder.CreateGround('ground', {width: 10, height: 10}, scene);
        const groundMaterial = new BABYLON.StandardMaterial('groundMaterial', scene);
        groundMaterial.diffuseColor = new BABYLON.Color3(0.4, 0.6, 0.2); // Grass color
        groundMaterial.specularColor = new BABYLON.Color3(0, 0, 0);
        ground.material = groundMaterial;
        
        // Create Minecraft-style skybox
        const skybox = BABYLON.MeshBuilder.CreateBox('skybox', {size: 100}, scene);
        const skyboxMaterial = new BABYLON.StandardMaterial('skyboxMaterial', scene);
        skyboxMaterial.backFaceCulling = false;
        skyboxMaterial.diffuseColor = new BABYLON.Color3(0.5, 0.8, 1.0);
        skyboxMaterial.specularColor = new BABYLON.Color3(0, 0, 0);
        skybox.material = skyboxMaterial;
        skybox.infiniteDistance = true;
        
        // Create the 3D model based on creature attributes
        function createMinecraftModel() {
            const creatureType = '${creatureType}';
            const color = '${color}';
            const hasFlames = ${hasFlames};
            const hasGlow = ${hasGlow};
            const hasWings = ${hasWings};
            
            let model;
            
            // Create different models based on type
            if (creatureType.includes('sword') || creatureType.includes('weapon')) {
                model = createSword(color, hasFlames, hasGlow);
            } else if (creatureType.includes('dragon') || creatureType.includes('creature')) {
                model = createDragon(color, hasWings, hasFlames);
            } else if (creatureType.includes('furniture') || creatureType.includes('chair')) {
                model = createFurniture(creatureType, color);
            } else {
                model = createGenericCreature(creatureType, color, hasWings);
            }
            
            return model;
        }
        
        function createSword(color, hasFlames, hasGlow) {
            // Create sword blade
            const blade = BABYLON.MeshBuilder.CreateBox('blade', {width: 0.2, height: 2, depth: 0.1}, scene);
            const bladeMaterial = new BABYLON.StandardMaterial('bladeMaterial', scene);
            
            // Set color based on input
            if (color === 'golden' || color === 'gold') {
                bladeMaterial.diffuseColor = new BABYLON.Color3(1, 0.8, 0);
                bladeMaterial.emissiveColor = new BABYLON.Color3(0.2, 0.1, 0);
            } else if (color === 'diamond' || color === 'blue') {
                bladeMaterial.diffuseColor = new BABYLON.Color3(0.5, 0.8, 1);
                bladeMaterial.emissiveColor = new BABYLON.Color3(0.1, 0.2, 0.3);
            } else if (color === 'iron' || color === 'gray') {
                bladeMaterial.diffuseColor = new BABYLON.Color3(0.7, 0.7, 0.7);
            } else {
                bladeMaterial.diffuseColor = new BABYLON.Color3(0.8, 0.4, 0.2); // Default orange
            }
            
            blade.material = bladeMaterial;
            blade.position.y = 1;
            
            // Create handle
            const handle = BABYLON.MeshBuilder.CreateBox('handle', {width: 0.1, height: 0.8, depth: 0.1}, scene);
            const handleMaterial = new BABYLON.StandardMaterial('handleMaterial', scene);
            handleMaterial.diffuseColor = new BABYLON.Color3(0.4, 0.2, 0.1); // Brown
            handle.material = handleMaterial;
            handle.position.y = -0.4;
            
            // Create parent mesh
            const sword = BABYLON.MeshBuilder.CreateBox('sword', {width: 0.1, height: 0.1, depth: 0.1}, scene);
            sword.isVisible = false;
            blade.parent = sword;
            handle.parent = sword;
            
            // Add flame effects
            if (hasFlames) {
                addFlameEffect(sword, 'black');
            }
            
            // Add glow effect
            if (hasGlow) {
                addGlowEffect(sword);
            }
            
            return sword;
        }
        
        function createDragon(color, hasWings, hasFlames) {
            // Create dragon body
            const body = BABYLON.MeshBuilder.CreateSphere('body', {diameter: 1.5}, scene);
            const bodyMaterial = new BABYLON.StandardMaterial('bodyMaterial', scene);
            
            if (color === 'red' || color === 'fire') {
                bodyMaterial.diffuseColor = new BABYLON.Color3(0.8, 0.2, 0.1);
            } else if (color === 'blue' || color === 'ice') {
                bodyMaterial.diffuseColor = new BABYLON.Color3(0.2, 0.4, 0.8);
            } else if (color === 'green') {
                bodyMaterial.diffuseColor = new BABYLON.Color3(0.2, 0.8, 0.2);
            } else {
                bodyMaterial.diffuseColor = new BABYLON.Color3(0.8, 0.6, 0.2); // Default gold
            }
            
            body.material = bodyMaterial;
            body.position.y = 0.5;
            
            // Create head
            const head = BABYLON.MeshBuilder.CreateSphere('head', {diameter: 0.8}, scene);
            head.material = bodyMaterial;
            head.position.y = 1.2;
            head.position.z = 0.3;
            head.parent = body;
            
            // Create wings
            if (hasWings) {
                const leftWing = BABYLON.MeshBuilder.CreateBox('leftWing', {width: 0.1, height: 1.5, depth: 0.8}, scene);
                leftWing.material = bodyMaterial;
                leftWing.position.x = -0.8;
                leftWing.position.y = 0.8;
                leftWing.rotation.z = 0.3;
                leftWing.parent = body;
                
                const rightWing = BABYLON.MeshBuilder.CreateBox('rightWing', {width: 0.1, height: 1.5, depth: 0.8}, scene);
                rightWing.material = bodyMaterial;
                rightWing.position.x = 0.8;
                rightWing.position.y = 0.8;
                rightWing.rotation.z = -0.3;
                rightWing.parent = body;
            }
            
            // Add flame effects
            if (hasFlames) {
                addFlameEffect(body, color);
            }
            
            return body;
        }
        
        function createFurniture(type, color) {
            let furniture;
            
            if (type.includes('chair')) {
                // Create chair
                const seat = BABYLON.MeshBuilder.CreateBox('seat', {width: 1, height: 0.2, depth: 1}, scene);
                const back = BABYLON.MeshBuilder.CreateBox('back', {width: 1, height: 1, depth: 0.2}, scene);
                const leg1 = BABYLON.MeshBuilder.CreateBox('leg1', {width: 0.1, height: 0.8, depth: 0.1}, scene);
                const leg2 = BABYLON.MeshBuilder.CreateBox('leg2', {width: 0.1, height: 0.8, depth: 0.1}, scene);
                const leg3 = BABYLON.MeshBuilder.CreateBox('leg3', {width: 0.1, height: 0.8, depth: 0.1}, scene);
                const leg4 = BABYLON.MeshBuilder.CreateBox('leg4', {width: 0.1, height: 0.8, depth: 0.1}, scene);
                
                seat.position.y = 0.4;
                back.position.y = 0.9;
                back.position.z = -0.4;
                leg1.position.set(-0.4, 0, -0.4);
                leg2.position.set(0.4, 0, -0.4);
                leg3.position.set(-0.4, 0, 0.4);
                leg4.position.set(0.4, 0, 0.4);
                
                furniture = BABYLON.MeshBuilder.CreateBox('chair', {width: 0.1, height: 0.1, depth: 0.1}, scene);
                furniture.isVisible = false;
                seat.parent = furniture;
                back.parent = furniture;
                leg1.parent = furniture;
                leg2.parent = furniture;
                leg3.parent = furniture;
                leg4.parent = furniture;
            } else {
                // Generic furniture
                furniture = BABYLON.MeshBuilder.CreateBox('furniture', {width: 1, height: 1, depth: 1}, scene);
            }
            
            // Apply color
            const material = new BABYLON.StandardMaterial('furnitureMaterial', scene);
            if (color === 'wood' || color === 'brown') {
                material.diffuseColor = new BABYLON.Color3(0.6, 0.4, 0.2);
            } else if (color === 'white') {
                material.diffuseColor = new BABYLON.Color3(0.9, 0.9, 0.9);
            } else {
                material.diffuseColor = new BABYLON.Color3(0.5, 0.5, 0.5);
            }
            
            furniture.material = material;
            
            return furniture;
        }
        
        function createGenericCreature(type, color, hasWings) {
            // Create basic creature
            const body = BABYLON.MeshBuilder.CreateSphere('creatureBody', {diameter: 1}, scene);
            const material = new BABYLON.StandardMaterial('creatureMaterial', scene);
            
            // Set color
            if (color === 'rainbow') {
                material.diffuseColor = new BABYLON.Color3(1, 0.5, 0.5);
            } else if (color === 'blue') {
                material.diffuseColor = new BABYLON.Color3(0.2, 0.4, 0.8);
            } else {
                material.diffuseColor = new BABYLON.Color3(0.8, 0.6, 0.2);
            }
            
            body.material = material;
            
            // Add wings if specified
            if (hasWings) {
                const leftWing = BABYLON.MeshBuilder.CreateBox('leftWing', {width: 0.1, height: 1, depth: 0.5}, scene);
                leftWing.material = material;
                leftWing.position.x = -0.6;
                leftWing.position.y = 0.3;
                leftWing.parent = body;
                
                const rightWing = BABYLON.MeshBuilder.CreateBox('rightWing', {width: 0.1, height: 1, depth: 0.5}, scene);
                rightWing.material = material;
                rightWing.position.x = 0.6;
                rightWing.position.y = 0.3;
                rightWing.parent = body;
            }
            
            return body;
        }
        
        function addFlameEffect(parent, flameColor) {
            // Create flame particles
            const particleSystem = new BABYLON.ParticleSystem('flames', 2000, scene);
            particleSystem.particleTexture = new BABYLON.Texture('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==', scene);
            
            particleSystem.emitter = parent;
            particleSystem.minEmitBox = new BABYLON.Vector3(-0.1, 0, -0.1);
            particleSystem.maxEmitBox = new BABYLON.Vector3(0.1, 0, 0.1);
            
            particleSystem.color1 = flameColor === 'black' ? new BABYLON.Color4(0.1, 0.1, 0.1, 1) : new BABYLON.Color4(1, 0.3, 0, 1);
            particleSystem.color2 = flameColor === 'black' ? new BABYLON.Color4(0.2, 0.2, 0.2, 0.8) : new BABYLON.Color4(1, 0.6, 0, 0.8);
            particleSystem.colorDead = new BABYLON.Color4(0, 0, 0, 0);
            
            particleSystem.minSize = 0.1;
            particleSystem.maxSize = 0.3;
            particleSystem.minLifeTime = 0.3;
            particleSystem.maxLifeTime = 1.0;
            particleSystem.emitRate = 1000;
            particleSystem.gravity = new BABYLON.Vector3(0, -2, 0);
            particleSystem.direction1 = new BABYLON.Vector3(-0.5, 1, -0.5);
            particleSystem.direction2 = new BABYLON.Vector3(0.5, 1, 0.5);
            particleSystem.minAngularSpeed = 0;
            particleSystem.maxAngularSpeed = Math.PI;
            particleSystem.minEmitPower = 1;
            particleSystem.maxEmitPower = 3;
            particleSystem.updateSpeed = 0.025;
            
            particleSystem.start();
        }
        
        function addGlowEffect(parent) {
            // Add emissive glow
            if (parent.material) {
                parent.material.emissiveColor = new BABYLON.Color3(0.2, 0.2, 0.2);
            }
        }
        
        // Load the model
        function loadModel() {
            try {
                const model = createMinecraftModel();
                if (model) {
                    // Hide loading
                    document.getElementById('loading').style.display = 'none';
                    
                    // Start render loop
                    engine.runRenderLoop(() => {
                        scene.render();
                    });
                    
                    // Handle window resize
                    window.addEventListener('resize', () => {
                        engine.resize();
                    });
                }
            } catch (error) {
                console.error('Error creating model:', error);
                document.getElementById('loading').innerHTML = 'Error loading 3D preview';
            }
        }
        
        // Start the preview
        loadModel();
    </script>
</body>
</html>
    ''';
  }

  void _loadModel() {
    // Additional model loading logic can be added here
    // For now, the HTML handles everything
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(
                '3D Preview Error',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (_isLoading)
              Container(
                color: const Color(0xFF87CEEB), // Minecraft sky color
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading 3D Preview...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
