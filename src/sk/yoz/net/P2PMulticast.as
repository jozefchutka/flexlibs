package sk.yoz.net
{
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    import sk.yoz.events.P2PMulticastEvent;
    import sk.yoz.events.P2PMulticastPersistenceEvent;
    import sk.yoz.events.P2PMulticastStreamEvent;
    
    public class P2PMulticast extends EventDispatcher
    {
        private var stream:P2PMulticastStream;
        private var persistence:IP2PMulticastPersistence;
        
        private var clientReloadTimer:Timer;
        
        public function P2PMulticast(persistence:IP2PMulticastPersistence, developerKey:String = "", 
            publishName:String = "", maxPeerConnections:uint = 0, handshakeURL:String = "", 
            clientConnectionTimeout:uint = 0)
        {
            super();
            
            stream = new P2PMulticastStream(developerKey, publishName, maxPeerConnections, 
                handshakeURL, clientConnectionTimeout);
            stream.addEventListener(P2PMulticastStreamEvent.CLIENT_ID_ASSIGNED, clientIdAssignedHandler);
            stream.addEventListener(P2PMulticastStreamEvent.PEER_CONNECTED, peerConnectedHandler);
            stream.addEventListener(P2PMulticastStreamEvent.PEER_DISCONNECTED, peerDisconnectedHandler);
            stream.addEventListener(P2PMulticastStreamEvent.PEER_DATA, peerDataHandler);
            
            this.persistence = persistence;
            persistence.addEventListener(P2PMulticastPersistenceEvent.CLIENTS_DEFINED, clientsDefinedHandler);
        }
        
        public function get connected():Boolean
        {
            return stream.connected;
        }
        
        public function set debug(value:Boolean):void
        {
            if(stream)
                stream.debug = value;
        }
        
        public function get onlineClients():Array
        {
            return stream.onlineClients;
        }
        
        public function broadcast(data:Object):Boolean
        {
            return stream.broadcast(data);
        }
        
        private function clientIdAssignedHandler(event:P2PMulticastStreamEvent):void
        {
            persistence.getClientList();
            dispatchEvent(new P2PMulticastEvent(P2PMulticastEvent.STREAM_CONNECTED));
        }
        
        private function clientsDefinedHandler(event:P2PMulticastPersistenceEvent):void
        {
            var list:Array = event.data.list;
            for each(var farID:String in list)
                stream.connectClient(farID);
            if(list.indexOf(stream.nearID) == -1)
                list.push(stream.nearID);
            persistence.saveClientList(list);
            clientReloadTimer = new Timer(10000 + Math.random() * 5000, 1);
            clientReloadTimer.addEventListener(TimerEvent.TIMER_COMPLETE, clientReloadTimerComplete);
            clientReloadTimer.start();
        }
        
        private function clientReloadTimerComplete(event:TimerEvent):void
        {
            persistence.getClientList();
            
            var timer:Timer = event.target as Timer;
            timer.removeEventListener(TimerEvent.TIMER_COMPLETE, clientReloadTimerComplete);
            timer = null;
        }
        
        private function peerDataHandler(event:P2PMulticastStreamEvent):void
        {
            dispatchEvent(new P2PMulticastEvent(P2PMulticastEvent.PEER_DATA, false, false, event.data));
        }
        
        private function peerConnectedHandler(event:P2PMulticastStreamEvent):void
        {
            var farID:String = event.data.farID;
            verifyClient(farID);
            dispatchEvent(new P2PMulticastEvent(P2PMulticastEvent.PEER_CONNECTED, false, true, event.data));
        }
        
        private function peerDisconnectedHandler(event:P2PMulticastStreamEvent):void
        {
            var farID:String = event.data.farID;
            verifyClient(farID);
            dispatchEvent(new P2PMulticastEvent(P2PMulticastEvent.PEER_DISCONNECTED, false, false, event.data));
        }
        
        private function verifyClient(farID:String):void
        {
            if(!stream.allConnected)
                return;
            var list:Array = stream.getClientList();
            list.push(stream.nearID);
            persistence.saveClientList(list);
        }
    }
}