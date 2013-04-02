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
	 * Represents formatting for a caption object. Typical use for this class would be to format a UI component's
	 * html text using a TextRange object in Flex, or Flash developers might use the setTextFormat method of the TextField class.
	 */
	public class CaptionFormat
	{
		private var _startIndex:int;
		private var _endIndex:int;
		private var _styleObj:Style;
		
		/**
		 * Creates a CaptionFormat object specifying the Style object and the zero-based start and end indices of the range.
		 * 
		 * @param styleObj The instance of the org.openvideoplayer.cc.Style object to apply.
		 * @param start The optional zero-based index position specifying the first character of the desired range of text. Default is to start with the first character.
		 * @param end The optional zero-based index position specifying the last character of the desired range of text. Default is to end with the last character.
		 */
		public function CaptionFormat(styleObj:Style, start:int=-1, end:int=-1)
		{
			_startIndex = start;
			_endIndex = end;
			_styleObj = styleObj;
		}
		
		/**
		 *  Get the start index supplied to the constructor.
		 */
		public function get startIndex():int {
			return _startIndex;
		}
		
		/**
		 * Get the end index supplied to the constructor.
		 */
		public function get endIndex():int {
			return _endIndex;
		}
		
		/**
		 * Get the style object supplied to the constructor.
		 */
		public function get styleObj():Style {
			return _styleObj;
		}
	}
}
