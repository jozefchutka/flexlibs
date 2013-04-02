package sk.yoz.utils
{
    import com.rouche.math.BigDecimal;
    
    public class FacebookUtils extends Object
    {
        public function FacebookUtils():void
        {
            super();
        }
        
        public static function profileAid(uid:String):String
        {
            var v1:BigDecimal = new BigDecimal(uid);
            var v2:BigDecimal = new BigDecimal(2);
            var v3:BigDecimal = new BigDecimal(32);
            var v4:BigDecimal = new BigDecimal(4294967293);
            var v5:BigDecimal = new BigDecimal(3);
            var v6:BigDecimal = new BigDecimal(uint.MAX_VALUE.toString());
            
            var r:String = v1.compareTo(v6) == 1
                ? v1.subtract(v5).toString()
                : v1.multiply(v2.pow(v3)).add(v4).toString();
            var l:Array = r.replace(",", ".").split(".");
            return l[0];
        }
    }
}