package sk.yoz.events
{
    import flash.events.Event;
    
    public class LazyDataGridEvent extends Event
    {
        public static const ITEMS_PENDING:String = "itemsPending";
        
        private var _indexMin:int;
        private var _indexMax:int;
        
        public function LazyDataGridEvent(type:String, bubbles:Boolean=false, 
            cancelable:Boolean=false, indexMin:int = -1, indexMax:int = -1)
        {
            super(type, bubbles, cancelable); 
            _indexMin = indexMin;
            _indexMax = indexMax;
        }
        
        public function get indexMin():int
        {
            return _indexMin;
        }
        
        public function get indexMax():int
        {
            return _indexMax;
        }
        
        override public function clone():Event
        {
            return new LazyDataGridEvent(type, bubbles, cancelable, indexMin, 
                indexMax);
        }
        
        override public function toString():String
        {
            return '[LazyDataGridEvent ' +
                'type="' + type +'" ' +
                'bubbles=' + bubbles + ' ' +
                'cancelable=' + cancelable + ' ' +
                'indexMin=' + indexMin + ' ' +
                'indexMax=' + indexMax + ' ' +
                'eventPhase=' + eventPhase + ']';
        }
    }
}