# Scene Graph Implementation Guide

## Unity Integration

### 1. Basic Setup
```csharp
// SceneGraphManager.cs
public class SceneGraphManager : MonoBehaviour
{
    private SceneGraph sceneGraph;
    private SceneDescriptionService descriptionService;
    
    void Start()
    {
        sceneGraph = new SceneGraph();
        descriptionService = new SceneDescriptionService();
        
        // Initialize TensorFlow.js
        descriptionService.initializeModel();
    }
    
    public async Task ProcessScene()
    {
        // Capture current scene view
        var imageData = await CaptureSceneView();
        
        // Process scene with AI
        var processedGraph = await descriptionService.processImage(imageData);
        
        // Update Unity scene
        UpdateUnityScene(processedGraph);
    }
}
```

### 2. Scene Node Implementation
```csharp
// UnitySceneNode.cs
public class UnitySceneNode : MonoBehaviour
{
    public string nodeId;
    public string label;
    public float confidence;
    public Bounds boundingBox;
    
    [System.Serializable]
    public class NodeMetadata
    {
        public string positivePrompt;
        public string negativePrompt;
        public string opinionPrompt;
        public CodifiedOpinion codifiedOpinion;
    }
    
    public NodeMetadata metadata;
    
    void Start()
    {
        // Initialize node properties
        nodeId = System.Guid.NewGuid().ToString();
    }
    
    public void UpdateFromSceneNode(SceneNode node)
    {
        label = node.label;
        confidence = node.confidence;
        boundingBox = new Bounds(
            new Vector3(node.boundingBox.x, node.boundingBox.y, 0),
            new Vector3(node.boundingBox.width, node.boundingBox.height, 0)
        );
        
        // Update metadata
        metadata = new NodeMetadata
        {
            positivePrompt = node.metadata.positivePrompt,
            negativePrompt = node.metadata.negativePrompt,
            opinionPrompt = node.metadata.opinionPrompt,
            codifiedOpinion = node.metadata.codifiedOpinion
        };
    }
}
```

### 3. Spatial Relations
```csharp
// SpatialRelationManager.cs
public class SpatialRelationManager : MonoBehaviour
{
    private Dictionary<string, List<SpatialRelation>> relations;
    
    public void UpdateRelations(SceneGraph graph)
    {
        relations.Clear();
        
        foreach (var node in graph.getNodes())
        {
            var nodeRelations = new List<SpatialRelation>();
            foreach (var relation in graph.getRelations())
            {
                if (relation.source == node.id)
                {
                    nodeRelations.Add(relation);
                }
            }
            relations[node.id] = nodeRelations;
        }
    }
    
    public string GetSpatialDescription(string nodeId)
    {
        if (!relations.ContainsKey(nodeId)) return "";
        
        var descriptions = new List<string>();
        foreach (var relation in relations[nodeId])
        {
            descriptions.Add($"{relation.source} is {relation.relation} {relation.target}");
        }
        
        return string.Join(", ", descriptions);
    }
}
```

## Roguescroll Integration

### 1. Scene Graph Adapter
```haxe
// RoguescrollSceneGraphAdapter.hx
class RoguescrollSceneGraphAdapter implements ISceneGraph
{
    private var scene:Scene;
    private var nodes:Map<String, Node>;
    private var descriptionService:SceneDescriptionService;
    
    public function new(scene:Scene)
    {
        this.scene = scene;
        this.nodes = new Map<String, Node>();
        this.descriptionService = new SceneDescriptionService();
    }
    
    public function processScene():Void
    {
        // Capture current scene
        var imageData = captureSceneView();
        
        // Process with AI
        var processedGraph = descriptionService.processImage(imageData);
        
        // Update Roguescroll scene
        updateRoguescrollScene(processedGraph);
    }
    
    private function updateRoguescrollScene(graph:SceneGraph):Void
    {
        for (node in graph.getNodes())
        {
            var roguescrollNode = new Node(node.id);
            roguescrollNode.setPosition(node.boundingBox.x, node.boundingBox.y, 0);
            roguescrollNode.setMetadata(node.metadata);
            scene.addNode(roguescrollNode);
            nodes.set(node.id, roguescrollNode);
        }
    }
}
```

