package sk.yoz.data.wsdl.testers
{
    import flash.utils.describeType;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    
    import mx.collections.ArrayCollection;
    
    import sk.yoz.data.wsdl.strucure.*;
    import sk.yoz.data.wsdl.valueObjects.ElementInfo;
    import sk.yoz.data.wsdl.valueObjects.Property;

    public class WSDLTester
    {
        public static const LOG_TYPE_ERROR_AS_INFO:uint = 1;
        public static const LOG_TYPE_INFO:uint = 2
        public static const LOG_TYPE_MAP_IGNORING:uint = 4;
        public static const LOG_TYPE_MAP_LOCAL_IGNORING:uint = 8;
        public static const LOG_TYPE_SUCCESSFUL_TEST:uint = 16;
        
        public var logTypes:uint = 0;
        
        protected var map:Object;
        protected var mapLocal:Object;
        protected var mapService:Object;
        
        public function WSDLTester(map:Object, mapLocal:Object, mapService:Object)
        {
            this.map = map;
            this.mapLocal = mapLocal;
            this.mapService = mapService;
        }
        
        public function test(wsdl:XML):Boolean
        {
            var definition:Definition = new Definition(wsdl);
            var schema:Schema, complexType:ComplexType, element:Element;
            for each(schema in definition.types)
            {
                for each(element in schema.elements)
                    testElement(definition, schema, element);
                for each(complexType in schema.complexTypes)
                    testComplexType(definition, schema, complexType);
            }
            
            return true;
        }
        
        private function testElement(definition:Definition, schema:Schema, element:Element):void
        {
            var constructor:Class = getConstructorFromMapService(schema.targetNamespace, element.name);
            if(!constructor)
                return;
            
            var complexType:ComplexType = element.complexType;
            if(!complexType)
                return;
            
            var elementInfos:Vector.<ElementInfo> = getElementInfoList(definition, complexType);
            var result1:Boolean = compareExtend(definition, schema, complexType, constructor);
            var result2:Boolean = compareProperties(constructor, getWSDLProperties(elementInfos), getConstructorProperties(constructor));
            var result3:Boolean = compareNamespaces(definition, schema, complexType, constructor);
            if(result1 && result2)
                logInfo(LOG_TYPE_SUCCESSFUL_TEST, 
                    "Successful test for " + getQualifiedClassName(constructor));
        }
        
        private function testComplexType(definition:Definition, schema:Schema, complexType:ComplexType):void
        {
            var constructor:Class = getConstructorForComplexType(schema, complexType);
            if(!constructor)
                return;
            
            var elementInfos:Vector.<ElementInfo> = getElementInfoList(definition, complexType);
            var result1:Boolean = compareExtend(definition, schema, complexType, constructor);
            var result2:Boolean = compareProperties(constructor, getWSDLProperties(elementInfos), getConstructorProperties(constructor));
            var result3:Boolean = compareNamespaces(definition, schema, complexType, constructor);
            if(result1 && result2 && result3)
                logInfo(LOG_TYPE_SUCCESSFUL_TEST, 
                    "Successful test for " + getQualifiedClassName(constructor));
        }
        
        protected function compareExtend(definition:Definition, schema:Schema, complexType:ComplexType, constructor:Class):Boolean
        {
            var wsdlExtendConstructor:Class = getComplexTypeExtendConstructor(definition, schema, complexType);
            if(!wsdlExtendConstructor)
                return true;
            
            var description:XML = describeType(constructor);
            var className:String = description.factory.extendsClass[0].@type;
            var constructorExtendConstructor:Class = getDefinitionByName(className) as Class;
            if(isAcceptableExtend(wsdlExtendConstructor, constructorExtendConstructor))
                return true;
            
            logError("Object " + getQualifiedClassName(constructor)  
                + " should extend " + getQualifiedClassName(wsdlExtendConstructor)
                + ", but extends " + getQualifiedClassName(constructorExtendConstructor));
            return false;
        }
        
        protected function compareProperties(constructor:Class, wsdlProperties:Vector.<Property>, constructorProperties:Vector.<Property>):Boolean
        {
            var result1:Boolean = comparePropertiesOnWSDL(constructor, wsdlProperties, constructorProperties)
            var result2:Boolean = comparePropertiesOnConstructor(constructor, wsdlProperties, constructorProperties)
            var result3:Boolean = comparePropertiesCount(constructor, wsdlProperties, constructorProperties);
            return result1 && result2 && result3;
        }
        
        protected function compareNamespaces(definition:Definition, schema:Schema, complexType:ComplexType, constructor:Class):Boolean
        {
            return true;
        }
        
        private function comparePropertiesOnWSDL(constructor:Class, wsdlProperties:Vector.<Property>, constructorProperties:Vector.<Property>):Boolean
        {
            var constructorProperty:Property, wsdlProperty:Property;
            for each(wsdlProperty in wsdlProperties)
            {
                constructorProperty = findProperty(constructorProperties, wsdlProperty.name);
                if(!constructorProperty)
                    logError("Undeclared property " + wsdlProperty.name + ":" 
                        + getQualifiedClassName(wsdlProperty.constructorClass) 
                        + " on " + getQualifiedClassName(constructor));
                
                if(!wsdlProperty.constructorClass)
                    continue;
                
                if(wsdlProperty.constructorClass != constructorProperty.constructorClass)
                    logError("Invalid property " + constructorProperty.name + ":" 
                        + getQualifiedClassName(constructorProperty.constructorClass) 
                        + " on " + getQualifiedClassName(constructor) 
                        + ". Expected type " + getQualifiedClassName(wsdlProperty.constructorClass));
            }
            
            return true;
        }
        
        private function comparePropertiesOnConstructor(constructor:Class, wsdlProperties:Vector.<Property>, constructorProperties:Vector.<Property>):Boolean
        {
            var constructorProperty:Property, wsdlProperty:Property;
            for each(constructorProperty in constructorProperties)
            {
                wsdlProperty = findProperty(wsdlProperties, constructorProperty.name);
                if(!wsdlProperty)
                    logError("Unexpected property " + constructorProperty.name + ":" 
                        + getQualifiedClassName(constructorProperty.constructorClass) 
                        + " on " + getQualifiedClassName(constructor));
            }
            
            return true;
        }
        
        protected function comparePropertiesCount(constructor:Class, wsdlProperties:Vector.<Property>, constructorProperties:Vector.<Property>):Boolean
        {
            if(wsdlProperties.length == constructorProperties.length)
                return true;
            
            logError("Invalid properties count ("
                + wsdlProperties.length + " vs. " 
                + constructorProperties.length + ") on "
                + getQualifiedClassName(constructor) 
                + ". Expected: " + wsdlProperties 
                + ", but found: " + constructorProperties);
            
            return false;
        }
        
        private function getComplexTypeExtend(definition:Definition, complexType:ComplexType):ComplexType
        {
            if(!complexType.complexContent)
                return null;
            
            var extension:Extension = complexType.complexContent.extension;
            return getComplexType(definition, extension);
        }
        
        protected function getComplexTypeExtendConstructor(definition:Definition, schema:Schema, complexType:ComplexType):Class
        {
            var extend:ComplexType = getComplexTypeExtend(definition, complexType);
            if(!extend)
                return null;
            var constructor:Class = getConstructorForComplexType(schema, extend);
            if(!constructor)
                logError("Unknown (null) extend constructor for " 
                    + extend._tns + " " + extend.name + ". "
                    + "Unable to compare extend constructor.");
            return constructor;
        }
        
        private function getElementInfoList(definition:Definition, complexType:ComplexType):Vector.<ElementInfo>
        {
            var list:Vector.<ElementInfo> = new Vector.<ElementInfo>;
            var element:Element, elementInfo:ElementInfo;
            var extension:Extension, extensionList:Vector.<ElementInfo>;
            var extensionComplexType:ComplexType = getComplexTypeExtend(definition, complexType);
            
            if(extensionComplexType)
            {
                extensionList = getElementInfoList(definition, extensionComplexType);
                for each(elementInfo in extensionList)
                    list.push(elementInfo);
                    
                extension = complexType.complexContent.extension;
                for each(element in extension.sequence)
                    list.push(new ElementInfo(complexType, element));
            }
            
            for each(element in complexType.elements)
                list.push(new ElementInfo(complexType, element));
            
            return list;
        }
        
        protected function findProperty(properties:Vector.<Property>, name:String):Property
        {
            for each(var property:Property in properties)
                if(property.name == name)
                    return property;
            return null;
        }
        
        protected function getConstructorByType(xml:XML, type:String):Class
        {
            var name:String = typeToName(type);
            var ns:Namespace = getNamespace(xml, type);
            return getConstructorFromMap(ns.uri, name);
        }
        
        protected function getConstructorForComplexType(schema:Schema, complexType:ComplexType):Class
        {
            return complexType._tns
                ? getConstructorFromMap(complexType._tns, complexType.name)
                : getConstructorFromMap(schema.targetNamespace, complexType.name);
        }
        
        protected function getConstructorFromMap(uri:String, name:String):Class
        {
            if(!map.hasOwnProperty(uri) 
                || !map[uri].hasOwnProperty(name))
            {
                logError("Missing mapping for " + uri + " " + name);
                return null;
            }
            var constructor:Class = map[uri][name];
            if(constructor)
                return constructor;
            
            logInfo(LOG_TYPE_MAP_IGNORING, "Ignoring " + uri + " " + name);
            return null;
        }
        
        protected function getConstructorFromMapService(uri:String, name:String):Class
        {
            if(!mapService.hasOwnProperty(uri) 
                || !mapService[uri].hasOwnProperty(name))
            {
                return getConstructorFromMap(uri, name);
            }
            var constructor:Class = mapService[uri][name];
            if(constructor)
                return constructor;
            
            logInfo(LOG_TYPE_MAP_IGNORING, "Ignoring " + uri + " " + name);
            return null;
        }
        
        protected function getConstructorFromMapLocal(uri:String, name:String, localName:String):Class
        {
            if(!mapLocal.hasOwnProperty(uri) 
                || !mapLocal[uri].hasOwnProperty(name)
                || !mapLocal[uri][name].hasOwnProperty(localName))
            {
                logError("Missing private mapping for " + uri + " " + name + " " + localName);
                return null;
            }
            var constructor:Class = mapLocal[uri][name][localName];
            if(constructor)
                return constructor;
            
            logInfo(LOG_TYPE_MAP_LOCAL_IGNORING, "Ignoring private " + uri + " " + name + " " + localName);
            return null;
        }
        
        protected function typeToPrefix(type:String):String
        {
            return type.split(":")[0];
        }
        
        protected function typeToName(type:String):String
        {
            return type.split(":")[1];
        }
        
        private function getNamespace(xml:XML, type:String):Namespace
        {
            var prefix:String = typeToPrefix(type);
            return xml.namespace(prefix);
        }
        
        private function getComplexType(definition:Definition, extension:Extension):ComplexType
        {
            var name:String = typeToName(extension.base);
            return getComplexTypeByName(definition, name);
        }
        
        private function getComplexTypeByName(definition:Definition, name:String):ComplexType
        {
            for each(var schema:Schema in definition.types)
            for each(var complexType:ComplexType in schema.complexTypes)
            if(complexType.name == name)
                return complexType;
            
            logError("Unable to find extension " + name + " on definition.");
            return null;
        }
        
        private function getWSDLProperties(elementInfos:Vector.<ElementInfo>):Vector.<Property>
        {
            var list:Vector.<Property> = new Vector.<Property>;
            var constructor:Class, element:Element, complexType:ComplexType;
            for each(var elementInfo:ElementInfo in elementInfos)
            {
                element = elementInfo.element;
                complexType = elementInfo.complexType;
                
                if(element.maxOccurs == Element.MAX_OCCURS_UNBOUNDED)
                    constructor = ArrayCollection;
                else if(element.type)
                    constructor = getConstructorByType(element._source, element.type);
                else
                    constructor = getConstructorFromMapLocal(complexType._tns, complexType.name, element.name);
                
                if(element.name)
                    list.push(new Property(element.name, constructor));
            }
            return list;
        }
        
        protected function getConstructorProperties(constructor:Class):Vector.<Property>
        {
            var list:Vector.<Property> = new Vector.<Property>;
            var description:XML = describeType(constructor);
            var factories:XMLList = description.factory;
            for each(var factory:XML in factories)
            {
                for each(var variable:XML in factory.variable)
                    list.push(createProperty(variable.@name, variable.@type));
                
                for each(var accessor:XML in factory.accessor)
                    list.push(createProperty(accessor.@name, accessor.@type));
            }
            
            return list;
        }
        
        protected function createProperty(name:String, type:String):Property
        {
            var constructor:Class = getDefinitionByName(type) as Class;
            return new Property(name, constructor);
        }
        
        protected function isAcceptableExtend(wsdlExtendConstructor:Class, constructorExtendConstructor:Class):Boolean
        {
            if(!wsdlExtendConstructor && constructorExtendConstructor == Object)
                return true;
            return wsdlExtendConstructor == constructorExtendConstructor;
        }
        
        protected function logError(message:String):void
        {
            if(logTypes & LOG_TYPE_ERROR_AS_INFO)
                return logInfo(LOG_TYPE_ERROR_AS_INFO, message);
            throw new Error(message);
        }
        
        protected function logInfo(type:uint, message:String):void
        {
            if(logTypes & type)
                trace(message);
        }
    }
}