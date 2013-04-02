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

package org.openvideoplayer.cc
{
	/**
	 * Represents a caption, including text and style formatting information, as well as when to show the caption and when to hide it.
	 */
	public class Caption
	{
		private var _id:uint;
		private var _begin:uint;	// Begin display in seconds
		private var _end:uint;		// End display in seconds
		private var _caption:String;// Text to display, can contain embedded html tags, such as <br>
		private var _captionFormats:Array;
		
		/**
		 * Creates a Caption.
		 */
		public function Caption(id:uint, start:uint, end:uint, text:String) {
			_id = id;
			_begin = start;
			_end = end;
			_caption = text;
			_captionFormats = new Array();
		}	
		
		/**
		 * The ID supplied to the constructor when the Caption was created.
		 */
		public function get id():uint {
			return _id;
		}
		
		/**
		 * Start time in seconds.
		 */
		public function get startTime():uint {
			return _begin;
		}
		
		/**
		 * End time in seconds.
		 */
		public function get endTime():uint {
			return _end;
		}
				
		/**
		 * Caption text. This could contain html display tags, such as &lt;br/&gt;, so best
		 * to assign to a control's htmlText property.
		 */
		public function get text():String {
			return _caption;
		}
		
		/**
		 * A caption can contain several format objects, this method returns the count of format objects
		 * for this particual caption.
		 */
		public function captionFormatCount():uint {
			return _captionFormats.length;
		}
		
		/**
		 * Returns the CaptionFormat object at the specified index or null if not found.
		 */
		public function getCaptionFormatAt(index:uint) : CaptionFormat {
			if (index < _captionFormats.length) {
				return _captionFormats[index];
			}
			return null;
		}
		
		/**
		 * Adds a caption format object for this caption.
		 */
		public function addCaptionFormat(cf:CaptionFormat):void {
			_captionFormats.push(cf);
		}
	}
}
