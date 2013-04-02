package sk.yoz.image
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.geom.Point;
    
    import mx.controls.Image;
    
    import sk.yoz.math.ResizeMath;
    
    public class SmoothImage extends Image
    {
        protected var _resizeFunction:String = "bilinearIterative";
        protected var _iterationMultiplier:Number = 2;
        protected var resizedBitmap:Bitmap;
        
        public function SmoothImage()
        {
            super();
        }
        
        [Bindable(event="resizeFunctionChanged")]
        [Inspectable(category="Other", defaultValue="bilinearIterative", 
            enumeration="bilinear,bilinearIterative")]
        public function set resizeFunction(value:String):void
        {
            if(value == resizeFunction)
                return;
            _resizeFunction = value;
            resizeBitmap();
        }
        
        public function get resizeFunction():String
        {
            return _resizeFunction;
        }
        
        [Bindable(event="iterationMultiplierChanged")]
        public function set iterationMultiplier(value:Number):void
        {
            if(value == iterationMultiplier)
                return;
                
            _iterationMultiplier = value;
            resizeBitmap();
        }
        
        public function get iterationMultiplier():Number
        {
            return _iterationMultiplier;
        }
        
        override protected function updateDisplayList(unscaledWidth:Number, 
            unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            resizeBitmap();
        }
        
        protected function resizeBitmap(... rest):void
        {
            if(!width || !height || !content)
                return;
            
            if(resizedBitmap && resizedBitmap.parent)
                resizedBitmap.parent.removeChild(resizedBitmap);
            
            resizedBitmap = new Bitmap(resizedBitmapData);
            addChild(resizedBitmap);
            content.visible = false;
        }
        
        protected function get resizeMethod():String
        {
            return maintainAspectRatio ? ResizeMath.METHOD_LETTERBOX 
                : ResizeMath.METHOD_RAW;
        }
        
        protected function get resizedBitmapData():BitmapData
        {
            var bitmapData:BitmapData;
            
            if(content is Bitmap)
            {
                bitmapData = Bitmap(content).bitmapData
            }
            else
            {
                bitmapData = new BitmapData(content.width / content.scaleX, 
                    content.height / content.scaleY, true, 0);
                bitmapData.draw(content);
            }
            
            var dimensions:Point = ResizeMath.newDimensions(
                new Point(bitmapData.width, bitmapData.height), 
                new Point(width, height), resizeMethod, true);
                
            return ImageResizer[resizeFunction](bitmapData, dimensions.x, 
                dimensions.y, resizeMethod, true, iterationMultiplier);
        }
    }
}