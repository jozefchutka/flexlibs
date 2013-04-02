package sk.yoz.data.wsdl.strucure
{
    import sk.yoz.data.wsdl.Namespaces;

    public class Element
    {
        public static const MAX_OCCURS_UNBOUNDED:String = "unbounded";
        
        private var _element:XML;
        private var _name:String;
        private var _nillable:String;
        private var _type:String;
        private var _minOccurs:String;
        private var _maxOccurs:String;
        private var _annotation:Annotation;
        private var _complexType:ComplexType;
        
        public function Element(element:XML)
        {
            var xsd:Namespace = Namespaces.XSD;
            _element = element;
            _name = element.@name;
            _nillable = element.@nillable;
            _type = element.@type;
            _minOccurs = element.@minOccurs;
            _maxOccurs = element.@maxOccurs;
            _annotation = Annotation.create(element.xsd::annotation[0]);
            _complexType = ComplexType.create(element.xsd::complexType[0]);
        }
        
        public static function createList(elements:XMLList):Vector.<Element>
        {
            var list:Vector.<Element> = new Vector.<Element>;
            for each(var element:XML in elements)
                list.push(new Element(element));
            return list;
        }
        
        public function get _source():XML
        {
            return _element;
        }
        
        public function get name():String
        {
            return _name;
        }
        
        public function get nillable():String
        {
            return _nillable;
        }
        
        public function get type():String
        {
            return _type;
        }
        
        public function get minOccurs():String
        {
            return _minOccurs;
        }
        
        public function get maxOccurs():String
        {
            return _maxOccurs;
        }
        
        public function get annotation():Annotation
        {
            return _annotation;
        }
        
        public function get complexType():ComplexType
        {
            return _complexType;
        }
    }
}