package sk.yoz.displacing
{
    
    import alternativa.engine3d.containers.DistanceSortContainer;
    import alternativa.engine3d.core.Camera3D;
    import alternativa.engine3d.core.Vertex;
    import alternativa.engine3d.core.View;
    import alternativa.engine3d.materials.TextureMaterial;
    import alternativa.engine3d.primitives.Plane;
    
    import flash.display.BitmapData;
    
    public class SimpleDisplacerAL extends AbstractDisplacer
    {
        public var viewport:View;
        public var camera:Camera3D;
        public var scene:DistanceSortContainer;
        
        public var viewportWidth:Number;
        public var viewportHeight:Number;
        
        public var plane:Plane;
        public var depth:Number = 100;
        public var segmentsW:uint = 15;
        public var segmentsH:uint = 15;
        
        public function SimpleDisplacerAL(
            viewportWidth:Number, viewportHeight:Number,
            image:BitmapData, map:BitmapData, 
            rotationXMax:Number = 30, rotationYMax:Number = 30,
            depth:Number = 100, segmentsW:uint = 15, segmentsH:uint = 15):void
        {
            super(image, map, rotationXMax, rotationYMax, 0, 0);
            
            this.viewportWidth = viewportWidth;
            this.viewportHeight = viewportHeight;
            this.depth = depth || this.depth;
            this.segmentsW = segmentsW || this.segmentsW;
            this.segmentsH = segmentsH || this.segmentsH;
            
            viewport = new View(viewportWidth, viewportHeight);
            addChild(viewport);
            
            camera = new Camera3D();
            camera.z = -1000;
            camera.fov = 1;
            camera.view = viewport;
            
            plane = new Plane(image.width, image.height,
                this.segmentsW, this.segmentsH, false, false, true, null, material);
            
            var length:uint = plane.vertices.length;
            var vertex:Vertex;
            var color:uint;
            var w:Number = (image.width - 1) / 2;
            var h:Number = (image.height - 1) / 2;
            for(var i:uint = 0; i < length; i++)
            {
                vertex = plane.vertices[i];
                color = map.getPixel(w + vertex.x, h - vertex.y);
                vertex.z = (color >> 16) / 0xff * this.depth;
            }
            
            scene = new DistanceSortContainer();
            scene.addChild(camera);
            scene.addChild(plane);
        }
        
        protected function get material():TextureMaterial
        {
            var material:TextureMaterial = new TextureMaterial(image);
            material.smooth = true;
            return material;
        }
        
        override public function set rotX(value:Number):void
        {
            super.rotX = value;
            plane.rotationX = -value / 180 * Math.PI + Math.PI;
        }
        
        override public function set rotY(value:Number):void
        {
            super.rotY = value;
            plane.rotationY = value / 180 * Math.PI;
        }
        
        override public function render():void
        {
            super.render();
            camera.render();
        }
    }
}