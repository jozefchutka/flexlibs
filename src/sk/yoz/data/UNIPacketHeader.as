package sk.yoz.data
{
    public dynamic class UNIPacketHeader
    {
        public var id:uint;
        public var hash:String;
        public var sender:String;
        
        public function UNIPacketHeader()
        {
        }
        
        public static function create(data:Object):UNIPacketHeader
        {
            var header:UNIPacketHeader = new UNIPacketHeader();
            for(var key:String in data)
                header[key] = data[key];
            return header;
        }
    }
}