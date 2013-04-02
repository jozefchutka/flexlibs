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
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.NetStreamPlayOptions;
	import flash.net.NetStreamPlayTransitions;
	import flash.utils.Timer;
	
	import org.openvideoplayer.events.OvpError;
	import org.openvideoplayer.events.OvpEvent;
	import org.openvideoplayer.net.OvpConnection;
	import org.openvideoplayer.net.OvpDynamicNetStream;
	import org.openvideoplayer.net.dynamicstream.*;
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
	 * Dispatched when the class has unsubscribed from a live stream, or when the live stream it was previously subscribed
	 * to has ceased publication.
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
	 * This class extends OvpDynamicNetStream to provide support  
	 * for live stream subscription and authentication on the Akamai CDN.
	 * 
	 * Note that this class can be used to play single-stream content as 
	 * well as multi-bitrate content. If you are building a player
	 * that will play content from Akamai, you can invoke this class as 
	 * your single NetStream instance and then not worry about whether 
	 * the content is multi-bitrate or single bitrate. 
	 */
	public class AkamaiDynamicNetStream extends OvpDynamicNetStream {
		private var _liveStreamAuthParams:String;
		private var _liveStreamRetryTimer:Timer;
		private var _liveStreamTimeoutTimer:Timer;
		private var _successfullySubscribed:Boolean;
		private var _liveRetryInterval:Number;
		private var _liveStreamMasterTimeout:Number;
		private var _playingLiveStream:Boolean;
		private var _pendingLiveStreamName:String;
		private var _akamaiConnection:AkamaiConnection;
		private var _retryLiveStreamsIfUnavailable:Boolean;
		private var _playReissueRequired:Boolean;

		private const LIVE_RETRY_INTERVAL:Number = 15000;
		private const LIVE_RETRY_TIMEOUT:Number = 1200000;
		
		/**
		 * Constructor
		 * 
		 * @param connection This object can be either an AkamaiConnection object, 
		 * an OvpConnection object or a NetConnection object. If an OvpConnection 
		 * object is provided, the constructor will use the NetConnection object 
		 * within it.
		 * <p />
		 * If you are connecting to a live stream on the Akamai network, you must 
		 * pass in an AkamaiConnection object in order to trigger the correct 
		 * subscription process.
		 */
		public function AkamaiDynamicNetStream (connection:Object) {
			var nc:NetConnection;
			
			if  (connection is AkamaiConnection) {	
				_akamaiConnection = connection as AkamaiConnection;				
				nc = _akamaiConnection.netConnection;
			} else if (connection is OvpConnection) {
				nc = (connection as OvpConnection).netConnection;
			} else {
				nc = connection as NetConnection;
			}

			super(nc);

			if (_akamaiConnection != null && _akamaiConnection.isLive) {
				_akamaiConnection.addEventListener(OvpEvent.FCSUBSCRIBE,onFCSubscribe);
				_akamaiConnection.addEventListener(OvpEvent.FCUNSUBSCRIBE,onFCUnsubscribe);
				this.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				isLive = true;
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
		
		/**
		 * Initiates playback of a stream. The argument type passed will 
		 * dictate whether this class switches or not. If a DynamicStreamItem 
		 * is passed, switching will take place. If a String is passed, conventional 
		 * non-switching playback will occur and the metrics provider instance will 
		 * be disabled to reduce unnecessary background calculations. 
		 * <p/>
		 * If a String is passed, Akamai specific live stream auth params and 
		 * the live stream subscription process will be invoked. 
		 * 
		 * @param playObject This object can be either an DynamicStreamItem or a 
		 * String. If passing a string, you may also pass additional play arguments 
		 * such as start, len and reset.
		 * 
		 * @see org.openvideoplayer.net.dynamicstream.DynamicStreamItem
		 */
		public override function play(... arguments):void {
			trace("at play " + arguments[0] + " nc=" + _akamaiConnection);
			if (arguments[0] is String && !_isProgressive && arguments && arguments.length) {
				// Add prefix if necessary
				arguments[0] = addPrefix(arguments[0]);
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
			}
			else if (arguments[0] is DynamicStreamItem && _akamaiConnection.isLive) {
				_dsi = arguments[0] as DynamicStreamItem;
				_isMultibitrate = true;
				isLive = true;
				_liveStreamTimeoutTimer.reset();
				_liveStreamTimeoutTimer.start();
			}
			
			super.play.apply(this, arguments);
		}
		
		/**
		* Strips any query args from the streamName
		*/
		override protected function prepareNetStreamPlayOptions(targetIndex:uint,firstPlay:Boolean):NetStreamPlayOptions{
			var nso:NetStreamPlayOptions = new NetStreamPlayOptions();
			nso.start = _dsi.start;
			nso.len = _dsi.len;
			nso.streamName = firstPlay ? _dsi.getNameAt(targetIndex):_dsi.getNameAt(targetIndex).split("?")[0];
			
			if (firstPlay && _liveStreamAuthParams != "")
			{
				nso.streamName = nso.streamName.indexOf("?") != -1 ? nso.streamName + "&" + _liveStreamAuthParams : nso.streamName + "?" + _liveStreamAuthParams;
			}
			
			nso.oldStreamName = _oldStreamName;
			nso.transition = firstPlay ? NetStreamPlayTransitions.RESET:NetStreamPlayTransitions.SWITCH;
			_oldStreamName = nso.streamName.split("?")[0];
			debug("Switching to index " + targetIndex + " with name " + nso.streamName +  " at " + Math.round(_dsi.getRateAt(targetIndex)) + " kbps");
			return nso;
		}
		
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
		 * <code>NetStatusEvent</code> event with <code>info.code</code> set to "NetStream Failed" will be dispatched. 
		 * <p />
		 * Note that if you are playing Multi-bitrate content, the stream auth tokens should not be included in
		 * the SMIL file, but instead supplied separately via this property before the play() method is called.
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
		 * If this property is true, then if a live stream is playing and becomes unpublished due to both the primary and backup encoders
		 * ceasing to publish, the class will automatically enter into a retry cycle, where it will attempt to
		 * play the streams again. Similarly, if a play request is made and the live stream is not found, the class
		 * will reattempt the streams at a predefined interval. This interval is set by the liveRetryInterval. The retries
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
		
		/**
		 * Makes sure to shut down any pending resubscribe attempts before closing.
		 */
		override public function close():void {
			super.close();
			
			if (isLive) {
				resetAllLiveTimers();
			}
		}
		
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
				if (_isMultibitrate) {
					for (var q:int = 0; q < _dsi.streamCount; q++) {
						_akamaiConnection.callFCSubscribe(_dsi.getNameAt(q).split("?")[0].toString());
					}
				} else {
					_akamaiConnection.call("FCSubscribe", null, _pendingLiveStreamName.split("?")[0].toString());
				}

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
					args.push(_isMultibitrate ? _dsi : _pendingLiveStreamName);
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
		
		/**
		 * @private
		 */
		private function resetAllLiveTimers():void {
			_liveStreamRetryTimer.reset();
			_liveStreamTimeoutTimer.reset();
		}
		
		public function onFCSubscribe(info:Object):void {
			debug("onFCSubscribe() - info.data.code="+info.data.code);
			
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
			debug("onFCUnsubscribe() - info.data.code = "+info.data.code);
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
		
		/** 
		 * @private
		 */
		override protected function chooseDefaultStartingIndex():void {
			// Let's measure bandwidth against the server in order to guess our starting point
			_akamaiConnection.addEventListener(OvpEvent.BANDWIDTH, handleBandwidthResult);
			debug("Measuring bandwidth in order to determine a good starting point");
			_akamaiConnection.detectBandwidth();
		}
		
		/** 
		 * @private
		 */
		private function handleBandwidthResult(e:OvpEvent):void {
			// If the bandwidth has produced a valid value, use it
			if (e.data.bandwidth > 0) {
				for (var i:int = _dsi.streamCount - 1; i >= 0; i--) {
					if (e.data.bandwidth > _dsi.getRateAt(i) ) {
							_streamIndex = i;
							break;
					}
				}
			} else {
				// Sometimes FMS returns a false 0 bandwidth result. In this
				// case, lets start with the first profile above 300kbps. 
				for (var j:int = 0; j < _dsi.streamCount; j++) {
					if (300 < _dsi.getRateAt(j) ) {
						_streamIndex = j;
						break;
					}
				}
			}

			if (isLive)
			{
				_pendingLiveStreamName = _dsi.getNameAt(_streamIndex);
			}
			makeFirstSwitch();
		}
	}
}
