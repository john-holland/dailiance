package dailiance.scene;

import dailiance.math.Vector3;
import dailiance.math.Quaternion;
import dailiance.math.Matrix3x3;
import dailiance.math.Ray;
import dailiance.visualization.HitResult;
import dailiance.visualization.Material;

class SceneGraph {
    private var root:SceneNode;
    private var nodes:Array<SceneNode>;
    private var manifold:NonEuclideanManifold;
    private var spatialIndex:SpatialIndex;

    public function new() {
        root = new SceneNode();
        nodes = [];
        manifold = new NonEuclideanManifold();
        spatialIndex = new SpatialIndex();
    }

    public function addNode(node:SceneNode):Void {
        nodes.push(node);
        spatialIndex.insert(node);
        updateManifold();
    }

    public function removeNode(node:SceneNode):Void {
        nodes.remove(node);
        spatialIndex.remove(node);
        updateManifold();
    }

    public function update(deltaTime:Float):Void {
        for (node in nodes) {
            node.update(deltaTime);
        }
        updateManifold();
    }

    public function render(renderer:Renderer):Void {
        for (node in nodes) {
            node.render(renderer);
        }
    }

    public function intersect(ray:Ray):HitResult {
        // Transform ray to manifold space
        var manifoldRay = manifold.transformRay(ray);
        
        // Get potential intersections from spatial index
        var candidates = spatialIndex.query(manifoldRay);
        
        var closestHit:HitResult = null;
        var minDistance = Float.POSITIVE_INFINITY;
        
        for (node in candidates) {
            var hit = node.intersect(manifoldRay);
            if (hit != null && hit.distance < minDistance) {
                minDistance = hit.distance;
                closestHit = hit;
            }
        }
        
        if (closestHit != null) {
            // Transform hit result back to world space
            return manifold.inverseTransformHit(closestHit);
        }
        
        return null;
    }

    private function updateManifold():Void {
        // Update manifold based on scene topology
        manifold.update(nodes);
    }
}

class SceneNode {
    public var position:Vector3;
    public var rotation:Quaternion;
    public var scale:Vector3;
    public var material:Material;
    public var geometry:Geometry;
    public var children:Array<SceneNode>;
    public var parent:SceneNode;
    public var bounds:BoundingBox;

    public function new() {
        position = new Vector3();
        rotation = new Quaternion();
        scale = new Vector3(1, 1, 1);
        material = new Material();
        children = [];
        bounds = new BoundingBox();
    }

    public function update(deltaTime:Float):Void {
        // Update node transform
        updateTransform();
        
        // Update children
        for (child in children) {
            child.update(deltaTime);
        }
        
        // Update bounds
        updateBounds();
    }

    public function render(renderer:Renderer):Void {
        // Render node geometry
        if (geometry != null) {
            geometry.render(renderer, getWorldTransform());
        }
        
        // Render children
        for (child in children) {
            child.render(renderer);
        }
    }

    public function intersect(ray:Ray):HitResult {
        // Transform ray to local space
        var localRay = transformRay(ray);
        
        // Check intersection with geometry
        if (geometry != null) {
            var hit = geometry.intersect(localRay);
            if (hit != null) {
                // Transform hit result to world space
                return transformHit(hit);
            }
        }
        
        // Check intersection with children
        var closestHit:HitResult = null;
        var minDistance = Float.POSITIVE_INFINITY;
        
        for (child in children) {
            var hit = child.intersect(ray);
            if (hit != null && hit.distance < minDistance) {
                minDistance = hit.distance;
                closestHit = hit;
            }
        }
        
        return closestHit;
    }

    private function updateTransform():Void {
        // Update world transform based on parent
        if (parent != null) {
            var parentTransform = parent.getWorldTransform();
            setWorldTransform(parentTransform.multiply(getLocalTransform()));
        } else {
            setWorldTransform(getLocalTransform());
        }
    }

    private function updateBounds():Void {
        if (geometry != null) {
            bounds = geometry.getBounds().transform(getWorldTransform());
        } else {
            bounds = new BoundingBox();
        }
        
        for (child in children) {
            bounds.merge(child.bounds);
        }
    }

    public function getWorldTransform():Matrix3x3 {
        var transform = new Matrix3x3();
        transform.setTranslation(position);
        transform.setRotation(rotation);
        transform.setScale(scale);
        return transform;
    }

    private function getLocalTransform():Matrix3x3 {
        var transform = new Matrix3x3();
        transform.setTranslation(position);
        transform.setRotation(rotation);
        transform.setScale(scale);
        return transform;
    }

    private function setWorldTransform(transform:Matrix3x3):Void {
        position = transform.getTranslation();
        rotation = transform.getRotation();
        scale = transform.getScale();
    }

