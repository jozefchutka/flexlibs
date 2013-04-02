package sk.yoz.font
{
    import flash.text.Font;
    
    import mx.collections.ArrayCollection;
    import mx.collections.Sort;
    import mx.collections.SortField;
    import mx.controls.ComboBox;
    import mx.events.FlexEvent;
    import mx.events.ListEvent;
    
    public class FontList extends ComboBox
    {
        private var fontList:ArrayCollection;
        
        [Bindable]
        public var selectedFont:String;
        
        public function FontList()
        {
            super();
            addEventListener(FlexEvent.CREATION_COMPLETE, listCreated);
            addEventListener(ListEvent.CHANGE, changeHandler);
        }
        
        public function changeHandler(event:ListEvent):void
        {
            selectedFont = selectedItem.fontName;
        }
        
        public function selectFont(fontName:String):void
        {
            if(!dataProvider)
                return;
                
            var list:ArrayCollection = dataProvider as ArrayCollection;
            var i:uint = list.length;
            while(i--)
                if(dataProvider[i].fontName == fontName)
                    selectedIndex = i;
        }
        
        override public function set selectedItem(value:Object):void
        {
            super.selectedItem = value;
            selectedFont = value.fontName;
        }
        
        private function listCreated(event:FlexEvent):void{
            fontList = new ArrayCollection(Font.enumerateFonts(true));
            labelField = "fontName";
            var fontSort:Sort = new Sort();
            fontSort.fields = [new SortField("fontName")];
            fontList.sort = fontSort;
            fontList.refresh();
            dataProvider = fontList;
            
            if(!selectedFont)
                selectedFont = fontList[0].fontName;
            else
                selectFont(selectedFont);
        }
    }
}
