package sk.yoz
{
    import flash.events.EventDispatcher;
    import flash.net.SharedObject;
    import flash.utils.*;
    
    use namespace flash_proxy;
    
    public class SharedSettings extends EventDispatcher
    {
        private static const SINGLETON_LOCK:Object = {};
        private static const _instance:SharedSettings = new SharedSettings(SINGLETON_LOCK);
        
        private var so:SharedObject;
        
        public function SharedSettings(lock:Object)
        {
            super();
            if(lock != SINGLETON_LOCK)
                throw new Error("Use SOSettings.instance");
        }
        
        public static function get instance():SharedSettings
        {
            return _instance;
        }
        
        public function init(name:String, localPath:String = null, secure:Boolean = false):void
        {
            so = SharedObject.getLocal(name, localPath, secure);
        }
        
        public function get data():Object
        {
            return so.data;
        }
    }
}