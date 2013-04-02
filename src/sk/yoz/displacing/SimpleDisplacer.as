package sk.yoz.displacing
{
    import flash.display.BitmapData;
    import flash.display.Shader;
    import flash.filters.ShaderFilter;
    import flash.utils.ByteArray;
    
    public class SimpleDisplacer extends ShaderDisplacer
    {
        [Embed("SimpleDisplacer.pbj", mimeType="application/octet-stream")]
        public static const SHADER_CLASS:Class;
        
        public function SimpleDisplacer(image:BitmapData, map:BitmapData, 
            rotationXMax:Number = 10, rotationYMax:Number = 10,
            rotationXMultiplier:Number = 1, rotationYMultiplier:Number = 1):void
        {
            super(image, map, rotationXMax, rotationYMax, rotationXMultiplier, 
                rotationYMultiplier);
            
            shader = new Shader(new SHADER_CLASS() as ByteArray);
            shader.data.map.input = map;
            
            filter = new ShaderFilter(shader);
        }
    }
}