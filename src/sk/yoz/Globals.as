package sk.yoz
{
    [Bindable]
    public final class Globals extends Object
    {
        private static const SINGLETON_LOCK:Object = {};
        private static const _instance:Globals = new Globals(SINGLETON_LOCK);
        
        public var data:Object = {};
        
        public function Globals(lock:Object)
        {
            super();
            if(lock != SINGLETON_LOCK)
                throw new Error("Use Globals.instance!");
        }
        
        public static function get instance():Globals
        {
            return _instance;
        }
        
        public function defaultize(key:String, value:*):void
        {
            if(!data.hasOwnProperty(key))
                data[key] = value;
        }
    }
}