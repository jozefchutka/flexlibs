package sk.yoz.math
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.geom.Point;
    
    public class RayMath extends Object
    {
        public function RayMath()
        {
            super();
        }
        
        public static function getRayPoints(lamp:DisplayObject, 
            boundary:DisplayObject, rayCount:uint = 50, rayRange:uint = 50)
            :Array
        {
            var lp:Point, gp:Point, fp:Point;
            var points:Array = [];
            var angle:Number;
            for(var i:uint = 0; i < rayCount; i++)
            {
                fp = null;
                for(var j:uint = 0; j < rayRange; j++)
                {
                    angle = Math.PI / rayCount * i * 2;
                    lp = new Point(Math.cos(angle) * j, Math.sin(angle) * j);
                    gp = lamp.localToGlobal(lp);
                    if(!boundary.hitTestPoint(gp.x, gp.y, true))
                        break;
                    fp = lp;
                }
                if(fp)
                    points.push(fp);
            }
            return points;
        }
        
        public static function boundaryDistance(points:Array):Number
        {
            var shortest:Number = Number.MAX_VALUE;
            var zeroPoint:Point = new Point(0, 0);
            var distance:Number;
            for each(var point:Point in points)
            {
                distance = Point.distance(point, zeroPoint);
                if(distance < shortest)
                    shortest = distance;
            }
            return shortest;
        }
        
        public static function drawRays(lamp:Sprite, points:Array):void
        {
            if(!points.length)
                return;
            lamp.graphics.moveTo(points[0].x, points[0].y);
            for each(var point:Point in points)
                lamp.graphics.lineTo(point.x, point.y);
            lamp.graphics.lineTo(points[0].x, points[0].y);
        }
    }
}