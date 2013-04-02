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
package org.openvideoplayer.plugins
{
	/**
	 * This is a Plug-in interface for the Open Video Player code base.
	 * 
	 * Each plug-in needs to implement this interface on it's main display object
	 * (meaning the Application in Flex or the Document Class in Flash).
	 * 
	 * There is some redundancy in the names of the methods, this is to insure
	 * there are no method name collisions with base classes or other interfaces in
	 * the plug-in's main display object.
	 *  
	 */
	public interface IOvpPlugIn
	{
		// Properties
		/**
		 * Should return the human readable name for the plug-in.
		 */
		function get ovpPlugInName():String;

		/**
		 * Should return a human readable description of the plug-in.
		 */
		function get ovpPlugInDescription():String;

		/**
		 * Should return the version of the plug-in. Note this is independent from the 
		 * property below and allows a plug-in to version itself independent of the
		 * OVP core version it is built against.
		 */
		function get ovpPlugInVersion():String;
		
		/**
		 * Should return the OVP version the plug-in was built against.
		 */
		function get ovpPlugInCoreVersion():String;

		/**
		 * Tells the plug-in to turn on/off tracing.
		 */ 
		function get ovpPlugInTracingOn():Boolean;
		function set ovpPlugInTracingOn(value:Boolean):void;

		// Methods
		/**
		 * Called from the player. Allows a plug-in to call properties, 
		 * methods, and listen for events coming from the player.
		 * 
		 * @see IOvpPlayer
		 */
		function initOvpPlugIn(player:IOvpPlayer):void;
		
	}
}
