# Mathematical Reference Guide for Scene Graph System

## 1. Scene Graph Fundamentals

### 1.1 Graph Structure
A scene graph G is defined as a directed graph G = (V, E) where:
- V is the set of vertices (nodes) representing scene elements
- E is the set of edges (relations) representing spatial relationships

### 1.2 Node Properties
For each node v ∈ V:
- Position: p(v) = (x, y, z) ∈ ℝ³
- Bounding box: B(v) = {min, max} where min, max ∈ ℝ³
- Confidence score: c(v) ∈ [0, 1]
- Metadata: M(v) = {positive_prompt, negative_prompt, opinion_prompt, codified_opinion}

### 1.3 Spatial Relations
For each edge e ∈ E:
- Source node: s(e) ∈ V
- Target node: t(e) ∈ V
- Relation type: r(e) ∈ R where R is the set of possible relations
- Confidence score: c(e) ∈ [0, 1]

## 2. Opinion-Based Transformations

### 2.1 Opinion Vector Space
An opinion o is represented as a vector in ℝⁿ where n is the number of opinion dimensions:
o = (o₁, o₂, ..., oₙ) where oᵢ ∈ [0, 1]

### 2.2 Opinion Transformation
For a node v with opinion o:
T(v, o) = v' where:
- v' is the transformed node
- T is the transformation function
- o is the opinion vector

### 2.3 Opinion Blending
For two opinions o₁ and o₂ with weight w:
o_blended = w·o₁ + (1-w)·o₂

## 3. Spatial Relation Calculations

### 3.1 Distance-Based Relations
For nodes v₁, v₂ ∈ V:
d(v₁, v₂) = ||p(v₁) - p(v₂)||₂

### 3.2 Direction-Based Relations
For nodes v₁, v₂ ∈ V:
θ(v₁, v₂) = arctan2(p(v₂).y - p(v₁).y, p(v₂).x - p(v₁).x)

### 3.3 Containment Relations
For nodes v₁, v₂ ∈ V:
v₁ contains v₂ if B(v₁) ⊃ B(v₂)

## 4. Confidence Scoring

### 4.1 Node Confidence
For a node v:
c(v) = w₁·c_detection + w₂·c_quality + w₃·c_opinion
where:
- c_detection is the detection confidence
- c_quality is the quality score
- c_opinion is the opinion confidence
- w₁, w₂, w₃ are weights

### 4.2 Relation Confidence
For a relation e:
c(e) = w₁·c_spatial + w₂·c_semantic + w₃·c_context
where:
- c_spatial is the spatial confidence
- c_semantic is the semantic confidence
- c_context is the context confidence
- w₁, w₂, w₃ are weights

## 5. Mathematical Properties

### 5.1 Transitivity
For relations r₁, r₂ ∈ R:
If v₁ r₁ v₂ and v₂ r₂ v₃, then v₁ r₃ v₃
where r₃ is the transitive relation

### 5.2 Symmetry
For relation r ∈ R:
If v₁ r v₂, then v₂ r⁻¹ v₁
where r⁻¹ is the inverse relation

### 5.3 Reflexivity
For relation r ∈ R:
v r v for all v ∈ V

## 6. Optimization Techniques

### 6.1 Spatial Partitioning
Divide space into cells C = {c₁, c₂, ..., cₙ}
For each cell c:
V(c) = {v ∈ V | p(v) ∈ c}

### 6.2 Relation Caching
Cache frequently accessed relations:
R_cache = {(v₁, v₂, r) | v₁, v₂ ∈ V, r ∈ R}

### 6.3 Opinion Caching
Cache opinion transformations:
O_cache = {(v, o, T(v, o)) | v ∈ V, o is an opinion}

## 7. Performance Metrics

### 7.1 Time Complexity
- Node addition: O(1)
- Relation addition: O(1)
- Opinion application: O(n) where n is the number of opinion dimensions
- Spatial query: O(log n) with spatial partitioning

### 7.2 Space Complexity
- Node storage: O(|V|)
- Relation storage: O(|E|)
- Opinion storage: O(|V|·n) where n is the number of opinion dimensions

## 8. Error Handling

### 8.1 Confidence Thresholds
For node v:
if c(v) < θ_node, mark v as uncertain
where θ_node is the node confidence threshold

For relation e:
if c(e) < θ_relation, mark e as uncertain
where θ_relation is the relation confidence threshold

### 8.2 Fallback Mechanisms
For uncertain nodes:
v' = fallback(v) where fallback is the fallback function

For uncertain relations:
e' = fallback(e) where fallback is the fallback function

## 9. Integration Considerations

### 9.1 Unity Integration
- Convert Unity coordinates to scene graph coordinates
- Map Unity transforms to scene graph nodes
- Handle Unity material properties in opinion transformations

### 9.2 Roguescroll Integration
- Map Roguescroll entities to scene graph nodes
- Convert Roguescroll spatial relations to scene graph relations
- Handle Roguescroll-specific opinion effects

## 10. Future Extensions

### 10.1 Advanced Opinion Spaces
- Non-linear opinion transformations
- Multi-dimensional opinion blending
- Temporal opinion evolution

### 10.2 Enhanced Spatial Relations
- Fuzzy spatial relations
- Probabilistic relation inference
- Dynamic relation updates

### 10.3 Performance Optimizations
- Parallel processing of opinions
- GPU-accelerated transformations
- Distributed scene graph processing 