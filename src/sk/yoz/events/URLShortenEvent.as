package sk.yoz.events
{
    import flash.events.Event;

    public class URLShortenEvent extends Event
    {
        public static const COMPLETE:String = "URLShortenEventCOMPLETE";
        
        private var _url:String;
        
        public function URLShortenEvent(type:String, bubbles:Boolean=false, 
            cancelable:Boolean=false, url:String="")
        {
            super(type, bubbles, cancelable);
            _url = url;
        }
        
        public function get url():String
        {
            return _url;
        }
    }
}