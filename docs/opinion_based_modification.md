# Opinion-Based Scene Modification Tutorial

## Overview

This tutorial explains how to implement opinion-based scene modification using our scene graph system. The system allows for dynamic reinterpretation of scene elements based on user opinions and preferences.

## Basic Concepts

1. **Opinion Prompts**
   - Style preferences
   - Mood settings
   - Quality parameters
   - Visual characteristics

2. **Codified Opinions**
   - Mathematical representation of opinions
   - Vector-based transformations
   - Confidence scoring

## Implementation Steps

### 1. Setting Up Opinion Handlers

```csharp
// OpinionHandler.cs
public class OpinionHandler
{
    private SceneDescriptionService descriptionService;
    private Dictionary<string, OpinionPrompt> activeOpinions;
    
    public OpinionHandler()
    {
        descriptionService = new SceneDescriptionService();
        activeOpinions = new Dictionary<string, OpinionPrompt>();
    }
    
    public async Task ApplyOpinion(string nodeId, OpinionPrompt opinion)
    {
        // Store the opinion
        activeOpinions[nodeId] = opinion;
        
        // Get the node
        var node = GetNodeById(nodeId);
        if (node == null) return;
        
        // Generate opinion prompt
        var opinionPrompt = GenerateOpinionPrompt(opinion);
        
        // Update node metadata
        node.metadata.opinionPrompt = opinionPrompt;
        
        // Trigger AI reinterpretation
        var codifiedOpinion = await descriptionService.reinterpretPrompts(
            node.metadata.positivePrompt,
            node.metadata.negativePrompt,
            opinionPrompt
        );
        
        // Update node with new opinion
        node.metadata.codifiedOpinion = codifiedOpinion;
        
        // Notify listeners
        OnOpinionApplied?.Invoke(nodeId, codifiedOpinion);
    }
    
    private string GenerateOpinionPrompt(OpinionPrompt opinion)
    {
        return $"{opinion.style}, {opinion.mood}, {opinion.quality}";
    }
}
```

### 2. Creating Opinion Prompts

```csharp
// OpinionPrompt.cs
[System.Serializable]
public class OpinionPrompt
{
    public string style;
    public string mood;
    public string quality;
    public Dictionary<string, float> parameters;
    
    public OpinionPrompt()
    {
        parameters = new Dictionary<string, float>();
    }
    
    public void AddParameter(string key, float value)
    {
        parameters[key] = Mathf.Clamp01(value);
    }
    
    public float GetParameter(string key)
    {
        return parameters.ContainsKey(key) ? parameters[key] : 0f;
    }
}
```

### 3. Implementing Opinion Effects

```csharp
// OpinionEffectManager.cs
public class OpinionEffectManager : MonoBehaviour
{
    private Dictionary<string, List<IOpinionEffect>> nodeEffects;
    
    void Start()
    {
        nodeEffects = new Dictionary<string, List<IOpinionEffect>>();
    }
    
    public void ApplyEffects(string nodeId, CodifiedOpinion opinion)
    {
        if (!nodeEffects.ContainsKey(nodeId))
        {
            nodeEffects[nodeId] = new List<IOpinionEffect>();
        }
        
        foreach (var effect in nodeEffects[nodeId])
        {
            effect.Apply(opinion);
        }
    }
    
    public void AddEffect(string nodeId, IOpinionEffect effect)
    {
        if (!nodeEffects.ContainsKey(nodeId))
        {
            nodeEffects[nodeId] = new List<IOpinionEffect>();
        }
        
        nodeEffects[nodeId].Add(effect);
    }
}

// IOpinionEffect.cs
public interface IOpinionEffect
{
    void Apply(CodifiedOpinion opinion);
    void Remove();
}
```

### 4. Example Visual Effects

```csharp
// VisualOpinionEffect.cs
public class VisualOpinionEffect : MonoBehaviour, IOpinionEffect
{
    private Material originalMaterial;
    private Material opinionMaterial;
    
    void Start()
    {
        originalMaterial = GetComponent<Renderer>().material;
        opinionMaterial = new Material(originalMaterial);
    }
    
    public void Apply(CodifiedOpinion opinion)
    {
        // Apply color modifications
        opinionMaterial.color = ModifyColor(originalMaterial.color, opinion);
        
        // Apply texture modifications
        opinionMaterial.mainTexture = ModifyTexture(originalMaterial.mainTexture, opinion);
        
        // Apply shader modifications
        ApplyShaderModifications(opinion);
        
        // Update material
        GetComponent<Renderer>().material = opinionMaterial;
    }
    
    public void Remove()
    {
        GetComponent<Renderer>().material = originalMaterial;
    }
    
    private Color ModifyColor(Color original, CodifiedOpinion opinion)
    {
        // Implement color modification based on opinion
        return original;
    }
    
    private Texture ModifyTexture(Texture original, CodifiedOpinion opinion)
    {
        // Implement texture modification based on opinion
        return original;
    }
    
    private void ApplyShaderModifications(CodifiedOpinion opinion)
    {
        // Implement shader modifications based on opinion
    }
}
```

## Usage Examples

### 1. Basic Opinion Application

```csharp
// Example usage
public class OpinionExample : MonoBehaviour
{
    public OpinionHandler opinionHandler;
    public OpinionEffectManager effectManager;
    
    async void ApplyOpinionToNode(string nodeId)
    {
        // Create opinion
        var opinion = new OpinionPrompt
        {
            style = "surreal",
            mood = "dreamy",
            quality = "high"
        };
        
        // Add parameters
        opinion.AddParameter("saturation", 0.8f);
        opinion.AddParameter("contrast", 0.6f);
        
        // Apply opinion
        await opinionHandler.ApplyOpinion(nodeId, opinion);
        
        // Apply effects
        effectManager.ApplyEffects(nodeId, opinion.codifiedOpinion);
    }
}
```

### 2. Dynamic Opinion Updates

```csharp
// Dynamic opinion updates
public class DynamicOpinionManager : MonoBehaviour
{
    public OpinionHandler opinionHandler;
    private Dictionary<string, OpinionPrompt> currentOpinions;
    
    void Start()
    {
        currentOpinions = new Dictionary<string, OpinionPrompt>();
    }
    
    public void UpdateOpinion(string nodeId, float time)
    {
        if (!currentOpinions.ContainsKey(nodeId)) return;
        
        var opinion = currentOpinions[nodeId];
        
        // Update parameters based on time
        opinion.AddParameter("saturation", Mathf.Sin(time) * 0.5f + 0.5f);
        opinion.AddParameter("contrast", Mathf.Cos(time) * 0.5f + 0.5f);
        
        // Apply updated opinion
        opinionHandler.ApplyOpinion(nodeId, opinion);
    }
}
```

## Best Practices

1. **Performance**
   - Cache opinion results
   - Batch opinion updates
   - Use object pooling for effects

2. **Memory Management**
   - Clean up unused effects
   - Dispose of materials properly
   - Clear opinion caches when needed

3. **Error Handling**
   - Validate opinion parameters
   - Handle missing nodes gracefully
   - Implement fallback effects

## Troubleshooting

1. **Common Issues**
   - Opinion not applying correctly
   - Performance issues with many effects
   - Memory leaks from effects

2. **Solutions**
   - Check opinion parameters
   - Optimize effect application
   - Implement proper cleanup

## Next Steps

1. **Advanced Features**
   - Opinion blending
   - Temporal opinion effects
   - Multi-node opinion propagation

2. **Integration**
   - UI system integration
   - Animation system integration
   - Physics system integration 