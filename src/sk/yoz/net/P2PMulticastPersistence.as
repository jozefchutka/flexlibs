package sk.yoz.net
{
    import com.adobe.crypto.MD5;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.utils.ByteArray;
    
    import sk.yoz.Log;
    import sk.yoz.events.P2PMulticastPersistenceEvent;
    
    public class P2PMulticastPersistence extends EventDispatcher implements IP2PMulticastPersistence
    {
        private var signSalt:String = "StratusIsCoool";
        
        private var loader:URLLoader = new URLLoader();
        public var scriptURL:String = "";   // http://mydomain/script.php? or ...
                                            // http://mydomain/script.php?id=123
                                            // "&sign={HASH}" is added
        
        public var debug:Boolean = false;
        private var log:Log = Log.instance;
        
        public function P2PMulticastPersistence(scriptURL:String, signSalt:String = "")
        {
            super();
            this.scriptURL = scriptURL;
            this.signSalt = signSalt;
            loader.addEventListener(Event.COMPLETE, loaderComplete);
            loader.addEventListener(Event.OPEN, openHandler);
            loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        }
        
        public function saveClientList(list:Array):void
        {
            var data:String = listToMessage(list);
            var sign:String = signData(data);
            var request:URLRequest = new URLRequest(scriptURL + "&sign=" + sign);
            var saver:URLLoader = new URLLoader();
            request.contentType = "text/xml";
            request.data = data;
            request.method = URLRequestMethod.POST;
            saver.load(request);
        }
        
        public function getClientList():void
        {
            var request:URLRequest = new URLRequest(scriptURL);
            request.method = URLRequestMethod.GET;
            
            try {
                loader.load(request);
            } catch (error:Error) {
                if(debug)
                    log.write("P2PMulticastPersistence.getClientList() load() Error");
            }
        }
        
        private function loaderComplete(event:Event):void
        {
            var list:Array = messageToList(loader.data);
            dispatchEvent(new P2PMulticastPersistenceEvent(P2PMulticastPersistenceEvent.CLIENTS_DEFINED, true, true, {list:list}));
        }
        
        private function messageToList(message:String):Array
        {
            var xml:XML = XML(message);
            var list:Array = [];
            for each(var id:String in xml.client.@['id'])
                list.push(id);
            return list;
        }
        
        private function listToMessage(list:Array):String
        {
            var xml:XML = <clients />
            var xmlNode:XML;
            for each(var id:String in list)
            {
                xmlNode = <client />;
                xmlNode.@id = id;
                xml.appendChild(xmlNode);
            }
            return xml.toXMLString();
        }
        
        private function openHandler(event:Event):void
        {
            if(debug)
                log.write("P2PMulticastPersistence.openHandler(" + event.toString() + ")");
        }
        
        private function progressHandler(event:ProgressEvent):void
        {
            if(debug)
                log.write("P2PMulticastPersistence.progressHandler() " + 
                        "// loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
        }
        
        private function securityErrorHandler(event:SecurityErrorEvent):void
        {
            if(debug)
                log.write("P2PMulticastPersistence.securityErrorHandler(" + event.toString() + ")");
        }
        
        private function httpStatusHandler(event:HTTPStatusEvent):void
        {
            if(debug)
                log.write("P2PMulticastPersistence.httpStatusHandler(" + event.toString() + ")");
        }
        
        private function ioErrorHandler(event:IOErrorEvent):void
        {
            if(debug)
                log.write("P2PMulticastPersistence.ioErrorHandler(" + event.toString() + ")");
        }
        
        private function signData(data:String):String
        {
            return MD5.hash(signSalt + MD5.hash(data));
        }
    }
}