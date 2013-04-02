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

package com.akamai.net {
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.openvideoplayer.events.OvpError;
	import org.openvideoplayer.events.OvpEvent;
	import org.openvideoplayer.net.*;
	import org.openvideoplayer.utilities.StringUtil;

	/**
	 * Dispatched when the class has successfully subscribed to a live stream.
	 *
	 * @see #play
	 *
	 * @eventType OvpEvent.SUBSCRIBED
	 */
	[Event(name="subscribed", type="org.openvideoplayer.events.OvpEvent")]
	/**
	 * Dispatched when the class has unsubscribed from a live stream, or 
	 * when the live stream it was previously subscribed to has ceased 
	 * publication.
	 *
	 * @see #play
	 * @see #unsubscribe
	 *
	 * @eventType OvpEvent.UNSUBSCRIBED
	 */
	[Event(name="unsubscribed", type="org.openvideoplayer.events.OvpEvent")]
	/**
	 * Dispatched when the class is making a new attempt to subscribe to a live stream.
	 *
	 * @see #play
	 *
	 * @eventType OvpEvent.SUBSCRIBE_ATTEMPT
	 */
	[Event(name="subscribeattempt", type="org.openvideoplayer.events.OvpEvent")]


	/**
	 * The AkamaiNetStream class extends the OvpNetStream class to provide 
	 * functionality specific to the Akamai network,
	 * such as live stream authentication.
	 */
	public class AkamaiNetStream extends OvpNetStream {
		protected var _liveStreamAuthParams:String;
		protected var _liveStreamRetryTimer:Timer;
		protected var _liveStreamTimeoutTimer:Timer;
		protected var _successfullySubscribed:Boolean;
		protected var _liveRetryInterval:Number;
		protected var _liveStreamMasterTimeout:Number;
		protected var _playingLiveStream:Boolean;
		protected var _pendingLiveStreamName:String;
		protected var _akamaiConnection:AkamaiConnection;
		protected var _retryLiveStreamsIfUnavailable:Boolean;
		protected var _playReissueRequired:Boolean;

		protected const LIVE_RETRY_INTERVAL:Number = 15000;
		protected const LIVE_RETRY_TIMEOUT:Number = 1200000;


		//-------------------------------------------------------------------
		// 
		// Constructor
		//
		//-------------------------------------------------------------------

		/**
		 * Constructor
		 *
		 * @param connection This object can be either an OvpConnection 
		 * object or a NetConnection object. If an OvpConnection
		 * object is provided, the base class constructor will use 
		 * the NetConnection object within it.
		 * <p />
		 * If you are connecting to a live stream on the Akamai network, 
		 * we recommend passing in an AkamaiConnection object.
		 */
		public function AkamaiNetStream(connection:Object) {
			super(connection);

			if (connection is AkamaiConnection && (AkamaiConnection(connection).isLive)) {
				_akamaiConnection = AkamaiConnection(connection);
				_akamaiConnection.addEventListener(OvpEvent.FCSUBSCRIBE,onFCSubscribe);
				_akamaiConnection.addEventListener(OvpEvent.FCUNSUBSCRIBE,onFCUnsubscribe);
				this.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				_isLive = true;
				_liveStreamAuthParams = "";
				_liveRetryInterval = LIVE_RETRY_INTERVAL;
				_liveStreamMasterTimeout = LIVE_RETRY_TIMEOUT;
				_liveStreamRetryTimer = new Timer(_liveRetryInterval);
				_liveStreamRetryTimer.addEventListener(TimerEvent.TIMER,onRetryLiveStream);
				_liveStreamTimeoutTimer = new Timer(_liveStreamMasterTimeout,1);
				_liveStreamTimeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onLiveStreamTimeout);
				_retryLiveStreamsIfUnavailable = true;
				_playReissueRequired = false;
			}
		}

		//-------------------------------------------------------------------
		//
		// Properties
		//
		//-------------------------------------------------------------------

		/**
		 * The name-value pairs required for invoking stream-level authorization services against
		 * live streams on the Akamai network. Typically these include the "auth" and "aifp"
		 * parameters. These name-value pairs must be separated by a "&" and should
		 * not commence with a "?", "&" or "/". An example of a valid authParams string
		 * would be:<p />
		 *
		 * auth=dxaEaxdNbCdQceb3aLd5a34hjkl3mabbydbbx-bfPxsv-b4toa-nmtE&aifp=babufp
		 *
		 * <p />
		 * These properties must be set before calling the <code>play</code> method,
		 * since per stream authorization is invoked when the file is first played (as opposed
		 * to connection auth params which are invoked when the connection is made).
		 * If the stream-level authorization parameters are rejected by the server, then
		 * <code>NetStatusEvent</code> event with <code>info.code</code> set to "NetStream Failed" 
		 * will be dispatched.
		 *
		 * @see AkamaiConnection#connectionAuth
		 * @see #play
		 */
		public function get liveStreamAuthParams():String {
			return _liveStreamAuthParams;
		}

		public function set liveStreamAuthParams(ap:String):void {
			_liveStreamAuthParams = ap;
		}
		
		/**
		 * If this property is true, then if a live stream is playing and becomes unpublished due 
		 * to both the primary and backup encoders ceasing to publish, the class will automatically 
		 * enter into a retry cycle, where it will attempt to play the streams again. Similarly, if 
		 * a play request is made and the live stream is not found, the class will reattempt the 
		 * streams at a predefined interval. This interval is set by the liveRetryInterval. The retries
		 * will cease and timeout once the liveRetryTimeout value has elapsed without a successfull play. 
		 *
		 * @default true
		 * @see AkamaiConnection#connectionAuth
		 * @see #play
		 */
		public function get retryLiveStreamsIfUnavailable():Boolean {
			return _retryLiveStreamsIfUnavailable;
		}
		public function set retryLiveStreamsIfUnavailable(value:Boolean):void {
			_retryLiveStreamsIfUnavailable = value;
		}
		
		/**
		 * Defines the live stream retry interval in seconds 
		 *
		 * @default 15
		 * @see #retryLiveStreamsIfUnavailable
		 * @see #liveRetryTimeout
		 */
		public function get liveRetryInterval():Number {
			return _liveRetryInterval/1000;
		}
		public function set liveRetryInterval(value:Number):void {
			_liveRetryInterval = value*1000;
		}
		

		/**
		 * The maximum number of seconds the class should wait before timing out while trying to locate a live stream
		 * on the network. This time begins decrementing the moment a <code>play</code> request is made against a live
		 * stream, or after the class receives an onUnpublish event while still playing a live stream, in which case it
		 * attempts to automatically reconnect. After this master time out has been triggered, the class will issue
		 * an <code>OvpError.STREAM_NOT_FOUND</code> event .
		 *
		 * @default 1200
		 */
		public function get liveStreamMasterTimeout():Number {
			return _liveStreamMasterTimeout / 1000;
		}
		public function set liveStreamMasterTimeout(numOfSeconds:Number):void {
			_liveStreamMasterTimeout = numOfSeconds * 1000;
			_liveStreamTimeoutTimer.delay = _liveStreamMasterTimeout;
		}

		//-------------------------------------------------------------------
		//
		// Public methods
		//
		//-------------------------------------------------------------------

		/**
		 * This method supports both streaming and progressive playback.
		 * <p />
		 * Streaming playback:
		 * <br />
		 * The stream name argument format will vary depending on the type of file you are streaming. The various conventions are best understood if we
		 * explain how the server processes the filename that it receives.  If there is no reserved prefix
		 * at the start of the file, then FMS assumes that an FLV file is being played and will automatically append a ".flv" to the end of the stream name
		 * when retrieving the file from storage. If the stream name begins with "mp3:" then the server assumes that an .mp3 file is being played and will add
		 * a ".mp3" extension to the filename. If the stream beins with "mp4:" then the server assumes a H.264 file is being played and will add
		 * a ".mp4" extension unless it detects another extension already there. Given this server-side behavior, the following stream naming rules apply:
		 * <br/>
		 * <ul><li>FLV files - when streaming .flv files (both vp6 and Spark codec), the file extension must NOT be included.
		 * If it is, then stream length lookup and playback will fail. </li>
		 * <li>MP3 files - the file extension must NOT be included. The reserved prefix "mp3:" must be used at the start of the stream name.</li>
		 * <li>H.264 files - this includes all files with these extensions: .mp4, .m4v, .m4a, .mov, .3gp, f4v, f4p, f4a, and f4b.
		 * The file extension MUST be included, except if the file is a .mp4 file in which case the default extension of .mp4 will
		 * be applied. The reserved prefix "mp4:" must also be used at the start of the stream name. </li>
		 * </ul>
		 * <p />Examples of valid stream names include: <ul>
		 * <li>myfile</li>
		 * <li>myfolder/myfile</li>
		 * <li>my_live_stream&#64;567</li>
		 * <li>my_secure_live_stream&#64;s568</li>
		 * <li>mp3:myfolder/mymp3file</li>
		 * <li>mp4:myfolder/mymp4file</li>
		 * <li>mp4:myfolder/mymp4file.mp4</li>
		 * <li>mp4:myfolder/mymovfile.mov</li>
		 * <li>mp4:myfolder/my3gpfile.3gp</li>
		 * <li>mp4:myfolder/my3gpfile.f4v</li>
		 * </ul>
		 * Examples of invalid stream names include:
		 * <ul>
		 * <li>myfile.flv</li>
		 * <li>myfolder/myfile.flv</li>
		 * <li>myfolder/mymp3file.mp3</li>
		 * <li>mp3:myfolder/mymp3file.mp3</li>
		 * <li>myfolder/mymp4file.mp4</li>
		 * <li>mp4:myfolder/myf4vfile</li>
		 * <li>mp4:myfolder/myfmovfile</li>
		 * </ul>
		 * <p />
		 * Progressive playback:
		 * <br />
		 * The stream name argument must be an absolute or relative path to a FLV or H.264 file and must include the file
		 * extension. MP3 files cannot be played through this class using progressive playback. Ensure that the
		 * Flash player security sandbox restrictions do not prohibit the loading of the MP3 from the source
		 * being specified. Examples of valid stream arguments for progressive playback include:
		 * <ul>
		 * <li>http://myserver.mydomain.com/myfolder/myfile.flv</li>
		 * <li>http://myserver.mydomain.com/myfolder/myfolder/myfile.m4v</li>
		 * <li>http://myserver.mydomain.com/myfolder/myfolder/myfile.m4a</li>
		 * <li>http://myserver.mydomain.com/myfolder/myfolder/myfile.mov</li>
		 * <li>http://myserver.mydomain.com/myfolder/myfolder/myfile.3gp</li>
		 * <li>myfolder/myfile.flv</li>
		 * </ul>
		 * <p />
		 * Note that playback of H.264 files, both streaming and progressive, requires a flash client version greater than 9.0.60.
		 *
		 * @param the name of the stream to play.
		 */
		public override function play(... arguments):void {
			if (!_isProgressive && arguments && arguments.length) {
				// Add prefix if necessary
				arguments[0] = addPrefix(arguments[0]);
			}
			if (isLive)
			{
				// Add auth params
				if (_liveStreamAuthParams != "") {
					var name:String = arguments[0];
					arguments[0] = name.indexOf("?") != -1 ? name + "&" + _liveStreamAuthParams : name + "?" + _liveStreamAuthParams;
				}
				_pendingLiveStreamName = arguments[0] as String;
				arguments[1] = -1;
				_liveStreamTimeoutTimer.reset();
				_liveStreamTimeoutTimer.start();
			}
			super.play.apply(this, arguments);
		}

		/**
		 * Closes the stream.
		 *
		 * @see flash.net.NetStream#close()
		 */
		public override function close():void {
			super.close();
			
			if (isLive) {
				resetAllLiveTimers()
			}
		}

		/**
		 * Initiates the process of unsubscribing from the active live NetStream. This method can only be called if
		 * the class is currently subscribed to a live stream. Since unsubscription is an asynchronous
		 * process, confirmation of a successful unsubscription is delivered via the OvpEvent.UNSUBSCRIBED event.
		 *
		 * @return true if previously subscribed, otherwise false.
		 */
		public function unsubscribe():Boolean {
			if (_successfullySubscribed) {
				resetAllLiveTimers();
				_playingLiveStream = false;
				super.play(false);
				_nc.call("FCUnsubscribe", null, _pendingLiveStreamName);
				return true;
			} else {
				return false;
			}
		}

		//-------------------------------------------------------------------
		//
		// Private Methods
		//
		//-------------------------------------------------------------------

		/**
		 * @private
		 */
		protected function addPrefix(filename:String):String {
			return StringUtil.addPrefix(filename);
		}
		
		/** makes a new subscription request for a live stream
		 * @private
		 */
		private function onRetryLiveStream(event:TimerEvent):void {
			if (_retryLiveStreamsIfUnavailable)
			{
				// Note - when subscribing to live streams, you must strip any query params that
				// are attached. 
				_akamaiConnection.callFCSubscribe(_pendingLiveStreamName.split("?")[0].toString());
				
				/*
				Calling play here fixes the jittery video after stopping/restarting 
				the encoder. If the primary and secondary encoders crash, the stream
				is cleaned up and no longer subscribed to through the live chain, so
				we need to issue an FCSubscribe again and re-issue a play request
				or the stream doesn't get subscribed to all the way from the 
				entry point. However, calling play again causes a NetStream.Play.Stop
				so we only want to do this once after the encoder stops.
				*/
				if (_playReissueRequired) {
					_playReissueRequired = false;
					var args:Array = new Array();
					args.push(_pendingLiveStreamName);
					super.play.apply(this, args);
				}
				
				dispatchEvent(new OvpEvent(OvpEvent.SUBSCRIBE_ATTEMPT));
			}
			else
			{
				onLiveStreamTimeout(null);
			}
		}
		
		/** Catches the final attempt timeout for a live stream
		 * @private
		 */
		private function onLiveStreamTimeout(e:TimerEvent):void {
			resetAllLiveTimers();
			dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.STREAM_NOT_FOUND)));
		}

		/** Cleans up all timers
		 * @private
		 */
		private function resetAllLiveTimers():void {
			_liveStreamRetryTimer.reset();
			_liveStreamTimeoutTimer.reset();
		}

		/** Handles the subscribe event dispatched from OvpConnection
		 * @private
		 */
		public function onFCSubscribe(info:Object):void {
			//trace("onFCSubscribe() - info.data.code="+info.data.code);
			
			switch (info.data.code) {
				case "NetStream.Play.StreamNotFound":
					if (!_liveStreamRetryTimer.running)
					{
						// If our first play has failed, let's try to resubscribe right away
						onRetryLiveStream(null);
						_liveStreamRetryTimer.reset();
						_liveStreamRetryTimer.start();
					}
					break;
			}
		}

		/** Handles the unsubscribe event dispatched from OvpConnection
		 * @private
		 */
		private function onFCUnsubscribe(info:Object):void {
			//trace("onFCUnsubscribe() - info.data.code = "+info.data.code);
		}

		private function onNetStatus(event:NetStatusEvent):void {
			switch (event.info.code) {
				case "NetStream.Play.PublishNotify":
					_successfullySubscribed = true;
					dispatchEvent(new OvpEvent(OvpEvent.SUBSCRIBED));
					resetAllLiveTimers();
					break;
				case "NetStream.Play.UnpublishNotify":
					_successfullySubscribed = false;
					_playReissueRequired = true;
					dispatchEvent(new OvpEvent(OvpEvent.UNSUBSCRIBED))
					if (!_liveStreamRetryTimer.running)
					{
						onRetryLiveStream(null);
						_liveStreamRetryTimer.reset();
						_liveStreamRetryTimer.start();
						_liveStreamTimeoutTimer.reset();
						_liveStreamTimeoutTimer.start();
					}
					break;
				
			}
		}		
	}
}
