package sk.yoz.data.wsdl.strucure
{
    public class AppInfo
    {
        private var _appinfo:XML;
        private var _enumerationValue:Object;
        
        public function AppInfo(appinfo:XML)
        {
            _appinfo = appinfo;
            _enumerationValue = appinfo.@EnumerationValue;
        }
        
        public static function create(appinfo:XML):AppInfo
        {
            return appinfo ? new AppInfo(appinfo) : null;
        }
        
        public function get enumerationValue():Object
        {
            return _enumerationValue;
        }
    }
}