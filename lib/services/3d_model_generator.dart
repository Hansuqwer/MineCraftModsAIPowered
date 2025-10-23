import '../services/ai_content_generator.dart';

/// 3D Model Generator - Creates Babylon.js models from blueprints
class Model3DGenerator {
  
  /// Generate Babylon.js code for a model based on blueprint
  static String generateBabylonCode(ModelBlueprint blueprint) {
    print('🎨 [3D_GENERATOR] Creating model for: ${blueprint.object}');
    
    final objectType = blueprint.object.toLowerCase();
    
    switch (objectType) {
      case 'couch':
        return _generateCouchCode(blueprint);
      case 'sword':
        return _generateSwordCode(blueprint);
      case 'dragon':
        return _generateDragonCode(blueprint);
      case 'chair':
        return _generateChairCode(blueprint);
      case 'table':
        return _generateTableCode(blueprint);
      case 'house':
        return _generateHouseCode(blueprint);
      case 'car':
        return _generateCarCode(blueprint);
      default:
        return _generateDefaultCode(blueprint);
    }
  }

  static String _generateCouchCode(ModelBlueprint blueprint) {
    final colors = _getColorValues(blueprint.colorScheme);
    final hasGlow = blueprint.specialFeatures.contains('glowing');
    final size = _getSizeMultiplier(blueprint.size);
    
    return '''
function createCouch(scene) {
  console.log('🛋️ Creating ${blueprint.theme} couch...');
  
  // Main seat
  const seat = BABYLON.MeshBuilder.CreateBox("seat", {
    width: ${3 * size}, height: ${0.5 * size}, depth: ${1.5 * size}
  }, scene);
  seat.position.y = 0;
  
  // Back rest
  const back = BABYLON.MeshBuilder.CreateBox("back", {
    width: ${3 * size}, height: ${1.2 * size}, depth: ${0.2 * size}
  }, scene);
  back.position.y = ${0.6 * size};
  back.position.z = -${0.6 * size};
  
  // Arm rests
  const leftArm = BABYLON.MeshBuilder.CreateBox("leftArm", {
    width: ${0.3 * size}, height: ${0.8 * size}, depth: ${1.5 * size}
  }, scene);
  leftArm.position.x = -${1.35 * size};
  leftArm.position.y = ${0.4 * size};
  
  const rightArm = BABYLON.MeshBuilder.CreateBox("rightArm", {
    width: ${0.3 * size}, height: ${0.8 * size}, depth: ${1.5 * size}
  }, scene);
  rightArm.position.x = ${1.35 * size};
  rightArm.position.y = ${0.4 * size};
  
  // Cushions
  const cushion1 = BABYLON.MeshBuilder.CreateBox("cushion1", {
    width: ${1.2 * size}, height: ${0.3 * size}, depth: ${1.2 * size}
  }, scene);
  cushion1.position.x = -${0.6 * size};
  cushion1.position.y = ${0.25 * size};
  cushion1.position.z = 0;
  
  const cushion2 = BABYLON.MeshBuilder.CreateBox("cushion2", {
    width: ${1.2 * size}, height: ${0.3 * size}, depth: ${1.2 * size}
  }, scene);
  cushion2.position.x = ${0.6 * size};
  cushion2.position.y = ${0.25 * size};
  cushion2.position.z = 0;
  
  // Materials
  const mainMat = new BABYLON.StandardMaterial("couchMat", scene);
  mainMat.diffuseColor = new BABYLON.Color3(${colors[0]});
  ${hasGlow ? 'mainMat.emissiveColor = new BABYLON.Color3(' + colors[0].toString() + ' * 0.2);' : ''}
  
  const accentMat = new BABYLON.StandardMaterial("accentMat", scene);
  accentMat.diffuseColor = new BABYLON.Color3(${colors[1]});
  ${hasGlow ? 'accentMat.emissiveColor = new BABYLON.Color3(' + colors[1].toString() + ' * 0.3);' : ''}
  
  // Apply materials
  seat.material = back.material = leftArm.material = rightArm.material = mainMat;
  cushion1.material = cushion2.material = accentMat;
  
  // Dragon theme decorations
  ${blueprint.theme == 'dragon' ? _generateDragonDecorations() : ''}
  
  // Merge into single mesh
  const couch = BABYLON.Mesh.MergeMeshes([seat, back, leftArm, rightArm, cushion1, cushion2], true, true);
  couch.name = "couch";
  
  // Add rotation animation
  scene.registerBeforeRender(() => {
    couch.rotation.y += 0.005;
  });
  
  console.log('✅ Couch created successfully!');
  return couch;
}
''';
  }

