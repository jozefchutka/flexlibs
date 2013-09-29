package sk.yoz.data.sequenceParser.sequences
{
    public interface ISequence
    {
        function test(input:String):String
        function get sequences():Vector.<ISequence>
        function get stopSequence():Boolean
    }
}