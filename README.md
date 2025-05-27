# Dailiance - Interactive AI-Driven Storytelling Platform

An interactive storytelling platform built with Haxe, supporting multiple game engine targets including Unity3D and roguescroll.

## Core Features

- Cross-platform Haxe codebase
- Multiple engine targets:
  - Unity3D integration
  - roguescroll engine integration
- Google Gemini AI integration for narrative generation
- CogView2/3 integration for visual content generation
- Statistical inference for game actor models
- Hybrid 2D/3D visualization system
- Non-Euclidean manifold for spatial relationships
- UV mapping and texture generation
- Scene graph with Cartesian topology
- ML-driven vector relationships for actor positioning

## Technical Architecture

### Core Haxe Components
- Cross-platform core systems
- Engine-agnostic interfaces
- Target-specific implementations

### AI Components
- Google Gemini AI for narrative generation
- CogView2/3 for image generation
- Statistical models for actor behavior and relationships

### Visualization System
- Engine-specific scene graph implementations
- Cartesian coordinate system for basic positioning
- Non-Euclidean manifold for complex spatial relationships
- UV mapping system for texture generation
- 2D/3D hybrid rendering pipeline

### Game Systems
- Actor model system with statistical inference
- Dynamic narrative branching
- Scene graph management
- Vector-based positioning system

## Setup Requirements

- Haxe 4.3.0 or newer
- Unity 2022.3 LTS (for Unity target)
- roguescroll engine (for roguescroll target)
- Google Cloud API credentials
- CogView2/3 API access
- Python 3.8+ for ML components

## Project Structure

```
src/
├── core/             # Core game logic
│   ├── ai/          # AI integration
│   ├── actors/      # Actor system
│   ├── math/        # Math utilities
│   └── utils/       # General utilities
├── targets/         # Target-specific implementations
│   ├── unity/       # Unity-specific code
│   └── roguescroll/ # roguescroll-specific code
├── interfaces/      # Engine-agnostic interfaces
└── resources/       # Shared resources

build/
├── unity/          # Unity build output
└── roguescroll/    # roguescroll build output

haxe/
├── build.hxml      # Haxe build configuration
└── project.xml     # Project configuration
```

## Development Status

🚧 Under Development 🚧

Current focus:
- Setting up Haxe project structure
- Implementing core systems
- Creating engine-specific implementations
- Integrating AI components
- Developing visualization pipeline

## Building

```bash
# Build for Unity
haxe build.hxml -D unity

# Build for roguescroll
haxe build.hxml -D roguescroll
```




### Cursor Prompt
yeah, let's pull that code in and write a "restructure.md" review document, and add Quaternion, eiganvector (or whatever support we need like scipi.js etc), TensorFlow lite transpiled for haxe would be good and cartesian coordinate system scene graph that is compatible with Unity3d and Vector3.hx, non-euclidian math should be described in matrix manifolds (i think?) let's setup a tokenizer that includes different matrix coordinate systems, like spherical, hyperbolic, pillar, AABB, and give each values vectors that match an actor, let's allow these systems to interact freely with Stable Diffusion weights for determining image to image or text to image based on sense data with simple capsule collider in cartesian space -- let's adapt in-painting and out-painting, and the control-net to establish actor motives and negative / positive prompts from the text encoder and an RNN or image description algorithm of choice, the VAES and MODELS from Civitai should be available through user interaction, and effectiveness toward lack of negative prompt association should help weight default selection beyond Gemeni guess - we should allow RNN to effect negative and positive prompts for actors "near" eachother and it would be good to implement cell tower peer to peer with associative client ownership like we do in rogue scroll, thank you, i love you

yes to 1,2,3,4 and do you understand what i mean by in painting and out painting effecting negative and positive prompts? also, let's do ray traces informing image-to-image vs text-to-image screen buffer capture depth buffer for image-to-image given in-painting / out-painting value effects

could we add an exterior perspective camera that interprets the scene additionally and adds pathing data as a supplement to the suggested 4 stage pathing, and a prompt RNN that generates new pathing names for these routine description associations? e.g. camera image description of scene + timeline temporal description of actor movement (scene after scene after scene etc) -> two stacks, permanant, temporary, when temporarily recognized pathing text CLIP associations yield hire fitness than permanent, then we add the temporary to permanent. E.x. if we keep walking to and talking around the water bubbler, we might generate a "water bubbler: Direct, slow, wobble slightly", or a "Care-for: Direct slow, circle around", but these would occur from natural play with users

(from you, please do:)
Add more sophisticated prompt generation based on scene analysis?
Implement additional manifold topologies?
Enhance the ray tracing with more advanced features?
Add support for specific game types and narrative structures?
Let me know which aspect you'd like to focus on next!


 let's implement hierarchical box pathing whereby any 3d shapes are subdivided by an octree and regarded as not enterable unless there is convex deconstruction - then the space is inverted and subdivided again, and used as a light weight graph search A* with centroid hub and spoke capsule colliders

 let's pull the rest of `~/Developers/roguescroll/` game engine core and utilities into this project, then add Three.js and buzz audio as dependencies and adjust the math for 1,2,3,4 to include a Unity3D / roguescroll game engine message property mixin so the Unity3D property access and methods construct for mori properly, and the Component Unity3D methods are automatically converted to message handlers appropriately

 1, 2, and 3 are good ideas, and yeah #4, i guess i was thinking of adding the engine from roguescroll directly as a build target in addition to Unity3D, let's do that so the haxe build may have some tricks