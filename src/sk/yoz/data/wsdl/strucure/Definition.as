package sk.yoz.data.wsdl.strucure
{
    import sk.yoz.data.wsdl.Namespaces;

    public class Definition
    {
        private var _definition:XML;
        private var _types:Vector.<Schema> = new Vector.<Schema>;
        
        public function Definition(definition:XML)
        {
            var ns:Namespace = definition.namespace();
            var xsd:Namespace = Namespaces.XSD;
            _definition = definition;
            _types = Schema.createList(definition.ns::types.xsd::schema);
        }
        
        public function get types():Vector.<Schema>
        {
            return _types;
        }
    }
}