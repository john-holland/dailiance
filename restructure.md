# Dailiance Restructuring Document

## Core Architecture

### 1. Mathematical Foundation
- **Coordinate Systems**
  - Cartesian (3D)
  - Spherical
  - Hyperbolic
  - Pillar
  - AABB (Axis-Aligned Bounding Box)
  - Matrix Manifolds for Non-Euclidean Spaces

- **Mathematical Libraries**
  - Eigenvector/Value Support
  - SciPy.js Integration
  - TensorFlow Lite Transpilation
  - Custom Matrix Operations

### 2. Scene Graph System
- **Base Components**
  - Cartesian Scene Graph
  - Non-Euclidean Manifold Integration
  - Capsule Collider System
  - Actor Position Mapping

- **Coordinate System Tokenizer**
  - System Type Classification
  - Vector Space Mapping
  - Inter-system Conversion
  - Actor Association

### 3. AI Integration
- **Stable Diffusion Components**
  - Image-to-Image Pipeline
  - Text-to-Image Pipeline
  - In-painting/Out-painting Support
  - ControlNet Integration

- **Model Management**
  - Civitai Model Integration
  - VAE Support
  - Model Weight Management
  - Default Selection Algorithm

### 4. Actor System
- **Behavior Components**
  - RNN-based Decision Making
  - Prompt Generation
  - Negative/Positive Prompt Association
  - Actor Interaction System

- **Spatial Awareness**
  - Proximity-based Interactions
  - Collision Detection
  - Spatial Relationship Mapping

### 5. Network Architecture
- **Peer-to-Peer System**
  - Cell Tower Architecture
  - Client Ownership Model
  - Associative Data Management
  - RogueScroll Integration

## Implementation Details

### 1. Mathematical Components
```haxe
// Matrix Manifold System
interface IManifold {
    function transformPoint(point:Vector3):Vector3;
    function inverseTransform(point:Vector3):Vector3;
    function getMetric(point:Vector3):Matrix3x3;
}

// Coordinate System Tokenizer
class CoordinateTokenizer {
    function tokenizeSystem(type:CoordinateSystemType):Token;
    function convertBetweenSystems(from:Token, to:Token):Matrix4x4;
    function associateActor(actor:Actor, system:Token):Void;
}
```

### 2. Scene Graph Implementation
```haxe
// Enhanced Scene Graph
class EnhancedSceneGraph {
    private var coordinateSystems:Map<String, IManifold>;
    private var actors:Map<String, Actor>;
    private var colliders:Array<CapsuleCollider>;
    
    function addActor(actor:Actor, system:CoordinateSystemType):Void;
    function updateActorPosition(actor:Actor, newPosition:Vector3):Void;
    function checkCollisions():Array<Collision>;
}
```

### 3. AI Integration
```haxe
// Stable Diffusion Integration
class StableDiffusionManager {
    private var models:Map<String, Model>;
    private var vae:VAE;
    private var controlNet:ControlNet;
    
    function generateImage(prompt:Prompt, negativePrompt:Prompt):Image;
    function inPaint(image:Image, mask:Mask):Image;
    function outPaint(image:Image, direction:Vector2):Image;
}

// Actor AI System
class ActorAI {
    private var rnn:RNN;
    private var promptGenerator:PromptGenerator;
    
    function generateBehavior(context:ActorContext):Behavior;
    function updatePrompts(actors:Array<Actor>):Void;
}
```

### 4. Network System
```haxe
// P2P Network Manager
class P2PNetworkManager {
    private var cellTowers:Array<CellTower>;
    private var clients:Map<String, Client>;
    
    function registerClient(client:Client):Void;
    function broadcastUpdate(update:Update):Void;
    function handleOwnership(asset:Asset, client:Client):Void;
}
```

## Integration Points

### 1. Unity Integration
- Custom Unity Plugin for Haxe Interop
- Scene Graph Synchronization
- Physics System Integration
- Rendering Pipeline Adaptation

### 2. RogueScroll Integration
- Shared Network Architecture
- Client Ownership Model
- Asset Management System
- Real-time Updates

## Development Roadmap

1. **Phase 1: Core Systems**
   - Implement Mathematical Foundation
   - Develop Scene Graph System
   - Create Coordinate System Tokenizer

2. **Phase 2: AI Integration**
   - Integrate Stable Diffusion
   - Implement Actor AI System
   - Develop Prompt Management

3. **Phase 3: Network System**
   - Implement P2P Architecture
   - Develop Cell Tower System
   - Create Client Management

4. **Phase 4: Engine Integration**
   - Unity Plugin Development
   - RogueScroll Integration
   - Cross-platform Testing

## Technical Requirements

### Dependencies
- Haxe 4.3.0+
- TensorFlow Lite
- SciPy.js
- Stable Diffusion Models
- Civitai Integration
- RNN Implementation

### Performance Considerations
- Efficient Matrix Operations
- Optimized Scene Graph
- Network Latency Management
- Memory Usage Optimization

## Next Steps

1. Implement Quaternion and Matrix Manifold Systems
2. Develop Coordinate System Tokenizer
3. Create Basic Scene Graph Implementation
4. Set up AI Integration Framework
5. Begin Network System Development 