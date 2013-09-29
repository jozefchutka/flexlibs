package sk.yoz.data.sequenceParser
{
    import sk.yoz.data.sequenceParser.sequences.ISequence;

    public class SequenceParser
    {
        public static function parse(input:String, sequences:Vector.<ISequence>):String
        {
            if(input == null || !input.length 
                || !sequences || !sequences.length)
                return input;
            
            var source:String = input;
            var i:uint = 0;
            while(true)
            {
                var sequence:ISequence = sequences[i++];
                var match:String = sequence.test(source);
                if(match != null)
                {
                    source = source.substr(match.length);
                    source = parse(source, sequence.sequences);
                    if(sequence.stopSequence)
                        break;
                    i = 0;
                }
                else if(i == sequences.length)
                    break;
            }
            
            if(source == input)
                throw new Error("Unmatching sequences");
            return source;
        }
    }
}