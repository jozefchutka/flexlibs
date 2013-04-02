package sk.yoz.text
{
    import flash.events.EventDispatcher;
    import flash.text.TextField;
    
    public class LinkedTextFields extends EventDispatcher
    {
        public static const DEFAULT_TEXT_DELIMITER:RegExp = /(\s)/;
        public static const DEFAULT_HTML_DELIMITER:RegExp = /([\s<>])/;
        
        public var autoRender:Function = null;
        public var textDelimiter:RegExp;
        public var htmlDelimiter:RegExp;
        
        protected var list:Array = [];
        protected var _text:String;
        
        public function LinkedTextFields(autoRender:Function = null, 
            delimiter:RegExp = null, htmlDelimiter:RegExp = null)
        {
            super();
            
            this.autoRender = autoRender;
            this.textDelimiter = textDelimiter 
                ? textDelimiter 
                : DEFAULT_TEXT_DELIMITER;
            this.htmlDelimiter = htmlDelimiter 
                ? htmlDelimiter 
                : DEFAULT_HTML_DELIMITER;
        }
        
        public function set text(value:String):void
        {
            _text = value;
            if(autoRender != null)
                autoRender();
        }
        
        public function get text():String
        {
            return _text;
        }
        
        public function add(textField:TextField, index:int = -1):void
        {
            if(index == -1)
                list.push(textField);
            else
                list.splice(index, 0, textField);
            if(autoRender != null)
                autoRender();
        }
        
        public function remove(textField:TextField):void
        {
            var index:int = list.indexOf(textField);
            if(index != -1)
                list.splice(index, 1);
            if(autoRender != null)
                autoRender();
        }
        
        public function renderText():void
        {
            emptyTextFields("text");
            if(!this.text)
                return;
            
            var chunk:String, prevText:String;
            var chunks:Array = text.split(textDelimiter);
            var textField:TextField = list[0];
            var last:Boolean = !nextTextField(textField);
            
            while(chunks.length)
            {
                chunk = chunks.shift();
                if(chunk == "\r")
                    chunk = "\n";
                prevText = textField.text;
                textField.appendText(chunk);
                if(!last && textField.maxScrollV > 1)
                {
                    textField.text = prevText;
                    textField = nextTextField(textField);
                    textField.text = chunk;
                    if(!nextTextField(textField))
                        last = true;
                }
            }
        }
        
        public function renderHtmlText():void
        {
            emptyTextFields("htmlText");
            if(!this.text)
                return;
            
            var chunk:String, text:String = "", prevText:String;
            var chunks:Array = this.text.split(htmlDelimiter);
            var textField:TextField = list[0];
            var last:Boolean = !nextTextField(textField);
            var tag:String = "", tagName:String, isTag:Boolean, tags:Array = [];
            
            while(chunks.length)
            {
                chunk = chunks.shift();
                    
                if(chunk == "<")
                    isTag = true;
                    
                if(isTag && tag == "<")
                {
                    tagName = chunk.toLowerCase();
                    if(tagName.substr(0, 1) == "/")
                        removeLastTag(tags, tagName.substr(1));
                    else
                        addTag(tags, tagName);
                }
                
                if(isTag)
                    tag += chunk;
                    
                if(isTag && chunk == ">")
                {
                    isTag = false;
                    if(tag.substr(-2) == "/>" || tagName == "br")
                        removeLastTag(tags, tagName);
                    else if(tag.substr(0, 2) != "</")
                        addLastTagDefinition(tags, tag);
                    chunk = tag;
                    tag = "";
                }
                
                if(isTag)
                    continue;
                
                prevText = text;
                text += chunk;
                textField.htmlText = text + writeAllTagClosage(tags);
                
                if(last || textField.maxScrollV <= 1)
                    continue;
                
                textField.htmlText = prevText + writeAllTagClosage(tags);
                textField = nextTextField(textField);
                text = writeAllTagDefinitions(tags) + chunk;
                if(!nextTextField(textField))
                    last = true;
            }
            
            textField.htmlText = text + writeAllTagClosage(tags);
            
        }
        
        public function emptyTextFields(type:String = "text"):void
        {
            for each(var textField:TextField in list)
                textField[type == "text" ? type : "htmlText"] = "";
        }
        
        protected function addTag(list:Array, tagName:String):void
        {
            list.push({name:tagName});
        }
        
        protected function addLastTagDefinition(list:Array, definition:String)
            :void
        {
            list[list.length - 1].definition = definition;
        }
        
        protected function writeAllTagDefinitions(list:Array):String
        {
            var definitions:String = "";
            for each(var item:Object in list)
                definitions += item.definition;
            return definitions;
        }
        
        protected function writeAllTagClosage(list:Array):String
        {
            var closage:String = "";
            for(var i:int = list.length - 1; i >= 0; i--)
                closage += "</" + list[i].name + ">";
            return closage;
        }
        
        protected function removeLastTag(list:Array, tagName:String):void
        {
            if(list[list.length - 1].name == tagName)
                list.splice(list.length - 1, 1);
        }
        
        protected function nextTextField(textField:TextField):TextField
        {
            var index:int = list.indexOf(textField);
            if(index == -1 || index + 1 >= list.length)
                return null;
            return list[index + 1];
        }
    }
}