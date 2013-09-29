/**
 * Jozef Chutka 2013
 * Bacil (ByteArray Crud Interface Library) provides extensible interface for 
 * CRUD (create, read, update, delete) operations over single instance of 
 * ByteArray.
 */

package sk.yoz.memory
{
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    
    public class Bacil
    {
        protected var _byteArray:ByteArray;
        protected var tempByteArray:ByteArray;
        
        protected var databaseOffset:Dictionary;
        protected var databaseLength:Dictionary;
        protected var nextIndex:uint;
        
        public function Bacil(endian:String)
        {
            _byteArray = new ByteArray;
            byteArray.endian = endian;
            
            tempByteArray = new ByteArray;
            tempByteArray.endian = endian;
            
            databaseOffset = new Dictionary;
            databaseLength = new Dictionary;
            nextIndex = 0;
        }
        
        public function get byteArray():ByteArray
        {
            return _byteArray;
        }
        
        public function getOffset(index:uint):uint
        {
            return databaseOffset[index];
        }
        
        public function getLength(index:uint):uint
        {
            return databaseLength[index];
        }
        
        public function create(data:Object):uint
        {
            var index:uint = nextIndex++;
            var offset:uint = byteArray.length;
            byteArray.position = offset;
            byteArray.writeObject(data);
            var length:uint = byteArray.length - offset;
            
            databaseLength[index] = length;
            databaseOffset[index] = offset;
            return index;
        }
        
        public function read(index:uint):Object
        {
            var offset:uint = databaseOffset[index];
            byteArray.position = offset;
            return byteArray.readObject();
        }
        
        public function update(index:uint, data:Object):void
        {
            var offset:uint = databaseOffset[index];
            var length:uint = databaseLength[index];
            
            prepareByteArray(offset, length);
            byteArray.writeObject(data);
            
            var newLength:uint = byteArray.length - offset;
            databaseLength[index] = newLength;
            
            byteArray.writeBytes(tempByteArray);
            
            tempByteArray.length = 0;
            shiftDatabaseOffset(index, newLength - length);
        }
        
        public function del(index:uint):void
        {
            var offset:uint = databaseOffset[index];
            var length:uint = databaseLength[index];
            
            prepareByteArray(offset, length);
            byteArray.writeBytes(tempByteArray);
            tempByteArray.length = 0;
            
            delete databaseOffset[index];
            delete databaseLength[index];
            shiftDatabaseOffset(index, -length);
        }
        
        protected function prepareByteArray(offset:uint, length:uint):void
        {
            tempByteArray.length = 0;
            
            byteArray.position = offset + length;
            byteArray.readBytes(tempByteArray);
            byteArray.length = offset;
            byteArray.position = offset;
        }
        
        protected function shiftDatabaseOffset(index:uint, delta:int):void
        {
            for(var key:uint in databaseOffset)
                if(key > index)
                    databaseOffset[key] += delta;
        }
    }
}