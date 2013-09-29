package sk.yoz.data.json
{
    import sk.yoz.data.sequenceParser.sequences.ISequence;
    
    public class EscapeSequence extends CustomStartStringEndStringSequence
    {
        public function EscapeSequence(start:String, sequences:Vector.<ISequence>=null, 
            topSequence:Boolean=false, startCallback:Function=null, endCallback:Function=null)
        {
            super(start, "", sequences, stopSequence, startCallback, endCallback);
        }
        
        override public function cacheSequences():void
        {
            super.cacheSequences();
            cachedSequences.shift();
        }
    }
}