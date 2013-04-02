//
// Copyright (c) 2009-2010, the Open Video Player authors. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without 
// modification, are permitted provided that the following conditions are 
// met:
//
//    * Redistributions of source code must retain the above copyright 
//		notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above 
//		copyright notice, this list of conditions and the following 
//		disclaimer in the documentation and/or other materials provided 
//		with the distribution.
//    * Neither the name of the openvideoplayer.org nor the names of its 
//		contributors may be used to endorse or promote products derived 
//		from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

package org.openvideoplayer.utilities
{
	import flash.system.Capabilities;
	
	/**
	 *  The FlashPlayer utility class is an all-static class.
	 *  You do not create instances of this class;
	 *  instead you call methods such as 
	 *  the <code>FlashPlayer.version()</code> method.  
	 */	public class FlashPlayer
	{
		/**
		 * Fills in the object passed in with the following:
		 * <ul>
		 * <li> versionInfo.os - string containing "WIN", "MAC", or "UNIX"</li>
		 * <li> versionInfo.major - major version as an integer for easy comparison</li>
		 * <li> versionInfo.minor - minor version as an integer</li>
		 * <li> versionInfo.build - build number as an integer</li>
		 * </ul>
		 */
		public static function version(versionInfo:Object):void {

			var _ver:String = Capabilities.version;
			var _aVer:Array = _ver.split(",");
			var _aOSandMajor:Array = _aVer[0].split(" ");
	
			versionInfo.os = _aOSandMajor[0];
			versionInfo.major = parseInt(_aOSandMajor[1]);
			versionInfo.minor = parseInt(_aVer[1]);
			versionInfo.build = parseInt(_aVer[2]);	
		}
	}
}
