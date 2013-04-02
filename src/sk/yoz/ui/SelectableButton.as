package sk.yoz.ui
{
    import flash.display.DisplayObject;
    import flash.display.SimpleButton;
    import flash.events.MouseEvent;
    
    public class SelectableButton extends SimpleButton
    {
        private var _selected:Boolean;
        private var _toggle:Boolean;
        
        private var _upState:DisplayObject;
        private var _overState:DisplayObject;
        
        public function SelectableButton(upState:DisplayObject=null, 
            overState:DisplayObject=null, downState:DisplayObject=null, 
            hitTestState:DisplayObject=null, toggle:Boolean=false)
        {
            super(upState, overState, downState, hitTestState);
            
            this.toggle = toggle;
            _upState = upState;
            _overState = overState;
            
            addEventListener(MouseEvent.CLICK, onClick);
        }
        
        public function set selected(value:Boolean):void
        {
            _selected = value;
            upState = selected ? downState : _upState;
            overState = selected ? downState : _overState;
        }
        
        public function get selected():Boolean
        {
            return _selected;
        }
        
        public function set toggle(value:Boolean):void
        {
            _toggle = value;
        }
        
        public function get toggle():Boolean
        {
            return _toggle;
        }
        
        private function onClick(event:MouseEvent):void
        {
            if(toggle)
                selected = !selected;
        }
    }
}