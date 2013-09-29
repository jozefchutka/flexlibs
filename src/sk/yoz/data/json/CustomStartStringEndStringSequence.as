package sk.yoz.data.json
{
    import sk.yoz.data.sequenceParser.sequences.ISequence;
    import sk.yoz.data.sequenceParser.sequences.StartStringEndStringSequence;
    
    public class CustomStartStringEndStringSequence extends StartStringEndStringSequence
    {
        protected var cachedSequences:Vector.<ISequence>;
        
        public function CustomStartStringEndStringSequence(start:String, end:String, 
            sequences:Vector.<ISequence>=null, stopSequence:Boolean=false, 
            startCallback:Function=null, endCallback:Function=null)
        {
            super(start, end, sequences, stopSequence, startCallback, endCallback);
        }
        
        public function cacheSequences():void
        {
            cachedSequences = super.sequences;
        }
        
        override public function get sequences():Vector.<ISequence>
        {
            return cachedSequences;
        }
    }
}