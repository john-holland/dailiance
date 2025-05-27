package dailiance.math;

class Matrix3x3 {
    public var m00:Float; public var m01:Float; public var m02:Float;
    public var m10:Float; public var m11:Float; public var m12:Float;
    public var m20:Float; public var m21:Float; public var m22:Float;

    public function new(
        m00:Float, m01:Float, m02:Float,
        m10:Float, m11:Float, m12:Float,
        m20:Float, m21:Float, m22:Float
    ) {
        this.m00 = m00; this.m01 = m01; this.m02 = m02;
        this.m10 = m10; this.m11 = m11; this.m12 = m12;
        this.m20 = m20; this.m21 = m21; this.m22 = m22;
    }

    public static function identity():Matrix3x3 {
        return new Matrix3x3(
            1, 0, 0,
            0, 1, 0,
            0, 0, 1
        );
    }

    public function multiply(m:Matrix3x3):Matrix3x3 {
        return new Matrix3x3(
            m00 * m.m00 + m01 * m.m10 + m02 * m.m20,
            m00 * m.m01 + m01 * m.m11 + m02 * m.m21,
            m00 * m.m02 + m01 * m.m12 + m02 * m.m22,
            
            m10 * m.m00 + m11 * m.m10 + m12 * m.m20,
            m10 * m.m01 + m11 * m.m11 + m12 * m.m21,
            m10 * m.m02 + m11 * m.m12 + m12 * m.m22,
            
            m20 * m.m00 + m21 * m.m10 + m22 * m.m20,
            m20 * m.m01 + m21 * m.m11 + m22 * m.m21,
            m20 * m.m02 + m21 * m.m12 + m22 * m.m22
        );
    }

    public function multiplyVector(v:Vector3):Vector3 {
        return new Vector3(
            m00 * v.x + m01 * v.y + m02 * v.z,
            m10 * v.x + m11 * v.y + m12 * v.z,
            m20 * v.x + m21 * v.y + m22 * v.z
        );
    }

    public function transpose():Matrix3x3 {
        return new Matrix3x3(
            m00, m10, m20,
            m01, m11, m21,
            m02, m12, m22
        );
    }

    public function determinant():Float {
        return m00 * (m11 * m22 - m12 * m21) -
               m01 * (m10 * m22 - m12 * m20) +
               m02 * (m10 * m21 - m11 * m20);
    }

    public function inverse():Matrix3x3 {
        var det = determinant();
        if (det == 0) return null;

        var invDet = 1 / det;
        return new Matrix3x3(
            (m11 * m22 - m12 * m21) * invDet,
            (m02 * m21 - m01 * m22) * invDet,
            (m01 * m12 - m02 * m11) * invDet,
            
            (m12 * m20 - m10 * m22) * invDet,
            (m00 * m22 - m02 * m20) * invDet,
            (m02 * m10 - m00 * m12) * invDet,
            
            (m10 * m21 - m11 * m20) * invDet,
            (m01 * m20 - m00 * m21) * invDet,
            (m00 * m11 - m01 * m10) * invDet
        );
    }

    public function scale(s:Float):Matrix3x3 {
        return new Matrix3x3(
            m00 * s, m01 * s, m02 * s,
            m10 * s, m11 * s, m12 * s,
            m20 * s, m21 * s, m22 * s
        );
    }

    public function add(m:Matrix3x3):Matrix3x3 {
        return new Matrix3x3(
            m00 + m.m00, m01 + m.m01, m02 + m.m02,
            m10 + m.m10, m11 + m.m11, m12 + m.m12,
            m20 + m.m20, m21 + m.m21, m22 + m.m22
        );
    }

    public function subtract(m:Matrix3x3):Matrix3x3 {
        return new Matrix3x3(
            m00 - m.m00, m01 - m.m01, m02 - m.m02,
            m10 - m.m10, m11 - m.m11, m12 - m.m12,
            m20 - m.m20, m21 - m.m21, m22 - m.m22
        );
    }

    public function toString():String {
        return 'Matrix3x3(\n' +
               '  $m00, $m01, $m02\n' +
               '  $m10, $m11, $m12\n' +
               '  $m20, $m21, $m22\n' +
               ')';
    }
} 