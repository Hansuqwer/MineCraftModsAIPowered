import 'dart:convert';
import '../../models/minecraft/addon_file.dart';
import '../../models/minecraft/addon_metadata.dart';

/// Generates Script API files for custom Minecraft commands
/// Provides interactive commands like /crafta:summon, /crafta:list, etc.
class ScriptApiGenerator {
  /// Generate all Script API files for an addon
  static List<AddonFile> generateScriptFiles({
    required Map<String, dynamic> creatureAttributes,
    required AddonMetadata metadata,
  }) {
    final files = <AddonFile>[];

    // Generate main script file
    files.add(_generateMainScript(creatureAttributes, metadata));

    // Generate creature summon script
    files.add(_generateSummonScript(creatureAttributes, metadata));

    // Generate creature list script
    files.add(_generateListScript(creatureAttributes, metadata));

    // Generate creature info script
    files.add(_generateInfoScript(creatureAttributes, metadata));

    return files;
  }

  /// Generate main script file with command registration
  static AddonFile _generateMainScript(
    Map<String, dynamic> creatureAttributes,
    AddonMetadata metadata,
  ) {
    final creatureName = creatureAttributes['creatureName'] ?? 'Creature';
    final creatureType = creatureAttributes['creatureType'] ?? 'creature';
    final namespace = metadata.namespace;

    final script = '''
// Crafta Script API - Main Command Handler
// Generated for: $creatureName
// Addon: ${metadata.name}

import { world, system, Player } from "@minecraft/server";

// Command registration
world.afterEvents.chatSend.subscribe((event) => {
  const message = event.message;
  const player = event.sender;

  if (message.startsWith('$namespace:')) {
    event.cancel = true;
    handleCommand(message, player);
  }
});

function handleCommand(message: string, player: Player) {
  const args = message.split(' ');
  const command = args[0];

  switch (command) {
    case '$namespace:summon':
      handleSummonCommand(args, player);
      break;
    case '$namespace:list':
      handleListCommand(args, player);
      break;
    case '$namespace:info':
      handleInfoCommand(args, player);
      break;
    case '$namespace:help':
      handleHelpCommand(player);
      break;
    default:
      player.sendMessage('§cUnknown command. Use $namespace:help for available commands.');
  }
}

function handleSummonCommand(args: string[], player: Player) {
  if (args.length < 2) {
    player.sendMessage('§cUsage: $namespace:summon <count> [x] [y] [z]');
    return;
  }

  const count = parseInt(args[1]) || 1;
  const location = player.location;
  
  // Get coordinates if provided
  if (args.length >= 5) {
    location.x = parseFloat(args[2]);
    location.y = parseFloat(args[3]);
    location.z = parseFloat(args[4]);
  }

  // Summon creatures
  for (let i = 0; i < Math.min(count, 10); i++) {
    const offsetX = (Math.random() - 0.5) * 4;
    const offsetZ = (Math.random() - 0.5) * 4;
    
    const summonLocation = {
      x: location.x + offsetX,
      y: location.y,
      z: location.z + offsetZ
    };

    try {
      player.dimension.spawnEntity('$namespace:${creatureType}', summonLocation);
    } catch (error) {
      player.sendMessage('§cFailed to summon creature: ' + error);
      return;
    }
  }

  player.sendMessage(`§aSummoned §e${creatures.length} §a$creatureName(s) near you!`);
}

function handleListCommand(args: string[], player: Player) {
  const entities = player.dimension.getEntities({
    type: '$namespace:${creatureType}',
    location: player.location,
    maxDistance: 50
  });

  const count = entities.length;
  player.sendMessage(`§6Found §e${count} §6$creatureName(s) within 50 blocks:`);
  
  entities.forEach((entity, index) => {
    const distance = Math.round(
      Math.sqrt(
        Math.pow(entity.location.x - player.location.x, 2) +
        Math.pow(entity.location.z - player.location.z, 2)
      )
    );
    player.sendMessage(`§7${index + 1}. Distance: §e${distance} blocks`);
  });
}

function handleInfoCommand(args: string[], player: Player) {
  const entities = player.dimension.getEntities({
    type: '$namespace:${creatureType}',
    location: player.location,
    maxDistance: 10
  });

  if (entities.length === 0) {
    player.sendMessage('§cNo $creatureName found nearby. Use $namespace:summon to create some!');
    return;
  }

  const entity = entities[0];
  const distance = Math.round(
    Math.sqrt(
      Math.pow(entity.location.x - player.location.x, 2) +
      Math.pow(entity.location.z - player.location.z, 2)
    )
  );

  player.sendMessage('§6=== $creatureName Info ===');
  player.sendMessage(`§7Type: §e${creatureType}`);
  player.sendMessage(`§7Distance: §e${distance} blocks`);
  player.sendMessage(`§7Location: §e${Math.round(entity.location.x)}, ${Math.round(entity.location.y)}, ${Math.round(entity.location.z)}`);
  
  // Add creature-specific info
  const abilities = ${JSON.encode(creatureAttributes['abilities'] ?? [])};
  if (abilities.length > 0) {
    player.sendMessage(`§7Abilities: §e${abilities.join(', ')}`);
  }
  
  const effects = ${JSON.encode(creatureAttributes['effects'] ?? [])};
  if (effects.length > 0) {
    player.sendMessage(`§7Effects: §e${effects.join(', ')}`);
  }
}

function handleHelpCommand(player: Player) {
  player.sendMessage('§6=== Crafta Commands ===');
  player.sendMessage('§e$namespace:summon <count> §7- Summon creatures');
  player.sendMessage('§e$namespace:list §7- List nearby creatures');
  player.sendMessage('§e$namespace:info §7- Get creature information');
  player.sendMessage('§e$namespace:help §7- Show this help');
  player.sendMessage('');
  player.sendMessage('§7Generated by Crafta - AI-Powered Creature Creator');
}
''';

    return AddonFile('scripts/crafta_main.js', script, 'application/javascript');
  }

