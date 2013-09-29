package sk.yoz.data.json
{
    import sk.yoz.data.sequenceParser.SequenceParser;
    import sk.yoz.data.sequenceParser.sequences.ISequence;
    import sk.yoz.data.sequenceParser.sequences.MatchAnythingSequence;
    import sk.yoz.data.sequenceParser.sequences.MatchRegexpSequence;
    import sk.yoz.data.sequenceParser.sequences.MatchStringSequence;
    
    public class JSON
    {
        private var result:Object;
        private var pendingDefinition:Definition;
        
        public static function decode(source:String):*
        {
            var parser:JSON = new JSON;
            return parser.decode(source);
        }
        
        public function decode(source:String):*
        {
            var sequences:Vector.<ISequence> = new Vector.<ISequence>;
            var sequencesObject:Vector.<ISequence> = new Vector.<ISequence>;
            var sequencesArray:Vector.<ISequence> = new Vector.<ISequence>;
            var sequencesDoubleQuota:Vector.<ISequence> = new Vector.<ISequence>;
            var sequencesEscaped:Vector.<ISequence> = new Vector.<ISequence>;
            
            var sequenceAnything:ISequence = new MatchAnythingSequence;
            var sequenceObject:ISequence = new CustomStartStringEndStringSequence("{", "}", sequencesObject, false, matchObjectStart, matchEnd);
            var sequenceArray:ISequence = new CustomStartStringEndStringSequence("[", "]", sequencesArray, false, matchArrayStart, matchEnd);
            var sequenceNumber:ISequence = new MatchRegexpSequence(/^-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][+-]?[0-9]+)?/, false, matchNumber);
            var sequenceDoubleQuota:ISequence = new CustomStartStringEndStringSequence("\"", "\"", sequencesDoubleQuota, false);
            var sequenceString:ISequence = new MatchAnythingSequence(false, matchChar);
            var sequenceTrue:ISequence = new MatchStringSequence("true", false, matchTrue);
            var sequenceFalse:ISequence = new MatchStringSequence("false", false, matchFalse);
            var sequenceNull:ISequence = new MatchStringSequence("null", false, matchNull);
            var sequenceObjectColon:ISequence = new MatchStringSequence(":", false, matchObjectColon);
            var sequenceObjectComma:ISequence = new MatchStringSequence(",", false, matchObjectComma);
            var sequenceArrayComma:ISequence = new MatchStringSequence(",", false, matchArrayComma);
            var sequenceEscaped:ISequence = new EscapeSequence("\\", sequencesEscaped);
            var sequenceEscapedQuota:ISequence = new MatchStringSequence("\"", true, matchEscapedChar);
            var sequenceEscapedBackslash:ISequence = new MatchStringSequence("\\", true, matchEscapedChar);
            var sequenceEscapedSlash:ISequence = new MatchStringSequence("/", true, matchEscapedChar);
            var sequenceEscapedB:ISequence = new MatchStringSequence("b", true, matchEscapedB);
            var sequenceEscapedF:ISequence = new MatchStringSequence("f", true, matchEscapedF);
            var sequenceEscapedN:ISequence = new MatchStringSequence("n", true, matchEscapedN);
            var sequenceEscapedR:ISequence = new MatchStringSequence("r", true, matchEscapedR);
            var sequenceEscapedT:ISequence = new MatchStringSequence("t", true, matchEscapedT);
            var sequenceEscapedU:ISequence = new MatchRegexpSequence(/^u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]/, true, matchEscapedU);
            
            sequences.push(sequenceObject);
            sequences.push(sequenceArray);
            sequences.push(sequenceDoubleQuota);
            sequences.push(sequenceTrue);
            sequences.push(sequenceFalse);
            sequences.push(sequenceNull);
            sequences.push(sequenceNumber);
            sequences.push(sequenceAnything);
            
            sequencesObject.push(sequenceObjectColon);
            sequencesObject.push(sequenceObjectComma);
            append(sequencesObject, sequences);
            
            sequencesArray.push(sequenceArrayComma);
            append(sequencesArray, sequences);
            
            sequencesDoubleQuota.push(sequenceEscaped);
            sequencesDoubleQuota.push(sequenceString);
            
            sequencesEscaped.push(sequenceEscapedQuota);
            sequencesEscaped.push(sequenceEscapedBackslash);
            sequencesEscaped.push(sequenceEscapedSlash);
            sequencesEscaped.push(sequenceEscapedB);
            sequencesEscaped.push(sequenceEscapedF);
            sequencesEscaped.push(sequenceEscapedN);
            sequencesEscaped.push(sequenceEscapedR);
            sequencesEscaped.push(sequenceEscapedT);
            sequencesEscaped.push(sequenceEscapedU);
            
            CustomStartStringEndStringSequence(sequenceObject).cacheSequences();
            CustomStartStringEndStringSequence(sequenceArray).cacheSequences();
            CustomStartStringEndStringSequence(sequenceDoubleQuota).cacheSequences();
            CustomStartStringEndStringSequence(sequenceEscaped).cacheSequences();
            
            SequenceParser.parse(source, sequences);
            return result;
        }
        
        private static function append(target:Vector.<ISequence>, source:Vector.<ISequence>):void
        {
            for each(var item:ISequence in source)
                target.push(item);
        }
        
        protected function objectProperty(object:Object, property:String):void
        {
        }
        
        private function matchObjectStart(input:String):void
        {
            pendingDefinition = new ObjectDefinition(pendingDefinition);
            if(result == null)
                result = pendingDefinition.value;
        }
        
        private function matchArrayStart(input:String):void
        {
            pendingDefinition = new ArrayDefinition(pendingDefinition);
            if(result == null)
                result = pendingDefinition.value;
        }
        
        private function matchEnd(input:String):void
        {
            pendingDefinition.finalize();
            if(pendingDefinition.parent)
            {
                pendingDefinition.parent.pendingItem.valueObject = pendingDefinition.value;
                pendingDefinition = pendingDefinition.parent;
            }
        }
        
        private function matchObjectColon(input:String):void
        {
            var objectItem:ObjectItem = ObjectItem(pendingDefinition.pendingItem);
            objectItem.endName();
            objectProperty(pendingDefinition.value, objectItem.name);
        }
        
        private function matchObjectComma(input:String):void
        {
            pendingDefinition.finalizePendingItem();
            pendingDefinition.pendingItem = new ObjectItem;
        }
        
        private function matchArrayComma(input:String):void
        {
            pendingDefinition.finalizePendingItem();
            pendingDefinition.pendingItem = new ArrayItem;
        }
        
        private function matchEscapedChar(input:String):void
        {
            matchChar(input);
        }
        
        private function matchEscapedB(input:String):void
        {
            matchChar("\b");
        }
        
        private function matchEscapedF(input:String):void
        {
            matchChar("\f");
        }
        
        private function matchEscapedN(input:String):void
        {
            matchChar("\n");
        }
        
        private function matchEscapedR(input:String):void
        {
            matchChar("\r");
        }
        
        private function matchEscapedT(input:String):void
        {
            matchChar("\t");
        }
        
        private function matchEscapedU(input:String):void
        {
            var value:String = input.substr(1);
            matchChar(String.fromCharCode(parseInt(value, 16)));
        }
        
        private function matchTrue(input:String):void
        {
            if(pendingDefinition)
                pendingDefinition.pendingItem.valueBoolean = true;
            else
                result = true;
        }
        
        private function matchFalse(input:String):void
        {
            if(pendingDefinition)
                pendingDefinition.pendingItem.valueBoolean = false;
            else
                result = false;
        }
        
        private function matchNull(input:String):void
        {
            if(pendingDefinition)
                pendingDefinition.pendingItem.valueObject = null;
            else
                result = null;
        }
        
        private function matchChar(input:String):void
        {
            if(pendingDefinition)
                pendingDefinition.pendingItem.valueString = input;
            else
            {
                if(result == null)
                    result = "";
                result += input;
            }
        }
        
        private function matchNumber(input:String):void
        {
            var value:Number = parseFloat(input);
            if(pendingDefinition)
                pendingDefinition.pendingItem.valueNumber = value;
            else
                result = value;
        }
    }
}

