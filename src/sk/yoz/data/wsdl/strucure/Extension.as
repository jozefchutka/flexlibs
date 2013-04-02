package sk.yoz.data.wsdl.strucure
{
    import sk.yoz.data.wsdl.Namespaces;

    public class Extension
    {
        private var _extension:XML;
        private var _base:String; // TODO mapping
        private var _sequence:Vector.<Element> = new Vector.<Element>;
        
        public function Extension(extension:XML)
        {
            var xsd:Namespace = Namespaces.XSD;
            _extension = extension;
            _base = extension.@base;
            _sequence = Element.createList(extension.xsd::sequence.xsd::element);
        }
        
        public static function create(extension:XML):Extension
        {
            return extension ? new Extension(extension) : null;
        }
        
        public function get _source():XML
        {
            return _extension;
        }
        
        public function get base():String
        {
            return _base;
        }
        
        public function get sequence():Vector.<Element>
        {
            return _sequence;
        }
    }
}