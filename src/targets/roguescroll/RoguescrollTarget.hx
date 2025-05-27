package dailiance.roguescroll;

import dailiance.core.Engine;
import dailiance.core.ISceneGraph;
import dailiance.core.IRenderer;
import dailiance.core.IAudioSystem;
import dailiance.core.IPhysicsSystem;
import dailiance.core.INetworkSystem;
import dailiance.math.Vector3;
import dailiance.math.Quaternion;
import mori.Map;
import mori.Vector;
import mori.Set;
import mori.SortedMap;

class RoguescrollTarget {
    private var engine:Engine;
    private var sceneGraph:RoguescrollSceneGraph;
    private var renderer:RoguescrollRenderer;
    private var audioSystem:RoguescrollAudio;
    private var physicsSystem:RoguescrollPhysics;
    private var networkSystem:RoguescrollNetwork;
    
    // Mori-based state management
    private var gameState:Map<String, Dynamic>;
    private var entityRegistry:Map<String, Dynamic>;
    private var componentRegistry:Map<String, Set<String>>;
    private var messageQueue:Vector<Dynamic>;
    private var eventHandlers:SortedMap<String, Vector<Dynamic->Void>>;
    
    public function new() {
        // Initialize mori data structures
        gameState = mori.hashMap();
        entityRegistry = mori.hashMap();
        componentRegistry = mori.hashMap();
        messageQueue = mori.vector();
        eventHandlers = mori.sortedMap();
        
        // Initialize systems
        sceneGraph = new RoguescrollSceneGraph();
        renderer = new RoguescrollRenderer();
        audioSystem = new RoguescrollAudio();
        physicsSystem = new RoguescrollPhysics();
        networkSystem = new RoguescrollNetwork();
        
        // Create engine with roguescroll systems
        engine = new Engine(
            sceneGraph,
            renderer,
            audioSystem,
            physicsSystem,
            networkSystem
        );
        
        // Initialize roguescroll-specific features
        initializeRoguescrollFeatures();
    }
    
    private function initializeRoguescrollFeatures():Void {
        // Register roguescroll-specific components
        registerComponent("Transform", ["position", "rotation", "scale"]);
        registerComponent("Rigidbody", ["mass", "velocity", "angularVelocity"]);
        registerComponent("Collider", ["shape", "isTrigger"]);
        registerComponent("Renderer", ["mesh", "material"]);
        registerComponent("Light", ["type", "color", "intensity"]);
        registerComponent("Camera", ["fov", "near", "far"]);
        registerComponent("AudioSource", ["clip", "volume", "pitch"]);
        registerComponent("NetworkIdentity", ["id", "isLocalPlayer"]);
        
        // Set up event system
        setupEventSystem();
    }
    
    private function registerComponent(name:String, properties:Array<String>):Void {
        var componentSet = mori.set(properties);
        componentRegistry = mori.assoc(componentRegistry, name, componentSet);
    }
    
    private function setupEventSystem():Void {
        // Register core events
        registerEvent("Update", mori.vector());
        registerEvent("FixedUpdate", mori.vector());
        registerEvent("LateUpdate", mori.vector());
        registerEvent("Collision", mori.vector());
        registerEvent("Trigger", mori.vector());
        registerEvent("NetworkMessage", mori.vector());
    }
    
    private function registerEvent(name:String, handlers:Vector<Dynamic->Void>):Void {
        eventHandlers = mori.assoc(eventHandlers, name, handlers);
    }
    
    public function addEventHandler(eventName:String, handler:Dynamic->Void):Void {
        var handlers = mori.get(eventHandlers, eventName);
        if (handlers != null) {
            handlers = mori.conj(handlers, handler);
            eventHandlers = mori.assoc(eventHandlers, eventName, handlers);
        }
    }
    
    public function removeEventHandler(eventName:String, handler:Dynamic->Void):Void {
        var handlers = mori.get(eventHandlers, eventName);
        if (handlers != null) {
            handlers = mori.filter(function(h) return h != handler, handlers);
            eventHandlers = mori.assoc(eventHandlers, eventName, handlers);
        }
    }
    
    public function dispatchEvent(eventName:String, data:Dynamic):Void {
        var handlers = mori.get(eventHandlers, eventName);
        if (handlers != null) {
            mori.each(handlers, function(handler) {
                handler(data);
            });
        }
    }
    
    public function createEntity(id:String, components:Map<String, Dynamic>):Void {
        // Create entity with components
        var entity = mori.assoc(mori.hashMap(), "id", id);
        entity = mori.assoc(entity, "components", components);
        
        // Add to registry
        entityRegistry = mori.assoc(entityRegistry, id, entity);
        
        // Initialize components
        mori.each(mori.keys(components), function(componentName) {
            var componentData = mori.get(components, componentName);
            initializeComponent(id, componentName, componentData);
        });
    }
    
