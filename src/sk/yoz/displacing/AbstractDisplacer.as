package sk.yoz.displacing
{
    import flash.display.BitmapData;
    import flash.display.Sprite;
    
    public class AbstractDisplacer extends Sprite
    {
        public var rotationXMax:Number = 10;
        public var rotationYMax:Number = 10;
        
        public var rotationXMultiplier:Number = 1;
        public var rotationYMultiplier:Number = 1;
        
        public var image:BitmapData;
        public var map:BitmapData;
        
        private var _rotX:Number = 0;
        private var _rotY:Number = 0;
        
        public function AbstractDisplacer(image:BitmapData, map:BitmapData, 
            rotationXMax:Number = 10, rotationYMax:Number = 10,
            rotationXMultiplier:Number = 1, rotationYMultiplier:Number = 1)
        {
            super();
            
            this.image = image;
            this.map = map;
            this.rotationXMax = Math.abs(rotationXMax) || this.rotationXMax;
            this.rotationYMax = Math.abs(rotationYMax) || this.rotationYMax;
            this.rotationXMultiplier = 
                Math.abs(rotationXMultiplier) || this.rotationXMultiplier;
            this.rotationYMultiplier = 
                Math.abs(rotationYMultiplier) || this.rotationYMultiplier;
        }
        
        public function get rotX():Number
        {
            return _rotX;
        }
        
        public function set rotX(value:Number):void
        {
            _rotX = value;
        }
        
        public function get rotY():Number
        {
            return _rotY;
        }
        
        public function set rotY(value:Number):void
        {
            _rotY = value;
        }
        
        public function render():void
        {
        }
        
        public function destroy():void
        {
            image.dispose();
            map.dispose();
        }
    }
}