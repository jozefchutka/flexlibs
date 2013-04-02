package sk.yoz.rider
{
    import flash.geom.Point;

    public class RiderPointer
    {
        public var point:Point;
        public var segment:uint;
        public var segmentFraction:Number;
        public var distance:Number;
        
        public function RiderPointer(point:Point, segment:uint, 
            segmentFraction:Number, distance:Number)
        {
            this.point = point;
            this.segment = segment;
            this.segmentFraction = segmentFraction;
            this.distance = distance;
            
        }
    }
}