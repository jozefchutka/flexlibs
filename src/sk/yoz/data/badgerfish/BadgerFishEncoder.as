package sk.yoz.data.badgerfish
{
    import flash.utils.describeType;
    
    import mx.collections.ArrayCollection;

    public class BadgerFishEncoder
    {
        public function encode(source:Object, 
            config:BadgerFishEncoderConfig=null):Object
        {
            var badgerfish:BadgerFish = construct(source);
            var result:Object;
            config = getConfig(source, config);
            
            if(source is XML)
            {
                var name:String = getXMLPropertyName(source as XML);
                result = construct(source);
                result[name] = encodeXML(source as XML, badgerfish);
            }
            else if(source is Array)
                result = encodeArray(source as Array, config);
            else if(source is ArrayCollection)
                result = encodeArray(source.source, config);
            else if(isPrimitive(source))
                result = encodePrimitive(source, config);
            else if(source)
                result = encodeObject(source, badgerfish, config);
            else 
                result = badgerfish;
            
            badgerfish = result as BadgerFish;
            if(!badgerfish)
                return result;
                
            copyDecoderConfig(source, badgerfish);
            encodeConfigNamespaces(badgerfish, config);
            encodeConfigAttributes(badgerfish, config);
            return badgerfish;
        }
        
        protected function construct(source:Object):BadgerFish
        {
            return new BadgerFish;
        }
        
        protected function isPrimitive(value:Object):Boolean
        {
            return value is String
                || value is Boolean
                || value is Number
                || value is uint
                || value is int;
        }
        
        protected function copyDecoderConfig(source:Object, 
            result:BadgerFish):void
        {
            var config:BadgerFishDecoderConfig = 
                BadgerFishDecoderConfig.on(source)
                || BadgerFishDecoderConfig.onConstructor(source)
            
            addDecoderConfig(result, config);
        }
        
        protected function addDecoderConfig(result:BadgerFish, 
            config:BadgerFishDecoderConfig):void
        {
            if(!config)
                return;
            
            result.badgerfishinternal::decoderConfig = config;
        }
        
        protected function getConfig(source:Object,
            config:BadgerFishEncoderConfig):BadgerFishEncoderConfig
        {
            return BadgerFishEncoderConfig.on(source)
                || BadgerFishEncoderConfig.onConstructor(source)
                || config;
        }
        
        protected function getPropertyName(type:String, name:String, 
            config:BadgerFishEncoderConfig):String
        {
            var forcedName:String = name;
            var prefix:String = (config && config.namespace) 
                ? config.namespace + ":" : "";
            return prefix + forcedName;
        }
        
        private function getXMLPropertyName(source:XML):String
        {
            var name:String = source.localName();
            var ns:Namespace = source.namespace();
            var prefix:String = (ns && ns.prefix) ? ns.prefix + ":" : "";
            return prefix + name;
        }
        
        protected function encodeXML(source:XML, result:BadgerFish):BadgerFish
        {
            var ns:Namespace;
            var name:String = getXMLPropertyName(source);
            var config:BadgerFishDecoderConfig = new BadgerFishDecoderConfig([]);
            
            if(!config.includeProperties)
                config.includeProperties = [];
            
            var namespaces:Array = source.namespaceDeclarations();
            for each(ns in namespaces)
                encodeNamespace(result, ns);
            if(namespaces && namespaces.length)
                config.includeProperties.push(BadgerFish.XMLNS);
            
            var attributes:XMLList = source.attributes();
            for each(var attribute:XML in attributes)
            {
                name = "@" + getXMLPropertyName(attribute);
                result[name] = attribute.toString();
                config.includeProperties.push(name);
            }
            
            var elements:XMLList = source.elements();
            for each(var element:XML in elements)
            {
                var child:BadgerFish = construct(element);
                name = getXMLPropertyName(element);
                
                if(result.hasOwnProperty(name))
                {
                    if(!(result[name] is Array))
                    {
                        var bf:BadgerFish = result[name];
                        result[name] = [];
                        result[name].push(bf);
                    }
                    
                    bf = encodeXML(element, construct(element));
                    result[name].push(bf);
                }
                else
                {
                    result[name] = encodeXML(element, child);
                    config.includeProperties.push(name);
                }
            }
            
            if(source.hasSimpleContent())
            {
                var value:String = source;
                if(value != "")
                    result["$"] = value;
            }
            else
            {
                addDecoderConfig(result, config);
            }
            
            return result;
        }
        
        protected function encodeObject(source:Object, result:BadgerFish,
            config:BadgerFishEncoderConfig=null):BadgerFish
        {
            var description:XML = describeType(source);
            encodeObjectDynamics(source, result, config, description);
            encodeObjectVariables(source, result, config, description);
            encodeObjectAccessors(source, result, config, description);
            return result;
        }
        
        private function encodeObjectDynamics(source:Object, result:BadgerFish, 
            config:BadgerFishEncoderConfig, description:XML):void
        {
            var name:String, type:String, value:Object;
            var currentConfig:BadgerFishEncoderConfig;
            if(description.@isDynamic != "true")
                return;
            
            for(name in source)
            {
                if(!includeObjectProperty(source, name))
                    continue;
                type = typeof source[name];
                value = source[name];
                currentConfig = getConfig(value, config ? config.properties[name] : null);
                assign(result, source, name, type, currentConfig);
            }
        }
        
        protected function includeObjectProperty(source:Object, property:String)
            :Boolean
        {
            return true;
        }
        
        protected function assign(result:BadgerFish, source:Object, name:String, 
            type:String, config:BadgerFishEncoderConfig):void
        {
            var propertyName:String = getPropertyName(type, name, config);
            var value:Object = source[name];
            if(propertyName.indexOf("@") == 0)
                result[propertyName] = value.toString();
            else
                result[propertyName] = encode(value, config);
        }
        
        private function encodeObjectVariables(source:Object, result:BadgerFish, 
            config:BadgerFishEncoderConfig, description:XML):void
        {
            var name:String, type:String, value:Object;
            var currentConfig:BadgerFishEncoderConfig;
            for each(var variable:XML in description.variable)
            {
                name = variable.@name;
                if(!includeObjectProperty(source, name))
                    continue;
                
                type = variable.@type;
                try
                {
                    value = source[name];
                }
                catch(error:Error)
                {
                    continue;
                }
                
                currentConfig = getConfig(value, config ? config.properties[name] : null);
                assign(result, source, name, type, currentConfig);
            }
        }
        
        private function encodeObjectAccessors(source:Object, result:BadgerFish,
            config:BadgerFishEncoderConfig, description:XML):void
        {
            var name:String, type:String, value:Object;
            var currentConfig:BadgerFishEncoderConfig;
            for each(var variable:XML in description.accessor)
            {
                if(variable.@access != "readonly" 
                    && variable.@access != "readwrite")
                    continue;
                
                name = variable.@name;
                if(!includeObjectProperty(source, name))
                    continue;
                
                type = variable.@type;
                value = source[name];
                currentConfig = getConfig(value, config ? config.properties[name] : null);
                assign(result, source, name, type, currentConfig);
            }
        }
        
        private function encodeNamespace(result:BadgerFish, 
            namespace:Namespace):void
        {
            if(!result.hasOwnProperty(BadgerFish.XMLNS))
                result[BadgerFish.XMLNS] = new BadgerFish;
            
            result[BadgerFish.XMLNS][namespace.prefix || "$"] = namespace.uri;
        }
        
        private function encodeConfigNamespaces(result:BadgerFish, 
            config:BadgerFishEncoderConfig):void
        {
            if(!config || !config.namespaces.length)
                return;
            
            for each(var namespace:Namespace in config.namespaces)
                encodeNamespace(result, namespace);
        }
        
        
        private function encodeConfigAttributes(result:BadgerFish, 
            config:BadgerFishEncoderConfig):void
        {
            if(!config)
                return;
            
            var name:String, value:Object;
            for(name in config.attributes)
            {
                value = config.attributes[name];
                result[name] = value;
            }
        }
        
        private function encodeArray(source:Array, 
            config:BadgerFishEncoderConfig):Array
        {
            var result:Array = [];
            for each(var data:Object in source)
                result.push(encode(data, config));
            return result;
        }
        
        protected function encodePrimitive(source:Object, 
            config:BadgerFishEncoderConfig):Object
        {
            var result:BadgerFish = construct(source);
            if(source != null)
                result["$"] = source.toString();
            
            return result;
        }
    }
}