package sk.yoz.utils
{
    import flash.utils.Timer;

    public class DataTimer extends Timer
    {
        private var _data:Object;
        
        public function DataTimer(delay:Number, repeatCount:int=0, data:Object=null)
        {
            super(delay, repeatCount);
            _data = data;
        }
        
        public function get data():Object
        {
            return _data;
        }
    }
}