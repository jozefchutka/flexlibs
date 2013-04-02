package sk.yoz.html
{
    import flash.display.LoaderInfo;
    import flash.net.URLVariables;
    
    public class EmbedCode extends Object
    {
        private var _params:Object = {};
        private var _flashVars:URLVariables;
        private var _width:uint;
        private var _height:uint;
        private var _url:String;
        
        private var loaderInfo:LoaderInfo;
        private var parameters:Object;
        
        public var encodeAmpersands:Boolean = false;
        
        public function EmbedCode(loaderInfo:LoaderInfo = null, parameters:Object = null)
        {
            super();
            this.loaderInfo = loaderInfo;
            this.parameters = parameters;
            
            useActualURL();
            useActualFlashVars();
        }
        
        public static function suggest(loaderInfo:LoaderInfo = null, parameters:Object = null, 
            encodeAmpersands:Boolean = false):EmbedCode
        {
            var embedCode:EmbedCode = new EmbedCode(loaderInfo, parameters);
            embedCode.encodeAmpersands = encodeAmpersands;
            embedCode.useActualURL();
            embedCode.useActualSize();
            embedCode.useActualFlashVars();
            return embedCode;
        }
        
        public static function containsProtocol(path:String):Boolean
        {
            return path.indexOf("http://") == 0 || path.indexOf("https://") == 0;
        }
        
        public static function urlToDomain(url:String):String
        {
            if(!containsProtocol(url))
                return null;
            var index:int = url.indexOf("/", 9);
            if(index == -1)
                return null;
            return url.substr(0, index);
        }
        
        public function get domain():String
        {
            return urlToDomain(url);
        }
        
        public function addParam(param:String, value:String):void
        {
            _params[param] = value;
        }
        
        public function set params(value:Object):void
        {
            _params = value;
        }
        
        public function get params():Object
        {
            return _params;
        }
        
        public function addFlashVar(variable:String, value:String):void
        {
            if(!flashVars)
                flashVars = new URLVariables();
            _flashVars[variable] = value;
        }
        
        public function set flashVars(value:URLVariables):void
        {
            _flashVars = value;
        }
        
        public function get flashVars():URLVariables
        {
            return _flashVars;
        }
        
        public function get flashVarsQueryString():String
        {
            var queryString:String = flashVars.toString();
            if(encodeAmpersands)
                queryString = queryString.replace(/\&/g, "&amp;");
            return queryString;
        }
        
        public function set width(value:uint):void
        {
            _width = value;
        }
        
        public function get width():uint
        {
            return _width;
        }
        
        public function set height(value:uint):void
        {
            _height = value;
        }
        
        public function get height():uint
        {
            return _height;
        }
        
        public function set url(value:String):void
        {
            _url = value;
        }
        
        public function get url():String
        {
            return _url;
        }
        
        public function toString():String
        {
            var key:String;
            var r:String = '';
            r += '<object width="' + width + '" height="' + height + '">';
            
            r += '<param name="movie" value="' + url + '"></param>';
            for(key in params)
                r += '<param name="' + key + '" value="' + params[key] + '"></param>';
            if(flashVars)
                r += '<param name="FlashVars" value="' + flashVarsQueryString + '"></param>';
                
            r += '<embed src="' + url + '" width="' + width + '" height="' + height + '" type="application/x-shockwave-flash"';
            for(key in params)
                r += ' ' + key + '="' + params[key] + '" ';
            if(flashVars)
                r += ' FlashVars="' + flashVarsQueryString + '" ';
            r += '></embed>';
            
            r += '</object>';
            return r;
        }
        
        public function useActualURL():void
        {
            if(!loaderInfo)
                return;
            url = loaderInfo.url;
        }
        
        public function useActualSize():void
        {
            if(!loaderInfo)
                return;
            width = loaderInfo.width;
            height = loaderInfo.height;
        }
        
        public function useActualFlashVars():void
        {
            flashVars = new URLVariables();
            if(!parameters)
                return;
            for(var key:String in parameters)
                addFlashVar(key, parameters[key]);
        }
    }
}