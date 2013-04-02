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
	import org.openvideoplayer.events.*;
	
	/**
	 * Dispatched when an error condition has occurred. The event provides an error number and a verbose description
	 * of each error. 
	 * @see org.openvideoplayer.events.OvpEvent#ERROR
	 */
 	[Event (name="error", type="org.openvideoplayer.events.OvpEvent")]
	/**
	 * Dispatched when the BOSS xml response has been successfully parsed. 
	 * 
	 * @see org.openvideoplayer.events.OvpEvent#PARSED
	 */
 	[Event (name="parsed", type="org.openvideoplayer.events.OvpEvent")]
	
	
	/**
	 * The AkamaiBOSSParser class loads and parses XML metafiles returned by the Akamai StreamOS BOSS service. There are three
	 * different types of metafiles that this parser recognizes:<p />
	 * Metafile version I
	 * <listing version="3.0">
	 *  &lt;FLVPlayerConfig&gt;
	 *      &lt;serverName&gt;cpxxxxx.edgefcs.net&lt;/serverName&gt;
	 *      &ltfallbackServerName>cpyyyyy.edgefcs.net</fallbackServerName&gt;
	 *      &lt;appName&gt;ondemand&lt;/appName&gt;
	 *      &lt;streamName&gt;&lt;![CDATA[xxxxx/6c/04/6c0442cadf77337d43a89fc56d2b28f9-461c1402]]/&gt;&lt;/streamName>
	 *      &lt;isLive&gt;false&lt;/isLive&gt;
	 *      &lt;bufferTime&gt;2&lt;/bufferTime&gt;
	 *  &lt;/FLVPlayerConfig&gt;
	 * </listing>
	 * <p/>
	 * Metafile version II
	 * <listing version="3.0">
	 *  &lt;FLVPlayerConfig&gt;
	 *   &lt;stream&gt;
	 *	  &lt;entry&gt;
	 *      &lt;serverName&gt;cpxxxxx.edgefcs.net&lt;/serverName&gt;
	 *      &lt;appName&gt;ondemand&lt;/appName&gt;
	 *      &lt;streamName&gt;&lt;![CDATA[xxxxx/6c/04/6c0442cadf77337d43a89fc56d2b28f9-461c1402]]/&gt;&lt;/streamName>
	 *      &lt;isLive&gt;false&lt;/isLive&gt;
	 *      &lt;bufferTime&gt;2&lt;/bufferTime&gt;
	 *    &lt;/entry&gt;
	 *  &lt;/stream&gt;
	 * &lt;/FLVPlayerConfig&gt;
	 * </listing>
	 * <p/>
	 * Metafile version III is deprecated.
	 * <p/>
	 * Metafile version IV <br/>
	 * On-demand sample:
	 * <listing version="3.0">
	 * 	 &lt;smil xmlns="http://www.w3.org/2005/SMIL21/Language" title="EdgeBOSS-SMIL:1.0"&gt;
  	 *      &lt;video src="rtmp://cpxxxxx.edgefcs.net/ondemand/flash/63/dc/63dcaade59637ee0193a5a2b95a40113-47d04e26" title="Superbowl 2008: Bud Light: Deli" copyright="2008. All Rights Reserved." author="Anheuser Busch" clipBegin="1s" clipEnd="30s" dur="60s"&gt;
     *         &lt;param name="connectAuthParams" value="auth=AUTH&aifp=AIFP" valuetype="data"/&gt;
     *         &lt;param name="keywords" value="football, beer, bud light, NFL" valuetype="data"/&gt;
     *         &lt;param name="isLive" value="0" valuetype="data"/&gt;
     *      &lt;/video&gt;
     *   &lt;/smil&gt;
	 * </listing>
	 * <p/>
	 * Live sample:
	 * <listing version="3.0">
	 * 	 &lt;smil xmlns="http://www.w3.org/2005/SMIL21/Language" title="EdgeBOSS-SMIL:1.0"&gt;
  	 *      &lt;video src="rtmp://cpxxxxx.live.edgefcs.net/live/smellhound&#64;1641" title="Stream OS Live Events Flash Format Test" copyright="2008. All Rights Reserved." author="Akamai Technologies, Inc."&gt;
     *         &lt;param name="playAuthParams" value="auth=AUTH&aifp=AIFP" valuetype="data"/&gt;
     *         &lt;param name="keywords" value="football, beer, bud light, NFL" valuetype="data"/&gt;
     *         &lt;param name="isLive" value="1" valuetype="data"/&gt;
     *      &lt;/video&gt;
     *   &lt;/smil&gt;
	 * </listing>
	 * <p/>
	 */
	public class AkamaiBOSSParser extends ParserBase {

		// Declare vars
		private var _serverName:String;
		private var _appName:String;
		private var _streamName:String;
		private var _protocol:String;
		private var _isLive:Boolean;
		private var _bufferTime:Number;
		private var _fallbackServerName:String;
		private var _connectAuthParams:String;
		private var _playAuthParams:String;
		private var _source:String;
		private var _title:String;
		private var _copyright:String;
		private var _author:String;
		private var _clipBegin:String;
		private var _clipEnd:String;
		private var _duration:String;
		private var _keywords:String;
		private var _secondaryEncoderSrc:String;
		private var _versionOfMetafile:String;
		private var _ns:Namespace;
		private var _hostName:String;
		
		
		//Declare constants
		public const VERSION:String = "2.0";
		public const METAFILE_VERSION_I:String = "METAFILE_VERSION_I";
		public const METAFILE_VERSION_II:String = "METAFILE_VERSION_II";
		public const METAFILE_VERSION_IV:String = "METAFILE_VERSION_IV";

		/**
		 * Constructor
		 * @private
		 */
		public function AkamaiBOSSParser():void {
			super();
		}

		/**
		 * The Akamai hostname, in the form cpxxxxx.edgefcs.net
		 * 
		 */
		public function get serverName():String{
			return _serverName;
		}
		/**
		 * The Akamai application name
		 * 
		 */
		public function get appName():String {
			return _appName;
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
		 * Boolean parameter indicating whether the stream is live or not
		 * 
		 */
		public function get isLive():Boolean {
			return _isLive;
		}
		/**
		 * The auth parameter string (auth=xxxx&aifp=yyyy&slist=zzzzz) to be used at connection time.
		 * Note that for Type I and Type II metafiles, the auth params are appended to the appName value.
		 * This class will strip them from the appName and expose them via the connectAuthParams property. This
		 * is a departure in behavior from Akamai Media Framework versions prior to 1.7, where auth params were left
		 * attached as part of the app name and were not exposed via the connectAuthParams property for
		 * Type I and II feeds. 
		 * 
		 */
		public function get connectAuthParams():String {
			return _connectAuthParams;
		}
		/**
		 * The auth parameter string(auth=xxxx&aifp=yyyy&slist=zzzzz) to be used at stream play time.
		 * Note that for Type I and Type II metafiles, the auth params are appended to the streamName value.
		 * This class will strip them from the streamName and expose them via the playAuthParams property. This
		 * is a departure in behavior from Akamai Media Framework versions prior to 1.7, where auth params were left
		 * attached as part of the stream name and were not exposed via the playAuthParams property for
		 * Type I and II feeds. 
		 * 
		 */
		public function get playAuthParams():String {
			return _playAuthParams;
		}
		/**
		 * The fallback server name. This property is only available with metafile type I.
		 * 
		 */
		public function get fallbackServerName():String {
			return _fallbackServerName;
		}
		/**
		 * The requested protocol attribute. This property is only available with metafile type IV.
		 * Note that a protocol of "rtmp" is the default and implies that port/protocol negotiation
		 * should be performed to select the optimum protocol. A protocol value of "rtmpe" implies that
		 * the account can only accept "rtmpe" or "rtmpte" connections and any subsequent connection attempts
		 * should be limited to just those two protocols. 
		 * 
		 */
		public function get protocol():String {
			return _protocol;
		}
		/**
		 * The video source attribute. This property is only available with metafile type IV.
		 * 
		 */
		public function get source():String {
			return _source;
		}
		/**
		 * The video title attribute. This property is only available with metafile type IV.
		 * 
		 */
		public function get title():String {
			return _title;
		}
		/**
		 * The video copyright attribute. This property is only available with metafile type IV.
		 * 
		 */
		public function get copyright():String {
			return _copyright;
		}
		/**
		 * The video author attribute. This property is only available with metafile type IV.
		 * 
		 */
		public function get author():String {
			return _author;
		}
		/**
		 * The designated clip start time. This property is only available with metafile type IV.
		 * Note that this value is a string, not a number and it may include the character "s" to indicate seconds e.g 30s.
		 * 
		 */
		public function get clipBegin():String {
			return _clipBegin;
		}
		/**
		 * The designated clip end time. This property is only available with metafile type IV.
		 * Note that this value is a string, not a number and it may include the character "s" to indicate seconds e.g 30s.
		 * 
		 */
		public function get clipEnd():String {
			return _clipEnd;
		}
		/**
		 * The stream duration. This property is only available with metafile type IV.
		 * Note that this value is a string, not a number and it may include the character "s" to indicate seconds e.g 30s.
		 * 
		 */
		public function get duration():String {
			return _duration;
		}
		/**
		 * A list of comma separated keywords to be associated with the video. This property is only available with metafile type IV.
		 * 
		 */
		public function get keywords():String {
			return _keywords;
		}
		/**
		 * A backup or secondary encoder source. This property is only available with metafile type IV when isLive is "1" and even then
		 * is not required to be present.
		 * 
		 */
		public function get secondaryEncoderSrc():String {
			return _secondaryEncoderSrc;
		}
		/**
		 * The classification of the metafile type, assuming it has been recognized by the class. Possible
		 * values are the constants:
		 * <ul>
		 * <li>METAFILE_VERSION_I</li>
		 * <li>METAFILE_VERSION_II</li>
		 * <li>METAFILE_VERSION_IV</li>
		 * </ul>
		 * 
		 */
		public function get versionOfMetafile():String {
			return _versionOfMetafile;
		}
		/**
		 * The buffer time designated for this stream
		 * 
		 */
		public function get bufferTime():Number {
			return _bufferTime;
		}

		/** Parses the RSS xml metafile into useful properties
		 * @private
		 */
		override protected function parseXML():void {
			if (!verifyRSS(_xml)) {
				dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.XML_BOSS_MALFORMED)));
			} else {
				switch (_versionOfMetafile) {
					case METAFILE_VERSION_I:
						_serverName = _xml.serverName;
						_fallbackServerName = _xml.fallbackServerName;
						_appName = _xml.appName.split("?")[0];
						_streamName = _xml.streamName.split("?")[0];
						_hostName = _serverName + "/" + _appName;
						_isLive = _xml.isLive.toString().toUpperCase() == "TRUE";
						_bufferTime = Number(xml.bufferTime);
						_connectAuthParams = _xml.appName.split("?")[1];
						_playAuthParams = _xml.streamName.split("?")[1];
						dispatchEvent(new OvpEvent(OvpEvent.PARSED));
					break;
					case METAFILE_VERSION_II:
						_serverName = _xml.stream.entry.serverName;
						_appName = _xml.stream.entry.appName.split("?")[0];
						_streamName = _xml.stream.entry.streamName.split("?")[0];
						_hostName = _serverName + "/" + _appName;
						_isLive = _xml.stream.entry.isLive.toString().toUpperCase() == "TRUE";
						_bufferTime = Number(xml.stream.entry.bufferTime);
						_connectAuthParams = _xml.stream.entry.appName.split("?")[1];
						_playAuthParams = _xml.stream.entry.streamName.split("?")[1];
						dispatchEvent(new OvpEvent(OvpEvent.PARSED));
					break;
					case METAFILE_VERSION_IV:
						_source = _xml._ns::video.@src;
						_title= _xml._ns::video.@title;
						_author= _xml._ns::video.@author;
						_clipBegin= _xml._ns::video.@clipBegin;
						_clipEnd= _xml._ns::video.@clipEnd;
						_duration= _xml._ns::video.@dur;
						_connectAuthParams = _xml._ns::video._ns::param.(@name=="connectAuthParams").@value;
						_playAuthParams = _xml._ns::video._ns::param.(@name=="playAuthParams").@value;
						_keywords = _xml._ns::video._ns::param.(@name=="keywords").@value;
						_secondaryEncoderSrc = _xml._ns::video._ns::param.(@name=="secondaryEncoderSrc").@value;
						_serverName = parseServerName(_source);
						_appName = parseAppName(_source);
						_hostName = _serverName + "/" + _appName;
						_streamName = parseStreamName(_source);
						_protocol = parseProtocol(_source);
						_isLive = _xml._ns::video._ns::param.(@name=="isLive").@value == "1";
						dispatchEvent(new OvpEvent(OvpEvent.PARSED));
					break;
				}
			}
			_busy = false;
		}
		/** Parses the server name from the source
		 * @private
		 */
		private function parseServerName(s:String):String {
			return s.split("/")[2];
		}
		/** Parses the application name from the source
		 * @private
		 */
		private function parseAppName(s:String):String {
			return s.split("/")[3];
		}
		/** Parses the stream name from the source
		 * @private
		 */
		private function parseStreamName(s:String):String {
			return s.slice(s.indexOf(this.hostName)+this.hostName.length+1);
		}
		/** Parses the protocol from the source
		 * @private
		 */
		private function parseProtocol(s:String):String {
			return s.slice(0,s.indexOf(":")).toLowerCase();
		}
		/** A simple verification routine to check if the XML received conforms
		 * to some basic BOSS requirements. This routine does not validate against
		 * any DTD.
		 * @private
		 */
		private function verifyRSS(src:XML):Boolean {
			// First, let's identify the type of BOSS metafile we are dealing with
			// by examining the first node
			var isVerified:Boolean;
			switch (src.localName()) {
				case "FLVPlayerConfig":
					if (src.stream == undefined && src.stream.entry == undefined) {
						_versionOfMetafile = METAFILE_VERSION_I;
						isVerified = !(src.serverName == undefined || src.appName == undefined || src.streamName == undefined || src.isLive == undefined  || src.bufferTime == undefined);
					} else {
						_versionOfMetafile = METAFILE_VERSION_II;
						isVerified = !(src.stream.entry.serverName == undefined || src.stream.entry.appName == undefined || src.stream.entry.streamName == undefined || src.stream.entry.isLive == undefined  || src.stream.entry.bufferTime == undefined);
					}
				break;
				case "smil":
					if (src.attribute("title").toString() == "EdgeBOSS-SMIL:1.0"){
						_versionOfMetafile = METAFILE_VERSION_IV;
						_ns = new Namespace("http://www.w3.org/2005/SMIL21/Language");
						isVerified = !(src._ns::video.@src == undefined);
					}
					else {
						isVerified = false;
					}
				break;
				default:
				 	isVerified = false;
				 break;
			}
			return isVerified;
		}

		
	}
}
