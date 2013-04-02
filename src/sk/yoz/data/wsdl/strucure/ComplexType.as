package sk.yoz.data.wsdl.strucure
{
    import sk.yoz.data.wsdl.Namespaces;

    public class ComplexType
    {
        private var __source:XML;
        private var __tns:String;
        
        private var _name:String;
        private var _complexContent:ComplexContent;
        private var _elements:Vector.<Element> = new Vector.<Element>;
        
        public function ComplexType(complexType:XML)
        {
            var xsd:Namespace = Namespaces.XSD;
            var tns:Namespace = complexType.namespace(Namespaces.TNS_PREFIX);
            __source = complexType;
            __tns = tns ? tns.uri : null;
            _name = complexType.@name;
            _complexContent = ComplexContent.create(complexType.xsd::complexContent[0]);
            _elements = Element.createList(complexType.xsd::sequence.xsd::element);
        }
        
        public static function create(complexType:XML):ComplexType
        {
            return complexType ? new ComplexType(complexType) : null;
        }
        
        public static function createList(complexTypes:XMLList):Vector.<ComplexType>
        {
            var list:Vector.<ComplexType> = new Vector.<ComplexType>;
            for each(var complexType:XML in complexTypes)
                list.push(new ComplexType(complexType));
            return list;
        }
        
        public function get _source():XML
        {
            return __source;
        }
        
        public function get _tns():String
        {
            return __tns;
        }
        
        public function get name():String
        {
            return _name;
        }
        
        public function get complexContent():ComplexContent
        {
            return _complexContent;
        }
        
        public function get elements():Vector.<Element>
        {
            return _elements;
        }
    }
}