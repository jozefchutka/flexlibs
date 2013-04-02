package sk.yoz.net
{
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;

    public class TwitterProxyLoader extends URLLoader
    {
        public var proxyURL:String;
        
        public function TwitterProxyLoader(proxyURL:String)
        {
            super();
            
            this.proxyURL = proxyURL;
        }
        
        override public function load(request:URLRequest):void
        {
            var proxy:URLRequest = new URLRequest();
            
            var data:Object = request.data || new URLVariables();
            data.url = request.url.replace(
                "http\:\/\/twitter\.com", "http://api.twitter.com/1");
            data.method = request.method;
            
            proxy.data = data;
            proxy.url = proxyURL;
            proxy.method = URLRequestMethod.POST;
            super.load(proxy);
        }
    }
}