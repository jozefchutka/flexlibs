package sk.yoz.data
{
    import sk.yoz.data.sequenceParser.SequenceParser;
    import sk.yoz.data.sequenceParser.sequences.ISequence;
    import sk.yoz.data.sequenceParser.sequences.MatchAnythingSequence;
    import sk.yoz.data.sequenceParser.sequences.MatchRegexpSequence;
    import sk.yoz.data.sequenceParser.sequences.MatchStringSequence;
    import sk.yoz.data.sequenceParser.sequences.StartStringEndStringSequence;
    
    public class SimpleQueryParser
    {
        private var expression:String = "";
        private var expressionCallback:Function;
        private var pendingExpression:String = "";
        private var openedBrackets:uint = 0;
        private var isBracketStart:Boolean;
        private var isBracketEnd:Boolean;
        
        public static function parse(input:String, callback:Function=null):String
        {
            var parser:SimpleQueryParser = new SimpleQueryParser;
            parser.expressionCallback = callback;
            
            var sequences:Vector.<ISequence> = new Vector.<ISequence>;
            sequences.push(new StartStringEndStringSequence("(", ")", sequences, false, parser.bracketStart, parser.bracketEnd));
            sequences.push(new MatchRegexpSequence(/^and\b/i, false, parser.andCallback));
            sequences.push(new MatchRegexpSequence(/^or\b/i, false, parser.orCallback));
            sequences.push(new MatchRegexpSequence(/^[^\s\(\)]+/i, false, parser.anythingCallback));
            sequences.push(new MatchStringSequence(")", false, parser.unexpectedBracketEndCallback));
            sequences.push(new MatchAnythingSequence(false, parser.anythingCallback));
            
            SequenceParser.parse(input, sequences);
            parser.evaluatePendingExpression();
            if(parser.openedBrackets)
                throw new Error("Invalid expression. Missing " + parser.openedBrackets + " closing bracket(s).");
            return parser.expression;
        }
        
        private function evaluatePendingExpression():void
        {
            pendingExpression = pendingExpression.replace(/[\s]+/g, " ");
            pendingExpression = pendingExpression.replace(/^[\s]+/, "");
            pendingExpression = pendingExpression.replace(/[\s]+$/, "");
            if(pendingExpression && expressionCallback != null)
                append(expressionCallback(pendingExpression));
            else if(pendingExpression)
                append(pendingExpression);
            pendingExpression = "";
        }
        
        private function append(value:String):void
        {
            if(!expression 
                || expression.charAt(expression.length - 1) == "("
                || expression.charAt(expression.length - 1) == ")"
                || value == ")")
                expression += value;
            else
                expression += " " + value;
        }
        
        private function anythingCallback(value:String):void
        {
            if(!pendingExpression)
                value = value.replace(/^[\s]+/, "");
            pendingExpression += value;
            if(value)
                isBracketStart = isBracketEnd = false;
        }
        
        private function bracketStart(value:String):void
        {
            if(pendingExpression && !isBracketStart)
                throw new Error("Unexpected bracket start. Missing operator before opening bracket.");
            openedBrackets++;
            evaluatePendingExpression();
            append(value);
            isBracketStart = true;
            isBracketEnd = false;
        }
        
        private function bracketEnd(value:String):void
        {
            if(!pendingExpression && !isBracketEnd)
                throw new Error("Unexpected bracket end. Missing expression before closing bracket.");
            openedBrackets--;
            evaluatePendingExpression();
            append(value);
            isBracketStart = false;
            isBracketEnd = true;
        }
        
        private function andCallback(value:String):void
        {
            if(!pendingExpression && !isBracketEnd)
                throw new Error("Unexpected operator. Missing expression before operator.");
            evaluatePendingExpression();
            append(isBracketEnd ? " AND" : "AND");
            isBracketStart = isBracketEnd = false;
        }
        
        private function orCallback(value:String):void
        {
            if(!pendingExpression && !isBracketEnd)
                throw new Error("Unexpected operator. Missing expression before operator.");
            evaluatePendingExpression();
            append(isBracketEnd ? " OR" : "OR");
            isBracketStart = isBracketEnd = false;
        }
        
        private function unexpectedBracketEndCallback(value:String):void
        {
            throw new Error("Unexpected closing bracket. No bracket was opened.");
        }
    }
}