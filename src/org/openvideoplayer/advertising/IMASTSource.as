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
package org.openvideoplayer.advertising
{
	/**
	 * IMASTSource represents the source or the payload
	 * of the MAST document.
	 */ 
	public interface IMASTSource
	{
		/**
		 *  The URI to retrieve a source from, for example a link to a VAST document
		 */		
		function get uri():String;
		function set uri(value:String):void;
		
		/**
		 * This is used to key the source against a resource already known by the
		 * player. To prevent collisions it can be keyed with the URI when possible.
		 */		
		function get altReference():String;
		function set altReference(value:String):void;
		
		/**
		 * The format this source is in, to be used to determine a handler for the 
		 * payload. Examples might include 'vast', 'uif', etc.
		 */		
		function get format():String;
		function set format(value:String):void;
	
		/**
		 * Child targets of this source.
		 */
		function get targets():Array;
		
		/**
		 * Child sources of this source.
		 */
		function get sources():Array;
		
	}
}
