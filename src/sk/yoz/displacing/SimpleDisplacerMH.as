package sk.yoz.displacing
{
    import com.adobe.utils.AGALMiniAssembler;
    import com.adobe.utils.PerspectiveMatrix3D;
    
    import flash.display.BitmapData;
    import flash.display.Stage3D;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.display3D.textures.Texture;
    import flash.events.Event;
    import flash.geom.Matrix3D;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    
    public class SimpleDisplacerMH
    {
        public var rotX:Number = 0;
        public var rotY:Number = 0;
        
        public var rotationXMax:Number;
        public var rotationYMax:Number;
        
        private var stage3D:Stage3D;
        private var viewportWidth:uint;
        private var viewportHeight:uint;
        private var image:BitmapData;
        private var map:BitmapData;
        private var depth:Number;
        private var segmentsW:uint;
        private var segmentsH:uint;
        
        private var indices:Vector.<uint>;
        private var textureSize:uint;
        private var bitmapData:BitmapData;
        private var indexBuffer:IndexBuffer3D;
        private var perspective:PerspectiveMatrix3D = new PerspectiveMatrix3D;
        
        public function SimpleDisplacerMH(stage3D:Stage3D,
            viewportWidth:uint, viewportHeight:uint, 
            image:BitmapData, map:BitmapData, 
            rotationXMax:Number=10, rotationYMax:Number=10, 
            depth:Number = 100, segmentsW:uint = 15, segmentsH:uint = 15)
        {
            this.stage3D = stage3D;
            this.viewportWidth = viewportWidth;
            this.viewportHeight = viewportHeight;
            this.image = image;
            this.textureSize = countTextureSize(image.width, image.height);
            this.map = map;
            this.rotationXMax = rotationXMax;
            this.rotationYMax = rotationYMax;
            this.segmentsW = segmentsW;
            this.segmentsH = segmentsH;
            this.depth = depth;
            this.bitmapData = createBitmapData();
            
            stage3D.addEventListener(Event.CONTEXT3D_CREATE, onCreate);
            stage3D.requestContext3D();
        }
        
        private function get context():Context3D
        {
            return stage3D.context3D;
        }
        
        private function countTextureSize(width:uint, height:uint):uint
        {
            var size:uint = 1;
            var max:uint = width > height ? width : height;
            while(size < max)
                size *= 2;
            return size;
        }
        
        private function createBitmapData():BitmapData
        {
            var bitmapData:BitmapData = new BitmapData(textureSize, textureSize);
            bitmapData.draw(image);
            return bitmapData;
        }
        
        private function createVertices():Vector.<Number>
        {
            var vertices:Vector.<Number> = new Vector.<Number>(
                (segmentsW + 1) * (segmentsH + 1) * 5, true);
            var color:uint, x:uint, y:uint, xs:Number, ys:Number, xyi:uint;
            var sizeW:Number = (image.width - 1) / segmentsW;
            var sizeH:Number = (image.height - 1) / segmentsH;
            var w:Number = image.width / 2;
            var h:Number = image.height / 2;
            var d:Number = 1 / 0xff * depth;
            var i:uint = 0;
            var scaleW:Number = image.width / textureSize / segmentsW;
            var scaleH:Number = image.height / textureSize / segmentsH;
            var colors:Vector.<uint> = map.getVector(
                new Rectangle(0, 0, map.width, map.height));
            for(y = 0; y <= segmentsH; y++)
            for(x = 0; x <= segmentsW; x++)
            {
                xs = x * sizeW;
                ys = y * sizeH;
                xyi = xs + int(ys) * map.width;
                color = colors[xyi];
                vertices[i] = xs - w;               i++;     // x
                vertices[i] = ys - h;               i++;     // y
                vertices[i] = (color >> 16) * d;    i++;     // z
                vertices[i] = x * scaleW;           i++;     // u
                vertices[i] = y * scaleH;           i++;     // v
            }
            
            return vertices;
        }
        
        private function createIndices():Vector.<uint>
        {
            var x:uint, y:uint, yvW:uint, y1vW:uint;
            var verticesW:uint = segmentsW + 1;
            var indices:Vector.<uint> = new Vector.<uint>(
                segmentsW * segmentsH * 6, true);
            var i:uint = 0;
            for(x = 0; x < segmentsW; x++)
            for(y = 0; y < segmentsH; y++)
            {
                yvW = y * verticesW;
                y1vW = (y + 1) * verticesW;
                indices[i] = x + yvW;         i++;
                indices[i] = x + yvW + 1;     i++;
                indices[i] = x + y1vW;        i++;
                indices[i] = x + yvW + 1;     i++;
                indices[i] = x + y1vW + 1;    i++;
                indices[i] = x + y1vW;        i++;
            }
            
            return indices;
        }
        
        private function createProgram():Program3D
        {
            var vertexAssembler:AGALMiniAssembler = new AGALMiniAssembler;
            vertexAssembler.assemble(Context3DProgramType.VERTEX,
                "m44 op, va0, vc0 \n" +     // pos to clipspace
                "mov v0, va1");             // copy uv
            
            var fragmentAssembler:AGALMiniAssembler = new AGALMiniAssembler;
            fragmentAssembler.assemble(Context3DProgramType.FRAGMENT,
                "tex ft1, v0, fs0 <2d,linear,nomip> \n" + // sample texture
                "mov oc, ft1");     // copy sampled texture to output
            
            var program:Program3D = context.createProgram();
            program.upload(vertexAssembler.agalcode, fragmentAssembler.agalcode);
            return program;
        }
        
        public function onCreate(event:Event):void
        {
            var vertices:Vector.<Number> = createVertices();
            var vertexBuffer:VertexBuffer3D = context.createVertexBuffer(
                vertices.length / 5, 5);
            vertexBuffer.uploadFromVector(vertices, 0, vertices.length / 5);
            
            indices = createIndices();
            indexBuffer = context.createIndexBuffer(indices.length);
            indexBuffer.uploadFromVector(indices, 0, indices.length);
            
            var texture:Texture = context.createTexture(
                textureSize, textureSize, Context3DTextureFormat.BGRA, false);
            texture.uploadFromBitmapData(bitmapData);
            
            var program:Program3D = createProgram();
            var float3:String = Context3DVertexBufferFormat.FLOAT_3;
            var float2:String = Context3DVertexBufferFormat.FLOAT_2;
            
            context.configureBackBuffer(viewportWidth, viewportHeight, 4, true);
            context.setVertexBufferAt(0, vertexBuffer, 0, float3);  // x, y, z
            context.setVertexBufferAt(1, vertexBuffer, 3, float2);  // u, v
            context.setTextureAt(0, texture);
            context.setProgram(program);
            
            perspective.perspectiveFieldOfViewLH(45 * Math.PI / 180, 
                viewportWidth / viewportHeight, 0.1, 10000);
        }
        
        public function render():void
        {
            var z:Number = Math.max(image.width, image.height) * 1.2;
            var programType:String = Context3DProgramType.VERTEX;
            
            var matrix:Matrix3D = new Matrix3D;
            matrix.appendRotation(-rotY, Vector3D.Y_AXIS);
            matrix.appendRotation(rotX + 180, Vector3D.X_AXIS);
            matrix.appendTranslation(0, 0, z);
            matrix.append(perspective);
            
            context.clear(1, 1, 1, 1);
            context.setProgramConstantsFromMatrix(programType, 0, matrix, true);
            context.drawTriangles(indexBuffer, 0, indices.length / 3);
            context.present();
        }
        
        public function dispose():void
        {
            stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onCreate);
            context && context.dispose();
            map.dispose();
            image.dispose();
            bitmapData.dispose();
            indices = null;
        }
    }
}