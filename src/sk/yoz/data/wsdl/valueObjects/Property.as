package sk.yoz.data.wsdl.valueObjects
{
    public class Property
    {
        private var _name:String;
        private var _constructorClass:Class;
        
        public function Property(name:String, constructorClass:Class)
        {
            _name = name;
            _constructorClass = constructorClass;
        }
        
        public function get name():String
        {
            return _name;
        }
        
        public function get constructorClass():Class
        {
            return _constructorClass;
        }
        
        public function toString():String
        {
            return name;
        }
    }
}