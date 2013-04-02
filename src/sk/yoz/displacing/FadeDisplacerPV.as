package sk.yoz.displacing
{
    import flash.display.BitmapData;
    import flash.display.Shader;
    import flash.display.ShaderJob;
    import flash.utils.ByteArray;
    
    import org.papervision3d.materials.BitmapMaterial;
    
    import sk.yoz.displacing.SimpleDisplacerPV;
    
    public class FadeDisplacerPV extends SimpleDisplacerPV
    {
        [Embed("FadeDisplacer.pbj", mimeType="application/octet-stream")]
        public static const SHADER_CLASS:Class;
        
        public var fade:BitmapData;
        public var fadeNear:Number = 0;
        public var fadeDistant:Number = 1;
        
        public function FadeDisplacerPV(
            viewportWidth:Number, viewportHeight:Number,
            image:BitmapData, map:BitmapData, fade:BitmapData,
            rotationXMax:Number = 10, rotationYMax:Number = 10,
            depth:Number = 10, segmentsW:uint = 20, segmentsH:uint = 20,
            fadeNear:Number = 0, fadeDistant:Number = 1)
        {
            this.fade = fade;
            this.fadeNear = fadeNear;
            this.fadeDistant = fadeDistant;
            
            super(viewportWidth, viewportHeight, image, map, 
                rotationXMax, rotationYMax, depth, segmentsW, segmentsH);
        }
        
        override protected function get material():BitmapMaterial
        {
            var w:uint = image.width;
            var h:uint = image.height;
            var bitmapData:BitmapData = new BitmapData(w, h, true);
            
            var shader:Shader = new Shader(new SHADER_CLASS() as ByteArray);
            shader.data.src.input = image;
            shader.data.map.input = map;
            shader.data.fader.input = fade;
            shader.data.dy.value = [0];
            shader.data.dx.value = [0];
            shader.data.fadeNear.value = [fadeNear];
            shader.data.fadeDistant.value = [fadeDistant];
            
            var job:ShaderJob = new ShaderJob(shader, bitmapData, w, h);
            job.start(false);
            
            var material:BitmapMaterial = new BitmapMaterial(bitmapData, false);
            material.oneSide = true;
            material.smooth = true;
            return material;
        }
    }
}