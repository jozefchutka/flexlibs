package sk.yoz.data.wsdl.testers
{
    import flash.utils.getQualifiedClassName;
    
    import sk.yoz.data.badgerfish.BadgerFish;
    import sk.yoz.data.badgerfish.BadgerFishDecoderConfig;
    import sk.yoz.data.wsdl.valueObjects.Property;
    
    public class BadgerFishTester extends WSDLTester
    {
        public static const LOG_TYPE_IGNORING_DECODER:uint = 1024;
        public static const LOG_TYPE_MISSING_DECODER_ON_SINGLE_PROPERTY:uint = 2048;
        public static const LOG_TYPE_EMPTY_DECODER_ON_SINGLE_PROPERTY:uint = 4096;
        
        private var ignoreDecoding:Array;
        
        public function BadgerFishTester(map:Object, mapLocal:Object, mapService:Object, ignoreDecoding:Array)
        {
            super(map, mapLocal, mapService);
            this.ignoreDecoding = ignoreDecoding;
        }
        
        override protected function compareProperties(constructor:Class, wsdlProperties:Vector.<Property>, constructorProperties:Vector.<Property>):Boolean
        {
            var result1:Boolean = super.compareProperties(constructor, wsdlProperties, constructorProperties);
            
            var orderedProperties:Vector.<Property> = orderProperties(constructor, constructorProperties);
            if(!orderedProperties)
                return false;
            
            var result2:Boolean = comparePropertiesCount(constructor, wsdlProperties, orderedProperties);
            var result3:Boolean = comparePropertiesOrder(constructor, wsdlProperties, orderedProperties);
            return result1 && result2 && result3;
        }
        
        private function orderProperties(constructor:Class, constructorProperties:Vector.<Property>):Vector.<Property>
        {
            if(ignoreDecoding.indexOf(constructor) != -1)
            {
                logInfo(LOG_TYPE_IGNORING_DECODER, "Ignoring decoder config on "
                    + getQualifiedClassName(constructor) + ".");
                return null;
            }
            
            var decoderConfig:BadgerFishDecoderConfig = 
                BadgerFishDecoderConfig.on(new constructor) 
                || BadgerFishDecoderConfig.on(constructor);
            
            if(!decoderConfig && constructorProperties.length == 0)
                return constructorProperties;
            
            if(!decoderConfig && constructorProperties.length == 1)
            {
                logInfo(LOG_TYPE_MISSING_DECODER_ON_SINGLE_PROPERTY, 
                    "Missing decoder config but should contain only one property on "
                    + getQualifiedClassName(constructor) + ".");
                return constructorProperties;
            }
            
            if(!decoderConfig)
            {
                logError("Unable to find decoderConfig on "
                    + getQualifiedClassName(constructor) + ".");
                return null;
            }
            
            if(constructorProperties.length == 1 && 
                (!decoderConfig.includeProperties || !decoderConfig.includeProperties.length))
            {
                logInfo(LOG_TYPE_EMPTY_DECODER_ON_SINGLE_PROPERTY,
                    "Decoder config is empty but should contain only one property on "
                    + getQualifiedClassName(constructor) + ".");
                return constructorProperties;
            }
            
            var list:Array = decoderConfig.includeProperties;
            var badgerFishProperties:Vector.<Property> = new Vector.<Property>;
            var property:Property;
            for each(var propertyName:String in list)
            {
                if(propertyName.substr(0, 1) == "@")
                    continue;
                if(propertyName.indexOf(":") != -1)
                    propertyName = propertyName.substr(propertyName.indexOf(":") + 1);
                
                property = findProperty(constructorProperties, propertyName);
                if(!property)
                    logError("Unable to find decoderConfig property " 
                        + propertyName + " on "
                        + getQualifiedClassName(constructor) + ".");
                badgerFishProperties.push(property);
            }
            return badgerFishProperties;
        }
        
        private function comparePropertiesOrder(constructor:Class, wsdlProperties:Vector.<Property>, orderedProperties:Vector.<Property>):Boolean
        {
            var badgerFishProperty:Property, wsdlProperty:Property;
            for(var i:uint = 0; i < wsdlProperties.length; i++)
            {
                wsdlProperty = wsdlProperties[i];
                badgerFishProperty = orderedProperties[i];
                if(wsdlProperty.name != badgerFishProperty.name)
                {
                    logError("Invalid property order on " 
                        + getQualifiedClassName(constructor) + ". On index " + i
                        + " expected " + wsdlProperty.name + ":" 
                        + getQualifiedClassName(wsdlProperty.constructorClass)
                        + ", but found " + badgerFishProperty.name + ":"
                        + getQualifiedClassName(badgerFishProperty.constructorClass));
                    return false;
                }
            }
            
            return true;
        }
    }
}