  static String _generateSwordCode(ModelBlueprint blueprint) {
    final colors = _getColorValues(blueprint.colorScheme);
    final hasGlow = blueprint.specialFeatures.contains('glowing');
    final size = _getSizeMultiplier(blueprint.size);
    
    return '''
function createSword(scene) {
  console.log('⚔️ Creating ${blueprint.theme} sword...');
  
  // Blade
  const blade = BABYLON.MeshBuilder.CreateBox("blade", {
    width: ${0.2 * size}, height: ${2.5 * size}, depth: ${0.1 * size}
  }, scene);
  blade.position.y = 0;
  blade.rotation.z = Math.PI / 6;
  
  // Handle
  const handle = BABYLON.MeshBuilder.CreateCylinder("handle", {
    diameter: ${0.2 * size}, height: ${0.6 * size}
  }, scene);
  handle.position.y = -${1.5 * size};
  handle.rotation.z = Math.PI / 6;
  
  // Guard
  const guard = BABYLON.MeshBuilder.CreateBox("guard", {
    width: ${0.8 * size}, height: ${0.1 * size}, depth: ${0.1 * size}
  }, scene);
  guard.position.y = -${1.2 * size};
  guard.rotation.z = Math.PI / 6;
  
  // Pommel
  const pommel = BABYLON.MeshBuilder.CreateSphere("pommel", {
    diameter: ${0.3 * size}
  }, scene);
  pommel.position.y = -${1.8 * size};
  
  // Materials
  const bladeMat = new BABYLON.StandardMaterial("bladeMat", scene);
  bladeMat.diffuseColor = new BABYLON.Color3(${colors[0]});
  bladeMat.specularColor = new BABYLON.Color3(0.8, 0.8, 0.8);
  ${hasGlow ? 'bladeMat.emissiveColor = new BABYLON.Color3(' + colors[0].toString() + ' * 0.4);' : ''}
  
  const handleMat = new BABYLON.StandardMaterial("handleMat", scene);
  handleMat.diffuseColor = new BABYLON.Color3(${colors[1]});
  
  // Apply materials
  blade.material = bladeMat;
  handle.material = guard.material = pommel.material = handleMat;
  
  // Magical effects
  ${blueprint.theme == 'magical' ? _generateMagicalEffects() : ''}
  
  // Merge into single mesh
  const sword = BABYLON.Mesh.MergeMeshes([blade, handle, guard, pommel], true, true);
  sword.name = "sword";
  
  // Add rotation animation
  scene.registerBeforeRender(() => {
    sword.rotation.y += 0.01;
  });
  
  console.log('✅ Sword created successfully!');
  return sword;
}
''';
  }

  static String _generateDragonCode(ModelBlueprint blueprint) {
    // Use the existing detailed dragon code we created
    return '''
function createDragon(scene) {
  console.log('🐉 Creating ${blueprint.theme} dragon...');
  
  // Main body
  const body = BABYLON.MeshBuilder.CreateBox("body", {
    width: 2.5, height: 2.5, depth: 4
  }, scene);
  body.position.y = 1.2;
  
  // Head
  const head = BABYLON.MeshBuilder.CreateBox("head", {
    width: 2, height: 2, depth: 2
  }, scene);
  head.position.y = 2.5;
  head.position.z = -2;
  
  // Wings
  const leftWing = BABYLON.MeshBuilder.CreateBox("leftWing", {
    width: 4, height: 0.3, depth: 3
  }, scene);
  leftWing.position.x = -2;
  leftWing.position.y = 2.5;
  leftWing.position.z = 0;
  
  const rightWing = BABYLON.MeshBuilder.CreateBox("rightWing", {
    width: 4, height: 0.3, depth: 3
  }, scene);
  rightWing.position.x = 2;
  rightWing.position.y = 2.5;
  rightWing.position.z = 0;
  
  // Tail
  const tail = BABYLON.MeshBuilder.CreateBox("tail", {
    width: 1, height: 1, depth: 2
  }, scene);
  tail.position.y = 1.5;
  tail.position.z = 2.5;
  
  // Eyes
  const leftEye = BABYLON.MeshBuilder.CreateBox("leftEye", {
    width: 0.15, height: 0.15, depth: 0.15
  }, scene);
  leftEye.position.x = -0.3;
  leftEye.position.y = 2.2;
  leftEye.position.z = -2.2;
  
  const rightEye = BABYLON.MeshBuilder.CreateBox("rightEye", {
    width: 0.15, height: 0.15, depth: 0.15
  }, scene);
  rightEye.position.x = 0.3;
  rightEye.position.y = 2.2;
  rightEye.position.z = -2.2;
  
  // Materials
  const dragonMat = new BABYLON.StandardMaterial("dragonMat", scene);
  dragonMat.diffuseColor = new BABYLON.Color3(0.8, 0.2, 0.2);
  dragonMat.emissiveColor = new BABYLON.Color3(0.1, 0.05, 0.05);
  
  const eyeMat = new BABYLON.StandardMaterial("eyeMat", scene);
  eyeMat.diffuseColor = new BABYLON.Color3(1, 0, 0);
  eyeMat.emissiveColor = new BABYLON.Color3(1, 0, 0);
  
  // Apply materials
  body.material = head.material = leftWing.material = rightWing.material = tail.material = dragonMat;
  leftEye.material = rightEye.material = eyeMat;
  
  // Merge into single mesh
  const dragon = BABYLON.Mesh.MergeMeshes([body, head, leftWing, rightWing, tail, leftEye, rightEye], true, true);
  dragon.name = "dragon";
  
  // Add rotation animation
  scene.registerBeforeRender(() => {
    dragon.rotation.y += 0.01;
  });
  
  console.log('✅ Dragon created successfully!');
  return dragon;
}
''';
  }

