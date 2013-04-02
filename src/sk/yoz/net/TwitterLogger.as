package sk.yoz.net
{
    import com.twitter.api.Twitter;
    
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.external.ExternalInterface;
    
    import sk.yoz.events.TwitterLoggerEvent;
    
    public class TwitterLogger extends Twitter
    {
        public var jsConfirm:String = "confirmTwitterConnection";
        public var jsWindowName:String = "twitterConnector";
        
        protected var _connected:Boolean = false;
        protected var _connectorURL:String;
        protected var _proxyURL:String;
        protected var tokenCallbackDefined:Boolean = false;
        
        public function TwitterLogger(connectorURL:String, proxyURL:String)
        {
            protected::connectorURL = connectorURL;
            protected::proxyURL = proxyURL;
            
            super();
            testAvailability();
        }
        
        [Bindable(event="TwitterLoggerEventCONNECTED")]
        public function get connected():Boolean
        {
            return _connected;
        }
        
        protected function set connected(value:Boolean):void
        {
            _connected = value;
            var type:String = TwitterLoggerEvent.CONNECTED;
            dispatchEvent(new TwitterLoggerEvent(type));
        }
        
        [Bindable(event="TwitterLoggerEventCONNECTOR_CHANGED")]
        public function get connectorURL():String
        {
            return _connectorURL;
        }
        
        protected function set connectorURL(value:String):void
        {
            _connectorURL = value;
            var type:String = TwitterLoggerEvent.CONNECTOR_CHANGED;
            dispatchEvent(new TwitterLoggerEvent(type));
        }
        
        [Bindable(event="TwitterLoggerEventPROXY_CHANGED")]
        public function get proxyURL():String
        {
            return _proxyURL;
        }
        
        protected function set proxyURL(value:String):void
        {
            _proxyURL = value;
            var type:String = TwitterLoggerEvent.PROXY_CHANGED;
            dispatchEvent(new TwitterLoggerEvent(type));
        }
        
        public function connect():void
        {
            if(!tokenCallbackDefined)
            {
                tokenCallbackDefined = true;
                ExternalInterface.addCallback(jsConfirm, confirmConnection);
            }
            
            var id:String = ExternalInterface.objectID;
            var url:String = public::connectorURL;
            var name:String = jsWindowName;
            var props:String = "width=790,height=370";
            var js:String = ''
                + 'if(!window.' + jsConfirm + '){'
                + '    window.' + jsConfirm + ' = function(){'
                + '        var flash = document.getElementById("' + id + '");'
                + '        flash.' + jsConfirm + '();'
                + '    }'
                + '};'
                + 'window.open("' + url + '", "' + name + '", "' + props + '");'
                
            ExternalInterface.call("function(){" + js + "}");
        }
        
        protected function testAvailability():void
        {
            if(!ExternalInterface.available)
                throw new Error("ExternalInterface is not available!");
            if(!ExternalInterface.objectID)
                throw new Error("ExternalInterface.objectID is not defined!");
        }
        
        public function confirmConnection(... rest):void
        {
            protected::connected = true;
        }
        
        override protected function addLoader(name:String, 
            completeHandler:Function):void
        {
            var loader:TwitterProxyLoader = 
                new TwitterProxyLoader(public::proxyURL);
            loader.addEventListener(Event.COMPLETE, completeHandler);
            loader.addEventListener(Event.COMPLETE, universalCompleteHandler);
            loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, 
                errorHandler);
            loaders[name] = loader;
        }
        
        protected function universalCompleteHandler(event:Event):void
        {
            var type:String = TwitterLoggerEvent.CALL_COMPLETE;
            var loader:TwitterProxyLoader = TwitterProxyLoader(event.target);
            var data:Object = loader.data;
            dispatchEvent(new TwitterLoggerEvent(type, false, false, data));
        }
    }
}