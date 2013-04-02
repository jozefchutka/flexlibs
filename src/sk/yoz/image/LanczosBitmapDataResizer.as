package sk.yoz.image
{
    import flash.display.BitmapData;
    import flash.utils.Dictionary;
    
    public class LanczosBitmapDataResizer
    {
        public static var CACHE:Dictionary;
        public static var CACHE_PRECISION:uint = 100;
        public static var FILTER_SIZE:uint = 1;
        
        public function LanczosBitmapDataResizer()
        {
        }
        
        public static function kernel(filterSize:uint, x:Number):Number
        {
            if(x >= filterSize || x <= -filterSize)
                return 0;
            if(x == 0)
                return 1;
            
            var xpi:Number = x * Math.PI;
            return filterSize * Math.sin(xpi) * Math.sin(xpi / filterSize) 
                / (xpi * xpi);
        }
        
        public static function createCache(kernel:Function, 
            cachePrecision:uint, filterSize:uint):Dictionary
        {
            var cache:Dictionary = new Dictionary();
            var max:uint = filterSize * filterSize * cachePrecision;
            var iPrecision:Number = 1 / cachePrecision;
            var value:Number;
            for(var cacheKey:uint = 0; cacheKey < max; cacheKey++)
            {
                value = kernel(filterSize, Math.sqrt(cacheKey * iPrecision));
                cache[cacheKey] = value < 0 ? 0 : value;
            }
            return cache;
        }
        
        public static function resize(source:BitmapData, width:uint, 
            height:uint, kernel:Function=null):BitmapData
        {
            var total:Number, distanceY:Number, value:Number;
            var a:Number, r:Number, g:Number, b:Number;
            var i:uint, color:uint, cacheKey:uint;
            
            var x:int, x1:uint, x1b:int, x1e:int;
            var y:int, y1:uint, y1b:int, y1e:int, y2:uint, y3:uint;
            var y1et:Number, x1et:Number;
            
            var values:Vector.<Number> = new Vector.<Number>();
            var sx:Number = width / source.width;
            var sy:Number = height / source.height;
            var sw1:uint = source.width - 1;
            var sh1:uint = source.height - 1;
            var isx:Number = 1 / sx;
            var isy:Number = 1 / sy;
            var cw:Number = 1 / width;
            var ch:Number = 1 / height;
            var csx:Number = Math.min(1, sx) * Math.min(1, sx);
            var csy:Number = Math.min(1, sy) * Math.min(1, sy);
            var cx:Number, cy:Number;
            
            var sourcePixelX:Number, sourcePixelY:Number;
            var sourcePixels:Vector.<uint> = source.getVector(source.rect);
            var output:BitmapData = 
                new BitmapData(width, height, source.transparent);
            var outputPixels:Vector.<uint> = 
                new Vector.<uint>(width * height, true);
            
            var cache:Dictionary = CACHE;
            var cachePrecision:uint = CACHE_PRECISION;
            var filterSize:uint = FILTER_SIZE;
            var kernel:Function = kernel || public::kernel;
            if(!cache)
                CACHE = cache = createCache(kernel, cachePrecision, filterSize);
            
            y = height;
            while(y--)
            {
                sourcePixelY = (y + 0.5) * isy;
                y1b = sourcePixelY - filterSize;
                if(y1b < 0)
                    y1b = 0;
                y1e = y1et = sourcePixelY + filterSize;
                if(y1e != y1et)
                    y1e = y1et + 1;
                if(y1e > sh1)
                    y1e = sh1;
                cy = y * ch - sourcePixelY;
                y3 = y * width;
                
                x = width;
                while(x--)
                {
                    sourcePixelX = (x + 0.5) * isx;
                    x1b = sourcePixelX - filterSize;
                    if(x1b < 0)
                        x1b = 0;
                    x1e = x1et = sourcePixelX + filterSize;
                    if(x1e != x1et)
                        x1e = x1et + 1;
                    if(x1e > sw1)
                        x1e = sw1;
                    cx = x * cw - sourcePixelX;
                    
                    values.length = i = total = 0;
                    for(y1 = y1b; y1 <= y1e; y1++)
                    {
                        distanceY = (y1 + cy) * (y1 + cy) * csy;
                        for(x1 = x1b; x1 <= x1e; x1++)
                        {
                            total += values[uint(i++)] = cache[uint(
                                ((x1 + cx) * (x1 + cx) * csx + distanceY) 
                                * cachePrecision)]||0;
                        }
                    }
                    
                    total = 1 / total;
                    
                    i = a = r = g = b = 0;
                    for(y1 = y1b; y1 <= y1e; y1++)
                    {
                        y2 = y1 * source.width;
                        for(x1 = x1b; x1 <= x1e; x1++)
                        {
                            color = sourcePixels[uint(y2 + x1)];
                            value = values[uint(i++)] * total;
                            a += (color >> 24 & 0xff) * value;
                            r += (color >> 16 & 0xff) * value;
                            g += (color >> 8 & 0xff) * value;
                            b += (color & 0xff) * value;
                        }
                    }
                    outputPixels[uint(x + y3)] = a << 24 | r << 16 | g << 8 | b;
                }
            }
            
            output.setVector(output.rect, outputPixels);
            return output;
        }
    }
}