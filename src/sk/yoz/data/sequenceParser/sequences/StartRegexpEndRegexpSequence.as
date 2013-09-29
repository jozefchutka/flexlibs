package sk.yoz.data.sequenceParser.sequences
{
    public class StartRegexpEndRegexpSequence implements ISequence
    {
        private var startSequence:MatchRegexpSequence;
        private var endSequence:MatchRegexpSequence;
        private var _sequences:Vector.<ISequence>;
        private var _stopSequence:Boolean;
        
        public function StartRegexpEndRegexpSequence(start:RegExp, end:RegExp,
            sequences:Vector.<ISequence> = null, stopSequence:Boolean = false,
            startCallback:Function = null, endCallback:Function = null)
        {
            startSequence = new MatchRegexpSequence(start, false, startCallback);
            endSequence = new MatchRegexpSequence(end, true, endCallback);
            _stopSequence = stopSequence;
        }
        
        public function get sequences():Vector.<ISequence>
        {
            var result:Vector.<ISequence> = _sequences 
                ? _sequences.concat() : new Vector.<ISequence>;
            result.splice(0, 0, endSequence);
            return result;
        }
        
        public function test(input:String):String
        {
            return startSequence.test(input);
        }
        
        public function get stopSequence():Boolean
        {
            return _stopSequence;
        }
    }
}