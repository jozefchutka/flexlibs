/* 
source
http://grepcode.com/file/repository.grepcode.com/java/ext/com.google.android/android/2.2_r1.1/android/hardware/GeomagneticField.java?av=f
*/


package sk.yoz.hardware
{
    public class GeomagneticField
    {
        private var mX:Number;
        private var mY:Number;
        private var mZ:Number;
        
        private var mGcLatitudeRad:Number;
        private var mGcLongitudeRad:Number;
        private var mGcRadiusKm:Number;
        
        private static const EARTH_SEMI_MAJOR_AXIS_KM:Number = 6378.137;
        private static const EARTH_SEMI_MINOR_AXIS_KM:Number = 6356.7523142;
        private static const EARTH_REFERENCE_RADIUS_KM:Number = 6371.2;
        
        private static const TO_RAD:Number = Math.PI / 180;
        private static const TO_DEG:Number = 180 / Math.PI;

		
        private static const G_COEFF:Array = [
            [ 0.0 ],
            [ -29496.6, -1586.3 ],
            [ -2396.6, 3026.1, 1668.6 ],
            [ 1340.1, -2326.2, 1231.9, 634.0 ],
            [ 912.6, 808.9, 166.7, -357.1, 89.4 ],
            [ -230.9, 357.2, 200.3, -141.1, -163.0, -7.8 ],
            [ 72.8, 68.6, 76.0, -141.4, -22.8, 13.2, -77.9 ],
            [ 80.5, -75.1, -4.7, 45.3, 13.9, 10.4, 1.7, 4.9 ],
            [ 24.4, 8.1, -14.5, -5.6, -19.3, 11.5, 10.9, -14.1, -3.7 ],
            [ 5.4, 9.4, 3.4, -5.2, 3.1, -12.4, -0.7, 8.4, -8.5, -10.1 ],
            [ -2.0, -6.3, 0.9, -1.1, -0.2, 2.5, -0.3, 2.2, 3.1, -1.0, -2.8 ],
            [ 3.0, -1.5, -2.1, 1.7, -0.5, 0.5, -0.8, 0.4, 1.8, 0.1, 0.7, 3.8 ],
            [ -2.2, -0.2, 0.3, 1.0, -0.6, 0.9, -0.1, 0.5, -0.4, -0.4, 0.2, -0.8, 0.0 ] ];
        
        private static const H_COEFF:Array = [
            [ 0.0 ],
            [ 0.0, 4944.4 ],
            [ 0.0, -2707.7, -576.1 ],
            [ 0.0, -160.2, 251.9, -536.6 ],
            [ 0.0, 286.4, -211.2, 164.3, -309.1 ],
            [ 0.0, 44.6, 188.9, -118.2, 0.0, 100.9 ],
            [ 0.0, -20.8, 44.1, 61.5, -66.3, 3.1, 55.0 ],
            [ 0.0, -57.9, -21.1, 6.5, 24.9, 7.0, -27.7, -3.3 ],
            [ 0.0, 11.0, -20.0, 11.9, -17.4, 16.7, 7.0, -10.8, 1.7 ],
            [ 0.0, -20.5, 11.5, 12.8, -7.2, -7.4, 8.0, 2.1, -6.1, 7.0 ],
            [ 0.0, 2.8, -0.1, 4.7, 4.4, -7.2, -1.0, -3.9, -2.0, -2.0, -8.3 ],
            [ 0.0, 0.2, 1.7, -0.6, -1.8, 0.9, -0.4, -2.5, -1.3, -2.1, -1.9, -1.8 ],
            [ 0.0, -0.9, 0.3, 2.1, -2.5, 0.5, 0.6, 0.0, 0.1, 0.3, -0.9, -0.2, 0.9 ] ];
        
        private static const DELTA_G:Array = [
            [ 0.0 ],
            [ 11.6, 16.5 ],
            [ -12.1, -4.4, 1.9 ],
            [ 0.4, -4.1, -2.9, -7.7 ],
            [ -1.8, 2.3, -8.7, 4.6, -2.1 ],
            [ -1.0, 0.6, -1.8, -1.0, 0.9, 1.0 ],
            [ -0.2, -0.2, -0.1, 2.0, -1.7, -0.3, 1.7 ],
            [ 0.1, -0.1, -0.6, 1.3, 0.4, 0.3, -0.7, 0.6 ],
            [ -0.1, 0.1, -0.6, 0.2, -0.2, 0.3, 0.3, -0.6, 0.2 ],
            [ 0.0, -0.1, 0.0, 0.3, -0.4, -0.3, 0.1, -0.1, -0.4, -0.2 ],
            [ 0.0, 0.0, -0.1, 0.2, 0.0, -0.1, -0.2, 0.0, -0.1, -0.2, -0.2 ],
            [ 0.0, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.1, 0.0 ],
            [ 0.0, 0.0, 0.1, 0.1, -0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.1, 0.1 ] ];
        
        private static const DELTA_H:Array = [
            [ 0.0 ],
            [ 0.0, -25.9 ],
            [ 0.0, -22.5, -11.8 ],
            [ 0.0, 7.3, -3.9, -2.6 ],
            [ 0.0, 1.1, 2.7, 3.9, -0.8 ],
            [ 0.0, 0.4, 1.8, 1.2, 4.0, -0.6 ],
            [ 0.0, -0.2, -2.1, -0.4, -0.6, 0.5, 0.9 ],
            [ 0.0, 0.7, 0.3, -0.1, -0.1, -0.8, -0.3, 0.3 ],
            [ 0.0, -0.1, 0.2, 0.4, 0.4, 0.1, -0.1, 0.4, 0.3 ],
            [ 0.0, 0.0, -0.2, 0.0, -0.1, 0.1, 0.0, -0.2, 0.3, 0.2 ],
            [ 0.0, 0.1, -0.1, 0.0, -0.1, -0.1, 0.0, -0.1, -0.2, 0.0, -0.1 ],
            [ 0.0, 0.0, 0.1, 0.0, 0.1, 0.0, 0.1, 0.0, -0.1, -0.1, 0.0, -0.1 ],
            [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ] ];
        
        private static const BASE_TIME:Number = new Date(2010, 1, 1).time;
        
        private static const SCHMIDT_QUASI_NORM_FACTORS:Array =
            computeSchmidtQuasiNormFactors(G_COEFF.length);
        
        public function GeomagneticField(gdLatitudeDeg:Number, gdLongitudeDeg:Number, 
            altitudeMeters:Number, timeMillis:Number)
        {
            const MAX_N:int = G_COEFF.length;
            
            gdLatitudeDeg = Math.min(90.0 - 1e-5,
                Math.max(-90.0 + 1e-5, gdLatitudeDeg));
            computeGeocentricCoordinates(gdLatitudeDeg,
                gdLongitudeDeg,
                altitudeMeters);
            
            //assert G_COEFF.length == H_COEFF.length;
            
            var legendre:LegendreTable =
                new LegendreTable(MAX_N - 1,
                    (Math.PI / 2.0 - mGcLatitudeRad));
            
            var relativeRadiusPower:Array = new Array(MAX_N + 2);
            relativeRadiusPower[0] = 1.0;
            relativeRadiusPower[1] = EARTH_REFERENCE_RADIUS_KM / mGcRadiusKm;
            for (var i:int = 2; i < relativeRadiusPower.length; ++i) {
                relativeRadiusPower[i] = relativeRadiusPower[i - 1] *
                    relativeRadiusPower[1];
            }
            
            var sinMLon:Array = new Array(MAX_N);
            var cosMLon:Array = new Array(MAX_N);
            sinMLon[0] = 0.0;
            cosMLon[0] = 1.0;
            sinMLon[1] = Math.sin(mGcLongitudeRad);
            cosMLon[1] = Math.cos(mGcLongitudeRad);
            
            for (var m:int = 2; m < MAX_N; ++m) {
                var x:int = m >> 1;
                sinMLon[m] = sinMLon[m-x] * cosMLon[x] + cosMLon[m-x] * sinMLon[x];
                cosMLon[m] = cosMLon[m-x] * cosMLon[x] - sinMLon[m-x] * sinMLon[x];
            }
            
            var inverseCosLatitude:Number = 1.0 / Math.cos(mGcLatitudeRad);
            var yearsSinceBase:Number =
                (timeMillis - BASE_TIME) / (365 * 24 * 60 * 60 * 1000);
            
            var gcX:Number = 0.0;
            var gcY:Number = 0.0;
            var gcZ:Number = 0.0;
            
            for (var n:int = 1; n < MAX_N; n++) {
                for (m = 0; m <= n; m++) {
                    var g:Number = G_COEFF[n][m] + yearsSinceBase * DELTA_G[n][m];
                    var h:Number = H_COEFF[n][m] + yearsSinceBase * DELTA_H[n][m];
                    
                    gcX += relativeRadiusPower[n+2]
                        * (g * cosMLon[m] + h * sinMLon[m])
                        * legendre.mPDeriv[n][m]
                        * SCHMIDT_QUASI_NORM_FACTORS[n][m];
                    
                    gcY += relativeRadiusPower[n+2] * m
                        * (g * sinMLon[m] - h * cosMLon[m])
                        * legendre.mP[n][m]
                        * SCHMIDT_QUASI_NORM_FACTORS[n][m]
                        * inverseCosLatitude;
                    
                    gcZ -= (n + 1) * relativeRadiusPower[n+2]
                        * (g * cosMLon[m] + h * sinMLon[m])
                        * legendre.mP[n][m]
                        * SCHMIDT_QUASI_NORM_FACTORS[n][m];
                }
            }
            
            var latDiffRad:Number = gdLatitudeDeg * TO_RAD - mGcLatitudeRad;
            mX = (gcX * Math.cos(latDiffRad)
                + gcZ * Math.sin(latDiffRad));
            mY = gcY;
            mZ = (- gcX * Math.sin(latDiffRad)
                + gcZ * Math.cos(latDiffRad));
        }
        
        public function get x():Number
        {
            return mX;
        }
        
        public function get y():Number
        {
            return mY;
        }
        
        public function get z():Number
        {
            return mZ;
        }
        
        public function get declination():Number
        {
            return Math.atan2(mY, mX) * TO_DEG;
        }
        
		public function get inclination():Number
		{
		  return Math.atan2( mZ, horizontalStrength ) * TO_DEG;
		}

		public function get horizontalStrength():Number
		{
		    return Math.sqrt(mX * mX + mY * mY);
		}
		
		public function get fieldStrength():Number
		{
		    return Math.sqrt(mX * mX + mY * mY + mZ * mZ);
		}		

		
        private function computeGeocentricCoordinates(gdLatitudeDeg:Number,
            gdLongitudeDeg:Number, altitudeMeters:Number):void
        {
                var altitudeKm:Number = altitudeMeters / 1000.0;
                var a2:Number = EARTH_SEMI_MAJOR_AXIS_KM * EARTH_SEMI_MAJOR_AXIS_KM;
                var b2:Number = EARTH_SEMI_MINOR_AXIS_KM * EARTH_SEMI_MINOR_AXIS_KM;
                var gdLatRad:Number = gdLatitudeDeg * TO_RAD;
                var clat:Number = Math.cos(gdLatRad);
                var slat:Number = Math.sin(gdLatRad);
                var tlat:Number = slat / clat;
                var latRad:Number =
                    Math.sqrt(a2 * clat * clat + b2 * slat * slat);
                
                mGcLatitudeRad = Math.atan(tlat * (latRad * altitudeKm + b2)
                    / (latRad * altitudeKm + a2));
                
                mGcLongitudeRad = gdLongitudeDeg * TO_RAD;
                
                var radSq:Number = altitudeKm * altitudeKm
                    + 2 * altitudeKm * Math.sqrt(a2 * clat * clat +
                        b2 * slat * slat)
                        + (a2 * a2 * clat * clat + b2 * b2 * slat * slat)
                        / (a2 * clat * clat + b2 * slat * slat);
                mGcRadiusKm = Math.sqrt(radSq);
            }
        
        private static function computeSchmidtQuasiNormFactors(maxN:int):Array
        {
            var schmidtQuasiNorm:Array = new Array(maxN + 1);
            schmidtQuasiNorm[0] = [ 1.0 ];
            for (var n:int = 1; n <= maxN; n++) {
                schmidtQuasiNorm[n] = new Array(n + 1);
                schmidtQuasiNorm[n][0] =
                    schmidtQuasiNorm[n - 1][0] * (2 * n - 1) / n;
                for (var m:int = 1; m <= n; m++) {
                    schmidtQuasiNorm[n][m] = schmidtQuasiNorm[n][m - 1]
                        * Math.sqrt((n - m + 1) * (m == 1 ? 2 : 1)
                            / (n + m));
                }
            }
            return schmidtQuasiNorm;
        }
    }
}

