package sk.yoz.fix
{
    import flash.text.TextFieldAutoSize;
    
    import mx.controls.TextArea;
    import mx.core.mx_internal;
    
    use namespace mx_internal;
    
    public class TextAreaFix extends Object
    {
        public function TextAreaFix()
        {
            super();
        }
        
        public static function getTextHeight(textArea:TextArea):uint
        {
            /* only whent textArea.width is not percentage */
            textArea.validateNow();
            textArea.mx_internal::getTextField().autoSize = TextFieldAutoSize.LEFT;
            var height:uint = textArea.mx_internal::getTextField().height;
            //var height2:uint = textArea.mx_internal::getTextField().getLineMetrics(0).height;
            return height;
        }
        
    }
}