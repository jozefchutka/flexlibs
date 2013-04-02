package sk.yoz.data.wsdl.strucure
{
    import sk.yoz.data.wsdl.Namespaces;

    public class Annotation
    {
        private var _annotation:XML;
        private var _appinfo:AppInfo
        
        public function Annotation(annotation:XML)
        {
            var xsd:Namespace = Namespaces.XSD;
            _annotation = annotation;
            _appinfo = AppInfo.create(annotation.xsd::appinfo[0]);
        }
        
        public static function create(annotation:XML):Annotation
        {
            return annotation ? new Annotation(annotation) : null;
        }
        
        public function get appinfo():AppInfo
        {
            return _appinfo;
        }
    }
}