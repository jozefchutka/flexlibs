package sk.yoz.events
{
    import flash.events.Event;

    public final class P2PMulticastEvent extends Event
    {
        public static const STREAM_CONNECTED:String = "p2pStreamConnected";
        public static const CLIENT_ID_ASSIGNED:String = "p2pClientIdAssigned";
        public static const PEER_DISCONNECTED:String = "p2pPeerDisconnected";
        public static const PEER_CONNECTED:String = "p2pPeerConnected";
        public static const PEER_DATA:String = "p2pPeerData";
        
        private var _data:Object;
        
        public function P2PMulticastEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object=null)
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