  /// Generate creature summon script
  static AddonFile _generateSummonScript(
    Map<String, dynamic> creatureAttributes,
    AddonMetadata metadata,
  ) {
    final creatureName = creatureAttributes['creatureName'] ?? 'Creature';
    final creatureType = creatureAttributes['creatureType'] ?? 'creature';
    final namespace = metadata.namespace;

    final script = '''
// Crafta Summon Script
// Advanced summoning with creature customization

import { world, system, Player, Entity } from "@minecraft/server";

export function summonCreature(
  player: Player,
  count: number = 1,
  location?: { x: number; y: number; z: number }
) {
  const summonLocation = location || player.location;
  
  for (let i = 0; i < Math.min(count, 10); i++) {
    const offsetX = (Math.random() - 0.5) * 4;
    const offsetZ = (Math.random() - 0.5) * 4;
    
    const entityLocation = {
      x: summonLocation.x + offsetX,
      y: summonLocation.y,
      z: summonLocation.z + offsetZ
    };

    try {
      const entity = player.dimension.spawnEntity('$namespace:${creatureType}', entityLocation);
      
      // Apply creature-specific customizations
      customizeCreature(entity, creatureAttributes);
      
    } catch (error) {
      player.sendMessage('§cFailed to summon $creatureName: ' + error);
    }
  }
}

function customizeCreature(entity: Entity, attributes: any) {
  // Apply size modifications
  const size = attributes['size'] || 'normal';
  if (size !== 'normal') {
    const scale = getSizeScale(size);
    entity.triggerEvent('crafta:scale', { scale: scale });
  }

  // Apply color modifications
  const color = attributes['color'] || 'normal';
  if (color !== 'normal') {
    entity.triggerEvent('crafta:color', { color: color });
  }

  // Apply ability modifications
  const abilities = attributes['abilities'] || [];
  abilities.forEach((ability: string) => {
    switch (ability) {
      case 'flying':
        entity.triggerEvent('crafta:fly');
        break;
      case 'swimming':
        entity.triggerEvent('crafta:swim');
        break;
      case 'glowing':
        entity.triggerEvent('crafta:glow');
        break;
    }
  });

  // Apply effect modifications
  const effects = attributes['effects'] || [];
  effects.forEach((effect: string) => {
    switch (effect) {
      case 'sparkles':
        entity.triggerEvent('crafta:sparkles');
        break;
      case 'glow':
        entity.triggerEvent('crafta:glow');
        break;
      case 'fire':
        entity.triggerEvent('crafta:fire');
        break;
    }
  });
}

function getSizeScale(size: string): number {
  switch (size) {
    case 'tiny': return 0.5;
    case 'small': return 0.7;
    case 'large': return 1.3;
    case 'huge': return 1.5;
    case 'giant': return 2.0;
    default: return 1.0;
  }
}
''';

    return AddonFile('scripts/crafta_summon.js', script, 'application/javascript');
  }

