package sk.yoz.data.sequenceParser.sequences 
{
    public class StartStringEndStringSequence implements ISequence
    {
        private var startSequence:MatchStringSequence;
        private var endSequence:MatchStringSequence;
        private var _sequences:Vector.<ISequence>;
        private var _stopSequence:Boolean;
        
        public function StartStringEndStringSequence(start:String, end:String,
            sequences:Vector.<ISequence> = null, stopSequence:Boolean = false,
            startCallback:Function = null, endCallback:Function = null)
        {
            startSequence = new MatchStringSequence(start, false, startCallback);
            endSequence = new MatchStringSequence(end, true, endCallback);
            _sequences = sequences;
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