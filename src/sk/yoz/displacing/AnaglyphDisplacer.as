package sk.yoz.displacing
{
    import flash.display.BitmapData;
    import flash.display.Shader;
    import flash.filters.ShaderFilter;
    import flash.utils.ByteArray;

    public class AnaglyphDisplacer extends ShaderDisplacer
    {
        [Embed("AnaglyphDisplacer.pbj", mimeType="application/octet-stream")]
        public static const SHADER_CLASS:Class;
        
        protected var maxDistanceX:Number = 10;
        protected var maxDistanceY:Number = 0;
        protected var zBase:Number = 0.5;
        
        protected var matrixLeft:Array = 
            [0.0, 0.0, 0.0, 0.7, 0.0, 0.0, 0.3, 0.0, 0.0];
        protected var matrixRight:Array = 
            [0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0];
        
        public function AnaglyphDisplacer(image:BitmapData, map:BitmapData, 
            rotationXMax:Number = 10, rotationYMax:Number = 10,
            rotationXMultiplier:Number = 1, rotationYMultiplier:Number = 1,
            maxDistanceX:Number = 10, maxDistanceY:Number = 0, zBase:Number = 0.5,
            matrixLeft:Array = null, matrixRight:Array = null)
        {
            super(image, map, rotationXMax, rotationYMax, rotationXMultiplier,
                rotationYMultiplier);
            
            this.maxDistanceX = maxDistanceX;
            this.maxDistanceY = maxDistanceY;
            this.zBase = zBase;
            this.matrixLeft = matrixLeft || this.matrixLeft;
            this.matrixRight = matrixRight || this.matrixRight;
            
            shader = new Shader(new SHADER_CLASS() as ByteArray);
            shader.data.srcWidth.value = [image.width];
            shader.data.srcHeight.value = [image.height];
            shader.data.map.input = map;
            shader.data.zBase.value = [zBase];
            shader.data.matrixLeft.value = this.matrixLeft
            shader.data.matrixRight.value = this.matrixRight;
            
            filter = new ShaderFilter(shader);
        }
        
        override public function set rotX(value:Number):void
        {
            super.rotX = value;
            shader.data.dy.value = [maxDistanceY];
        }
        
        override public function set rotY(value:Number):void
        {
            super.rotY = value;
            shader.data.dx.value = [maxDistanceX];
        }
    }
}