  static String _generateChairCode(ModelBlueprint blueprint) {
    final colors = _getColorValues(blueprint.colorScheme);
    final size = _getSizeMultiplier(blueprint.size);
    
    return '''
function createChair(scene) {
  console.log('🪑 Creating ${blueprint.theme} chair...');
  
  // Seat
  const seat = BABYLON.MeshBuilder.CreateBox("seat", {
    width: ${1.0 * size}, height: ${0.2 * size}, depth: ${1.0 * size}
  }, scene);
  seat.position.y = 0;
  
  // Back
  const back = BABYLON.MeshBuilder.CreateBox("back", {
    width: ${1.0 * size}, height: ${1.2 * size}, depth: ${0.2 * size}
  }, scene);
  back.position.y = ${0.5 * size};
  back.position.z = -${0.4 * size};
  
  // Legs
  const legPositions = [
    {x: -${0.4 * size}, z: ${0.4 * size}},
    {x: ${0.4 * size}, z: ${0.4 * size}},
    {x: -${0.4 * size}, z: -${0.4 * size}},
    {x: ${0.4 * size}, z: -${0.4 * size}}
  ];
  
  const legs = [];
  legPositions.forEach((pos, i) => {
    const leg = BABYLON.MeshBuilder.CreateCylinder("leg" + i, {
      diameter: ${0.15 * size}, height: ${0.8 * size}
    }, scene);
    leg.position.x = pos.x;
    leg.position.y = -${0.5 * size};
    leg.position.z = pos.z;
    legs.push(leg);
  });
  
  // Material
  const chairMat = new BABYLON.StandardMaterial("chairMat", scene);
  chairMat.diffuseColor = new BABYLON.Color3(${colors[0]});
  
  // Apply material
  seat.material = back.material = chairMat;
  legs.forEach(leg => leg.material = chairMat);
  
  // Merge into single mesh
  const chair = BABYLON.Mesh.MergeMeshes([seat, back].concat(legs), true, true);
  chair.name = "chair";
  
  // Add rotation animation
  scene.registerBeforeRender(() => {
    chair.rotation.y += 0.01;
  });
  
  console.log('✅ Chair created successfully!');
  return chair;
}
''';
  }

