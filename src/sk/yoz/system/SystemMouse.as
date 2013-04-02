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
    
    public class SystemMouse
    {
        public static const MOUSE_LEFT_DOWN:String = "LEFTDOWN";
        public static const MOUSE_LEFT_UP:String = "LEFTUP";
        public static const MOUSE_LEFT_CLICK:String = "LEFTCLICK";
        public static const MOUSE_RIGHT_DOWN:String = "RIGHTDOWN";
        public static const MOUSE_RIGHT_UP:String = "RIGHTUP";
        public static const MOUSE_RIGHT_CLICK:String = "RIGHTCLICK";
        
        public function SystemMouse()
        {
        }
        
        public static function moveBy(path:String, x:Number, y:Number):void
        {
            var file:File = File.applicationDirectory.resolvePath(path);
            
            var args:Vector.<String> = new Vector.<String>();
            args.push(x.toString());
            args.push(y.toString());
            
            var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
            info.executable = file;
            info.arguments = args;
            
            var process:NativeProcess = new NativeProcess();
            process.start(info);
        }
        
        public static function event(path:String, flag:String):void
        {
            var file:File = File.applicationDirectory.resolvePath(path);
            
            var args:Vector.<String> = new Vector.<String>();
            args.push(flag);
            
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
C++ code for MouseEvent.cpp - version for windows:

#include "stdafx.h"
#include <windows.h>

int main(int argc, const char * argv[])
{
	int dwFlags;
	
	if(strcmp(argv[1], "LEFTDOWN") == 0)
	{
		dwFlags = MOUSEEVENTF_LEFTDOWN;
	}
	else if(strcmp(argv[1], "LEFTUP") == 0)
	{
		dwFlags = MOUSEEVENTF_LEFTUP;
	}
	else if(strcmp(argv[1], "LEFTCLICK") == 0)
	{
		dwFlags = MOUSEEVENTF_LEFTDOWN | MOUSEEVENTF_LEFTUP;
	}

	if(strcmp(argv[1], "RIGHTDOWN") == 0)
	{
		dwFlags = MOUSEEVENTF_RIGHTDOWN;
	}
	else if(strcmp(argv[1], "RIGHTUP") == 0)
	{
		dwFlags = MOUSEEVENTF_RIGHTUP;
	}
	else if(strcmp(argv[1], "RIGHTCLICK") == 0)
	{
		dwFlags = MOUSEEVENTF_RIGHTDOWN | MOUSEEVENTF_RIGHTUP;
	}


	if(dwFlags > 0)
	{
		mouse_event(dwFlags, 0, 0, 0, 0);
	}
}
-------------------------------------------------------------------------------
C++ code for SetCursorPos.cpp - version for windows:

#include "stdafx.h"
#include <windows.h>

int main(int argc, const char * argv[])
{
	POINT pt;
    GetCursorPos(&pt);
	SetCursorPos(pt.x + atoi(argv[1]), pt.y + atoi(argv[2]));
}

*/