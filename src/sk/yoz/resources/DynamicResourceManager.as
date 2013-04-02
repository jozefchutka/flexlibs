package sk.yoz.resources
{
    import flash.events.Event;
    
    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;
    
    import sk.yoz.utils.BindableDynamics;
    
    [Bindable(event="propertyChange")]
    public dynamic class DynamicResourceManager extends BindableDynamics
    {
        protected var _bundleName:String;
        protected var _resourceManager:IResourceManager;
        
        public function DynamicResourceManager(bundleName:String)
        {
            super();
            _bundleName = bundleName;
            _resourceManager = ResourceManager.getInstance();
            _resourceManager.addEventListener(Event.CHANGE, onResourceManagerChange);
        }
        
        protected function onResourceManagerChange(event:Event):void
        {
            dispatchEvent(new Event(BindableDynamics.EVENT_PROPERTY_CHANGE));
        }
        
        [Bindable(event="propertyChange")]
        override public function getDynamicProperty(name:*):*
        {
            return _resourceManager.getString(_bundleName, name);
        }
    }
}