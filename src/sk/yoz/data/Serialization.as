package sk.yoz.data
{   
    import flash.utils.ByteArray;
    import com.dynamicflash.util.Base64;
   
    public class Serialization 
    {
        public static function objectToString(data:Object):String
        {
            var bytes:ByteArray = objectToBytes(data);
            return bytesToString(bytes);
        }
        
        public static function stringToObject(data:String):Object
        {
            var bytes:ByteArray = stringToBytes(data);
            return bytesToObject(bytes);
        }
        
        public static function objectToBytes(data:Object):ByteArray
        {
            var bytes:ByteArray = new ByteArray();
            bytes.writeObject(data);
            bytes.position = 0;
            return bytes;
        }
        
        public static function bytesToString(bytes:ByteArray):String
        {
            return Base64.encodeByteArray(bytes);
        }
        
        public static function stringToBytes(data:String):ByteArray
        {
            return Base64.decodeToByteArray(data);
        }
        
        public static function bytesToObject(bytes:ByteArray):Object
        {
            bytes.position = 0;
            return bytes.readObject();
        }
        
        public static function p16Top64(p16:String):String
        {
            var b:ByteArray = new ByteArray();
            var s:String = p16;
            while(s.length)
            {
                b.writeUnsignedInt(parseInt("0x" + s.substr(0, 8), 16));
                s = s.substr(8);
            }
            b.position = 0;
            return Base64.encodeByteArray(b);
        }
        
        public static function p64Top16(p64:String):String
        {
            var r:String = "";
            var b:ByteArray = Base64.decodeToByteArray(p64);
            var x:String = "";
            b.position = 0;
            while(b.position < b.length)
            {
                x = b.readUnsignedInt().toString(16);
                r += String("00000000").substr(x.length) + x;
            }
            return r;
        }
    }
}