package sk.yoz.shader
{
    import flash.display.Shader;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.filters.ShaderFilter;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    
    public class ShaderLoader extends EventDispatcher
    {
        protected var loader:URLLoader = new URLLoader();
        protected var _filters:Array = [];
        protected var _shader:Shader;
        protected var _shaderFilter:ShaderFilter;
        
        public function ShaderLoader()
        {
            super();
            
            loader.dataFormat = URLLoaderDataFormat.BINARY;
            loader.addEventListener(Event.COMPLETE, loadCompleteHandler);
            loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        }
        
        [Bindable(event="filtersChanged")]
        public function get filters():Array
        {
            return _filters;
        }
        
        protected function set filters(value:Array):void
        {
            _filters = value;
            dispatchEvent(new Event("filtersChanged"));
        }
        
        [Bindable(event="shaderChanged")]
        public function get shader():Shader
        {
            return _shader;
        }
        
        protected function set shader(value:Shader):void
        {
            _shader = value;
            dispatchEvent(new Event("shaderChanged"));
        }
        
        [Bindable(event="shaderFilterChanged")]
        public function get shaderFilter():ShaderFilter
        {
            return _shaderFilter;
        }
        
        protected function set shaderFilter(value:ShaderFilter):void
        {
            _shaderFilter = value;
            dispatchEvent(new Event("shaderFilterChanged"));
        }
        
        public function load(url:String):void
        {
            loader.load(new URLRequest(url));
        }
        
        protected function loadCompleteHandler(event:Event):void
        {
            try
            {
                protected::shader = new Shader(event.target.data);
                protected::shaderFilter = new ShaderFilter(public::shader);
                protected::filters = [public::shaderFilter];
            }
            catch(error:Error)
            {
                protected::shader = null;
                protected::shaderFilter = null;
                protected::filters = [];
            }
        }
        
        protected function ioErrorHandler(event:IOErrorEvent):void
        {
        }
    }
}