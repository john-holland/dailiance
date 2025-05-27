package dailiance.pathing;

import dailiance.math.Vector3;
import dailiance.math.BoundingBox;
import dailiance.math.Capsule;
import dailiance.scene.SceneGraph;
import dailiance.visualization.ExteriorCamera;

class HierarchicalPathing {
    private var sceneGraph:SceneGraph;
    private var exteriorCamera:ExteriorCamera;
    private var octree:Octree;
    private var invertedOctree:Octree;
    private var capsuleColliders:Array<Capsule>;
    private var centroidHubs:Array<CentroidHub>;
    private var pathCache:Map<String, Path>;

    public function new(sceneGraph:SceneGraph, exteriorCamera:ExteriorCamera) {
        this.sceneGraph = sceneGraph;
        this.exteriorCamera = exteriorCamera;
        this.capsuleColliders = [];
        this.centroidHubs = [];
        this.pathCache = new Map();
        
        // Initialize octrees
        initializeOctrees();
    }

    private function initializeOctrees():Void {
        // Create main octree for scene geometry
        var sceneBounds = sceneGraph.getBoundingBox();
        octree = new Octree(sceneBounds, 8); // Max depth of 8
        
        // Create inverted octree for navigable space
        invertedOctree = new Octree(sceneBounds, 8);
        
        // Subdivide scene geometry
        subdivideSceneGeometry();
        
        // Create inverted space
        createInvertedSpace();
        
        // Generate centroid hubs
        generateCentroidHubs();
    }

    private function subdivideSceneGeometry():Void {
        // Get all 3D shapes from scene
        var shapes = sceneGraph.getShapes();
        
        for (shape in shapes) {
            if (!isConvex(shape)) {
                // Decompose non-convex shapes into convex parts
                var convexParts = decomposeConvex(shape);
                for (part in convexParts) {
                    octree.insert(part);
                }
            } else {
                octree.insert(shape);
            }
        }
    }

    private function createInvertedSpace():Void {
        // Create inverted octree by inverting the main octree
        var bounds = octree.getBounds();
        var resolution = octree.getResolution();
        
        // Create grid of points
        for (x in 0...resolution) {
            for (y in 0...resolution) {
                for (z in 0...resolution) {
                    var point = bounds.getPointAt(x, y, z);
                    if (!isPointInObstacle(point)) {
                        invertedOctree.insert(point);
                    }
                }
            }
        }
    }

    private function generateCentroidHubs():Void {
        // Get all navigable cells from inverted octree
        var navigableCells = invertedOctree.getLeafCells();
        
        // Calculate centroids for each cell
        for (cell in navigableCells) {
            var centroid = cell.getCentroid();
            var hub = new CentroidHub(centroid);
            
            // Create capsule colliders for connections
            createHubConnections(hub, navigableCells);
            
            centroidHubs.push(hub);
        }
    }

    private function createHubConnections(hub:CentroidHub, cells:Array<OctreeCell>):Void {
        for (otherCell in cells) {
            if (otherCell != hub.cell) {
                var otherCentroid = otherCell.getCentroid();
                if (hasLineOfSight(hub.centroid, otherCentroid)) {
                    var capsule = new Capsule(hub.centroid, otherCentroid, 0.5); // 0.5 radius
                    capsuleColliders.push(capsule);
                    hub.addConnection(otherCell);
                }
            }
        }
    }

    public function findPath(start:Vector3, end:Vector3, pathType:PathType):Path {
        var cacheKey = '${start.toString()}_${end.toString()}_${pathType}';
        if (pathCache.exists(cacheKey)) {
            return pathCache.get(cacheKey);
        }

        // Find nearest hubs
        var startHub = findNearestHub(start);
        var endHub = findNearestHub(end);

        // Perform A* search
        var path = performAStarSearch(startHub, endHub, pathType);
        
        // Cache the result
        pathCache.set(cacheKey, path);
        
        return path;
    }

