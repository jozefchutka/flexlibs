package sk.yoz.math
{
    public class Math2D
    {
        public function Math2D()
        {
        }
        
        public static function calcA(x1:Number, y1:Number, x2:Number, y2:Number)
            :Number
        {
            return (y1 - y2) / (x1 - x2);
        }
        
        public static function projectX(
            boundary1X:Number, boundary1Y:Number,
            boundary2X:Number, boundary2Y:Number,
            pointX:Number, pointY:Number):Number
        {
            if(boundary1X == boundary2X)
                return boundary1X;
            if(boundary1Y == boundary2Y)
                return pointX;
            var a:Number = calcA(boundary1X, boundary1Y, boundary2X, boundary2Y);
            return (pointY - boundary2Y + boundary2X * a + pointX / a) /
                   (a + 1 / a);
        }
        
        public static function projectY(
            boundary1X:Number, boundary1Y:Number,
            boundary2X:Number, boundary2Y:Number,
            pointX:Number, pointY:Number):Number
        {
            if(boundary1X == boundary2X)
                return pointY;
            if(boundary1Y == boundary2Y)
                return boundary1Y;
            var a:Number = calcA(boundary1X, boundary1Y, boundary2X, boundary2Y);
            var x:Number = projectX(boundary1X, boundary1Y,
                boundary2X, boundary2Y, pointX, pointY)
            return pointY + (pointX - x) / a;
        }
        
        public static function isUnderBoundaries(
            boundary1X:Number, boundary1Y:Number,
            boundary2X:Number, boundary2Y:Number,
            projectedX:Number, projectedY:Number):Boolean
        {
            if(boundary1X == boundary2X)
                return projectedY <= 
                    (boundary1Y > boundary2Y ? boundary1Y : boundary2Y);
            return projectedX <= 
                (boundary1X > boundary2X ? boundary1X : boundary2X);
        }
        
        public static function isOverBoundaries(
            boundary1X:Number, boundary1Y:Number,
            boundary2X:Number, boundary2Y:Number,
            projectedX:Number, projectedY:Number):Boolean
        {
            if(boundary1X == boundary2X)
                return projectedY >= 
                    (boundary1Y < boundary2Y ? boundary1Y : boundary2Y);
            return projectedX >= 
                (boundary1X < boundary2X ? boundary1X : boundary2X);
        }
        
        public static function isProjectedUnderBoundaries(
            boundary1X:Number, boundary1Y:Number,
            boundary2X:Number, boundary2Y:Number,
            pointX:Number, pointY:Number):Boolean
        {
            var x:Number = projectX(boundary1X, boundary1Y,
                boundary2X, boundary2Y, pointX, pointY);
            var y:Number = projectY(boundary1X, boundary1Y,
                boundary2X, boundary2Y, pointX, pointY);
            return isUnderBoundaries(boundary1X, boundary1Y, 
                boundary2X, boundary2Y, x, y);
        }
        
        public static function isProjectedOverBoundaries(
            boundary1X:Number, boundary1Y:Number,
            boundary2X:Number, boundary2Y:Number,
            pointX:Number, pointY:Number):Boolean
        {
            var x:Number = projectX(boundary1X, boundary1Y,
                boundary2X, boundary2Y, pointX, pointY);
            var y:Number = projectY(boundary1X, boundary1Y,
                boundary2X, boundary2Y, pointX, pointY);
            return isOverBoundaries(boundary1X, boundary1Y, 
                boundary2X, boundary2Y, x, y);
        }
        
        public static function isAxisCollision(
            boundary1X:Number, boundary1Y:Number,
            boundary2X:Number, boundary2Y:Number,
            projected1X:Number, projected1Y:Number,
            projected2X:Number, projected2Y:Number,
            projected3X:Number, projected3Y:Number,
            projected4X:Number, projected4Y:Number):Boolean
        {
            return hasOneUnderBoundaries(boundary1X, boundary1Y,
                    boundary2X, boundary2Y,
                    projected1X, projected1Y,
                    projected2X, projected2Y,
                    projected3X, projected3Y,
                    projected4X, projected4Y) &&
                hasOneOverBoundaries(boundary1X, boundary1Y,
                    boundary2X, boundary2Y,
                    projected1X, projected1Y,
                    projected2X, projected2Y,
                    projected3X, projected3Y,
                    projected4X, projected4Y);
        }
        
        public static function isProjectedAxisCollision(
            boundary1X:Number, boundary1Y:Number,
            boundary2X:Number, boundary2Y:Number,
            point1X:Number, point1Y:Number,
            point2X:Number, point2Y:Number,
            point3X:Number, point3Y:Number,
            point4X:Number, point4Y:Number):Boolean
        {
            return isAxisCollision(boundary1X, boundary1Y, 
                boundary2X, boundary2Y,
                projectX(boundary1X, boundary1Y, boundary2X, boundary2Y, 
                    point1X, point1Y),
                projectY(boundary1X, boundary1Y, boundary2X, boundary2Y, 
                    point1X, point1Y),
                projectX(boundary1X, boundary1Y, boundary2X, boundary2Y, 
                    point2X, point2Y),
                projectY(boundary1X, boundary1Y, boundary2X, boundary2Y, 
                    point2X, point2Y),
                projectX(boundary1X, boundary1Y, boundary2X, boundary2Y, 
                    point3X, point3Y),
                projectY(boundary1X, boundary1Y, boundary2X, boundary2Y, 
                    point3X, point3Y),
                projectX(boundary1X, boundary1Y, boundary2X, boundary2Y, 
                    point4X, point4Y),
                projectY(boundary1X, boundary1Y, boundary2X, boundary2Y, 
                    point4X, point4Y));
        }
        
        public static function hasOneUnderBoundaries(
            boundary1X:Number, boundary1Y:Number,
            boundary2X:Number, boundary2Y:Number,
            projected1X:Number, projected1Y:Number,
            projected2X:Number, projected2Y:Number,
            projected3X:Number, projected3Y:Number,
            projected4X:Number, projected4Y:Number):Boolean
        {
            if(isUnderBoundaries(boundary1X, boundary1Y, 
                boundary2X, boundary2Y, projected1X, projected1Y))
                return true;
            if(isUnderBoundaries(boundary1X, boundary1Y, 
                boundary2X, boundary2Y, projected2X, projected2Y))
                return true;
            if(isUnderBoundaries(boundary1X, boundary1Y, 
                boundary2X, boundary2Y, projected3X, projected3Y))
                return true;
            if(isUnderBoundaries(boundary1X, boundary1Y, 
                boundary2X, boundary2Y, projected4X, projected4Y))
                return true;
            return false;
        }
        
        public static function hasOneOverBoundaries(
            boundary1X:Number, boundary1Y:Number,
            boundary2X:Number, boundary2Y:Number,
            projected1X:Number, projected1Y:Number,
            projected2X:Number, projected2Y:Number,
            projected3X:Number, projected3Y:Number,
            projected4X:Number, projected4Y:Number):Boolean
        {
            if(isOverBoundaries(boundary1X, boundary1Y, 
                boundary2X, boundary2Y, projected1X, projected1Y))
                return true;
            if(isOverBoundaries(boundary1X, boundary1Y, 
                boundary2X, boundary2Y, projected2X, projected2Y))
                return true;
            if(isOverBoundaries(boundary1X, boundary1Y, 
                boundary2X, boundary2Y, projected3X, projected3Y))
                return true;
            if(isOverBoundaries(boundary1X, boundary1Y, 
                boundary2X, boundary2Y, projected4X, projected4Y))
                return true;
            return false;
        }
    }
}