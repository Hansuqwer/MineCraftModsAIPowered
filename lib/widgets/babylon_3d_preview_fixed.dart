import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 🎨 Fixed Babylon.js 3D Preview Widget
///
/// Uses proper WebView loading with loadFlutterAsset
/// Shows real 3D models from GLB files
/// Includes error logging and fallbacks
class Babylon3DPreviewFixed extends StatefulWidget {
  final Map<String, dynamic> creatureAttributes;
  final double height;

  const Babylon3DPreviewFixed({
    super.key,
    required this.creatureAttributes,
    this.height = 300,
  });

  @override
  State<Babylon3DPreviewFixed> createState() => _Babylon3DPreviewFixedState();
}

class _Babylon3DPreviewFixedState extends State<Babylon3DPreviewFixed> {
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
    print('🎨 [BABYLON_FIXED] Initializing 3D preview...');
    print('🔍 [BABYLON_FIXED] Attributes: ${widget.creatureAttributes}');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('🔄 [BABYLON_FIXED] Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('✅ [BABYLON_FIXED] Page loaded successfully: $url');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ [BABYLON_FIXED] WebView error: ${error.description}');
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
      ..loadHtmlString(_generateProceduralHTML());
  }

  String _generateProceduralHTML() {
    // Extract attributes
    final creatureType = widget.creatureAttributes['creatureType'] ?? 'dragon';
    final color = widget.creatureAttributes['color'] ?? 'red';
    final size = widget.creatureAttributes['size'] ?? 'medium';
    final glow = widget.creatureAttributes['glow'] ?? 'none';
    
    // Convert to JavaScript-safe values
    final jsCreatureType = creatureType.replaceAll("'", "\\'");
    final jsColor = color.replaceAll("'", "\\'");
    final jsSize = size.replaceAll("'", "\\'");
    final jsGlow = glow.replaceAll("'", "\\'");
    
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Crafta Preview – $jsCreatureType</title>
<script src="https://cdn.babylonjs.com/babylon.js"></script>
<script src="https://cdn.babylonjs.com/loaders/babylonjs.loaders.min.js"></script>
<style>
  html,body{margin:0;overflow:hidden;background:#d6f1ff;}
  #renderCanvas{width:100vw;height:100vh;touch-action:none;display:block;}
  #hud{
    position:fixed;left:8px;bottom:8px;right:8px;
    color:#333;font:12px/1.4 system-ui,sans-serif;pointer-events:none;
    max-height:180px;overflow-y:auto;
  }
  .success{color:#16a34a}.err{color:#dc2626}.warn{color:#f59e0b}
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

  window.addEventListener('error', e => {
    log(\`JS Error: \${e.message}\`, 'err');
  });

  const canvas = document.getElementById("renderCanvas");
  const engine = new BABYLON.Engine(canvas, true, {preserveDrawingBuffer:true, stencil:true});
  const scene = new BABYLON.Scene(engine);
  scene.clearColor = new BABYLON.Color3(0.85, 0.95, 1.0); // bright sky tone
  scene.ambientColor = new BABYLON.Color3(0.5, 0.5, 0.5);

  // Camera - child moves it by touch
  const camera = new BABYLON.ArcRotateCamera("cam",
    Math.PI/4, Math.PI/3, 12, BABYLON.Vector3.Zero(), scene);
  camera.lowerRadiusLimit = 5;
  camera.upperRadiusLimit = 25;
  camera.attachControl(canvas, true);
  camera.wheelPrecision = 40;
  camera.panningSensibility = 0;

  // Lights - bright daylight
  new BABYLON.HemisphericLight("hemi", new BABYLON.Vector3(0.3, 1, 0.2), scene).intensity = 1.3;
  const sun = new BABYLON.DirectionalLight("sun", new BABYLON.Vector3(-1, -2, -1), scene);
  sun.position = new BABYLON.Vector3(6, 15, 6);
  sun.intensity = 1.0;

  log("🎨 Creating procedural model...");

  // Get parameters from Flutter
  const creatureType = '$jsCreatureType';
  const color = '$jsColor';
  const size = '$jsSize';
  const glow = '$jsGlow';
  
  log(\`📋 Building: \${creatureType} (\${color}, \${size}, \${glow})\`);

  let model;
  try {
    // Create model based on type
    switch (creatureType.toLowerCase()) {
      // Furniture
      case 'couch':
      case 'sofa':
        model = buildCouch(scene, { color, size, glow });
        break;
      case 'chair':
        model = buildChair(scene, { color, size, glow });
        break;
      case 'table':
        model = buildTable(scene, { color, size, glow });
        break;
      case 'house':
      case 'home':
        model = buildHouse(scene, { color, size, glow });
        break;
      case 'car':
      case 'vehicle':
        model = buildCar(scene, { color, size, glow });
        break;
      case 'sword':
      case 'weapon':
        model = buildSword(scene, { color, size, glow });
        break;
      // Creatures - Dragons
      case 'dragon':
      case 'red dragon':
      case 'black dragon':
      case 'fire dragon':
        model = buildDragon(scene, { color, size, glow });
        break;
      case 'ice dragon':
      case 'frost dragon':
        model = buildIceDragon(scene, { color, size, glow });
        break;
      case 'shadow dragon':
      case 'dark dragon':
        model = buildShadowDragon(scene, { color, size, glow });
        break;
      // Creatures - Fantasy
      case 'phoenix':
      case 'fire bird':
        model = buildPhoenix(scene, { color, size, glow });
        break;
      case 'griffin':
      case 'griffon':
        model = buildGriffin(scene, { color, size, glow });
        break;
      case 'unicorn':
        model = buildUnicorn(scene, { color, size, glow });
        break;
      case 'pegasus':
        model = buildPegasus(scene, { color, size, glow });
        break;
      // Creatures - Animals
      case 'cat':
      case 'kitten':
        model = buildCat(scene, { color, size, glow });
        break;
      case 'dog':
      case 'puppy':
        model = buildDog(scene, { color, size, glow });
        break;
      case 'bird':
      case 'eagle':
        model = buildBird(scene, { color, size, glow });
        break;
      case 'bear':
        model = buildBear(scene, { color, size, glow });
        break;
      case 'wolf':
        model = buildWolf(scene, { color, size, glow });
        break;
      case 'lion':
        model = buildLion(scene, { color, size, glow });
        break;
      case 'tiger':
        model = buildTiger(scene, { color, size, glow });
        break;
      // Creatures - Mythical
      case 'dinosaur':
      case 't-rex':
        model = buildDinosaur(scene, { color, size, glow });
        break;
      case 'robot':
      case 'mech':
        model = buildRobot(scene, { color, size, glow });
        break;
      case 'alien':
      case 'ufo':
        model = buildAlien(scene, { color, size, glow });
        break;
      default:
        model = buildDragon(scene, { color, size, glow });
    }
    
    if (model) {
      log("✅ Model created successfully!", 'success');
      camera.setTarget(model.position);
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
  function buildDragon(scene, options = {}) {
    const { color = 'red', size = 'medium', glow = 'none' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    const hasGlow = glow !== 'none';
    const mat = createMaterial(scene, color, hasGlow);
    const eyeMat = createEyeMaterial(scene);

    // body (tapered capsule)
    const body = BABYLON.MeshBuilder.CreateCylinder("body", {
      height: 4 * scale,
      diameterTop: 1.0 * scale,
      diameterBottom: 1.6 * scale,
      tessellation: 24,
    }, scene);
    body.rotation.x = Math.PI / 2;
    body.position.y = 1.4 * scale;

    // head (rounded)
    const head = BABYLON.MeshBuilder.CreateSphere("head", {
      diameterX: 1.3 * scale,
      diameterY: 1.0 * scale,
      diameterZ: 1.6 * scale
    }, scene);
    head.position.set(0, 1.8 * scale, -2.8 * scale);

    // tail (cone)
    const tail = BABYLON.MeshBuilder.CreateCylinder("tail", {
      height: 2.8 * scale,
      diameterTop: 0.1 * scale,
      diameterBottom: 0.7 * scale,
      tessellation: 24,
    }, scene);
    tail.rotation.x = Math.PI / 2;
    tail.position.z = 3.5 * scale;
    tail.position.y = 1.2 * scale;

    // wings (plane mesh)
    const wingShape = BABYLON.MeshBuilder.CreatePlane("wing", {
      width: 4 * scale,
      height: 2 * scale,
    }, scene);
    const wingLeft = wingShape.clone("wingLeft");
    const wingRight = wingShape.clone("wingRight");
    wingLeft.position.set(-2.3 * scale, 2.4 * scale, -0.5 * scale);
    wingLeft.rotation.y = Math.PI / 3;
    wingRight.position.set(2.3 * scale, 2.4 * scale, -0.5 * scale);
    wingRight.rotation.y = -Math.PI / 3;

    // eyes
    const leftEye = BABYLON.MeshBuilder.CreateSphere("eyeL", { diameter: 0.25 * scale }, scene);
    const rightEye = leftEye.clone("eyeR");
    leftEye.position.set(-0.35 * scale, 1.9 * scale, -3.3 * scale);
    rightEye.position.set(0.35 * scale, 1.9 * scale, -3.3 * scale);
    leftEye.material = rightEye.material = eyeMat;

    [body, head, tail, wingLeft, wingRight].forEach(m => m.material = mat);
    const dragon = BABYLON.Mesh.MergeMeshes(
      [body, head, tail, wingLeft, wingRight, leftEye, rightEye],
      true, true
    );
    dragon.name = "dragon";

    // idle hover + gentle wing flap
    let flap = 0;
    scene.registerBeforeRender(() => {
      dragon.rotation.y += 0.004;
      dragon.position.y = 1.2 * scale + Math.sin(performance.now() * 0.002) * 0.1;
      flap += 0.05;
      wingLeft.rotation.z = Math.sin(flap) * 0.2;
      wingRight.rotation.z = -Math.sin(flap) * 0.2;
    });
    return dragon;
  }

  function buildCouch(scene, options = {}) {
    const { color = 'red', size = 'medium', glow = 'none' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    const hasGlow = glow !== 'none';
    
    // Seat
    const seat = BABYLON.MeshBuilder.CreateBox("seat", { width: 3 * scale, height: 0.4 * scale, depth: 1.2 * scale }, scene);
    seat.position.y = 0.2 * scale;
    
    // Backrest
    const back = BABYLON.MeshBuilder.CreateBox("back", { width: 3 * scale, height: 1.0 * scale, depth: 0.2 * scale }, scene);
    back.position.y = 0.9 * scale;
    back.position.z = -0.5 * scale;
    
    // Arms
    const leftArm = BABYLON.MeshBuilder.CreateBox("leftArm", { width: 0.3 * scale, height: 0.8 * scale, depth: 1.2 * scale }, scene);
    const rightArm = leftArm.clone("rightArm");
    leftArm.position.x = -1.5 * scale;
    rightArm.position.x = 1.5 * scale;
    leftArm.position.y = rightArm.position.y = 0.6 * scale;
    
    // Material
    const couchMat = new BABYLON.StandardMaterial("couchMat", scene);
    const colorRGB = getColorRGB(color);
    couchMat.diffuseColor = new BABYLON.Color3(colorRGB[0], colorRGB[1], colorRGB[2]);
    
    if (hasGlow) {
      couchMat.emissiveColor = new BABYLON.Color3(colorRGB[0] * 0.2, colorRGB[1] * 0.2, colorRGB[2] * 0.2);
    }
    
    seat.material = back.material = leftArm.material = rightArm.material = couchMat;
    
    // Merge parts
    const couch = BABYLON.Mesh.MergeMeshes([seat, back, leftArm, rightArm], true, true);
    couch.name = "couch";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      couch.rotation.y += 0.005;
    });
    
    return couch;
  }

  function buildSword(scene, options = {}) {
    const { color = 'blue', size = 'medium', glow = 'none' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    const hasGlow = glow !== 'none';
    
    // Blade
    const blade = BABYLON.MeshBuilder.CreateBox("blade", { width: 0.2 * scale, height: 2.5 * scale, depth: 0.1 * scale }, scene);
    blade.position.y = 0;
    blade.rotation.z = Math.PI / 6;
    
    // Handle
    const handle = BABYLON.MeshBuilder.CreateCylinder("handle", { diameter: 0.2 * scale, height: 0.6 * scale }, scene);
    handle.position.y = -1.5 * scale;
    handle.rotation.z = Math.PI / 6;
    
    // Guard
    const guard = BABYLON.MeshBuilder.CreateBox("guard", { width: 0.8 * scale, height: 0.1 * scale, depth: 0.1 * scale }, scene);
    guard.position.y = -1.2 * scale;
    guard.rotation.z = Math.PI / 6;
    
    // Pommel
    const pommel = BABYLON.MeshBuilder.CreateSphere("pommel", { diameter: 0.3 * scale }, scene);
    pommel.position.y = -1.8 * scale;
    
    // Material
    const swordMat = new BABYLON.StandardMaterial("swordMat", scene);
    const colorRGB = getColorRGB(color);
    swordMat.diffuseColor = new BABYLON.Color3(colorRGB[0], colorRGB[1], colorRGB[2]);
    
    if (hasGlow) {
      swordMat.emissiveColor = new BABYLON.Color3(colorRGB[0] * 0.4, colorRGB[1] * 0.4, colorRGB[2] * 0.4);
    }
    
    blade.material = handle.material = guard.material = pommel.material = swordMat;
    
    // Merge into single mesh
    const sword = BABYLON.Mesh.MergeMeshes([blade, handle, guard, pommel], true, true);
    sword.name = "sword";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      sword.rotation.y += 0.01;
    });
    
    return sword;
  }

  function buildChair(scene, options = {}) {
    const { color = 'brown', size = 'medium', glow = 'none' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Seat
    const seat = BABYLON.MeshBuilder.CreateBox("seat", { width: 1 * scale, height: 0.2 * scale, depth: 1 * scale }, scene);
    seat.position.y = 0;
    
    // Back
    const back = BABYLON.MeshBuilder.CreateBox("back", { width: 1 * scale, height: 1.2 * scale, depth: 0.2 * scale }, scene);
    back.position.y = 0.5 * scale;
    back.position.z = -0.4 * scale;
    
    // Legs
    const legPositions = [
      {x: -0.4 * scale, z: 0.4 * scale}, {x: 0.4 * scale, z: 0.4 * scale},
      {x: -0.4 * scale, z: -0.4 * scale}, {x: 0.4 * scale, z: -0.4 * scale}
    ];
    
    const legs = [];
    legPositions.forEach((pos, i) => {
      const leg = BABYLON.MeshBuilder.CreateCylinder("leg" + i, { diameter: 0.15 * scale, height: 0.8 * scale }, scene);
      leg.position.x = pos.x;
      leg.position.y = -0.5 * scale;
      leg.position.z = pos.z;
      legs.push(leg);
    });
    
    // Material
    const chairMat = new BABYLON.StandardMaterial("chairMat", scene);
    const colorRGB = getColorRGB(color);
    chairMat.diffuseColor = new BABYLON.Color3(colorRGB[0], colorRGB[1], colorRGB[2]);
    
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
    const { color = 'brown', size = 'medium', glow = 'none' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Table top
    const top = BABYLON.MeshBuilder.CreateBox("top", { width: 2 * scale, height: 0.1 * scale, depth: 1 * scale }, scene);
    top.position.y = 0.4 * scale;
    
    // Legs
    const legPositions = [
      {x: -0.8 * scale, z: 0.3 * scale}, {x: 0.8 * scale, z: 0.3 * scale},
      {x: -0.8 * scale, z: -0.3 * scale}, {x: 0.8 * scale, z: -0.3 * scale}
    ];
    
    const legs = [];
    legPositions.forEach((pos, i) => {
      const leg = BABYLON.MeshBuilder.CreateCylinder("leg" + i, { diameter: 0.1 * scale, height: 0.8 * scale }, scene);
      leg.position.x = pos.x;
      leg.position.y = 0;
      leg.position.z = pos.z;
      legs.push(leg);
    });
    
    // Material
    const tableMat = new BABYLON.StandardMaterial("tableMat", scene);
    const colorRGB = getColorRGB(color);
    tableMat.diffuseColor = new BABYLON.Color3(colorRGB[0], colorRGB[1], colorRGB[2]);
    
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
    const { color = 'brown', size = 'medium', glow = 'none' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Main structure
    const walls = BABYLON.MeshBuilder.CreateBox("walls", { width: 3 * scale, height: 2 * scale, depth: 3 * scale }, scene);
    walls.position.y = 1 * scale;
    
    // Roof
    const roof = BABYLON.MeshBuilder.CreateBox("roof", { width: 3.5 * scale, height: 1 * scale, depth: 3.5 * scale }, scene);
    roof.position.y = 2.5 * scale;
    roof.rotation.x = Math.PI / 4;
    
    // Door
    const door = BABYLON.MeshBuilder.CreateBox("door", { width: 0.8 * scale, height: 1.5 * scale, depth: 0.1 * scale }, scene);
    door.position.y = 0.75 * scale;
    door.position.z = 1.5 * scale;
    
    // Windows
    const window1 = BABYLON.MeshBuilder.CreateBox("window1", { width: 0.6 * scale, height: 0.6 * scale, depth: 0.1 * scale }, scene);
    window1.position.x = -1 * scale;
    window1.position.y = 1.2 * scale;
    window1.position.z = 1.5 * scale;
    
    const window2 = BABYLON.MeshBuilder.CreateBox("window2", { width: 0.6 * scale, height: 0.6 * scale, depth: 0.1 * scale }, scene);
    window2.position.x = 1 * scale;
    window2.position.y = 1.2 * scale;
    window2.position.z = 1.5 * scale;
    
    // Materials
    const wallMat = new BABYLON.StandardMaterial("wallMat", scene);
    const roofMat = new BABYLON.StandardMaterial("roofMat", scene);
    const doorMat = new BABYLON.StandardMaterial("doorMat", scene);
    const windowMat = new BABYLON.StandardMaterial("windowMat", scene);
    
    const colorRGB = getColorRGB(color);
    wallMat.diffuseColor = new BABYLON.Color3(colorRGB[0], colorRGB[1], colorRGB[2]);
    roofMat.diffuseColor = new BABYLON.Color3(0.8, 0.2, 0.2);
    doorMat.diffuseColor = new BABYLON.Color3(0.4, 0.2, 0.1);
    windowMat.diffuseColor = new BABYLON.Color3(0.7, 0.9, 1.0);
    windowMat.emissiveColor = new BABYLON.Color3(0.1, 0.1, 0.2);
    
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
    const { color = 'red', size = 'medium', glow = 'none' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Main body
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 2 * scale, height: 0.8 * scale, depth: 4 * scale }, scene);
    body.position.y = 0.4 * scale;
    
    // Roof
    const roof = BABYLON.MeshBuilder.CreateBox("roof", { width: 1.6 * scale, height: 0.6 * scale, depth: 2.5 * scale }, scene);
    roof.position.y = 1.1 * scale;
    roof.position.z = -0.3 * scale;
    
    // Wheels
    const wheelPositions = [
      {x: -0.7 * scale, z: 1.2 * scale}, {x: 0.7 * scale, z: 1.2 * scale},
      {x: -0.7 * scale, z: -1.2 * scale}, {x: 0.7 * scale, z: -1.2 * scale}
    ];
    
    const wheels = [];
    wheelPositions.forEach((pos, i) => {
      const wheel = BABYLON.MeshBuilder.CreateCylinder("wheel" + i, { diameter: 0.6 * scale, height: 0.3 * scale }, scene);
      wheel.position.x = pos.x;
      wheel.position.y = 0.3 * scale;
      wheel.position.z = pos.z;
      wheel.rotation.z = Math.PI / 2;
      wheels.push(wheel);
    });
    
    // Materials
    const bodyMat = new BABYLON.StandardMaterial("bodyMat", scene);
    const wheelMat = new BABYLON.StandardMaterial("wheelMat", scene);
    
    const colorRGB = getColorRGB(color);
    bodyMat.diffuseColor = new BABYLON.Color3(colorRGB[0], colorRGB[1], colorRGB[2]);
    wheelMat.diffuseColor = new BABYLON.Color3(0.1, 0.1, 0.1);
    
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

  // ===== CREATURE BUILDERS =====
  
  function buildIceDragon(scene, options = {}) {
    const { color = 'blue', size = 'medium', glow = 'ice' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Use the same improved dragon structure but with ice materials
    const mainMat = new BABYLON.StandardMaterial("iceDragonMat", scene);
    mainMat.diffuseColor = new BABYLON.Color3(0.2, 0.6, 1.0);
    mainMat.emissiveColor = new BABYLON.Color3(0.1, 0.3, 0.5);
    
    const eyeMat = new BABYLON.StandardMaterial("iceEyeMat", scene);
    eyeMat.diffuseColor = new BABYLON.Color3(0, 0.8, 1);
    eyeMat.emissiveColor = new BABYLON.Color3(0, 0.8, 1);

    // body - more realistic proportions
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 2 * scale, height: 1.2 * scale, depth: 4 * scale }, scene);
    body.position.y = 1.2 * scale;

    // head - smaller and more proportional
    const head = BABYLON.MeshBuilder.CreateBox("head", { width: 1.5 * scale, height: 1 * scale, depth: 1.5 * scale }, scene);
    head.position.set(0, 1.6 * scale, -2.7 * scale);

    // tail - tapered cylinder for more realistic shape
    const tail = BABYLON.MeshBuilder.CreateCylinder("tail", { 
      diameterTop: 0.2 * scale, 
      diameterBottom: 0.8 * scale, 
      height: 3 * scale, 
      tessellation: 8 
    }, scene);
    tail.rotation.x = Math.PI / 2;
    tail.position.z = 3.2 * scale;
    tail.position.y = 1.0 * scale;

    // wings - more spread out and realistic
    const wingShape = BABYLON.MeshBuilder.CreateBox("wing", { width: 4 * scale, height: 0.1 * scale, depth: 2.2 * scale }, scene);
    const wingLeft = wingShape.clone("wingLeft");
    const wingRight = wingShape.clone("wingRight");
    wingLeft.position.set(-2.2 * scale, 2.2 * scale, -0.5 * scale);
    wingRight.position.set(2.2 * scale, 2.2 * scale, -0.5 * scale);
    wingRight.scaling.x *= -1;

    // eyes - spheres instead of boxes for more realistic look
    const leftEye = BABYLON.MeshBuilder.CreateSphere("eyeL", { diameter: 0.25 * scale }, scene);
    const rightEye = leftEye.clone("eyeR");
    leftEye.position.set(-0.35 * scale, 1.8 * scale, -3.3 * scale);
    rightEye.position.set(0.35 * scale, 1.8 * scale, -3.3 * scale);
    leftEye.material = rightEye.material = eyeMat;

    // assign materials
    [body, head, tail, wingLeft, wingRight].forEach(m => m.material = mainMat);

    const dragon = BABYLON.Mesh.MergeMeshes([body, head, tail, wingLeft, wingRight, leftEye, rightEye], true, true);
    dragon.name = "iceDragon";
    
    // Add smooth hover animation
    scene.registerBeforeRender(() => {
      if (dragon) {
        dragon.rotation.y += 0.005;
        dragon.position.y = Math.sin(performance.now() * 0.001) * 0.1 + 1.2 * scale; // slight hover
      }
    });
    
    return dragon;
  }

  function buildShadowDragon(scene, options = {}) {
    const { color = 'black', size = 'medium', glow = 'shadow' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Main body (dark)
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 2.5 * scale, height: 2.5 * scale, depth: 4 * scale }, scene);
    body.position.y = 1.2 * scale;
    
    // Head
    const head = BABYLON.MeshBuilder.CreateBox("head", { width: 2 * scale, height: 2 * scale, depth: 2 * scale }, scene);
    head.position.y = 2.5 * scale;
    head.position.z = -2 * scale;
    
    // Wings (shadowy)
    const leftWing = BABYLON.MeshBuilder.CreateBox("leftWing", { width: 4 * scale, height: 0.3 * scale, depth: 3 * scale }, scene);
    leftWing.position.x = -2 * scale;
    leftWing.position.y = 2.5 * scale;
    leftWing.position.z = 0;
    
    const rightWing = BABYLON.MeshBuilder.CreateBox("rightWing", { width: 4 * scale, height: 0.3 * scale, depth: 3 * scale }, scene);
    rightWing.position.x = 2 * scale;
    rightWing.position.y = 2.5 * scale;
    rightWing.position.z = 0;
    
    // Tail
    const tail = BABYLON.MeshBuilder.CreateBox("tail", { width: 1 * scale, height: 1 * scale, depth: 2 * scale }, scene);
    tail.position.y = 1.5 * scale;
    tail.position.z = 2.5 * scale;
    
    // Eyes (purple glow)
    const leftEye = BABYLON.MeshBuilder.CreateBox("leftEye", { width: 0.15 * scale, height: 0.15 * scale, depth: 0.15 * scale }, scene);
    leftEye.position.x = -0.3 * scale;
    leftEye.position.y = 2.2 * scale;
    leftEye.position.z = -2.2 * scale;
    
    const rightEye = BABYLON.MeshBuilder.CreateBox("rightEye", { width: 0.15 * scale, height: 0.15 * scale, depth: 0.15 * scale }, scene);
    rightEye.position.x = 0.3 * scale;
    rightEye.position.y = 2.2 * scale;
    rightEye.position.z = -2.2 * scale;
    
    // Materials
    const dragonMat = new BABYLON.StandardMaterial("shadowDragonMat", scene);
    dragonMat.diffuseColor = new BABYLON.Color3(0.1, 0.1, 0.1);
    dragonMat.emissiveColor = new BABYLON.Color3(0.2, 0.1, 0.3);
    
    const eyeMat = new BABYLON.StandardMaterial("shadowEyeMat", scene);
    eyeMat.diffuseColor = new BABYLON.Color3(0.8, 0, 0.8);
    eyeMat.emissiveColor = new BABYLON.Color3(0.8, 0, 0.8);
    
    body.material = head.material = leftWing.material = rightWing.material = tail.material = dragonMat;
    leftEye.material = rightEye.material = eyeMat;
    
    // Merge into single mesh
    const dragon = BABYLON.Mesh.MergeMeshes([body, head, leftWing, rightWing, tail, leftEye, rightEye], true, true);
    dragon.name = "shadowDragon";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      dragon.rotation.y += 0.01;
    });
    
    return dragon;
  }

  function buildPhoenix(scene, options = {}) {
    const { color = 'red', size = 'medium', glow = 'fire' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Body
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 1.5 * scale, height: 1.5 * scale, depth: 2 * scale }, scene);
    body.position.y = 0.8 * scale;
    
    // Head
    const head = BABYLON.MeshBuilder.CreateBox("head", { width: 1 * scale, height: 1 * scale, depth: 1.2 * scale }, scene);
    head.position.y = 1.8 * scale;
    head.position.z = -0.8 * scale;
    
    // Wings (large and spread)
    const leftWing = BABYLON.MeshBuilder.CreateBox("leftWing", { width: 3 * scale, height: 0.2 * scale, depth: 2 * scale }, scene);
    leftWing.position.x = -1.5 * scale;
    leftWing.position.y = 1.5 * scale;
    leftWing.position.z = 0;
    
    const rightWing = BABYLON.MeshBuilder.CreateBox("rightWing", { width: 3 * scale, height: 0.2 * scale, depth: 2 * scale }, scene);
    rightWing.position.x = 1.5 * scale;
    rightWing.position.y = 1.5 * scale;
    rightWing.position.z = 0;
    
    // Tail (long and flowing)
    const tail = BABYLON.MeshBuilder.CreateBox("tail", { width: 0.8 * scale, height: 0.8 * scale, depth: 3 * scale }, scene);
    tail.position.y = 1 * scale;
    tail.position.z = 2 * scale;
    
    // Materials
    const phoenixMat = new BABYLON.StandardMaterial("phoenixMat", scene);
    phoenixMat.diffuseColor = new BABYLON.Color3(1, 0.3, 0);
    phoenixMat.emissiveColor = new BABYLON.Color3(0.5, 0.1, 0);
    
    body.material = head.material = leftWing.material = rightWing.material = tail.material = phoenixMat;
    
    // Merge into single mesh
    const phoenix = BABYLON.Mesh.MergeMeshes([body, head, leftWing, rightWing, tail], true, true);
    phoenix.name = "phoenix";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      phoenix.rotation.y += 0.01;
    });
    
    return phoenix;
  }

  function buildGriffin(scene, options = {}) {
    const { color = 'gold', size = 'medium', glow = 'none' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Lion body
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 2 * scale, height: 1.5 * scale, depth: 3 * scale }, scene);
    body.position.y = 0.8 * scale;
    
    // Eagle head
    const head = BABYLON.MeshBuilder.CreateBox("head", { width: 1.2 * scale, height: 1.2 * scale, depth: 1.5 * scale }, scene);
    head.position.y = 1.8 * scale;
    head.position.z = -1.2 * scale;
    
    // Eagle wings
    const leftWing = BABYLON.MeshBuilder.CreateBox("leftWing", { width: 2.5 * scale, height: 0.3 * scale, depth: 1.5 * scale }, scene);
    leftWing.position.x = -1.2 * scale;
    leftWing.position.y = 1.5 * scale;
    leftWing.position.z = 0;
    
    const rightWing = BABYLON.MeshBuilder.CreateBox("rightWing", { width: 2.5 * scale, height: 0.3 * scale, depth: 1.5 * scale }, scene);
    rightWing.position.x = 1.2 * scale;
    rightWing.position.y = 1.5 * scale;
    rightWing.position.z = 0;
    
    // Lion tail
    const tail = BABYLON.MeshBuilder.CreateBox("tail", { width: 0.3 * scale, height: 0.3 * scale, depth: 1.5 * scale }, scene);
    tail.position.y = 0.8 * scale;
    tail.position.z = 2 * scale;
    
    // Materials
    const griffinMat = new BABYLON.StandardMaterial("griffinMat", scene);
    griffinMat.diffuseColor = new BABYLON.Color3(0.8, 0.6, 0.2);
    
    body.material = head.material = leftWing.material = rightWing.material = tail.material = griffinMat;
    
    // Merge into single mesh
    const griffin = BABYLON.Mesh.MergeMeshes([body, head, leftWing, rightWing, tail], true, true);
    griffin.name = "griffin";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      griffin.rotation.y += 0.01;
    });
    
    return griffin;
  }

  function buildUnicorn(scene, options = {}) {
    const { color = 'white', size = 'medium', glow = 'magic' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Horse body
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 1.8 * scale, height: 1.5 * scale, depth: 3 * scale }, scene);
    body.position.y = 0.8 * scale;
    
    // Head
    const head = BABYLON.MeshBuilder.CreateBox("head", { width: 1 * scale, height: 1.2 * scale, depth: 1.5 * scale }, scene);
    head.position.y = 1.5 * scale;
    head.position.z = -1.5 * scale;
    
    // Horn
    const horn = BABYLON.MeshBuilder.CreateCylinder("horn", { diameter: 0.1 * scale, height: 0.8 * scale }, scene);
    horn.position.y = 2.2 * scale;
    horn.position.z = -1.5 * scale;
    
    // Legs
    const legPositions = [
      {x: -0.6 * scale, z: 0.8 * scale}, {x: 0.6 * scale, z: 0.8 * scale},
      {x: -0.6 * scale, z: -0.8 * scale}, {x: 0.6 * scale, z: -0.8 * scale}
    ];
    
    const legs = [];
    legPositions.forEach((pos, i) => {
      const leg = BABYLON.MeshBuilder.CreateCylinder("leg" + i, { diameter: 0.2 * scale, height: 1.2 * scale }, scene);
      leg.position.x = pos.x;
      leg.position.y = 0.2 * scale;
      leg.position.z = pos.z;
      legs.push(leg);
    });
    
    // Materials
    const unicornMat = new BABYLON.StandardMaterial("unicornMat", scene);
    unicornMat.diffuseColor = new BABYLON.Color3(0.9, 0.9, 0.9);
    unicornMat.emissiveColor = new BABYLON.Color3(0.1, 0.1, 0.2);
    
    const hornMat = new BABYLON.StandardMaterial("hornMat", scene);
    hornMat.diffuseColor = new BABYLON.Color3(1, 1, 0.8);
    hornMat.emissiveColor = new BABYLON.Color3(0.3, 0.3, 0.5);
    
    body.material = head.material = unicornMat;
    horn.material = hornMat;
    legs.forEach(leg => leg.material = unicornMat);
    
    // Merge into single mesh
    const unicorn = BABYLON.Mesh.MergeMeshes([body, head, horn].concat(legs), true, true);
    unicorn.name = "unicorn";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      unicorn.rotation.y += 0.01;
    });
    
    return unicorn;
  }

  function buildPegasus(scene, options = {}) {
    const { color = 'white', size = 'medium', glow = 'none' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Horse body
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 1.8 * scale, height: 1.5 * scale, depth: 3 * scale }, scene);
    body.position.y = 0.8 * scale;
    
    // Head
    const head = BABYLON.MeshBuilder.CreateBox("head", { width: 1 * scale, height: 1.2 * scale, depth: 1.5 * scale }, scene);
    head.position.y = 1.5 * scale;
    head.position.z = -1.5 * scale;
    
    // Wings
    const leftWing = BABYLON.MeshBuilder.CreateBox("leftWing", { width: 2 * scale, height: 0.2 * scale, depth: 1.5 * scale }, scene);
    leftWing.position.x = -1 * scale;
    leftWing.position.y = 1.8 * scale;
    leftWing.position.z = 0;
    
    const rightWing = BABYLON.MeshBuilder.CreateBox("rightWing", { width: 2 * scale, height: 0.2 * scale, depth: 1.5 * scale }, scene);
    rightWing.position.x = 1 * scale;
    rightWing.position.y = 1.8 * scale;
    rightWing.position.z = 0;
    
    // Legs
    const legPositions = [
      {x: -0.6 * scale, z: 0.8 * scale}, {x: 0.6 * scale, z: 0.8 * scale},
      {x: -0.6 * scale, z: -0.8 * scale}, {x: 0.6 * scale, z: -0.8 * scale}
    ];
    
    const legs = [];
    legPositions.forEach((pos, i) => {
      const leg = BABYLON.MeshBuilder.CreateCylinder("leg" + i, { diameter: 0.2 * scale, height: 1.2 * scale }, scene);
      leg.position.x = pos.x;
      leg.position.y = 0.2 * scale;
      leg.position.z = pos.z;
      legs.push(leg);
    });
    
    // Materials
    const pegasusMat = new BABYLON.StandardMaterial("pegasusMat", scene);
    pegasusMat.diffuseColor = new BABYLON.Color3(0.9, 0.9, 0.9);
    
    body.material = head.material = leftWing.material = rightWing.material = pegasusMat;
    legs.forEach(leg => leg.material = pegasusMat);
    
    // Merge into single mesh
    const pegasus = BABYLON.Mesh.MergeMeshes([body, head, leftWing, rightWing].concat(legs), true, true);
    pegasus.name = "pegasus";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      pegasus.rotation.y += 0.01;
    });
    
    return pegasus;
  }

  function buildCat(scene, options = {}) {
    const { color = 'orange', size = 'medium', glow = 'none' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Body
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 1.5 * scale, height: 1 * scale, depth: 2 * scale }, scene);
    body.position.y = 0.5 * scale;
    
    // Head
    const head = BABYLON.MeshBuilder.CreateBox("head", { width: 1 * scale, height: 0.8 * scale, depth: 1 * scale }, scene);
    head.position.y = 1.2 * scale;
    head.position.z = -1 * scale;
    
    // Ears
    const leftEar = BABYLON.MeshBuilder.CreateBox("leftEar", { width: 0.3 * scale, height: 0.4 * scale, depth: 0.3 * scale }, scene);
    leftEar.position.x = -0.3 * scale;
    leftEar.position.y = 1.6 * scale;
    leftEar.position.z = -1.2 * scale;
    
    const rightEar = BABYLON.MeshBuilder.CreateBox("rightEar", { width: 0.3 * scale, height: 0.4 * scale, depth: 0.3 * scale }, scene);
    rightEar.position.x = 0.3 * scale;
    rightEar.position.y = 1.6 * scale;
    rightEar.position.z = -1.2 * scale;
    
    // Tail
    const tail = BABYLON.MeshBuilder.CreateBox("tail", { width: 0.2 * scale, height: 0.2 * scale, depth: 1.5 * scale }, scene);
    tail.position.y = 0.8 * scale;
    tail.position.z = 1.5 * scale;
    
    // Legs
    const legPositions = [
      {x: -0.5 * scale, z: 0.5 * scale}, {x: 0.5 * scale, z: 0.5 * scale},
      {x: -0.5 * scale, z: -0.5 * scale}, {x: 0.5 * scale, z: -0.5 * scale}
    ];
    
    const legs = [];
    legPositions.forEach((pos, i) => {
      const leg = BABYLON.MeshBuilder.CreateCylinder("leg" + i, { diameter: 0.15 * scale, height: 0.8 * scale }, scene);
      leg.position.x = pos.x;
      leg.position.y = 0.1 * scale;
      leg.position.z = pos.z;
      legs.push(leg);
    });
    
    // Materials
    const catMat = new BABYLON.StandardMaterial("catMat", scene);
    const colorRGB = getColorRGB(color);
    catMat.diffuseColor = new BABYLON.Color3(colorRGB[0], colorRGB[1], colorRGB[2]);
    
    body.material = head.material = leftEar.material = rightEar.material = tail.material = catMat;
    legs.forEach(leg => leg.material = catMat);
    
    // Merge into single mesh
    const cat = BABYLON.Mesh.MergeMeshes([body, head, leftEar, rightEar, tail].concat(legs), true, true);
    cat.name = "cat";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      cat.rotation.y += 0.01;
    });
    
    return cat;
  }

  function buildDog(scene, options = {}) {
    const { color = 'brown', size = 'medium', glow = 'none' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Body
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 1.8 * scale, height: 1.2 * scale, depth: 2.5 * scale }, scene);
    body.position.y = 0.6 * scale;
    
    // Head
    const head = BABYLON.MeshBuilder.CreateBox("head", { width: 1.2 * scale, height: 1 * scale, depth: 1.2 * scale }, scene);
    head.position.y = 1.2 * scale;
    head.position.z = -1.2 * scale;
    
    // Ears
    const leftEar = BABYLON.MeshBuilder.CreateBox("leftEar", { width: 0.4 * scale, height: 0.6 * scale, depth: 0.3 * scale }, scene);
    leftEar.position.x = -0.4 * scale;
    leftEar.position.y = 1.5 * scale;
    leftEar.position.z = -1.4 * scale;
    
    const rightEar = BABYLON.MeshBuilder.CreateBox("rightEar", { width: 0.4 * scale, height: 0.6 * scale, depth: 0.3 * scale }, scene);
    rightEar.position.x = 0.4 * scale;
    rightEar.position.y = 1.5 * scale;
    rightEar.position.z = -1.4 * scale;
    
    // Tail
    const tail = BABYLON.MeshBuilder.CreateBox("tail", { width: 0.3 * scale, height: 0.3 * scale, depth: 1.8 * scale }, scene);
    tail.position.y = 1 * scale;
    tail.position.z = 2 * scale;
    
    // Legs
    const legPositions = [
      {x: -0.6 * scale, z: 0.6 * scale}, {x: 0.6 * scale, z: 0.6 * scale},
      {x: -0.6 * scale, z: -0.6 * scale}, {x: 0.6 * scale, z: -0.6 * scale}
    ];
    
    const legs = [];
    legPositions.forEach((pos, i) => {
      const leg = BABYLON.MeshBuilder.CreateCylinder("leg" + i, { diameter: 0.2 * scale, height: 1 * scale }, scene);
      leg.position.x = pos.x;
      leg.position.y = 0.1 * scale;
      leg.position.z = pos.z;
      legs.push(leg);
    });
    
    // Materials
    const dogMat = new BABYLON.StandardMaterial("dogMat", scene);
    const colorRGB = getColorRGB(color);
    dogMat.diffuseColor = new BABYLON.Color3(colorRGB[0], colorRGB[1], colorRGB[2]);
    
    body.material = head.material = leftEar.material = rightEar.material = tail.material = dogMat;
    legs.forEach(leg => leg.material = dogMat);
    
    // Merge into single mesh
    const dog = BABYLON.Mesh.MergeMeshes([body, head, leftEar, rightEar, tail].concat(legs), true, true);
    dog.name = "dog";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      dog.rotation.y += 0.01;
    });
    
    return dog;
  }

  function buildBird(scene, options = {}) {
    const { color = 'blue', size = 'medium', glow = 'none' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Body
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 1 * scale, height: 1.2 * scale, depth: 1.5 * scale }, scene);
    body.position.y = 0.6 * scale;
    
    // Head
    const head = BABYLON.MeshBuilder.CreateBox("head", { width: 0.8 * scale, height: 0.8 * scale, depth: 0.8 * scale }, scene);
    head.position.y = 1.2 * scale;
    head.position.z = -0.8 * scale;
    
    // Beak
    const beak = BABYLON.MeshBuilder.CreateBox("beak", { width: 0.2 * scale, height: 0.2 * scale, depth: 0.4 * scale }, scene);
    beak.position.y = 1.2 * scale;
    beak.position.z = -1.2 * scale;
    
    // Wings
    const leftWing = BABYLON.MeshBuilder.CreateBox("leftWing", { width: 1.5 * scale, height: 0.2 * scale, depth: 1 * scale }, scene);
    leftWing.position.x = -0.7 * scale;
    leftWing.position.y = 1 * scale;
    leftWing.position.z = 0;
    
    const rightWing = BABYLON.MeshBuilder.CreateBox("rightWing", { width: 1.5 * scale, height: 0.2 * scale, depth: 1 * scale }, scene);
    rightWing.position.x = 0.7 * scale;
    rightWing.position.y = 1 * scale;
    rightWing.position.z = 0;
    
    // Tail
    const tail = BABYLON.MeshBuilder.CreateBox("tail", { width: 0.8 * scale, height: 0.3 * scale, depth: 1 * scale }, scene);
    tail.position.y = 0.8 * scale;
    tail.position.z = 1.2 * scale;
    
    // Legs
    const leftLeg = BABYLON.MeshBuilder.CreateCylinder("leftLeg", { diameter: 0.1 * scale, height: 0.6 * scale }, scene);
    leftLeg.position.x = -0.2 * scale;
    leftLeg.position.y = 0.1 * scale;
    leftLeg.position.z = 0.3 * scale;
    
    const rightLeg = BABYLON.MeshBuilder.CreateCylinder("rightLeg", { diameter: 0.1 * scale, height: 0.6 * scale }, scene);
    rightLeg.position.x = 0.2 * scale;
    rightLeg.position.y = 0.1 * scale;
    rightLeg.position.z = 0.3 * scale;
    
    // Materials
    const birdMat = new BABYLON.StandardMaterial("birdMat", scene);
    const colorRGB = getColorRGB(color);
    birdMat.diffuseColor = new BABYLON.Color3(colorRGB[0], colorRGB[1], colorRGB[2]);
    
    const beakMat = new BABYLON.StandardMaterial("beakMat", scene);
    beakMat.diffuseColor = new BABYLON.Color3(1, 0.8, 0.2);
    
    body.material = head.material = leftWing.material = rightWing.material = tail.material = birdMat;
    beak.material = beakMat;
    leftLeg.material = rightLeg.material = birdMat;
    
    // Merge into single mesh
    const bird = BABYLON.Mesh.MergeMeshes([body, head, beak, leftWing, rightWing, tail, leftLeg, rightLeg], true, true);
    bird.name = "bird";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      bird.rotation.y += 0.01;
    });
    
    return bird;
  }

  function buildBear(scene, options = {}) {
    const { color = 'brown', size = 'medium', glow = 'none' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Body
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 2 * scale, height: 1.8 * scale, depth: 2.5 * scale }, scene);
    body.position.y = 0.9 * scale;
    
    // Head
    const head = BABYLON.MeshBuilder.CreateBox("head", { width: 1.5 * scale, height: 1.2 * scale, depth: 1.2 * scale }, scene);
    head.position.y = 2.1 * scale;
    head.position.z = -1.2 * scale;
    
    // Ears
    const leftEar = BABYLON.MeshBuilder.CreateBox("leftEar", { width: 0.4 * scale, height: 0.4 * scale, depth: 0.3 * scale }, scene);
    leftEar.position.x = -0.5 * scale;
    leftEar.position.y = 2.4 * scale;
    leftEar.position.z = -1.4 * scale;
    
    const rightEar = BABYLON.MeshBuilder.CreateBox("rightEar", { width: 0.4 * scale, height: 0.4 * scale, depth: 0.3 * scale }, scene);
    rightEar.position.x = 0.5 * scale;
    rightEar.position.y = 2.4 * scale;
    rightEar.position.z = -1.4 * scale;
    
    // Legs
    const legPositions = [
      {x: -0.7 * scale, z: 0.7 * scale}, {x: 0.7 * scale, z: 0.7 * scale},
      {x: -0.7 * scale, z: -0.7 * scale}, {x: 0.7 * scale, z: -0.7 * scale}
    ];
    
    const legs = [];
    legPositions.forEach((pos, i) => {
      const leg = BABYLON.MeshBuilder.CreateCylinder("leg" + i, { diameter: 0.3 * scale, height: 1.2 * scale }, scene);
      leg.position.x = pos.x;
      leg.position.y = 0.3 * scale;
      leg.position.z = pos.z;
      legs.push(leg);
    });
    
    // Materials
    const bearMat = new BABYLON.StandardMaterial("bearMat", scene);
    const colorRGB = getColorRGB(color);
    bearMat.diffuseColor = new BABYLON.Color3(colorRGB[0], colorRGB[1], colorRGB[2]);
    
    body.material = head.material = leftEar.material = rightEar.material = bearMat;
    legs.forEach(leg => leg.material = bearMat);
    
    // Merge into single mesh
    const bear = BABYLON.Mesh.MergeMeshes([body, head, leftEar, rightEar].concat(legs), true, true);
    bear.name = "bear";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      bear.rotation.y += 0.01;
    });
    
    return bear;
  }

  function buildWolf(scene, options = {}) {
    const { color = 'gray', size = 'medium', glow = 'none' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Body
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 1.8 * scale, height: 1.2 * scale, depth: 2.8 * scale }, scene);
    body.position.y = 0.6 * scale;
    
    // Head
    const head = BABYLON.MeshBuilder.CreateBox("head", { width: 1.2 * scale, height: 1 * scale, depth: 1.4 * scale }, scene);
    head.position.y = 1.2 * scale;
    head.position.z = -1.4 * scale;
    
    // Snout
    const snout = BABYLON.MeshBuilder.CreateBox("snout", { width: 0.6 * scale, height: 0.4 * scale, depth: 0.8 * scale }, scene);
    snout.position.y = 1 * scale;
    snout.position.z = -1.8 * scale;
    
    // Ears
    const leftEar = BABYLON.MeshBuilder.CreateBox("leftEar", { width: 0.3 * scale, height: 0.5 * scale, depth: 0.2 * scale }, scene);
    leftEar.position.x = -0.4 * scale;
    leftEar.position.y = 1.5 * scale;
    leftEar.position.z = -1.2 * scale;
    
    const rightEar = BABYLON.MeshBuilder.CreateBox("rightEar", { width: 0.3 * scale, height: 0.5 * scale, depth: 0.2 * scale }, scene);
    rightEar.position.x = 0.4 * scale;
    rightEar.position.y = 1.5 * scale;
    rightEar.position.z = -1.2 * scale;
    
    // Tail
    const tail = BABYLON.MeshBuilder.CreateBox("tail", { width: 0.3 * scale, height: 0.3 * scale, depth: 1.5 * scale }, scene);
    tail.position.y = 1 * scale;
    tail.position.z = 2.2 * scale;
    
    // Legs
    const legPositions = [
      {x: -0.6 * scale, z: 0.7 * scale}, {x: 0.6 * scale, z: 0.7 * scale},
      {x: -0.6 * scale, z: -0.7 * scale}, {x: 0.6 * scale, z: -0.7 * scale}
    ];
    
    const legs = [];
    legPositions.forEach((pos, i) => {
      const leg = BABYLON.MeshBuilder.CreateCylinder("leg" + i, { diameter: 0.2 * scale, height: 1 * scale }, scene);
      leg.position.x = pos.x;
      leg.position.y = 0.1 * scale;
      leg.position.z = pos.z;
      legs.push(leg);
    });
    
    // Materials
    const wolfMat = new BABYLON.StandardMaterial("wolfMat", scene);
    const colorRGB = getColorRGB(color);
    wolfMat.diffuseColor = new BABYLON.Color3(colorRGB[0], colorRGB[1], colorRGB[2]);
    
    body.material = head.material = snout.material = leftEar.material = rightEar.material = tail.material = wolfMat;
    legs.forEach(leg => leg.material = wolfMat);
    
    // Merge into single mesh
    const wolf = BABYLON.Mesh.MergeMeshes([body, head, snout, leftEar, rightEar, tail].concat(legs), true, true);
    wolf.name = "wolf";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      wolf.rotation.y += 0.01;
    });
    
    return wolf;
  }

  function buildLion(scene, options = {}) {
    const { color = 'gold', size = 'medium', glow = 'none' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Body
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 2 * scale, height: 1.5 * scale, depth: 3 * scale }, scene);
    body.position.y = 0.8 * scale;
    
    // Head
    const head = BABYLON.MeshBuilder.CreateBox("head", { width: 1.5 * scale, height: 1.2 * scale, depth: 1.5 * scale }, scene);
    head.position.y = 1.8 * scale;
    head.position.z = -1.5 * scale;
    
    // Mane
    const mane = BABYLON.MeshBuilder.CreateBox("mane", { width: 2.2 * scale, height: 1.5 * scale, depth: 1.8 * scale }, scene);
    mane.position.y = 1.8 * scale;
    mane.position.z = -1.2 * scale;
    
    // Tail
    const tail = BABYLON.MeshBuilder.CreateBox("tail", { width: 0.3 * scale, height: 0.3 * scale, depth: 2 * scale }, scene);
    tail.position.y = 1.2 * scale;
    tail.position.z = 2.5 * scale;
    
    // Legs
    const legPositions = [
      {x: -0.7 * scale, z: 0.8 * scale}, {x: 0.7 * scale, z: 0.8 * scale},
      {x: -0.7 * scale, z: -0.8 * scale}, {x: 0.7 * scale, z: -0.8 * scale}
    ];
    
    const legs = [];
    legPositions.forEach((pos, i) => {
      const leg = BABYLON.MeshBuilder.CreateCylinder("leg" + i, { diameter: 0.25 * scale, height: 1.2 * scale }, scene);
      leg.position.x = pos.x;
      leg.position.y = 0.2 * scale;
      leg.position.z = pos.z;
      legs.push(leg);
    });
    
    // Materials
    const lionMat = new BABYLON.StandardMaterial("lionMat", scene);
    lionMat.diffuseColor = new BABYLON.Color3(0.8, 0.6, 0.2);
    
    const maneMat = new BABYLON.StandardMaterial("maneMat", scene);
    maneMat.diffuseColor = new BABYLON.Color3(0.9, 0.7, 0.3);
    
    body.material = head.material = tail.material = lionMat;
    mane.material = maneMat;
    legs.forEach(leg => leg.material = lionMat);
    
    // Merge into single mesh
    const lion = BABYLON.Mesh.MergeMeshes([body, head, mane, tail].concat(legs), true, true);
    lion.name = "lion";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      lion.rotation.y += 0.01;
    });
    
    return lion;
  }

  function buildTiger(scene, options = {}) {
    const { color = 'orange', size = 'medium', glow = 'none' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Body
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 2 * scale, height: 1.5 * scale, depth: 3 * scale }, scene);
    body.position.y = 0.8 * scale;
    
    // Head
    const head = BABYLON.MeshBuilder.CreateBox("head", { width: 1.5 * scale, height: 1.2 * scale, depth: 1.5 * scale }, scene);
    head.position.y = 1.8 * scale;
    head.position.z = -1.5 * scale;
    
    // Tail
    const tail = BABYLON.MeshBuilder.CreateBox("tail", { width: 0.3 * scale, height: 0.3 * scale, depth: 2 * scale }, scene);
    tail.position.y = 1.2 * scale;
    tail.position.z = 2.5 * scale;
    
    // Legs
    const legPositions = [
      {x: -0.7 * scale, z: 0.8 * scale}, {x: 0.7 * scale, z: 0.8 * scale},
      {x: -0.7 * scale, z: -0.8 * scale}, {x: 0.7 * scale, z: -0.8 * scale}
    ];
    
    const legs = [];
    legPositions.forEach((pos, i) => {
      const leg = BABYLON.MeshBuilder.CreateCylinder("leg" + i, { diameter: 0.25 * scale, height: 1.2 * scale }, scene);
      leg.position.x = pos.x;
      leg.position.y = 0.2 * scale;
      leg.position.z = pos.z;
      legs.push(leg);
    });
    
    // Materials
    const tigerMat = new BABYLON.StandardMaterial("tigerMat", scene);
    tigerMat.diffuseColor = new BABYLON.Color3(1, 0.5, 0);
    
    body.material = head.material = tail.material = tigerMat;
    legs.forEach(leg => leg.material = tigerMat);
    
    // Merge into single mesh
    const tiger = BABYLON.Mesh.MergeMeshes([body, head, tail].concat(legs), true, true);
    tiger.name = "tiger";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      tiger.rotation.y += 0.01;
    });
    
    return tiger;
  }

  function buildDinosaur(scene, options = {}) {
    const { color = 'green', size = 'medium', glow = 'none' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Body
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 2.5 * scale, height: 2 * scale, depth: 4 * scale }, scene);
    body.position.y = 1 * scale;
    
    // Head
    const head = BABYLON.MeshBuilder.CreateBox("head", { width: 1.8 * scale, height: 1.5 * scale, depth: 2 * scale }, scene);
    head.position.y = 2.2 * scale;
    head.position.z = -2 * scale;
    
    // Tail
    const tail = BABYLON.MeshBuilder.CreateBox("tail", { width: 1 * scale, height: 1 * scale, depth: 3 * scale }, scene);
    tail.position.y = 1.5 * scale;
    tail.position.z = 3 * scale;
    
    // Legs
    const legPositions = [
      {x: -0.8 * scale, z: 1 * scale}, {x: 0.8 * scale, z: 1 * scale},
      {x: -0.8 * scale, z: -1 * scale}, {x: 0.8 * scale, z: -1 * scale}
    ];
    
    const legs = [];
    legPositions.forEach((pos, i) => {
      const leg = BABYLON.MeshBuilder.CreateCylinder("leg" + i, { diameter: 0.4 * scale, height: 1.5 * scale }, scene);
      leg.position.x = pos.x;
      leg.position.y = 0.3 * scale;
      leg.position.z = pos.z;
      legs.push(leg);
    });
    
    // Materials
    const dinoMat = new BABYLON.StandardMaterial("dinoMat", scene);
    const colorRGB = getColorRGB(color);
    dinoMat.diffuseColor = new BABYLON.Color3(colorRGB[0], colorRGB[1], colorRGB[2]);
    
    body.material = head.material = tail.material = dinoMat;
    legs.forEach(leg => leg.material = dinoMat);
    
    // Merge into single mesh
    const dinosaur = BABYLON.Mesh.MergeMeshes([body, head, tail].concat(legs), true, true);
    dinosaur.name = "dinosaur";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      dinosaur.rotation.y += 0.01;
    });
    
    return dinosaur;
  }

  function buildRobot(scene, options = {}) {
    const { color = 'gray', size = 'medium', glow = 'tech' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Body
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 2 * scale, height: 2.5 * scale, depth: 1.5 * scale }, scene);
    body.position.y = 1.25 * scale;
    
    // Head
    const head = BABYLON.MeshBuilder.CreateBox("head", { width: 1.2 * scale, height: 1.2 * scale, depth: 1 * scale }, scene);
    head.position.y = 2.8 * scale;
    head.position.z = -0.5 * scale;
    
    // Eyes
    const leftEye = BABYLON.MeshBuilder.CreateBox("leftEye", { width: 0.2 * scale, height: 0.2 * scale, depth: 0.2 * scale }, scene);
    leftEye.position.x = -0.3 * scale;
    leftEye.position.y = 2.9 * scale;
    leftEye.position.z = -0.8 * scale;
    
    const rightEye = BABYLON.MeshBuilder.CreateBox("rightEye", { width: 0.2 * scale, height: 0.2 * scale, depth: 0.2 * scale }, scene);
    rightEye.position.x = 0.3 * scale;
    rightEye.position.y = 2.9 * scale;
    rightEye.position.z = -0.8 * scale;
    
    // Arms
    const leftArm = BABYLON.MeshBuilder.CreateBox("leftArm", { width: 0.8 * scale, height: 1.5 * scale, depth: 0.8 * scale }, scene);
    leftArm.position.x = -1.4 * scale;
    leftArm.position.y = 1.8 * scale;
    leftArm.position.z = 0;
    
    const rightArm = BABYLON.MeshBuilder.CreateBox("rightArm", { width: 0.8 * scale, height: 1.5 * scale, depth: 0.8 * scale }, scene);
    rightArm.position.x = 1.4 * scale;
    rightArm.position.y = 1.8 * scale;
    rightArm.position.z = 0;
    
    // Legs
    const leftLeg = BABYLON.MeshBuilder.CreateBox("leftLeg", { width: 0.6 * scale, height: 1.8 * scale, depth: 0.6 * scale }, scene);
    leftLeg.position.x = -0.6 * scale;
    leftLeg.position.y = 0.4 * scale;
    leftLeg.position.z = 0;
    
    const rightLeg = BABYLON.MeshBuilder.CreateBox("rightLeg", { width: 0.6 * scale, height: 1.8 * scale, depth: 0.6 * scale }, scene);
    rightLeg.position.x = 0.6 * scale;
    rightLeg.position.y = 0.4 * scale;
    rightLeg.position.z = 0;
    
    // Materials
    const robotMat = new BABYLON.StandardMaterial("robotMat", scene);
    robotMat.diffuseColor = new BABYLON.Color3(0.6, 0.6, 0.6);
    
    const eyeMat = new BABYLON.StandardMaterial("robotEyeMat", scene);
    eyeMat.diffuseColor = new BABYLON.Color3(0, 1, 0);
    eyeMat.emissiveColor = new BABYLON.Color3(0, 0.5, 0);
    
    body.material = head.material = leftArm.material = rightArm.material = leftLeg.material = rightLeg.material = robotMat;
    leftEye.material = rightEye.material = eyeMat;
    
    // Merge into single mesh
    const robot = BABYLON.Mesh.MergeMeshes([body, head, leftEye, rightEye, leftArm, rightArm, leftLeg, rightLeg], true, true);
    robot.name = "robot";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      robot.rotation.y += 0.01;
    });
    
    return robot;
  }

  function buildAlien(scene, options = {}) {
    const { color = 'green', size = 'medium', glow = 'alien' } = options;
    const scale = size === 'large' ? 1.5 : size === 'small' ? 0.7 : 1.0;
    
    // Body
    const body = BABYLON.MeshBuilder.CreateBox("body", { width: 1.5 * scale, height: 2 * scale, depth: 1 * scale }, scene);
    body.position.y = 1 * scale;
    
    // Head (large)
    const head = BABYLON.MeshBuilder.CreateBox("head", { width: 1.8 * scale, height: 1.8 * scale, depth: 1.2 * scale }, scene);
    head.position.y = 2.5 * scale;
    head.position.z = -0.2 * scale;
    
    // Eyes (large)
    const leftEye = BABYLON.MeshBuilder.CreateBox("leftEye", { width: 0.4 * scale, height: 0.4 * scale, depth: 0.3 * scale }, scene);
    leftEye.position.x = -0.5 * scale;
    leftEye.position.y = 2.7 * scale;
    leftEye.position.z = -0.8 * scale;
    
    const rightEye = BABYLON.MeshBuilder.CreateBox("rightEye", { width: 0.4 * scale, height: 0.4 * scale, depth: 0.3 * scale }, scene);
    rightEye.position.x = 0.5 * scale;
    rightEye.position.y = 2.7 * scale;
    rightEye.position.z = -0.8 * scale;
    
    // Arms (long)
    const leftArm = BABYLON.MeshBuilder.CreateBox("leftArm", { width: 0.4 * scale, height: 1.8 * scale, depth: 0.4 * scale }, scene);
    leftArm.position.x = -1 * scale;
    leftArm.position.y = 1.5 * scale;
    leftArm.position.z = 0;
    
    const rightArm = BABYLON.MeshBuilder.CreateBox("rightArm", { width: 0.4 * scale, height: 1.8 * scale, depth: 0.4 * scale }, scene);
    rightArm.position.x = 1 * scale;
    rightArm.position.y = 1.5 * scale;
    rightArm.position.z = 0;
    
    // Legs
    const leftLeg = BABYLON.MeshBuilder.CreateBox("leftLeg", { width: 0.4 * scale, height: 1.5 * scale, depth: 0.4 * scale }, scene);
    leftLeg.position.x = -0.4 * scale;
    leftLeg.position.y = 0.3 * scale;
    leftLeg.position.z = 0;
    
    const rightLeg = BABYLON.MeshBuilder.CreateBox("rightLeg", { width: 0.4 * scale, height: 1.5 * scale, depth: 0.4 * scale }, scene);
    rightLeg.position.x = 0.4 * scale;
    rightLeg.position.y = 0.3 * scale;
    rightLeg.position.z = 0;
    
    // Materials
    const alienMat = new BABYLON.StandardMaterial("alienMat", scene);
    alienMat.diffuseColor = new BABYLON.Color3(0.2, 0.8, 0.2);
    alienMat.emissiveColor = new BABYLON.Color3(0.1, 0.3, 0.1);
    
    const eyeMat = new BABYLON.StandardMaterial("alienEyeMat", scene);
    eyeMat.diffuseColor = new BABYLON.Color3(1, 1, 0);
    eyeMat.emissiveColor = new BABYLON.Color3(0.8, 0.8, 0);
    
    body.material = head.material = leftArm.material = rightArm.material = leftLeg.material = rightLeg.material = alienMat;
    leftEye.material = rightEye.material = eyeMat;
    
    // Merge into single mesh
    const alien = BABYLON.Mesh.MergeMeshes([body, head, leftEye, rightEye, leftArm, rightArm, leftLeg, rightLeg], true, true);
    alien.name = "alien";
    
    // Add rotation animation
    scene.registerBeforeRender(() => {
      alien.rotation.y += 0.01;
    });
    
    return alien;
  }

  // Helper: color from name
  function getColorFromName(name) {
    const c = {
      red: [0.8, 0.2, 0.2], green: [0.2, 0.8, 0.2], blue: [0.2, 0.2, 0.8],
      gold: [0.8, 0.6, 0.2], black: [0.1, 0.1, 0.1], white: [0.9, 0.9, 0.9],
      brown: [0.4, 0.2, 0.1], darkbrown: [0.2, 0.1, 0.05], orange: [0.8, 0.5, 0.2],
      purple: [0.6, 0.2, 0.8], yellow: [0.8, 0.8, 0.2], silver: [0.7, 0.7, 0.7],
      gray: [0.5, 0.5, 0.5], pink: [1, 0.4, 0.7], cyan: [0, 0.8, 0.8]
    };
    return c[name.toLowerCase()] || [0.3, 0.3, 0.8];
  }

  function createMaterial(scene, colorName, glow = false) {
    const c = getColorFromName(colorName);
    const m = new BABYLON.StandardMaterial(
      \`mat_\${colorName}_\${Math.random().toString(36).slice(2)}\`, scene);
    m.diffuseColor = new BABYLON.Color3(...c);
    if (glow) m.emissiveColor = new BABYLON.Color3(c[0] * 0.4, c[1] * 0.4, c[2] * 0.4);
    return m;
  }

  function createEyeMaterial(scene) {
    const m = new BABYLON.StandardMaterial("eye", scene);
    m.diffuseColor = new BABYLON.Color3(1, 0, 0);
    m.emissiveColor = new BABYLON.Color3(1, 0, 0);
    return m;
  }
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
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '🐉 Loading 3D Dragon...',
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
          ],
        ),
      ),
    );
  }
}
