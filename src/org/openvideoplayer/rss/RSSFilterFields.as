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

package org.openvideoplayer.rss {
	/**
	 * The FilterFields class is used by the <code>filterItemList</code> method in the XxxMediaRSS class.
	 * This class provides the caller of the <code>filterItemList</code> method with a simple way to specify 
	 * which fields to search in a media RSS feed.<p/>
	 * The Media RSS specification can be viewed at <a href="http://search.yahoo.com/mrss" target="_blank">http://search.yahoo.com/mrss</a>.
	 */
	public class RSSFilterFields
	{	
		private var _title:Boolean;
		private var _author:Boolean;
		private var _description:Boolean;
		private var _pubDate:Boolean;
		private var _enclosureType:Boolean;
		private var _enclosureURL:Boolean;
		private var _mediaContentType:Boolean;
		private var _mediaContentMedium:Boolean;
		private var _mediaContentIsDefault:Boolean;
		private var _mediaContentExpression:Boolean;
		private var _mediaContentLang:Boolean;
		private var _mediaContentURL:Boolean;
		private var _mediaCopyright:Boolean;
		private var _mediaTitle:Boolean;
		private var _mediaDescription:Boolean;
		private var _mediaKeywords:Boolean;
		private var _mediaThumbnailTime:Boolean;
		private var _mediaThumbnailURL:Boolean;
		
		/**
		 * Constructor
		 * 
		 */
		public function RSSFilterFields() {
			setAll(false);
		}

		/**
		 * Sets all fields to either true or false depending on the argument.
		 * 
		 */
		public function setAll(value:Boolean):void {
			_title = 
			_author = 
			_description = 
			_pubDate = 
			_enclosureType = 
			_enclosureURL = 
			_mediaContentType = 
			_mediaContentMedium = 
			_mediaContentIsDefault = 
			_mediaContentExpression = 
			_mediaContentLang = 
			_mediaContentURL = 
			_mediaCopyright = 
			_mediaTitle = 
			_mediaDescription = 
			_mediaKeywords = 
			_mediaThumbnailTime = 
			_mediaThumbnailURL = value;
		}
		
		public function set title(value:Boolean) : void { _title = value; }
		public function get title() : Boolean { return _title; }

		public function set author(value:Boolean) : void { _author = value; }
		public function get author() : Boolean { return _author; }

		public function set description(value:Boolean) : void { _description = value; }
		public function get description() : Boolean { return _description; }

		public function set pubDate(value:Boolean) : void { _pubDate = value; }
		public function get pubDate() : Boolean { return _pubDate; }

		public function set enclosureType(value:Boolean) : void { _enclosureType = value; }
		public function get enclosureType() : Boolean { return _enclosureType; }

		public function set enclosureURL(value:Boolean) : void { _enclosureURL = value; }
		public function get enclosureURL() : Boolean { return _enclosureURL; }

		public function set mediaContentType(value:Boolean) : void { _mediaContentType = value; }
		public function get mediaContentType() : Boolean { return _mediaContentType; }

		public function set mediaContentMedium(value:Boolean) : void { _mediaContentMedium = value; }
		public function get mediaContentMedium() : Boolean { return _mediaContentMedium; }

		public function set mediaContentIsDefault(value:Boolean) : void { _mediaContentIsDefault = value; }
		public function get mediaContentIsDefault() : Boolean { return _mediaContentIsDefault; }

		public function set mediaContentExpression(value:Boolean) : void { _mediaContentExpression = value; }
		public function get mediaContentExpression() : Boolean { return _mediaContentExpression; }

		public function set mediaContentLang(value:Boolean) : void { _mediaContentLang = value; }
		public function get mediaContentLang() : Boolean { return _mediaContentLang; }

		public function set mediaContentURL(value:Boolean) : void { _mediaContentURL = value; }
		public function get mediaContentURL() : Boolean { return _mediaContentURL; }

		public function set mediaCopyright(value:Boolean) : void { _mediaCopyright = value; }
		public function get mediaCopyright() : Boolean { return _mediaCopyright; }

		public function set mediaTitle(value:Boolean) : void { _mediaTitle = value; }
		public function get mediaTitle() : Boolean { return _mediaTitle; }

		public function set mediaDescription(value:Boolean) : void { _mediaDescription = value; }
		public function get mediaDescription() : Boolean { return _mediaDescription; }

		public function set mediaKeywords(value:Boolean) : void { _mediaKeywords = value; }
		public function get mediaKeywords() : Boolean { return _mediaKeywords; }

		public function set mediaThumbnailTime(value:Boolean) : void { _mediaThumbnailTime = value; }
		public function get mediaThumbnailTime() : Boolean { return _mediaThumbnailTime; }

		public function set mediaThumbnailURL(value:Boolean) : void { _mediaThumbnailURL = value; }		
		public function get mediaThumbnailURL() : Boolean { return _mediaThumbnailURL; }	
	}
}
