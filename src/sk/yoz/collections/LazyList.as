package sk.yoz.collections
{
    import mx.collections.ArrayCollection;
    import mx.collections.errors.ItemPendingError;
    
    public class LazyList extends ArrayCollection
    {
        private var _length:int;
        
        public function LazyList(length:int = -1)
        {
            super([]);
            
            if(length > -1)
                this.length = length;
        }
        
        public function set length(value:int):void
        {
            _length = value;
            
            var i:uint, l:uint;
            if(!source)
                for(i = 0, source = []; i < value; i++)
                    source.push(undefined);
            else if(source.length < value)
                for(i = 0, l = value - source.length; i < l; i++)
                    source.push(undefined);
            else if(source.length > value)
                source.splice(value, source.length - value);
            
            refresh();
        }
        
        override public function get length():int
        {
            return _length;
        }
        
        override public function getItemAt(index:int, prefetch:int=0):Object
        {
            var result:* = super.getItemAt(index, prefetch);
            if(result == undefined)
                throw new ItemPendingError("itemPending");
            return result;
        }
    }
}