    private function transformRay(ray:Ray):Ray {
        var localRay = new Ray();
        var invTransform = getWorldTransform().inverse();
        
        localRay.origin = invTransform.transformPoint(ray.origin);
        localRay.direction = invTransform.transformVector(ray.direction);
        
        return localRay;
    }

    private function transformHit(hit:HitResult):HitResult {
        var worldHit = new HitResult();
        var transform = getWorldTransform();
        
        worldHit.position = transform.transformPoint(hit.position);
        worldHit.normal = transform.transformVector(hit.normal).normalize();
        worldHit.distance = hit.distance;
        worldHit.material = hit.material;
        
        return worldHit;
    }
}

class NonEuclideanManifold {
    private var curvature:Float;
    private var topology:ManifoldTopology;
    private var transform:Matrix3x3;

    public function new() {
        curvature = 0;
        topology = ManifoldTopology.Euclidean;
        transform = new Matrix3x3();
    }

    public function update(nodes:Array<SceneNode>):Void {
        // Update manifold based on scene topology
        calculateCurvature(nodes);
        updateTopology(nodes);
        updateTransform();
    }

    public function transformRay(ray:Ray):Ray {
        var manifoldRay = new Ray();
        manifoldRay.origin = transform.transformPoint(ray.origin);
        manifoldRay.direction = transform.transformVector(ray.direction);
        return manifoldRay;
    }

    public function inverseTransformHit(hit:HitResult):HitResult {
        var worldHit = new HitResult();
        var invTransform = transform.inverse();
        
        worldHit.position = invTransform.transformPoint(hit.position);
        worldHit.normal = invTransform.transformVector(hit.normal).normalize();
        worldHit.distance = hit.distance;
        worldHit.material = hit.material;
        
        return worldHit;
    }

    private function calculateCurvature(nodes:Array<SceneNode>):Void {
        // Calculate manifold curvature based on scene topology
        var totalCurvature = 0.0;
        var nodeCount = nodes.length;
        
        for (i in 0...nodeCount) {
            for (j in (i + 1)...nodeCount) {
                var node1 = nodes[i];
                var node2 = nodes[j];
                var distance = Vector3.distance(node1.position, node2.position);
                var expectedDistance = calculateExpectedDistance(node1, node2);
                totalCurvature += (distance - expectedDistance) / expectedDistance;
            }
        }
        
        curvature = totalCurvature / (nodeCount * (nodeCount - 1) / 2);
    }

    private function calculateExpectedDistance(node1:SceneNode, node2:SceneNode):Float {
        // Calculate expected distance in Euclidean space
        return Vector3.distance(node1.position, node2.position);
    }

    private function updateTopology(nodes:Array<SceneNode>):Void {
        // Update manifold topology based on scene structure
        var connections = calculateConnections(nodes);
        topology = determineTopology(connections);
    }

    private function calculateConnections(nodes:Array<SceneNode>):Array<{node1:SceneNode, node2:SceneNode, weight:Float}> {
        var connections = [];
        
        for (i in 0...nodes.length) {
            for (j in (i + 1)...nodes.length) {
                var node1 = nodes[i];
                var node2 = nodes[j];
                var weight = calculateConnectionWeight(node1, node2);
                connections.push({node1: node1, node2: node2, weight: weight});
            }
        }
        
        return connections;
    }

    private function calculateConnectionWeight(node1:SceneNode, node2:SceneNode):Float {
        // Calculate connection weight based on distance and other factors
        var distance = Vector3.distance(node1.position, node2.position);
        return 1.0 / (1.0 + distance * distance);
    }

    private function determineTopology(connections:Array<{node1:SceneNode, node2:SceneNode, weight:Float}>):ManifoldTopology {
        // Determine manifold topology based on connection patterns
        var totalWeight = 0.0;
        var maxWeight = 0.0;
        
        for (connection in connections) {
            totalWeight += connection.weight;
            if (connection.weight > maxWeight) {
                maxWeight = connection.weight;
            }
        }
        
        var averageWeight = totalWeight / connections.length;
        
        if (maxWeight > averageWeight * 2) {
            return ManifoldTopology.Hyperbolic;
        } else if (maxWeight < averageWeight * 0.5) {
            return ManifoldTopology.Spherical;
        } else {
            return ManifoldTopology.Euclidean;
        }
    }

    private function updateTransform():Void {
        // Update transformation matrix based on curvature and topology
        transform = new Matrix3x3();
        
        switch (topology) {
            case Euclidean:
                // Identity transformation
            case Spherical:
                // Spherical transformation
                var radius = 1.0 / curvature;
                transform.setScale(new Vector3(radius, radius, radius));
            case Hyperbolic:
                // Hyperbolic transformation
                var scale = 1.0 / (1.0 + curvature);
                transform.setScale(new Vector3(scale, scale, scale));
        }
    }
}

