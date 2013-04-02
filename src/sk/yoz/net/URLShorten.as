package sk.yoz.net
{
    import com.adobe.serialization.json.JSON;
    
    import flash.events.Event;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    
    import sk.yoz.events.URLShortenEvent;
    
    public class URLShorten extends Object
    {
        public function URLShorten()
        {
            super();
        }
        
        private static function prepare(request:URLRequest, 
            data:Object, callback:Function, completeHandler:Function=null)
            :URLLoaderDynamic
        {
            var loader:URLLoaderDynamic = new URLLoaderDynamic();
            var handler:Function = completeHandler || complete;
            
            request.data = data;
            loader.callback = callback;
            loader.load(request);
            loader.addEventListener(Event.COMPLETE, handler);
            return loader;
        }
        
        private static function complete(event:Event):void
        {
            var loader:URLLoaderDynamic = URLLoaderDynamic(event.target);
            var url:String = String(loader.data);
            
            loader.removeEventListener(Event.COMPLETE, complete);
            dispatch(url, loader)
        }
        
        private static function dispatch(url:String, loader:URLLoaderDynamic)
            :void
        {
            var callback:Function = loader.callback;
            var type:String = URLShortenEvent.COMPLETE;
            
            if(callback != null)
                callback(url);
            loader.dispatchEvent(new URLShortenEvent(type, false, false, url));
        }
        
        public static function jdemcz(longUrl:String, callback:Function=null)
            :URLLoaderDynamic
        {
            var apiUrl:String = "http://www.jdem.cz/get";
            var request:URLRequest = new URLRequest(apiUrl);
            var variables:URLVariables = new URLVariables();
            
            variables.url = longUrl;
            return prepare(request, variables, callback);
        }
        
        public static function tinyurlcom(longUrl:String, 
            callback:Function=null):URLLoaderDynamic
        {
            var apiUrl:String = "http://tinyurl.com/api-create.php";
            var request:URLRequest = new URLRequest(apiUrl);
            var variables:URLVariables = new URLVariables();
            
            variables.url = longUrl;
            return prepare(request, variables, callback);
        }
        
        public static function bitly(longUrl:String, login:String, 
            apiKey:String, version:String="2.0.1", callback:Function=null)
            :URLLoaderDynamic
        {
            var apiUrl:String = "http://api.bit.ly/shorten";
            var request:URLRequest = new URLRequest(apiUrl);
            var variables:URLVariables = new URLVariables();
            
            variables.version = version;
            variables.longUrl = longUrl;
            variables.login = login;
            variables.apiKey = apiKey;
            return prepare(request, variables, callback, bitlyComplete);
        }
        
        private static function bitlyComplete(event:Event):void
        {
            var loader:URLLoaderDynamic = URLLoaderDynamic(event.target);
            var result:String = String(loader.data);
            var data:Object = JSON.decode(result);
            var url:String;
            
            loader.removeEventListener(Event.COMPLETE, bitlyComplete);
            for each(var resultItem:Object in data.results)
                url = resultItem.shortUrl;
            dispatch(url, loader);
        }
        
        public static function trim(longUrl:String, 
            callback:Function=null):URLLoaderDynamic
        {
            var apiUrl:String = "http://api.tr.im/v1/trim_simple";
            var request:URLRequest = new URLRequest(apiUrl);
            var variables:URLVariables = new URLVariables();
            
            variables.url = longUrl;
            return prepare(request, variables, callback);
        }
        
        public static function isgd(longUrl:String, 
            callback:Function=null):URLLoaderDynamic
        {
            var apiUrl:String = "http://is.gd/api.php";
            var request:URLRequest = new URLRequest(apiUrl);
            var variables:URLVariables = new URLVariables();
            
            variables.longurl = longUrl;
            return prepare(request, variables, callback);
        }
        
        public static function googl(longUrl:String,
            callback:Function=null):URLLoaderDynamic
        {
            var apiUrl:String = 
                "https://www.googleapis.com/urlshortener/v1/url";
            var request:URLRequest = new URLRequest(apiUrl);
            var data:String = '{"longUrl": "' + longUrl + '"}';
            
            request.method = URLRequestMethod.POST;
            request.contentType = "application/json";
            return prepare(request, data, callback, googlComplete);
        }
        
        private static function googlComplete(event:Event):void
        {
            var loader:URLLoaderDynamic = URLLoaderDynamic(event.target);
            var result:String = String(loader.data);
            var data:Object = JSON.decode(result);
            var url:String = data.id;
            
            loader.removeEventListener(Event.COMPLETE, googlComplete);
            dispatch(url, loader);
        }
    }
}