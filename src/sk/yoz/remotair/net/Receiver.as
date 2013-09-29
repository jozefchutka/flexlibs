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
    import com.adobe.serialization.json.JSON;
    
    import flash.events.AccelerometerEvent;
    import flash.events.ActivityEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.GeolocationEvent;
    import flash.events.GestureEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.NetStatusEvent;
    import flash.events.PressAndTapGestureEvent;
    import flash.events.StatusEvent;
    import flash.events.TextEvent;
    import flash.events.TouchEvent;
    import flash.events.TransformGestureEvent;
    import flash.net.URLLoader;
    
    import sk.yoz.data.UNIPacket;
    import sk.yoz.remotair.data.Serializer;
    import sk.yoz.remotair.events.CameraEvent;
    import sk.yoz.remotair.events.JoystickEvent;
    import sk.yoz.remotair.events.MicrophoneEvent;
    import sk.yoz.remotair.events.ReceiverEvent;
    import sk.yoz.remotair.events.RemotairEvent;
    import sk.yoz.remotair.events.ViewEvent;
    
    public class Receiver extends GenericConnector
    {
        public var mouseEvents:EventDispatcher = new EventDispatcher;
        public var keyboardEvents:EventDispatcher = new EventDispatcher;
        public var textEvents:EventDispatcher = new EventDispatcher;
        public var joystickEvents:EventDispatcher = new EventDispatcher;
        public var cameraEvents:EventDispatcher = new EventDispatcher;
        public var microphoneEvents:EventDispatcher = new EventDispatcher;
        public var activityEvents:EventDispatcher = new EventDispatcher;
        public var accelerometerEvents:EventDispatcher = new EventDispatcher;
        public var statusEvents:EventDispatcher = new EventDispatcher;
        public var touchEvents:EventDispatcher = new EventDispatcher;
        public var gestureEvents:EventDispatcher = new EventDispatcher;
        public var geolocationEvents:EventDispatcher = new EventDispatcher;
        public var viewEvents:EventDispatcher = new EventDispatcher;
        public var remotairEvents:EventDispatcher = new EventDispatcher;
        
        public function Receiver(handshakeURL:String, developerKey:String, 
                                 channelService:String)
        {
            super(handshakeURL, developerKey, channelService);
        }
        
        public function connectChannel(channel:String):void
        {
            protected::channel = channel;
            !inited && init();
            connect();
        }
        
        protected function onChannelConnectionCompleted(event:Event):void
        {
            var loader:URLLoader = URLLoader(event.currentTarget);
            var data:Object = JSON.decode(loader.data.toString());
            var client:Object = {};
            client[PACKET_METHOD] = onPacketMethod;
            play(data.connection, client);
        }
        
        protected function onPacketMethod(data:Object):void
        {
            var packet:UNIPacket = UNIPacket.create(data);
            var className:String = packet.header.className;
            var type:String = ReceiverEvent.PACKET_RECEIVED;
            dispatchEvent(new ReceiverEvent(type, packet));
            
            try
            {
                packet.data = unserialize(className, packet.data);
                dispatch(packet);
            }
            catch(error:Error){}
        }
        
        protected function unserialize(className:String, data:Object):Object
        {
            return Serializer.unserialize(className, data);
        }
        
        override protected function fNetConnectionConnectSuccess(event:NetStatusEvent):void
        {
            super.fNetConnectionConnectSuccess(event);
            getChannelConnection(public::channel, onChannelConnectionCompleted);
        }
        
        override protected function fNetConnectionConnectFailed(event:NetStatusEvent):void
        {
            super.fNetConnectionConnectFailed(event);
            destroy();
        }
        
        override protected function fNetConnectionConnectClosed(event:NetStatusEvent):void
        {
            super.fNetConnectionConnectClosed(event);
            destroy();
        }
        
        override protected function fNetStreamPlayStart(event:NetStatusEvent):void
        {
            super.fNetStreamPlayStart(event);
            protected::peerID = "unknown";
        }
        
        override protected function fNetStreamConnectClosed(event:NetStatusEvent):void
        {
            super.fNetStreamConnectClosed(event);
            if(event.info.stream == stream)
                protected::peerID = null;
        }
        
        protected function dispatch(packet:UNIPacket):Boolean
        {
            var type:String = ReceiverEvent.EVENT_RECEIVED;
            if(packet.data is Event)
                dispatchEvent(new ReceiverEvent(type, packet));
            
            if(packet.data is RemotairEvent)
                return remotairEvents.dispatchEvent(packet.data);
            if(packet.data is ViewEvent)
                return viewEvents.dispatchEvent(packet.data);
            if(packet.data is MouseEvent)
                return mouseEvents.dispatchEvent(packet.data);
            if(packet.data is KeyboardEvent)
                return keyboardEvents.dispatchEvent(packet.data);
            if(packet.data is TextEvent)
                return textEvents.dispatchEvent(packet.data);
            if(packet.data is JoystickEvent)
                return joystickEvents.dispatchEvent(packet.data);
            if(packet.data is CameraEvent)
                return cameraEvents.dispatchEvent(packet.data);
            if(packet.data is MicrophoneEvent)
                return microphoneEvents.dispatchEvent(packet.data);
            if(packet.data is ActivityEvent)
                return activityEvents.dispatchEvent(packet.data);
            if(packet.data is StatusEvent)
                return statusEvents.dispatchEvent(packet.data);
            if(packet.data is AccelerometerEvent)
                return accelerometerEvents.dispatchEvent(packet.data);
            if(packet.data is TouchEvent)
                return touchEvents.dispatchEvent(packet.data);
            if(packet.data is PressAndTapGestureEvent)
                return gestureEvents.dispatchEvent(packet.data);
            if(packet.data is TransformGestureEvent)
                return gestureEvents.dispatchEvent(packet.data);
            if(packet.data is GestureEvent)
                return gestureEvents.dispatchEvent(packet.data);
            if(packet.data is GeolocationEvent)
                return geolocationEvents.dispatchEvent(packet.data);
            return false;
        }
    }
}