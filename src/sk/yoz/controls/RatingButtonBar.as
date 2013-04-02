package sk.yoz.controls
{
    import flash.events.MouseEvent;
    
    import mx.controls.Button;
    import mx.controls.ButtonBar;
    
    public class RatingButtonBar extends ButtonBar
    {
        private var indexChanged:Boolean = false;
        private var suggestedIndex:int = -2;
        private var rollOverPhase:Object;
        private var rollOutPhase:Object;
        
        public function RatingButtonBar()
        {
            super();
        }
        
        override protected function createChildren():void
        {
            super.createChildren();
            selectValue(suggestedIndex != -2 ? suggestedIndex : selectedIndex);
            var children:Array = getChildren();
            for each(var button:Button in children)
            {
                button.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
                button.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
            }
        }
        
        override public function set selectedIndex(value:int):void
        {
            super.selectedIndex = value;
            suggestedIndex = value;
            selectValue(value);
        }
        
        protected function selectValue(value:int):void
        {
            if(value != selectedIndex)
            {
                selectedIndex = value;
                return;
            }
            var children:Array = getChildren();
            var index:uint = 0;
            var selected:Boolean = value != -1;
            var out:String = MouseEvent.ROLL_OUT;
            for each(var button:Button in children)
            {
                button.selected = selected;
                if(selected)
                    button.dispatchEvent(new MouseEvent(out, false, true));
                if(index++ == value)
                    selected = false;
            }
        }
        
        protected function overValue(value:int):void
        {
            var children:Array = getChildren();
            var index:uint = 0;
            var out:String = MouseEvent.ROLL_OUT;
            var over:String = MouseEvent.ROLL_OVER;
            for each(var button:Button in children)
            {
                if(index != value && !button.selected)
                    button.dispatchEvent(new MouseEvent(out, false, true));
                if(index++ < value && !button.selected)
                    button.dispatchEvent(new MouseEvent(over, false, true));
            }
        }
        
        override protected function clickHandler(event:MouseEvent):void
        {
            super.clickHandler(event);
            var children:Array = getChildren();
            selectValue(children.indexOf(event.target));
        }
        
        protected function rollOverHandler(event:MouseEvent):void
        {
            var children:Array = getChildren();
            var flag:Object = {};
            if(!rollOverPhase)
                rollOverPhase = flag;
            if(rollOverPhase != flag)
                return;
            overValue(children.indexOf(event.target));
            rollOverPhase = null;
        }
        
        protected function rollOutHandler(event:MouseEvent):void
        {
            if(rollOverPhase)
                return;
            
            var flag:Object = {};
            if(!rollOutPhase)
                rollOutPhase = flag;
            if(rollOutPhase != flag)
                return;
            overValue(-1);
            rollOutPhase = null;
        }
    }
}