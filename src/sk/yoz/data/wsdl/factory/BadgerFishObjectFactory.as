package sk.yoz.data.wsdl.factory
{
    import com.kitd.cms.ui.services.valueObjects.collections.Collection;
    
    import mx.collections.ArrayCollection;
    
    import sk.yoz.data.badgerfish.BadgerFish;
    import sk.yoz.data.badgerfish.BadgerFishDecoderConfig;
    import sk.yoz.data.badgerfish.badgerfishinternal;

    public class BadgerFishObjectFactory extends ObjectFactory
    {
        public var collectionItemsCount:uint = 2;
        
        public function BadgerFishObjectFactory()
        {
            super();
        }
        
        override protected function createInternal(result:Object, name:String, 
            constructor:Class, levels:int):void
        {
            super.createInternal(result, name, constructor, levels);
            if(constructor == ArrayCollection)
                createCollection(result, name, constructor, levels);
        }
        
        protected function createCollection(result:Object, name:String, 
            constructor:Class, levels:int):void
        {
            var config:BadgerFishDecoderConfig = BadgerFishDecoderConfig.onConstructor(result);
            var item:Object;
            var itemConstructor:Class = config.classMap[name] || Object;
            var collection:ArrayCollection = result[name];
            if(!collection.source)
                collection.source = [];
            
            for(var i:uint = 0; i < collectionItemsCount; i++)
            {
                item = create(itemConstructor, levels - 2);
                collection.addItem(item);
            }
        }
    }
}