  static String _generateTableCode(ModelBlueprint blueprint) {
    final colors = _getColorValues(blueprint.colorScheme);
    final size = _getSizeMultiplier(blueprint.size);
    
    return '''
function createTable(scene) {
  console.log('🪑 Creating ${blueprint.theme} table...');
  
  // Table top
  const top = BABYLON.MeshBuilder.CreateBox("top", {
    width: ${2.0 * size}, height: ${0.1 * size}, depth: ${1.0 * size}
  }, scene);
  top.position.y = ${0.4 * size};
  
  // Legs
  const legPositions = [
    {x: -${0.8 * size}, z: ${0.3 * size}},
    {x: ${0.8 * size}, z: ${0.3 * size}},
    {x: -${0.8 * size}, z: -${0.3 * size}},
    {x: ${0.8 * size}, z: -${0.3 * size}}
  ];
  
  const legs = [];
  legPositions.forEach((pos, i) => {
    const leg = BABYLON.MeshBuilder.CreateCylinder("leg" + i, {
      diameter: ${0.1 * size}, height: ${0.8 * size}
    }, scene);
    leg.position.x = pos.x;
    leg.position.y = 0;
    leg.position.z = pos.z;
    legs.push(leg);
  });
  
  // Material
  const tableMat = new BABYLON.StandardMaterial("tableMat", scene);
  tableMat.diffuseColor = new BABYLON.Color3(${colors[0]});
  
  // Apply material
  top.material = tableMat;
  legs.forEach(leg => leg.material = tableMat);
  
  // Merge into single mesh
  const table = BABYLON.Mesh.MergeMeshes([top].concat(legs), true, true);
  table.name = "table";
  
  // Add rotation animation
  scene.registerBeforeRender(() => {
    table.rotation.y += 0.01;
  });
  
  console.log('✅ Table created successfully!');
  return table;
}
''';
  }

  static String _generateHouseCode(ModelBlueprint blueprint) {
    final colors = _getColorValues(blueprint.colorScheme);
    final size = _getSizeMultiplier(blueprint.size);
    
    return '''
function createHouse(scene) {
  console.log('🏠 Creating ${blueprint.theme} house...');
  
  // Main structure
  const walls = BABYLON.MeshBuilder.CreateBox("walls", {
    width: ${3 * size}, height: ${2 * size}, depth: ${3 * size}
  }, scene);
  walls.position.y = ${1 * size};
  
  // Roof
  const roof = BABYLON.MeshBuilder.CreateBox("roof", {
    width: ${3.5 * size}, height: ${1 * size}, depth: ${3.5 * size}
  }, scene);
  roof.position.y = ${2.5 * size};
  roof.rotation.x = Math.PI / 4;
  
  // Door
  const door = BABYLON.MeshBuilder.CreateBox("door", {
    width: ${0.8 * size}, height: ${1.5 * size}, depth: ${0.1 * size}
  }, scene);
  door.position.y = ${0.75 * size};
  door.position.z = ${1.5 * size};
  
  // Windows
  const window1 = BABYLON.MeshBuilder.CreateBox("window1", {
    width: ${0.6 * size}, height: ${0.6 * size}, depth: ${0.1 * size}
  }, scene);
  window1.position.x = -${1 * size};
  window1.position.y = ${1.2 * size};
  window1.position.z = ${1.5 * size};
  
  const window2 = BABYLON.MeshBuilder.CreateBox("window2", {
    width: ${0.6 * size}, height: ${0.6 * size}, depth: ${0.1 * size}
  }, scene);
  window2.position.x = ${1 * size};
  window2.position.y = ${1.2 * size};
  window2.position.z = ${1.5 * size};
  
  // Materials
  const wallMat = new BABYLON.StandardMaterial("wallMat", scene);
  wallMat.diffuseColor = new BABYLON.Color3(${colors[0]});
  
  const roofMat = new BABYLON.StandardMaterial("roofMat", scene);
  roofMat.diffuseColor = new BABYLON.Color3(${colors[1]});
  
  const doorMat = new BABYLON.StandardMaterial("doorMat", scene);
  doorMat.diffuseColor = new BABYLON.Color3(0.4, 0.2, 0.1);
  
  const windowMat = new BABYLON.StandardMaterial("windowMat", scene);
  windowMat.diffuseColor = new BABYLON.Color3(0.7, 0.9, 1.0);
  windowMat.emissiveColor = new BABYLON.Color3(0.1, 0.1, 0.2);
  
  // Apply materials
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
  
  console.log('✅ House created successfully!');
  return house;
}
''';
  }

