package sk.yoz.events
{
    import flash.events.Event;

    public class TwitterLoggerEvent extends Event
    {
        public static const CONNECTED:String = "TwitterLoggerEventCONNECTED";
        public static const PROXY_CHANGED:String = "TwitterLoggerEventPROXY_CHANGED";
        public static const CONNECTOR_CHANGED:String = "TwitterLoggerEventCONNECTOR_CHANGED";
        public static const CALL_COMPLETE:String = "TwitterLoggerEventCONNECTOR_CHANGED";
        
        private var _data:Object;
        
        public function TwitterLoggerEvent(type:String, bubbles:Boolean=false, 
            cancelable:Boolean=false, data:Object=null)
        {
            super(type, bubbles, cancelable);
            
            _data = data;
        }
        
        public function get data():Object
        {
            return _data;
        }
    }
}