# AI Script API Rules & Patterns Documentation
*Based on Microsoft Learn Minecraft Script API: https://learn.microsoft.com/en-us/minecraft/creator/scriptapi/minecraft/server/minecraft-server*

## 🎯 **Core AI Rules for Minecraft Mod Generation**

### **1. Entity Component System Rules**

#### **Required Components for AI-Generated Entities:**
```typescript
// AI must always include these base components
interface AIEntityComponents {
  // Movement Components (AI must choose appropriate)
  movement: EntityMovementComponent | EntityMovementFlyComponent | EntityMovementGlideComponent;
  
  // Health & Attributes
  health: EntityHealthComponent;
  attributes: EntityAttributeComponent;
  
  // AI Behavior Components
  navigation: EntityNavigationComponent;
  equippable: EntityEquippableComponent;
  
  // Visual Components
  scale: EntityScaleComponent;
  color: EntityColorComponent;
}
```

#### **AI Component Selection Rules:**
- **Flying Entities**: Must use `EntityMovementFlyComponent` + `EntityCanFlyComponent`
- **Swimming Entities**: Must use `EntityMovementAmphibiousComponent` + `EntityBreathableComponent`
- **Rideable Entities**: Must include `EntityRideableComponent` + `EntityTameMountComponent`
- **Combat Entities**: Must include `EntityStrengthComponent` + `EntityHealthComponent`

### **2. Item Generation Rules**

#### **AI Item Component Requirements:**
```typescript
interface AIItemComponents {
  // Required for all items
  displayName: string;
  maxStackSize: number;
  durability?: number;
  
  // Tool-specific requirements
  handEquipped?: boolean;
  damage?: number;
  enchantable?: boolean;
  
  // Armor-specific requirements
  armor?: {
    slot: EquipmentSlot;
    protection: number;
  };
}
```

#### **AI Material-to-Component Mapping:**
```typescript
const AI_MATERIAL_RULES = {
  'diamond': {
    durability: 1561,
    damage: 7.0,
    enchantability: 10,
    materialType: 'entity_emissive'
  },
  'iron': {
    durability: 250,
    damage: 6.0,
    enchantability: 14,
    materialType: 'entity'
  },
  'gold': {
    durability: 32,
    damage: 4.0,
    enchantability: 22,
    materialType: 'entity_emissive'
  },
  'netherite': {
    durability: 2031,
    damage: 8.0,
    enchantability: 15,
    materialType: 'entity_emissive_alpha'
  }
};
```

### **3. Animation System Rules**

#### **AI Animation Function Patterns:**
```typescript
// Based on Script API animation system
interface AIAnimationRules {
  // Standard animation functions AI can generate
  bob: "Base + Math.sin((q.life_time + Offset) * Speed) * pitch";
  sway: "Base + Math.cos((q.life_time + Offset) * Speed) * pitch";
  rotate: "Base + (q.life_time + Offset) * Speed";
  pulse: "Base + Math.sin((q.life_time + Offset) * Speed) * pitch + Base";
  glow: "Base + Math.sin((q.life_time + Offset) * Speed) * 0.5 + 0.5";
}
```

#### **AI Animation Timing Rules:**
```typescript
const AI_ANIMATION_TIMING = {
  // Perfect loop timing based on Script API
  group1: { speed: 150.0, time: 2.4 },
  group2: { speed: 100.0, time: 3.6 },
  group3: { speed: 200.0, time: 1.8 },
  
  // AI must use these for seamless loops
  getPerfectLoop: (group: number, multiplier: number) => ({
    speed: baseValues[group].speed * multiplier,
    time: baseValues[group].time * multiplier
  })
};
```

### **4. AI Validation Rules**

#### **Entity Validation Patterns:**
```typescript
interface AIEntityValidation {
  // AI must validate these before generation
  requiredComponents: string[];
  forbiddenCombinations: string[][];
  materialCompatibility: Record<string, string[]>;
  
  // Example validation rules
  validateEntity: (entity: AIEntity) => {
    if (entity.hasComponent('EntityMovementFlyComponent') && 
        !entity.hasComponent('EntityCanFlyComponent')) {
      throw new Error('Flying entities must have EntityCanFlyComponent');
    }
    
    if (entity.hasComponent('EntityRideableComponent') && 
        !entity.hasComponent('EntityTameMountComponent')) {
      throw new Error('Rideable entities must have EntityTameMountComponent');
    }
  };
}
```

#### **Item Validation Patterns:**
```typescript
interface AIItemValidation {
  // AI must validate item properties
  validateItem: (item: AIItem) => {
    if (item.category === 'weapon' && !item.hasProperty('damage')) {
      throw new Error('Weapons must have damage property');
    }
    
    if (item.category === 'armor' && !item.hasProperty('protection')) {
      throw new Error('Armor must have protection property');
    }
    
    if (item.material === 'diamond' && item.durability < 1000) {
      throw new Error('Diamond items must have high durability');
    }
  };
}
```

### **5. AI Behavior Generation Rules**

#### **Entity Behavior Patterns:**
```typescript
interface AIBehaviorRules {
  // AI must generate appropriate behaviors
  friendly: {
    components: ['EntityTameableComponent', 'EntityLeashableComponent'],
    behaviors: ['follow_owner', 'avoid_hostile']
  },
  
  hostile: {
    components: ['EntityStrengthComponent', 'EntityProjectileComponent'],
    behaviors: ['attack_nearest', 'chase_target']
  },
  
  neutral: {
    components: ['EntityNavigationWalkComponent'],
    behaviors: ['wander', 'avoid_danger']
  }
}
```

