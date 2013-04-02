package sk.yoz.data.wsdl.strucure
{
    import sk.yoz.data.wsdl.Namespaces;

    public class Enumeration
    {
        private var _enumeration:XML;
        private var _value:String;
        private var _annotation:Annotation;
        
        public function Enumeration(enumeration:XML)
        {
            var xsd:Namespace = Namespaces.XSD;
            _enumeration = enumeration;
            _value = enumeration.@value;
            _annotation = Annotation.create(enumeration.xsd::annotation[0]);
        }
        
        public static function createList(enumerations:XMLList):Vector.<Enumeration>
        {
            var list:Vector.<Enumeration> = new Vector.<Enumeration>;
            for each(var enumeration:XML in enumerations)
                list.push(new Enumeration(enumeration));
            return list;
        }
        
        public function get value():String
        {
            return _value;
        }
        
        public function get annotation():Annotation
        {
            return _annotation;
        }
    }
}