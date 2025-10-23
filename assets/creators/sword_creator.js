// Sword Creator - Procedural Babylon.js sword builder
function buildSword(scene, options = {}) {
  console.log('⚔️ Building sword with options:', options);
  
  const {
    theme = 'basic',
    colorScheme = ['blue', 'silver', 'purple'],
    material = 'metal',
    style = 'minecraft_blocky',
    size = 'medium',
    specialFeatures = []
  } = options;

  const scale = getSizeMultiplier(size);
  const hasGlow = specialFeatures.includes('glowing');
  const isMagical = specialFeatures.includes('magical');
  
  // Blade
  const blade = BABYLON.MeshBuilder.CreateBox("blade", {
    width: 0.2 * scale,
    height: 2.5 * scale,
    depth: 0.1 * scale
  }, scene);
  blade.position.y = 0;
  blade.rotation.z = Math.PI / 6;
  
  // Handle
  const handle = BABYLON.MeshBuilder.CreateCylinder("handle", {
    diameter: 0.2 * scale,
    height: 0.6 * scale
  }, scene);
  handle.position.y = -1.5 * scale;
  handle.rotation.z = Math.PI / 6;
  
  // Guard
  const guard = BABYLON.MeshBuilder.CreateBox("guard", {
    width: 0.8 * scale,
    height: 0.1 * scale,
    depth: 0.1 * scale
  }, scene);
  guard.position.y = -1.2 * scale;
  guard.rotation.z = Math.PI / 6;
  
  // Pommel
  const pommel = BABYLON.MeshBuilder.CreateSphere("pommel", {
    diameter: 0.3 * scale
  }, scene);
  pommel.position.y = -1.8 * scale;
  
  // Create materials
  const bladeMat = createBladeMaterial(scene, colorScheme[0], hasGlow, isMagical);
  const handleMat = createHandleMaterial(scene, colorScheme[1] || colorScheme[0]);
  
  // Apply materials
  blade.material = bladeMat;
  handle.material = guard.material = pommel.material = handleMat;
  
  // Apply magical effects
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
  
  console.log('✅ Sword created successfully!');
  return sword;
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

function applyMagicalEffects(blade, scene) {
  // Create magical glow layer
  const glowLayer = new BABYLON.GlowLayer("magicalGlow", scene);
  glowLayer.intensity = 0.8;
  glowLayer.addIncludedOnlyMesh(blade);
  
  // Add magical particles (if available)
  if (BABYLON.ParticleSystem) {
    const particleSystem = new BABYLON.ParticleSystem("magicalParticles", 2000, scene);
    particleSystem.particleTexture = new BABYLON.Texture("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==", scene);
    particleSystem.emitter = blade;
    particleSystem.minEmitBox = new BABYLON.Vector3(-0.1, -1, -0.1);
    particleSystem.maxEmitBox = new BABYLON.Vector3(0.1, 1, 0.1);
    particleSystem.color1 = new BABYLON.Color4(0.7, 0.8, 1.0, 1.0);
    particleSystem.color2 = new BABYLON.Color4(0.2, 0.5, 1.0, 1.0);
    particleSystem.colorDead = new BABYLON.Color4(0, 0, 0.2, 0.0);
    particleSystem.minSize = 0.1;
    particleSystem.maxSize = 0.3;
    particleSystem.minLifeTime = 0.3;
    particleSystem.maxLifeTime = 1.5;
    particleSystem.emitRate = 1500;
    particleSystem.gravity = new BABYLON.Vector3(0, -9.81, 0);
    particleSystem.direction1 = new BABYLON.Vector3(-1, 1, -1);
    particleSystem.direction2 = new BABYLON.Vector3(1, 1, 1);
    particleSystem.minAngularSpeed = 0;
    particleSystem.maxAngularSpeed = Math.PI;
    particleSystem.minEmitPower = 1;
    particleSystem.maxEmitPower = 3;
    particleSystem.updateSpeed = 0.025;
    particleSystem.start();
  }
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
