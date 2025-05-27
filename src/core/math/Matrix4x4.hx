package dailiance.math;

class Matrix4x4 {
    private var elements:Array<Float>;

    public function new() {
        elements = new Array<Float>();
        for (i in 0...16) {
            elements[i] = 0;
        }
        elements[0] = 1;
        elements[5] = 1;
        elements[10] = 1;
        elements[15] = 1;
    }

    public function set(row:Int, col:Int, value:Float):Void {
        elements[row * 4 + col] = value;
    }

    public function get(row:Int, col:Int):Float {
        return elements[row * 4 + col];
    }

    public function multiply(other:Matrix4x4):Matrix4x4 {
        var result = new Matrix4x4();
        
        for (i in 0...4) {
            for (j in 0...4) {
                var sum = 0.0;
                for (k in 0...4) {
                    sum += get(i, k) * other.get(k, j);
                }
                result.set(i, j, sum);
            }
        }
        
        return result;
    }

    public function transformPoint(point:Vector3):Vector3 {
        var x = point.x;
        var y = point.y;
        var z = point.z;
        var w = 1.0;
        
        var resultX = x * get(0, 0) + y * get(0, 1) + z * get(0, 2) + w * get(0, 3);
        var resultY = x * get(1, 0) + y * get(1, 1) + z * get(1, 2) + w * get(1, 3);
        var resultZ = x * get(2, 0) + y * get(2, 1) + z * get(2, 2) + w * get(2, 3);
        var resultW = x * get(3, 0) + y * get(3, 1) + z * get(3, 2) + w * get(3, 3);
        
        if (resultW != 0) {
            resultX /= resultW;
            resultY /= resultW;
            resultZ /= resultW;
        }
        
        return new Vector3(resultX, resultY, resultZ);
    }

    public function transformVector(vector:Vector3):Vector3 {
        var x = vector.x;
        var y = vector.y;
        var z = vector.z;
        
        var resultX = x * get(0, 0) + y * get(0, 1) + z * get(0, 2);
        var resultY = x * get(1, 0) + y * get(1, 1) + z * get(1, 2);
        var resultZ = x * get(2, 0) + y * get(2, 1) + z * get(2, 2);
        
        return new Vector3(resultX, resultY, resultZ);
    }

    public static function translation(x:Float, y:Float, z:Float):Matrix4x4 {
        var matrix = new Matrix4x4();
        matrix.set(0, 3, x);
        matrix.set(1, 3, y);
        matrix.set(2, 3, z);
        return matrix;
    }

    public static function rotation(axis:Vector3, angle:Float):Matrix4x4 {
        var matrix = new Matrix4x4();
        var c = Math.cos(angle);
        var s = Math.sin(angle);
        var t = 1 - c;
        var x = axis.x;
        var y = axis.y;
        var z = axis.z;
        
        matrix.set(0, 0, t * x * x + c);
        matrix.set(0, 1, t * x * y - z * s);
        matrix.set(0, 2, t * x * z + y * s);
        
        matrix.set(1, 0, t * x * y + z * s);
        matrix.set(1, 1, t * y * y + c);
        matrix.set(1, 2, t * y * z - x * s);
        
        matrix.set(2, 0, t * x * z - y * s);
        matrix.set(2, 1, t * y * z + x * s);
        matrix.set(2, 2, t * z * z + c);
        
        return matrix;
    }

    public static function scaling(x:Float, y:Float, z:Float):Matrix4x4 {
        var matrix = new Matrix4x4();
        matrix.set(0, 0, x);
        matrix.set(1, 1, y);
        matrix.set(2, 2, z);
        return matrix;
    }

    public static function perspective(fov:Float, aspect:Float, near:Float, far:Float):Matrix4x4 {
        var matrix = new Matrix4x4();
        var f = 1.0 / Math.tan(fov * 0.5);
        var nf = 1.0 / (near - far);
        
        matrix.set(0, 0, f / aspect);
        matrix.set(1, 1, f);
        matrix.set(2, 2, (far + near) * nf);
        matrix.set(2, 3, 2 * far * near * nf);
        matrix.set(3, 2, -1);
        matrix.set(3, 3, 0);
        
        return matrix;
    }

    public static function orthographic(left:Float, right:Float, bottom:Float, top:Float, near:Float, far:Float):Matrix4x4 {
        var matrix = new Matrix4x4();
        var w = right - left;
        var h = top - bottom;
        var d = far - near;
        
        matrix.set(0, 0, 2 / w);
        matrix.set(1, 1, 2 / h);
        matrix.set(2, 2, -2 / d);
        
        matrix.set(0, 3, -(right + left) / w);
        matrix.set(1, 3, -(top + bottom) / h);
        matrix.set(2, 3, -(far + near) / d);
        
        return matrix;
    }

    public static function lookAt(eye:Vector3, target:Vector3, up:Vector3):Matrix4x4 {
        var matrix = new Matrix4x4();
        var z = eye.subtract(target).normalize();
        var x = up.cross(z).normalize();
        var y = z.cross(x);
        
        matrix.set(0, 0, x.x);
        matrix.set(0, 1, x.y);
        matrix.set(0, 2, x.z);
        
        matrix.set(1, 0, y.x);
        matrix.set(1, 1, y.y);
        matrix.set(1, 2, y.z);
        
        matrix.set(2, 0, z.x);
        matrix.set(2, 1, z.y);
        matrix.set(2, 2, z.z);
        
        matrix.set(0, 3, -x.dot(eye));
        matrix.set(1, 3, -y.dot(eye));
        matrix.set(2, 3, -z.dot(eye));
        
        return matrix;
    }

    public function transpose():Matrix4x4 {
        var result = new Matrix4x4();
        
        for (i in 0...4) {
            for (j in 0...4) {
                result.set(i, j, get(j, i));
            }
        }
        
        return result;
    }

