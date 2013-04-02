package sk.yoz.data.wsdl.factory
{
    import flash.utils.describeType;
    import flash.utils.getDefinitionByName;
    
    import mx.collections.ArrayCollection;

    public class ObjectFactory
    {
        public function ObjectFactory()
        {
        }
        
        public function create(constructor:Class, levels:int = 1):Object
        {
            if(levels < 0)
                return null;
            
            var template:Object = createTemplate(constructor, levels)
            if(template)
                return template;
            
            var description:XML = describeType(constructor);
            var properties:Vector.<XML> = listProperties(constructor, description);
            var result:Object = new constructor;
            fillProperties(result, properties, description, levels);
            return result;
        }
        
        protected function createTemplate(constructor:Class, levels:int):Object
        {
            switch(constructor)
            {
                case String:
                    return "value " + int(Math.random() * 100);
                case int:
                    return int(Math.random() * 1000 - 500);
                case uint:
                    return uint(Math.random() * 1000);
                case Number:
                    return Math.random() * 1000;
                case Date:
                    return new Date;
                case Boolean:
                    return true;
                default:
                    return null;
            }
        }
        
        protected function listProperties(constructor:Class, description:XML):Vector.<XML>
        {
            var properties:Vector.<XML> = new Vector.<XML>();
            
            var variable:XML;
            var variables:XMLList = description.factory.variable;
            for each(variable in variables)
                if(includeVariable(variable))
                    properties.push(variable);
            
            var accessor:XML;
            var accessors:XMLList = description.factory.accessor;
            for each(accessor in accessors)
                if(includeAccessor(accessor))
                    properties.push(accessor);
            
            return properties;
        }
        
        protected function includeVariable(variable:XML):Boolean
        {
            return true;
        }
        
        protected function includeAccessor(acessor:XML):Boolean
        {
            return acessor.@access == "readwrite";
        }
        
        protected function fillProperties(result:Object, properties:Vector.<XML>, 
            description:XML, levels:int):void
        {
            var property:XML;
            var name:String, type:String, constructor:Class;
            for each(property in properties)
            {
                name = property.@name.toString();
                type = property.@type.toString();
                constructor = getDefinitionByName(type) as Class;
                createInternal(result, name, constructor, levels);
            }
        }
        
        protected function createInternal(result:Object, name:String, 
            constructor:Class, levels:int):void
        {
            if(constructor == ArrayCollection)
                result[name] = create(constructor, 0);
            else
                result[name] = create(constructor, levels - 1);
        }
    }
}