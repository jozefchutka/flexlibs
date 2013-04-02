package sk.yoz.shader
{
    import flash.display.Shader;
    import flash.display.ShaderInput;
    import flash.display.ShaderParameter;
    import flash.events.Event;
    import flash.filters.ShaderFilter;
    
    import mx.containers.VBox;
    import mx.controls.HRule;
    import mx.controls.HSlider;
    import mx.events.SliderEvent;
    import mx.controls.Spacer;
    import mx.controls.Text;
    
    public class ShaderExplorer extends VBox
    {
        protected var _shader:Shader;
        
        public function ShaderExplorer()
        {
            super();
        }
        
        public function get shader():Shader
        {
            return _shader;
        }
        
        public function set shader(value:Shader):void
        {
            _shader = value;
            createControls();
            dispatchEvent(new Event("shaderFiltersChanged"));
        }
        
        [Bindable(event="shaderFiltersChanged")]
        public function get shaderFilters():Array
        {
            if(!shader)
                return [];
            return [new ShaderFilter(shader)];
        }
        
        protected function createControls():void
        {
            var spacer:Spacer;
            
            removeAllChildren();
            createDescriptors();
            spacer = new Spacer();
            spacer.height = 20;
            addChild(spacer);
            createInputs();
            spacer = new Spacer();
            spacer.height = 20;
            addChild(spacer);
            createParameters();
        }
        
        protected function createDescriptors():void
        {
            var param:String;
            for(param in shader.data)
                if(shader.data[param] is String)
                    add_text(param + ": " + shader.data[param]);
        }
        
        protected function createInputs():void
        {
            var param:String;
            for(param in shader.data)
                if(shader.data[param] is ShaderInput)
                    add_text(param + ": " + shader.data[param]);
        }
        
        protected function sliderChangeHandler(event:SliderEvent):void
        {
            if(!event.target.name)
                return;
            var name:String = String(event.target.name).replace(/_[0-9]+$/, '');
            var shaderParameter:ShaderParameter = shader.data[name];
            var values:Array = [];
            var i:uint = 0;
            while(getChildByName(name + "_" + i))
                values.push(HSlider(getChildByName(name + "_" + i++)).value);
            shaderParameter.value = values;
            dispatchEvent(new Event("shaderFiltersChanged"));
        }
        
        protected function createParameters():void
        {
            var param:String;
            var shaderParameter:ShaderParameter;
            for(param in shader.data)
            {
                if(!(shader.data[param] is ShaderParameter))
                    continue;
                
                shaderParameter = shader.data[param] as ShaderParameter;
                try
                {
                    this["add_" + shaderParameter.type].apply(null, [shaderParameter]);
                }
                catch(error:Error)
                {
                    add_text("unknown type (" + shaderParameter.type + ")");
                }
            }
        }
        
        protected function add_text(text:String):void
        {
            var txt:Text = new Text();
            txt.text = text;
            txt.percentWidth = 100;
            addChild(txt);
        }
        
        protected function add_slider(name:String, value:Number, minimum:Number,
            maximum:Number, snapInterval:Number = 0):void
        {
            var slider:HSlider = new HSlider();
            slider.name = name;
            slider.minimum = minimum;
            slider.maximum = maximum;
            slider.value = value;
            slider.snapInterval = snapInterval;
            slider.percentWidth = 100;
            slider.addEventListener(SliderEvent.CHANGE, sliderChangeHandler);
            addChild(slider);
        }
        
        protected function add_float(p:ShaderParameter):void
        {
            add_text(p.name + " (" + p.type + ")");
            add_slider(p.name + "_0", p.defaultValue[0], p.minValue[0], p.maxValue[0]);
        }
        
        protected function add_float2(p:ShaderParameter):void
        {
            add_text(p.name + " (" + p.type + ")");
            add_slider(p.name + "_0", p.defaultValue[0], p.minValue[0], p.maxValue[0]);
            add_slider(p.name + "_1", p.defaultValue[1], p.minValue[1], p.maxValue[1]);
        }
        
        protected function add_float3(p:ShaderParameter):void
        {
            add_text(p.name + " (" + p.type + ")");
            add_slider(p.name + "_0", p.defaultValue[0], p.minValue[0], p.maxValue[0]);
            add_slider(p.name + "_1", p.defaultValue[1], p.minValue[1], p.maxValue[1]);
            add_slider(p.name + "_2", p.defaultValue[2], p.minValue[2], p.maxValue[2]);
        }
        
        protected function add_float4(p:ShaderParameter):void
        {
            add_text(p.name + " (" + p.type + ")");
            add_slider(p.name + "_0", p.defaultValue[0], p.minValue[0], p.maxValue[0]);
            add_slider(p.name + "_1", p.defaultValue[1], p.minValue[1], p.maxValue[1]);
            add_slider(p.name + "_2", p.defaultValue[2], p.minValue[2], p.maxValue[2]);
            add_slider(p.name + "_3", p.defaultValue[3], p.minValue[3], p.maxValue[3]);
        }
        
        protected function add_int(p:ShaderParameter):void
        {
            add_text(p.name + " (" + p.type + ")");
            add_slider(p.name + "_0", p.defaultValue[0], p.minValue[0], p.maxValue[0] ,1);
        }
        
        protected function add_int2(p:ShaderParameter):void
        {
            add_text(p.name + " (" + p.type + ")");
            add_slider(p.name + "_0", p.defaultValue[0], p.minValue[0], p.maxValue[0] ,1);
            add_slider(p.name + "_1", p.defaultValue[1], p.minValue[1], p.maxValue[1] ,1);
        }
        
        protected function add_int3(p:ShaderParameter):void
        {
            add_text(p.name + " (" + p.type + ")");
            add_slider(p.name + "_0", p.defaultValue[0], p.minValue[0], p.maxValue[0] ,1);
            add_slider(p.name + "_1", p.defaultValue[1], p.minValue[1], p.maxValue[1] ,1);
            add_slider(p.name + "_2", p.defaultValue[2], p.minValue[2], p.maxValue[2] ,1);
        }
        
        protected function add_int4(p:ShaderParameter):void
        {
            add_text(p.name + " (" + p.type + ")");
            add_slider(p.name + "_0", p.defaultValue[0], p.minValue[0], p.maxValue[0] ,1);
            add_slider(p.name + "_1", p.defaultValue[1], p.minValue[1], p.maxValue[1] ,1);
            add_slider(p.name + "_2", p.defaultValue[2], p.minValue[2], p.maxValue[2] ,1);
            add_slider(p.name + "_3", p.defaultValue[3], p.minValue[3], p.maxValue[3], 1);
        }
        
        // TODO, matrix, matrix4x4...
    }
}