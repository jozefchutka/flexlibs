package sk.yoz.data.wsdl.strucure
{
    import sk.yoz.data.wsdl.Namespaces;

    public class Schema
    {
        private var _schema:XML;
        private var _attributeFormDefault:String;
        private var _elementFormDefault:String;
        private var _targetNamespace:String;
        private var _elements:Vector.<Element>;
        private var _simpleTypes:Vector.<SimpleType>;
        private var _attributes:Vector.<Attribute>;
        private var _complexTypes:Vector.<ComplexType>;
        
        public function Schema(schema:XML)
        {
            var xsd:Namespace = Namespaces.XSD;
            _schema = schema;
            _attributeFormDefault = schema.@attributeFormDefault;
            _elementFormDefault = schema.@elementFormDefault;
            _targetNamespace = schema.@targetNamespace;
            _elements = Element.createList(schema.xsd::element);
            _simpleTypes = SimpleType.createList(schema.xsd::simpleType);
            _attributes = Attribute.createList(schema.xsd::attribute);
            _complexTypes = ComplexType.createList(schema.xsd::complexType);
        }
        
        public static function createList(schemas:XMLList):Vector.<Schema>
        {
            var list:Vector.<Schema> = new Vector.<Schema>;
            for each(var schema:XML in schemas)
                list.push(new Schema(schema));
            return list;
        }
        
        public function get attributeFormDefault():String
        {
            return _attributeFormDefault;
        }
        
        public function get elementFormDefault():String
        {
            return _elementFormDefault;
        }
        
        public function get targetNamespace():String
        {
            return _targetNamespace;
        }
        
        public function get elements():Vector.<Element>
        {
            return _elements;
        }
        
        public function get simpleTypes():Vector.<SimpleType>
        {
            return _simpleTypes;
        }
        
        public function get attributes():Vector.<Attribute>
        {
            return _attributes;
        }
        
        public function get complexTypes():Vector.<ComplexType>
        {
            return _complexTypes;
        }
    }
}