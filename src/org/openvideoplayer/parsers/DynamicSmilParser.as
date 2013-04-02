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

package org.openvideoplayer.parsers {

	import org.openvideoplayer.events.*;
	import org.openvideoplayer.net.dynamicstream.DynamicStreamItem;
	import org.openvideoplayer.utilities.StringUtil;

	/**
	 * Dispatched when an error condition has occurred. The event provides an error number and a verbose description
	 * of each error. 
	 * @see org.openvideoplayer.events.OvpEvent#ERROR
	 */
 	[Event (name="error", type="org.openvideoplayer.events.OvpEvent")]
	/**
	 * Dispatched when the SMIL response has been successfully parsed. 
	 * 
	 * @see org.openvideoplayer.events.OvpEvent#PARSED
	 */
 	[Event (name="parsed", type="org.openvideoplayer.events.OvpEvent")]
	
	/**
	 * This class verifies and parses a SMIL file.
	 */
	public class DynamicSmilParser extends ParserBase {

		private var _hostName:String;
		private var _streamName:String;
		private var _dsi:DynamicStreamItem;
		private var _protocol:String;

		public function DynamicSmilParser():void {
				super();
		}
	
		/**
		 * The stream name
		 * 
		 */
		public function get streamName():String {
			return _streamName;
		}

		/**
		 * The Akamai Hostname, a concatenation of the server and application names
		 * 
		 */
		public function get hostName():String {
			return _hostName;
		}		
		
		/**
		 * The DynamicStreamItem representation of the content. Only applicable when the metafile type is METAFILE_MULTIBITRATE_SMIL.
		 * 
		 */
		public function get dsi():DynamicStreamItem{
			return _dsi;
		}
		
		/**
		 * The stream protocol
		 * 
		 */
		public function get protocol():String {
			return _protocol;
		}
		

		/** Parses the SMIL file into useful properties
		 * @private
		 */
		override protected function parseXML():void {
			if (!verifySMIL(_xml)) {
				dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.XML_BOSS_MALFORMED)));
			} else {
				var ns:Namespace = _xml.namespace();
				_hostName = _xml.ns::head.ns::meta.@base.slice(_xml.ns::head.ns::meta.@base .indexOf("://")+3);
    			_protocol = _xml.ns::head.ns::meta.@base.slice(0,_xml.ns::head.ns::meta.@base .indexOf("://")).toLowerCase();
				_dsi = parseDsi(_xml);
				_streamName = _dsi.streams[0].name;
				dispatchEvent(new OvpEvent(OvpEvent.PARSED));
			}
			_busy = false;
		}

		/** A simple verification routine to check if the XML received conforms
		 * to some basic requirements. This routine does not validate against
		 * any DTD.
		 * @private
		 */
		private function verifySMIL(src:XML):Boolean {
			var ns:Namespace = src.namespace();
			var isVerified:Boolean = false;
			
			if (src.ns::body.ns::["switch"] != undefined) {
				isVerified = !(src.ns::head.ns::meta.@base == undefined || src.ns::body.ns::["switch"].ns::video.length() < 1 );
			}
			return isVerified;
		}

		/** Parses the SMIL into a DynamicStreamItem
		 * @private
		 */
		private function parseDsi(x:XML):DynamicStreamItem {
			var ns: Namespace = x.namespace();
			var dsi:DynamicStreamItem = new DynamicStreamItem();
			for (var i:uint = 0; i < x.ns::body.ns::["switch"].ns::video.length(); i++) {
				var streamName:String = x.ns::body.ns::["switch"].ns::video[i].@src;
				streamName = StringUtil.addPrefix(streamName);
				dsi.addStream(streamName, Number(x.ns::body.ns::["switch"].ns::video[i].@["system-bitrate"])/1000);
			}
			return dsi;
		}
		


	}
}
