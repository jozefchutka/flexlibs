package sk.yoz.events
{
    import flash.events.Event;
    
    public class ColorCircleEvent extends Event
    {
        public static const COLOR_SELECTED:String = 
            "ColorCircleEventCOLOR_SELECTED";
            
        public static const COLOR_OVER:String = 
            "ColorCircleEventCOLOR_OVER";
        
        private var _color:uint;
        
        public function ColorCircleEvent(type:String, bubbles:Boolean=false, 
            cancelable:Boolean=false, color:uint=0):void
        {
            super(type, bubbles, cancelable);
            _color = color;
        }
        
        public function get color():uint
        {
            return _color;
        }
    }
}