    private function performAStarSearch(start:CentroidHub, end:CentroidHub, pathType:PathType):Path {
        var openSet = [start];
        var closedSet = new Map<String, Bool>();
        var cameFrom = new Map<String, CentroidHub>();
        var gScore = new Map<String, Float>();
        var fScore = new Map<String, Float>();
        
        gScore.set(start.id, 0);
        fScore.set(start.id, heuristic(start, end));
        
        while (openSet.length > 0) {
            var current = getLowestFScore(openSet, fScore);
            
            if (current == end) {
                return reconstructPath(cameFrom, current, pathType);
            }
            
            openSet.remove(current);
            closedSet.set(current.id, true);
            
            for (neighbor in current.connections) {
                if (closedSet.exists(neighbor.id)) continue;
                
                var tentativeGScore = gScore.get(current.id) + distance(current, neighbor);
                
                if (!openSet.contains(neighbor)) {
                    openSet.push(neighbor);
                } else if (tentativeGScore >= gScore.get(neighbor.id)) {
                    continue;
                }
                
                cameFrom.set(neighbor.id, current);
                gScore.set(neighbor.id, tentativeGScore);
                fScore.set(neighbor.id, tentativeGScore + heuristic(neighbor, end));
            }
        }
        
        return null; // No path found
    }

    private function reconstructPath(cameFrom:Map<String, CentroidHub>, 
                                   end:CentroidHub, 
                                   pathType:PathType):Path {
        var path = new Path();
        var current = end;
        
        while (cameFrom.exists(current.id)) {
            path.addPoint(current.centroid);
            current = cameFrom.get(current.id);
        }
        
        path.addPoint(current.centroid);
        path.reverse();
        
        // Apply path type modifications
        modifyPathForType(path, pathType);
        
        return path;
    }

    private function modifyPathForType(path:Path, pathType:PathType):Void {
        switch (pathType) {
            case Direct:
                // Keep path as is
            case Meandering:
                addMeanderingModification(path);
            case Circular:
                addCircularModification(path);
            case Zigzag:
                addZigzagModification(path);
            case Random:
                addRandomModification(path);
        }
    }

    private function addMeanderingModification(path:Path):Void {
        var points = path.getPoints();
        var modifiedPoints = [];
        
        for (i in 0...points.length - 1) {
            var current = points[i];
            var next = points[i + 1];
            
            // Add slight deviation
            var deviation = Vector3.random().scale(0.5);
            var midPoint = current.add(next).scale(0.5).add(deviation);
            
            modifiedPoints.push(current);
            modifiedPoints.push(midPoint);
        }
        
        modifiedPoints.push(points[points.length - 1]);
        path.setPoints(modifiedPoints);
    }

    private function addCircularModification(path:Path):Void {
        var points = path.getPoints();
        var modifiedPoints = [];
        
        for (i in 0...points.length - 1) {
            var current = points[i];
            var next = points[i + 1];
            
            // Add circular arc
            var center = current.add(next).scale(0.5);
            var radius = current.distance(next) * 0.5;
            
            for (angle in 0...180 step 45) {
                var point = calculateArcPoint(center, radius, angle);
                modifiedPoints.push(point);
            }
        }
        
        path.setPoints(modifiedPoints);
    }

    private function addZigzagModification(path:Path):Void {
        var points = path.getPoints();
        var modifiedPoints = [];
        
        for (i in 0...points.length - 1) {
            var current = points[i];
            var next = points[i + 1];
            
            // Add zigzag pattern
            var direction = next.subtract(current).normalize();
            var perpendicular = direction.cross(Vector3.up()).normalize();
            
            var midPoint1 = current.add(next).scale(0.5).add(perpendicular.scale(0.5));
            var midPoint2 = current.add(next).scale(0.5).subtract(perpendicular.scale(0.5));
            
            modifiedPoints.push(current);
            modifiedPoints.push(midPoint1);
            modifiedPoints.push(midPoint2);
        }
        
        modifiedPoints.push(points[points.length - 1]);
        path.setPoints(modifiedPoints);
    }

    private function addRandomModification(path:Path):Void {
        var points = path.getPoints();
        var modifiedPoints = [];
        
        for (i in 0...points.length - 1) {
            var current = points[i];
            var next = points[i + 1];
            
            // Add random deviation
            var deviation = Vector3.random().scale(0.3);
            var midPoint = current.add(next).scale(0.5).add(deviation);
            
            modifiedPoints.push(current);
            modifiedPoints.push(midPoint);
        }
        
        modifiedPoints.push(points[points.length - 1]);
        path.setPoints(modifiedPoints);
    }

    private function isPointInObstacle(point:Vector3):Bool {
        return octree.isPointInObstacle(point);
    }

