package sk.yoz.events
{
    import flash.events.Event;

    public final class P2PMulticastPersistenceEvent extends Event
    {
        public static const CLIENTS_DEFINED:String = "clientsDefined";
        
        private var _data:Object;
        
        public function P2PMulticastPersistenceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object=null)
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