package sk.yoz.geom
{
    public class Triangle
    {
        public var z:int;
        
        public var next:Triangle;
        public var sort:Triangle;
        
        protected var indice1:int;
        protected var indice2:int;
        protected var indice3:int;
        
        protected var verticePosition1:uint;
        protected var verticePosition2:uint;
        protected var verticePosition3:uint;
        
        public function Triangle(indices:Vector.<int>, i:uint, 
                                 vertices:Vector.<Number>)
        {
            indice1 = indices[i];
            indice2 = indices[int(i + 1)];
            indice3 = indices[int(i + 2)];
            
            verticePosition1 = indice1 * 3 + 2;
            verticePosition2 = indice2 * 3 + 2;
            verticePosition3 = indice3 * 3 + 2;
            
            this.vertices = vertices;
        }
        
        public static function create(indices:Vector.<int>, 
                                      vertices:Vector.<Number>):Triangle
        {
            var f:Triangle = new Triangle(indices, 0, vertices);
            var c:Triangle = f;
            var length:uint = indices.length;
            for(var i:uint = 3; i < length; i += 3)
            {
                c.next = new Triangle(indices, i, vertices);
                c = c.next;
            }
            return f;
        }
        
        public function set vertices(value:Vector.<Number>):void
        {
            var c:Triangle = this;
            while(c)
            {
                var z1:Number = value[c.verticePosition1];
                var z2:Number = value[c.verticePosition2];
                var z3:Number = value[c.verticePosition3];
                
                // radix sort is int based
                c.z = int(-Math.max(z1, z2, z3));
                c = c.next;
            }
        }
        
        public function get zSort():Vector.<int>
        {
            var q0:Vector.<Triangle> = new Vector.<Triangle>(256, true);
            var q1:Vector.<Triangle> = new Vector.<Triangle>(256, true);
            var i:int = 0;
            var k:int;
            var f:Triangle = this;
            var p:Triangle, c:Triangle;
            var list:Vector.<int> = new Vector.<int>();
            
            c = f;
            while (c) {
                c.sort = q0[k = (255 & c.z)];
                q0[k] = c;
                c = c.next;
            }
            
            i = 256;
            while (i--) {
                c = q0[i];
                while (c) {
                    p = c.sort;
                    c.sort = q1[k = (65280 & c.z) >> 8];
                    q1[k] = c;
                    c = p;
                }
            }
            
            i = 0;
            while (i < 256) {
                c = q1[int(i++)];
                while (c) {
                    list.push(c.indice1, c.indice2, c.indice3);
                    c = c.sort;
                }
            }
            
            return list;
        }
    }
}