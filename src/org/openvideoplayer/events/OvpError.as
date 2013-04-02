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

package org.openvideoplayer.events
{
	/**
	 * The OvpError class contains all of the error codes and descriptions for the Open Video Player code base.
	 * 
	 * <p/>
	 * Use this class with the OvpEvent class to dispatch error events, such as:
	 * <p/>
	 * <listing>
	 * dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.STREAM_NOT_FOUND)));
	 * </listing>
	 * 
	 * <p/>
	 * The listener for the error event can use the methods in this class to get the error number and the description, such as:
	 * <p/>
	 * <listing>
	 * private function errorHandler(e:OvpEvent):void {
	 * &#xA0;&#xA0;&#xA0;&#xA0;////trace("Error event [" + e.data.errorNumber+ "]: " + e.data.errorDescription);
	 * }
	 * </listing>
	 * 
	 * @see OvpEvent 
	 */
	public class OvpError
	{
		/**
		 * A method was given an empty hostname.
		 */
		public static const HOSTNAME_EMPTY:uint 			= 1;
		/**
		 * Invalid buffer length value.
		 */
		public static const BUFFER_LENGTH:uint 				= 2;
		/**
		 * Protocol is not supported.
		 */
		public static const PROTOCOL_NOT_SUPPORTED:uint 	= 3;
		/**
		 * Port is not supported.
		 */
		public static const PORT_NOT_SUPPORTED:uint 		= 4;
		/**
		 * ident request failure.
		 */
		public static const IDENT_REQUEST_FAILED:uint 		= 5;
		/**
		 * Connection attempt timed out.
		 */
		public static const CONNECTION_TIMEOUT:uint 		= 6;
		/**
		 * Stream is not defined, therefore unable to play, pause, seek or resume.
		 */
		public static const STREAM_NOT_DEFINED:uint			= 8;
		/**
		 * A time out occurred while trying to find the stream.
		 */
		public static const STREAM_NOT_FOUND:uint			= 9;
		/**
		 * Could not successfully request the stream length.
		 */
		public static const STREAM_LENGTH_REQ_ERROR:uint	= 10;
		/**
		 * Value for volume is out of range.
		 */
		public static const VOLUME_OUT_OF_RANGE:uint		= 11;
		/**
		 * A network failure has occured
		 */
		public static const NETWORK_FAILED:uint				= 12;
		/**
		 * An HTTP load attempt failed.
		 */
		public static const HTTP_LOAD_FAILED:uint			= 14;
		/**
		 * XML is not properly formatted.
		 */
		public static const XML_MALFORMED:uint				= 15;
		/**
		 * The XML does not conform to the Media RSS standard.
		 */
		public static const XML_MEDIARSS_MALFORMED:uint		= 16;
		/** 
		 * The class is busy with a task and cannot process your request.
		 */
		public static const CLASS_BUSY:uint					= 17;
		/**
		 * The XML does not conform to the Akamai BOSS standard.
		 */
		public static const XML_BOSS_MALFORMED:uint			= 18;
		/**
		 * Error requesting the fast start feature on a stream.
		 */
		public static const STREAM_FASTSTART_INVALID:uint	= 19;
		/**
		 * Time out occurred trying to load an XML file.
		 */
		public static const XML_LOAD_TIMEOUT:uint			= 20;
		/**
		 * A stream IO error has occurred.
		 */
		public static const STREAM_IO_ERROR:uint			= 21;
		/**
		 * The stream buffer has remained empty past a time out threshold.
		 */
		public static const STREAM_BUFFER_EMPTY:uint		= 24;
		/**
		 * Invalid cue point name.
		 */
		public static const INVALID_CUEPOINT_NAME:uint		= 25;
		/**
		 * Invalid cue point time.
		 */
		public static const INVALID_CUEPOINT_TIME:uint		= 26;
		/**
		 * Invalid cue point object.
		 */
		public static const INVALID_CUEPOINT:uint			= 27;
		/**
		 * Invalid stream index requested.
		 */
		public static const INVALID_INDEX:uint				= 28;
		/**
		 * Invalid argument passed to a property or method.
		 */
		public static const INVALID_ARGUMENT:uint			= 29;	
		/**
		 * Invalid caption font size.
		 */
		public static const INVALID_CAPTION_FONT_SIZE:uint	= 30;
		
		private static const _errorMap:Array = [
			{n:HOSTNAME_EMPTY, 			d:"Hostname cannot be empty"}, 
			{n:BUFFER_LENGTH, 			d:"Buffer length must be > 0.1"},
			{n:PROTOCOL_NOT_SUPPORTED, 	d:"Warning - this protocol is not supported"},
			{n:PORT_NOT_SUPPORTED, 		d:"Warning - this port is not supported"},
			{n:IDENT_REQUEST_FAILED, 	d:"Warning - unable to load XML data from ident request, will use domain name to connect"},
			{n:CONNECTION_TIMEOUT, 		d:"Timed out while trying to connect"},
			{n:STREAM_NOT_DEFINED, 		d:"Cannot play, pause, seek, or resume since the stream is not defined"},
			{n:STREAM_NOT_FOUND, 		d:"Timed out trying to find the stream"},
			{n:STREAM_LENGTH_REQ_ERROR,	d:"Error requesting stream length"},
			{n:VOLUME_OUT_OF_RANGE, 	d:"Volume value out of range"},
			{n:NETWORK_FAILED, 			d:"Network failure - unable to play the live stream"},
			{n:HTTP_LOAD_FAILED,		d:"HTTP loading operation failed"},
			{n:XML_MALFORMED,			d:"XML is not well formed"},
			{n:XML_MEDIARSS_MALFORMED,	d:"XML does not conform to Media RSS standard"},
			{n:CLASS_BUSY,				d:"Class is busy and cannot process your request"},
			{n:XML_BOSS_MALFORMED,		d:"XML does not conform to BOSS standard"},
			{n:STREAM_FASTSTART_INVALID,d:"The Fast Start feature cannot be used with live streams"},
			{n:XML_LOAD_TIMEOUT,		d:"Timed out trying to load the XML file"},
			{n:STREAM_IO_ERROR,			d:"NetStream IO Error event"},
			{n:STREAM_BUFFER_EMPTY,		d:"NetStream buffer has remained empty past timeout threshold"}, 
			{n:INVALID_CUEPOINT_NAME, 	d:"Invalid cue point name - cannot be null or undefined"},
			{n:INVALID_CUEPOINT_TIME,	d:"Invalid cue point time - must be a number greater than zero"},
			{n:INVALID_CUEPOINT,		d:"Invalid cue point object - must contain a 'name' and 'time' properties"},
			{n:INVALID_INDEX,			d:"Attempting to switch to an invalid index in a multi-bitrate stream"},
			{n:INVALID_ARGUMENT,		d:"Invalid argument passed to property or method"},
			{n:INVALID_CAPTION_FONT_SIZE,	d:"Invalid caption font size specified. '%', '+', '-' are not supported"} ];

			
		private var _num:uint;
		private var _desc:String;
		
		/**
		 * Constructor. Give it one of the public constant error codes defined in this class 
		 * and it will look up the corresponding description.
		 */
		public function OvpError(errorCode:uint)
		{
			_num = errorCode;
			_desc = "";
			
			for (var i:uint = 0; i < _errorMap.length; i++) {
				if (_errorMap[i].n == _num) {
					_desc = _errorMap[i].d;
					break;
				}
			}
		}
		
		/**
		 * The error number for the error dispatched. This should be one of the public constants defined in this class.
		 */
		public function get errorNumber():uint { return _num; }
		
		/**
		 * The error description for the error dispatched.
		 */
		public function get errorDescription():String { return _desc; }
	}
}
