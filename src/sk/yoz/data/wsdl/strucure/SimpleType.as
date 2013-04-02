package sk.yoz.data.wsdl.strucure
{
    import sk.yoz.data.wsdl.Namespaces;

    public class SimpleType
    {
        private var _simpleType:XML;
        private var _name:String;
        private var _restrictions:Vector.<Enumeration> = new Vector.<Enumeration>;
        
        public function SimpleType(simpleType:XML)
        {
            var xsd:Namespace = Namespaces.XSD;
            _simpleType = simpleType;
            _name = simpleType.@name;
            _restrictions = Enumeration.createList(simpleType.xsd::restriction.xsd::enumeration);
        }
        
        public static function createList(simpleTypes:XMLList):Vector.<SimpleType>
        {
            var list:Vector.<SimpleType> = new Vector.<SimpleType>;
            for each(var simpleType:XML in simpleTypes)
                list.push(new SimpleType(simpleType));
            return list;
        }
        
        public function get name():String
        {
            return _name;
        }
        
        public function get restrictions():Vector.<Enumeration>
        {
            return _restrictions;
        }
    }
}