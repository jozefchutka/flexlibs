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
    
    public class MicrophoneEvent extends Event
    {
        public static const MICROPHONE_PUBLISHED:String = "MicrophoneEventMICROPHONE_PUBLISHED";
        public static const MICROPHONE_UPDATED:String = "MicrophoneEventMICROPHONE_UPDATED";
        public static const MICROPHONE_UNPUBLISHED:String = "MicrophoneEventMICROPHONE_UNPUBLISHED";
        
        private var _microphoneName:String;
        private var _microphoneCodec:String;
        private var _microphoneGain:Number;
        private var _microphoneRate:int;
        private var _microphoneEncodeQuality:int;
        
        public function MicrophoneEvent(type:String, microphoneName:String=null, 
            microphoneCodec:String=null, microphoneGain:Number=NaN, 
            microphoneRate:int=0, microphoneEncodeQuality:int=0)
        {
            super(type, false, true);
            
            _microphoneName = microphoneName;
            _microphoneCodec = microphoneCodec;
            _microphoneGain = microphoneGain;
            _microphoneRate = microphoneRate;
            _microphoneEncodeQuality = microphoneEncodeQuality;
        }
        
        public function get microphoneName():String
        {
            return _microphoneName;
        }
        
        public function get microphoneCodec():String
        {
            return _microphoneCodec;
        }
        
        public function get microphoneGain():Number
        {
            return _microphoneGain;
        }
        
        public function get microphoneRate():int
        {
            return _microphoneRate;
        }
        
        public function get microphoneEncodeQuality():int
        {
            return _microphoneEncodeQuality;
        }
        
        override public function toString():String
        {
            return '[MicrophoneEvent type="' + type + '"'
                + ' microphoneName=' + microphoneName
                + ' microphoneCodec=' + microphoneCodec 
                + ' microphoneGain=' + microphoneGain
                + ' microphoneRate=' + microphoneRate 
                + ' microphoneEncodeQuality=' + microphoneEncodeQuality
                + ' bubbles=' + bubbles + ' cancelable=' + cancelable
                + ' eventPhase=' + eventPhase + ']';
        }
    }
}