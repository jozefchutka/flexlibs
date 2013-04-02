package sk.yoz.data.badgerfish
{
    public class BadgerFishEncoderConfig
    {
        public var namespace:String;
        public var namespaces:Array;
        public var properties:Object;
        public var attributes:Object;
        
        public function BadgerFishEncoderConfig(namespace:String=null, 
            namespaces:Array=null, properties:Object=null, 
            attributes:Object=null)
        {
            this.namespace = namespace;
            this.namespaces = namespaces || [];
            this.properties = properties || {};
            this.attributes = attributes || {};
        }
        
        public static function on(source:Object, create:Boolean = false)
            :BadgerFishEncoderConfig
        {
            var config:BadgerFishEncoderConfig;
            try
            {
                config = source.badgerfishinternal::encoderConfig;
            }
            catch(error:Error){}
            return config || (create ? new BadgerFishEncoderConfig : null);
        }
        
        public static function onConstructor(source:Object, 
            create:Boolean = false):BadgerFishEncoderConfig
        {
            var config:BadgerFishEncoderConfig;
            try
            {
                config = on(Object(source).constructor, create);
            }
            catch(error:Error){}
            return config;
        }
    }
}