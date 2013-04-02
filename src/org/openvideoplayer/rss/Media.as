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
	

	import flash.events.EventDispatcher;
	
	/**
	 * The Media class holds the data referenced by the media namespace in a RSS file. 
	 * This class is used by the XxxMediaRSS class and is not invoked directly by
	 * end users.<p/>
	 * The properties in this class (with the exception of <code>ContentArray</code>) are defined by the Media RSS specification which can
	 * be viewed at <a href="http://search.yahoo.com/mrss" target="_blank">http://search.yahoo.com/mrss</a>.
	 * 
	 */
	public class Media extends EventDispatcher{
		/**
		 * An array of ContentTO objects. If the parent item contains a group tag, then
		 * each content source within that group tag is added to this array. For items
		 * without a group tag, the array length will be 1 and it will a hold a single entry
		 * which is the content tag contained within that item. Use the utility function
		 * <code>getContentAt(index:uint)</code> to retrieve a specific ContentTO object with
		 * the correct type. 
		 * 
		 */
		public var contentArray:Array;
		public var copyright:String;
		public var title:String;
		public var description:String;
		public var keywords:String;
		/**
		 * The first item in the thumbnailArray. Provided for backwards compatibility.
		 * 
		 */
		public var thumbnail:ThumbnailTO;
		/**
		 * An array of ThumnbnailTO objects, since it is permissable for RSS feeds to reference 
		 * multiple thumbnails for each content item. 
		 * 
		 */
		public var thumbnailArray:Array;
		
		/**
		 * Constructor
		 * 
		 */
		public function Media():void {
			contentArray = new Array();
			thumbnailArray = new Array();
		}
		/**
		 * Returns the ContentTO object at the requested index.
		 * 
		 * @see org.openvideoplayer.rss.ContentTO
		 */
		public function getContentAt(index:uint):ContentTO {
			return ContentTO(contentArray[index]);
		}
	}
}
