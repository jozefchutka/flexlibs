/*
Copyright (c) 2009-2010 Jozef Chutka
 
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package sk.yoz.remotair.net
{
    import flash.events.AsyncErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.NetStatusEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.NetConnection;
    import flash.net.NetStream;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    
    import sk.yoz.remotair.events.GenericConnectorEvent;
    
    public class GenericConnector extends EventDispatcher
    {
        public static const HANDSHAKE_URL:String = "rtmfp://p2p.rtmfp.net";
        public static const DEVELOPER_KEY:String = "a2299ef15861a53c65699063-7c3e48fa4695";
        public static const CHANNEL_SERVICE:String = "http://remotair.yoz.sk";
        
        //public static const HANDSHAKE_URL:String = "rtmfp://ec2-184-72-79-139.compute-1.amazonaws.com:1936";
        //public static const HANDSHAKE_URL:String = "rtmfp://rtmfp.yoz.sk:1936";
        //public static const DEVELOPER_KEY:String = "";
        
        protected static const PACKET_METHOD:String = "onPacket";
        protected static const PUBLISH_NAME:String = "remotair";
        
        private var _connection:NetConnection;
        private var _stream:NetStream;
        private var _channel:String;
        private var _inited:Boolean;
        
        private var _netConnected:Boolean;
        private var _peerID:String;
        
        private var handshakeURL:String;
        private var developerKey:String;
        private var channelService:String;
        
        public function GenericConnector(handshakeURL:String, 
            developerKey:String, channelService:String)
        {
            super();
            
            this.handshakeURL = handshakeURL;
            this.developerKey = developerKey;
            this.channelService = channelService;
        }
        
        protected function get inited():Boolean
        {
            return _inited;
        }
        
        protected function set netConnected(value:Boolean):void
        {
            _netConnected = value;
            
            var type:String = value 
                ? GenericConnectorEvent.NET_CONNECTED 
                : GenericConnectorEvent.NET_DISCONNECTED;
            dispatchEvent(new GenericConnectorEvent(type));
            
            if(!value)
                protected::peerID = null;
        }
        
        public function get netConnected():Boolean
        {
            return _netConnected;
        }
        
        protected function set peerID(value:String):void
        {
            _peerID = value;
            
            var type:String = value 
                ? GenericConnectorEvent.PEER_CONNECTED 
                : GenericConnectorEvent.PEER_DISCONNECTED;
            dispatchEvent(new GenericConnectorEvent(type));
        }
        
        public function get peerID():String
        {
            return _peerID;
        }
        
        public function get peerConnected():Boolean
        {
            return public::peerID ? true : false;
        }
        
        public function get nearID():String
        {
            return (public::connection && public::connection.connected) 
                ? public::connection.nearID : null;
        }
        
        public function get connection():NetConnection
        {
            return _connection;
        }
        
        private function set connection(value:NetConnection):void
        {
            _connection = value;
        }
        
        public function get stream():NetStream
        {
            return _stream;
        }
        
        private function set stream(value:NetStream):void
        {
            _stream = value;
        }
        
        public function get channel():String
        {
            return _channel;
        }
        
        protected function set channel(value:String):void
        {
            _channel = value;
        }
        
        protected function init():void
        {
            _inited = true;
            private::connection = new NetConnection();
            public::connection.maxPeerConnections = 2;
            public::connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            public::connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
            public::connection.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
            public::connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
        }
        
        protected function destroy():void
        {
            _inited = false;
            if(public::netConnected)
                protected::netConnected = false;
            if(public::peerConnected)
                protected::peerID = null;
            protected::channel = null;
            
            try
            {
                public::connection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
                public::connection.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
                public::connection.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
                public::connection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
                public::connection.close();
                private::connection = null;
            }
            catch(error:Error){}
            
            var stream:NetStream = public::stream;
            try
            {
                stream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
                stream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
                stream.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
                stream.close();
                stream = null;
            }
            catch(error:Error){}
        }
        
        public function connect():void
        {
            public::connection.connect(handshakeURL + "/" + developerKey);
        }
        
        public function disconnect():void
        {
            public::connection.close();
        }
        
        protected function publish(peerID:String, client:Object):void
        {
            var stream:NetStream = new NetStream(public::connection, peerID);
            stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
            stream.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
            stream.client = client;
            stream.publish(PUBLISH_NAME);
            private::stream = stream;
        }
        
        protected function play(peerID:String, client:Object):void
        {
            var stream:NetStream = new NetStream(public::connection, peerID);
            stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
            stream.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
            stream.client = client;
            stream.play(PUBLISH_NAME);
            private::stream = stream;
        }
        
        protected function createChannel(connection:String, onComplete:Function):void
        {
            var url:String = channelService + "/channel/create/" + connection;
            var loader:URLLoader = new URLLoader();
            var request:URLRequest = new URLRequest(url);
            loader.load(request);
            loader.addEventListener(Event.COMPLETE, onComplete);
        }
        
        protected function getChannelConnection(channel:String, onComplete:Function):void
        {
            var url:String = channelService + "/channel/get/" + channel;
            var loader:URLLoader = new URLLoader();
            var request:URLRequest = new URLRequest(url);
            loader.load(request);
            loader.addEventListener(Event.COMPLETE, onComplete);
        }
        
        private function onNetStatus(event:NetStatusEvent):void
        {
            var code:String = event.info.code;
            var fName:String = "f" + code.replace(/\./g, "");
            try
            {
                var fFunction:Function = this[fName] as Function;
                fFunction(event);
            }
            catch(error:Error){}
        }
        
        protected function fNetConnectionConnectSuccess(event:NetStatusEvent):void
        {
            protected::netConnected = true;
        }
        
        protected function fNetConnectionConnectFailed(event:NetStatusEvent):void
        {
            protected::netConnected = false;
        }
        
        protected function fNetConnectionConnectClosed(event:NetStatusEvent):void
        {
            protected::netConnected = false;
        }
        
        protected function fNetStreamPublishStart(event:NetStatusEvent):void{}
        protected function fNetStreamPlayStart(event:NetStatusEvent):void{}
        protected function fNetStreamPlayReset(event:NetStatusEvent):void{}
        protected function fNetStreamPlayFailed(event:NetStatusEvent):void{}
        protected function fNetStreamConnectClosed(event:NetStatusEvent):void{}
        protected function fNetConnectionConnectNetworkChange(event:NetStatusEvent):void{}
        
        protected function onAsyncError(event:AsyncErrorEvent):void
        {
            trace("asyncErrorHandler", event.text);
        }
        
        protected function onIOError(event:IOErrorEvent):void
        {
            trace("ioErrorHandler", event.text);
        }
        
        protected function onSecurityError(event:SecurityErrorEvent):void
        {
            trace("securityErrorHandler", event.text);
        }
    }
}