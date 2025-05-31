# Scene Graph and Actor Interaction Mathematics

## 1. Scene Graph Structure

### 1.1 Basic Graph Representation
The scene graph \(G = (V, E)\) consists of:
- Vertices \(V\): Scene nodes with properties
- Edges \(E\): Spatial relations between nodes

### 1.2 Node Properties
Each node \(n \in V\) has properties:
\[
n = \begin{cases}
    id: \text{unique identifier} \\
    label: \text{object class} \\
    confidence: [0,1] \\
    boundingBox: \begin{cases}
        x, y: \text{position} \\
        width, height: \text{dimensions}
    \end{cases} \\
    metadata: \begin{cases}
        positivePrompt: \text{what is there} \\
        negativePrompt: \text{what is not there} \\
        opinionPrompt: \text{style preferences} \\
        codifiedOpinion: \text{AI-reinterpreted prompts}
    \end{cases}
\end{cases}
\]

## 2. Spatial Relations

### 2.1 Relation Definition
A spatial relation \(r \in E\) between nodes \(n_1, n_2 \in V\):
\[
r = \begin{cases}
    source: n_1.id \\
    target: n_2.id \\
    relation: \text{spatial descriptor} \\
    confidence: [0,1]
\end{cases}
\]

### 2.2 Spatial Calculation
For nodes with bounding boxes \(b_1, b_2\):
\[
\text{center}_i = \begin{pmatrix}
    b_i.x + \frac{b_i.width}{2} \\
    b_i.y + \frac{b_i.height}{2}
\end{pmatrix}
\]

Relative position:
\[
\text{relation} = \begin{cases}
    \text{"to the right of"} & \text{if } dx > |dy| \text{ and } dx > 0 \\
    \text{"to the left of"} & \text{if } dx > |dy| \text{ and } dx < 0 \\
    \text{"below"} & \text{if } dy > |dx| \text{ and } dy > 0 \\
    \text{"above"} & \text{if } dy > |dx| \text{ and } dy < 0
\end{cases}
\]

## 3. Non-Euclidean Manifold

### 3.1 Curvature Calculation
For a set of nodes \(N\):
\[
\text{curvature} = \frac{1}{|N|(|N|-1)/2} \sum_{i=1}^{|N|} \sum_{j=i+1}^{|N|} \frac{d_{ij} - d_{ij}^e}{d_{ij}^e}
\]
where:
- \(d_{ij}\): Actual distance between nodes \(i\) and \(j\)
- \(d_{ij}^e\): Expected Euclidean distance

### 3.2 Topology Classification
Based on connection weights \(w_{ij}\):
\[
\text{topology} = \begin{cases}
    \text{Hyperbolic} & \text{if } w_{max} > 2\bar{w} \\
    \text{Spherical} & \text{if } w_{max} < 0.5\bar{w} \\
    \text{Euclidean} & \text{otherwise}
\end{cases}
\]

## 4. Actor Interactions

### 4.1 Path Generation
For actor \(A\) moving from \(p_1\) to \(p_2\):
\[
\text{Path} = \begin{cases}
    \text{points}: [p_1, ..., p_2] \\
    \text{speed}: v \in [0,1] \\
    \text{urgency}: u \in [0,1] \\
    \text{behavior}: \text{PathBehavior} \\
    \text{modifiers}: \text{Array<PathModifier>}
\end{cases}
\]

### 4.2 Interaction Types
For actors \(A_1, A_2\):
\[
\text{interactionType} = f(\text{distance}, \text{relativeDirection}, \text{actorStates})
\]

## 5. Prompt Generation

### 5.1 Base Prompts
For node \(n\):
\[
\text{positivePrompt} = \begin{cases}
    n.label & \text{if } \text{instanceCount} = 1 \\
    \text{"Currently the } k\text{th } n.label \text{ in the scene"} & \text{otherwise}
\end{cases}
\]

### 5.2 Opinion-based Reinterpretation
For opinion \(o = \{\text{style}, \text{mood}, \text{quality}\}\):
\[
\text{codifiedOpinion} = \begin{cases}
    \text{positivePrompt}: \text{AI}(p, o) \\
    \text{negativePrompt}: \text{AI}(n, o) \\
    \text{reasoning}: \text{AI explanation}
\end{cases}
\]

## 6. Scene Analysis

### 6.1 Visibility Calculation
For actor \(A\) and camera \(C\):
\[
\text{visible} = \begin{cases}
    \text{true} & \text{if } A \in \text{viewFrustum}(C) \\
    \text{false} & \text{otherwise}
\end{cases}
\]

### 6.2 Scene Description
\[
\text{description} = \text{AI}(\text{visibleActors}, \text{spatialRelations}, \text{temporalPatterns})
\]

## 7. Mathematical Proofs and Properties

### 7.1 Graph Properties

#### Theorem 1: Scene Graph Connectivity
For a scene graph \(G = (V, E)\), if every node has at least one spatial relation, then:
\[
|E| \geq |V| - 1
\]

**Proof:**
1. Base case: \(|V| = 1\)
   - Trivially true as no edges needed
