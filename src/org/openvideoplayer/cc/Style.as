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
	 * Represents a Caption Style.
	 * 
	 * @see org.openvideoplayer.parsers.DfxpParser
	 * @see Caption
	 * @see CaptionFormat
	 */
	public class Style
	{
		private var _id:String;
		private var _backgroundColor:String;
		private var _color:String;
		private var _fontFamily:String;
		private var _fontSize:uint;
		private var _fontStyle:String;
		private var _fontWeight:String;
		private var _textAlign:String;
		private var _wrapOption:Boolean;
		
		/**
		 * Creates a Style object.
		 * 
		 * @param id The ID is usually provided when read from the DFXP file in the head section.
		 * 
		 * @see org.openvideoplayer.parsers.DfxpParser
		 */
		public function Style(id:String)
		{
			_id = id;
			_backgroundColor = _color = "";
			_fontFamily = "";
			_fontSize = 0;
			_fontStyle = "";
			_fontWeight = "";
			_textAlign = "";
			_wrapOption = true;
		}
		
		/**
		 * Get the ID passed to the constructor.
		 */
		public function get id():String {
			return _id;
		}
		
		/**
		 * The background color for the control rendering the captioning text.
		 */
		public function get backgroundColor():String {
			return _backgroundColor;
		}
		public function set backgroundColor(value:String):void {
			_backgroundColor = value;
		}
		
		/**
		 * The text color of the caption.
		 */
		public function get color():String {
			return _color;
		}
		public function set color(value:String):void {
			_color = value;
		}
		
		/**
		 * The font family.
		 */
		public function get fontFamily():String {
			return _fontFamily;
		}
		public function set fontFamily(value:String):void {
			_fontFamily = value;
		}
		
		/**
		 * The font size in pixels.
		 */
		public function get fontSize():uint {
			return _fontSize;
		}
		public function set fontSize(value:uint):void {
			_fontSize = value;
		}
		
		/**
		 * The font style, normal or italic.
		 */
		public function get fontStyle():String {
			return _fontStyle;
		}
		public function set fontStyle(value:String):void {
			_fontStyle = value;
		}
		
		/**
		 * The font weight, normal or bold.
		 */
		public function get fontWeight():String {
			return _fontWeight;
		}
		public function set fontWeight(value:String):void {
			_fontWeight = value;
		}
		
		/**
		 * The text alignment, left, center, or right.
		 */
		public function get textAlign():String {
			return _textAlign;
		}
		public function set textAlign(value:String):void {
			_textAlign = value;
		}
		
		/**
		 * The word wrap option.
		 */
		public function get wrapOption():Boolean {
			return _wrapOption;
		}
		public function set wrapOption(value:Boolean):void {
			_wrapOption = value;
		}

	}
}
