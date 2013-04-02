package sk.yoz.graphics
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    
    import sk.yoz.events.ColorCircleEvent;
    
    public class ColorCircle extends Sprite
    {
        protected var _radius:Number = 0;
        protected var _color:uint = 0;
        protected var bitmap:Bitmap = new Bitmap();
        
        protected var currentColor:Sprite;
        protected var currentColorInnerRadius:Number;
        protected var currentColorOuterRadius:Number;
        
        public function ColorCircle(radius:Number, color:uint=0):void
        {
            super();
            
            _radius = radius;
            this.color = color;
            
            bitmap.bitmapData = new BitmapData(radius * 2, radius * 2, true, 0);
            addChild(bitmap);
            
            var mask:Shape = new Shape();
            mask.graphics.beginFill(0, 1);
            mask.graphics.drawCircle(radius, radius, radius);
            addChild(mask);
            this.mask = mask;
            
            addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            addEventListener(MouseEvent.ROLL_OUT, onRollOut);
        }
        
        public function get radius():Number
        {
            return _radius;
        }
        
        public function set color(value:uint):void
        {
            _color = value;
            updateCurrentColor(value);
        }
        
        public function get color():uint
        {
            return _color;
        }
        
        protected function updateCurrentColor(color:uint):void
        {
            if(!currentColor)
                return;
            drawCurrentColor(
                currentColorOuterRadius, currentColorInnerRadius, color);
        }
        
        protected function onMouseMove(event:MouseEvent):void
        {
            event.updateAfterEvent();
            var color:uint = event.target == currentColor 
                ? this.color : bitmap.bitmapData.getPixel(mouseX, mouseY);
            updateCurrentColor(color);
            
            var type:String = ColorCircleEvent.COLOR_OVER;
            dispatchEvent(new ColorCircleEvent(type, false, false, color));
        }
        
        protected function onMouseDown(event:MouseEvent):void
        {
            var color:uint = event.target == currentColor 
                ? this.color : bitmap.bitmapData.getPixel(mouseX, mouseY);
            this.color = color;
            
            var type:String = ColorCircleEvent.COLOR_SELECTED;
            dispatchEvent(new ColorCircleEvent(type, false, false, color));
        }
        
        protected function onRollOut(event:MouseEvent):void
        {
            updateCurrentColor(color);
        }
        
        protected function drawDonut(innerRadius:Number, outerRadius:Number, 
            bitmapData:BitmapData):void
        {
            var donut:Shape = new Shape();
            donut.graphics.lineStyle(outerRadius - innerRadius, 0, 1);
            donut.graphics.drawCircle(outerRadius, outerRadius, 
                (outerRadius + innerRadius) / 2);
            donut.cacheAsBitmap = true;
            bitmapData.draw(donut, null, null, BlendMode.ALPHA);
            
            var matrix:Matrix = new Matrix();
            matrix.translate(radius - outerRadius, radius - outerRadius);
            
            bitmap.bitmapData.draw(bitmapData, matrix);
        }
        
        public function drawRGBPalette(outerRadius:Number, innerRadius:Number):void
        {
            var color:uint, distance:Number, dx:Number, dy:Number;
            var r2:Number = outerRadius * 2;
            var radiusDif2:Number = (outerRadius - innerRadius) / 2;
            var middleRadius:Number = innerRadius + radiusDif2;
            var bitmapData:BitmapData = new BitmapData(r2, r2, true, 0);
            var light:Number, dark:Number;
            bitmapData.lock();
            for(var x:uint = 0; x < r2; x++)
            for(var y:uint = 0; y < r2; y++)
            {
                dx = outerRadius - x;
                dy = outerRadius - y;
                distance = Math.sqrt(dx * dx + dy * dy);
                if(distance > outerRadius + 2 || distance < innerRadius - 2)
                    continue;
                
                light = dark = 0;
                if(distance > middleRadius)
                    light = (distance - middleRadius) / radiusDif2;
                else
                    dark = (middleRadius - distance) / radiusDif2;
                light = light > 1 ? 1 : light;
                dark = dark > 1 ? 1 : dark;
                color = paletteColor(Math.atan2(dy, dx) / Math.PI / 2 + .5,
                    light, dark * dark * dark * dark);
                
                bitmapData.setPixel32(x, y, color + 0xff000000);
            }
            
            bitmapData.unlock();
            drawDonut(innerRadius, outerRadius, bitmapData);
            bitmapData.dispose();
        }
        
        public function drawBWPalette(outerRadius:Number, innerRadius:Number):void
        {
            var color:uint, amount:Number, distance:Number, dx:Number, dy:Number;
            var r2:Number = outerRadius * 2;
            var bitmapData:BitmapData = new BitmapData(r2, r2, true, 0);
            bitmapData.lock();
            for(var x:uint = 0; x < r2; x++)
            for(var y:uint = 0; y < r2; y++)
            {
                dx = outerRadius - x;
                dy = outerRadius - y;
                distance = Math.sqrt(dx * dx + dy * dy);
                if(distance > outerRadius + 2 || distance < innerRadius - 2)
                    continue;
                
                amount = (Math.atan2(dy, dx) / Math.PI / 2 + .5) * 0xff;
                color = amount << 16 | amount << 8 | amount;
                
                bitmapData.setPixel32(x, y, color + 0xff000000);
            }
            bitmapData.unlock();
            drawDonut(innerRadius, outerRadius, bitmapData);
            bitmapData.dispose();
        }
        
        public function drawSolid(outerRadius:Number, innerRadius:Number, 
            color:uint):void
        {
            var r2:Number = outerRadius * 2;
            var bitmapData:BitmapData = new BitmapData(r2, r2, true, 0);
            var shape:Shape = new Shape();
            shape.graphics.beginFill(color, 1);
            shape.graphics.drawCircle(outerRadius, outerRadius, outerRadius);
            shape.graphics.endFill();
            
            bitmapData.draw(shape);
            drawDonut(innerRadius, outerRadius, bitmapData);
            bitmapData.dispose();
        }
        
        public function drawCurrentColor(outerRadius:Number, innerRadius:Number,
            color:int = -1):void
        {
            if(!outerRadius)
                return;
            currentColorOuterRadius = outerRadius;
            currentColorInnerRadius = innerRadius;
            
            if(!currentColor)
            {
                currentColor = new Sprite();
                addChild(currentColor);
            }
            
            color = color == -1 ? this.color : color;
            var radius:Number = (outerRadius + innerRadius) / 2;
            
            currentColor.graphics.clear();
            currentColor.graphics.lineStyle(outerRadius - innerRadius, color, 1);
            currentColor.graphics.drawCircle(this.radius, this.radius, radius);
            currentColor.graphics.endFill();
        }
        
        public static function paletteColor(position:Number, light:Number=0, 
            dark:Number=0):uint
        {
            var r:Number = Math.abs(.5 - position) * 6 - 1;
            r = r > 1 ? 1 : r < 0 ? 0 : r;
            r = (r + (1 - r) * light) * (1 - dark);
            
            var g:Number = (1 - Math.abs(1/3 - position)) * 6 - 4;
            g = g > 1 ? 1 : g < 0 ? 0 : g;
            g = (g + (1 - g) * light) * (1 - dark);
            
            var b:Number = (1 - Math.abs(2/3 - position)) * 6 - 4;
            b = b > 1 ? 1 : b < 0 ? 0 : b;
            b = (b + (1 - b) * light) * (1 - dark);
            
            return (r * 0xff) << 16 | (g * 0xff) << 8 | (b * 0xff);
        }
    }
}