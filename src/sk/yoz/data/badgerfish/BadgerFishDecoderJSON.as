package sk.yoz.data.badgerfish
{

    public class BadgerFishDecoderJSON extends BadgerFishDecoder
    {
        public function BadgerFishDecoderJSON()
        {
        }
        
        public static function decode(source:BadgerFish):String
        {
            var decoder:BadgerFishDecoderJSON = new BadgerFishDecoderJSON;
            return decoder.decode(source).toString();
        }
        
        override public function decode(source:BadgerFish, constructor:Class=null,
            config:BadgerFishDecoderConfig=null):Object
        {
            config = getConfig(source, config);
            
            var result:Object = decodeProperties(source, config, "");
            return "{" + result.toString() + "}";
        }
        
        override protected function decodeProperty(source:BadgerFish, 
            config:BadgerFishDecoderConfig, name:String, result:Object):Object
        {
            var currentConfig:BadgerFishDecoderConfig = getPropertyConfig(name, config);
            result += (result ? "," : "") + escapeString(name) + ":";
            result += convertToString(source[name], currentConfig);
            return result;
        }
        
        override protected function getConfig(source:Object, 
            config:BadgerFishDecoderConfig):BadgerFishDecoderConfig
        {
            return BadgerFishDecoderConfig.on(source)
                || BadgerFishDecoderConfig.onConstructor(source)
                || super.getConfig(source, config);
        }
        
        private function convertToString(value:*, 
            config:BadgerFishDecoderConfig):String
        {
            if(value is String)
                return escapeString(value as String);
            if(value is Number)
                return isFinite(value as Number) ? value.toString() : "null";
            if(value is Boolean)
                return value ? "true" : "false";
            if(value is Array)
                return arrayToString(value as Array, config);
            if(value is Object && value != null)
                return decode(value, null, config) as String;
            return "null";
        }
        
        private function escapeString(str:String):String
        {
            var s:String = "";
            var ch:String;
            var len:Number = str.length;
            
            for(var i:int = 0; i < len; i++)
            {
                ch = str.charAt(i);
                switch(ch)
                {
                    case '"': // quotation mark
                        s += "\\\"";
                        break;
                    case '\\': // reverse solidus
                        s += "\\\\";
                        break;
                    case '\b': // bell
                        s += "\\b";
                        break;
                    case '\f': // form feed
                        s += "\\f";
                        break;
                    case '\n': // newline
                        s += "\\n";
                        break;
                    case '\r': // carriage return
                        s += "\\r";
                        break;
                    case '\t': // horizontal tab
                        s += "\\t";
                        break;
                    default: // everything else
                        // check for a control character and escape as unicode
                        if(ch < ' ')
                        {
                            // get the hex digit(s) of the character (either 1 or 2 digits)
                            var hexCode:String = ch.charCodeAt( 0 ).toString( 16 );
                            
                            // ensure that there are 4 digits by adjusting
                            // the # of zeros accordingly.
                            var zeroPad:String = hexCode.length == 2 ? "00" : "000";
                            
                            // create the unicode escape sequence with 4 hex digits
                            s += "\\u" + zeroPad + hexCode;
                        }
                        else
                        {
                            s += ch;
                            
                        }
                }
            }
            return "\"" + s + "\"";
        }
        
        private function arrayToString(a:Array, 
            config:BadgerFishDecoderConfig):String
        {
            var s:String = "";
            var length:int = a.length;
            for(var i:int = 0; i < length; i++)
                s += (s.length > 0 ? "," : "") + convertToString(a[i], config);
            return "[" + s + "]";
        }
    }
}