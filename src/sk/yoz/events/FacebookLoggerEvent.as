package sk.yoz.events
{
    import flash.events.Event;
    
    public class FacebookLoggerEvent extends Event
    {
        public static const CONNECTED:String = "FacebookLoggerEventCONNECTED";
        
        public function FacebookLoggerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
        
    }
}