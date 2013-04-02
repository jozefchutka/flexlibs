package sk.yoz.data.badgerfish
{
    import flash.utils.describeType;
    import flash.utils.getDefinitionByName;
    
    import mx.collections.ArrayCollection;

    public class BadgerFishDecoderObject extends BadgerFishDecoder
    {
        override public function decode(source:BadgerFish, constructor:Class=null,
            config:BadgerFishDecoderConfig=null):Object
        {
            var result:Object = constructor ? construct(constructor, source) : {};
            var currentConfig:BadgerFishDecoderConfig = getConfig(result, config);
            return decodeProperties(source, currentConfig, result);
        }
        
        protected function construct(constructor:Class, source:BadgerFish):Object
        {
            return new constructor;
        }
        
        override protected function get tryConfigProperties():Boolean
        {
            return false;
        }
        
        override protected function decodeProperty(source:BadgerFish, 
            config:BadgerFishDecoderConfig, name:String, result:Object):Object
        {
            var property:String = getPropertyName(name);
            if(!includeProperty(result, property))
                return result;
            
            if(property == "$")
                return castProperty(source["$"], Object(result).constructor);
            
            if(result.hasOwnProperty(property))
            {
                var type:String = getTargetPropertyType(result, property);
                if(type == "Array")
                {
                    result[property] = [];
                    value = source[name];
                    if(!(value is Array))
                        value = [value];
                    convertToObject(name, value, config, null, result[property]);
                    return result;
                }
                
                if(type == "mx.collections::ArrayCollection")
                {
                    result[property] = new ArrayCollection;
                    value = source[name];
                    if(!(value is Array))
                        value = [value];
                    convertToObject(name, value, config, null, result[property]);
                    return result;
                }
            }
            
            var currentConfig:BadgerFishDecoderConfig = getPropertyConfig(name, config);
            var value:Object = convertToObject(name, source[name], config, currentConfig, result);
            if(value != null)
                assignValue(result, property, value);
            return result;
        }
        
        protected function assignValue(result:Object, property:String, value:Object):void
        {
            result[property] = value;
        }
        
        protected function castProperty(value:Object, constructor:Class):Object
        {
            if(constructor == Boolean)
                return value == "true";
            if(constructor == Number)
                return Number(value);
            if(constructor == int)
                return int(value);
            if(constructor == uint)
                return uint(value);
            return value.toString();
        }
        
        protected function includeProperty(result:Object, property:String):Boolean
        {
            return property != "xmlns";
        }
        
        protected function convertToObject(name:String, value:Object, 
            config:BadgerFishDecoderConfig, 
            currentConfig:BadgerFishDecoderConfig = null, result:Object = null):Object
        {
            if(value.hasOwnProperty("$") 
                && !BadgerFish(value).getAttributes().length)
                value = value["$"];
            
            if(value is Array)
                return arrayToObject(name, value as Array, config, result);
            
            var constructor:Class;
            var property:String = getPropertyName(name);
            if(isPrimitive(typeof value))
            {
                constructor = getConstructor(property, result, currentConfig || config);
                return castProperty(value, constructor);
            }
            
            var badgerfish:BadgerFish = value as BadgerFish;
            if(hasContent(badgerfish))
            {
                constructor = getConstructor(property, result, config, badgerfish);
                return decode(badgerfish, constructor, currentConfig || config);
            }
            return null;
        }
        
        protected function hasContent(badgerfish:BadgerFish):Boolean
        {
            return badgerfish && badgerfish.getFirstChild()
        }
        
        protected function isPrimitive(type:String):Boolean
        {
            return type == "boolean" 
                || type == "number" 
                || type == "string";
        }
        
        override protected function getConfig(source:Object, 
            config:BadgerFishDecoderConfig):BadgerFishDecoderConfig
        {
            return BadgerFishDecoderConfig.onConstructor(source, true);
        }
        
        protected function arrayToObject(name:String, a:Array, 
            config:BadgerFishDecoderConfig, result:Object):Object
        {
            var length:int = a.length;
            var i:int;
            if(result is Array)
                for(i = 0; i < length; i++)
                    result.push(convertToObject(name, a[i], config));
            else if(result is ArrayCollection)
                for(i = 0; i < length; i++)
                    result.addItem(convertToObject(name, a[i], config));
            return result;
        }
        
        protected function getConstructor(property:String, result:Object, 
            config:BadgerFishDecoderConfig=null, source:BadgerFish=null):Class
        {
            if(result)
            {
                var type:String = getTargetPropertyType(result, property);
                var constructor:Class = getDefinitionByName(type) as Class;
                if(constructor)
                    return constructor;
            }
            if(config && config.classMap && config.classMap.hasOwnProperty(property))
                return config.classMap[property];
            return Object;
        }
        
        override protected function getPropertyConfig(name:String, 
            config:BadgerFishDecoderConfig):BadgerFishDecoderConfig
        {
            var currentConfig:BadgerFishDecoderConfig;
            if(config && config.classMap && config.classMap.hasOwnProperty(name))
                currentConfig = BadgerFishDecoderConfig.on(config.classMap[name]);
            
            return currentConfig 
                || super.getPropertyConfig(name, config) 
                || new BadgerFishDecoderConfig;
        }
        
        protected function getTargetPropertyType(target:Object, 
            property:String):String
        {
            if(!target.hasOwnProperty(property))
                return null;
            
            var constructor:Class = Object(target).constructor;
            var description:XML = describeType(constructor);
            var variable:XMLList = description.factory.variable.(@name==property).@type;
            var accessor:XMLList = description.factory.accessor.(@name==property).@type;
            return String(variable.length() ? variable : accessor);
        }
    }
}