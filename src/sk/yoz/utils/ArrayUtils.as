package sk.yoz.utils
{
    import sk.yoz.data.Clone;
    
    public class ArrayUtils extends Object
    {
        public function ArrayUtils()
        {
            super();
        }
        
        public static function shuffleClone(source:Array):Array
        {
            var arr:Array = Clone.array(source);
            var arr2:Array = [];
            while (arr.length > 0)
                arr2.push(arr.splice(Math.round(Math.random() * (arr.length - 1)), 1)[0]);
            return arr2;
        }
        
        public static function randomItem(arr:Array):Object
        {
            return arr[Math.floor(Math.random() * arr.length)];
            
        }
    }
}