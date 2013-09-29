package sk.yoz.data.sequenceParser.sequences
{
    public class MatchAnythingSequence implements ISequence
    {
        private var _stopSequence:Boolean;
        private var matchCallback:Function;
        
        public function MatchAnythingSequence(stopSequence:Boolean = false, 
            matchCallback:Function = null)
        {
            _stopSequence = stopSequence;
            this.matchCallback = matchCallback;
        }
        
        public function test(input:String):String
        {
            if(input == null || input == "")
                return null;
            
            var match:String = input.substr(0, 1);
            if(matchCallback != null)
                matchCallback(match);
            return match;
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