package sk.yoz.data.sequenceParser.sequences
{
    public class MatchRegexpSequence implements ISequence
    {
        private var match:RegExp;
        private var _stopSequence:Boolean;
        private var matchCallback:Function;
        
        public function MatchRegexpSequence(match:RegExp, 
            stopSequence:Boolean = false, matchCallback:Function = null)
        {
            this.match = match;
            _stopSequence = stopSequence;
            this.matchCallback = matchCallback;
        }
        
        public function test(input:String):String
        {
            var matches:Array = input.match(this.match);
            if(matches)
            {
                var match:String = matches[0];
                if(matchCallback != null)
                    matchCallback(match);
                return match;
            }
            return null;
        }
        
        public function get sequences():Vector.<ISequence>
        {
            return null;
        }
        
        public function get stopSequence():Boolean
        {
            return _stopSequence;
        }
    }
}