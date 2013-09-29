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
package sk.yoz.remotair.data
{
    import flash.events.AccelerometerEvent;
    import flash.events.ActivityEvent;
    import flash.events.GeolocationEvent;
    import flash.events.GestureEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.PressAndTapGestureEvent;
    import flash.events.TextEvent;
    import flash.events.TouchEvent;
    import flash.events.TransformGestureEvent;
    import flash.utils.getQualifiedClassName;
    
    import sk.yoz.remotair.events.CameraEvent;
    import sk.yoz.remotair.events.JoystickEvent;
    import sk.yoz.remotair.events.MicrophoneEvent;
    import sk.yoz.remotair.events.RemotairEvent;
    import sk.yoz.remotair.events.ViewEvent;
    
    public class Serializer
    {
        public function Serializer(){}
        
        public static function unserialize(className:String, rawData:Object):Object
        {
            with(rawData)
            switch(className)
            {
                case "flash.events::MouseEvent":
                    return new MouseEvent(type, false, true, localX, localY);
                case "flash.events::KeyboardEvent":
                    return new KeyboardEvent(type, false, true, charCode, 
                        keyCode);
                case "flash.events::TextEvent":
                    return new TextEvent(type, false, true, text);
                case "flash.events::ActivityEvent":
                    return new ActivityEvent(type, false, true, activating)
                case "flash.events::AccelerometerEvent":
                    return new AccelerometerEvent(type, false, true, timestamp, 
                        accelerationX, accelerationY, accelerationZ);
                case "flash.events::TouchEvent":
                    return new TouchEvent(type, false, true, touchPointID, 
                        isPrimaryTouchPoint, localX, localY, sizeX, sizeY, 
                        pressure);
                case "flash.events::GestureEvent":
                    return new GestureEvent(type, false, true, phase, 
                        localX, localY);
                case "flash.events::PressAndTapGestureEvent":
                    return new PressAndTapGestureEvent(type, false, true,
                        phase, localX, localY, tapLocalX, tapLocalY);
                case "flash.events::TransformGestureEvent":
                    return new TransformGestureEvent(type, false, true,
                        phase, localX, localY, scaleX, scaleY, rotation,
                        offsetX, offsetY);
                case "flash.events::GeolocationEvent":
                    return new GeolocationEvent(type, false, true, latitude, 
                        longitude, altitude, horizontalAccuracy, 
                        verticalAccuracy, speed, heading, timestamp);
                case "remotair.events::ViewEvent":
                    return new ViewEvent(type, viewClass);
                case "sk.yoz.remotair.events::JoystickEvent":
                    return new JoystickEvent(type, joystickID, x, y);
                case "sk.yoz.remotair.events::CameraEvent":
                    return new CameraEvent(type, cameraName, cameraWidth, 
                        cameraHeight, cameraFPS, cameraQuality);
                case "sk.yoz.remotair.events::MicrophoneEvent":
                    return new MicrophoneEvent(type, microphoneName, 
                        microphoneCodec, microphoneGain, microphoneRate, 
                        microphoneEncodeQuality);
                case "sk.yoz.remotair.events::RemotairEvent":
                    return new RemotairEvent(type, data);
                default:
                    return data;
            }
        }
        
        public static function serialize(rawData:Object):Object
        {
            var className:String = getQualifiedClassName(rawData);
            with(rawData)
            switch(className)
            {
                case "flash.events::MouseEvent":
                    return {type:type, localX:localX, localY:localY};
                case "flash.events::KeyboardEvent":
                    return {type:type, charCode:charCode, keyCode:keyCode};
                case "flash.events::TextEvent":
                    return {type:type, text:text};
                case "flash.events::ActivityEvent":
                    return {type:type, activating:activating};
                case "flash.events::AccelerometerEvent":
                    return {type:type, timestamp:timestamp, 
                        accelerationX:accelerationX, accelerationY:accelerationY, 
                        accelerationZ:accelerationZ};
                case "flash.events::TouchEvent":
                    return {type:type, touchPointID:touchPointID, 
                        isPrimaryTouchPoint:isPrimaryTouchPoint, 
                        localX:localX, localY:localY, sizeX:sizeX, sizeY:sizeY, 
                        pressure:pressure};
                case "flash.events::GestureEvent":
                    return {type:type, phase:phase, localX:localX, 
                        localY:localY};
                case "flash.events::PressAndTapGestureEvent":
                    return {type:type, phase:phase, 
                        localX:localX, localY:localY, 
                        tapLocalX:tapLocalX, tapLocalY:tapLocalY};
                case "flash.events::TransformGestureEvent":
                    return {type:type, phase:phase, localX:localX, 
                        localY:localY, scaleX:scaleX, scaleY:scaleY, 
                        rotation:rotation, offsetX:offsetX, offsetY:offsetY};
                case "flash.events::GeolocationEvent":
                    return {type:type, latitude:latitude, longitude:longitude, 
                        altitude:altitude, horizontalAccuracy:horizontalAccuracy, 
                        verticalAccuracy:verticalAccuracy, speed:speed, 
                        heading:heading, timestamp:timestamp};
                case "remotair.events::ViewEvent":
                    return {type:type, viewClass:getQualifiedClassName(viewClass)};
                case "sk.yoz.remotair.events::JoystickEvent":
                    return {type:type, joystickID:joystickID, x:x, y:y};
                case "sk.yoz.remotair.events::CameraEvent":
                    return {type:type, cameraName:cameraName, 
                        cameraWidth:cameraWidth, cameraHeight:cameraHeight, 
                        cameraFPS:cameraFPS, cameraQuality:cameraQuality};
                case "sk.yoz.remotair.events::MicrophoneEvent":
                    return {type:type, microphoneName:microphoneName, 
                        microphoneCodec:microphoneCodec, 
                        microphoneGain:microphoneGain, 
                        microphoneRate:microphoneRate, 
                        microphoneEncodeQuality:microphoneEncodeQuality};
                case "sk.yoz.remotair.events::RemotairEvent":
                    return {type:type, data:data};
                default:
                    return data;
            }
        }
    }
}