2. Inductive step:
   - Assume true for \(|V| = n\)
   - Adding node \(n+1\) requires at least one edge to connect to existing graph
   - Therefore \(|E| \geq n\) for \(|V| = n+1\)
   - By induction, theorem holds for all \(|V| \geq 1\)

#### Theorem 2: Manifold Curvature Bounds
For a scene graph with \(n\) nodes, the curvature \(k\) is bounded by:
\[
-\frac{n-1}{2} \leq k \leq \frac{n-1}{2}
\]

**Proof:**
1. For any pair of nodes \((i,j)\):
   \[
   -1 \leq \frac{d_{ij} - d_{ij}^e}{d_{ij}^e} \leq 1
   \]
2. Summing over all \(\frac{n(n-1)}{2}\) pairs:
   \[
   -\frac{n(n-1)}{2} \leq \sum_{i=1}^{n} \sum_{j=i+1}^{n} \frac{d_{ij} - d_{ij}^e}{d_{ij}^e} \leq \frac{n(n-1)}{2}
   \]
3. Dividing by \(\frac{n(n-1)}{2}\):
   \[
   -1 \leq k \leq 1
   \]

### 7.2 Spatial Relation Properties

#### Theorem 3: Spatial Relation Transitivity
For nodes \(a, b, c\) with spatial relations:
If \(a\) is to the right of \(b\) and \(b\) is to the right of \(c\), then:
\[
P(a \text{ is to the right of } c) \geq \max(P(a \text{ is to the right of } b), P(b \text{ is to the right of } c))
\]

**Proof:**
1. Let \(P_{ab}\) be the probability of \(a\) being to the right of \(b\)
2. Let \(P_{bc}\) be the probability of \(b\) being to the right of \(c\)
3. The probability of \(a\) being to the right of \(c\) is:
   \[
   P_{ac} = P_{ab}P_{bc} + (1-P_{ab})(1-P_{bc})P_{ab}
   \]
4. Since \(P_{ab}, P_{bc} \in [0,1]\):
   \[
   P_{ac} \geq P_{ab}P_{bc} \geq \max(P_{ab}, P_{bc})
   \]

### 7.3 Actor Interaction Properties

#### Theorem 4: Path Optimality
For an actor \(A\) moving from \(p_1\) to \(p_2\) with urgency \(u\):
The optimal path \(P^*\) minimizes:
\[
C(P) = \alpha \sum_{i=1}^{n-1} \|p_{i+1} - p_i\| + \beta \sum_{i=1}^{n-1} \|p_i - p_{i+1}\|^2
\]
where \(\alpha = 1-u\) and \(\beta = u\)

**Proof:**
1. The cost function \(C(P)\) represents:
   - First term: Total path length (weighted by \(1-u\))
   - Second term: Smoothness penalty (weighted by \(u\))
2. For \(u = 0\):
   - Minimizes pure distance (straight line)
3. For \(u = 1\):
   - Minimizes acceleration (smooth path)
4. For \(0 < u < 1\):
   - Balances distance and smoothness
5. The optimal path \(P^*\) satisfies:
   \[
   \frac{\partial C(P^*)}{\partial p_i} = 0 \text{ for all } i
   \]

### 7.4 Prompt Generation Properties

#### Theorem 5: Opinion Consistency
For a set of nodes \(N\) with opinion \(o\):
The codified opinions maintain consistency if:
\[
\forall n_1, n_2 \in N, \text{ if } n_1 \text{ is related to } n_2 \text{ then:}
\]
\[
\text{style}(n_1) = \text{style}(n_2) \text{ and } \text{mood}(n_1) = \text{mood}(n_2)
\]

**Proof:**
1. Let \(R\) be the set of all relations in the scene
2. For each relation \(r \in R\):
   \[
   \text{style}(r.source) = \text{style}(r.target)
   \]
   \[
   \text{mood}(r.source) = \text{mood}(r.target)
   \]
3. By transitivity of relations:
   \[
   \forall n_1, n_2 \in N, \text{style}(n_1) = \text{style}(n_2)
   \]
   \[
   \forall n_1, n_2 \in N, \text{mood}(n_1) = \text{mood}(n_2)
   \]

### 7.5 Scene Analysis Properties

#### Theorem 6: Visibility Completeness
For a scene with \(n\) actors and camera \(C\):
The visibility calculation is complete if:
\[
\sum_{i=1}^{n} P(A_i \text{ is visible}) = \sum_{i=1}^{n} \int_{V} p(A_i|C) dV
\]
where \(V\) is the view frustum and \(p(A_i|C)\) is the visibility probability

**Proof:**
1. For each actor \(A_i\):
   \[
   P(A_i \text{ is visible}) = \int_{V} p(A_i|C) dV
   \]
2. Summing over all actors:
   \[
   \sum_{i=1}^{n} P(A_i \text{ is visible}) = \sum_{i=1}^{n} \int_{V} p(A_i|C) dV
   \]
3. By linearity of integration:
   \[
   \sum_{i=1}^{n} \int_{V} p(A_i|C) dV = \int_{V} \sum_{i=1}^{n} p(A_i|C) dV
   \]
4. Therefore:
   \[
   \sum_{i=1}^{n} P(A_i \text{ is visible}) = \int_{V} \sum_{i=1}^{n} p(A_i|C) dV
   \] 