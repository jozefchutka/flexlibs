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

package org.openvideoplayer.net
{
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Timer;
	
	import org.openvideoplayer.events.OvpError;
	import org.openvideoplayer.events.OvpEvent;
	import org.openvideoplayer.utilities.TimeUtil;

	//-----------------------------------------------------------------
	//
	// Events
	//
	//-----------------------------------------------------------------
	
 	/**
 	 * See the INetConnection interface for information on this event.
 	 * 
 	 * @see INetConnection
	 */
 	[Event (name="asyncError", type="flash.events.AsyncErrorEvent.ASYNC_ERROR")]
	
 	/**
 	 * See the INetConnection interface for information on this event.
 	 * 
 	 * @see INetConnection
	 */
	[Event (name="ioError", type="flash.events.IOErrorEvent.IO_ERROR")]
	
 	/**
 	 * See the INetConnection interface for information on this event.
 	 * 
 	 * @see INetConnection
	 */
	[Event (name="netStatus", type="flash.events.NetStatusEvent.NET_STATUS")]
	
 	/**
 	 * See the INetConnection interface for information on this event.
 	 * 
 	 * @see INetConnection
	 */
	[Event (name="securityError", type="flash.events.SecurityErrorEvent.SECURITY_ERROR")]

	/**
	 * Dispatched when an OVP error condition has occurred. The OvpEvent object contains a data
	 * property.  The contents of the data property will contain the error number and a description.
	 * 
	 * @see org.openvideoplayer.events.OvpError
	 * @see org.openvideoplayer.events.OvpEvent
	 */
 	[Event (name="error", type="org.openvideoplayer.events.OpvEvent.ERROR")]
 
 	/**
	 * Dispatched when a bandwidth estimate is complete. 
	 * 
	 * @see #detectBandwidth()
	 */
 	[Event (name="bandwidth", type="org.openvideoplayer.events.OpvEvent.BANDWIDTH")]
 
	/**
	 * Dispatched when a stream length request is complete.
	 * 
	 * @see #requestStreamLength()
	 */
 	[Event (name="streamlength", type="org.openvideoplayer.events.OpvEvent.STREAMLENGTH")]
 		 
	/**
	 *  The OvpConnection class manages the complexity of establishing a robust NetConnection
	 *  with a streaming service.
	 *  The OvpConnection class works with on-demand FLV and H.264 MP4 (both
	 *  streaming and progressive) and MP3 playback (streaming only), as well as live FLV streams. 
	 *
	 */
	public class OvpConnection extends EventDispatcher implements INetConnection
	{
   		// Declare private/protected vars
   		
   		/**
   		 * @private
   		 */
    	protected var _hostName:String;
   		/**
   		 * @private
   		 */
    	protected var _appNameInstName:String;	// The full connect command string minus the host
   		/**
   		 * @private
   		 */
		protected var _port:String;
   		/**
   		 * @private
   		 */
		protected var _protocol:String;
   		/**
   		 * @private
   		 */
		protected var _actualPort:String;
   		/**
   		 * @private
   		 */
		protected var _actualProtocol:String;
   		/**
   		 * @private
   		 */
		protected var _urlLoader:URLLoader;
   		/**
   		 * @private
   		 */
		protected var _nc:NetConnection;
   		/**
   		 * @private
   		 */
		protected var _aConnections:Array;
   		/**
   		 * @private
   		 */
		protected var _connectionTimer:Timer;
   		/**
   		 * @private
   		 */
		protected var _timeOutTimer:Timer;
   		/**
   		 * @private
   		 */
		protected var _timeOutTimerDelay:Number;
   		/**
   		 * @private
   		 */
		protected var _bufferFailureTimer:Timer;
   		/**
   		 * @private
   		 */
		protected var _liveStreamMasterTimeout:uint;
   		/**
   		 * @private
   		 */
		protected var _connectionAttempt:uint;
   		/**
   		 * @private
   		 */
		protected var _aNC:Array;
   		/**
   		 * @private
   		 */
		protected var _aboutToStop:uint;
   		/**
   		 * @private
   		 */
		protected var _connectionEstablished:Boolean;
   		/**
   		 * @private
   		 */
		protected var _pendingLiveStreamName:String;
   		/**
   		 * @private
   		 */
		protected var _playingLiveStream:Boolean;
   		/**
   		 * @private
   		 */
		protected var _successfullySubscribed:Boolean;
   		/**
   		 * @private
   		 */
		protected var _authParams:String;
   		/**
   		 * @private
   		 */
		protected var _liveStreamAuthParams:String;
   		/**
   		 * @private
   		 */
		protected var _isProgressive:Boolean;
		/**
		 * @private
		 */
		protected var _serverVersion:String;
		/**
		 * @private
		 */
		protected var _cacheable:Boolean;
		/**
		 * @private
		 */
		protected var _attemptInterval:uint;
		/**
		 * @private
		 */
		protected var _connectionArgs:Array;
		
		// Declare private constants
		private const TIMEOUT:uint = 15000;
		
		//-------------------------------------------------------------------
		// 
		// Constructor
		//
		//-------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function OvpConnection() {
			NetConnection.defaultObjectEncoding = flash.net.ObjectEncoding.AMF3;
			_liveStreamMasterTimeout = 3600000;
			_port = "any";
			_protocol = "any";
			_authParams = "";
			_liveStreamAuthParams = "";
			_aboutToStop = 0;
			_isProgressive = false;
			_serverVersion = "";
			_cacheable = false;
			_attemptInterval = 200;

			// Master connection timeout
			_timeOutTimerDelay = TIMEOUT;
			_timeOutTimer = new Timer(_timeOutTimerDelay, 1);
			_timeOutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, masterTimeout);
			// Controls the delay between each connection attempt
			_connectionTimer = new Timer(200);
			_connectionTimer.addEventListener(TimerEvent.TIMER, tryToConnect);
		}
		
		//-------------------------------------------------------------------
		//
		// Properties
		//
		//-------------------------------------------------------------------
		
		/**
		 * Returns a reference to the active NetConnection object. This property will
		 * only return a valid reference if the connection was successful. 
		 * 
		 * @return the NetConnection object, or null if the connection was unsuccessful.
		 */
		public function get netConnection():NetConnection { 
			return _nc;
		}
				
		/**
		 * Indicates whether the application is connected to a server through a persistent RTMP connection (true) or not (false).
		 */				
		public function get connected():Boolean {
			if (_nc && (_nc is NetConnection)) {
				return _nc.connected;
			}
			return false;
		}
		
		/**
		 * If a successful connection is made, indicates the method that was used to make it: a direct connection, the CONNECT method, or HTTP tunneling.
		 */
		public function get connectedProxyType():String {
			if (_nc && (_nc is NetConnection)) {
				return _nc.connectedProxyType;
			}
			return "";
		}
		
		/**
		 * The default object encoding for NetConnection objects. 
		 */
		public function get defaultObjectEncoding():uint {
			return NetConnection.defaultObjectEncoding;
		}
		public function set defaultObjectEncoding(value:uint):void {
			switch (value) {
				case ObjectEncoding.AMF0:
				case ObjectEncoding.AMF3:
				case ObjectEncoding.DEFAULT:
					NetConnection.defaultObjectEncoding = value;
					break;
				default:
					dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.INVALID_ARGUMENT)));
			} 
		}
		
		/**
		 * The object encoding for this NetConnection instance.
		 */
		public function get objectEncoding():uint {
			if (_nc && (_nc is NetConnection)) {
				return _nc.objectEncoding;
			}
			return ObjectEncoding.DEFAULT;
		}
		public function set objectEncoding(value:uint):void {
			if (_nc && (_nc is NetConnection)) {
				_nc.objectEncoding = value;
			}
		}
		
		/**
		 * A reference to the prototype object of a class or function object.
		 */
		public function get proxyType():String {
			if (_nc && (_nc is NetConnection)) {
				return _nc.proxyType;
			}
			return "";
		}
		public function set proxyType(value:String):void {
			if (_nc && (_nc is NetConnection)) {
				_nc.proxyType = value;
			}
		}
		
		/**
		 * The URI passed to the NetConnection.connect() method.
		 */
		public function get uri():String {
			if (_nc && (_nc is NetConnection)) {
				return _nc.uri;
			}
			return "";
		}
		
		/**
		 * Indicates whether a secure connection was made using native Transport Layer Security (TLS) rather than HTTPS.
		 */
		public function get usingTLS():Boolean {
			if (_nc && (_nc is NetConnection)) {
				return _nc.usingTLS;
			}
			return false;
		}
						
		/**
		 * The port on which the class has connected. This parameter will only be returned if the class has managed to
		 * successfully connect to the server. Possible port values are "1935", "443", and "80". This property differs
		 * from requestedPort since it returns the port that was actually used and not the port combination that was requested.
		 * <p />
		 * This property is not available with progressive playback.
		 * 
		 * @return the port over which the connection has actually been made, otherwise null.
		 * 
		 * @see #requestedPort
		 */
		public function get actualPort():String {
			return _connectionEstablished ? _actualPort: null;
		}
		
		/**
		 * The protocol over which the class has connected. This parameter will only be returned if the class has managed to
		 * successfully connect to the server. Possible protocol values are "rtmp","rtmpt","rtmpe" or "rtmpte". This property will
		 * differ from requestedProtocol if the requestedProtocol value was "any", in which case this property will return
		 * the protocol that was actually used.
		 * 
		 * <p />
		 * This property is not available with progressive playback.
		 * 
		 * @return the protocol over which the connection has actually been made, otherwise null.
		 * 
		 * @see #requestedProtocol
		 */
		public function get actualProtocol():String {
			return _connectionEstablished ? _actualProtocol : null;
		}		
		
		/** The server connection timeout in milliseconds. If a successful connection has not been established within this
		 * time period, an OvpEvent.TIMEOUT will be dispatched.
		 */
		public function get timeout():Number {
			return _timeOutTimerDelay;
		}
		public function set timeout(value:Number):void {
			_timeOutTimerDelay = value;
		}
		
		/**
		 * This method is primarly here to be overridden.
		 * @private 
		 */
		public function get serverIPaddress():String {
			return _connectionEstablished ? _hostName: null;
		}
		
		/**
		 * The port(s) over which the class may attempt to connect. These combinations are specified
		 * as a single string of ports separated by a delimiter.
		 * Possible requested port values are "any", "1935", "443" and "80", or
		 * any combination of these values, separated by the ',' delimiter. "any" is a reserved word meaning that the 
		 * class should attempt all of the ports which the target network supports. Valid examples include
		 * "1935,80", "443,80" etc. The order in which the ports are specified is the order in which the connection
		 * attempts are made. All the ports for the first protocol (as specified by requestedProtocol) are attempted,
		 * followed by all the ports for the second protocol etc. For example, if requestedPort was set to "1935,80" and requestedProtocol
		 * to "rtmpt,rtmpe", then the connection attempt sequence would be:
		 * <ul>
		 * <li> rtmpt:1935</li>
		 * <li> rtmpt:80</li>
		 * <li> rtmpe:1935</li>
		 * <li> rtmpe:180</li>
		 * </ul>
		 * <p />
		 * If requestedPort is set to "any" (the default), then the port order is set to "1935,443,80". If both requestedPort
		 * and requestedProtocol are set to "any" then the following optimized sequence is used:
		 * <ul>
		 * <li> rtmp:1935</li>
		 * <li> rtmp:443</li>
		 * <li> rtmp:80</li>
		 * <li> rtmpt:80</li>
		 * <li> rtmpt:443</li>
		 * <li> rtmpt:1935</li>
		 * <li> rtmpe:1935</li>
		 * <li> rtmpe:443</li>
		 * <li> rtmpe:80</li>
		 * <li> rtmpte:80</li>
		 * <li> rtmpte:443</li>
		 * <li> rtmpte:1935</li>
		 * </ul>
		 * <p />
		 * This property is not available with progressive playback. 
		 * 
		 * @return the requested port 
		 * 
		 * @default "any"
		 * 
		 * @see #actualPort
		 * @see #requestedProtocol
		 */
		public function get requestedPort():String {
			return _port;
		}
		public function set requestedPort(p:String):void {
			_port = p;
		}

		/**
		 * The protocol(s) over which the class was originally requested to connect via the <code>requestedProtocol</code> property.
		 * These combinations are specified as a single string of protocols separated by a delimiter.
		 * Possible requested protocol values are "any", "rtmp","rtmpt","rtmpe" or "rtmpte", or
		 * any combination of these values, separated by the ',' delimiter. "any" is a reserved word meaning that the 
		 * class should attempt all of the protocols which the target network supports. Valid examples include
		 * "rtmpt,rtmp", "rtmpe,rtmpte" etc. The order in which the protocols are specified is the order in which the connection
		 * attempts are made. This property will differ from <code>actualProtocol</code> if the requestedProtocol value was "any", in which case <code>actualProtocol</code>
		 * will return the protocol that was actually used. The order in which the protocols are specified is the order in which the connection
		 * attempts are made. All the ports (as specified by requestedPort) for the first protocol are attempted,
		 * followed by all the ports for the second protocol etc. For example, if requestedPort was set to "1935,80" and requestedProtocol
		 * to "rtmpt,rtmpe", then the connection attempt sequence would be:
		 * <ul>
		 * <li> rtmpt:1935</li>
		 * <li> rtmpt:80</li>
		 * <li> rtmpe:1935</li>
		 * <li> rtmpe:180</li>
		 * </ul>
		 * <p />
		 * 
		 * If requestedProtocol is set to "any" (the default), then the protocol order is set to "rtmp,rtmpt,rtmpe,rtmpte". If both requestedPort
		 * and requestedProtocol are set to "any" then the following optimized sequence is used:
		 * <ul>
		 * <li> rtmp:1935</li>
		 * <li> rtmp:443</li>
		 * <li> rtmp:80</li>
		 * <li> rtmpt:80</li>
		 * <li> rtmpt:443</li>
		 * <li> rtmpt:1935</li>
		 * <li> rtmpe:1935</li>
		 * <li> rtmpe:443</li>
		 * <li> rtmpe:80</li>
		 * <li> rtmpte:80</li>
		 * <li> rtmpte:443</li>
		 * <li> rtmpte:1935</li>
		 * </ul>
		 * 
		 * <p />
		 * This property is not available with progressive playback.
		 * 
		 * @return the requested protocol 
		 * 
		 * @default "any"
		 * 
		 * @see #actualProtocol
		 * @see #requestedPort
		 */
		public function get requestedProtocol():String {
			return _protocol;
		}
		public function set requestedProtocol(p:String):void {
			_protocol = p;
		}
		
		/**
		 * Informs whether the current connection is progressive or not.
		 * 
		 * @return true if the conenction is progressive or false if not. 
		 * 
		 * @see #connect()
		 */
		public function get isProgressive():Boolean {
			return _isProgressive;
		}
		
		/**
		 * The last hostName used by the class. If the hostName was sent in the <code>connect</code> method
		 * concatenated with the application name (for example <code>connect("cpxxxx.edgefcs.net/myappalias")</code>)
		 * then this method will only return "cpxxxx.edgefcs.net". Use the <code>appNameInstanceName</code> 
		 * property to retrieve the application name.
		 * 
		 * @return the last hostName used by the class
		 * 
		 * @see #appNameInstanceName
		 * 
		 */
		public function get hostName():String {
			return _hostName;
		}
		
		/**
		 * The last appName/instanceName used by the class. 
		 * 
		 * @return the last appName/instanceName used by the class
		 * 
		 * 
		 */
		public function get appNameInstanceName():String {
			return _appNameInstName;
		}
		
		/**
		 * True if connections can be cached and re-used, false otherwise.
		 */
		public function get cacheable():Boolean {
			return _cacheable;
		}
		public function set cacheable(value:Boolean):void {
			_cacheable = value;
		}
		
		/**
		 * The connection attempt interval when trying multiple ports and protocols.  If connection authentication
		 * parameters are set from a derived class instance, 150 milliseconds will be added to ensure the server
		 * has enough time to process the auth information.
		 */
		public function get attemptInterval():uint {
			return _attemptInterval;
		}
		public function set attemptInterval(value:uint):void {
			_attemptInterval = value;
		}
				
		//-------------------------------------------------------------------
		//
		// Public methods
		//
		//-------------------------------------------------------------------
		
		/**
		 * Adds a context header to the Action Message Format (AMF) packet structure.
		 */
		public function addHeader(operation:String, mustUnderstand:Boolean=false, param:Object=null):void {
			if (_nc && (_nc is NetConnection)) {
				_nc.addHeader(operation, mustUnderstand, param);
			}
		}
		
		/**
		 * Invokes a command or method on Flash Media Server or on an application server running Flash Remoting.
		 */
		public function call(command:String, responder:Responder, ...arguments):void {
			if (_nc && (_nc is NetConnection)) {
				var args:Array = [command, responder].concat( arguments );
				_nc.call.apply( _nc, args );
			}
		}
		
		/**
		 * Closes the connection that was opened locally or to the server and dispatches a netStatus event with a code property of NetConnection.Connect.Closed.
		 */
		public function close():void {
			if (_nc && _connectionEstablished) {
				_nc.close();
				_connectionEstablished = false;
			}
		}
		
		/**
		 * The connect method initiates a connection to either a streaming service or a progressive
		 * link to a HTTP server. A progressive connection is requested by passing 
		 * the <code>null</code> object, or the string "null". All other strings
		 * are treated as requests for a streaming connection. 
		 * 
		 * @param command A string containing hostname/appname/instance
		 */
		public function connect(command:String, ...arguments):void {
			_connectionArgs = arguments;
			
			if (command == null || command == "null") {
				setUpProgressiveConnection();
				return;
			} 

			if (command == "" ) { 
				dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.HOSTNAME_EMPTY)));
				return;
			}
			
			_isProgressive = false;
			_hostName = command.indexOf("/") != -1 ? command.slice(0,command.indexOf("/")):command;
			_appNameInstName = ((command.indexOf("/") != -1) && (command.indexOf("/") != command.length-1)) ? command.slice(command.indexOf("/")+1) : "";
			_connectionEstablished = false;
			buildConnectionSequence();
		}
		
		/**
		 * Attempts to establish a connection based on the arguments passed to the connect method.
		 */
		public function reconnect():void {
			_connectionEstablished = false;
			buildConnectionSequence();	
		}
		
		/**
		 * Initiates a new bandwidth measurement.
		 *  
		 * To recover the estimated bandwidth value, wait for the OvpEvent.BANDWIDTH event and then inspect
		 * the <code>data.bandwidth</code> property.<p />
		 * 
		 * <p />
		 * This method is not available with progressive playback. To estimate bandwidth with progressive connections,
		 * use the HTTPBandwidthEstimate class. 
		 * 
		 * @see org.openvideoplayer.utilities.HTTPBandwidthEstimate
		 * 
		 * @return true if the connection has been established, otherwise false.
		 * 
		 */
		public function detectBandwidth():Boolean {
			if (_nc && _connectionEstablished) 
				_nc.call("_checkbw",null);
			return _connectionEstablished;
		}
		
		/**
		 * Initiates the server request to measure the stream length of a file. Since this measurement is an asynchronous
		 * process, the stream length value can retrieved using the data property of the OvpEvent object, i.e., <code>event.data.streamLength</code>.
		 * Note the name of the file being measured is decoupled from the file being played, meaning you can request the 
		 * length of one file while playing another.
		 * 
		 * @param filename The name of the streaming file for which length is to be requested.
		 * 
		 * @return true if the connection has been established, otherwise false.
		 * @see org.openvideoplayer.events.OvpEvent
		 */
		public function requestStreamLength(filename:String):Boolean {
			if (!_connectionEstablished || filename == "")
				return false;
				
			// if the filename includes parameters, strip them off, since the server can't handle them.
			if (_nc && (_nc is NetConnection)) {
				_nc.call("getStreamLength", new Responder(onStreamLengthResult, onStreamLengthFault), filename.indexOf("?") != -1 ? filename.slice(0,filename.indexOf("?")):filename );
			}
			return true;
		}
		
		/**
		 * Returns the given stream length (duration) in timecode HH:MM:SS format.
		 * 
		 * @return the length as timecode HH:MM:SS
		 */
		public function streamLengthAsTimeCode(value:Number):String{
			return TimeUtil.timeCode(value);
		}
		
		/**
		 * Returns the server version if detectable.
		 * 
		 * @param info An object that, upon return, will contain the major, minor, sub-minor and build information as
		 * integers for ease of making comparisons. If the server version is not available, these values will be zero.
		 * 
		 * @return the server version as a string "major, minor, sub-minor, build", i.e., "3,5,0,1234"
		 */
		public function serverVersion(info:Object):String {
			if (!info)
				return _serverVersion;
			
			if (!_serverVersion || !_serverVersion.length || _serverVersion == "") {
				info.major = info.minor = info.subMinor = info.build = 0;
				return _serverVersion;	
			}	
						
			// Parse into major, minor, sub-minor, build number
			var _aVer:Array = _serverVersion.split(",");
				
			info.major = parseInt(_aVer[0]);
			info.minor = parseInt(_aVer[1]);
			info.subMinor = parseInt(_aVer[2]);
			info.build = parseInt(_aVer[3]);
			return _serverVersion;
		}
					
		//-------------------------------------------------------------------
		//
		// Private Methods
		//
		//-------------------------------------------------------------------

		/** Utility function
		 * @private
		 */
		protected function contains(prop:String,str:String):Boolean {
			var a:Array = prop.split(",");
			for each (var s:String in a) {
				if (s.toLowerCase() == str) {
					return true;
				}
			}
			return false;
		}
		
		
		/** Assembles the array of ports and protocols to be attempted
		 * @private
		 */
		protected function buildPortProtocolSequence():Array {
			var aTemp:Array = new Array();
			if (_port == "any" && _protocol == "any") {
				aTemp = [{port:"1935",protocol:"rtmp"},
						 {port:"443",protocol:"rtmp"},
						 {port:"80",protocol:"rtmp"},
						 {port:"80",protocol:"rtmpt"},
						 {port:"443",protocol:"rtmpt"},
						 {port:"1935",protocol:"rtmpt"},
						 {port:"1935",protocol:"rtmpe"},
						 {port:"443",protocol:"rtmpe"},
						 {port:"80",protocol:"rtmpe"},
						 {port:"80",protocol:"rtmpte"},
						 {port:"443",protocol:"rtmpte"},
						 {port:"1935",protocol:"rtmpte"}];
			} else {
				if (contains(_port,"any")) {
					_port = "1935,443,80";
				}
				if (contains(_protocol,"any")) {
					_protocol= "rtmp,rtmpt,rtmpe,rtmpte";
				}
				var aPort:Array = _port.split(",");
				var aProtocol:Array = _protocol.split(",");
				for (var pr:Number =0; pr < aProtocol.length;pr++) {
					for (var po:Number =0; po < aPort.length;po++) {
						aTemp.push({port:aPort[po], protocol:aProtocol[pr]});
					}
				}
			}
			return aTemp;
		}
		
		/**
		 * @private
		 */
		protected function buildConnectionAddress(protocol:String, port:String):String
		{
			var address:String = protocol+"://"+_hostName+":"+port+"/"+_appNameInstName;
			return address;
		}
		
		/** Builds an array of connection strings and starts connecting
		 * @private
		 */
		protected function buildConnectionSequence():void {
			var aPortProtocol:Array = buildPortProtocolSequence();
			_aConnections = new Array();
			_aNC = new Array();
			for (var a:uint = 0; a<aPortProtocol.length; a++) {
				var connectionObject:Object = new Object();
				var address:String = buildConnectionAddress(aPortProtocol[a].protocol, aPortProtocol[a].port);
				connectionObject.address = address;
				connectionObject.port = aPortProtocol[a].port;
				connectionObject.protocol = aPortProtocol[a].protocol;
				_aConnections.push(connectionObject);
			}
			_timeOutTimer.delay = _timeOutTimerDelay;
			_timeOutTimer.reset();
			_timeOutTimer.start();
			_connectionAttempt = 0;
			_connectionTimer.reset();
			_connectionTimer.delay = _authParams == "" ? _attemptInterval : _attemptInterval + 150;
			_connectionTimer.start();
			tryToConnect(null);
		}
		/** Attempts to connect to FMS using a particular connection string
		 * @private
		 */
		protected function tryToConnect(evt:TimerEvent):void {
			_aNC[_connectionAttempt] = new NetConnection();
			_aNC[_connectionAttempt].addEventListener(NetStatusEvent.NET_STATUS,netStatus);
    		_aNC[_connectionAttempt].addEventListener(SecurityErrorEvent.SECURITY_ERROR,netSecurityError);
    		_aNC[_connectionAttempt].addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncError);
    		
			_aNC[_connectionAttempt].client = new Object;
			_aNC[_connectionAttempt].client.id = _connectionAttempt;		// The identifier for this connection
			_aNC[_connectionAttempt].client._onbwcheck = this._onbwcheck;	// Callbacks for bandwidth detection
			_aNC[_connectionAttempt].client._onbwdone = this._onbwdone;
			_aNC[_connectionAttempt].client.onFCSubscribe = this.onFCSubscribe;	// Callbacks for subscribing to live streams
			_aNC[_connectionAttempt].client.onFCUnsubscribe = this.onFCUnsubscribe;
			
			try {
				_aNC[_connectionAttempt].connect(_aConnections[_connectionAttempt].address, _connectionArgs);
			}
			catch (error:Error) {
				// the connectionTimer will time out and report an error.
			}
			finally {
				_connectionAttempt++;
				if (_connectionAttempt >= _aConnections.length) {
					_connectionTimer.stop();
				}
			}
		}
		
		/** Handles a successful connection
		 * @private
		 */
		protected function handleGoodConnect():void {
			_connectionEstablished = true;
			
			var info:Object = new Object();
			info.code = "NetConnection.Connect.Success";
			info.description = "Connection succeeded.";
			info.level = "status";
			
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, info)); 
		}
    	
		/** Handles the case when the server rejects the connection. Note that by default this function does nothing except
		 * bubble up the NetStatusEvent. The reason is that many firewalls that block rtmp traffic will cause the class
		 * to synthesize a REJECTED event. If the class abandoned all its attempts after receiving one REJECTED event, then it would 
		 * never succeed in finding a port/protocl combination that the firewall may accept. The timeout function will eventually 
		 * catch all the rejections if they are indeed valid. 
		 * <p/>
		 * If you are expecting custom data messages passed back in the REJECTED event (say your CDN is implementing geo-blocking
		 * for example) then sub-class OvpConneciton and insert your own custom logic into this function. 
		 * 
		 * @private
		 */
		protected function handleRejectedOrInvalid(event:NetStatusEvent):void {
			dispatchEvent(event);
    	}

		/** Establish the progressive connection
		 * @private
		 */
		protected function setUpProgressiveConnection():void {
			_isProgressive = true;
			_nc = new NetConnection();
    		_nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR,netSecurityError);
    		_nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncError);
    		_nc.connect(null);
			handleGoodConnect();		
		}		
		
		//-------------------------------------------------------------------
		//
		// Event Handlers
		//
		//-------------------------------------------------------------------

		/** Catches the master timeout when no connections have succeeded within TIMEOUT.
		 * @private
		 */
		protected function masterTimeout(evt:Event):void {
			for (var i:uint = 0; i<_aNC.length; i++) {
				_aNC[i].close();
				_aNC[i] = null;
			}
			dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.CONNECTION_TIMEOUT))); 
		}
		
		
 		/** Handles all status events from the NetConnections
		 * @private
		 */
		protected function netStatus(event:NetStatusEvent):void {
    		if (_connectionEstablished) {
    			// only dispatch netconnection events once we have a good connection, otherwise
    			// the user receives all the close() events when the parallel unused connection attempts
    			// are shut down. One exception is that if the connection is rejected, then the NetStatusEvent event
    			// is re-dispatched by the handleRejectedOrInvalid() function.
    			dispatchEvent(event);
			}
			switch (event.info.code) {
				case "NetConnection.Connect.InvalidApp":
				case "NetConnection.Connect.Rejected":
					handleRejectedOrInvalid(event) 
    				break;
				case "NetConnection.Call.Failed":
					if (event.info.description.indexOf("_checkbw") != -1) {
						event.target.expectBWDone = true;
						event.target.call("checkBandwidth",null);
					}
					break;
				case "NetConnection.Connect.Success":
					_timeOutTimer.stop();
					_connectionTimer.stop();
					for (var i:uint = 0; i<_aNC.length; i++) {
						if (_aNC[i] && (i != event.target.client.id)) {
							_aNC[i].close();
							_aNC[i] = null;
						}
					}
					_nc = NetConnection(event.target);
					_actualPort = _aConnections[_nc.client.id].port;
					_actualProtocol = _aConnections[_nc.client.id].protocol;

					// See if we have version info
					if (event.info.data && event.info.data.version)
						_serverVersion = event.info.data.version;
						
					handleGoodConnect();
					break;
			}
			
  		}
		/** Catches any netconnection net security errors
		 * @private
		 */
		protected function netSecurityError(event:SecurityErrorEvent):void {
			dispatchEvent(event);
    	}
    	
    	/** Catches any async errors
    	 * @private
    	 */
		protected function asyncError(event:AsyncErrorEvent):void {
			dispatchEvent(event);
    	}
	
		/**
		 * @private
		 */
		public function _onbwcheck(data:Object, ctx:Number):Number {
			return ctx;
		}
		
		// Live subscription callbacks - these are callbacks resulting from calling
		// "FCSubscribe" on the server, we will dispatch a custom OVP event because 
		// a NetStream object is most likely interested in these events.
		/**
		 * @private
		 */
		public function onFCSubscribe(info:Object):void {
			dispatchEvent(new OvpEvent(OvpEvent.FCSUBSCRIBE,info)); 		
		}
	
		/**
		 * @private
		 */
		public function onFCUnsubscribe(info:Object):void {
			if (info.code == "NetStream.Play.Stop") {
				dispatchEvent(new OvpEvent(OvpEvent.FCUNSUBSCRIBE,info)); 
			}
		}
		
		/**
		 * @private
		 */
		public function _onbwdone(latencyInMs:Number, bandwidthInKbps:Number):void {
			var data:Object = new Object();
			data.bandwidth = bandwidthInKbps;
			data.latency = latencyInMs;
			dispatchEvent(new OvpEvent(OvpEvent.BANDWIDTH, data)); 
		}
		
		/** Handles the responder result from a streamlength request.
		 * @private
		 */
		private function onStreamLengthResult(streamLength:Number):void {
			var data:Object = new Object();
			data.streamLength = streamLength;
			dispatchEvent(new OvpEvent(OvpEvent.STREAM_LENGTH, data)); 
		}

		/** Handles the responder fault after a streamlength request
		 * @private
		 */
		private function onStreamLengthFault(info:Object):void {
			dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.STREAM_LENGTH_REQ_ERROR)));
		}

	}
}
