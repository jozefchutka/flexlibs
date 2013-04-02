package sk.yoz.data
{
    import __AS3__.vec.Vector;
    
    import flash.events.EventDispatcher;
    
    import mx.binding.utils.ChangeWatcher;

    public class WatcherList extends EventDispatcher
    {
        private var list:Vector.<ChangeWatcher> = new Vector.<ChangeWatcher>();
        
        public function WatcherList()
        {
            super();
        }
        
        public function addWatcher(watcher:ChangeWatcher):void
        {
            list.push(watcher);
        }
        
        public function destroy():void
        {
            for each(var watcher:ChangeWatcher in list)
            {
                watcher.unwatch();
                watcher = null;
            }
            list = new Vector.<ChangeWatcher>();
        }
    }
}