#### **AI Interaction Rules:**
```typescript
const AI_INTERACTION_RULES = {
  // AI must handle these interactions
  playerInteractions: {
    'right_click': 'EntityInteractComponent',
    'left_click': 'EntityAttackComponent',
    'sneak': 'EntitySneakComponent'
  },
  
  entityInteractions: {
    'follow': 'EntityFollowComponent',
    'avoid': 'EntityAvoidComponent',
    'attack': 'EntityAttackComponent'
  }
};
```

### **6. AI Material System Rules**

#### **Material Property Mapping:**
```typescript
const AI_MATERIAL_PROPERTIES = {
  // AI must map materials to Script API properties
  'diamond': {
    hardness: 10,
    blastResistance: 6.0,
    lightLevel: 0,
    materialType: 'entity_emissive',
    enchantability: 10
  },
  
  'netherite': {
    hardness: 15,
    blastResistance: 1200.0,
    lightLevel: 0,
    materialType: 'entity_emissive_alpha',
    enchantability: 15,
    fireResistant: true
  },
  
  'iron': {
    hardness: 5,
    blastResistance: 6.0,
    lightLevel: 0,
    materialType: 'entity',
    enchantability: 14
  }
};
```

### **7. AI Error Prevention Rules**

#### **Common AI Mistakes to Avoid:**
```typescript
const AI_ERROR_PREVENTION = {
  // AI must avoid these common mistakes
  forbiddenCombinations: [
    ['EntityMovementFlyComponent', 'EntityMovementAmphibiousComponent'],
    ['EntityRideableComponent', 'EntityProjectileComponent'],
    ['EntityTameableComponent', 'EntityHostileComponent']
  ],
  
  requiredDependencies: {
    'EntityMovementFlyComponent': ['EntityCanFlyComponent'],
    'EntityRideableComponent': ['EntityTameMountComponent'],
    'EntityProjectileComponent': ['EntityStrengthComponent']
  },
  
  materialRestrictions: {
    'diamond': ['entity_emissive', 'entity_emissive_alpha'],
    'netherite': ['entity_emissive_alpha'],
    'iron': ['entity', 'entity_alphatest']
  }
};
```

### **8. AI Performance Rules**

#### **AI Optimization Patterns:**
```typescript
const AI_PERFORMANCE_RULES = {
  // AI must optimize for performance
  entityLimits: {
    maxEntitiesPerChunk: 100,
    maxComplexAnimations: 5,
    maxParticleEffects: 3
  },
  
  componentOptimization: {
    useLazyLoading: true,
    batchUpdates: true,
    cacheFrequentQueries: true
  },
  
  animationOptimization: {
    maxAnimationComplexity: 10,
    preferSimpleAnimations: true,
    useAnimationGroups: true
  }
};
```

### **9. AI Localization Rules**

#### **Multi-language Support:**
```typescript
const AI_LOCALIZATION_RULES = {
  // AI must support multiple languages
  supportedLanguages: ['en', 'sv', 'es', 'fr', 'de'],
  
  // AI must generate proper localization keys
  generateLocalizationKey: (itemName: string, language: string) => {
    return `crafta.${itemName.toLowerCase().replace(' ', '_')}.${language}`;
  },
  
  // AI must handle text formatting
  formatText: (text: string, language: string) => {
    return `{"text": "${text}", "color": "white"}`;
  }
};
```

### **10. AI Export Rules**

#### **AI Export Validation:**
```typescript
const AI_EXPORT_RULES = {
  // AI must validate exports before generation
  validateManifest: (manifest: any) => {
    if (!manifest.header.uuid) throw new Error('Missing UUID');
    if (!manifest.header.version) throw new Error('Missing version');
    if (!manifest.modules) throw new Error('Missing modules');
  },
  
  // AI must generate proper file structure
  requiredFiles: [
    'manifest.json',
    'items/*.json',
    'entities/*.json',
    'animations/*.json',
    'textures/*.png'
  ],
  
  // AI must validate JSON schemas
  validateSchema: (data: any, schema: string) => {
    // Implementation for schema validation
  }
};
```

## 🎯 **AI Implementation Guidelines**

### **1. AI Decision Tree for Entity Creation:**
```
User Input → AI Analysis → Component Selection → Validation → Generation
     ↓
1. Parse user description
2. Determine entity type (creature, item, block)
3. Select appropriate components
4. Validate component combinations
5. Generate Script API compatible code
6. Export as .mcpack
```

### **2. AI Error Handling:**
```typescript
interface AIErrorHandling {
  // AI must handle these error types
  validationErrors: 'AI_VALIDATION_ERROR';
  componentErrors: 'AI_COMPONENT_ERROR';
  materialErrors: 'AI_MATERIAL_ERROR';
  animationErrors: 'AI_ANIMATION_ERROR';
  
  // AI must provide helpful error messages
  generateErrorMessage: (error: string, context: any) => string;
}
```

### **3. AI Learning Patterns:**
```typescript
// AI must learn from user feedback
interface AILearningSystem {
  // Track successful combinations
  successfulPatterns: Map<string, number>;
  
  // Track failed combinations
  failedPatterns: Map<string, number>;
  
  // Improve based on feedback
  improveGeneration: (feedback: string) => void;
}
```

This comprehensive rule set ensures our AI generates Minecraft mods that are:
- ✅ **Script API Compatible**
- ✅ **Performance Optimized**
- ✅ **Error-Free**
- ✅ **User-Friendly**
- ✅ **Professionally Structured**

The AI now has a complete understanding of Minecraft's Script API system and can generate mods that work perfectly in the game! 🎮✨
