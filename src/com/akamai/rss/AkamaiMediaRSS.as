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

package com.akamai.rss {
	
	import org.openvideoplayer.parsers.ParserBase;
	import org.openvideoplayer.utilities.DateUtil;
	import org.openvideoplayer.utilities.StringUtil;
	
	import org.openvideoplayer.rss.*;
	import org.openvideoplayer.events.*;
	
	/**
	 * Dispatched when an error condition has occurred. The event provides an error number and a verbose description
	 * of each error. 
	 * 
	 * @see org.openvideoplayer.events.OvpEvent#ERROR
	 */
 	[Event (name="error", type="org.openvideoplayer.events.OvpEvent")]
	/**
	 * Dispatched when the RSS response has been successfully parsed. 
	 * 
	 * @eventType org.openvideoplayer.events.OvpEvent.PARSED
	 */
 	[Event (name="parsed", type="org.openvideoplayer.events.OvpEvent")]
 	
	/**
	 * The AkamaiMediaRSS class loads a Media RSS playlist, parses it and makes utility
	 * properties and methods available which expose the contents of that feed.
	 *  
	 */
	public class AkamaiMediaRSS extends ParserBase {

		// Declare vars
		private var _title:String;
		private var _description:String;
		private var _imageUrl:String;
		private var _itemCount:Number;
		private var _itemArray:Array;
		private var _filterFields:RSSFilterFields;
		private var _filterPattern:RegExp;
		private var _filterDate:Date;
		private var _filterDateMatch:int;
		
		//Declare constants
		public const VERSION:String = "1.0";
		public const FILTER_ANY:int = 1;
		public const FILTER_ALL:int = 2;
		public const FILTER_DATE_LEQ:int = 1;	// For Date filtering; less than or equal to
		public const FILTER_DATE_GEQ:int = 2;	// For Date filtering; greater than or equal to
		
		// Declare namespaces
		private var mediaNs:Namespace;
		
		/**
		 * Constructor
		 */
		public function AkamaiMediaRSS():void {
			super();
		}
	
		/**
		 * The RSS item at the given index. 
		 * 
		 */
		public function getItemAt(i:uint):ItemTO {
			return _itemArray[i];
		}
		/**
		 * The title of the RSS feed 
		 * 
		 */
		public function get title():String {
			return _title;
		}
		/**
		 * The description of the RSS feed 
		 * 
		 */
		public function get description():String {
			return _description;
		}
		/**
		 * The image URL of the feed
		 * 
		 */
		public function get imageUrl():String {
			return _imageUrl;
		}
		/**
		 * The number of items in the feed 
		 * 
		 */
		public function get itemCount():Number {
			return _itemCount;
		}
		/**
		 * The items as an array of ItemTO objects 
		 * 
		 */
		public function get itemArray():Array {
			return _itemArray;
		}
		/**
		 * The items as an XMLList
		 * 
		 */
		public function get itemXmlList():XMLList{
			return XMLList(_xml.channel.item);
		}
		/**
		 * Returns a filtered play list, allowing text filtering or date filtering. The properties in the 
		 * <code>FilterFields</code> class allow you to specify which RSS fields will be used for the filtering.
		 * 
		 * Calling this method with both <code>filterText</code> and <code>filterDate</code> arguments will essentially result
		 * in a double-filtering: the results of the text filter are then filtered again using the date filter. 
		 * 
		 * For date filtering the <code>filterMatch</code> argument is ignored.
		 * 
		 * @return An array containing the filtered list or <code>null</code> if no matching items were found.
		 *
		 * @param filterText The text string to search for in the item list of RSS feeds.
		 * @param filterFields A FilterFields object specifying which fields in the item list of RSS feeds to search. If this argument 
		 * is null, all fields will be searched. 
		 * @param filterMatch Either <code>FILTER_ANY</code> or <code>FILTER_ALL</code>. <code>FILTER_ANY</code> will find a match if
		 * any string contained in the <code>filterText</code> argument is found in any of the <code>filterFields</code> specified.
		 * <code>FILTER_ALL</code> will find a match only if the entire string is found in any of the <code>filterFields</code> specified.
		 * @param filterDate A date to search for in the item list of RSS feeds that contain dates. If the <code>filterFields</code> argument
		 * is null, all fields containing dates will be searched. In order for the 'less than or equal to' comparison to work as expected,
		 * we will set the time of this object to midnight if the hours, minutes, and seconds are all equal to zero. If this is not the
		 * desired behavior, set the seconds to 1 on the Date object before calling this method.
		 * @param filterDateMatch Either <code>FILTER_DATE_LEQ</code> specifying 'less than or equal to', or <code>FILTER_DATE_GEQ</code> specifying
		 * 'greater than or equal to'.
		 */
		public function filterItemList(filterText:String, filterFields:RSSFilterFields=null, filterMatch:int=FILTER_ANY,
										filterDate:Date=null, filterDateMatch:int=FILTER_DATE_LEQ):Array {
			var resultArr:Array = null;
			var useResultArray:Boolean = false;

			_filterFields = filterFields;

			if (filterText && filterText != "") {
				resultArr = filterItemListText(filterText, filterMatch);
				useResultArray = true;
			}
			if (filterDate) {
				var tempResultArr:Array = filterItemListDate((useResultArray ? resultArr:null), filterDate, filterDateMatch);
				resultArr = tempResultArr;
			}
			return resultArr;									
		}
		/** Filter method for finding dates in the item array
		 * @private
		 */
		private function filterItemListDate(arr:Array, filterDate:Date, filterMatch:int):Array {
			var filterArr:Array = arr ? arr : _itemArray;
			
			if (_filterFields == null) {
				_filterFields = new RSSFilterFields();
				_filterFields.pubDate = true;
			}
			_filterDate = filterDate;
			_filterDateMatch = filterMatch;
			
			return filterArr.filter(findFilterDate);
		}
		/**
		 * The date filter method for each individual item in the item list.
		 * @private
		 */
		private function findFilterDate(item:ItemTO, index:int, arr:Array):Boolean {
			if (item.pubDate && filterCompareDate(item.pubDate))
				return true;
			return false;
		}				
		/**
		 * The compare function for an individual date used by the filter functionality. 
		 * @private
		 */
		private function filterCompareDate(rssField:String):Boolean {
			var tempDate:String = rssField.replace(/-/g, "/");
			var ms:Number = Date.parse(tempDate);
			var rssFieldDate:Date = new Date(ms);
			
			// In order for the 'less than or equal to' compare to work as expected with the default time settings of the Date object, we
			// need to set the time to midnight on the date specified.
			if ((_filterDateMatch == FILTER_DATE_LEQ) && (_filterDate.hours == 0) && (_filterDate.minutes == 0) && (_filterDate.seconds == 0)) {
				_filterDate.hours = 23;
				_filterDate.minutes = 59;
				_filterDate.seconds = 59;
			}
			
			var compResult:Number = DateUtil.compare(rssFieldDate, _filterDate);
			if (compResult == 0)
				return true;	// The dates are equal
				
			switch (_filterDateMatch) {
				case FILTER_DATE_LEQ:
					if (compResult == -1)	// Less than
						return true;
					break;
				case FILTER_DATE_GEQ:
					if (compResult == 1)	// Greater than
						return true;
					break;
			}
			return false;
		}	
		/** Filter method for finding text in the item array
		 * @private
		 */
		private function filterItemListText(filterText:String, filterMatch:int):Array {
			if (!_itemArray || !_itemArray.length)
				return null;
				
			if (_filterFields == null) {
				_filterFields = new RSSFilterFields();
				_filterFields.setAll(true);
			}
			// Remove leading and trailing white spaces
			filterText = StringUtil.trim(filterText);
			
			var _tempPattern:String = new String;

			if (filterMatch == FILTER_ANY)
			{
				var _filterText:Array = filterText.split(' ');
				if (_filterText.length == 0)
					return null;
				
				for (var i:int = 0; i < _filterText.length; i++) {
					var _tempString:String = StringUtil.trim(_filterText[i]);
					if (_tempString.length == 0)
						continue;
					_tempPattern += _tempString; 
					if (i != (_filterText.length-1))
						_tempPattern += '|';
				}
			}
			else
				_tempPattern = filterText;
			
			_filterPattern = null;
			_filterPattern = new RegExp(_tempPattern, "gi");
						
			return _itemArray.filter(findFilterText);
		}
		/**
		 * The text filter method for each individual item in the item list.
		 * @private
		 */
		private function findFilterText(item:ItemTO, index:int, arr:Array):Boolean {			
			if (_filterFields.author && filterCompare(item.author))
				return true;
			if (_filterFields.description && filterCompare(item.description))
				return true;
			if (_filterFields.enclosureType && filterCompare(item.enclosure.type))
				return true;
			if (_filterFields.enclosureURL && filterCompare(item.enclosure.url))
				return true;
				
			var i:int;

			if (_filterFields.mediaContentExpression) {
				for (i = 0; i < item.media.contentArray.length; i++) {
					if (filterCompare(item.media.contentArray[i].expression))
						return true;
				}	
			}
			if (_filterFields.mediaContentIsDefault) {
				for (i = 0; i < item.media.contentArray.length; i++) {
					if (filterCompare(item.media.contentArray[i].isDefault))
						return true;
				}
			}
			if (_filterFields.mediaContentLang) {
				for (i = 0; i < item.media.contentArray.length; i++) {
					if (filterCompare(item.media.contentArray[i].lang))
						return true;
				}
			}
			if (_filterFields.mediaContentMedium) {
				for (i = 0; i < item.media.contentArray.length; i++) {
					if (filterCompare(item.media.contentArray[i].medium))
						return true;
				}
			}
			if (_filterFields.mediaContentType) {
				for (i = 0; i < item.media.contentArray.length; i++) {
					if (filterCompare(item.media.contentArray[i].type))
						return true;
				}
			}
			if (_filterFields.mediaContentURL) {
				for (i = 0; i < item.media.contentArray.length; i++) {
					if (filterCompare(item.media.contentArray[i].url))
						return true;
				}
			}
			if (_filterFields.mediaCopyright && filterCompare(item.media.copyright))
				return true;
			if (_filterFields.mediaDescription && filterCompare(item.media.description))
				return true;
			if (_filterFields.mediaKeywords && filterCompare(item.media.keywords))
				return true;
			if (_filterFields.mediaThumbnailTime) {
				for (i = 0; i < item.media.thumbnailArray.length; i++) {
					if (filterCompare(item.media.thumbnailArray[i].time))
						return true;
				}
			}
			if (_filterFields.mediaThumbnailURL) {
				for (i = 0; i < item.media.thumbnailArray.length; i++) {
					if (filterCompare(item.media.thumbnailArray[i].url))
						return true;
				}
			}
			if (_filterFields.mediaTitle && filterCompare(item.media.title))
				return true;
			if (_filterFields.pubDate && filterCompare(item.pubDate))
				return true;
			if (_filterFields.title && filterCompare(item.title))
				return true;

			return false;
		}
		/**
		 * The compare function for an individual string used by the filter functionality. 
		 * @private
		 */
		private function filterCompare(str:String):int {
			var _matchArray:Array = str.match(_filterPattern);
			if (_matchArray)
				return _matchArray.length;
			return 0;
		}	
	
		/** Parses the RSS xml feed into useful properties
		 * @private
		 */
		override protected function parseXML():void {
			_busy = false;
			if (!verifyRSS(_xml)) {
				dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.XML_MEDIARSS_MALFORMED)));
			} else {
				mediaNs = _xml.namespace("media");
				_title=_xml.channel.title;
				_description=_xml.channel.description;
				_imageUrl=_xml.channel.image.url;
				_itemCount=_xml.channel.item.length();
				_itemArray=new Array  ;
				for (var i:uint = 0; i < _itemCount; i++) {
					var item:ItemTO=new ItemTO();
					item.title=_xml.channel.item[i].title;
					item.author=_xml.channel.item[i].author;
					item.description=_xml.channel.item[i].description;
					item.pubDate=_xml.channel.item[i].pubDate;
					var enclosure:EnclosureTO = new EnclosureTO();
					enclosure.url =_xml.channel.item[i].enclosure.@url;
					enclosure.length=Number(_xml.channel.item[i].enclosure.@length.toString());
					enclosure.type=_xml.channel.item[i].enclosure.@type;
					item.enclosure = enclosure;
					if (_xml.channel.item[i].mediaNs::group == undefined) {
						item.media = buildMediaObject(_xml.channel.item[i]);
					
					} else {
						item.media = buildMediaObject(XML(_xml.channel.item[i].mediaNs::group));
						
					}
					_itemArray.push(item);
					
				}
				dispatchEvent(new OvpEvent(OvpEvent.PARSED));
			}
			
		}
		private function buildMediaObject(node:XML):Media {
				var media:Media = new Media();
				for (var k:uint=0;k<node.mediaNs::thumbnail.length();k++) {
					// It is possible for media items to contain mutiple thumbnail definitions.
					// Here we opt to take the first item found.
					var thumbnail:ThumbnailTO = new ThumbnailTO();
					thumbnail.url = node.mediaNs::thumbnail[k].@url;
					thumbnail.height = Number(node.mediaNs::thumbnail[k].@height);
					thumbnail.width = Number(node.mediaNs::thumbnail[k].@width);
					thumbnail.time = node.mediaNs::thumbnail[k].@width;
					media.thumbnailArray.push(thumbnail);
				}
				for (var i:uint=0;i<node.mediaNs::content.length();i++) {
					var content:ContentTO = new ContentTO();
					content.fileSize=Number(node.mediaNs::content[i].@fileSize);
					content.type=node.mediaNs::content[i].@type;
					content.medium=node.mediaNs::content[i].@medium;
					content.isDefault=node.mediaNs::content[i].@isDefault;
					content.expression=node.mediaNs::content[i].@expression;
					content.bitrate=Number(node.mediaNs::content[i].@bitrate);
					content.framerate=Number(node.mediaNs::content[i].@framerate);
					content.samplingrate=Number(node.mediaNs::content[i].@samplingrate);
					content.channels=node.mediaNs::content[i].@channels;
					content.duration=node.mediaNs::content[i].@duration;
					content.height=Number(node.mediaNs::content[i].@height);
					content.width=Number(node.mediaNs::content[i].@width);
					content.lang = node.mediaNs::content[i].@lang;
					content.url =node.mediaNs::content[i].@url;
					media.contentArray.push(content);
				}
				media.title = node.mediaNs::title;
				media.description = node.mediaNs::description;
				media.copyright = node.mediaNs::copyright;
				media.keywords = node.mediaNs::keywords;
				media.thumbnail = media.thumbnailArray[0];
				//
				return media;
			
		}
		/** A simple verification routine to check if the XML received conforms
		 * to some basic RSS requirements. This routine does not validate against
		 * the DTD.
		 * @private
		 */
		private function verifyRSS(src:XML):Boolean {
			var verified:Boolean = true;
			if (src.@version == undefined) {
				verified = false;
			}
			if (src.channel.title == undefined || src.channel.link == undefined || src.channel.description == undefined) {
				verified = false;
			}
			if (src.channel.item is XMLList) {
				for each (var item:XML in _xml.channel.item) {
					if (item.title == undefined && item.description == undefined) {
						verified = false;
					}
				}

			} else {
				if (src.channel.item != undefined && src.channel.item.title == undefined && src.channel.item.description == undefined) {
					verified = false;
				}
			}
			return verified;
		}

	}
}
