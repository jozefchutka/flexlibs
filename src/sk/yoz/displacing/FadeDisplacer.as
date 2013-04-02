package sk.yoz.displacing
{
    import flash.display.BitmapData;
    import flash.display.Shader;
    import flash.filters.ShaderFilter;
    import flash.utils.ByteArray;
    
    public class FadeDisplacer extends ShaderDisplacer
    {
        [Embed("FadeDisplacer.pbj", mimeType="application/octet-stream")]
        public static const SHADER_CLASS:Class;
        
        protected var fade:BitmapData;
        protected var fadeNear:Number = 0;
        protected var fadeDistant:Number = 1;
        
        public function FadeDisplacer(image:BitmapData, map:BitmapData, 
            fade:BitmapData, rotationXMax:Number = 10, rotationYMax:Number = 10,
            rotationXMultiplier:Number = 1, rotationYMultiplier:Number = 1,
            fadeNear:Number = 0, fadeDistant:Number = 1):void
        {
            super(image, map, rotationXMax, rotationYMax, rotationXMultiplier, 
                rotationYMultiplier);
            
            this.fade = fade;
            this.fadeNear = fadeNear;
            this.fadeDistant = fadeDistant;
            
            shader = new Shader(new SHADER_CLASS() as ByteArray);
            shader.data.map.input = map; 
            shader.data.fader.input = fade;
            shader.data.fadeNear.value = [fadeNear];
            shader.data.fadeDistant.value = [fadeDistant];
            
            filter = new ShaderFilter(shader);
        }
    }
}