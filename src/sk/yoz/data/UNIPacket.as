package sk.yoz.data
{
    public class UNIPacket
    {
        public var header:UNIPacketHeader;
        public var data:*;
        
        public function UNIPacket(header:UNIPacketHeader=null, data:*=null)
        {
            this.header = header;
            this.data = data;
        }
        
        public static function create(data:Object):UNIPacket
        {
            return new UNIPacket(UNIPacketHeader.create(data.header), data.data);
        }
    }
}