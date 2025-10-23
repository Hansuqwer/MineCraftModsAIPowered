// Couch Creator - Procedural Babylon.js couch builder
function buildCouch(scene, options = {}) {
  console.log('🛋️ Building couch with options:', options);
  
  const {
    theme = 'basic',
    colorScheme = ['red', 'black', 'gold'],
    material = 'leather',
    style = 'minecraft_blocky',
    size = 'medium',
    specialFeatures = []
  } = options;

  const scale = getSizeMultiplier(size);
  const hasGlow = specialFeatures.includes('glowing');
  
  // Main seat
  const seat = BABYLON.MeshBuilder.CreateBox("seat", {
    width: 3 * scale,
    height: 0.5 * scale,
    depth: 1.5 * scale
  }, scene);
  seat.position.y = 0;
  
  // Back rest
  const back = BABYLON.MeshBuilder.CreateBox("back", {
    width: 3 * scale,
    height: 1.2 * scale,
    depth: 0.2 * scale
  }, scene);
  back.position.y = 0.6 * scale;
  back.position.z = -0.6 * scale;
  
  // Arm rests
  const leftArm = BABYLON.MeshBuilder.CreateBox("leftArm", {
    width: 0.3 * scale,
    height: 0.8 * scale,
    depth: 1.5 * scale
  }, scene);
  leftArm.position.x = -1.35 * scale;
  leftArm.position.y = 0.4 * scale;
  
  const rightArm = BABYLON.MeshBuilder.CreateBox("rightArm", {
    width: 0.3 * scale,
    height: 0.8 * scale,
    depth: 1.5 * scale
  }, scene);
  rightArm.position.x = 1.35 * scale;
  rightArm.position.y = 0.4 * scale;
  
  // Cushions
  const cushion1 = BABYLON.MeshBuilder.CreateBox("cushion1", {
    width: 1.2 * scale,
    height: 0.3 * scale,
    depth: 1.2 * scale
  }, scene);
  cushion1.position.x = -0.6 * scale;
  cushion1.position.y = 0.25 * scale;
  cushion1.position.z = 0;
  
  const cushion2 = BABYLON.MeshBuilder.CreateBox("cushion2", {
    width: 1.2 * scale,
    height: 0.3 * scale,
    depth: 1.2 * scale
  }, scene);
  cushion2.position.x = 0.6 * scale;
  cushion2.position.y = 0.25 * scale;
  cushion2.position.z = 0;
  
  // Create materials
  const mainMat = createMaterial(scene, colorScheme[0], hasGlow);
  const accentMat = createMaterial(scene, colorScheme[1] || colorScheme[0], hasGlow);
  
  // Apply materials
  seat.material = back.material = leftArm.material = rightArm.material = mainMat;
  
  // Apply theme-specific decorations
  if (theme === 'dragon') {
    applyDragonTheme(cushion1, cushion2, accentMat, scene);
  } else {
    cushion1.material = cushion2.material = accentMat;
  }
  
  // Merge into single mesh
  const couch = BABYLON.Mesh.MergeMeshes([
    seat, back, leftArm, rightArm, cushion1, cushion2
  ], true, true);
  couch.name = "couch";
  
  // Add rotation animation
  scene.registerBeforeRender(() => {
    couch.rotation.y += 0.005;
  });
  
  console.log('✅ Couch created successfully!');
  return couch;
}

function applyDragonTheme(cushion1, cushion2, material, scene) {
  // Create dragon texture
  const dragonTex = new BABYLON.DynamicTexture("dragonTex", {width: 512, height: 512}, scene);
  const ctx = dragonTex.getContext();
  
  // Background
  ctx.fillStyle = "#550000";
  ctx.fillRect(0, 0, 512, 512);
  
  // Dragon pattern
  ctx.fillStyle = "#ff0000";
  ctx.font = "48px Arial";
  ctx.textAlign = "center";
  ctx.fillText("🐉", 256, 200);
  
  // Scale pattern
  ctx.fillStyle = "#00ff00";
  ctx.font = "24px Arial";
  ctx.fillText("◊◊◊", 256, 300);
  
  dragonTex.update();
  
  // Apply texture to cushions
  const dragonMat = new BABYLON.StandardMaterial("dragonMat", scene);
  dragonMat.diffuseTexture = dragonTex;
  dragonMat.emissiveColor = new BABYLON.Color3(0.1, 0, 0);
  
  cushion1.material = cushion2.material = dragonMat;
}

function createMaterial(scene, colorName, hasGlow = false) {
  const mat = new BABYLON.StandardMaterial("couchMat", scene);
  const color = getColorFromName(colorName);
  mat.diffuseColor = new BABYLON.Color3(color[0], color[1], color[2]);
  
  if (hasGlow) {
    mat.emissiveColor = new BABYLON.Color3(color[0] * 0.2, color[1] * 0.2, color[2] * 0.2);
  }
  
  return mat;
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
    'silver': [0.7, 0.7, 0.7]
  };
  return colors[colorName.toLowerCase()] || [0.2, 0.2, 0.8];
}

function getSizeMultiplier(size) {
  switch (size.toLowerCase()) {
    case 'small': return 0.7;
    case 'large': return 1.5;
    case 'giant': return 2.0;
    default: return 1.0;
  }
}
