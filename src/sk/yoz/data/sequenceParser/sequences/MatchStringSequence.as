package sk.yoz.data.sequenceParser.sequences
{
    public class MatchStringSequence implements ISequence
    {
        private var match:String;
        private var matchLength:uint;
        private var _stopSequence:Boolean;
        private var matchCallback:Function;
        
        public function MatchStringSequence(match:String, 
            stopSequence:Boolean = false, matchCallback:Function = null)
        {
            this.match = match;
            matchLength = match.length;
            _stopSequence = stopSequence;
            this.matchCallback = matchCallback;
        }
        
        public function test(input:String):String
        {
            if(input.substr(0, matchLength) == match)
            {
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