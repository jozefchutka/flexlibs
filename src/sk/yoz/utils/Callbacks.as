package sk.yoz.utils
{
    public class Callbacks
    {
        private static var list:Array = [];
        
        public function Callbacks()
        {
        }
        
        public static function add(thisObject:Object, method:Function, 
            argArray:Array=null, flag:String=""):void
        {
            list.splice(0, 0, {
                thisObject:thisObject, 
                method:method,
                argArray:argArray, 
                flag:flag});
        }
        
        public static function remove(flag:String = ""):void
        {
            var item:Object;
            var i:int = list.length;
            while(i--)
            {
                item = list[i];
                if(flag && item.flag != flag)
                    continue;
                list.splice(i, 1);
            }
        }
        
        public static function execute(flag:String = ""):uint
        {
            var method:Function, length:uint, item:Object;
            var i:int = list.length;
            var count:uint = 0;
            while(i--)
            {
                item = list[i];
                if(flag && item.flag != flag)
                    continue;
                count++;
                list.splice(i, 1);
                length = list.length;
                method = item.method;
                method.apply(item.thisObject, item.argArray || []);
                if(length != list.length)
                    i = list.length;
            }
            return count;
        }
    }
}