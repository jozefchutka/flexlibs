package sk.yoz.data.badgerfish
{
    public dynamic class BadgerFish
    {
        public static const XMLNS:String = "@xmlns";
        
        badgerfishinternal var decoderConfig:Object;
        
        public function BadgerFish(source:Object=null)
        {
            source && create(source, this);
        }
        
        private function create(source:Object, result:BadgerFish):void
        {
            for(var name:String in source)
            {
                var value:Object = source[name];
                var constructor:Class = value.constructor;
                if(constructor == Object)
                    this[name] = new BadgerFish(value);
                else if(constructor == Array)
                    this[name] = createFromArray(value as Array);
                else this[name] = value;
            }
        }
        
        private function createFromArray(source:Array):Array
        {
            var result:Array = [];
            var length:uint = source.length;
            for(var i:uint = 0; i < length; i++)
                result.push(new BadgerFish(source[i]));
            return result;
        }
        
        public function getAttributes():Array
        {
            var result:Array = [];
            for(var name:String in this)
                if(name.indexOf(XMLNS) == -1 && name.indexOf("@") == 0)
                    result.push(name);
            return result;
        }
        
        public function getFirstChild():Object
        {
            for(var name:String in this)
                if(name.indexOf("@") != 0)
                    return this[name];
            return null;
        }
    }
}