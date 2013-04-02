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

package org.openvideoplayer.parsers
{
	import flash.events.Event;
	
	import org.openvideoplayer.cc.Caption;
	import org.openvideoplayer.cc.CaptionFormat;
	import org.openvideoplayer.cc.Style;
	import org.openvideoplayer.events.*;
	
	/**
	 * Dispatched when an error condition has occurred. The event provides an error number and a verbose description
	 * of each error. 
	 * @see org.openvideoplayer.events.OvpEvent#ERROR
	 */
 	[Event (name="error", type="org.openvideoplayer.events.OvpEvent")]
	/**
	 * Dispatched when the DFXP response has been successfully parsed. 
	 * 
	 * @see org.openvideoplayer.events.OvpEvent#PARSED
	 */
 	[Event (name="parsed", type="org.openvideoplayer.events.OvpEvent")]
		
	/**
	 * This class parses XML files for the purpose of providing closed captioning and supports 
	 * a subset of the W3C Timed Text Authoring Format 1.0 - Distribution Format Exchange Profile (DFXP).
	 * 
	 * The subset supported by this class is specified here:
	 * <ul>
	 *	<li> <strong>tt</strong> tag</li>
	 * 		<ul>
	 * 			<li> All attributes of the tt tag are ignored.</li>
	 * 			<li> <strong>head</strong> tag</li>
	 * 			<ul>
	 * 				<li> head tag is not required.</li>
	 * 				<li> <strong>metadata</strong> tag is supported. The title, description, and copyright attribute values are available via properties of this class.</li>
	 * 				<li> <strong>layout</strong> tag and any child tags are ignored.</li>
	 * 				<li> <strong>styling</strong> tag is supported.</li>
	 * 				<ul>
	 * 					<li> <strong>style</strong> tags are supported.</li>
	 * 					<ul>
	 * 						<li> Each style tag must have a unique ID and the following attributes are supported:</li>
	 * 						<ul>
	 * 							<li>tts:fontFamily</li>
	 * 							<li>tts:fontSize</li>
	 * 							<ul>
	 * 								<li> Support for only one value. If two vales are present only the first is used.</li>
	 * 								<li> Units are ignored, pixels are assumed.</li>
	 * 								<li> Percentage is not supported (e.g. 50%) and will cause an OvpError.INVALID_CAPTION_FONT_SIZE to be dispatched.</li>
	 * 								<li> Increment/decrement is not supported (e.g. +5) and will cause an OvpError.INVALID_CAPTION_FONT_SIZE to be dispatched.</li>
	 * 							</ul>
	 * 							<li>tts:fontStyle</li>
	 * 							<li>tts:fontWeight</li>
	 * 							<li>tts:textAlign</li>
	 * 							<li>tts:wrapOption</li>
	 * 							<li>tts:backgroundColor</li>
	 * 							<li>tts:color</li>
	 * 						</ul>
	 * 					</ul>
	 * 				</ul>
	 * 			</ul>
	 * 			<li> <strong>body</strong> tag</li>
	 * 			<ul>
	 * 				<li> body tag is required.</li>
	 * 				<li> Only one body tag is supported.</li>
	 * 				<li> All attributes of the body tag are ignored.</li>
	 * 				<li> <strong>div</strong> tag</li>
	 * 				<ul>
	 * 					<li> Supported but is not required.</li>
	 * 					<li> Support for one div tag only.</li>
	 * 					<li> All attributes of the div tag are ignored.</li>
	 * 					<li> <strong>p</strong> tag</li>
	 * 					<ul>
	 * 						<li> Support for one or many.</li>
	 * 						<li> p tags contain the caption text and optionally any styles.</li>
	 * 						<li> Support for the attributes begin, dur, and end only. All other attributes are ignored.</li> 
	 * 						<ul>
	 * 							<li> If begin is absent, zero is assumed.</li> 
	 * 							<li> If both dur and end are present, dur will be ignored.</li>
	 * 							<li> The following time values are supported:</li>
	 * 						</ul>
	 * 						<ul>
	 * 							<li> full clock format in "hours:minutes:seconds:fraction" (e.g. 00:03:00:00).</li>
	 * 							<li> offset time (e.g. 10s for ten seconds or 1m for one minute).</li>
	 * 							<li> offset times without units (e.g. 10) are assumed to be seconds.</li>
	 * 						</ul>
	 * 						<li> styles can be 'inline', using a span tag, or referenced with a style ID</li>
	 * 						<li> <strong>span</strong> tags are supported.</li>
	 * 						<ul>
	 * 							<li> suppport for style attributes only, all other attributes are ignored.</li>
	 * 							<li> nested span tags are not supported.</li>
	 * 						</ul>
	 * 						<li> The <strong>br</strong> tag is supported.</li>
	 * 				</ul>
	 * 			</ul>
	 * 		</ul>
	 * 	</li>
	 * </ul>
	 * 
	 * <p>
	 * Captioning is implemented in OVP using dynamic cue points, also known as ActionScript cue points. This class creates a collection of light weight cue point objects,
	 * each with a unique ID. This class also creates a collection of Caption objects which can be a little bit heavier since they can contain styling. When the DFXP file has been 
	 * parsed, this class dispatches an OvpEvent.PARSED event.
	 * </p>
	 * 
	 * @see org.openvideoplayer.cc.OvpCCManager
	 * @see org.openvideoplayer.cc.Caption
	 * @see org.openvideoplayer.net.OvpCuePointManager
	 * 
	 */
	public class DfxpParser extends ParserBase {
		
		private var _cuePointObjs:Array;
		private var _captionObjs:Array;
		private var _styleObjs:Array;
		private var _title:String;
		private var _desc:String;
		private var _copyright:String;
		private var _ns:Namespace;
		private var _ttm:Namespace;
		private var _tts:Namespace;
		private var _saveXMLIgnoreWhitespace:Boolean;
		private var _saveXMLPrettyPrinting:Boolean;
		
		/**
		 * @private
		 */ 
		public static const _CC_CUE_POINT_NAME_PREFIX_:String = "org.openvideoplayer.cc_";
		
		/**
		 * Creates a new DfxpParser object.
		 */
		public function DfxpParser():void {
			super();
			
			_cuePointObjs = new Array();
			_captionObjs = new Array();
			_styleObjs = new Array();	
		}
				
		/**
		 * Returns a count of cue point objects this class created.
		 */
		public function cuePointObjectCount():uint {
			return _cuePointObjs.length;
		}
		
		/** 
		 * Returns the cue point object at the specified index.
		 */
		public function cuePointObjectAt(index:uint):Object {
			if (index < _cuePointObjs.length) {
				return _cuePointObjs[index];
			}
			return null;
		}
		
		/**
		 * Returns a count of caption objects this class has created.
		 */
		public function captionObjectCount():uint {
			return _captionObjs.length;
		}
		
		/** 
		 * Returns the caption object at the specified index.
		 */
		public function captionObjectAt(index:uint):Caption {
			if (index < _captionObjs.length) {
				return _captionObjs[index];
			}
			return null;
		}
		
		/**
		 * The title, if it was found in the metadata in the header.
		 */
		public function get title():String {
			return _title;
		}
		
		/**
		 * The description, if it was found in the metadata in the header.
		 */
		public function get description():String {
			return _desc;
		}
		
		/**
		 * The copyright, if it was found in the metadata in the header.
		 */
		public function get copyright():String {
			return _copyright;
		}
		
		/**
		 * @private
		 */
		override protected function xmlLoaded(e:Event):void {
			_timeoutTimer.stop();

			_saveXMLIgnoreWhitespace = XML.ignoreWhitespace;
			_saveXMLPrettyPrinting = XML.prettyPrinting;

			_rawData = e.currentTarget.data.toString();
			
			// Remove line ending whitespaces
			var xmlStr:String = e.currentTarget.data.replace(/\s+$/, "");
			
			// Remove whitespaces between tags
			xmlStr = xmlStr.replace(/>\s+</g, "><");

			// Replace cr/lf with lf
			xmlStr = xmlStr.replace(/\r\n/g, "\n");

			XML.ignoreWhitespace = false;
			XML.prettyPrinting = false;
			
			try {
				_xml = new XML(xmlStr);
				
				XML.ignoreWhitespace = _saveXMLIgnoreWhitespace;
				XML.prettyPrinting = _saveXMLPrettyPrinting;		
					
				dispatchEvent(new OvpEvent(OvpEvent.LOADED));
				parseXML();
			} catch (err:Error) {
				_busy = false;
				dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.XML_MALFORMED)));
			}	
		}
		
		/**
		 * @private
		 */
		override protected function parseXML():void {
			_ns = _xml.namespace();
			_ttm = _xml.namespace("ttm");
			_tts = _xml.namespace("tts");
			
			try {
				parseHead();
				parseBody();		
			}
			catch (err:Error) {
				throw err;
			}
			finally {
				_busy = false;			
			}
			
			dispatchEvent(new OvpEvent(OvpEvent.PARSED));
		}
		
		private function parseHead():void {
			// Metadata - not required
			try {
				_title = _xml.._ttm::title.text();
				_desc = _xml.._ttm::desc.text();
				_copyright = _xml.._ttm::copyright.text();
			}
			catch (err:Error) {
				// Catch only this one: "Error #1080: Illegal value for namespace."
				if (err.errorID != 1080) {
					throw err;
				}
			}
			
			// Styles - not required
			var styling:XMLList = _xml.._ns::styling;
			
			if (styling.length()) {
				var styles:XMLList = styling.children();
				for (var i:uint = 0; i < styles.length(); i++) {
					var styleNode:XML = styles[i];
					var styleObj:Style = createStyleObject(styleNode);
					
					_styleObjs.push(styleObj);
				}
			}			
		}
		
		/**
		 * Creates a Style from a style node.
		 */
		private function createStyleObject(styleNode:XML):Style {
			var id:String = styleNode.@*::id;
			
			var styleObj:Style = new Style(id);
			
			var color:String = styleNode.@_tts::backgroundColor;
			if (color != "") {
				styleObj.backgroundColor = color;					
			}
			styleObj.textAlign = styleNode.@_tts::textAlign;
			
			color = styleNode.@_tts::color;
			if (color != "") {
				styleObj.color = color; 					
			}
			
			styleObj.fontFamily = parseFontFamily(styleNode.@_tts::fontFamily);
			
			var fontSize:String = parseFontSize(styleNode.@_tts::fontSize);
			styleObj.fontSize = parseInt(fontSize);
			
			styleObj.fontStyle = styleNode.@_tts::fontStyle;
			styleObj.fontWeight = styleNode.@_tts::fontWeight;
			styleObj.wrapOption = (String(styleNode.@_tts::wrapOption).toLowerCase() == "nowrap") ? false : true;

			return styleObj;			
		}
			
		private function parseFontSize(rawFontSize:String):String {
			if (!rawFontSize || rawFontSize == "") {
				return "";
			}	
			
			// Check for percentage, e.g., 50%
			var perRegExp:RegExp = new RegExp(/^\s*\d+%.*$/);
			var perResult:Object = perRegExp.exec(rawFontSize);
						
			if (perResult) {
				// Percentages not supported
				dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.INVALID_CAPTION_FONT_SIZE)));
				return "";	
			}
			
			// Check for increment, e.g., +5
			var incRegExp:RegExp = new RegExp(/^\s*[\+\-]\d.*/);
			var incResult:Object = incRegExp.exec(rawFontSize);
			
			if (incResult) {
				// Increment not supported
				dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.INVALID_CAPTION_FONT_SIZE)));
				return "";
			}
			
			var regExp:RegExp = new RegExp(/^\s*(\d+).*$/);
			var result:Object = regExp.exec(rawFontSize);
			
			if (result && (result[1] != undefined)) {
				var tempStr:String = result[1];
				
				return result[1];
			}
			return "";
		}
		
		private function parseFontFamily(rawFontFamily:String):String {
			if (!rawFontFamily || rawFontFamily == "") {
				return "";
			}
			var retVal:String = "";
			var regExp:RegExp = new RegExp(/^\s*([^,\s]+)\s*((,\s*([^,\s]+)\s*)*)$/);
			var done:Boolean = false;
			
			do {
				var result:Object = regExp.exec(rawFontFamily);
				if (!result) {
					done = true;
				}
				else {
					if (retVal.length > 0) {
						retVal += ",";
					} 
					
					// These generic family names are right out of the W3C spec. We need to map them to one of the Flash player's
					// three default fonts: "_sans", "_serif", and "_typewriter". The Flash player will find the closest font
					// on the user's system at run-time.
					switch (result[1]) {
						case "default":
						case "serif":
						case "proportionalSerif":
							retVal += "_serif";
							break;					
							
						case "monospace":
						case "monospaceSansSerif":
						case "monospaceSerif":
							retVal += "_typewriter";
							break;
							
						case "sansSerif":
						case "proportionalSansSerif":
							retVal += "_sans";
							break;
							
						default:
							retVal += result[1];
							break;
					}
					
					if ((result[2] != undefined) && (result[2] != "")) {
						rawFontFamily = result[2].slice(1);
					}
					else {
						done = true;
					}
				}
				
			} while (!done);
			
			return retVal;			
		}
		
		private function parseBody():void {
			// The <body> tag is required
			var body:XMLList = _xml.._ns::body;
			if (!body.length()) {
				dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.XML_MALFORMED)));
				return;
			}
			
			// Support for one <div> tag only, but it is not required
			var div:XMLList = _xml.._ns::div;
			
			// Support for 1 to many <p> tags, these tags contain the timing info, they can appear in any order
			var p:XMLList = div.length() ? div.children() : (body.length() ? body.children() : new XMLList());
			
			// Captions should be in <p> tags
			for (var i:uint = 0; i < p.length(); i++) {
				var pNode:XML = p[i];
				parsePTag(pNode, i);
			}			
		}
		
		private function parsePTag(pNode:XML, index:uint):void {
			// For timing attributes, we support 'begin', 'dur', 'end', all others are ignored.
			// If the attribute 'begin' is missing, we default to zero.
			// If both 'dur' and 'end' are present, the 'end' attribute is used
			
			var begin:String = pNode.@begin;
			var end:String = pNode.@end;
			var dur:String = pNode.@dur;
										
			// If no 'begin' default to 0 seconds
			if (begin == "") {
				begin = "0s";
			}
			
			// Format begin in seconds
			var beginSecs:Number = formatTime(begin);
			
			var endSecs:Number = 0;
			
			// If we found both 'end' and 'dur', ignore 'dur'
			if (end != "") {
				endSecs = formatTime(end);
			}
			else if (dur != "") {
				endSecs = beginSecs + formatTime(dur);
			}
						
			// Create the cue point and the caption object		
			var cuePointItem:Object = new Object();
			cuePointItem.id = index;
			cuePointItem.time = beginSecs;
			cuePointItem.name = _CC_CUE_POINT_NAME_PREFIX_ + index;
			_cuePointObjs.push(cuePointItem);			
			
			var captionFormatList:Array = new Array();

			// Create the caption text, we don't support nested span tags
			var text:String = new String("<p>");
			var startTagLen:uint = text.length;
			
			var children:XMLList = pNode.children();
			for (var i:uint = 0; i < children.length(); i++) {
				var child:XML = children[i];
				switch (child.nodeKind()) {
					case "text":
						text += formatCCText(child.toString());
						break;
					case "element":
						switch (child.localName()) {
							case "set":
							case "metadata":
								break;	// We don't support these in <p> tags
							case "span":
								var styleStartIndex:uint = text.length - startTagLen;
								var spanText:String;
								
								var stylesList:Array = new Array();

								text += parseSpanTag(child, stylesList);
												
								var styleEndIndex:uint = text.length - startTagLen;
								
								for each (var styleObject:Style in stylesList) {
									var fmtObj:CaptionFormat = new CaptionFormat(styleObject, styleStartIndex, styleEndIndex);
									captionFormatList.push(fmtObj);
								}
								break;
							case "br":
								text += "<br/>";
								break;
							default:
								text += formatCCText(child.toString());
								break;
						}
						break;
				}
			}
			
			text += "</p>";
			
			var captionItem:Caption = new Caption(cuePointItem.id, beginSecs, endSecs, text);
			
			// If there is a style attribute, parse that
			var styleObj:Style = parseStyleAttrib(pNode);
			if (styleObj) {
				var formatObj:CaptionFormat = new CaptionFormat(styleObj);
				captionItem.addCaptionFormat(formatObj);
			}
			
			// If there were styles in the span tag(s), add those
			for (i = 0; i < captionFormatList.length; i++) {
				captionItem.addCaptionFormat(captionFormatList[i]);
			}
		
			_captionObjs.push(captionItem);		
		}
		
		/**
		 * If an element has a style attribute specifying a style id, such as <code><p style="1">Caption text</p></code>,
		 * this method looks up the style object read from the head tag and returns it.
		 * 
		 * If an element has an attribute in the TT Style namespace, such as <code><span tts:color="green">some green text</span></code>,
		 * this method parses that attribute and returns a new style object.
		 */
		private function parseStyleAttrib(node:XML):Style {
			var styleId:String = node.@style;
			
			// See if it references a style tag with an ID attribute
			if (styleId != "") {
				for (var i:uint; i < _styleObjs.length; i++) {
					if (_styleObjs[i].id == styleId) {
						return _styleObjs[i];
					}
				}
			}
			else {
				var attributes:XMLList = node.@_tts::*;
				
				for (i = 0; i < attributes.length(); i++) {
					var attrib:XML = attributes[i];
					var localName:String = attrib.localName();
					
					if (localName == "inherit") {
						continue;
					}
					else {
						return this.createStyleObject(node);
					}
				}
			}
			return null;
		}
		
		private function parseSpanTag(spanNode:XML, styles:Array):String {
			// Look for style attribute
			var styleObj:Style = parseStyleAttrib(spanNode);
			styles.push(styleObj);
			
			var ccText:String = new String();
			var children:XMLList = spanNode.children();
			
			for (var i:uint = 0; i < children.length(); i++ ) {
				var child:XML = children[i];
				
				switch (child.nodeKind()) {
					case "text":
						ccText += formatCCText(child.toString());
						break;
					case "element":
						switch (child.localName()) {
							case "set":
							case "metadata":
								break;	// We don't support these in <span> tags
							case "br":
								ccText += "<br/>";
								break;
							default:
								ccText += child.toString();
								break;
						}
						break;
				}
			}

			return ccText;
		}
				
		private function formatCCText(txt:String):String {
			var retString:String = txt.replace(/\s+/g, " ");
			return retString;
		}
			
		/**
		 * The following time values are supported:<ul>
		 * <li>full clock format in "hours:minutes:seconds:fraction" (e.g. 00:03:00:00).</li>
		 * <li>offset time (e.g. 100.1s or 2m).</li>
		 * </ul>
		 * Note: Offset times without units (for example, 10) are assumed to be seconds.
		 */
		private function formatTime(time:String):Number {
			var _time:Number = 0;
			var a:Array = time.split(":");
			
			if (a.length > 1) {
				// clock format,  "hh:mm:ss"
				_time = a[0] * 3600;
				_time += a[1] * 60;
				_time += Number(a[2]);
			}
			else {
				// offset time format, "1h", "8m", "10s"
				var mul:int = 0;
				
				switch (time.charAt(time.length-1)) {
					case 'h':
						mul = 3600;
						break;
					case 'm':
						mul = 60;
						break;
					case 's':
						mul = 1;
						break;
				}
				
				if (mul) {
					_time = Number(time.substr(0, time.length-1)) * mul;
				}
				else {
					_time = Number(time);
				}
			}
			
			return _time;
		}
	}
}
