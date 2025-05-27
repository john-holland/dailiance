package dailiance.math;

enum CoordinateSystemType {
    Cartesian;
    Spherical;
    Hyperbolic;
    Pillar;
    AABB;
}

class CoordinateTokenizer {
    private var systems:Map<String, IManifold>;
    private var actorMappings:Map<String, CoordinateSystemType>;

    public function new() {
        systems = new Map<String, IManifold>();
        actorMappings = new Map<String, CoordinateSystemType>();
        initializeSystems();
    }

    private function initializeSystems():Void {
        systems.set("cartesian", new CartesianManifold());
        systems.set("spherical", new SphericalManifold());
        systems.set("hyperbolic", new HyperbolicManifold());
        systems.set("pillar", new PillarManifold());
        systems.set("aabb", new AABBManifold());
    }

    public function tokenizeSystem(type:CoordinateSystemType):Token {
        return switch(type) {
            case Cartesian: new Token("cartesian", systems.get("cartesian"));
            case Spherical: new Token("spherical", systems.get("spherical"));
            case Hyperbolic: new Token("hyperbolic", systems.get("hyperbolic"));
            case Pillar: new Token("pillar", systems.get("pillar"));
            case AABB: new Token("aabb", systems.get("aabb"));
        };
    }

    public function convertBetweenSystems(from:Token, to:Token, point:Vector3):Vector3 {
        var intermediate = from.manifold.inverseTransform(point);
        return to.manifold.transformPoint(intermediate);
    }

    public function associateActor(actorId:String, system:CoordinateSystemType):Void {
        actorMappings.set(actorId, system);
    }

    public function getActorSystem(actorId:String):CoordinateSystemType {
        return actorMappings.exists(actorId) ? actorMappings.get(actorId) : Cartesian;
    }

    public function transformActorPosition(actorId:String, position:Vector3):Vector3 {
        var system = getActorSystem(actorId);
        var token = tokenizeSystem(system);
        return token.manifold.transformPoint(position);
    }
}

class Token {
    public var name:String;
    public var manifold:IManifold;

    public function new(name:String, manifold:IManifold) {
        this.name = name;
        this.manifold = manifold;
    }
}

interface IManifold {
    function transformPoint(point:Vector3):Vector3;
    function inverseTransform(point:Vector3):Vector3;
    function getMetric(point:Vector3):Matrix3x3;
}

class CartesianManifold implements IManifold {
    public function new() {}

    public function transformPoint(point:Vector3):Vector3 {
        return point;
    }

    public function inverseTransform(point:Vector3):Vector3 {
        return point;
    }

    public function getMetric(point:Vector3):Matrix3x3 {
        return Matrix3x3.identity();
    }
}

class SphericalManifold implements IManifold {
    public function new() {}

    public function transformPoint(point:Vector3):Vector3 {
        var r = point.magnitude();
        var theta = Math.atan2(point.y, point.x);
        var phi = Math.acos(point.z / r);
        
        return new Vector3(
            r * Math.sin(phi) * Math.cos(theta),
            r * Math.sin(phi) * Math.sin(theta),
            r * Math.cos(phi)
        );
    }

    public function inverseTransform(point:Vector3):Vector3 {
        var r = point.magnitude();
        var theta = Math.atan2(point.y, point.x);
        var phi = Math.acos(point.z / r);
        
        return new Vector3(r, theta, phi);
    }

    public function getMetric(point:Vector3):Matrix3x3 {
        var r = point.magnitude();
        var sinPhi = Math.sin(Math.acos(point.z / r));
        
        return new Matrix3x3(
            1, 0, 0,
            0, r * r, 0,
            0, 0, r * r * sinPhi * sinPhi
        );
    }
}

class HyperbolicManifold implements IManifold {
    public function new() {}

    public function transformPoint(point:Vector3):Vector3 {
        var r = point.magnitude();
        var theta = Math.atan2(point.y, point.x);
        var phi = Math.acos(point.z / r);
        
        return new Vector3(
            Math.sinh(r) * Math.sin(phi) * Math.cos(theta),
            Math.sinh(r) * Math.sin(phi) * Math.sin(theta),
            Math.cosh(r) * Math.cos(phi)
        );
    }

    public function inverseTransform(point:Vector3):Vector3 {
        var r = Math.acosh(point.magnitude());
        var theta = Math.atan2(point.y, point.x);
        var phi = Math.acos(point.z / point.magnitude());
        
        return new Vector3(r, theta, phi);
    }

    public function getMetric(point:Vector3):Matrix3x3 {
        var r = point.magnitude();
        var sinPhi = Math.sin(Math.acos(point.z / r));
        
        return new Matrix3x3(
            1, 0, 0,
            0, Math.sinh(r) * Math.sinh(r), 0,
            0, 0, Math.sinh(r) * Math.sinh(r) * sinPhi * sinPhi
        );
    }
}

class PillarManifold implements IManifold {
    public function new() {}

    public function transformPoint(point:Vector3):Vector3 {
        var r = Math.sqrt(point.x * point.x + point.y * point.y);
        var theta = Math.atan2(point.y, point.x);
        
        return new Vector3(
            r * Math.cos(theta),
            r * Math.sin(theta),
            point.z
        );
    }

    public function inverseTransform(point:Vector3):Vector3 {
        var r = Math.sqrt(point.x * point.x + point.y * point.y);
        var theta = Math.atan2(point.y, point.x);
        
        return new Vector3(r, theta, point.z);
    }

    public function getMetric(point:Vector3):Matrix3x3 {
        return Matrix3x3.identity();
    }
}

class AABBManifold implements IManifold {
    private var min:Vector3;
    private var max:Vector3;

    public function new(min:Vector3, max:Vector3) {
        this.min = min;
        this.max = max;
    }

    public function transformPoint(point:Vector3):Vector3 {
        return new Vector3(
            (point.x - min.x) / (max.x - min.x),
            (point.y - min.y) / (max.y - min.y),
            (point.z - min.z) / (max.z - min.z)
        );
    }

    public function inverseTransform(point:Vector3):Vector3 {
        return new Vector3(
            point.x * (max.x - min.x) + min.x,
            point.y * (max.y - min.y) + min.y,
            point.z * (max.z - min.z) + min.z
        );
    }

    public function getMetric(point:Vector3):Matrix3x3 {
        return Matrix3x3.identity();
    }
} 