/*
source
http://grepcode.com/file/repository.grepcode.com/java/ext/com.google.android/android/2.2_r1.1/android/hardware/SensorManager.java#SensorManager
*/

package sk.yoz.hardware
{
    public class SensorManager
    {
        public function SensorManager()
        {
        }
        
        public static function getOrientation(R:Array):Array
        {
            var values:Array = [];
            if (R.length == 9) {
                values[0] = Math.atan2(R[1], R[4]);
                values[1] = Math.asin(-R[7]);
                values[2] = Math.atan2(-R[6], R[8]);
            } else {
                values[0] = Math.atan2(R[1], R[5]);
                values[1] = Math.asin(-R[9]);
                values[2] = Math.atan2(-R[8], R[10]);
            }
            return values;
        }
        
        public static function getRotationMatrix(
            accelerationX:Number, accelerationY:Number, accelerationZ:Number,
            geomagneticX:Number, geomagneticY:Number, geomagneticZ:Number,
            R:Array=null, I:Array=null):Boolean
        {
            var Ax:Number = accelerationX;
            var Ay:Number = accelerationY;
            var Az:Number = accelerationZ;
            const Ex:Number = geomagneticX;
            const Ey:Number = geomagneticY;
            const Ez:Number = geomagneticZ;
            var Hx:Number = Ey*Az - Ez*Ay;
            var Hy:Number = Ez*Ax - Ex*Az;
            var Hz:Number = Ex*Ay - Ey*Ax;
            const normH:Number = Math.sqrt(Hx*Hx + Hy*Hy + Hz*Hz);
            if (normH < 0.1)
            {
                return false;
            }
            const invH:Number = 1.0 / normH;
            Hx *= invH;
            Hy *= invH;
            Hz *= invH;
            const invA:Number = 1.0 / Math.sqrt(Ax*Ax + Ay*Ay + Az*Az);
            Ax *= invA;
            Ay *= invA;
            Az *= invA;
            const Mx:Number = Ay*Hz - Az*Hy;
            const My:Number = Az*Hx - Ax*Hz;
            const Mz:Number = Ax*Hy - Ay*Hx;
            if (R != null) {
                if (R.length == 9) {
                    R[0] = Hx;     R[1] = Hy;     R[2] = Hz;
                    R[3] = Mx;     R[4] = My;     R[5] = Mz;
                    R[6] = Ax;     R[7] = Ay;     R[8] = Az;
                } else if (R.length == 16) {
                    R[0]  = Hx;    R[1]  = Hy;    R[2]  = Hz;   R[3]  = 0;
                    R[4]  = Mx;    R[5]  = My;    R[6]  = Mz;   R[7]  = 0;
                    R[8]  = Ax;    R[9]  = Ay;    R[10] = Az;   R[11] = 0;
                    R[12] = 0;     R[13] = 0;     R[14] = 0;    R[15] = 1;
                }
            }
            if (I != null) {
                // compute the inclination matrix by projecting the geomagnetic
                // vector onto the Z (gravity) and X (horizontal component
                // of geomagnetic vector) axes.
                const invE:Number = 1.0 / Math.sqrt(Ex*Ex + Ey*Ey + Ez*Ez);
                const c:Number = (Ex*Mx + Ey*My + Ez*Mz) * invE;
                const s:Number = (Ex*Ax + Ey*Ay + Ez*Az) * invE;
                if (I.length == 9) {
                    I[0] = 1;     I[1] = 0;     I[2] = 0;
                    I[3] = 0;     I[4] = c;     I[5] = s;
                    I[6] = 0;     I[7] =-s;     I[8] = c;
                } else if (I.length == 16) {
                    I[0] = 1;     I[1] = 0;     I[2] = 0;
                    I[4] = 0;     I[5] = c;     I[6] = s;
                    I[8] = 0;     I[9] =-s;     I[10]= c;
                    I[3] = I[7] = I[11] = I[12] = I[13] = I[14] = 0;
                    I[15] = 1;
                }
            }
            return true;
        }
        
        public static function getInclination(I:Array):Number
        {
            if (I.length == 9)
            {
                return Math.atan2(I[5], I[4]);
            }
            else
            {
                return Math.atan2(I[6], I[5]);
            }
        }
    }
}