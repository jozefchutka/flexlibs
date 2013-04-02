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

package com.akamai.net
{
	import flash.events.*;
	import flash.net.*;
	
	import org.openvideoplayer.net.*;
	import org.openvideoplayer.events.*;
	import org.openvideoplayer.utilities.*;
	import org.openvideoplayer.version.OvpVersion;
	
	/**
	 * The AkamaiConnection class extends the OvpConnection class to provide functionality specific to the Akamai network,
	 * such as connection authentication and host name formatting.
	 * 
	 */
	public class AkamaiConnection extends OvpConnection
	{
		// protected vars
		
		/**
		 * @private
		 */
		protected var _ip:String;
		/**
		 * @private
		 */
		protected var _isLive:Boolean;
		
		/**
		 * @private
		 */
		private var _overrideIP:String = "";
		
		//-------------------------------------------------------------------
		// 
		// Constructor
		//
		//-------------------------------------------------------------------

		/** 
		 * Constructor
		 */
		public function AkamaiConnection()
		{
			_isLive = false;
			super();
		}
		
		//-------------------------------------------------------------------
		//
		// Properties
		//
		//-------------------------------------------------------------------

		/**
		 * The port(s) over which the class may attempt to connect.
		 * 
		 * @see OvpConnection#requestedPort
		 */
		override public function set requestedPort(p:String):void {
			var aPort:Array = p.split(",");
			for (var i:String in aPort) {
				if (!(aPort[i].toLowerCase() == "any" || aPort[i] == "1935" || aPort[i] == "80" || aPort[i] == "443")) {
					dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.PORT_NOT_SUPPORTED)));
				} 
			}
			_port = p;
		}
		
		/** 
		 * The protocol(s) over which the class may attempt to connect.
		 * 
		 * @see OvpConnection#requestedProtocol
		 */
		override public function set requestedProtocol(p:String):void {
			var aProtocol:Array = p.split(",");
			for (var i:String in aProtocol) {
				if (!(aProtocol[i].toLowerCase()== "any" || aProtocol[i].toLowerCase() == "rtmp" || aProtocol[i].toLowerCase() == "rtmpt" || aProtocol[i].toLowerCase() == "rtmpe" || aProtocol[i].toLowerCase() == "rtmpte")) {
					dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.PROTOCOL_NOT_SUPPORTED)));
				} 
			}
			_protocol = p;
		}
		
		/**
		 * The name-value pairs required for invoking connection authorization services on the 
		 * Akamai network. Typically these include the "auth","aifp" and "slist"
		 * parameters. These name-value pairs must be separated by a "&" and should
		 * not commence with a "?", "&" or "/". An example of a valid authParams string
		 * would be:<p />
		 * 
		 * auth=dxaEaxdNbCdQceb3aLd5a34hjkl3mabbydbbx-bfPxsv-b4toa-nmtE&aifp=babufp&slist=secure/babutest
		 * 
		 * <p />
		 * These properties must be set before calling the <code>connect</code> method,
		 * since authorization is checked when the connection is first established.
		 * If the authorization parameters are rejected by the server, then <code>OvpError.CONNECTION_REJECTED</code> 
		 * will be dispatched.
		 * 
		 * <p />
		 * Auth params cannot be used with progressive playback and are for streaming connections only. 
		 * 
		 * @return the authorization name-value pairs.
		 * 
		 * @default empty string.
		 *
		 * @see #connect()
		 */		
		public function get connectionAuth():String {
			return _authParams;
		}
		public function set connectionAuth(value:String):void {
			_authParams = value;
		}
		
		/**
		 * Returns the IP address if possible, otherwise the hostname. The IP address will only be available 
		 * if the class uses the IDENT function to locate the optimum server (in terms of physical 
		 * proximity and load) for connections.
		 * 
		 * @see #connect()
		 */ 
		override public function get serverIPaddress():String {
			return _connectionEstablished ? ((_ip && _ip != "") ? _ip : _hostName) : null;
		}
		
		/**
		 * Returns true if the server requires clients to subscribe to live streams. This 
		 * property can only be used after a succesful connection has been established.
		 * 
		 * This need for this property has essentially been deprecated with the installation of FMS 3.5+
		 * across the Akamai network. Explicit subscribe requests are no longer required to play live
		 * streams on Akamai. 
		 */
		public function get subscribeRequiredForLiveStreams():Boolean {
			return false;
		}
		
		/**
		 * Returns true if connected to a live stream. This is determined by inspecting the arguments passed
		 * to the connect method.
		 * 
		 * @see #connect()
		 */
		public function get isLive():Boolean {
			return _isLive;
		} 
		
		
		/** 
		 * Allows you to force the class to connect to this IP address. The IDENT request will not be made.
		 * To resume using IDENT, set overrideIP to empty string.
		 * 
		 */
		public function set overrideIP(value:String):void 
		{
			_overrideIP = value;
		}
		public function get overrideIP():String
		{
			return _overrideIP;
		}
		//-------------------------------------------------------------------
		//
		// Public methods
		//
		//-------------------------------------------------------------------

		/**
		 * The connect method initiates a connection to either the Akamai Streaming service or a progressive
		 * link to an HTTP server. It accepts a single hostName parameter, which describes the host account with which 
		 * to connect. This parameter must include the application name, separated by a "/". A progressive
		 * connection is requested by passing the <code>null</code> object, or the string "null". All other strings
		 * are treated as requests for a streaming connection. 
		 * <p />
		 * Valid usage examples include:<ul>
		 * 			<li>_nc.connect("cpxxxxx.edgefcs.net/ondemand");</li>
		 * 			<li>_nc.connect("cpxxxxx.edgefcs.net/aliased_ondemand_app_name");</li>
		 *  		<li>_nc.connect("aliased.domain.name/aliased_ondemand_app_name");</li>
		 * 			<li>_nc.connect("cpxxxxx.live.edgefcs.net/live");</li>
		 * 		    <li>_nc.connect(null);</li>
		 *  		<li>_nc.connect("null");</li></ul>
		 *  To connect to a cp code requiring connection authorization, first set the <code>connectionAuth</code>
		 *  property before calling this <code>connect</code> method. 
		 * <p/>
		 * If a connection attempt is rejected due to SWF auth being enabled for that CP code and the SWF being invalid,
		 * then either one of the following behaviors can occur:
		 * <ul><li> The connection will initially be accepted by the server and then closed a short moment after.
		 * This pattern can be detected by listening for the <code>NetStatusEvent</code> event with an <code>info.code</code> value of 
		 * "NetConnection.Connect.Success" followed by a <code>NetStatusEvent</code> event with an <code>info.code</code> value of 
		 * "NetConnection.Connect.Closed".<li>
		 * <li> Or the connection will never actually be accepted by the server and the connection attempt will fail.
		 * This pattern can be detected by listening for the <code>NetStatusEvent</code> event with an <code>info.code</code> value of
		 * ""NetConnection.Connect.Failed".
		 * </li></ul><p />
		 * 
		 * @param command The Akamai hostname/appname to which to connect. For a progressive connection,
		 * pass <code>null</code>, either as a null object or as a string.
		 * 
		 * @see #connectionAuth
		 */
		override public function connect(command:String, ...arguments):void {
			if (command == null || command == "null") {
				super.connect(command, arguments); // progressive connection, we don't need to do anything special
				return;
			}
			
			if (command == "" ) { 
				dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.HOSTNAME_EMPTY))); 
				return;
			}

			_isProgressive = false;
			_hostName = command.indexOf("/") != -1 ? command.slice(0,command.indexOf("/")):command;
			_appNameInstName = ((command.indexOf("/") != -1) && (command.indexOf("/") != command.length-1)) ? command.slice(command.indexOf("/")+1) : "";
			_isLive = _appNameInstName.indexOf("live") != -1 ? true : false;
			_connectionEstablished = false;
			var versionInfo:Object = new Object();			
			FlashPlayer.version(versionInfo);
			// If the caller wants to override the IP address, then skip IDENT
			if (_overrideIP != "")
			{
				_ip = _overrideIP;
				buildConnectionSequence();
			} 
			else 
			{
				// Old ident request required for Flash Player version < 9.0.60
				if ((versionInfo.major < 9) || (versionInfo.major == 9 && versionInfo.build < 60)) {
					// request IP address of optimum server
					_urlLoader= new URLLoader();	
					_urlLoader.addEventListener("complete", onXMLLoaded);
					_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, catchIOError);
					_urlLoader.load(new URLRequest("http://" + _hostName + "/fcs/ident"));
				}
				else {
					buildConnectionSequence();
				}
			}
		}
		
		/**
		 * Call FCSubscribe on the server for a given stream name.
		 */
		public function callFCSubscribe(streamName:String):void
		{			
			dispatchEvent(new OvpEvent(OvpEvent.SUBSCRIBE_ATTEMPT));
			_nc.call("FCSubscribe", null, streamName);
		}
		
		
		//-------------------------------------------------------------------
		//
		// Private Methods
		//
		//-------------------------------------------------------------------

		/**
		 * @private
		 */
		override protected function buildConnectionAddress(protocol:String, port:String):String
		{			
			var addr:String = protocol+"://";

			addr += (_ip && _ip != "") ? _ip : _hostName;
			addr += ":"+port+"/"+_appNameInstName+"?";
			addr += (_ip && _ip != "") ? "_fcs_vhost="+_hostName+"&" : "";
			addr += "ovpfv=" + OvpVersion.version + (_authParams == "" ? "":"&" + _authParams);
			return addr;
		}

		//-------------------------------------------------------------------
		//
		// Event Handlers
		//
		//-------------------------------------------------------------------
		

		/** Catches IO errors when requesting IDENT xml
		 * @private
		 */
		protected function catchIOError(event:IOErrorEvent):void {
			dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.IDENT_REQUEST_FAILED))); 
			_ip = _hostName;
			buildConnectionSequence();
		}
		
		
	    /** Handles the XML return from the IDENT request
	    * @private
	    */
	    protected function onXMLLoaded(event:Event):void { 
				_ip = XML(_urlLoader.data).ip;
				buildConnectionSequence();
				
		}
		

	}
}
