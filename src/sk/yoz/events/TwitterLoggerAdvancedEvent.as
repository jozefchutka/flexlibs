package sk.yoz.events
{
    import sk.yoz.events.TwitterLoggerEvent;

    public class TwitterLoggerAdvancedEvent extends TwitterLoggerEvent
    {
        public static const AUTHENTICATION_ERROR:String = 
            "TwitterLoggerAdvancedEventAUTHENTICATION_ERROR"
        
        public function TwitterLoggerAdvancedEvent(type:String, 
            bubbles:Boolean=false, cancelable:Boolean=false, data:Object=null)
        {
            super(type, bubbles, cancelable, data);
        }
        
    }
}