enum ManifoldTopology {
    Euclidean;
    Spherical;
    Hyperbolic;
}

class BoundingBox {
    public var min:Vector3;
    public var max:Vector3;

    public function new() {
        min = new Vector3(Float.POSITIVE_INFINITY, Float.POSITIVE_INFINITY, Float.POSITIVE_INFINITY);
        max = new Vector3(Float.NEGATIVE_INFINITY, Float.NEGATIVE_INFINITY, Float.NEGATIVE_INFINITY);
    }

    public function merge(other:BoundingBox):Void {
        min.x = Math.min(min.x, other.min.x);
        min.y = Math.min(min.y, other.min.y);
        min.z = Math.min(min.z, other.min.z);
        
        max.x = Math.max(max.x, other.max.x);
        max.y = Math.max(max.y, other.max.y);
        max.z = Math.max(max.z, other.max.z);
    }

    public function transform(transform:Matrix3x3):BoundingBox {
        var transformed = new BoundingBox();
        
        // Transform all corners of the bounding box
        var corners = [
            new Vector3(min.x, min.y, min.z),
            new Vector3(max.x, min.y, min.z),
            new Vector3(min.x, max.y, min.z),
            new Vector3(max.x, max.y, min.z),
            new Vector3(min.x, min.y, max.z),
            new Vector3(max.x, min.y, max.z),
            new Vector3(min.x, max.y, max.z),
            new Vector3(max.x, max.y, max.z)
        ];
        
        for (corner in corners) {
            var transformedCorner = transform.transformPoint(corner);
            transformed.min.x = Math.min(transformed.min.x, transformedCorner.x);
            transformed.min.y = Math.min(transformed.min.y, transformedCorner.y);
            transformed.min.z = Math.min(transformed.min.z, transformedCorner.z);
            
            transformed.max.x = Math.max(transformed.max.x, transformedCorner.x);
            transformed.max.y = Math.max(transformed.max.y, transformedCorner.y);
            transformed.max.z = Math.max(transformed.max.z, transformedCorner.z);
        }
        
        return transformed;
    }
}

class SpatialIndex {
    private var nodes:Array<SceneNode>;
    private var grid:Map<String, Array<SceneNode>>;
    private var cellSize:Float;

    public function new() {
        nodes = [];
        grid = new Map();
        cellSize = 10.0;
    }

    public function insert(node:SceneNode):Void {
        nodes.push(node);
        updateGrid();
    }

    public function remove(node:SceneNode):Void {
        nodes.remove(node);
        updateGrid();
    }

    public function query(ray:Ray):Array<SceneNode> {
        var candidates = [];
        var cells = getIntersectedCells(ray);
        
        for (cell in cells) {
            var cellNodes = grid.get(cell);
            if (cellNodes != null) {
                candidates = candidates.concat(cellNodes);
            }
        }
        
        return candidates;
    }

    private function updateGrid():Void {
        grid.clear();
        
        for (node in nodes) {
            var cells = getNodeCells(node);
            for (cell in cells) {
                if (!grid.exists(cell)) {
                    grid.set(cell, []);
                }
                grid.get(cell).push(node);
            }
        }
    }

    private function getNodeCells(node:SceneNode):Array<String> {
        var cells = [];
        var bounds = node.bounds;
        
        var minCellX = Math.floor(bounds.min.x / cellSize);
        var minCellY = Math.floor(bounds.min.y / cellSize);
        var minCellZ = Math.floor(bounds.min.z / cellSize);
        
        var maxCellX = Math.floor(bounds.max.x / cellSize);
        var maxCellY = Math.floor(bounds.max.y / cellSize);
        var maxCellZ = Math.floor(bounds.max.z / cellSize);
        
        for (x in minCellX...maxCellX + 1) {
            for (y in minCellY...maxCellY + 1) {
                for (z in minCellZ...maxCellZ + 1) {
                    cells.push('${x},${y},${z}');
                }
            }
        }
        
        return cells;
    }

    private function getIntersectedCells(ray:Ray):Array<String> {
        var cells = [];
        var t = 0.0;
        var step = cellSize / 2.0;
        
        while (t < 1000.0) {
            var point = ray.origin.add(ray.direction.multiply(t));
            var cellX = Math.floor(point.x / cellSize);
            var cellY = Math.floor(point.y / cellSize);
            var cellZ = Math.floor(point.z / cellSize);
            
            cells.push('${cellX},${cellY},${cellZ}');
            t += step;
        }
        
        return cells;
    }
} 