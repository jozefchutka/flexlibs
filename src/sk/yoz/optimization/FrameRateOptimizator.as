package sk.yoz.optimization
{
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.Matrix;
    import flash.utils.Timer;
    
    public class FrameRateOptimizator extends EventDispatcher
    {
        public var frameRateActive:uint = 24;
        public var frameRateInactive:uint = 2;
        
        protected var snapshot:BitmapData;
        
        protected var fpsp:uint;
        protected var _fps:uint;
        protected var fpsTimer:Timer;
        
        protected var root:DisplayObject;
        protected var _forceActive:Boolean = false;
        protected var _forceInactive:Boolean = false;
        protected var _mouseMoveActivation:Boolean = false;
        protected var _samplingScale:Number = 1;
        protected var samplingMatrix:Matrix = new Matrix();
        
        protected var samplingPeriod:uint = 1000;
        protected var activityTimer:Timer;
        
        public var debug:Boolean = false;
        
        public function FrameRateOptimizator(root:DisplayObject, 
            frameRateActive:uint = 24, frameRateInactive:uint = 2,
            samplingPeriod:uint = 1000, mouseMoveActivation:Boolean = false,
            samplingScale:Number = 1):void
        {
            super();
            
            this.root = root;
            this.frameRateActive = frameRateActive;
            this.frameRateInactive = frameRateInactive;
            this.samplingPeriod = samplingPeriod;
            this.mouseMoveActivation = mouseMoveActivation;
            this.samplingScale = samplingScale;
            
            root.addEventListener(Event.ENTER_FRAME, rootEnterFrame);
            
            fpsTimer = new Timer(1000);
            fpsTimer.addEventListener(TimerEvent.TIMER, fpsTimerHandler);
            fpsTimer.start();
            
            var type:String = TimerEvent.TIMER_COMPLETE;
            activityTimer = new Timer(samplingPeriod, 1);
            activityTimer.addEventListener(type, activityTimerComplete);
            
            isActive = true;
        }
        
        [Bindable(event="fpsChanged")]
        public function get fps():uint
        {
            return _fps;
        }
        
        protected function set fps(value:uint):void
        {
            if(_fps == value)
                return;
            _fps = value;
            dispatchEvent(new Event("fpsChanged"));
        }
        
        public function set forceActive(value:Boolean):void
        {
            _forceActive = value;
            if(forceActive)
                isActive = true;
        }
        
        public function get forceActive():Boolean
        {
            return _forceActive;
        }
        
        public function set forceInactive(value:Boolean):void
        {
            _forceInactive = value;
            if(forceInactive)
                isActive = false;
        }
        
        public function get forceInactive():Boolean
        {
            return _forceInactive;
        }
        
        public function set mouseMoveActivation(value:Boolean):void
        {
            if(value == _mouseMoveActivation)
                return;
            _mouseMoveActivation = value;
            if(value)
                root.addEventListener(MouseEvent.MOUSE_MOVE, rootMouseMove);
            else
                root.removeEventListener(MouseEvent.MOUSE_MOVE, rootMouseMove);
        }
        
        public function get mouseMoveActivation():Boolean
        {
            return _mouseMoveActivation;
        }
        
        public function set isActive(value:Boolean):void
        {
            if(value && !forceActive && !forceInactive)
            {
                activityTimer.reset();
                activityTimer.start();
            }
            frameRate = suggestFrameRate(value);
        }
        
        public function set samplingScale(value:Number):void
        {
            _samplingScale = value;
            samplingMatrix = new Matrix();
            samplingMatrix.scale(value, value);
        }
        
        public function get samplingScale():Number
        {
            return _samplingScale;
        }
        
        protected function suggestFrameRate(active:Boolean):uint
        {
            if(forceActive)
                return frameRateActive;
            if(forceInactive)
                return frameRateInactive;
            return active ? frameRateActive : frameRateInactive;
        }
        
        protected function set frameRate(value:uint):void
        {
            if(value == frameRate)
                return;
            root.stage.frameRate = value;
            if(debug)
                trace("FrameRateOptimizator -> frameRate = " + value);
        }
        
        protected function get frameRate():uint
        {
            return root.stage.frameRate;
        }
        
        public function get isActive():Boolean
        {
            return frameRate == frameRateActive;
        }
        
        protected function rootEnterFrame(event:Event):void
        {
            fpsp++;
            if(!isActive && rootChanged)
                isActive = true;
        }
        
        protected function rootMouseMove(event:MouseEvent):void
        {
            isActive = true;
        }
        
        protected function get rootChanged():Boolean
        {
            var changed:Boolean = true;
            var bitmapData:BitmapData;
            try
            {
                var d0:Date = new Date();
                bitmapData = new BitmapData(
                    root.width * samplingScale, root.height * samplingScale);
                bitmapData.draw(root, samplingMatrix);
                if(snapshot)
                    changed = bitmapData.compare(snapshot) != 0;
                snapshot = bitmapData;
                trace(new Date().time - d0.time, "ms")
            }
            catch(error:Error)
            {
                snapshot = null;
                if(debug)
                    trace("FrameRateOptimizator Error: " + error.message);
            }
            return changed;
        }
        
        protected function fpsTimerHandler(event:TimerEvent):void
        {
            protected::fps = fpsp;
            fpsp = 0;
        }
        
        protected function activityTimerComplete(event:TimerEvent):void
        {
            isActive = rootChanged;
        }
    }
}