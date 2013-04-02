package sk.yoz.resources
{
    import flash.events.Event;
    
    import mx.events.PropertyChangeEvent;
    
    import sk.yoz.utils.BindableDynamics;
    
    public dynamic class DynamicBundle extends BindableDynamics
    {
        private var _locale:String;
        private var _bundleName:String;
        
        public function DynamicBundle(bundleName:String)
        {
            super();
            _bundleName = bundleName;
        }
        
        public function get bundleName():String
        {
            return _bundleName;
        }
        
        [Bindable(event="propertyChange")]
        public function set locale(value:String):void
        {
            var event:Event = PropertyChangeEvent.createUpdateEvent(this, 
                "locale", _locale, value);
            _locale = value;
            dispatchEvent(event);
        }
        
        public function get locale():String
        {
            return _locale;
        }
        
        override protected function getDynamicProperty(name:*):*
        {
            trace(name, locale);
            return "gottcha";
        }
    }
}