class LegendreTable {
    // These are the Gauss-normalized associated Legendre functions -- that
    // is, they are normal Legendre functions multiplied by
    // (n-m)!/(2n-1)!! (where (2n-1)!! = 1*3*5*...*2n-1)
    public var mP:Array = [];
    
    // Derivative of mP, with respect to theta.
    public var mPDeriv:Array = [];
    
    /**
     * @param maxN
     *            The maximum n- and m-values to support
     * @param thetaRad
     *            Returned functions will be Gauss-normalized
     *            P_n^m(cos(thetaRad)), with thetaRad in radians.
     */
    public function LegendreTable(maxN:int, thetaRad:Number)
    {
        // Compute the table of Gauss-normalized associated Legendre
        // functions using standard recursion relations. Also compute the
        // table of derivatives using the derivative of the recursion
        // relations.
        var cos:Number = Math.cos(thetaRad);
        var sin:Number = Math.sin(thetaRad);
        
        mP = new Array(maxN + 1);
        mPDeriv =  new Array(maxN + 1);
        mP[0] = [ 1.0 ];
        mPDeriv[0] = [ 0.0 ];
        for (var n:int = 1; n <= maxN; n++) {
            mP[n] = new Array(n + 1);
            mPDeriv[n] = new Array(n + 1);
            for (var m:int = 0; m <= n; m++) {
                if (n == m) {
                    mP[n][m] = sin * mP[n - 1][m - 1];
                    mPDeriv[n][m] = cos * mP[n - 1][m - 1]
                        + sin * mPDeriv[n - 1][m - 1];
                } else if (n == 1 || m == n - 1) {
                    mP[n][m] = cos * mP[n - 1][m];
                    mPDeriv[n][m] = -sin * mP[n - 1][m]
                        + cos * mPDeriv[n - 1][m];
                } else {
                    //assert n > 1 && m < n - 1;
                    var k:Number = ((n - 1) * (n - 1) - m * m)
                        / ((2 * n - 1) * (2 * n - 3));
                    mP[n][m] = cos * mP[n - 1][m] - k * mP[n - 2][m];
                    mPDeriv[n][m] = -sin * mP[n - 1][m]
                        + cos * mPDeriv[n - 1][m] - k * mPDeriv[n - 2][m];
                }
            }
        }
    }
}