    private function hasLineOfSight(start:Vector3, end:Vector3):Bool {
        var direction = end.subtract(start);
        var distance = direction.length();
        direction = direction.normalize();
        
        // Check for intersections with capsule colliders
        for (capsule in capsuleColliders) {
            if (capsule.intersectsLine(start, direction, distance)) {
                return false;
            }
        }
        
        return true;
    }

    private function findNearestHub(point:Vector3):CentroidHub {
        var nearest = centroidHubs[0];
        var minDistance = point.distance(nearest.centroid);
        
        for (hub in centroidHubs) {
            var distance = point.distance(hub.centroid);
            if (distance < minDistance) {
                minDistance = distance;
                nearest = hub;
            }
        }
        
        return nearest;
    }

    private function heuristic(a:CentroidHub, b:CentroidHub):Float {
        return a.centroid.distance(b.centroid);
    }

    private function distance(a:CentroidHub, b:CentroidHub):Float {
        return a.centroid.distance(b.centroid);
    }

    private function getLowestFScore(hubs:Array<CentroidHub>, 
                                   fScore:Map<String, Float>):CentroidHub {
        var lowest = hubs[0];
        var lowestScore = fScore.get(lowest.id);
        
        for (hub in hubs) {
            var score = fScore.get(hub.id);
            if (score < lowestScore) {
                lowestScore = score;
                lowest = hub;
            }
        }
        
        return lowest;
    }
}

class Octree {
    private var bounds:BoundingBox;
    private var maxDepth:Int;
    private var children:Array<Octree>;
    private var objects:Array<Dynamic>;
    private var depth:Int;

    public function new(bounds:BoundingBox, maxDepth:Int) {
        this.bounds = bounds;
        this.maxDepth = maxDepth;
        this.children = [];
        this.objects = [];
        this.depth = 0;
    }

    public function insert(object:Dynamic):Void {
        if (depth == maxDepth) {
            objects.push(object);
            return;
        }

        if (children.length == 0) {
            subdivide();
        }

        for (child in children) {
            if (child.bounds.contains(object)) {
                child.insert(object);
                return;
            }
        }

        objects.push(object);
    }

    private function subdivide():Void {
        var center = bounds.getCenter();
        var halfSize = bounds.getSize().scale(0.5);

        for (i in 0...8) {
            var offset = new Vector3(
                (i & 1) == 0 ? -halfSize.x : halfSize.x,
                (i & 2) == 0 ? -halfSize.y : halfSize.y,
                (i & 4) == 0 ? -halfSize.z : halfSize.z
            );

            var childBounds = new BoundingBox(
                center.add(offset),
                halfSize
            );

            var child = new Octree(childBounds, maxDepth);
            child.depth = depth + 1;
            children.push(child);
        }
    }

    public function getLeafCells():Array<OctreeCell> {
        var cells = [];
        
        if (children.length == 0) {
            cells.push(new OctreeCell(bounds, objects));
        } else {
            for (child in children) {
                cells = cells.concat(child.getLeafCells());
            }
        }
        
        return cells;
    }

    public function isPointInObstacle(point:Vector3):Bool {
        if (!bounds.contains(point)) {
            return false;
        }

        if (children.length == 0) {
            for (object in objects) {
                if (object.contains(point)) {
                    return true;
                }
            }
            return false;
        }

        for (child in children) {
            if (child.isPointInObstacle(point)) {
                return true;
            }
        }

        return false;
    }
}

class OctreeCell {
    public var bounds:BoundingBox;
    public var objects:Array<Dynamic>;

    public function new(bounds:BoundingBox, objects:Array<Dynamic>) {
        this.bounds = bounds;
        this.objects = objects;
    }

    public function getCentroid():Vector3 {
        return bounds.getCenter();
    }
}

class CentroidHub {
    public var id:String;
    public var centroid:Vector3;
    public var cell:OctreeCell;
    public var connections:Array<OctreeCell>;

    public function new(centroid:Vector3) {
        this.id = generateUniqueId();
        this.centroid = centroid;
        this.connections = [];
    }

    public function addConnection(cell:OctreeCell):Void {
        connections.push(cell);
    }

    private function generateUniqueId():String {
        return "hub_" + Date.now().getTime() + "_" + Math.floor(Math.random() * 1000);
    }
}

enum PathType {
    Direct;
    Meandering;
    Circular;
    Zigzag;
    Random;
} 