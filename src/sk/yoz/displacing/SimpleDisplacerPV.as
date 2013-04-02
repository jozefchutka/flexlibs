package sk.yoz.displacing
{
    import flash.display.BitmapData;
    
    import org.papervision3d.cameras.Camera3D;
    import org.papervision3d.core.geom.renderables.Vertex3D;
    import org.papervision3d.materials.BitmapMaterial;
    import org.papervision3d.objects.primitives.Plane;
    import org.papervision3d.render.BasicRenderEngine;
    import org.papervision3d.scenes.Scene3D;
    import org.papervision3d.view.Viewport3D;
    
    public class SimpleDisplacerPV extends AbstractDisplacer
    {
        public var viewport:Viewport3D;
        public var scene:Scene3D = new Scene3D();
        public var camera:Camera3D = new Camera3D();
        public var renderer:BasicRenderEngine = new BasicRenderEngine();
        
        public var plane:Plane;
        public var depth:Number = 100;
        public var segmentsW:uint = 15;
        public var segmentsH:uint = 15;
        
        public function SimpleDisplacerPV(
            viewportWidth:Number, viewportHeight:Number,
            image:BitmapData, map:BitmapData, 
            rotationXMax:Number = 30, rotationYMax:Number = 30,
            depth:Number = 100, segmentsW:uint = 15, segmentsH:uint = 15):void
        {
            super(image, map, rotationXMax, rotationYMax, 0, 0);
            
            this.depth = depth || this.depth;
            this.segmentsW = segmentsW || this.segmentsW;
            this.segmentsH = segmentsH || this.segmentsH;
            
            viewport = new Viewport3D(viewportWidth, viewportHeight, false, 
                false, false);
            addChild(viewport);
            
            camera.zoom = 120;
            
            plane = new Plane(material, image.width, image.height, 
                this.segmentsW, this.segmentsH);
            
            var length:uint = plane.geometry.vertices.length;
            var vertex:Vertex3D;
            var color:uint;
            var w:Number = (image.width - 1) / 2;
            var h:Number = (image.height - 1) / 2;
            for(var i:uint = 0; i < length; i++)
            {
                vertex = plane.geometry.vertices[i];
                color = map.getPixel(w + vertex.x, h - vertex.y);
                vertex.z = -(color >> 16) / 0xff * this.depth;
            }
            
            scene.addChild(plane);
        }
        
        protected function get material():BitmapMaterial
        {
            var material:BitmapMaterial = new BitmapMaterial(image, false);
            material.oneSide = true;
            material.smooth = true;
            return material;
        }
        
        override public function set rotX(value:Number):void
        {
            super.rotX = value;
            plane.rotationX = value;
        }
        
        override public function set rotY(value:Number):void
        {
            super.rotY = value;
            plane.rotationY = value;
        }
        
        override public function render():void
        {
            super.render();
            renderer.renderScene(scene, camera, viewport);
        }
    }
}