package sk.yoz.utils
{
    import flash.display.Shape;
    import flash.events.Event;

    public class LaterDispatcher
    {
        private static const enterFrameBuffer:Array = [];
        private static const exitFrameBuffer:Array = [];
        private static const dispatcher:Shape = new Shape;
        
        public static function addOnEnterFrame(callback:Function, ... args):void
        {
            enterFrameBuffer.push(new BufferItem(callback, args));
            
            if(!dispatcher.hasEventListener(Event.ENTER_FRAME))
                dispatcher.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        public static function addOnExitFrame(callback:Function, ... args):void
        {
            exitFrameBuffer.push(new BufferItem(callback, args));
            
            if(!dispatcher.hasEventListener(Event.EXIT_FRAME))
                dispatcher.addEventListener(Event.EXIT_FRAME, onExitFrame);
        }
        
        private static function onEnterFrame(event:Event):void
        {
            var item:Object, bufferItem:BufferItem;
            for each(item in enterFrameBuffer)
            {
                bufferItem = BufferItem(item);
                bufferItem.callback.apply(null, bufferItem.args);
            }
            
            enterFrameBuffer.length = 0;
            dispatcher.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private static function onExitFrame(event:Event):void
        {
            var item:Object, bufferItem:BufferItem;
            for each(item in exitFrameBuffer)
            {
                bufferItem = BufferItem(item);
                bufferItem.callback.apply(null, bufferItem.args);
            }
            
            exitFrameBuffer.length = 0;
            dispatcher.removeEventListener(Event.EXIT_FRAME, onExitFrame);
        }
    }
}

internal class BufferItem
{
    private var _callback:Function;
    private var _args:Array;
    
    public function BufferItem(callback:Function, args:Array)
    {
        _callback = callback;
        _args = args;
    }
    
    public function get callback():Function
    {
        return _callback;
    }
    
    public function get args():Array
    {
        return _args;
    }
}