package sk.yoz.data.badgerfish
{
    public class BadgerFishDecoderConfig
    {
        public var includeProperties:Array;
        public var classMap:Object;
        public var properties:Object;
        
        public function BadgerFishDecoderConfig(classMap:Object=null,
            includeProperties:Array=null, properties:Object=null)
        {
            this.classMap = classMap || {};
            this.includeProperties = includeProperties;
            this.properties = properties || {};
        }
        
        public static function on(source:Object, create:Boolean = false)
            :BadgerFishDecoderConfig
        {
            var config:BadgerFishDecoderConfig;
            try
            {
                config = source.badgerfishinternal::decoderConfig;
            }
            catch(error:Error){}
            return config || (create ? new BadgerFishDecoderConfig : null);
        }
        
        public static function onConstructor(source:Object, 
            create:Boolean = false):BadgerFishDecoderConfig
        {
            var config:BadgerFishDecoderConfig;
            try
            {
                config = on(Object(source).constructor, create);
            }
            catch(error:Error){}
            return config;
        }
    }
}