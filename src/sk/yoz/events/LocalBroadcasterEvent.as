package sk.yoz.events
{
    import flash.events.Event;

    public class LocalBroadcasterEvent extends Event
    {
        private var _channel:String;
        private var _data:Object;
        
        public static const RECEIVED_DATA:String = "LocalBroadcasterEventReceivedData";
        public static const RECEIVED_HALLO_WORLD:String = "LocalBroadcasterEventReceivedHalloWorld";
        
        public static const CHANNEL_ADDED:String = "LocalBroadcasterEventChannelAdded";
        public static const CHANNEL_CREATED:String = "LocalBroadcasterEventChannelCreated";
        public static const CHANNEL_FOUND:String = "LocalBroadcasterEventChannelFound";
        public static const CHANNEL_REMOVED:String = "LocalBroadcasterEventChannelRemoved";
        
        public function LocalBroadcasterEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,
            channel:String=null, data:Object=null)
        {
            super(type, bubbles, cancelable);
            
            _channel = channel;
            _data = data;
        }
        
        public function get channel():String
        {
            return _channel;
        }
        
        public function get data():Object
        {
            return _data;
        }
    }
}