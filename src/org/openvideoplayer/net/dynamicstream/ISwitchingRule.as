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

package org.openvideoplayer.net.dynamicstream
{
	import flash.events.IEventDispatcher;
	
	/**
	 * Rules Interface
     * Defines an interface for heuristics switching rules to implement in order
     * to be callable by the managing dynamic stream class. 
	 */
	public interface ISwitchingRule extends IEventDispatcher {
		

		/**
		 * Returns the index value in the active DSI to which this heuristics implementation thinks
		 * the bitrate should shift.  It's up to the calling function to act on this. This index 
		 * will range in value from -1 to n-1,where n is the number of bitrate items available.
		 * A value of -1 means that this rule does not suggest a switch away from the current item. A
		 * value from 0 to n-1 indicates that the caller should switch to that index immediately.
		 */
        function getNewIndex():int;
		
		/**
		 * Returns the reason the rule is suggesting the new index. This information is intended to be read by humans
		 * and may be used during the debugging process. 
		 */
		function get reason():String;
    }
}