  /// Generate creature list script
  static AddonFile _generateListScript(
    Map<String, dynamic> creatureAttributes,
    AddonMetadata metadata,
  ) {
    final creatureName = creatureAttributes['creatureName'] ?? 'Creature';
    final creatureType = creatureAttributes['creatureType'] ?? 'creature';
    final namespace = metadata.namespace;

    final script = '''
// Crafta List Script
// Advanced creature listing and management

import { world, system, Player, Entity } from "@minecraft/server";

export function listCreatures(player: Player, maxDistance: number = 50) {
  const entities = player.dimension.getEntities({
    type: '$namespace:${creatureType}',
    location: player.location,
    maxDistance: maxDistance
  });

  const count = entities.length;
  
  if (count === 0) {
    player.sendMessage('§cNo $creatureName found within ${maxDistance} blocks.');
    player.sendMessage('§7Use $namespace:summon to create some creatures!');
    return;
  }

  player.sendMessage(`§6=== $creatureName List ===`);
  player.sendMessage(`§7Found §e${count} §7creatures within ${maxDistance} blocks:`);
  
  entities.forEach((entity, index) => {
    const distance = Math.round(
      Math.sqrt(
        Math.pow(entity.location.x - player.location.x, 2) +
        Math.pow(entity.location.z - player.location.z, 2)
      )
    );
    
    const health = entity.getComponent('minecraft:health')?.currentValue || 0;
    const maxHealth = entity.getComponent('minecraft:health')?.effectiveMax || 0;
    
    player.sendMessage(`§7${index + 1}. §eDistance: ${distance} blocks §7| §eHealth: ${health}/${maxHealth}`);
  });

  // Show statistics
  const totalHealth = entities.reduce((sum, entity) => {
    return sum + (entity.getComponent('minecraft:health')?.currentValue || 0);
  }, 0);
  
  const averageHealth = Math.round(totalHealth / count);
  player.sendMessage(`§7Average Health: §e${averageHealth}`);
}

export function getCreatureStats(player: Player) {
  const entities = player.dimension.getEntities({
    type: '$namespace:${creatureType}',
    location: player.location,
    maxDistance: 100
  });

  const stats = {
    total: entities.length,
    healthy: 0,
    injured: 0,
    dead: 0
  };

  entities.forEach(entity => {
    const health = entity.getComponent('minecraft:health')?.currentValue || 0;
    const maxHealth = entity.getComponent('minecraft:health')?.effectiveMax || 0;
    
    if (health <= 0) {
      stats.dead++;
    } else if (health < maxHealth * 0.5) {
      stats.injured++;
    } else {
      stats.healthy++;
    }
  });

  player.sendMessage('§6=== Creature Statistics ===');
  player.sendMessage(`§7Total: §e${stats.total}`);
  player.sendMessage(`§7Healthy: §a${stats.healthy}`);
  player.sendMessage(`§7Injured: §e${stats.injured}`);
  player.sendMessage(`§7Dead: §c${stats.dead}`);
}
''';

    return AddonFile('scripts/crafta_list.js', script, 'application/javascript');
  }

