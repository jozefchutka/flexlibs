package sk.yoz.html
{
    import flash.events.Event;
    import flash.external.ExternalInterface;
    import flash.geom.Point;
    
    import mx.containers.Canvas;

    public class IFrame extends Canvas
    {
        public var methodResize:String = "FlexIFrame.resize";
        public var methodMove:String = "FlexIFrame.move";
        public var methodNavigate:String = "FlexIFrame.navigate";
        public var methodVisibility:String = "FlexIFrame.visibility";
        
        public var positionChanged:Boolean = false;
        public var sizeChanged:Boolean = false;
        
        private var _autoResize:Boolean = false;
        private var _url:String = '';
        
        public function IFrame()
        {
            super();
            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler)
        }
        
        override public function set id(value:String):void
        {
            super.id = value;
        }
        
        protected function addedToStageHandler(event:Event):void
        {
            positionChanged = true;
            sizeChanged = true;
            invalidateProperties();
        }
        
        public function set autoResize(value:Boolean):void
        {
            _autoResize = value;
            if(value)
                addEventListener(Event.RESIZE, autoResizeHandler);
            else
                removeEventListener(Event.RESIZE, autoResizeHandler);
        }
        
        public function get autoResize():Boolean
        {
            return _autoResize;
        }
        
        protected function autoResizeHandler(event:Event):void
        {
            positionChanged = true;
            sizeChanged = true;
            invalidateProperties();
        }
        
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            if(positionChanged)
            {
                var point:Point = localToGlobal(new Point(0, 0));
                callJS(methodMove, point.x, point.y);
                positionChanged = false;
            }
            
            if(sizeChanged)
            {
                callJS(methodResize, width, height);
                sizeChanged = false;
            }
        }
        
        public function set url(value:String):void
        {
            _url = value;
            callJS(methodNavigate, value)
        }
        
        public function get url():String
        {
            return _url;
        }
        
        protected function callJS(method:String, ... values):void
        {
            if(!id)
                throw new Error("IFrame id is not defined");
            var args:Array = [method, id];
            try
            {
                ExternalInterface.call.apply(ExternalInterface, args.concat(values));
            }
            catch(error:Error)
            {
                trace(error.message);
            }
        }
        
        override public function set visible(value:Boolean):void
        {
            super.visible = value;
            callJS(methodVisibility, value);
        }
        
        override public function set width(value:Number):void
        {
            super.width = value;
            callJS(methodResize, value, height);
        }
        
        override public function set height(value:Number):void
        {
            super.height = value;
            callJS(methodResize, width, value);
        }
        
        override public function set x(value:Number):void
        {
            super.x = value;
            var point:Point = localToGlobal(new Point(0, 0));
            callJS(methodMove, point.x, point.y);
        }
        
        override public function set y(value:Number):void
        {
            super.y = value;
            var point:Point = localToGlobal(new Point(0, 0));
            callJS(methodMove, point.x, point.y);
        }
    }
}

/*
var FlexIFrame = {
    get: function(id)
    {
        var iframe = document.getElementById(id);
        if(!iframe)
            return FlexIFrame.create(id);
        return iframe;
    },

    create: function(id)
    {
        var iframe = document.createElement('iframe');
        iframe.id = id;
        iframe.frameborder = 0;
        iframe.style.position = "absolute";
        iframe.style.zIndex = 1;
        iframe.style.border = "none";
        document.body.insertBefore(iframe, document.body.firstChild);
        return iframe;
    },

    resize: function(id, width, height)
    {
        var iframe = FlexIFrame.get(id);
        iframe.style.width = width + "px";
        iframe.style.height = height + "px";
    },

    move: function(id, x, y)
    {
        var iframe = FlexIFrame.get(id);
        iframe.style.left = x + "px";
        iframe.style.top = y + "px";
    },

    navigate: function(id, url)
    {
        var iframe = FlexIFrame.get(id);
        iframe.src = url;
    },

    visibility: function(id, visible)
    {
        var iframe = FlexIFrame.get(id);
        iframe.style.display = visible ? "block" : "none";
    }
}
*/