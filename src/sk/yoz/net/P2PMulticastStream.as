package sk.yoz.net
{
    import flash.events.AsyncErrorEvent;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.NetStatusEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.TimerEvent;
    import flash.net.NetConnection;
    import flash.net.NetStream;
    
    import sk.yoz.DataTimer;
    import sk.yoz.Log;
    import sk.yoz.events.P2PMulticastStreamEvent;
    
    public class P2PMulticastStream extends EventDispatcher
    {
        private var publishName:String = "com";
        private var maxPeerConnections:uint = 100;
        private var handshakeURL:String = "rtmfp://stratus.adobe.com";   // eg: rtmfp://stratus.adobe.com
        private var developerKey:String = "";
        private var clientConnectionTimeout:uint = 15000;
        
        private var stratus:NetConnection;
        private var publish:NetStream;
        private var clients:Object = {};
        
        public var debug:Boolean = false;
        private var log:Log = Log.instance;
        
        public function P2PMulticastStream(developerKey:String = "", publishName:String = "", 
            maxPeerConnections:uint = 0, handshakeURL:String = "", clientConnectionTimeout:uint = 0)
        {
            super();
            if(publishName)
                this.publishName = publishName;
            if(maxPeerConnections)
                this.maxPeerConnections = maxPeerConnections;
            if(handshakeURL)
                this.handshakeURL = handshakeURL;
            if(developerKey)
                this.developerKey = developerKey;
            if(clientConnectionTimeout)
                this.clientConnectionTimeout = clientConnectionTimeout;
                
            stratus = new NetConnection();
            stratus.maxPeerConnections = this.maxPeerConnections;
            stratus.addEventListener(NetStatusEvent.NET_STATUS, stratusStatusHandler);
            stratus.addEventListener(AsyncErrorEvent.ASYNC_ERROR, stratusAsyncErrorHandler);
            stratus.addEventListener(IOErrorEvent.IO_ERROR, stratusIOErrorHandler);
            stratus.addEventListener(SecurityErrorEvent.SECURITY_ERROR, stratusSecurityErrorHandler);
            stratus.connect(this.handshakeURL + "/" + this.developerKey + "/");
        }
        
        public function get connected():Boolean
        {
            return nearID ? true : false;
        }
        
        public function get onlineClients():Array
        {
            var list:Array = [];
            for(var farID:String in clients)
                if(client(farID).connected)
                    list.push(farID);
            return list;
        }
        
        public function get allConnected():Boolean
        {
            for(var farID:String in clients)
                if(!client(farID).connected)
                    return false;
            return true;
        }
        
        private function initPublish():void
        {
            if(debug)
                log.write("P2PMulticastStream.initPublish()");
            publish = new NetStream(stratus, NetStream.DIRECT_CONNECTIONS);
            publish.addEventListener(NetStatusEvent.NET_STATUS, publishStatusHandler);
            publish.addEventListener(AsyncErrorEvent.ASYNC_ERROR, publishAsyncErrorHandler);
            publish.addEventListener(IOErrorEvent.IO_ERROR, publishIOErrorHandler);
            publish.publish(publishName);
            publish.client = {
                onPeerConnect: function(caller:NetStream):Boolean
                {
                    connectClient(caller.farID);
                    return true;
                }
            };
        }
        
        public function get nearID():String
        {
            return stratus && stratus.connected ? stratus.nearID : '';
        }
        
        private function client(farID:String):StratusStream
        {
            return clients.hasOwnProperty(farID) ? clients[farID] : null;
        }
        
        public function connectClient(farID:String):void
        {
            if(farID == nearID || clients.hasOwnProperty(farID))
                return;
                
            if(debug)
                log.write("P2PMulticastStream.connectClient(" + farID + ")");
            var c:StratusStream = new StratusStream(stratus, farID);
            c.addEventListener(NetStatusEvent.NET_STATUS, clientStatusHandler);
            c.play(publishName);
            c.client = {
                onData: function(data:Object):void
                {
                    if(debug)
                        log.write("P2PMulticastStream.client(" + farID + ").onData(" + data.toString() + ")");
                    dispatchEvent(new P2PMulticastStreamEvent(P2PMulticastStreamEvent.PEER_DATA, false, false, {farID:farID, data:data}));
                }
            };
            clients[farID] = c;
            
            var timer:DataTimer = new DataTimer(clientConnectionTimeout, 1, {farID:farID});
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, clientConnectionTimeoutHandler);
            timer.start();
        }
        
        private function clientConnectionTimeoutHandler(event:TimerEvent):void
        {
            var timer:DataTimer = event.target as DataTimer;
            var farID:String = timer.data.farID;
            if(client(farID) && !client(farID).connected)
                disconnectClient(farID);
            timer.removeEventListener(TimerEvent.TIMER_COMPLETE, clientConnectionTimeoutHandler);
            timer = null;
        }
        
        private function disconnectClient(farID:String):void
        {
            if(farID == nearID || !client(farID))
                return;
            clients[farID] = null;
            delete clients[farID];
            if(debug)
                log.write("P2PMulticastStream.disconnectClient(" + farID + ")");
            dispatchEvent(new P2PMulticastStreamEvent(P2PMulticastStreamEvent.PEER_DISCONNECTED, true, true, {farID:farID}));
        }
        
        public function broadcast(data:Object):Boolean
        {
            if(!connected)
                return false;
            try
            {
                publish.send("onData", data);
            }
            catch(error:Error)
            {
                if(debug)
                    log.write("P2PMulticastStream.sendData(" + data.toString() + ") // ERROR: " + error.message);
                return false;
            }
            return true;
        }
        
        private function clientStatusHandler(event:NetStatusEvent):void
        {
            var farID:String = event.target.farID;
            if(debug)
                log.write("P2PMulticastStream.clientStatusHandler(" + event.info.code + ")");
            switch(event.info.code)
            {
                case "NetStream.Play.Start":
                    if(debug)
                        log.write("P2PMulticastStream.clientStatusHandler(" + event.info.code + ") " + 
                                "// client(" + farID + ") connected");
                    client(farID).connected = true;
                    dispatchEvent(new P2PMulticastStreamEvent(P2PMulticastStreamEvent.PEER_CONNECTED, true, true, {farID:farID}));
                    break;
            }
        }
        
        private function stratusStatusHandler(event:NetStatusEvent):void
        {
            if(debug)
                log.write("P2PMulticastStream.stratusStatusHandler(" + event.info.code + ")");
            switch(event.info.code)
            {
                case "NetConnection.Connect.Success":
                    if(debug)
                        log.write("P2PMulticastStream.stratusStatusHandler(" + event.info.code + ") " + 
                                "// p2p connection ready (" + nearID + ")");
                    initPublish();
                    dispatchEvent(new P2PMulticastStreamEvent(P2PMulticastStreamEvent.CLIENT_ID_ASSIGNED, true, true, {nearID:nearID}));
                    break;
                    
                case "NetStream.Connect.Closed":
                    if(debug)
                        log.write("P2PMulticastStream.stratusStatusHandler(" + event.info.code + ") " + 
                                "// p2p disconnected (" + event.info.stream.farID + ")");
                    disconnectClient(event.info.stream.farID);
                    break;
            }
        }
        
        private function stratusAsyncErrorHandler(event:AsyncErrorEvent):void
        {
            if(debug)
                log.write("P2PMulticastStream.stratusAsyncErrorHandler(" + event.text + ")");
        }
        
        private function stratusIOErrorHandler(event:IOErrorEvent):void
        {
            if(debug)
                log.write("P2PMulticastStream.stratusIOErrorHandler(" + event.text + ")");
        }
        
        private function stratusSecurityErrorHandler(event:SecurityErrorEvent):void
        {
            if(debug)
                log.write("P2PMulticastStream.stratusSecurityErrorHandler(" + event.text + ")");
        }
        
        private function publishStatusHandler(event:NetStatusEvent):void
        {
            if(debug)
                log.write("P2PMulticastStream.publishStatusHandler(" + event.info.code + ")");
            switch(event.info.code)
            {
                case "NetStream.Publish.Start":
                    if(debug)
                        log.write("P2PMulticastStream.publishStatusHandler(" + event.info.code + ") " + 
                                "// publishing started (" + nearID + ")");
                    break;
            }
        }
        
        private function publishAsyncErrorHandler(event:AsyncErrorEvent):void
        {
            if(debug)
                log.write("P2PMulticastStream.publishAsyncErrorHandler(" + event.text + ")");
        }
        
        private function publishIOErrorHandler(event:IOErrorEvent):void
        {
            if(debug)
                log.write("P2PMulticastStream.publishIOErrorHandler(" + event.text + ")");
        }
        
        public function getClientList():Array
        {
            var list:Array = [];
            for(var farID:String in clients)
                list.push(farID);
            return list;
        }
    }
}