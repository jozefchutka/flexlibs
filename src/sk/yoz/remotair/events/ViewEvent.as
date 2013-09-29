/*
Copyright (c) 2009-2010 Jozef Chutka
 
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package sk.yoz.remotair.events
{
    import flash.events.Event;
    
    public class ViewEvent extends Event
    {
        public static const CHANGE:String = "ViewEventCHANGE";
        
        private var _viewClass:String;
        
        public function ViewEvent(type:String, viewClass:String)
        {
            super(type, false, false);
            _viewClass = viewClass;
        }
        
        public function get viewClass():String
        {
            return _viewClass;
        }
        
        override public function toString():String
        {
            return '[ViewEvent type="' + type + '"'
                + ' viewClass=' + viewClass
                + ' bubbles=' + bubbles + ' cancelable=' + cancelable 
                + ' eventPhase=' + eventPhase + ']';
        }
    }
}