    public function determinant():Float {
        var a00 = get(0, 0);
        var a01 = get(0, 1);
        var a02 = get(0, 2);
        var a03 = get(0, 3);
        
        var a10 = get(1, 0);
        var a11 = get(1, 1);
        var a12 = get(1, 2);
        var a13 = get(1, 3);
        
        var a20 = get(2, 0);
        var a21 = get(2, 1);
        var a22 = get(2, 2);
        var a23 = get(2, 3);
        
        var a30 = get(3, 0);
        var a31 = get(3, 1);
        var a32 = get(3, 2);
        var a33 = get(3, 3);
        
        var b00 = a00 * a11 - a01 * a10;
        var b01 = a00 * a12 - a02 * a10;
        var b02 = a00 * a13 - a03 * a10;
        var b03 = a01 * a12 - a02 * a11;
        var b04 = a01 * a13 - a03 * a11;
        var b05 = a02 * a13 - a03 * a12;
        var b06 = a20 * a31 - a21 * a30;
        var b07 = a20 * a32 - a22 * a30;
        var b08 = a20 * a33 - a23 * a30;
        var b09 = a21 * a32 - a22 * a31;
        var b10 = a21 * a33 - a23 * a31;
        var b11 = a22 * a33 - a23 * a32;
        
        return b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;
    }

    public function inverse():Matrix4x4 {
        var det = determinant();
        if (det == 0) return null;
        
        var result = new Matrix4x4();
        var invDet = 1 / det;
        
        var a00 = get(0, 0);
        var a01 = get(0, 1);
        var a02 = get(0, 2);
        var a03 = get(0, 3);
        
        var a10 = get(1, 0);
        var a11 = get(1, 1);
        var a12 = get(1, 2);
        var a13 = get(1, 3);
        
        var a20 = get(2, 0);
        var a21 = get(2, 1);
        var a22 = get(2, 2);
        var a23 = get(2, 3);
        
        var a30 = get(3, 0);
        var a31 = get(3, 1);
        var a32 = get(3, 2);
        var a33 = get(3, 3);
        
        result.set(0, 0, (a11 * a22 * a33 - a11 * a23 * a32 - a12 * a21 * a33 + a12 * a23 * a31 + a13 * a21 * a32 - a13 * a22 * a31) * invDet);
        result.set(0, 1, (-a01 * a22 * a33 + a01 * a23 * a32 + a02 * a21 * a33 - a02 * a23 * a31 - a03 * a21 * a32 + a03 * a22 * a31) * invDet);
        result.set(0, 2, (a01 * a12 * a33 - a01 * a13 * a32 - a02 * a11 * a33 + a02 * a13 * a31 + a03 * a11 * a32 - a03 * a12 * a31) * invDet);
        result.set(0, 3, (-a01 * a12 * a23 + a01 * a13 * a22 + a02 * a11 * a23 - a02 * a13 * a21 - a03 * a11 * a22 + a03 * a12 * a21) * invDet);
        
        result.set(1, 0, (-a10 * a22 * a33 + a10 * a23 * a32 + a12 * a20 * a33 - a12 * a23 * a30 - a13 * a20 * a32 + a13 * a22 * a30) * invDet);
        result.set(1, 1, (a00 * a22 * a33 - a00 * a23 * a32 - a02 * a20 * a33 + a02 * a23 * a30 + a03 * a20 * a32 - a03 * a22 * a30) * invDet);
        result.set(1, 2, (-a00 * a12 * a33 + a00 * a13 * a32 + a02 * a10 * a33 - a02 * a13 * a30 - a03 * a10 * a32 + a03 * a12 * a30) * invDet);
        result.set(1, 3, (a00 * a12 * a23 - a00 * a13 * a22 - a02 * a10 * a23 + a02 * a13 * a20 + a03 * a10 * a22 - a03 * a12 * a20) * invDet);
        
        result.set(2, 0, (a10 * a21 * a33 - a10 * a23 * a31 - a11 * a20 * a33 + a11 * a23 * a30 + a13 * a20 * a31 - a13 * a21 * a30) * invDet);
        result.set(2, 1, (-a00 * a21 * a33 + a00 * a23 * a31 + a01 * a20 * a33 - a01 * a23 * a30 - a03 * a20 * a31 + a03 * a21 * a30) * invDet);
        result.set(2, 2, (a00 * a11 * a33 - a00 * a13 * a31 - a01 * a10 * a33 + a01 * a13 * a30 + a03 * a10 * a31 - a03 * a11 * a30) * invDet);
        result.set(2, 3, (-a00 * a11 * a23 + a00 * a13 * a21 + a01 * a10 * a23 - a01 * a13 * a20 - a03 * a10 * a21 + a03 * a11 * a20) * invDet);
        
        result.set(3, 0, (-a10 * a21 * a32 + a10 * a22 * a31 + a11 * a20 * a32 - a11 * a22 * a30 - a12 * a20 * a31 + a12 * a21 * a30) * invDet);
        result.set(3, 1, (a00 * a21 * a32 - a00 * a22 * a31 - a01 * a20 * a32 + a01 * a22 * a30 + a02 * a20 * a31 - a02 * a21 * a30) * invDet);
        result.set(3, 2, (-a00 * a11 * a32 + a00 * a12 * a31 + a01 * a10 * a32 - a01 * a12 * a30 - a02 * a10 * a31 + a02 * a11 * a30) * invDet);
        result.set(3, 3, (a00 * a11 * a22 - a00 * a12 * a21 - a01 * a10 * a22 + a01 * a12 * a20 + a02 * a10 * a21 - a02 * a11 * a20) * invDet);
        
        return result;
    }
} 