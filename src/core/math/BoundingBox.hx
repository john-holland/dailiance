package dailiance.math;

class BoundingBox {
    public var center:Vector3;
    public var size:Vector3;

    public function new(center:Vector3, size:Vector3) {
        this.center = center;
        this.size = size;
    }

    public function contains(point:Vector3):Bool {
        var halfSize = size.scale(0.5);
        return Math.abs(point.x - center.x) <= halfSize.x &&
               Math.abs(point.y - center.y) <= halfSize.y &&
               Math.abs(point.z - center.z) <= halfSize.z;
    }

    public function containsBox(box:BoundingBox):Bool {
        var halfSize = size.scale(0.5);
        var otherHalfSize = box.size.scale(0.5);
        
        return Math.abs(box.center.x - center.x) + otherHalfSize.x <= halfSize.x &&
               Math.abs(box.center.y - center.y) + otherHalfSize.y <= halfSize.y &&
               Math.abs(box.center.z - center.z) + otherHalfSize.z <= halfSize.z;
    }

    public function intersects(box:BoundingBox):Bool {
        var halfSize = size.scale(0.5);
        var otherHalfSize = box.size.scale(0.5);
        
        return Math.abs(box.center.x - center.x) <= halfSize.x + otherHalfSize.x &&
               Math.abs(box.center.y - center.y) <= halfSize.y + otherHalfSize.y &&
               Math.abs(box.center.z - center.z) <= halfSize.z + otherHalfSize.z;
    }

    public function getCenter():Vector3 {
        return center;
    }

    public function getSize():Vector3 {
        return size;
    }

    public function getMin():Vector3 {
        return center.subtract(size.scale(0.5));
    }

    public function getMax():Vector3 {
        return center.add(size.scale(0.5));
    }

    public function getPointAt(x:Int, y:Int, z:Int):Vector3 {
        var min = getMin();
        var max = getMax();
        
        return new Vector3(
            min.x + (max.x - min.x) * x,
            min.y + (max.y - min.y) * y,
            min.z + (max.z - min.z) * z
        );
    }

    public function expand(amount:Float):BoundingBox {
        return new BoundingBox(center, size.add(new Vector3(amount, amount, amount)));
    }

    public function merge(box:BoundingBox):BoundingBox {
        var min = getMin();
        var max = getMax();
        var otherMin = box.getMin();
        var otherMax = box.getMax();
        
        var newMin = new Vector3(
            Math.min(min.x, otherMin.x),
            Math.min(min.y, otherMin.y),
            Math.min(min.z, otherMin.z)
        );
        
        var newMax = new Vector3(
            Math.max(max.x, otherMax.x),
            Math.max(max.y, otherMax.y),
            Math.max(max.z, otherMax.z)
        );
        
        var newCenter = newMin.add(newMax).scale(0.5);
        var newSize = newMax.subtract(newMin);
        
        return new BoundingBox(newCenter, newSize);
    }

    public function getVolume():Float {
        return size.x * size.y * size.z;
    }

    public function getSurfaceArea():Float {
        return 2 * (size.x * size.y + size.y * size.z + size.z * size.x);
    }

    public function getCorners():Array<Vector3> {
        var min = getMin();
        var max = getMax();
        
        return [
            new Vector3(min.x, min.y, min.z),
            new Vector3(max.x, min.y, min.z),
            new Vector3(min.x, max.y, min.z),
            new Vector3(max.x, max.y, min.z),
            new Vector3(min.x, min.y, max.z),
            new Vector3(max.x, min.y, max.z),
            new Vector3(min.x, max.y, max.z),
            new Vector3(max.x, max.y, max.z)
        ];
    }

    public function transform(matrix:Matrix4x4):BoundingBox {
        var corners = getCorners();
        var transformedCorners = corners.map(function(corner) {
            return matrix.transformPoint(corner);
        });
        
        var min = transformedCorners[0];
        var max = transformedCorners[0];
        
        for (i in 1...transformedCorners.length) {
            var corner = transformedCorners[i];
            min = new Vector3(
                Math.min(min.x, corner.x),
                Math.min(min.y, corner.y),
                Math.min(min.z, corner.z)
            );
            max = new Vector3(
                Math.max(max.x, corner.x),
                Math.max(max.y, corner.y),
                Math.max(max.z, corner.z)
            );
        }
        
        var newCenter = min.add(max).scale(0.5);
        var newSize = max.subtract(min);
        
        return new BoundingBox(newCenter, newSize);
    }
} 