  static String _generateCarCode(ModelBlueprint blueprint) {
    final colors = _getColorValues(blueprint.colorScheme);
    final size = _getSizeMultiplier(blueprint.size);
    
    return '''
function createCar(scene) {
  console.log('🚗 Creating ${blueprint.theme} car...');
  
  // Main body
  const body = BABYLON.MeshBuilder.CreateBox("body", {
    width: ${2 * size}, height: ${0.8 * size}, depth: ${4 * size}
  }, scene);
  body.position.y = ${0.4 * size};
  
  // Roof
  const roof = BABYLON.MeshBuilder.CreateBox("roof", {
    width: ${1.6 * size}, height: ${0.6 * size}, depth: ${2.5 * size}
  }, scene);
  roof.position.y = ${1.1 * size};
  roof.position.z = -${0.3 * size};
  
  // Wheels
  const wheelPositions = [
    {x: -${0.7 * size}, z: ${1.2 * size}},
    {x: ${0.7 * size}, z: ${1.2 * size}},
    {x: -${0.7 * size}, z: -${1.2 * size}},
    {x: ${0.7 * size}, z: -${1.2 * size}}
  ];
  
  const wheels = [];
  wheelPositions.forEach((pos, i) => {
    const wheel = BABYLON.MeshBuilder.CreateCylinder("wheel" + i, {
      diameter: ${0.6 * size}, height: ${0.3 * size}
    }, scene);
    wheel.position.x = pos.x;
    wheel.position.y = ${0.3 * size};
    wheel.position.z = pos.z;
    wheel.rotation.z = Math.PI / 2;
    wheels.push(wheel);
  });
  
  // Materials
  const bodyMat = new BABYLON.StandardMaterial("bodyMat", scene);
  bodyMat.diffuseColor = new BABYLON.Color3(${colors[0]});
  bodyMat.specularColor = new BABYLON.Color3(0.8, 0.8, 0.8);
  
  const wheelMat = new BABYLON.StandardMaterial("wheelMat", scene);
  wheelMat.diffuseColor = new BABYLON.Color3(0.1, 0.1, 0.1);
  
  // Apply materials
  body.material = roof.material = bodyMat;
  wheels.forEach(wheel => wheel.material = wheelMat);
  
  // Merge into single mesh
  const car = BABYLON.Mesh.MergeMeshes([body, roof].concat(wheels), true, true);
  car.name = "car";
  
  // Add rotation animation
  scene.registerBeforeRender(() => {
    car.rotation.y += 0.01;
  });
  
  console.log('✅ Car created successfully!');
  return car;
}
''';
  }

  static String _generateDefaultCode(ModelBlueprint blueprint) {
    final colors = _getColorValues(blueprint.colorScheme);
    final size = _getSizeMultiplier(blueprint.size);
    
    return '''
function createDefault(scene) {
  console.log('📦 Creating ${blueprint.theme} ${blueprint.object}...');
  
  // Create a basic box
  const box = BABYLON.MeshBuilder.CreateBox("box", {
    width: ${2 * size}, height: ${2 * size}, depth: ${2 * size}
  }, scene);
  
  // Material
  const mat = new BABYLON.StandardMaterial("defaultMat", scene);
  mat.diffuseColor = new BABYLON.Color3(${colors[0]});
  
  box.material = mat;
  box.name = "${blueprint.object}";
  
  // Add rotation animation
  scene.registerBeforeRender(() => {
    box.rotation.y += 0.01;
  });
  
  console.log('✅ ${blueprint.object} created successfully!');
  return box;
}
''';
  }

  static String _generateDragonDecorations() {
    return '''
  // Dragon decorations on cushions
  const dragonTex = new BABYLON.DynamicTexture("dragonTex", {width: 256, height: 256}, scene);
  const ctx = dragonTex.getContext();
  ctx.fillStyle = "#ff0000";
  ctx.fillRect(0, 0, 256, 256);
  ctx.fillStyle = "#ffff00";
  ctx.font = "48px Arial";
  ctx.textAlign = "center";
  ctx.fillText("🐉", 128, 140);
  dragonTex.update();
  
  const dragonMat = new BABYLON.StandardMaterial("dragonMat", scene);
  dragonMat.diffuseTexture = dragonTex;
  cushion1.material = cushion2.material = dragonMat;
''';
  }

  static String _generateMagicalEffects() {
    return '''
  // Magical glow effect
  const glowLayer = new BABYLON.GlowLayer("glow", scene);
  glowLayer.intensity = 0.8;
  glowLayer.addIncludedOnlyMesh(blade);
''';
  }

  static List<double> _getColorValues(List<String> colorScheme) {
    final colorMap = {
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
    };
    
    final primaryColor = colorMap[colorScheme[0]] ?? [0.2, 0.2, 0.8];
    final secondaryColor = colorScheme.length > 1 
        ? (colorMap[colorScheme[1]] ?? [0.8, 0.8, 0.2])
        : primaryColor;
    
    return [primaryColor[0], primaryColor[1], primaryColor[2], 
            secondaryColor[0], secondaryColor[1], secondaryColor[2]];
  }

  static double _getSizeMultiplier(String size) {
    switch (size.toLowerCase()) {
      case 'small': return 0.7;
      case 'large': return 1.5;
      case 'giant': return 2.0;
      default: return 1.0;
    }
  }
}
