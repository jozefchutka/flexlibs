package sk.yoz.data.badgerfish
{

    public class BadgerFishDecoderXML extends BadgerFishDecoder
    {
        private var namespaces:Object = {};
        
        public function BadgerFishDecoderXML()
        {
            super();
        }
        
        override public function decode(source:BadgerFish, 
            constructor:Class=null, config:BadgerFishDecoderConfig=null):Object
        {
            var result:XML = decodeInternal(source, constructor, config) as XML;
            return result.children()[0];
        }
        
        protected function decodeInternal(source:BadgerFish, 
            constructor:Class=null, config:BadgerFishDecoderConfig=null):Object
        {
            var currentConfig:BadgerFishDecoderConfig = getConfig(source, config);
            var result:XML = new XML(<badgerfish />);
            return decodeProperties(source, currentConfig, result);
        }
        
        override protected function getConfig(source:Object, 
            config:BadgerFishDecoderConfig):BadgerFishDecoderConfig
        {
            return BadgerFishDecoderConfig.on(source, true);
        }
        
        override protected function decodeProperty(source:BadgerFish, 
            config:BadgerFishDecoderConfig, name:String, result:Object):Object
        {
            var xml:XML = result as XML;
            var value:Object = source[name];
            
            if(name == BadgerFish.XMLNS)
                return decodeNamespaces(value, xml);
            if(name.indexOf("@") == 0)
                return decodeAttribute(name, value, xml);
            
            var property:String = getPropertyName(name);
            if(property == "$")
            {
                xml.appendChild(value);
                return result;
            }
            
            if(value is Array)
                return arrayToXML(name, value as Array, config, xml);
            
            var currentConfig:BadgerFishDecoderConfig;
            currentConfig = getPropertyConfig(name, config);
            xml[property] = decodeXML(name, value, config, currentConfig, xml);
            if(xml[property][0] is XML)
                renameElement(xml[property][0], name);
            return xml;
        }
        
        protected function decodeNamespaces(source:Object, result:XML):XML
        {
            var ns:Namespace;
            for(var name:String in source)
            {
                ns = new Namespace(name == "$" ? "" : name, source[name]);
                if(name == "$")
                {
                    result.setNamespace(ns);
                }
                else
                {
                    result.addNamespace(ns);
                    namespaces[name] = ns;
                }
            }
            return result;
        }
        
        protected function decodeAttribute(name:String, value:Object, 
            result:XML):XML
        {
            var attribute:String = name.substr(1);
            result.@[attribute] = value;
            return result;
        }
        
        protected function decodeXML(name:String, value:Object, 
            config:BadgerFishDecoderConfig, 
            currentConfig:BadgerFishDecoderConfig = null, result:XML = null)
            :Object
        {
            var badgerfish:BadgerFish = value as BadgerFish;
            result = decodeInternal(badgerfish, null, currentConfig || config) as XML;
            if(result)
                renameElement(result, name);
            return result;
        }
        
        protected function renameElement(result:XML, name:String):void
        {
            var index:int = name.indexOf(":");
            result.setName(name.substr(index + 1));
            if(index > -1)
            {
                var prefix:String = name.substr(0, index);
                var ns:Namespace = result.namespace(prefix) || namespaces[prefix];
                result.setNamespace(ns);
            }
        }
        
        protected function arrayToXML(name:String, a:Array, 
            config:BadgerFishDecoderConfig, result:XML):XML
        {
            var length:int = a.length;
            for(var i:int = 0; i < length; i++)
                result.appendChild(decodeXML(name, a[i], config))
            return result;
        }
    }
}