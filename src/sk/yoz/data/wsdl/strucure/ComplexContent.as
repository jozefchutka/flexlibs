package sk.yoz.data.wsdl.strucure
{
    import sk.yoz.data.wsdl.Namespaces;

    public class ComplexContent
    {
        private var _complexContent:XML;
        private var _mixed:Boolean;
        private var _extension:Extension;
        
        public function ComplexContent(complexContent:XML)
        {
            var xsd:Namespace = Namespaces.XSD;
            _complexContent = complexContent;
            _mixed = String(complexContent.@mixed) == "true";
            _extension = Extension.create(complexContent.xsd::extension[0]);
        }
        
        public static function create(complexContent:XML):ComplexContent
        {
            return complexContent ? new ComplexContent(complexContent) : null;
        }
        
        public function get mixed():Boolean
        {
            return _mixed;
        }
        
        public function get extension():Extension
        {
            return _extension;
        }
    }
}