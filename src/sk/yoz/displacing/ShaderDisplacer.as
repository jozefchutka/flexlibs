package sk.yoz.displacing
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Shader;
    import flash.filters.ShaderFilter;
    
    public class ShaderDisplacer extends AbstractDisplacer
    {
        protected var imageBitmap:Bitmap;
        protected var shader:Shader;
        protected var filter:ShaderFilter;
        
        public function ShaderDisplacer(image:BitmapData, map:BitmapData, 
            rotationXMax:Number=10, rotationYMax:Number=10, 
            rotationXMultiplier:Number=1, rotationYMultiplier:Number=1)
        {
            super(image, map, rotationXMax, rotationYMax, 
                rotationXMultiplier, rotationYMultiplier);
            
            imageBitmap = new Bitmap(image);
            imageBitmap.x = -image.width / 2;
            imageBitmap.y = -image.height / 2;
            addChild(imageBitmap);
        }
        
        override public function set rotX(value:Number):void
        {
            super.rotX = value;
            rotationX = value;
            shader.data.dy.value = [-value * rotationYMultiplier];
        }
        
        override public function set rotY(value:Number):void
        {
            super.rotY = value;
            rotationY = value;
            shader.data.dx.value = [value * rotationXMultiplier];
        }
        
        override public function render():void
        {
            super.render();
            filters = [filter];
        }
    }
}