internal class Definition
{
    public var value:Object;
    public var pendingItem:Item;
    
    private var _parent:Definition;
    
    public function Definition(parent:Definition)
    {
        _parent = parent;
    }
    
    public function get parent():Definition
    {
        return _parent;
    }
    
    public function finalize():void
    {
        finalizePendingItem();
    }
    
    public function finalizePendingItem():void
    {
    }
}

internal class ObjectDefinition extends Definition
{
    public function ObjectDefinition(parent:Definition)
    {
        super(parent);
        value = {};
        pendingItem = new ObjectItem;
    }
    
    override public function finalizePendingItem():void
    {
        if(pendingItem.isValid)
            value[(pendingItem as ObjectItem).name] = pendingItem.value;
    }
}

internal class ArrayDefinition extends Definition
{
    public function ArrayDefinition(parent:Definition)
    {
        super(parent);
        value = [];
        pendingItem = new ArrayItem;
    }
    
    override public function finalizePendingItem():void
    {
        if(pendingItem.isValid)
            value.push(pendingItem.value);
    }
}

internal class Item
{
    private var _value:Object = "";
    
    public function get value():Object
    {
        return _value;
    }
    
    public function get isValid():Boolean
    {
        return true;
    }
    
    public function set valueNumber(value:Number):void
    {
        _value = value;
    }
    
    public function set valueString(value:String):void
    {
        _value += value;
    }
    
    public function set valueObject(value:Object):void
    {
        _value = value;
    }
    
    public function set valueBoolean(value:Boolean):void
    {
        _value = value;
    }
}

internal class ObjectItem extends Item
{
    private var _name:String = "";
    private var pendingName:Boolean = true;
    
    public function get name():String
    {
        return _name;
    }
    
    public function endName():void
    {
        if(!pendingName)
            throw new Error("Unexpected end name.");
        
        pendingName = false;
    }
    
    override public function get isValid():Boolean
    {
        if(pendingName)
            throw new Error("Unexpected pending name.");
        return super.isValid;
    }
    
    override public function set valueNumber(value:Number):void
    {
        if(pendingName)
            throw new Error("Unexpected value.");
        super.valueNumber = value;
    }
    
    override public function set valueString(value:String):void
    {
        if(pendingName)
            _name += value;
        else
            super.valueString = value;
    }
}

internal class ArrayItem extends Item
{
    
}