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
    
    import sk.yoz.data.UNIPacket;
    
    public class ReceiverEvent extends Event
    {
        public static const PACKET_RECEIVED:String = "ReceiverEventPACKET_RECEIVED";
        public static const EVENT_RECEIVED:String = "ReceiverEventEVENT_RECEIVED";
        
        private var _packet:UNIPacket
        
        public function ReceiverEvent(type:String, packet:UNIPacket=null)
        {
            super(type, false, false);
            
            _packet = packet;
        }
        
        public function get packet():UNIPacket
        {
            return _packet;
        }
        
        override public function toString():String
        {
            return '[ReceiverEvent type="' + type 
                + ' packet=' + packet
                + ' bubbles=' + bubbles  + ' cancelable=' + cancelable
                + ' eventPhase=' + eventPhase + ']';
        }
    }
}