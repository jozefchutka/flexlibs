package sk.yoz.data
{
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.utils.getDefinitionByName;
    
    /**
     * XMLSkin class makes runtime settings/skinning easy
     * get latest version and examples on:
     * http://blog.yoz.sk/2009/10/xml-skin/
     * updated: 2010-03-07
     */
    
    public class XMLSkin extends Object
    {
        protected var assets:Object;
        protected var assetsSource:String;
        protected var root:Object;
        protected var skin:XML;
        protected var autoApply:Boolean;
        protected var loader:Loader;
        
        public function XMLSkin(root:Object, skin:XML)
        {
            super();
            this.root = root;
            this.skin = skin;
        }
        
        public function apply():void
        {
            XMLSkin.apply(root, skin, loader);
        }
        
        public static function apply(root:Object, skin:XML, 
            assetsLoader:Loader = null):void
        {
            if(!skin)
                return;
            for each(var a:XML in skin.@*)
                doApply(root, a.name(), a.toString(), assetsLoader);
            var children:XMLList = skin.children();
                
            if(!children.length())
                return;
            var childName:String;
            for each(var child:XML in children)
            {
                childName = child.name();
                if(!childName)
                    continue;
                if(child.text().toString())
                    doApply(root, childName, child.text().toString(), 
                        assetsLoader);
                if(root.hasOwnProperty(childName))
                    XMLSkin.apply(root[childName], child, assetsLoader);
                else if(getDefinitionByName(childName))
                    XMLSkin.apply(getDefinitionByName(childName), child, 
                        assetsLoader);
            }
        }
        
        protected static function doApply(root:Object, attribute:String, 
            value:String, assetsLoader:Loader = null):void
        {
            var name:String = attributeToName(attribute);
            if(isStyle(attribute))
                root.setStyle(name, castStyle(root, value, attribute, 
                    assetsLoader));
            else if(root.hasOwnProperty(name))
                root[name] = castProperty(root, value, attribute, assetsLoader);
        }
        
        protected static function castProperty(object:Object, value:String, 
            attribute:String, assetsLoader:Loader = null):*
        {
            var name:String = attributeToName(attribute);
            switch(typeof object[name])
            {
                case "boolean":
                    return Boolean(value.toLowerCase() == "true");
                case "number":
                case "string":
                    return value;
                default:
                    return getClassFromLibrary(value, assetsLoader)
                        || getClassFromAssets(value, assetsLoader)
                        || value;
            }
        }
        
        protected static function castStyle(object:Object, value:String, 
            attribute:String, assetsLoader:Loader = null):*
        {
            var name:String = attributeToName(attribute);
            if(!assetsLoader && isAsset(attribute))
                return null;
            if(isAsset(attribute))
                return getClassFromLibrary(value, assetsLoader)
                    || getClassFromAssets(value, assetsLoader);
            return value;
        }
        
        protected static function getClassFromLibrary(value:String, 
            assetsLoader:Loader):Class
        {
            var assetClass:Class;
            try
            {
                assetClass = getDefinitionByName(value) as Class;
            }
            catch(error:Error){}
            return assetClass;
        }
        
        protected static function getClassFromAssets(value:String, 
            assetsLoader:Loader):Class
        {
            var assetClass:Class;
            try
            {
                var applicationDomain:ApplicationDomain = 
                    assetsLoader.contentLoaderInfo.applicationDomain;
                var assetsClass:Class = 
                    applicationDomain.getDefinition("Assets") as Class;
                assetClass = assetsClass[value];
            }
            catch(error:Error){}
            return assetClass;
        }
        
        public function loadAssets(assetsSource:String):Loader
        {
            this.assetsSource = assetsSource;
            loader = new Loader();
            
            var info:LoaderInfo = loader.contentLoaderInfo;
            info.addEventListener(Event.COMPLETE, assetsComplete, false, 
                int.MAX_VALUE);
            info.addEventListener(IOErrorEvent.IO_ERROR, assetsIOError, false, 
                int.MAX_VALUE);
            info.addEventListener(SecurityErrorEvent.SECURITY_ERROR, 
                assetsSecurityError, false, int.MAX_VALUE);
            
            var request:URLRequest = new URLRequest(assetsSource);
            var context:LoaderContext = new LoaderContext(false, 
                ApplicationDomain.currentDomain);
            loader.load(request, context);
            return loader;
        }
        
        protected function assetsComplete(event:Event):void
        {
            apply();
        }
        
        protected function assetsIOError(event:IOErrorEvent):void
        {
        }
        
        protected function assetsSecurityError(event:SecurityErrorEvent):void
        {
        }
        
        protected static function isStyle(attribute:String):Boolean
        {
            attribute = stripAsset(attribute);
            return attribute.toLowerCase().substr(0, 6) == "style.";
        }
        
        protected static function stripStyle(attribute:String):String
        {
            if(isStyle(attribute))
                return attribute.substr(6);
            return attribute;
        }
        
        protected static function isAsset(attribute:String):Boolean
        {
            return attribute.toLowerCase().substr(0, 6) == "asset.";
        }
        
        protected static function stripAsset(attribute:String):String
        {
            if(isAsset(attribute))
                return attribute.substr(6);
            return attribute;
        }
        
        public static function attributeToName(attribute:String):String
        {
            return stripStyle(stripAsset(attribute));
        }
    }
}