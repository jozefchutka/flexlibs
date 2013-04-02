package sk.yoz.events
{
    import flash.events.Event;

    public final class P2PMulticastStreamEvent extends Event
    {
        public static const CLIENT_ID_ASSIGNED:String = "clientIdAssigned";
        public static const PEER_DISCONNECTED:String = "peerDisconnected";
        public static const PEER_CONNECTED:String = "peerConnected";
        public static const PEER_DATA:String = "peerData";
        
        private var _data:Object;
        
        public function P2PMulticastStreamEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object=null)
        {
            super(type, bubbles, cancelable);
            if(data)
                _data = data;
        }
        
        public function get data():Object
        {
            return _data;
        }
    }
}