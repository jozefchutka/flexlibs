package sk.yoz.data
{
    import com.adobe.utils.ArrayUtil;
    
    import flash.utils.ByteArray;
    
    import mx.collections.ArrayCollection;
    import flash.events.Event;
    
    public class Clone extends Object
    {
        public function Clone()
        {
            super();
        }
        
        public static function object(original:Object):Object
        {
            return Object(raw(original));
        }
        
        public static function array(original:Array):Array
        {
            return ArrayUtil.copyArray(original);
        }
        
        public static function arrayCollection(original:ArrayCollection):ArrayCollection
        {
            return raw(original) as ArrayCollection;
        }
        
        public static function raw(original:*):*
        {
            var byteArray:ByteArray = new ByteArray();
            byteArray.writeObject(original);
            byteArray.position = 0;
            return byteArray.readObject();
        }
    }
}