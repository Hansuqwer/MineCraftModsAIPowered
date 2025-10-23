import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:crafta/services/ai_content_generator.dart';

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
  late WebViewController _controller;
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
    
    final htmlContent = '''
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>AI Creation Preview</title>
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

  log("🎨 Creating AI-generated model...");

  // Get model parameters
  const objectType = '${widget.blueprint.object}';
  const theme = '${widget.blueprint.theme}';
  const colorScheme = '${widget.blueprint.colorScheme.join(',')}'.split(',');
  const specialFeatures = '${widget.blueprint.specialFeatures.join(',')}'.split(',');
  
  log(\`📋 Model: \${objectType} with \${theme} theme\`);
  log(\`🎨 Colors: \${colorScheme.join(', ')}\`);
  log(\`✨ Features: \${specialFeatures.join(', ')}\`);

  // Create the model based on type
  let model;
  try {
    switch (objectType.toLowerCase()) {
      case 'couch':
        model = buildCouch(scene, { theme, colorScheme, specialFeatures });
        break;
      case 'sword':
        model = buildSword(scene, { theme, colorScheme, specialFeatures });
        break;
      case 'dragon':
        model = buildDragon(scene, { theme, colorScheme, specialFeatures });
        break;
      case 'chair':
        model = buildChair(scene, { theme, colorScheme, specialFeatures });
        break;
      case 'table':
        model = buildTable(scene, { theme, colorScheme, specialFeatures });
        break;
      case 'house':
        model = buildHouse(scene, { theme, colorScheme, specialFeatures });
        break;
      case 'car':
        model = buildCar(scene, { theme, colorScheme, specialFeatures });
        break;
      default:
        model = buildDragon(scene, { theme, colorScheme, specialFeatures });
    }
    
    if (model) {
      log("✅ Model created successfully!", 'success');
    } else {
      log("❌ Model creation failed", 'err');
    }
  } catch (e) {
    log(\`❌ Error creating model: \${e.message}\`, 'err');
  }

  engine.runRenderLoop(() => scene.render());
  window.addEventListener("resize", () => engine.resize());
  
  log("🎬 Render loop started");

  // Procedural builders
  function buildCouch(scene, options = {}) {
    const { theme = 'basic', colorScheme = ['red', 'black', 'gold'], specialFeatures = [] } = options;
    const hasGlow = specialFeatures.includes('glowing');
    
    // Main seat
    const seat = BABYLON.MeshBuilder.CreateBox("seat", { width: 3, height: 0.5, depth: 1.5 }, scene);
    seat.position.y = 0;
    
    // Back rest
    const back = BABYLON.MeshBuilder.CreateBox("back", { width: 3, height: 1.2, depth: 0.2 }, scene);
    back.position.y = 0.6;
    back.position.z = -0.6;
    
    // Arm rests
    const leftArm = BABYLON.MeshBuilder.CreateBox("leftArm", { width: 0.3, height: 0.8, depth: 1.5 }, scene);
    leftArm.position.x = -1.35;
    leftArm.position.y = 0.4;
    
    const rightArm = BABYLON.MeshBuilder.CreateBox("rightArm", { width: 0.3, height: 0.8, depth: 1.5 }, scene);
    rightArm.position.x = 1.35;
    rightArm.position.y = 0.4;
    
    // Cushions
    const cushion1 = BABYLON.MeshBuilder.CreateBox("cushion1", { width: 1.2, height: 0.3, depth: 1.2 }, scene);
    cushion1.position.x = -0.6;
    cushion1.position.y = 0.25;
    cushion1.position.z = 0;
    
    const cushion2 = BABYLON.MeshBuilder.CreateBox("cushion2", { width: 1.2, height: 0.3, depth: 1.2 }, scene);
    cushion2.position.x = 0.6;
    cushion2.position.y = 0.25;
    cushion2.position.z = 0;
    
    // Materials
    const mainMat = createMaterial(scene, colorScheme[0], hasGlow);
    const accentMat = createMaterial(scene, colorScheme[1] || colorScheme[0], hasGlow);
    
    seat.material = back.material = leftArm.material = rightArm.material = mainMat;
    
    // Dragon theme decorations
    if (theme === 'dragon') {
      applyDragonTheme(cushion1, cushion2, scene);
    } else {
      cushion1.material = cushion2.material = accentMat;
    }
    
    // Merge into single mesh
    const couch = BABYLON.Mesh.MergeMeshes([seat, back, leftArm, rightArm, cushion1, cushion2], true, true);
    couch.name = "couch";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      couch.rotation.y += 0.005;
    });
    
    return couch;
  }

  function buildSword(scene, options = {}) {
    const { theme = 'basic', colorScheme = ['blue', 'silver', 'purple'], specialFeatures = [] } = options;
    const hasGlow = specialFeatures.includes('glowing');
    const isMagical = specialFeatures.includes('magical');
    
    // Blade
    const blade = BABYLON.MeshBuilder.CreateBox("blade", { width: 0.2, height: 2.5, depth: 0.1 }, scene);
    blade.position.y = 0;
    blade.rotation.z = Math.PI / 6;
    
    // Handle
    const handle = BABYLON.MeshBuilder.CreateCylinder("handle", { diameter: 0.2, height: 0.6 }, scene);
    handle.position.y = -1.5;
    handle.rotation.z = Math.PI / 6;
    
    // Guard
    const guard = BABYLON.MeshBuilder.CreateBox("guard", { width: 0.8, height: 0.1, depth: 0.1 }, scene);
    guard.position.y = -1.2;
    guard.rotation.z = Math.PI / 6;
    
    // Pommel
    const pommel = BABYLON.MeshBuilder.CreateSphere("pommel", { diameter: 0.3 }, scene);
    pommel.position.y = -1.8;
    
    // Materials
    const bladeMat = createBladeMaterial(scene, colorScheme[0], hasGlow, isMagical);
    const handleMat = createHandleMaterial(scene, colorScheme[1] || colorScheme[0]);
    
    blade.material = bladeMat;
    handle.material = guard.material = pommel.material = handleMat;
    
    // Magical effects
    if (isMagical) {
      applyMagicalEffects(blade, scene);
    }
    
    // Merge into single mesh
    const sword = BABYLON.Mesh.MergeMeshes([blade, handle, guard, pommel], true, true);
    sword.name = "sword";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      sword.rotation.y += 0.01;
    });
    
    return sword;
  }

  function buildDragon(scene, options = {}) {
    const { theme = 'dragon', colorScheme = ['red', 'gold', 'black'], specialFeatures = [] } = options;
    const hasGlow = specialFeatures.includes('glowing');
    const isFlying = specialFeatures.includes('flying');
    
    // Main body
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 2.5, height: 2.5, depth: 4 }, scene);
    body.position.y = 1.2;
    
    // Head
    const head = BABYLON.MeshBuilder.CreateBox("head", { width: 2, height: 2, depth: 2 }, scene);
    head.position.y = 2.5;
    head.position.z = -2;
    
    // Wings
    const leftWing = BABYLON.MeshBuilder.CreateBox("leftWing", { width: 4, height: 0.3, depth: 3 }, scene);
    leftWing.position.x = -2;
    leftWing.position.y = 2.5;
    leftWing.position.z = 0;
    
    const rightWing = BABYLON.MeshBuilder.CreateBox("rightWing", { width: 4, height: 0.3, depth: 3 }, scene);
    rightWing.position.x = 2;
    rightWing.position.y = 2.5;
    rightWing.position.z = 0;
    
    // Tail
    const tail = BABYLON.MeshBuilder.CreateBox("tail", { width: 1, height: 1, depth: 2 }, scene);
    tail.position.y = 1.5;
    tail.position.z = 2.5;
    
    // Eyes
    const leftEye = BABYLON.MeshBuilder.CreateBox("leftEye", { width: 0.15, height: 0.15, depth: 0.15 }, scene);
    leftEye.position.x = -0.3;
    leftEye.position.y = 2.2;
    leftEye.position.z = -2.2;
    
    const rightEye = BABYLON.MeshBuilder.CreateBox("rightEye", { width: 0.15, height: 0.15, depth: 0.15 }, scene);
    rightEye.position.x = 0.3;
    rightEye.position.y = 2.2;
    rightEye.position.z = -2.2;
    
    // Materials
    const dragonMat = createMaterial(scene, colorScheme[0], hasGlow);
    const eyeMat = createEyeMaterial(scene);
    
    body.material = head.material = leftWing.material = rightWing.material = tail.material = dragonMat;
    leftEye.material = rightEye.material = eyeMat;
    
    // Flying animation
    if (isFlying) {
      scene.registerBeforeRender(() => {
        body.position.y += Math.sin(Date.now() * 0.001) * 0.01;
      });
    }
    
    // Merge into single mesh
    const dragon = BABYLON.Mesh.MergeMeshes([body, head, leftWing, rightWing, tail, leftEye, rightEye], true, true);
    dragon.name = "dragon";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      dragon.rotation.y += 0.01;
    });
    
    return dragon;
  }

  function buildChair(scene, options = {}) {
    const { colorScheme = ['brown', 'darkbrown'], specialFeatures = [] } = options;
    
    // Seat
    const seat = BABYLON.MeshBuilder.CreateBox("seat", { width: 1, height: 0.2, depth: 1 }, scene);
    seat.position.y = 0;
    
    // Back
    const back = BABYLON.MeshBuilder.CreateBox("back", { width: 1, height: 1.2, depth: 0.2 }, scene);
    back.position.y = 0.5;
    back.position.z = -0.4;
    
    // Legs
    const legPositions = [
      {x: -0.4, z: 0.4}, {x: 0.4, z: 0.4},
      {x: -0.4, z: -0.4}, {x: 0.4, z: -0.4}
    ];
    
    const legs = [];
    legPositions.forEach((pos, i) => {
      const leg = BABYLON.MeshBuilder.CreateCylinder("leg" + i, { diameter: 0.15, height: 0.8 }, scene);
      leg.position.x = pos.x;
      leg.position.y = -0.5;
      leg.position.z = pos.z;
      legs.push(leg);
    });
    
    // Material
    const chairMat = createMaterial(scene, colorScheme[0]);
    
    seat.material = back.material = chairMat;
    legs.forEach(leg => leg.material = chairMat);
    
    // Merge into single mesh
    const chair = BABYLON.Mesh.MergeMeshes([seat, back].concat(legs), true, true);
    chair.name = "chair";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      chair.rotation.y += 0.01;
    });
    
    return chair;
  }

  function buildTable(scene, options = {}) {
    const { colorScheme = ['brown', 'darkbrown'], specialFeatures = [] } = options;
    
    // Table top
    const top = BABYLON.MeshBuilder.CreateBox("top", { width: 2, height: 0.1, depth: 1 }, scene);
    top.position.y = 0.4;
    
    // Legs
    const legPositions = [
      {x: -0.8, z: 0.3}, {x: 0.8, z: 0.3},
      {x: -0.8, z: -0.3}, {x: 0.8, z: -0.3}
    ];
    
    const legs = [];
    legPositions.forEach((pos, i) => {
      const leg = BABYLON.MeshBuilder.CreateCylinder("leg" + i, { diameter: 0.1, height: 0.8 }, scene);
      leg.position.x = pos.x;
      leg.position.y = 0;
      leg.position.z = pos.z;
      legs.push(leg);
    });
    
    // Material
    const tableMat = createMaterial(scene, colorScheme[0]);
    
    top.material = tableMat;
    legs.forEach(leg => leg.material = tableMat);
    
    // Merge into single mesh
    const table = BABYLON.Mesh.MergeMeshes([top].concat(legs), true, true);
    table.name = "table";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      table.rotation.y += 0.01;
    });
    
    return table;
  }

  function buildHouse(scene, options = {}) {
    const { colorScheme = ['brown', 'red'], specialFeatures = [] } = options;
    
    // Main structure
    const walls = BABYLON.MeshBuilder.CreateBox("walls", { width: 3, height: 2, depth: 3 }, scene);
    walls.position.y = 1;
    
    // Roof
    const roof = BABYLON.MeshBuilder.CreateBox("roof", { width: 3.5, height: 1, depth: 3.5 }, scene);
    roof.position.y = 2.5;
    roof.rotation.x = Math.PI / 4;
    
    // Door
    const door = BABYLON.MeshBuilder.CreateBox("door", { width: 0.8, height: 1.5, depth: 0.1 }, scene);
    door.position.y = 0.75;
    door.position.z = 1.5;
    
    // Windows
    const window1 = BABYLON.MeshBuilder.CreateBox("window1", { width: 0.6, height: 0.6, depth: 0.1 }, scene);
    window1.position.x = -1;
    window1.position.y = 1.2;
    window1.position.z = 1.5;
    
    const window2 = BABYLON.MeshBuilder.CreateBox("window2", { width: 0.6, height: 0.6, depth: 0.1 }, scene);
    window2.position.x = 1;
    window2.position.y = 1.2;
    window2.position.z = 1.5;
    
    // Materials
    const wallMat = createMaterial(scene, colorScheme[0]);
    const roofMat = createMaterial(scene, colorScheme[1]);
    const doorMat = createMaterial(scene, 'darkbrown');
    const windowMat = createWindowMaterial(scene);
    
    walls.material = wallMat;
    roof.material = roofMat;
    door.material = doorMat;
    window1.material = window2.material = windowMat;
    
    // Merge into single mesh
    const house = BABYLON.Mesh.MergeMeshes([walls, roof, door, window1, window2], true, true);
    house.name = "house";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      house.rotation.y += 0.005;
    });
    
    return house;
  }

  function buildCar(scene, options = {}) {
    const { colorScheme = ['red', 'black'], specialFeatures = [] } = options;
    
    // Main body
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 2, height: 0.8, depth: 4 }, scene);
    body.position.y = 0.4;
    
    // Roof
    const roof = BABYLON.MeshBuilder.CreateBox("roof", { width: 1.6, height: 0.6, depth: 2.5 }, scene);
    roof.position.y = 1.1;
    roof.position.z = -0.3;
    
    // Wheels
    const wheelPositions = [
      {x: -0.7, z: 1.2}, {x: 0.7, z: 1.2},
      {x: -0.7, z: -1.2}, {x: 0.7, z: -1.2}
    ];
    
    const wheels = [];
    wheelPositions.forEach((pos, i) => {
      const wheel = BABYLON.MeshBuilder.CreateCylinder("wheel" + i, { diameter: 0.6, height: 0.3 }, scene);
      wheel.position.x = pos.x;
      wheel.position.y = 0.3;
      wheel.position.z = pos.z;
      wheel.rotation.z = Math.PI / 2;
      wheels.push(wheel);
    });
    
    // Materials
    const bodyMat = createMaterial(scene, colorScheme[0]);
    const wheelMat = createMaterial(scene, 'black');
    
    body.material = roof.material = bodyMat;
    wheels.forEach(wheel => wheel.material = wheelMat);
    
    // Merge into single mesh
    const car = BABYLON.Mesh.MergeMeshes([body, roof].concat(wheels), true, true);
    car.name = "car";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      car.rotation.y += 0.01;
    });
    
    return car;
  }

  // Helper functions
  function createMaterial(scene, colorName, hasGlow = false) {
    const mat = new BABYLON.StandardMaterial("mat", scene);
    const color = getColorFromName(colorName);
    mat.diffuseColor = new BABYLON.Color3(color[0], color[1], color[2]);
    
    if (hasGlow) {
      mat.emissiveColor = new BABYLON.Color3(color[0] * 0.2, color[1] * 0.2, color[2] * 0.2);
    }
    
    return mat;
  }

  function createBladeMaterial(scene, colorName, hasGlow, isMagical) {
    const mat = new BABYLON.StandardMaterial("bladeMat", scene);
    const color = getColorFromName(colorName);
    
    mat.diffuseColor = new BABYLON.Color3(color[0], color[1], color[2]);
    mat.specularColor = new BABYLON.Color3(0.8, 0.8, 0.8);
    
    if (hasGlow) {
      mat.emissiveColor = new BABYLON.Color3(color[0] * 0.4, color[1] * 0.4, color[2] * 0.4);
    }
    
    if (isMagical) {
      mat.metallicFactor = 0.8;
      mat.roughnessFactor = 0.2;
    }
    
    return mat;
  }

  function createHandleMaterial(scene, colorName) {
    const mat = new BABYLON.StandardMaterial("handleMat", scene);
    const color = getColorFromName(colorName);
    
    mat.diffuseColor = new BABYLON.Color3(color[0], color[1], color[2]);
    mat.roughnessFactor = 0.8;
    
    return mat;
  }

  function createEyeMaterial(scene) {
    const mat = new BABYLON.StandardMaterial("eyeMat", scene);
    mat.diffuseColor = new BABYLON.Color3(1, 0, 0);
    mat.emissiveColor = new BABYLON.Color3(1, 0, 0);
    return mat;
  }

  function createWindowMaterial(scene) {
    const mat = new BABYLON.StandardMaterial("windowMat", scene);
    mat.diffuseColor = new BABYLON.Color3(0.7, 0.9, 1.0);
    mat.emissiveColor = new BABYLON.Color3(0.1, 0.1, 0.2);
    return mat;
  }

  function applyDragonTheme(cushion1, cushion2, scene) {
    // Create dragon texture
    const dragonTex = new BABYLON.DynamicTexture("dragonTex", {width: 256, height: 256}, scene);
    const ctx = dragonTex.getContext();
    
    // Background
    ctx.fillStyle = "#550000";
    ctx.fillRect(0, 0, 256, 256);
    
    // Dragon pattern
    ctx.fillStyle = "#ff0000";
    ctx.font = "48px Arial";
    ctx.textAlign = "center";
    ctx.fillText("🐉", 128, 200);
    
    // Scale pattern
    ctx.fillStyle = "#00ff00";
    ctx.font = "24px Arial";
    ctx.fillText("◊◊◊", 128, 300);
    
    dragonTex.update();
    
    // Apply texture to cushions
    const dragonMat = new BABYLON.StandardMaterial("dragonMat", scene);
    dragonMat.diffuseTexture = dragonTex;
    dragonMat.emissiveColor = new BABYLON.Color3(0.1, 0, 0);
    
    cushion1.material = cushion2.material = dragonMat;
  }

  function applyMagicalEffects(blade, scene) {
    // Create magical glow layer
    const glowLayer = new BABYLON.GlowLayer("magicalGlow", scene);
    glowLayer.intensity = 0.8;
    glowLayer.addIncludedOnlyMesh(blade);
  }

  function getColorFromName(colorName) {
    const colors = {
      'red': [0.8, 0.2, 0.2],
      'blue': [0.2, 0.2, 0.8],
      'green': [0.2, 0.8, 0.2],
      'yellow': [0.8, 0.8, 0.2],
      'purple': [0.6, 0.2, 0.8],
      'orange': [0.8, 0.5, 0.2],
      'black': [0.1, 0.1, 0.1],
      'white': [0.9, 0.9, 0.9],
      'gold': [0.8, 0.6, 0.2],
      'silver': [0.7, 0.7, 0.7],
      'brown': [0.4, 0.2, 0.1],
      'darkbrown': [0.2, 0.1, 0.05]
    };
    return colors[colorName.toLowerCase()] || [0.2, 0.2, 0.8];
  }
})();
</script>
</body>
</html>
''';

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
      ..loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_hasError)
            Center(
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}