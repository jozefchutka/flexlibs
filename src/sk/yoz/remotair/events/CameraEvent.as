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
    
    public class CameraEvent extends Event
    {
        public static const CAMERA_PUBLISHED:String = "CameraEventCAMERA_PUBLISHED";
        public static const CAMERA_UPDATED:String = "CameraEventCAMERA_UPDATED";
        public static const CAMERA_UNPUBLISHED:String = "CameraEventCAMERA_UNPUBLISHED";
        
        private var _cameraName:String;
        private var _cameraWidth:uint;
        private var _cameraHeight:uint;
        private var _cameraFPS:Number;
        private var _cameraQuality:int;
        
        public function CameraEvent(type:String, cameraName:String=null, 
            cameraWidth:uint=0, cameraHeight:uint=0, cameraFPS:Number=NaN, 
            cameraQuality:int=0)
        {
            super(type, false, true);
            
            _cameraName = cameraName;
            _cameraWidth = cameraWidth;
            _cameraHeight = cameraHeight;
            _cameraFPS = cameraFPS;
            _cameraQuality = cameraQuality;
        }
        
        public function get cameraName():String
        {
            return _cameraName;
        }
        
        public function get cameraWidth():uint
        {
            return _cameraWidth;
        }
        
        public function get cameraHeight():uint
        {
            return _cameraHeight;
        }
        
        public function get cameraFPS():Number
        {
            return _cameraFPS;
        }
        
        public function get cameraQuality():int
        {
            return _cameraQuality;
        }
        
        override public function toString():String
        {
            return '[CameraEvent type="' + type + '"'
                + ' cameraName=' + cameraName
                + ' cameraWidth=' + cameraWidth + ' cameraHeight=' + cameraHeight
                + ' cameraFPS=' + cameraFPS + ' cameraQuality=' + cameraQuality
                + ' bubbles=' + bubbles + ' cancelable=' + cancelable
                + ' eventPhase=' + eventPhase + ']';
        }
    }
}