package sk.yoz.rider
{
    import flash.geom.Point;

    public class Rider
    {
        public var pointer:RiderPointer;
        
        private var _first:RiderPointer;
        private var _last:RiderPointer;
        private var _length:Number;
        private var points:Vector.<Point>;
        
        public function Rider(points:Vector.<Point>)
        {
            this.points = points;
            var lastIndex:uint = points.length - 1;
            _length = calculateLength(points);
            _first = new RiderPointer(points[0], 0, 0, 0);
            _last = new RiderPointer(points[lastIndex], lastIndex, 1, length);
            gotoFirst();
        }
        
        public function get first():RiderPointer
        {
            return _first;
        }
        
        public function get last():RiderPointer
        {
            return _last;
        }
        
        public function get length():Number
        {
            return _length;
        }
        
        public function gotoFirst():RiderPointer
        {
            pointer = first;
            return pointer;
        }
        
        public function gotoLast():RiderPointer
        {
            pointer = last;
            return pointer;
        }
        
        public function moveBy(distance:Number):RiderPointer
        {
            if(distance == 0)
                return pointer;
            if(!pointer.point && pointer.segment == 0 && distance > 0)
                gotoFirst();
            if(!pointer.point && pointer.segment == points.length - 1 && distance < 0)
                gotoLast();
            if(!pointer.point)
                return pointer;
            
            pointer = moveByProjection(distance);
            return pointer;
        }
        
        public function moveByProjection(distance:Number):RiderPointer
        {
            if(distance == 0)
                return pointer;
            if(!pointer.point)
                return pointer;
            return distance > 0 ? forward(distance) : back(-distance);
        }
        
        private function forward(distance:Number):RiderPointer
        {
            var remainingDistance:Number = distance;
            var pointCount:uint = points.length;
            var current:Point = pointer.point;
            var segment:uint = pointer.segment;
            var fraction:Number = pointer.segmentFraction;
            var resultDistance:Number = pointer.distance;
            while(true)
            {
                var nextSegment:uint = segment + 1;
                if(nextSegment == pointCount)
                {
                    current = null;
                    resultDistance = NaN;
                    fraction = NaN;
                    break;
                }
                
                var next:Point = points[nextSegment];
                var nextDistance:Number = Math.sqrt(
                    (current.x - next.x) * (current.x - next.x) +
                    (current.y - next.y) * (current.y - next.y));
                if(remainingDistance == nextDistance)
                {
                    current = next;
                    segment = nextSegment;
                    resultDistance += distance;
                    fraction = 0;
                    break;
                }
                else if(remainingDistance < nextDistance)
                {
                    var moveFraction:Number = remainingDistance / nextDistance;
                    fraction += (1 - fraction) * moveFraction;
                    current = new Point(
                        current.x + (next.x - current.x) * moveFraction,
                        current.y + (next.y - current.y) * moveFraction);
                    resultDistance += distance;
                    break;
                }
                else
                {
                    remainingDistance -= nextDistance;
                    current = next;
                    segment = nextSegment;
                    fraction = 0;
                }
            }
            
            return new RiderPointer(current, segment, fraction, resultDistance);
        }
        
        private function back(distance:Number):RiderPointer
        {
            var remainingDistance:Number = distance;
            var current:Point = pointer.point;
            var segment:uint = pointer.segment;
            var fraction:Number = pointer.segmentFraction;
            var resultDistance:Number = pointer.distance;
            while(true)
            {
                var next:Point = points[segment];
                var nextDistance:Number = Math.sqrt(
                    (current.x - next.x) * (current.x - next.x) +
                    (current.y - next.y) * (current.y - next.y));
                if(remainingDistance == nextDistance)
                {
                    current = next;
                    fraction = 0;
                    resultDistance -= distance;
                    break;
                }
                else if(remainingDistance < nextDistance)
                {
                    var moveFraction:Number = remainingDistance / nextDistance;
                    fraction -= moveFraction * fraction;
                    current = new Point(
                        current.x + (next.x - current.x) * moveFraction,
                        current.y + (next.y - current.y) * moveFraction);
                    resultDistance -= distance;
                    break;
                }
                else if(segment == 0)
                {
                    current = null;
                    segment = 0;
                    resultDistance = NaN;
                    fraction = NaN;
                    break;
                }
                else
                {
                    remainingDistance -= nextDistance;
                    current = next;
                    segment--;
                    fraction = 1;
                }
            }
            
            return new RiderPointer(current, segment, fraction, resultDistance);
        }
        
        public static function calculateLength(points:Vector.<Point>):Number
        {
            var result:Number = 0;
            var p0:Point = points[0];
            for(var i:uint = 1, length:uint = points.length; i < length; i++)
            {
                var p1:Point = points[i];
                result += Math.sqrt(
                    (p0.x - p1.x) * (p0.x - p1.x) +
                    (p0.y - p1.y) * (p0.y - p1.y));
                p0 = p1;
            }
            return result;
        }
    }
}