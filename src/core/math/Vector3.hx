package dailiance.math;

class Vector3 {
    public var x:Float;
    public var y:Float;
    public var z:Float;

    public function new(x:Float = 0, y:Float = 0, z:Float = 0) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public function add(v:Vector3):Vector3 {
        return new Vector3(x + v.x, y + v.y, z + v.z);
    }

    public function subtract(v:Vector3):Vector3 {
        return new Vector3(x - v.x, y - v.y, z - v.z);
    }

    public function scale(s:Float):Vector3 {
        return new Vector3(x * s, y * s, z * s);
    }

    public function dot(v:Vector3):Float {
        return x * v.x + y * v.y + z * v.z;
    }

    public function cross(v:Vector3):Vector3 {
        return new Vector3(
            y * v.z - z * v.y,
            z * v.x - x * v.z,
            x * v.y - y * v.x
        );
    }

    public function length():Float {
        return Math.sqrt(x * x + y * y + z * z);
    }

    public function normalize():Vector3 {
        var len = length();
        if (len == 0) return new Vector3();
        return scale(1 / len);
    }

    public function distance(v:Vector3):Float {
        var dx = x - v.x;
        var dy = y - v.y;
        var dz = z - v.z;
        return Math.sqrt(dx * dx + dy * dy + dz * dz);
    }

    public function toString():String {
        return '(${x}, ${y}, ${z})';
    }

    public static function zero():Vector3 {
        return new Vector3(0, 0, 0);
    }

    public static function up():Vector3 {
        return new Vector3(0, 1, 0);
    }

    public static function random():Vector3 {
        return new Vector3(
            Math.random() * 2 - 1,
            Math.random() * 2 - 1,
            Math.random() * 2 - 1
        ).normalize();
    }

    public function equals(v:Vector3):Bool {
        return x == v.x && y == v.y && z == v.z;
    }

    public function lerp(v:Vector3, t:Float):Vector3 {
        return new Vector3(
            x + (v.x - x) * t,
            y + (v.y - y) * t,
            z + (v.z - z) * t
        );
    }

    public function reflect(normal:Vector3):Vector3 {
        var dot = this.dot(normal);
        return subtract(normal.scale(2 * dot));
    }

    public function project(onto:Vector3):Vector3 {
        var dot = this.dot(onto);
        var lenSq = onto.dot(onto);
        return onto.scale(dot / lenSq);
    }

    public function rotate(axis:Vector3, angle:Float):Vector3 {
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);
        var axis = axis.normalize();
        
        return new Vector3(
            x * (cos + axis.x * axis.x * (1 - cos)) +
            y * (axis.x * axis.y * (1 - cos) - axis.z * sin) +
            z * (axis.x * axis.z * (1 - cos) + axis.y * sin),
            
            x * (axis.y * axis.x * (1 - cos) + axis.z * sin) +
            y * (cos + axis.y * axis.y * (1 - cos)) +
            z * (axis.y * axis.z * (1 - cos) - axis.x * sin),
            
            x * (axis.z * axis.x * (1 - cos) - axis.y * sin) +
            y * (axis.z * axis.y * (1 - cos) + axis.x * sin) +
            z * (cos + axis.z * axis.z * (1 - cos))
        );
    }
} 