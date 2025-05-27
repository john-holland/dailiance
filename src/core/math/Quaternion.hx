package dailiance.math;

class Quaternion {
    public var x:Float;
    public var y:Float;
    public var z:Float;
    public var w:Float;

    public function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 1) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }

    public function multiply(q:Quaternion):Quaternion {
        return new Quaternion(
            w * q.x + x * q.w + y * q.z - z * q.y,
            w * q.y - x * q.z + y * q.w + z * q.x,
            w * q.z + x * q.y - y * q.x + z * q.w,
            w * q.w - x * q.x - y * q.y - z * q.z
        );
    }

    public function conjugate():Quaternion {
        return new Quaternion(-x, -y, -z, w);
    }

    public function normalize():Quaternion {
        var length = Math.sqrt(x * x + y * y + z * z + w * w);
        if (length == 0) return new Quaternion();
        return new Quaternion(x / length, y / length, z / length, w / length);
    }

    public function fromEuler(pitch:Float, yaw:Float, roll:Float):Quaternion {
        var cy = Math.cos(yaw * 0.5);
        var sy = Math.sin(yaw * 0.5);
        var cp = Math.cos(pitch * 0.5);
        var sp = Math.sin(pitch * 0.5);
        var cr = Math.cos(roll * 0.5);
        var sr = Math.sin(roll * 0.5);

        return new Quaternion(
            cy * cp * sr - sy * sp * cr,
            sy * cp * sr + cy * sp * cr,
            sy * cp * cr - cy * sp * sr,
            cy * cp * cr + sy * sp * sr
        );
    }

    public function toEuler():{pitch:Float, yaw:Float, roll:Float} {
        var pitch:Float, yaw:Float, roll:Float;
        
        // Roll (x-axis rotation)
        var sinr_cosp = 2 * (w * x + y * z);
        var cosr_cosp = 1 - 2 * (x * x + y * y);
        roll = Math.atan2(sinr_cosp, cosr_cosp);

        // Pitch (y-axis rotation)
        var sinp = 2 * (w * y - z * x);
        if (Math.abs(sinp) >= 1) {
            pitch = Math.PI / 2 * (sinp >= 0 ? 1 : -1);
        } else {
            pitch = Math.asin(sinp);
        }

        // Yaw (z-axis rotation)
        var siny_cosp = 2 * (w * z + x * y);
        var cosy_cosp = 1 - 2 * (y * y + z * z);
        yaw = Math.atan2(siny_cosp, cosy_cosp);

        return {pitch: pitch, yaw: yaw, roll: roll};
    }

    public function fromAxisAngle(axis:Vector3, angle:Float):Quaternion {
        var halfAngle = angle * 0.5;
        var s = Math.sin(halfAngle);
        return new Quaternion(
            axis.x * s,
            axis.y * s,
            axis.z * s,
            Math.cos(halfAngle)
        );
    }

    public function toAxisAngle():{axis:Vector3, angle:Float} {
        var angle = 2 * Math.acos(w);
        var s = Math.sqrt(1 - w * w);
        
        if (s < 0.001) {
            return {
                axis: new Vector3(1, 0, 0),
                angle: angle
            };
        }

        return {
            axis: new Vector3(x / s, y / s, z / s),
            angle: angle
        };
    }

    public function slerp(q:Quaternion, t:Float):Quaternion {
        var dot = x * q.x + y * q.y + z * q.z + w * q.w;
        
        if (dot < 0) {
            q = new Quaternion(-q.x, -q.y, -q.z, -q.w);
            dot = -dot;
        }

        if (dot > 0.9995) {
            return new Quaternion(
                x + (q.x - x) * t,
                y + (q.y - y) * t,
                z + (q.z - z) * t,
                w + (q.w - w) * t
            ).normalize();
        }

        var theta_0 = Math.acos(dot);
        var theta = theta_0 * t;
        var sin_theta = Math.sin(theta);
        var sin_theta_0 = Math.sin(theta_0);

        var s0 = Math.cos(theta) - dot * sin_theta / sin_theta_0;
        var s1 = sin_theta / sin_theta_0;

        return new Quaternion(
            s0 * x + s1 * q.x,
            s0 * y + s1 * q.y,
            s0 * z + s1 * q.z,
            s0 * w + s1 * q.w
        );
    }

    public function toString():String {
        return 'Quaternion($x, $y, $z, $w)';
    }
} 