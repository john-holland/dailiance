package dailiance.pathing;

import dailiance.math.Vector3;
import dailiance.math.Path;
import dailiance.scene.SceneGraph;
import dailiance.scene.SceneNode;

class PathingSystem {
    private var sceneGraph:SceneGraph;
    private var pathCache:Map<String, Path>;
    private var maxPathLength:Float;
    private var pathSmoothing:Float;

    public function new(sceneGraph:SceneGraph) {
        this.sceneGraph = sceneGraph;
        this.pathCache = new Map();
        this.maxPathLength = 100.0;
        this.pathSmoothing = 0.5;
    }

    public function generateAssistPath(start:Vector3, target:Vector3):Path {
        var path = new Path();
        
        // Generate direct path with urgency
        path.points = generateDirectPath(start, target);
        path.speed = 1.2; // Faster than normal
        path.urgency = 0.8;
        path.behavior = PathBehavior.Assist;
        
        // Add path modifiers
        path.modifiers.push(new PathModifier("determined", "hesitant"));
        path.modifiers.push(new PathModifier("focused", "distracted"));
        
        return path;
    }

    public function generateConfrontPath(start:Vector3, target:Vector3):Path {
        var path = new Path();
        
        // Generate aggressive approach path
        path.points = generateAggressivePath(start, target);
        path.speed = 1.0;
        path.urgency = 0.6;
        path.behavior = PathBehavior.Confront;
        
        // Add path modifiers
        path.modifiers.push(new PathModifier("aggressive", "submissive"));
        path.modifiers.push(new PathModifier("confident", "uncertain"));
        
        return path;
    }

    public function generateExplorePath(start:Vector3, target:Vector3):Path {
        var path = new Path();
        
        // Generate meandering exploration path
        path.points = generateExplorationPath(start, target);
        path.speed = 0.8; // Slower than normal
        path.urgency = 0.3;
        path.behavior = PathBehavior.Explore;
        
        // Add path modifiers
        path.modifiers.push(new PathModifier("curious", "disinterested"));
        path.modifiers.push(new PathModifier("observant", "careless"));
        
        return path;
    }

    public function generateFleePath(start:Vector3, target:Vector3):Path {
        var path = new Path();
        
        // Generate escape path away from target
        path.points = generateEscapePath(start, target);
        path.speed = 1.5; // Fastest speed
        path.urgency = 1.0;
        path.behavior = PathBehavior.Flee;
        
        // Add path modifiers
        path.modifiers.push(new PathModifier("panicked", "calm"));
        path.modifiers.push(new PathModifier("desperate", "composed"));
        
        return path;
    }

    private function generateDirectPath(start:Vector3, target:Vector3):Array<Vector3> {
        var points:Array<Vector3> = [];
        var direction = target.subtract(start).normalize();
        var distance = Vector3.distance(start, target);
        
        // Generate points along direct path
        var numPoints = Math.ceil(distance / 2.0); // Points every 2 units
        for (i in 0...numPoints) {
            var t = i / (numPoints - 1);
            var point = start.add(direction.multiply(distance * t));
            points.push(point);
        }
        
        return smoothPath(points);
    }

    private function generateAggressivePath(start:Vector3, target:Vector3):Array<Vector3> {
        var points = generateDirectPath(start, target);
        
        // Add aggressive movement patterns
        for (i in 1...points.length - 1) {
            if (i % 3 == 0) { // Add zigzag pattern
                var direction = points[i + 1].subtract(points[i - 1]).normalize();
                var perpendicular = new Vector3(-direction.z, 0, direction.x);
                points[i] = points[i].add(perpendicular.multiply(Math.sin(i * 0.5) * 2.0));
            }
        }
        
        return smoothPath(points);
    }

    private function generateExplorationPath(start:Vector3, target:Vector3):Array<Vector3> {
        var points:Array<Vector3> = [];
        var current = start;
        var direction = target.subtract(start).normalize();
        var distance = Vector3.distance(start, target);
        
        // Generate meandering path
        while (Vector3.distance(current, target) > 2.0) {
            points.push(current);
            
            // Add random exploration
            var randomAngle = (Math.random() - 0.5) * Math.PI * 0.5;
            var rotation = new Matrix3x3().setRotationY(randomAngle);
            direction = rotation.transformVector(direction);
            
            // Move forward with some randomness
            current = current.add(direction.multiply(2.0 + Math.random()));
        }
        
        points.push(target);
        return smoothPath(points);
    }

    private function generateEscapePath(start:Vector3, target:Vector3):Array<Vector3> {
        var points:Array<Vector3> = [];
        var escapeDirection = start.subtract(target).normalize();
        var current = start;
        
        // Generate path away from target
        for (i in 0...10) {
            points.push(current);
            
            // Add some randomness to escape path
            var randomAngle = (Math.random() - 0.5) * Math.PI * 0.25;
            var rotation = new Matrix3x3().setRotationY(randomAngle);
            escapeDirection = rotation.transformVector(escapeDirection);
            
            current = current.add(escapeDirection.multiply(5.0));
        }
        
        return smoothPath(points);
    }

    private function smoothPath(points:Array<Vector3>):Array<Vector3> {
        if (points.length < 3) return points;
        
        var smoothed:Array<Vector3> = [];
        smoothed.push(points[0]);
        
        for (i in 1...points.length - 1) {
            var prev = points[i - 1];
            var current = points[i];
            var next = points[i + 1];
            
            // Smooth point using weighted average
            var smoothedPoint = current.multiply(1 - pathSmoothing)
                .add(prev.add(next).multiply(pathSmoothing * 0.5));
            
            smoothed.push(smoothedPoint);
        }
        
        smoothed.push(points[points.length - 1]);
        return smoothed;
    }
}

class Path {
    public var points:Array<Vector3>;
    public var speed:Float;
    public var urgency:Float;
    public var behavior:PathBehavior;
    public var modifiers:Array<PathModifier>;

    public function new() {
        points = [];
        speed = 1.0;
        urgency = 0.5;
        behavior = PathBehavior.None;
        modifiers = [];
    }
}

enum PathBehavior {
    None;
    Assist;
    Confront;
    Explore;
    Flee;
}

class PathModifier {
    public var positive:String;
    public var negative:String;

    public function new(positive:String, negative:String) {
        this.positive = positive;
        this.negative = negative;
    }
} 