### 2. Node Metadata Handling
```haxe
// RoguescrollNodeMetadata.hx
class RoguescrollNodeMetadata
{
    public var positivePrompt:String;
    public var negativePrompt:String;
    public var opinionPrompt:String;
    public var codifiedOpinion:CodifiedOpinion;
    
    public function new()
    {
        positivePrompt = "";
        negativePrompt = "";
        opinionPrompt = "";
        codifiedOpinion = null;
    }
    
    public function updateFromSceneNode(node:SceneNode):Void
    {
        positivePrompt = node.metadata.positivePrompt;
        negativePrompt = node.metadata.negativePrompt;
        opinionPrompt = node.metadata.opinionPrompt;
        codifiedOpinion = node.metadata.codifiedOpinion;
    }
}
```

## Example Usage

### 1. Basic Scene Processing
```csharp
// Example usage in Unity
public class SceneProcessor : MonoBehaviour
{
    public SceneGraphManager graphManager;
    public SpatialRelationManager relationManager;
    
    async void ProcessCurrentScene()
    {
        // Process scene with AI
        await graphManager.ProcessScene();
        
        // Update spatial relations
        relationManager.UpdateRelations(graphManager.sceneGraph);
        
        // Get spatial descriptions
        foreach (var node in graphManager.sceneGraph.getNodes())
        {
            var description = relationManager.GetSpatialDescription(node.id);
            Debug.Log($"Node {node.id}: {description}");
        }
    }
}
```

### 2. Opinion-based Scene Modification
```csharp
// Example of opinion-based scene modification
public class OpinionBasedModifier : MonoBehaviour
{
    public void ApplyOpinion(string nodeId, OpinionPrompt opinion)
    {
        var node = FindNodeById(nodeId);
        if (node != null)
        {
            node.metadata.opinionPrompt = $"{opinion.style}, {opinion.mood}, {opinion.quality}";
            
            // Trigger AI reinterpretation
            var codifiedOpinion = await descriptionService.reinterpretPrompts(
                node.metadata.positivePrompt,
                node.metadata.negativePrompt,
                node.metadata.opinionPrompt
            );
            
            node.metadata.codifiedOpinion = codifiedOpinion;
            
            // Update visual representation
            UpdateNodeVisuals(node);
        }
    }
}
```

## Best Practices

1. **Performance Optimization**
   - Cache processed results
   - Use spatial partitioning for large scenes
   - Implement lazy loading for off-screen nodes

2. **Memory Management**
   - Clear unused nodes and relations
   - Implement object pooling for frequently created objects
   - Use weak references for temporary relations

3. **Error Handling**
   - Implement fallback mechanisms for AI processing
   - Handle missing or invalid nodes gracefully
   - Log and monitor spatial relation calculations

4. **Scene Synchronization**
   - Maintain consistency between engine and scene graph
   - Handle scene transitions smoothly
   - Implement proper cleanup on scene changes

## Troubleshooting

1. **Common Issues**
   - TensorFlow.js initialization failures
   - Memory leaks in scene graph
   - Incorrect spatial relations
   - Performance bottlenecks

2. **Solutions**
   - Check TensorFlow.js model loading
   - Implement proper cleanup
   - Verify spatial calculations
   - Use profiling tools

## Next Steps

1. **Future Improvements**
   - Implement more sophisticated spatial relations
   - Add support for dynamic scene modifications
   - Improve AI model integration
   - Add more opinion-based features

2. **Integration with Other Systems**
   - Physics system integration
   - Animation system integration
   - UI system integration
   - Networking support 