package sk.yoz.api
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    
    public class AbstractApi extends Event implements IEventDispatcher
    {
        private var dispatcher:EventDispatcher;
        private var _rawResult:Object;
        private var _completed:Boolean;
        
        public function AbstractApi(type:String)
        {
            super(type, false, false);
            
            dispatcher = new EventDispatcher(this);
        }
        
        public function get rawResult():Object
        {
            return _rawResult;
        }
        
        public function get completed():Boolean
        {
            return _completed;
        }
        
        public function complete(rawResult:Object):void
        {
            _rawResult = rawResult;
            _completed = true;
            stopImmediatePropagation();
            dispatchEvent(new Event(Event.COMPLETE, false, false));
        }
        
        override public function clone():Event
        {
            return new AbstractApi(type);
        }
        
        override public function toString():String
        {
            return "[AbstractApi " 
                + "type='" + type + "' "
                + "completed=" + completed + " "
                + "rawResult=" + rawResult + "]";
        }
        
        public function addEventListener(type:String, listener:Function, 
            useCapture:Boolean = false, priority:int = 0,
            useWeakReference:Boolean = false):void
        {
            dispatcher.addEventListener(type, listener, useCapture, priority, 
                useWeakReference);
        }
        
        public function removeEventListener(type:String, listener:Function,
            useCapture:Boolean = false ):void
        {
            dispatcher.removeEventListener(type, listener, useCapture);
        }
        
        public function dispatchEvent(event:Event):Boolean
        {
            return dispatcher.dispatchEvent(event);
        }
        
        public function hasEventListener(type:String):Boolean
        {
            return dispatcher.hasEventListener(type);
        }
        
        public function willTrigger(type:String):Boolean
        {
            return dispatcher.willTrigger(type);
        }
    }
}