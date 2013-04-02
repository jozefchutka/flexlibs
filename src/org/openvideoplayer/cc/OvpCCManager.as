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
	import org.openvideoplayer.events.OvpEvent;
	import org.openvideoplayer.net.OvpCuePointManager;
	import org.openvideoplayer.net.OvpNetStream;
	import org.openvideoplayer.parsers.DfxpParser;

	/**
	 * Dispatched when an OVP error condition has occurred. The OvpEvent object contains a data
	 * property.  The contents of the data property will contain the error number and a description.
	 * 
	 * @see org.openvideoplayer.events.OvpError
	 * @see org.openvideoplayer.events.OvpEvent
	 */
	[Event (name="error", type="org.openvideoplayer.events.OvpEvent")]
	
	/**
	 * Dispatched when a caption event has occured. The OvpEvent object contains a data
	 * property. The data property will be a Caption object in this case.
	 * 
	 * @see org.openvideoplayer.events.OvpEvent
	 * @see org.openvideoplayer.cc.Caption
	 */
	[Event (name="caption", type="org.openvideoplayer.events.OvpEvent")]
	
	/**
	 * The OvpCCManager class provides closed captioning for video playback and supports a subset of the 
	 * W3C Timed Text Authoring Format 1.0 - Distribution Format Exchange Profile (DFXP). The DfxpParser 
	 * class contains details about the supported subset.
	 * 
	 * @see org.openvideoplayer.parsers.DfxpParser 
	 *
	 */ 
	public class OvpCCManager extends OvpCuePointManager
	{
		private var _parser:DfxpParser;
		
		/**
		 * Constructs a new OvpCCManager object, with the OvpNetStream object it will use.
		 * The OvpNetStream object can also be set via the <code>netStream</code> property.
		 * 
		 * @param ns The OvpNetStream object the class should use.
		 */
		
		public function OvpCCManager(ns:OvpNetStream=null) {
			super(ns);
			_parser = new DfxpParser();
			_parser.addEventListener(OvpEvent.ERROR, onParseError);
			_parser.addEventListener(OvpEvent.PARSED, onParsed);
			
			if (ns) {
				this.netStream = ns;
			}
		}
		
		/**
		 * Set the OvpNetStream object this class will use.
		 */
		override public function set netStream(ns:OvpNetStream):void {
			if (ns) {
				super.netStream = ns;
				ns.addEventListener(OvpEvent.NETSTREAM_CUEPOINT, onCuePoint);				
			}
		}
		
		/**
		 * Begin parsing the DFXP file containing the caption information.
		 */	
		public function parse(dfxpURL:String):void {
			_parser.load(dfxpURL);
		}
		
		private function onParseError(e:OvpEvent):void {
			dispatchEvent(e);
		}	
		
		private function onParsed(e:OvpEvent):void {
			for (var i:uint = 0; i < _parser.cuePointObjectCount(); i++) {
				this.addCuePoint(_parser.cuePointObjectAt(i));
			}
		}
		
		private function onCuePoint(e:OvpEvent):void {
			if (e && e.data && e.data.name && (e.data.name.search(DfxpParser._CC_CUE_POINT_NAME_PREFIX_) == 0)) {
				var captionObj:Caption = _parser.captionObjectAt(e.data.id);
				dispatchEvent(new OvpEvent(OvpEvent.CAPTION, captionObj));
			}
		}
	}
}