  /// Generate creature info script
  static AddonFile _generateInfoScript(
    Map<String, dynamic> creatureAttributes,
    AddonMetadata metadata,
  ) {
    final creatureName = creatureAttributes['creatureName'] ?? 'Creature';
    final creatureType = creatureAttributes['creatureType'] ?? 'creature';
    final namespace = metadata.namespace;

    final script = '''
// Crafta Info Script
// Detailed creature information and analysis

import { world, system, Player, Entity } from "@minecraft/server";

export function getCreatureInfo(player: Player) {
  const entities = player.dimension.getEntities({
    type: '$namespace:${creatureType}',
    location: player.location,
    maxDistance: 10
  });

  if (entities.length === 0) {
    player.sendMessage('§cNo $creatureName found nearby.');
    player.sendMessage('§7Use $namespace:summon to create some creatures!');
    return;
  }

  const entity = entities[0];
  const distance = Math.round(
    Math.sqrt(
      Math.pow(entity.location.x - player.location.x, 2) +
      Math.pow(entity.location.z - player.location.z, 2)
    )
  );

  // Basic info
  player.sendMessage('§6=== $creatureName Information ===');
  player.sendMessage(`§7Type: §e${creatureType}`);
  player.sendMessage(`§7Distance: §e${distance} blocks`);
  player.sendMessage(`§7Location: §e${Math.round(entity.location.x)}, ${Math.round(entity.location.y)}, ${Math.round(entity.location.z)}`);
  
  // Health info
  const health = entity.getComponent('minecraft:health');
  if (health) {
    player.sendMessage(`§7Health: §e${health.currentValue}/${health.effectiveMax}`);
    const healthPercent = Math.round((health.currentValue / health.effectiveMax) * 100);
    player.sendMessage(`§7Health %: §e${healthPercent}%`);
  }

  // Movement info
  const movement = entity.getComponent('minecraft:movement');
  if (movement) {
    player.sendMessage(`§7Movement: §e${movement.value}`);
  }

  // Custom attributes
  const abilities = ${JSON.encode(creatureAttributes['abilities'] ?? [])};
  if (abilities.length > 0) {
    player.sendMessage(`§7Abilities: §e${abilities.join(', ')}`);
  }
  
  const effects = ${JSON.encode(creatureAttributes['effects'] ?? [])};
  if (effects.length > 0) {
    player.sendMessage(`§7Effects: §e${effects.join(', ')}`);
  }

  const color = creatureAttributes['color'] || 'normal';
  if (color !== 'normal') {
    player.sendMessage(`§7Color: §e${color}`);
  }

  const size = creatureAttributes['size'] || 'normal';
  if (size !== 'normal') {
    player.sendMessage(`§7Size: §e${size}`);
  }

  // AI behavior info
  const brain = entity.getComponent('minecraft:brain');
  if (brain) {
    player.sendMessage('§7AI: §aActive');
  }

  // Show entity ID for debugging
  player.sendMessage(`§7Entity ID: §e${entity.id}`);
}

export function analyzeCreatureBehavior(player: Player) {
  const entities = player.dimension.getEntities({
    type: '$namespace:${creatureType}',
    location: player.location,
    maxDistance: 20
  });

  if (entities.length === 0) {
    player.sendMessage('§cNo creatures found for behavior analysis.');
    return;
  }

  player.sendMessage('§6=== Behavior Analysis ===');
  
  entities.forEach((entity, index) => {
    const distance = Math.round(
      Math.sqrt(
        Math.pow(entity.location.x - player.location.x, 2) +
        Math.pow(entity.location.z - player.location.z, 2)
      )
    );
    
    player.sendMessage(`§7Creature ${index + 1}: §e${distance} blocks away`);
    
    // Check if creature is moving
    const velocity = entity.getComponent('minecraft:velocity');
    if (velocity) {
      const speed = Math.sqrt(
        Math.pow(velocity.current.x, 2) +
        Math.pow(velocity.current.z, 2)
      );
      player.sendMessage(`§7  Speed: §e${Math.round(speed * 100) / 100} blocks/sec`);
    }
  });
}
''';

    return AddonFile('scripts/crafta_info.js', script, 'application/javascript');
  }
}
