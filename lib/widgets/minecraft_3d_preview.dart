import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;

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
    // Skip WebView initialization on desktop platforms
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
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
    final size = widget.creatureAttributes['size'] ?? 'normal';
    final abilities = widget.creatureAttributes['abilities'] ?? [];
    final personality = widget.creatureAttributes['personality'] ?? 'friendly';

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
            const size = '${size}';
            const abilities = ${abilities};
            const personality = '${personality}';
            
            let model;
            
            // Create different models based on type - EXACTLY as they will appear in Minecraft
            if (creatureType.includes('sword') || creatureType.includes('weapon') || creatureType.includes('fish')) {
                model = createMinecraftSword(color, hasFlames, hasGlow, size);
            } else if (creatureType.includes('dragon') || creatureType.includes('creature')) {
                model = createMinecraftDragon(color, hasWings, hasFlames, size);
            } else if (creatureType.includes('furniture') || creatureType.includes('chair') || creatureType.includes('couch')) {
                model = createMinecraftFurniture(creatureType, color, size);
            } else if (creatureType.includes('armor') || creatureType.includes('helmet')) {
                model = createMinecraftArmor(creatureType, color, hasGlow, size);
            } else if (creatureType.includes('tool') || creatureType.includes('pickaxe')) {
                model = createMinecraftTool(creatureType, color, hasGlow, size);
            } else {
                model = createMinecraftCreature(creatureType, color, hasWings, size);
            }
            
            return model;
        }
        
        function createMinecraftSword(color, hasFlames, hasGlow, size) {
            // Create Minecraft-accurate sword with proper proportions
            const scale = size === 'giant' ? 2.0 : size === 'tiny' ? 0.5 : 1.0;

            // Create sword blade (Minecraft sword proportions)
            const blade = BABYLON.MeshBuilder.CreateBox('blade', {
                width: 0.15 * scale,
                height: 1.8 * scale,
                depth: 0.08 * scale
            }, scene);
            const bladeMaterial = new BABYLON.StandardMaterial('bladeMaterial', scene);
            
            // Apply Bedrock material types based on properties
            if (hasGlow) {
                bladeMaterial.emissiveTexture = new BABYLON.Texture('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==', scene);
            }
            
            // Minecraft-accurate colors
            if (color === 'golden' || color === 'gold') {
                bladeMaterial.diffuseColor = new BABYLON.Color3(1, 0.84, 0); // Minecraft gold
                bladeMaterial.emissiveColor = new BABYLON.Color3(0.1, 0.08, 0);
            } else if (color === 'diamond' || color === 'blue') {
                bladeMaterial.diffuseColor = new BABYLON.Color3(0.5, 0.8, 1); // Minecraft diamond
                bladeMaterial.emissiveColor = new BABYLON.Color3(0.05, 0.1, 0.15);
            } else if (color === 'iron' || color === 'gray') {
                bladeMaterial.diffuseColor = new BABYLON.Color3(0.8, 0.8, 0.8); // Minecraft iron
            } else if (color === 'netherite' || color === 'black') {
                bladeMaterial.diffuseColor = new BABYLON.Color3(0.2, 0.2, 0.25); // Minecraft netherite
                bladeMaterial.emissiveColor = new BABYLON.Color3(0.02, 0.02, 0.03);
            } else {
                bladeMaterial.diffuseColor = new BABYLON.Color3(0.8, 0.4, 0.2); // Default orange
            }
            
            blade.material = bladeMaterial;
            blade.position.y = 0.9 * scale;
            
            // Create handle (Minecraft sword handle)
            const handle = BABYLON.MeshBuilder.CreateBox('handle', {
                width: 0.08 * scale, 
                height: 0.6 * scale, 
                depth: 0.08 * scale
            }, scene);
            const handleMaterial = new BABYLON.StandardMaterial('handleMaterial', scene);
            handleMaterial.diffuseColor = new BABYLON.Color3(0.4, 0.2, 0.1); // Brown wood
            handle.material = handleMaterial;
            handle.position.y = -0.3 * scale;
            
            // Create guard (crossguard)
            const guard = BABYLON.MeshBuilder.CreateBox('guard', {
                width: 0.3 * scale, 
                height: 0.05 * scale, 
                depth: 0.05 * scale
            }, scene);
            guard.material = bladeMaterial;
            guard.position.y = 0.1 * scale;
            
            // Create parent mesh
            const sword = BABYLON.MeshBuilder.CreateBox('sword', {width: 0.1, height: 0.1, depth: 0.1}, scene);
            sword.isVisible = false;
            blade.parent = sword;
            handle.parent = sword;
            guard.parent = sword;
            
            // Add flame effects (like enchanted sword)
            if (hasFlames) {
                addMinecraftFlameEffect(sword, color);
            }
            
            // Add glow effect (like enchanted items)
            if (hasGlow) {
                addMinecraftGlowEffect(sword, color);
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
        
        function addMinecraftFlameEffect(parent, flameColor) {
            // Create Minecraft-style flame particles (like enchanted items)
            const particleSystem = new BABYLON.ParticleSystem('minecraftFlames', 1500, scene);
            particleSystem.particleTexture = new BABYLON.Texture('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==', scene);
            
            particleSystem.emitter = parent;
            particleSystem.minEmitBox = new BABYLON.Vector3(-0.05, 0, -0.05);
            particleSystem.maxEmitBox = new BABYLON.Vector3(0.05, 0, 0.05);
            
            // Minecraft-style flame colors
            if (flameColor === 'black' || flameColor === 'netherite') {
                particleSystem.color1 = new BABYLON.Color4(0.1, 0.05, 0.1, 1);
                particleSystem.color2 = new BABYLON.Color4(0.2, 0.1, 0.2, 0.8);
            } else if (flameColor === 'diamond' || flameColor === 'blue') {
                particleSystem.color1 = new BABYLON.Color4(0.2, 0.4, 0.8, 1);
                particleSystem.color2 = new BABYLON.Color4(0.4, 0.6, 1, 0.8);
            } else {
                particleSystem.color1 = new BABYLON.Color4(1, 0.3, 0, 1);
                particleSystem.color2 = new BABYLON.Color4(1, 0.6, 0, 0.8);
            }
            particleSystem.colorDead = new BABYLON.Color4(0, 0, 0, 0);
            
            particleSystem.minSize = 0.05;
            particleSystem.maxSize = 0.15;
            particleSystem.minLifeTime = 0.5;
            particleSystem.maxLifeTime = 1.5;
            particleSystem.emitRate = 800;
            particleSystem.gravity = new BABYLON.Vector3(0, -1, 0);
            particleSystem.direction1 = new BABYLON.Vector3(-0.3, 0.8, -0.3);
            particleSystem.direction2 = new BABYLON.Vector3(0.3, 0.8, 0.3);
            particleSystem.minAngularSpeed = 0;
            particleSystem.maxAngularSpeed = Math.PI / 2;
            particleSystem.minEmitPower = 0.5;
            particleSystem.maxEmitPower = 1.5;
            particleSystem.updateSpeed = 0.02;
            
            particleSystem.start();
        }
        
        function addMinecraftGlowEffect(parent, glowColor) {
            // Add Minecraft-style enchantment glow
            if (parent.material) {
                if (glowColor === 'diamond' || glowColor === 'blue') {
                    parent.material.emissiveColor = new BABYLON.Color3(0.1, 0.2, 0.4);
                } else if (glowColor === 'gold' || glowColor === 'golden') {
                    parent.material.emissiveColor = new BABYLON.Color3(0.3, 0.25, 0.1);
                } else {
                    parent.material.emissiveColor = new BABYLON.Color3(0.2, 0.1, 0.2);
                }
            }
        }
        
        function addFlameEffect(parent, flameColor) {
            // Legacy function for backward compatibility
            addMinecraftFlameEffect(parent, flameColor);
        }
        
        function addGlowEffect(parent) {
            // Legacy function for backward compatibility
            addMinecraftGlowEffect(parent, 'default');
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
    // Use fallback for desktop platforms where WebView doesn't work well
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return _buildDesktopFallback();
    }
    
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
            (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
                ? _buildDesktopFallback()
                : WebViewWidget(controller: _webViewController),
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

  Widget _buildDesktopFallback() {
    final creatureType = widget.creatureAttributes['creatureType'] ?? 'sword';
    final color = widget.creatureAttributes['color'] ?? 'golden';
    final effects = widget.creatureAttributes['effects'] ?? [];
    final hasFlames = effects.contains('flames') || effects.contains('fire');
    final hasGlow = effects.contains('glow') || effects.contains('magic');
    final hasWings = effects.contains('wings') || effects.contains('flying');
    final size = widget.creatureAttributes['size'] ?? 'normal';
    
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade100,
            Colors.blue.shade200,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCreatureIcon(creatureType),
            size: 80,
            color: _getColorFromString(color),
          ),
          const SizedBox(height: 16),
          Text(
            '${_capitalize(creatureType)} Preview',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Color: ${_capitalize(color)}',
            style: const TextStyle(fontSize: 14),
          ),
          if (hasFlames) ...[
            const SizedBox(height: 4),
            const Text('🔥 Flames', style: TextStyle(fontSize: 12)),
          ],
          if (hasGlow) ...[
            const SizedBox(height: 4),
            const Text('✨ Glow', style: TextStyle(fontSize: 12)),
          ],
          if (hasWings) ...[
            const SizedBox(height: 4),
            const Text('🕊️ Wings', style: TextStyle(fontSize: 12)),
          ],
          const SizedBox(height: 16),
          const Text(
            '3D Preview\n(Desktop Fallback)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCreatureIcon(String creatureType) {
    switch (creatureType.toLowerCase()) {
      case 'sword':
      case 'weapon':
        return Icons.sports_martial_arts;
      case 'dragon':
      case 'creature':
        return Icons.pets;
      case 'furniture':
      case 'chair':
      case 'couch':
        return Icons.chair;
      case 'armor':
      case 'helmet':
        return Icons.shield;
      case 'tool':
      case 'pickaxe':
        return Icons.build;
      default:
        return Icons.auto_awesome;
    }
  }

  Color _getColorFromString(String color) {
    switch (color.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'golden':
      case 'gold':
        return Colors.amber;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      default:
        return Colors.blue;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
