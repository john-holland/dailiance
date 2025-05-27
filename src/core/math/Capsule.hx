package dailiance.math;

class Capsule {
    public var start:Vector3;
    public var end:Vector3;
    public var radius:Float;

    public function new(start:Vector3, end:Vector3, radius:Float) {
        this.start = start;
        this.end = end;
        this.radius = radius;
    }

    public function intersectsLine(lineStart:Vector3, lineDirection:Vector3, lineLength:Float):Bool {
        // Calculate closest points between line and capsule
        var closestPointOnLine = closestPointOnLineSegment(lineStart, lineDirection, lineLength);
        var closestPointOnCapsule = closestPointOnCapsule(closestPointOnLine);
        
        // Check if distance between closest points is less than capsule radius
        return closestPointOnLine.distance(closestPointOnCapsule) <= radius;
    }

    private function closestPointOnLineSegment(lineStart:Vector3, lineDirection:Vector3, lineLength:Float):Vector3 {
        var lineEnd = lineStart.add(lineDirection.scale(lineLength));
        var capsuleDirection = end.subtract(start);
        var capsuleLength = capsuleDirection.length();
        capsuleDirection = capsuleDirection.normalize();
        
        // Calculate closest points between infinite lines
        var closestPointOnLine = closestPointOnInfiniteLine(lineStart, lineDirection, start, capsuleDirection);
        
        // Clamp to line segment
        var t = (closestPointOnLine.subtract(lineStart)).dot(lineDirection);
        t = Math.max(0, Math.min(lineLength, t));
        
        return lineStart.add(lineDirection.scale(t));
    }

    private function closestPointOnCapsule(point:Vector3):Vector3 {
        var capsuleDirection = end.subtract(start);
        var capsuleLength = capsuleDirection.length();
        capsuleDirection = capsuleDirection.normalize();
        
        // Calculate closest point on infinite line
        var closestPointOnLine = closestPointOnInfiniteLine(point, Vector3.zero(), start, capsuleDirection);
        
        // Clamp to capsule segment
        var t = (closestPointOnLine.subtract(start)).dot(capsuleDirection);
        t = Math.max(0, Math.min(capsuleLength, t));
        
        return start.add(capsuleDirection.scale(t));
    }

    private function closestPointOnInfiniteLine(point:Vector3, line1Start:Vector3, line1Dir:Vector3, 
                                              line2Start:Vector3, line2Dir:Vector3):Vector3 {
        var n1 = line1Dir.cross(line2Dir);
        var n2 = line2Dir.cross(n1);
        
        var c1 = line1Start.add(line1Dir.scale(
            (point.subtract(line1Start)).dot(n2) / line1Dir.dot(n2)
        ));
        
        var c2 = line2Start.add(line2Dir.scale(
            (point.subtract(line2Start)).dot(n1) / line2Dir.dot(n1)
        ));
        
        return c1.add(c2).scale(0.5);
    }
} 