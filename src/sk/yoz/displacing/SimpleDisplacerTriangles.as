package sk.yoz.displacing
{
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.geom.Matrix3D;
    import flash.geom.PerspectiveProjection;
    import flash.geom.Utils3D;
    import flash.geom.Vector3D;
    
    import sk.yoz.geom.Triangle;
    
    public class SimpleDisplacerTriangles extends AbstractDisplacer
    {
        public var depth:Number = 100;
        public var segmentsW:uint = 15;
        public var segmentsH:uint = 15;
        
        protected var matrix3D:Matrix3D = new Matrix3D();
        protected var projection:PerspectiveProjection = new PerspectiveProjection();
        protected var uvtData:Vector.<Number>;
        protected var vertices:Vector.<Number>;
        protected var projected:Vector.<Number>;
        
        protected var container:Shape = new Shape();
        
        private var _indices:Vector.<int>;
        private var indicesCache:Object = {};
        private var firstTriangle:Triangle;
        private var matrixUpdateRequired:Boolean = true;
        
        public function SimpleDisplacerTriangles(
            viewportWidth:Number, viewportHeight:Number,
            image:BitmapData, map:BitmapData, 
            rotationXMax:Number = 30, rotationYMax:Number = 30,
            depth:Number = 100, segmentsW:uint = 15, segmentsH:uint = 15):void
        {
            super(image, map, rotationXMax, rotationYMax, 0, 0);
            
            projection.fieldOfView = 60;
            
            update(depth, segmentsW, segmentsH);
            
            container.x = viewportWidth / 2;
            container.y = viewportHeight / 2;
            addChild(container);
        }
        
        override public function set rotX(value:Number):void
        {
            super.rotX = value;
            matrixUpdateRequired = true;
        }
        
        override public function set rotY(value:Number):void
        {
            super.rotY = value;
            matrixUpdateRequired = true;
        }
        
        override public function render():void
        {
            super.render();
            
            if(matrixUpdateRequired)
                updateMatrix(matrix3D, rotX, rotY);
            matrixUpdateRequired = false;
            
            Utils3D.projectVectors(matrix3D, vertices, projected, uvtData);
            container.graphics.clear();
            container.graphics.beginBitmapFill(image, null, false, true);
            container.graphics.drawTriangles(projected, indices, uvtData);
        }
        
        protected function normalizeRotation(rotation:Number):Number
        {
            var abs:Number = Math.abs(rotation);
            if(abs < 5)
                return 0;
            if(abs < 20)
                return rotation > 0 ? 10 : -10;
            if(abs < 60)
                return rotation > 0 ? 30 : -30;
            return rotation > 0 ? 90 : -90;
        }
        
        protected function get indices():Vector.<int>
        {
            var rx:int = normalizeRotation(rotX);
            var ry:int = normalizeRotation(rotY);
            
            if(!indicesCache.hasOwnProperty(rx))
                indicesCache[rx] = {};
            if(!indicesCache[rx].hasOwnProperty(ry))
                indicesCache[rx][ry] = zSort(rx, ry);
            return indicesCache[rx][ry];
        }
        
        public function update(depth:Number, segmentsW:uint, segmentsH:uint):void
        {
            this.depth = depth || this.depth;
            this.segmentsW = segmentsW || this.segmentsW;
            this.segmentsH = segmentsH || this.segmentsH;
            
            generateModel();
            updateMatrix(matrix3D, rotX, rotY);
            indicesCache = {};
        }
        
        protected function generateModel():void
        {
            vertices = new Vector.<Number>();
            uvtData = new Vector.<Number>();
            projected = new Vector.<Number>();
            
            var color:uint, x:uint, y:uint;
            var sizeW:Number = (image.width - 1) / segmentsW;
            var sizeH:Number = (image.height - 1) / segmentsH;
            var w:Number = image.width / 2;
            var h:Number = image.height / 2;
            var d:Number = 1 / 0xff * depth;
            for(y = 0; y <= segmentsH; y++)
            for(x = 0; x <= segmentsW; x++)
            {
                color = map.getPixel(x * sizeW, y * sizeH);
                vertices.push(x * sizeW - w, y * sizeH - h, -(color >> 16) * d);
                uvtData.push(x / segmentsW, y / segmentsH, 0);
            }
            
            var verticesW:uint = segmentsW + 1;
            _indices = new Vector.<int>();
            for(x = 0; x < segmentsW; x++)
            for(y = 0; y < segmentsH; y++)
            {
                var yvW:uint = y * verticesW;
                var y1vW:uint = (y + 1) * verticesW;
                _indices.push(
                    x + yvW, x + yvW + 1, x + y1vW, 
                    x + yvW + 1, x + y1vW + 1, x + y1vW);
            }
        }
        
        private function updateMatrix(matrix3D:Matrix3D, 
            rotX:Number, rotY:Number):void
        {
            matrix3D.identity();
            matrix3D.appendRotation(-rotX, Vector3D.X_AXIS);
            matrix3D.appendRotation(rotY, Vector3D.Y_AXIS);
            matrix3D.appendTranslation(0, 0, 550);
            matrix3D.append(projection.toMatrix3D());
        }
        
        private function zSort(rotX:Number, rotY:Number):Vector.<int>
        {
            var projected:Vector.<Number> = new Vector.<Number>();
            var matrix3D:Matrix3D = new Matrix3D();
            updateMatrix(matrix3D, rotX, rotY);
            matrix3D.transformVectors(vertices, projected);
            
            if(!firstTriangle)
                firstTriangle = Triangle.create(_indices, projected);
            else
                firstTriangle.vertices = projected;
            return firstTriangle.zSort;
        }
    }
}