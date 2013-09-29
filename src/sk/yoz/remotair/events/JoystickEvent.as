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
    
    public class JoystickEvent extends Event
    {
        public static const CHANGE:String = "JoystickEventCHANGE";
        
        private var _joystickID:uint;
        private var _x:Number;
        private var _y:Number;
        
        public function JoystickEvent(type:String, joystickID:uint, x:Number, y:Number)
        {
            super(type, false, true);
            _joystickID = joystickID;
            _x = x;
            _y = y;
        }
        
        public function get joystickID():uint
        {
            return _joystickID;
        }
        
        public function get x():Number
        {
            return _x;
        }
        
        public function get y():Number
        {
            return _y;
        }
        
        override public function toString():String
        {
            return '[JoystickEvent type="' + type + '"'
                + ' joystickID=' + joystickID + ' x=' + x + ' y=' + y 
                + ' bubbles=' + bubbles  + ' cancelable=' + cancelable
                + ' eventPhase=' + eventPhase + ']';
        }
    }
}