package sk.yoz.displacing
{
    import away3d.cameras.Camera3D;
    import away3d.containers.Scene3D;
    import away3d.containers.View3D;
    import away3d.core.render.DefaultRenderer;
    import away3d.materials.BitmapMaterial;
    import away3d.primitives.Plane;
    
    import flash.display.BitmapData;
    
    public class SimpleDisplacerAWMH extends AbstractDisplacer
    {
        public var viewport:View3D;
        public var scene:Scene3D;
        public var camera:Camera3D;
        public var renderer:DefaultRenderer;
        
        public var viewportWidth:Number;
        public var viewportHeight:Number;
        
        public var plane:Plane;
        public var depth:Number = 100;
        public var segmentsW:uint = 15;
        public var segmentsH:uint = 15;
        
        public function SimpleDisplacerAWMH(
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
            
            scene = new Scene3D();
            
            camera = new Camera3D();
            camera.z = -1000;
            
            renderer = new DefaultRenderer();
            
            viewport = new View3D(scene, camera, renderer);
            viewport.x = 0;
            viewport.y = 0;
            viewport.backgroundColor = 0xffffff;
            addChild(viewport);
            
            plane = new Plane(material, image.width, image.height,
                this.segmentsW, this.segmentsH, false);
            
            var length:uint = plane.geometry.subGeometries[0].vertexData.length;
            var x:Number, y:Number;
            var color:uint;
            var w:Number = (image.width - 1) / 2;
            var h:Number = (image.height - 1) / 2;
            for(var i:uint = 0; i < length; i+=3)
            {
                x = plane.geometry.subGeometries[0].vertexData[i];
                y = plane.geometry.subGeometries[0].vertexData[i+2];
                color = map.getPixel(w + x, h - y);
                plane.geometry.subGeometries[0].vertexData[i+1] = (color >> 16) / 0xff * this.depth;
            }
            
            scene.addChild(plane);
        }
        
        protected function get material():BitmapMaterial
        {
            var material:BitmapMaterial = new BitmapMaterial(image);
            material.smooth = true;
            return material;
        }
        
        override public function set rotX(value:Number):void
        {
            super.rotX = value;
            plane.rotationX = -value + 90;
        }
        
        override public function set rotY(value:Number):void
        {
            super.rotY = value;
            plane.rotationY = value;
        }
        
        override public function render():void
        {
            super.render();
            viewport.render();
        }
        
        override public function destroy():void
        {
            super.destroy();
            scene.removeChild(plane);
            BitmapMaterial(plane.material).bitmapData.dispose();
            plane.geometry.subGeometries[0].dispose();
            plane.material = null;
            plane.dispose(true);
        }
    }
}