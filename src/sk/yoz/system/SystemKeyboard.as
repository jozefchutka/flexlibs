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
package sk.yoz.system
{
    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.filesystem.File;
    
    public class SystemKeyboard
    {
        public function SystemKeyboard()
        {
        }
        
        public static function event(path:String, keyCode:uint):void
        {
            var file:File = File.applicationDirectory.resolvePath(path);
            
            var args:Vector.<String> = new Vector.<String>();
            args.push(keyCode.toString());
            
            var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
            info.executable = file;
            info.arguments = args;
            
            var process:NativeProcess = new NativeProcess();
            process.start(info);
        }
    }
}

/* 
-------------------------------------------------------------------------------
C++ code for KeyboardEvent.cpp - version for windows:

#include "stdafx.h"
#include <windows.h>

int main(int argc, const char * argv[])
{
    keybd_event(atoi(argv[1]), 0, KEYEVENTF_EXTENDEDKEY | 0, 0);
    keybd_event(atoi(argv[1]), 0, KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP, 0);
}

*/