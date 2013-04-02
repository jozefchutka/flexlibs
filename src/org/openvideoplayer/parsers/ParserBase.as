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
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;	
	
	import org.openvideoplayer.events.*;
	
	/**
	 * Dispatched when an error condition has occurred. The event provides an error number and a verbose description
	 * of each error. 
	 * @see org.openvideoplayer.events.OvpEvent#ERROR
	 */
 	[Event (name="error", type="org.openvideoplayer.events.OvpEvent")]
	/**
	 * Dispatched when the response has been successfully loaded. 
	 * 
	 * @see org.openvideoplayer.events.OvpEvent#LOADED
	 */
 	[Event (name="loaded", type="org.openvideoplayer.events.OvpEvent")]
 	
 	/**
 	 * Base class for OVP Parsers.
 	 */
	public class ParserBase extends EventDispatcher {

		// Member Variables
		protected var _xml:XML;
		protected var _busy:Boolean;
		protected var _timeoutTimer:Timer;
		protected var _rawData:String;
				
		// Constants
		private const TIMEOUT_MILLISECONDS:uint= 15000;
		
		public function ParserBase():void {
			_busy = false;
			_timeoutTimer = new Timer(TIMEOUT_MILLISECONDS, 1);
			_timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, doTimeOut);
		}

		/** Catches the time out of the initial load request.
		  * @private
		  */
		private function doTimeOut(e:TimerEvent):void {
			dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.XML_LOAD_TIMEOUT)));
		}

		/**
		 * Loads a file and initiates the parsing process.
		 * 
		 * @return true if the load is initiated otherwise false if the class is busy
		 * 
		 * @see #isBusy
		 */
		public function load(src:String):Boolean{
			if (!_busy) {
				_busy = true;
				_timeoutTimer.reset();
				_timeoutTimer.start();
				var xmlLoader:URLLoader = new URLLoader();
				xmlLoader.addEventListener("complete", xmlLoaded);
				xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, catchIOError);
				xmlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, catchSecurityError);				
				xmlLoader.load(new URLRequest(src));
				return true;
			} else {
				dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.CLASS_BUSY)));
				return false;
			}
		}
	
		/**
		 * The raw data string returned by the request. This value will still
		 * be populated even if the data is not well-formed, to assist with debugging.
		 * 
		 * @return string representing the text returned by the request.
		 * 
		 */
		public function get rawData():String {
			return _rawData;
		}
		
		/**
		 * The response data as an XML object. 
		 * 
		 */
		public function get xml():XML {
			return _xml;
		}
		
		/** Handles the XML request response
		* @private
		*/
		protected function xmlLoaded(e:Event):void {
			_timeoutTimer.stop();
			_rawData=e.currentTarget.data.toString();
			try {
				_xml = new XML(_rawData);
				dispatchEvent(new OvpEvent(OvpEvent.LOADED));
				parseXML();
			} catch (err:Error) {
				_busy = false;
				dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.XML_MALFORMED)));
			}
		}
		
		/** 
		* Override this method to handle parsing specific to the type of request.
		* The overridden method should dispatch an OvpEvent.PARSED event.
		*
		* @private
		*/
		protected function parseXML():void {
		}
		
		/**
		 * Boolean parameter indicating whether the class is already busy loading a file. Since the 
		 * load is asynchronous, the class will not allow a new <code>load()</code> request until
		 * the prior request has ended.
		 * 
		 */
		public function get isBusy():Boolean {
			return _busy;
		}
		
		/** Catches IO errors when requesting the xml 
		 * @private
		 */
		private function catchIOError(e:IOErrorEvent):void {
			_timeoutTimer.stop();
			_busy = false;
			dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.HTTP_LOAD_FAILED)));
		}
				
		/** Catches Security errors when requesting the xml 
		 * @private
		 */
		private function catchSecurityError(e:SecurityErrorEvent):void {
			catchIOError(null);
		}
			
	}
}
