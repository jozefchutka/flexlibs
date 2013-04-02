package sk.yoz.transformation
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    public class SubjectTransformator extends Sprite
    {
        public static const POSITION_LT:uint = 0;
        public static const POSITION_RT:uint = 1;
        public static const POSITION_RB:uint = 2;
        public static const POSITION_LB:uint = 3;
        
        protected var _subject:DisplayObject;
        protected var _draggable:Boolean;
        
        protected var resizers:Object = {};
        protected var rotators:Object = {};
        
        protected var shape:Sprite;
        protected var shapeWidth:Number;
        protected var shapeHeight:Number;
        
        protected var lastMouse:Point;
        
        public function SubjectTransformator()
        {
            super();
        }
        
        public function get subject():DisplayObject
        {
            return _subject;
        }
        
        public function set subject(value:DisplayObject):void
        {
            if(value == _subject)
                return;
            _subject = value;
        }
        
        public function set draggable(value:Boolean):void
        {
            _draggable = value;
        }
        
        public function get draggable():Boolean
        {
            return _draggable;
        }
        
        public function addResizer(resizer:DisplayObject, position:uint):void
        {
            removeResizer(position);
            resizer.x = -resizer.width / 2;
            resizer.y = -resizer.height / 2;
            
            var wrapper:Sprite = new Sprite();
            wrapper.addChild(resizer);
            wrapper.rotation = position * 90;
            wrapper.addEventListener(MouseEvent.MOUSE_DOWN, resizerDown);
            resizers[position] = wrapper;
            addChild(wrapper);
        }
        
        public function removeResizer(position:uint):void
        {
            var wrapper:Sprite = resizers[position];
            if(!wrapper)
                return;
            if(wrapper.parent)
                wrapper.parent.removeChild(wrapper);
            wrapper.removeEventListener(MouseEvent.MOUSE_DOWN, resizerDown);
            delete resizers[position];
        }
        
        public function addRotator(rotator:DisplayObject, position:uint):void
        {
            removeRotator(position);
            rotator.x = -rotator.width / 2;
            rotator.y = -rotator.height / 2;
            
            var wrapper:Sprite = new Sprite();
            wrapper.addChild(rotator);
            wrapper.rotation = position * 90;
            wrapper.addEventListener(MouseEvent.MOUSE_DOWN, rotatorDown);
            rotators[position] = wrapper;
            addChild(wrapper);
        }
        
        public function removeRotator(position:uint):void
        {
            var wrapper:Sprite = rotators[position];
            if(!wrapper)
                return;
            if(wrapper.parent)
                wrapper.parent.removeChild(wrapper);
            wrapper.removeEventListener(MouseEvent.MOUSE_DOWN, rotatorDown);
            delete rotators[position];
        }
        
        public function subjectMatchTransformator():void
        {
            if(!subject)
                return;
            
            shape.width = shapeWidth;
            shape.height = shapeHeight;
            
            subject.rotation = 0;
            subject.width = shapeWidth;
            subject.height = shapeHeight;
            subject.rotation = rotation;
            
            var shapeRectangle:Rectangle = shape.getRect(parent);
            var objectRectangle:Rectangle = subject.getRect(parent);
            subject.x += shapeRectangle.x - objectRectangle.x;
            subject.y += shapeRectangle.y - objectRectangle.y;
            
            positionResizers(shapeWidth, shapeHeight);
            positionRotators(shapeWidth, shapeHeight);
        }
        
        public function transformatorMatchSubject():void
        {
            if(!subject)
                return;
            
            var r:Number = subject.rotation;
            subject.rotation = 0;
            var w:Number = subject.width;
            var h:Number = subject.height;
            subject.rotation = r;
            rotation = r;
            
            var objectRectangle:Rectangle = subject.getRect(parent);
            x = objectRectangle.x + objectRectangle.width / 2;
            y = objectRectangle.y + objectRectangle.height / 2;
            
            createShape(w, h);
            positionResizers(w, h);
            positionRotators(w, h);
        }
        
        protected function createShape(w:Number, h:Number):void
        {
            shapeWidth = w;
            shapeHeight = h;
            
            if(!shape)
            {
                shape = new Sprite();
                shape.addEventListener(MouseEvent.MOUSE_DOWN, shapeDown);
                addChildAt(shape, 0);
            }
            
            shape.graphics.clear();
            shape.graphics.beginFill(0, 0);
            shape.graphics.drawRect(-w / 2, -h / 2, w, h);
            shape.graphics.endFill();
            shape.width = w;
            shape.height = h;
        }
        
        protected function positionResizers(w:Number, h:Number):void
        {
            var wrapper:Sprite, key:String, position:uint;
            var isTop:Boolean, isLeft:Boolean;
            
            for(key in resizers)
            {
                position = uint(key);
                wrapper = resizers[position];
                isLeft = position == POSITION_LT || position == POSITION_LB;
                isTop = position == POSITION_LT || position == POSITION_RT;
                wrapper.x = isLeft ? (-w / 2) : (w / 2);
                wrapper.y = isTop  ? (-h / 2) : (h / 2);
            }
        }
        
        protected function positionRotators(w:Number, h:Number):void
        {
            var wrapper:Sprite, key:String, position:uint;
            var isTop:Boolean, isLeft:Boolean;
            
            for(key in rotators)
            {
                position = uint(key);
                wrapper = rotators[position];
                isLeft = position == POSITION_LT || position == POSITION_LB;
                isTop = position == POSITION_LT || position == POSITION_RT;
                wrapper.x = isLeft ? (-w / 2) : (w / 2);
                wrapper.y = isTop  ? (-h / 2) : (h / 2);
            }
        }
        
        protected function resizerDown(event:MouseEvent):void
        {
            if(lastMouse)
                return;
            lastMouse = new Point(mouseX, mouseY);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, resizerMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, resizerUp);
        }
        
        protected function resizerMove(event:MouseEvent):void
        {
            var dx:Number = Math.abs(mouseX) - Math.abs(lastMouse.x);
            var dy:Number = Math.abs(mouseY) - Math.abs(lastMouse.y);
            shapeWidth += dx * 2; 
            shapeHeight += dy * 2;
            subjectMatchTransformator();
            lastMouse = new Point(mouseX, mouseY);
        }
        
        protected function resizerUp(event:MouseEvent):void
        {
            lastMouse = null;
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, resizerMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, resizerUp);
        }
        
        protected function rotatorDown(event:MouseEvent):void
        {
            if(lastMouse)
                return;
            lastMouse = new Point(mouseX, mouseY);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, rotatorMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, rotatorUp);
        }
        
        protected function rotatorMove(event:MouseEvent):void
        {
            var rad1:Number = Math.atan2(lastMouse.y, lastMouse.x);
            var rad2:Number = Math.atan2(mouseY, mouseX);
            rotation += (rad2 - rad1) * 180 / Math.PI;
            subjectMatchTransformator();
            lastMouse = new Point(mouseX, mouseY);
        }
        
        protected function rotatorUp(event:MouseEvent):void
        {
            lastMouse = null;
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, rotatorMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, rotatorUp);
        }
        
        protected function shapeDown(event:MouseEvent):void
        {
            if(!draggable)
                return;
                
            lastMouse = new Point(mouseX, mouseY);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, shapeMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, shapeUp);
        }
        
        protected function shapeMove(event:MouseEvent):void
        {
            var p1:Point = localToGlobal(lastMouse);
            var p2:Point = localToGlobal(new Point(mouseX, mouseY));
            x += p2.x - p1.x;
            y += p2.y - p1.y;
            subjectMatchTransformator();
            lastMouse = new Point(mouseX, mouseY);
        }
        
        protected function shapeUp(event:MouseEvent):void
        {
            lastMouse = null;
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, shapeMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, shapeUp);
        }
    }
}