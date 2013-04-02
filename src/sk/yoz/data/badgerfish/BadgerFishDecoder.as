package sk.yoz.data.badgerfish
{
    public class BadgerFishDecoder
    {
        public function decode(source:BadgerFish, constructor:Class=null,
            config:BadgerFishDecoderConfig=null):Object
        {
            return null;
        }
        
        protected function get tryConfigProperties():Boolean
        {
            return true;
        }
        
        protected function decodeProperties(source:BadgerFish,
            config:BadgerFishDecoderConfig, result:Object):Object
        {
            var name:String;
            if(tryConfigProperties && config.includeProperties)
            {
                if(source.hasOwnProperty(BadgerFish.XMLNS) 
                    && config.includeProperties.indexOf(BadgerFish.XMLNS) >= 0)
                    result = decodeProperty(source, config, BadgerFish.XMLNS, result);
                for each(name in config.includeProperties)
                    if(allowDecoding(name))
                        result = decodeProperty(source, config, name, result);
                return result;
            }
            else
            {
                if(source.hasOwnProperty(BadgerFish.XMLNS))
                    result = decodeProperty(source, config, BadgerFish.XMLNS, result);
                for(name in source)
                    if(allowDecoding(name))
                        result = decodeProperty(source, config, name, result);
                return result;
            }
        }
        
        protected function allowDecoding(name:String):Boolean
        {
            return name != BadgerFish.XMLNS;
        }
        
        protected function decodeProperty(source:BadgerFish, 
            config:BadgerFishDecoderConfig, name:String, result:Object):Object
        {
            return null;
        }
        
        protected function getConfig(source:Object, 
            config:BadgerFishDecoderConfig):BadgerFishDecoderConfig
        {
            return config || new BadgerFishDecoderConfig;
        }
        
        protected function getPropertyConfig(name:String, 
            config:BadgerFishDecoderConfig):BadgerFishDecoderConfig
        {
            return config.properties[name];
        }
        
        protected function getPropertyName(name:String):String
        {
            var result:String = name;
            var index:int;
            
            index = result.indexOf("@");
            if(index == 0)
                result = result.substr(index + 1);
            
            index = result.indexOf(":");
            if(index >= 0)
                result = result.substr(index + 1);
            
            return result;
        }
    }
}