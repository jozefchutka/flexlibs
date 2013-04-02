package sk.yoz.net
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.StatusEvent;
    import flash.net.LocalConnection;
    import flash.net.SharedObject;
    
    import sk.yoz.events.LocalBroadcasterEvent;
    
    public class LocalBroadcaster extends EventDispatcher
    {
        private var connection:LocalConnection;
        private var _channel:String;
        private var so:SharedObject = SharedObject.getLocal("LocalBroadcaster", "/");
        private var senderList:Object;
        
        public static const HALLO_WORLD_MESSAGE:String = ".,*-@Hallo World@-*,.";
        
        private var connectionList:Array = new Array();
        
        public function LocalBroadcaster()
        {
            super();
            var result:Boolean;
            var attempts:uint = 0;
            while(!result || attempts >= 5)
            {
                result = initConnection(randomChannel);
                attempts++;
            }
            
            if(result)
                addChannel(public::channel);
            else
                trace("LocalBroadcaster: Unable to create connection!");
        }
        
        private function get randomChannel():String
        {
            return Math.round(Math.random() * uint.MAX_VALUE).toString(36);
        }
        
        public function get channel():String
        {
            return _channel;
        }
        
        [Bindable(event="channelsChanged")]
        public function get channels():Array
        {
            var list:Array = [];
            if(!so || !so.data.hasOwnProperty("channels"))
                return list;
            for(var channel:String in so.data.channels)
                list.push(channel);
            return list;
        }
        
        private function set channel(value:String):void
        {
            _channel = value;
        }
        
        private function initConnection(channel:String):Boolean
        {
            connection = new LocalConnection();
            connection.client = this;
            try
            {
                connection.connect(channel);
            }
            catch(error:Error)
            {
                //dispatchEvent(new Error(error.message));
                connection = null;
                return false;
            }
            
            private::channel = channel;
            dispatchEvent(new LocalBroadcasterEvent(LocalBroadcasterEvent.CHANNEL_CREATED, false, false, channel));
            dispatchEvent(new Event("channelsChanged"));
            broadcast(HALLO_WORLD_MESSAGE);
            return true;
        }
        
        private function addChannel(channel:String):void
        {
            if(!so.data.channels)
                so.data.channels = {};
            if(so.data.channels.hasOwnProperty(channel))
                return;
            so.data.channels[channel] = channel;
            try
            {
                so.flush();
            }
            catch(error:Error){}
            dispatchEvent(new LocalBroadcasterEvent(LocalBroadcasterEvent.CHANNEL_ADDED, false, false, channel));
            dispatchEvent(new Event("channelsChanged"));
        }
        
        private function removeChannel(channel:String):void
        {
            if(!so.data.channels)
                return;
            delete so.data.channels[channel];
            try
            {
                so.flush();
            }
            catch(error:Error){}
            dispatchEvent(new LocalBroadcasterEvent(LocalBroadcasterEvent.CHANNEL_REMOVED, false, false, channel));
            dispatchEvent(new Event("channelsChanged"));
        }
        
        public function broadcast(data:Object, broadcastToSender:Boolean = false):void
        {
            var sender:LocalConnection;
            senderList = {};
            for(var channel:String in so.data.channels)
            {
                if(!broadcastToSender && channel == public::channel)
                    continue;
                sender = new LocalConnection();
                sender.addEventListener(StatusEvent.STATUS, onStatus);
                sender.send(channel, "receive", public::channel, data);
                senderList[channel] = sender;
                dispatchEvent(new LocalBroadcasterEvent(LocalBroadcasterEvent.CHANNEL_FOUND, false, false, channel));
                dispatchEvent(new Event("channelsChanged"));
            }
        }
        
        public function receive(channel:String, data:Object):void
        {
            if(data == HALLO_WORLD_MESSAGE)
            {
                addChannel(channel);
                dispatchEvent(new LocalBroadcasterEvent(LocalBroadcasterEvent.RECEIVED_HALLO_WORLD, false, false, channel, data));
                return;
            }
            
            dispatchEvent(new LocalBroadcasterEvent(LocalBroadcasterEvent.RECEIVED_DATA, false, false, channel, data));
        }
        
        private function onStatus(event:StatusEvent):void
        {
            if(!senderList)
                return;
                
            var sender:LocalConnection;
            var channel:String;
            for(var key:String in senderList)
                if(senderList[key] == event.target)
                    channel = key;
            
            senderList[channel] = null;
            delete senderList[channel];
            if(event.level == "error")
                removeChannel(channel);
        }
    }
}