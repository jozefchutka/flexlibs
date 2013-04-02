package sk.yoz.data.wsdl.strucure
{
    public class Attribute
    {
        private var _attribute:XML;
        private var _name:String;
        private var _type:String; // TODO mapping
        
        public function Attribute(attribute:XML)
        {
            _attribute = attribute;
            _name = attribute.@name;
            _type = attribute.@type;
        }
        
        public static function createList(attributes:XMLList):Vector.<Attribute>
        {
            var list:Vector.<Attribute> = new Vector.<Attribute>;
            for each(var attribute:XML in attributes)
                list.push(new Attribute(attribute));
            return list;
        }
        
        public function get name():String
        {
            return _name;
        }
        
        public function get type():String
        {
            return _type;
        }
    }
}