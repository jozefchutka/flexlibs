package sk.yoz
{
    import mx.controls.TextArea;
    
    public final class Log extends Object
    {
        private static const SINGLETON_LOCK:Object = SINGLETON_LOCK;
        private static const _instance:Log = new Log(SINGLETON_LOCK);
        public var output:TextArea; 
        
        public function Log(lock:Object)
        {
            super();
            if(lock != SINGLETON_LOCK)
                throw new Error("Use Log.instance!");
        }
        
        public static function get instance():Log
        {
            return _instance;
        }
        
        public function write(message:String):void
        {
            trace(message);
            if(output && output.visible)
                output.text += message + "\n";
        }
    }
}