package sk.yoz.data.wsdl.valueObjects
{
    import sk.yoz.data.wsdl.strucure.ComplexType;
    import sk.yoz.data.wsdl.strucure.Element;

    public class ElementInfo
    {
        private var _complexType:ComplexType;
        private var _element:Element;
        
        public function ElementInfo(complexType:ComplexType, element:Element)
        {
            _complexType = complexType;
            _element = element;
        }
        
        public function get complexType():ComplexType
        {
            return _complexType;
        }
        
        public function get element():Element
        {
            return _element;
        }
    }
}