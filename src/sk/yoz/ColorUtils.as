package sk.yoz
{
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.geom.Matrix;
    
    public class ColorUtils extends Object
    {
        public static var color:uint;
        
        public function ColorUtils()
        {
            super();
        }
        
        public static function eyedropper(obj:DisplayObject, x:int, y:int):uint
        {
            var bmd:BitmapData = new BitmapData(1, 1, false);
            var matrix:Matrix = new Matrix();
            matrix.tx = -x;
            matrix.ty = -y;
            bmd.draw(obj, matrix);
            color = bmd.getPixel(0, 0);
            return color;
        }
        
        public static function toHex(value:uint):String
        {
            var s:String = String("00000" + value.toString(16)).substr(-6);
            return s.toUpperCase();
        }
    }
}