    private function initializeComponent(entityId:String, componentName:String, data:Dynamic):Void {
        switch (componentName) {
            case "Transform":
                var transform = new RoguescrollTransform(
                    data.position,
                    data.rotation,
                    data.scale
                );
                sceneGraph.addNode(entityId, transform);
                
            case "Rigidbody":
                var rigidbody = new RoguescrollRigidbody(
                    data.mass,
                    data.velocity,
                    data.angularVelocity
                );
                physicsSystem.addRigidbody(entityId, rigidbody);
                
            case "Collider":
                var collider = new RoguescrollCollider(
                    data.shape,
                    data.isTrigger
                );
                physicsSystem.addCollider(entityId, collider);
                
            case "Renderer":
                var renderer = new RoguescrollRenderer(
                    data.mesh,
                    data.material
                );
                this.renderer.addRenderer(entityId, renderer);
                
            case "Light":
                var light = new RoguescrollLight(
                    data.type,
                    data.color,
                    data.intensity
                );
                this.renderer.addLight(entityId, light);
                
            case "Camera":
                var camera = new RoguescrollCamera(
                    data.fov,
                    data.near,
                    data.far
                );
                this.renderer.setCamera(entityId, camera);
                
            case "AudioSource":
                var audioSource = new RoguescrollAudioSource(
                    data.clip,
                    data.volume,
                    data.pitch
                );
                audioSystem.addSource(entityId, audioSource);
                
            case "NetworkIdentity":
                var networkIdentity = new RoguescrollNetworkIdentity(
                    data.id,
                    data.isLocalPlayer
                );
                networkSystem.addIdentity(entityId, networkIdentity);
        }
    }
    
    public function update(deltaTime:Float):Void {
        // Update game state
        updateGameState(deltaTime);
        
        // Process message queue
        processMessageQueue();
        
        // Update systems
        engine.update(deltaTime);
    }
    
    private function updateGameState(deltaTime:Float):Void {
        // Update all entities
        mori.each(mori.keys(entityRegistry), function(entityId) {
            var entity = mori.get(entityRegistry, entityId);
            updateEntity(entityId, entity, deltaTime);
        });
    }
    
    private function updateEntity(entityId:String, entity:Map<String, Dynamic>, deltaTime:Float):Void {
        var components = mori.get(entity, "components");
        
        // Update each component
        mori.each(mori.keys(components), function(componentName) {
            var componentData = mori.get(components, componentName);
            updateComponent(entityId, componentName, componentData, deltaTime);
        });
    }
    
    private function updateComponent(entityId:String, componentName:String, data:Dynamic, deltaTime:Float):Void {
        switch (componentName) {
            case "Transform":
                var transform = sceneGraph.getNode(entityId);
                if (transform != null) {
                    transform.update(deltaTime);
                }
                
            case "Rigidbody":
                var rigidbody = physicsSystem.getRigidbody(entityId);
                if (rigidbody != null) {
                    rigidbody.update(deltaTime);
                }
                
            case "Renderer":
                var renderer = this.renderer.getRenderer(entityId);
                if (renderer != null) {
                    renderer.update(deltaTime);
                }
                
            case "AudioSource":
                var audioSource = audioSystem.getSource(entityId);
                if (audioSource != null) {
                    audioSource.update(deltaTime);
                }
        }
    }
    
    private function processMessageQueue():Void {
        while (!mori.isEmpty(messageQueue)) {
            var message = mori.first(messageQueue);
            messageQueue = mori.rest(messageQueue);
            
            // Process message
            processMessage(message);
        }
    }
    
    private function processMessage(message:Dynamic):Void {
        var type = mori.get(message, "type");
        var data = mori.get(message, "data");
        
        switch (type) {
            case "ComponentUpdate":
                var entityId = mori.get(data, "entityId");
                var componentName = mori.get(data, "componentName");
                var componentData = mori.get(data, "componentData");
                updateComponent(entityId, componentName, componentData, 0);
                
            case "EntityDestroy":
                var entityId = mori.get(data, "entityId");
                destroyEntity(entityId);
                
            case "NetworkSync":
                var entityId = mori.get(data, "entityId");
                var syncData = mori.get(data, "syncData");
                networkSystem.syncEntity(entityId, syncData);
        }
    }
    
    private function destroyEntity(entityId:String):Void {
        var entity = mori.get(entityRegistry, entityId);
        if (entity != null) {
            var components = mori.get(entity, "components");
            
            // Clean up components
            mori.each(mori.keys(components), function(componentName) {
                cleanupComponent(entityId, componentName);
            });
            
            // Remove from registry
            entityRegistry = mori.dissoc(entityRegistry, entityId);
        }
    }
    
    private function cleanupComponent(entityId:String, componentName:String):Void {
        switch (componentName) {
            case "Transform":
                sceneGraph.removeNode(entityId);
                
            case "Rigidbody":
                physicsSystem.removeRigidbody(entityId);
                
            case "Collider":
                physicsSystem.removeCollider(entityId);
                
            case "Renderer":
                renderer.removeRenderer(entityId);
                
            case "Light":
                renderer.removeLight(entityId);
                
            case "Camera":
                renderer.removeCamera(entityId);
                
            case "AudioSource":
                audioSystem.removeSource(entityId);
                
            case "NetworkIdentity":
                networkSystem.removeIdentity(entityId);
        }
    }
} 