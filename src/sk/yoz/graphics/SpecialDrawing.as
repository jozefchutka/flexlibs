package sk.yoz.graphics
{
    import flash.display.Graphics;
    
    public class SpecialDrawing extends Object
    {
        public function SpecialDrawing()
        {
            super();
        }
        
        public static function wedge(
            graphics:Graphics, centerX:Number, centerY:Number, 
            radius:Number, startAngle:Number, endAngle:Number):void
        {
            var degToRad:Number = Math.PI / 180;
            if (endAngle < startAngle) 
                endAngle += 360;
            
            var r:Number = radius;
            var n:Number = Math.ceil((endAngle - startAngle) / 45);
            var theta:Number = ((endAngle - startAngle) / n) * degToRad;
            var cr:Number = radius / Math.cos(theta / 2);
            var angle:Number = startAngle * degToRad;
            var cangle:Number = angle - theta / 2;
            
            graphics.moveTo(centerX, centerY);
            graphics.lineTo(centerX + r * Math.cos(angle), 
                centerY + r * Math.sin(angle));
            for (var i:uint = 0; i < n; i++) 
            {
                angle += theta;
                cangle += theta;
                var endX:Number = r * Math.cos(angle);
                var endY:Number = r * Math.sin(angle);
                var cX:Number = cr * Math.cos(cangle);
                var cY:Number = cr * Math.sin(cangle);
                graphics.curveTo(centerX + cX, centerY + cY, centerX + endX, 
                    centerY + endY);
            }
            
            graphics.lineTo(centerX, centerY);
        }
    }
}