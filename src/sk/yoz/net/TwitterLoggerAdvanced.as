package sk.yoz.net
{
    import com.twitter.api.events.TwitterEvent;
    
    import flash.events.Event;
    import flash.net.URLRequest;
    import flash.net.URLVariables;
    
    import sk.yoz.events.TwitterLoggerAdvancedEvent;
    
    public class TwitterLoggerAdvanced extends TwitterLogger
    {
        protected var _rawProxyURL:String;
        protected var _variables:URLVariables;
        
        public function TwitterLoggerAdvanced(connectorURL:String, 
            proxyURL:String, rawProxyURL:String)
        {
            super(connectorURL, proxyURL);
            
            protected::rawProxyURL = rawProxyURL;
        }
        
        public function get rawProxyURL():String
        {
            return _rawProxyURL;
        }
        
        protected function set rawProxyURL(value:String):void
        {
            _rawProxyURL = value;
        }
        
        public function call(method:Function, argArray:Array, 
            useRawProxy:Boolean = true, variables:URLVariables = null):void
        {
            _variables = variables;
            if(useRawProxy)
                changeLoaders(public::rawProxyURL);
            method.apply(this, argArray);
            if(useRawProxy)
                changeLoaders(public::proxyURL);
            _variables = null;
        }
        
        protected function changeLoaders(url:String):void
        {
            for each(var loader:TwitterProxyLoader in loaders)
                loader.proxyURL = url;
        }
        
        override protected function twitterRequest(url:String):URLRequest
        {
            var request:URLRequest = super.twitterRequest(url);
            if(_variables)
            {
                var data:Object = request.data || new URLVariables();
                for(var key:String in _variables)
                    data[key] = _variables[key];
                request.data = data;
            }
            
            return request;
        }
        
        override protected function universalCompleteHandler(event:Event):void
        {
            super.universalCompleteHandler(event);
            
            var loader:TwitterProxyLoader = TwitterProxyLoader(event.target);
            try
            {
                var data:XML = XML(loader.data);
                var errorString:String = data.error.toString();
                if(errorString)
                    dispatchEvent(new TwitterLoggerAdvancedEvent(
                        TwitterLoggerAdvancedEvent.AUTHENTICATION_ERROR,
                        false, false, errorString));
            }
            catch(error:Error){}
        }
    }
}