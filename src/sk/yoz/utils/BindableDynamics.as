package sk.yoz.utils
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.utils.Proxy;
    import flash.utils.flash_proxy;
     
    [Bindable(event="propertyChange")]
    public dynamic class BindableDynamics extends Proxy implements IEventDispatcher
    {
        public static const EVENT_PROPERTY_CHANGE:String = "propertyChange";
        
        private var dispatcher:EventDispatcher;
        private var items:Array;
        
        public function BindableDynamics()
        {
            dispatcher = new EventDispatcher(this);
            items = [];
        }
        
        override flash_proxy function setProperty(name:*, value:*):void
        {
            items[name] = value;
            dispatchEvent(new Event(EVENT_PROPERTY_CHANGE));
        }
        
        override flash_proxy function getProperty(name:*):*
        {
            return getDynamicProperty(name);
        }
        
        public function getDynamicProperty(name:*):*
        {
            return items[name];
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