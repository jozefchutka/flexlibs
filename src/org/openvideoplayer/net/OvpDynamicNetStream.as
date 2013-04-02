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
		import flash.events.NetStatusEvent;
		import flash.events.TimerEvent;
		import flash.net.NetConnection;
		import flash.net.NetStreamPlayOptions;
		import flash.net.NetStreamPlayTransitions;
		import flash.utils.Timer;
		
		import org.openvideoplayer.events.*;
		import org.openvideoplayer.net.dynamicstream.*;
		
	/**
	 * Dispatched when a debug message is being sent. The message itself will
	 * be carried by the contents of the data property.
	 * 
	 * @see org.openvideoplayer.events.OvpEvent
	 */
 	[Event (name = "debug", type = "org.openvideoplayer.events.OvpEvent")]
	
	/**
	 * Dispatched when a stream from a server is complete. 
	 * 
	 * @see org.openvideoplayer.events.OvpEvent#COMPLETE
 	 */
	[Event (name = "complete", type = "org.openvideoplayer.events.OvpEvent")]
	
	/**
	 * Dispatched when an OVP error condition has occurred. The OvpEvent object contains a data
	 * property.  The contents of the data property will contain the error number and a description.
	 * 
	 * @see org.openvideoplayer.events.OvpError
	 * @see org.openvideoplayer.events.OvpEvented
	 */
	[Event (name = "error", type = "org.openvideoplayer.events.OvpEvent")]
	
	 /**
	 * Dispatched when the class has completely played a stream, switches to a different stream in a server-side playlist or completes
	 * a dynamic transition.
	 * 
	 * @see #play
	 */
	[Event (name="playstatus", type="org.openvideoplayer.events.OvpEvent")]
	
	
	/**
	 * The OvpDynamicNetStream class extends OvpnetStream to implement Adobe's Dynamic Switching -i.e the ability to switch smoothly between
	 * a suite of consistent source files which vary in their bitrate and dimensions. Note that this class can function as both a standard non-switching 
	 * netstream and as a switching netstream, depending on the argument passed to the play() method. If you pass an instance of a DynamicStreamItem,
	 * it will invoke dynamic stream switching. If you pass a String, it will default to the same behavior as OvpNetStream.
	 * <p/>
	 * In order to monitor when switch transitions have completed, this class controls overrides the client object (keeps it null) and manages the onPlayStatus
	 * callback. Any information that would have been transmitted via the onPlayStatus callback is instead dispatched via the OvpEvent.NETSTREAM_PLAYSTATUS
	 * event. 
	 * <p/>
	 * The switching logic is implemented by a collection of switching rules, each of which implements ISwitchingRule. These are added via the addRule()
	 * method before playback begins. You may modify which rules are used, or easily write and insert your own rules if you wish to modify the switching
	 * logic. 
	 */
	public class OvpDynamicNetStream extends OvpNetStream {
		
		protected var _checkRulesTimer:Timer;
		protected var _switchingRules:Array;
		protected var _metricsProvider:MetricsProvider;
		protected var _streamIndex:int;
		protected var _oldStreamName:String;
		protected var _dsi:DynamicStreamItem;
		protected var _useManualSwitchMode:Boolean;
		protected var _switchUnderway:Boolean;
		protected var _renderingIndex:int;
		protected var _pendingIndex:Number;
		protected var _isMultibitrate: Boolean;
		protected var _reason:String;
		protected var _startingBuffer:Number;
		protected var _autoRateLimits:Boolean;
		protected var _rateLimits:Number;
		
		private const RULE_CHECK_INTERVAL_IN_MS:Number = 500;
		private const BUFFER_STABLE:Number = 8;
		private const BUFFER_START:Number = 1;
		
		/**
		 * Constructor
		 */
		public function OvpDynamicNetStream(nc:NetConnection) {
			
			super(nc);
			
			this.addEventListener(NetStatusEvent.NET_STATUS, handleNetStatus);
			_maxBufferLength = BUFFER_STABLE;
			_startingBuffer = BUFFER_START;
			_metricsProvider = new MetricsProvider(this);
			_metricsProvider.targetBufferTime = _maxBufferLength;
			_metricsProvider.addEventListener(OvpEvent.DEBUG,handleDebugEvents);
			_checkRulesTimer = new Timer(RULE_CHECK_INTERVAL_IN_MS);
			_checkRulesTimer.addEventListener(TimerEvent.TIMER, checkRules);
			_autoRateLimits = true;
			
			// Start with automatic switching by default
			_useManualSwitchMode = false;
			_switchingRules = new Array();
			// Add the switching rules we will be using and initialize them with the metrics provider instance
			addRule(new BandwidthRule(_metricsProvider));
			addRule(new FrameDropRule(_metricsProvider));
			addRule(new BufferRule(_metricsProvider));
		}
		
		/**
		 * Closes the stream and halts the metrics provider.
		 *
		 * @see flash.net.NetStream#close()
		 */
		public override function close():void {
			_progressTimer.stop();
			_streamTimer.stop();
			_metricsProvider.disable();
			super.close();
		}
		
		/**
		 * AutoRateLimits enables automatic limiting of server-client connection
		 * this can help improve speed of stream switches
		 */
		public function set autoRateLimits(b:Boolean):void{
			_autoRateLimits = b;
		}
		
		/**
		 * AutoRateLimits enables automatic limiting of server-client connection
		 * this can help improve speed of stream switches
		 */
		public function get autoRateLimits():Boolean{
			return _autoRateLimits;
		}
		
		/**
		 * Manually set the server-client connection limit in kbps
		 */
		public function set rateLimits(limit:Number):void{
			if (!_autoRateLimits){
				_rateLimits = limit
				setRateLimitsManual(_rateLimits);
			}else{
				debug("autoRateLimits must be disabled before manual setting");
			}
		}
		
		/** 
		 * Returns the current server-cleint connection limit in kbps
		 * This is not available bandwidth, but an imposed limit
		 */
		public function get rateLimits():Number{
			return _rateLimits;
		}
		
		/**
		 * Adds a heuristics rule to the stack
		 */
		public function addRule(rule:ISwitchingRule):void {
			rule.addEventListener(OvpEvent.DEBUG,handleDebugEvents);
			_switchingRules.push(rule);
		}
		
        /**
         * Adds a module into the heuristics engine, replacing all other rules
         */
		public function addAndReplaceRule(rule:ISwitchingRule):void {
			_switchingRules = new Array(rule);
		}
        
        /**
         * Empties the heuristics engine of all heuristics implementations
         */
        public function clearRules():void {
            _switchingRules = new Array();
        }
		
		/**
         * Returns the metrics provider instance
         */
        public function get metricsProvider():INetStreamMetrics {
            return _metricsProvider;
        }
		
		/**
         * Returns the buffer value in seconds that is used when playback starts
         */
        public function get startingBuffer():Number {
            return _startingBuffer;
        }
		/**
         * Sets the buffer value in seconds that is used when playback starts
         */
        public function set startingBuffer(startingBuffer:Number):void {
            _startingBuffer = startingBuffer;
        }
		

		/**
         * Sets the stable buffer value for the stream, in seconds.
         */
        override public function set maxBufferLength(bufferLength:Number):void {
            _maxBufferLength = bufferLength;
			_metricsProvider.targetBufferTime = _maxBufferLength;
        }
		
		
		/**
		 * Initiates playback of a stream. The argument type passed will dictate whether this class switches or not. If a 
		 * DynamicStreamItem is passed, switching will take place. If a String is passed, conventional non-switching playback will occur and 
		 * the metrics provider instance will be disabled to reduce unnecessary background calculations. 
		 * 
		 * @param playObject This object can be either an DynamicStreamItem or a String. If passing a string, you may also pass additional play arguments such
		 * as start, len and reset.
		 * 
		 * @see org.openvideoplayer.net.dynamicstream.DynamicStreamItem
		 */
		
		
		override public function play(...args):void {
			
			if (!_progressTimer.running)
				_progressTimer.start();
			if (!_streamTimer.running)
				_streamTimer.start();
				
			if (args[0] is DynamicStreamItem){
				_dsi = args[0] as DynamicStreamItem;
				_isMultibitrate = true;
				_metricsProvider.enable();
				_metricsProvider.optimizeForLivebandwidthEstimate = isLive;
				startPlay();
 			} else if (args[0] is String) {
				_metricsProvider.disable();
				_isMultibitrate = false;
				super.play.apply(this,args);
			}
			
		}
			
		/**
         * Returns the highest index available in the DynamicStreamItem which is being played.
         */
		public function get maxIndex():int {
			return _dsi.streamCount - 1;
		}
		
		/**
		 * Returns the current stream index that is rendering on the client. Note that this may differ
		 * from the last index requested if this property is requested between the 
		 * NetStream.Play.Transition and NetStream.Play.TransitionComplete events. 
		 */
		public function get renderingIndex():uint {
			return _renderingIndex;
		}
		
		/**
		 * Returns the current playback rate of this stream, in kbps. 
		 */
		public function get playbackKiloBitsPerSecond():int {
			return Math.round(this.info.playbackBytesPerSecond*8/1024);
		}
		
		/**
         * Instructs the class to switch between manual and automatic switching modes. The default is automatic. In
		 * manual mode, use the switchUp() and switchDown() methods to request stream switches. 
		 * 
		 * @see #switchUp()
		 * @see #switchDown()
		 * @see #switchTo()
         */
		public function useManualSwitchMode(useManual:Boolean):void {
			_useManualSwitchMode = useManual;
			if (_useManualSwitchMode) {
				debug("Manual switching enabled");
				_checkRulesTimer.stop();
			} else {
				debug("Auto switching enabled");
				_checkRulesTimer.start();
			}
		}
		
		/**
         * In manual switching mode only, switches up to the next highest bitrate. If it is already playing the highest index
		 * it will dispatch a OvpError.INVALID_INDEX error event. 
		 * 
		 * @see #switchDown()
		 * @see #useManualSwitchMode()
		 * @see #switchTo()
         */
		public function switchUp():void {
			if (_useManualSwitchMode) {
				if (_streamIndex + 1  >  _dsi.streamCount - 1 ) {
					debug("Already playing the highest stream");
					dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.INVALID_INDEX)));
				} else {
					debug("Manually switching up");
					_reason = "Manual switch request.";					
					switchToIndex(_streamIndex + 1,false);
				}
			}
		}
		
		/**
         * In manual switching mode only, switches down to the next lowest bitrate. If it is already playing the zeroth index
		 * it will dispatch a OvpError.INVALID_INDEX error event. 
		 * 
		 * @see #switchUp()
		 * @see #useManualSwitchMode()
		 * @see #switchTo()
         */
		public function switchDown():void {
			if (_useManualSwitchMode) {
				if (_streamIndex - 1  < 0 ) {
					debug("Already playing the lowest stream");
					dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.INVALID_INDEX)));
				} else {
					debug("Manually switching down");
					_reason = "Manual switch request.";					
					switchToIndex(_streamIndex - 1,false);
				}
			}
		}
		
		/**
         * In manual switching mode only, switches to the specified index. If the index is out of range,
		 * it will dispatch a OvpError.INVALID_INDEX error event. 
		 * 
		 * @see #switchUp()
		 * @see #switchDown()
		 * @see #useManualSwitchMode()
         */
		public function switchTo(index:int):void {
			if (_useManualSwitchMode) {
				if (index < 0 || index > maxIndex) {
					debug("Requested switch index is out of range");
					dispatchEvent(new OvpEvent(OvpEvent.ERROR, new OvpError(OvpError.INVALID_INDEX)));
				} else {
					debug("Manually switching to index " + index);
					_reason = "Manual switch request.";
					switchToIndex(index,false);
				}
			}
		}
		
		/**
		 * Returns the average maximum bandwidth in kbps
		 */	
		public function get maxBandwidth():Number {
			return _metricsProvider.averageMaxBandwidth;
		}
		
		/**
		 * Returns the current stream bitrate in kbps
		 */	
		public function get currentStreamBitRate():Number {
			if (_streamIndex < 0 || _streamIndex > _dsi.streamCount) {
				debug ("Error with currentStreamBitRate for " + _streamIndex);
			}
			return _dsi.streams[_streamIndex].rate;
		}
		
		
		/**
		 * Catches onPlayStatus callbacks. Do not call this function directly. If you want the callback information, listen
		 * to the OvpEvent.NETSTREAM_PLAYSTATUS event. 
		 */	
		override protected function onPlayStatus(info:Object):void { 
        	
			switch(info.code) {
				case "NetStream.Play.TransitionComplete":
					_renderingIndex  = _pendingIndex;
					debug("Transition complete to index " + _renderingIndex + " at " + Math.round(_dsi.getRateAt(_renderingIndex )) +  " kbps");
					// dispatch the switching complete message
					var data:Object = new Object();
					data.renderingIndex = _renderingIndex;
  		 			data.renderingBitrate = Math.round(_dsi.getRateAt(_renderingIndex ));
  		 			dispatchEvent(new OvpEvent(OvpEvent.SWITCH_COMPLETE, data));
					break;
				
				case "NetStream.Play.Complete":
					dispatchEvent(new OvpEvent(OvpEvent.COMPLETE));
					break;
			}
			
			dispatchEvent(new OvpEvent(OvpEvent.NETSTREAM_PLAYSTATUS,info));
		}
		
		/**
		* Disables calls to the default play2() method. Do not call this function. If you want to play multi-bitrate content, use the
		* play() method instead. 
		* 
		* @see #play()
		 */	
		override public function play2(param:NetStreamPlayOptions):void {
			// Do nothing. 
		}
		
		/**
		 * @private
		 */
		private function startPlay():void {
			
			_metricsProvider.dynamicStreamItem = _dsi;
			
			this.bufferTime = isLive? _maxBufferLength: _startingBuffer;
			_streamIndex = 0;
			_pendingIndex = NaN;
					
			if ((_dsi.startingIndex >= 0) && (_dsi.startingIndex < _dsi.streamCount)) {
				_streamIndex = _dsi.startingIndex;
			} 	else if (_metricsProvider.averageMaxBandwidth > 0) {
				for (var i:int = _dsi.streamCount-1; i >= 0; i--) {
					if (_metricsProvider.averageMaxBandwidth > _dsi.getRateAt(i) ) {
						_streamIndex = i;
						break;
					}
				}
			} 
			if (_streamIndex == 0) {
				chooseDefaultStartingIndex()
			} else {
				makeFirstSwitch();
			}
		}
		
		/**
		 * Override this function if you wish to implement alternate starting logic
		 * @private 
		 */
		protected function chooseDefaultStartingIndex():void {
				// Let's start with the lowest profile above 300kbps
				for (var j:int = 0; j < _dsi.streamCount; j++) {
					if (300 < _dsi.getRateAt(j) ) {
						_streamIndex = j;
						break;
					}
				}
				makeFirstSwitch();
		}
		
		/**
		 * @private
		 */
		protected function makeFirstSwitch():void {
			if (!_useManualSwitchMode) {
				_checkRulesTimer.start();
			}
			// Set the starting max data rate from the server to be 120% of the highest bitrate in the DSI
			if (_autoRateLimits) {
				setRateLimits(_dsi.streamCount - 1);
			}
			debug("Starting with stream index " + _streamIndex + " at " + Math.round(_dsi.getRateAt(_streamIndex)) + " kbps");
			switchToIndex(_streamIndex, true);
			_metricsProvider.currentIndex = _streamIndex;
		}
		
		/**
		 * @private
		 */
		private function setRateLimits(index:int):void {
			// We set the bandwidth in both directions to 140% of the bitrate level. 
			_rateLimits = _dsi.getRateAt(index) * 1.40;
			debug("Set rate limit to " + Math.round(_rateLimits) + " kbps");
			_nc.call("setBandwidthLimit", null, _rateLimits * 1024/8, _rateLimits * 1024/8);
		}

		/**
		 * @private
		 */
		private function setRateLimitsManual(limit:Number):void {
			// remember to use kpbs 
			_rateLimits = limit
			debug("Manually setting rate limit to " + _rateLimits + " kbps");
			_nc.call("setBandwidthLimit",null, _rateLimits * 1024/8, _rateLimits * 1024/8);
		}
		
		
		/**
		* This function is provided so that any class extending this class can modify the 
		* NetStreamPlayOptions that are being requested. 
		*/
		protected function prepareNetStreamPlayOptions(targetIndex:uint,firstPlay:Boolean):NetStreamPlayOptions{
			var nso:NetStreamPlayOptions = new NetStreamPlayOptions();
			nso.start = _dsi.start;
			nso.len = _dsi.len;
			nso.streamName = _dsi.getNameAt(targetIndex);
			nso.oldStreamName = _oldStreamName;
			nso.transition = firstPlay ? NetStreamPlayTransitions.RESET:NetStreamPlayTransitions.SWITCH;
			_oldStreamName = _dsi.getNameAt(targetIndex);
			debug("Switching to index " + targetIndex + " at " + Math.round(_dsi.getRateAt(targetIndex)) + " kbps");
			return nso;
		}
		
		/**
		 * @private
		 */
		private function switchToIndex(targetIndex:uint, firstPlay:Boolean = false):void {
			var nso:NetStreamPlayOptions = prepareNetStreamPlayOptions(targetIndex,firstPlay);
			
			// dispatch the switch requested event
			var data:Object = new Object();
  		 	data.targetIndex = targetIndex;	
  		 	data.streamName = nso.streamName;
  		 	data.firstPlay = firstPlay;
  		 	data.reason = this._reason;
			
			dispatchEvent(new OvpEvent(OvpEvent.SWITCH_REQUESTED, data));
			
			if (firstPlay)
			{
				super.play(nso.streamName);
			}
			else
			{
				super.play2(nso);
			}
			
			
			
			if (!firstPlay && targetIndex < _streamIndex && !_useManualSwitchMode) {
				// this is a failure for the current stream so lets tag it as such
				_dsi.incrementFailCountAt(_streamIndex);
			}
			if (firstPlay) {
				_switchUnderway  = false;
				_renderingIndex = targetIndex;
				_streamIndex = targetIndex;
				_pendingIndex = targetIndex;
				this.client.onPlayStatus({code:"NetStream.Play.TransitionComplete"})
			} else {
				_switchUnderway  = true;
			}
		}
		
		/**
		 * @private
		 */
		private function checkRules(e:TimerEvent):void {
			var newIndex:int = int.MAX_VALUE;
			_reason = "";
			
			for (var i:int = 0; i < _switchingRules.length; i++) {
				var x:int =  _switchingRules[i].getNewIndex();
				if (x != -1 && x < newIndex) {
					newIndex = x;
					_reason = _switchingRules[i].reason;
				} 
			}
			if (newIndex != -1 && 
				newIndex != int.MAX_VALUE  && 
				newIndex != _streamIndex &&
				!_switchUnderway && 
				_dsi.isAvailable(newIndex)) {
				debug("Calling for switch to " + newIndex + " at " + _dsi.getRateAt(newIndex));
				debug("Reason: " + _reason);
				switchToIndex(newIndex);
			}  
			
		}
		
		/**
		 * @private
		 */
		private function handleNetStatus(e:NetStatusEvent):void {
			if (_isMultibitrate) {
				switch (e.info.code) {
					case "NetStream.Buffer.Full":
					if (_isMultibitrate) {
							this.bufferTime = _maxBufferLength;
					}
					break;
					case "NetStream.Play.Start":
						this.bufferTime = isLive? _maxBufferLength:_startingBuffer;
					break;
					case "NetStream.Play.Transition":
						_switchUnderway  = false;
						_streamIndex = _dsi.indexFromName(e.info.details);
						if (autoRateLimits) {
							setRateLimits(_streamIndex);
						}
						_metricsProvider.currentIndex = _streamIndex;
						_pendingIndex = _streamIndex;
						
						// dispatch the switch acknowledged event
		 				var data:Object = new Object;
		 				data.nsInfo = e.info;
						dispatchEvent(new OvpEvent(OvpEvent.SWITCH_ACKNOWLEDGED, data));				
					break;
					case "NetStream.Play.Failed":
						_switchUnderway  = false;
					break;
					case "NetStream.Seek.Notify":
						this.bufferTime = isLive? _maxBufferLength:_startingBuffer;
						_switchUnderway  = false;
						if (!isNaN(_pendingIndex)) {
							_renderingIndex  = _pendingIndex;
							_pendingIndex = NaN;
						}
						
					break;
					case "NetStream.Play.Stop":
						_checkRulesTimer.stop();
						debug("Stopping rules since server has stopped sending data");
					break;
					
				}
			}
		}
	
		/**
		 * @private
		 */	
		protected function debug(msg:String):void {
				dispatchEvent(new OvpEvent(OvpEvent.DEBUG, msg));
		}
		/**
		 * @private
		 */	
		private function handleDebugEvents(e:OvpEvent):void {
			debug(e.data.toString());
		}
		
	}
}
