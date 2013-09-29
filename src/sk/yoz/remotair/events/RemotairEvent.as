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
    
    public class RemotairEvent extends Event
    {
        public static const STAGE_SIZE:String = "RemotairEventSTAGE_SIZE";
        public static const INIT_REMOTE_DESKTOP:String = "RemotairEventINIT_REMOTE_DESKTOP";
        public static const TEXT_CHANGE:String = "RemotairEventTEXT_CHANGE";
        
        public static const MOUSE_LEFT_DOWN:String = "RemotairEventMOUSE_LEFT_DOWN";
        public static const MOUSE_LEFT_UP:String = "RemotairEventMOUSE_LEFT_UP";
        public static const MOUSE_LEFT_CLICK:String = "RemotairEventMOUSE_LEFT_CLICK";
        public static const MOUSE_LEFT_ROLL_OUT:String = "RemotairEventMOUSE_LEFT_ROLL_OUT";
        
        public static const MOUSE_RIGHT_DOWN:String = "RemotairEventMOUSE_RIGHT_DOWN";
        public static const MOUSE_RIGHT_UP:String = "RemotairEventMOUSE_RIGHT_UP";
        public static const MOUSE_RIGHT_CLICK:String = "RemotairEventMOUSE_RIGHT_CLICK";
        public static const MOUSE_RIGHT_ROLL_OUT:String = "RemotairEventMOUSE_RIGHT_ROLL_OUT";
        
        private var _data:Object;
        
        public function RemotairEvent(type:String, data:Object = null)
        {
            super(type, false, false);
            
            _data = data;
        }
        
        public function get data():Object
        {
            return _data;
        }
        
        override public function toString():String
        {
            return '[ReceiverEvent type="' + type 
                + ' data=' + data
                + ' bubbles=' + bubbles  + ' cancelable=' + cancelable
                + ' eventPhase=' + eventPhase + ']';
        }
    }
}