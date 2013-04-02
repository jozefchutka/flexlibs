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
package org.openvideoplayer.net.dynamicstream
{
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetStream;
	import flash.net.NetStreamInfo;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	import org.openvideoplayer.events.OvpEvent;
	
	/**
 	 * Dispatched when the class has a debug message to propagate.
	 */
 	[Event (name = "debug", type = "org.openvideoplayer.events.OvpEvent")]
	
	/**
	 * The purpose of the MetricsProvider class is to provide run-time metrics to the switching rules. It 
	 * makes use of the metrics offered by netstream.info, but more importantly it calculates running averages, which we feel
	 * are more robust metrics on which to make switching decisions. It's goal is to be the one-stop shop for all the info you
	 * need about the health of the stream.
	 */
	public class MetricsProvider extends EventDispatcher implements INetStreamMetrics
	{
		private var _ns:NetStream;
		private var _timer:Timer;
		private var _reachedTargetBufferFull:Boolean;
		private var _currentBufferSize:Number;
		private var _maxBufferSize:Number;
		private var _lastMaxBitrate:Number;
		private var _avgMaxBitrateArray:Array;
		private var _avgMaxBitrate:Number;
		private var _avgDroppedFrameRateArray:Array;
		private var _avgDroppedFrameRate:Number;
		private var _frameDropRate:Number;
		private var _lastFrameDropValue:Number;
		private var _lastFrameDropCounter:Number;
		private var _maxFrameRate:Number
		private var _currentIndex:uint;
		private var _dsi:DynamicStreamItem;
		private var _so:SharedObject;
		private var _targetBufferTime:Number;
		private var _enabled:Boolean;
		private var _optimizeForLivebandwidthEstimate:Boolean;
		private var _framerateChecked:int;
		private var _smoothStartup:Boolean;
		private var _smoothStartupCap:Number;
		private var _smoothStartupValue:Number;
		private var _startupCount:int;
		private var _smoothStartupSampleSize:int;
		private var _avgBandwidthSampleSize:int;
		private var _avgFramerateSampleSize:int;
		private var _autoFramerateUpdate:Boolean;
		private var _qualityRating:Number;
		
		private const DEFAULT_UPDATE_INTERVAL:Number = 100;
		private const DEFAULT_AVG_BANDWIDTH_SAMPLE_SIZE:int = 50;
		private const DEFAULT_AVG_FRAMERATE_SAMPLE_SIZE:Number = 50;
		private const DEFAULT_SMOOTH_STARTUP_SAMPLE_SIZE:int = 10;
		
		/**
		 * Constructor
		 * 
		 * Note that for correct operation of this class, the caller must set the dynamicStreamItem which
		 * the monitored stream is playing each time a new item is played.
		 * 
		 * @param netstream instance that it will monitor.
		 * @see #dynamicStreamItem()
		 */
		public function MetricsProvider(ns:NetStream) {
			super(null);
			_ns = ns;
			_ns.addEventListener(NetStatusEvent.NET_STATUS,netStatus);
			_frameDropRate = 0;
			_reachedTargetBufferFull = false;
			_lastFrameDropCounter = 0;
			_lastFrameDropValue = 0;
			_maxFrameRate = 0;
			_optimizeForLivebandwidthEstimate = false;
			_avgMaxBitrateArray = new Array();
			_avgDroppedFrameRateArray = new Array();
			_enabled = true;
			_targetBufferTime = 0;
			_smoothStartup = true;
			_smoothStartupValue = 0;
			
			_so = SharedObject.getLocal("OVPMetricsProvider", "/", false);

			if (_so.data.avgMaxBitrate != undefined) {
				_avgMaxBitrate = _so.data.avgMaxBitrate;
			}

			_timer = new Timer(DEFAULT_UPDATE_INTERVAL);
			_timer.addEventListener(TimerEvent.TIMER, update);

			_startupCount = 0;
			_smoothStartupSampleSize = DEFAULT_SMOOTH_STARTUP_SAMPLE_SIZE;
			_avgBandwidthSampleSize = DEFAULT_AVG_BANDWIDTH_SAMPLE_SIZE;
			_avgFramerateSampleSize = DEFAULT_AVG_FRAMERATE_SAMPLE_SIZE;
			_autoFramerateUpdate = true;
		}
		
		/**
		 * Returns the update interval at which metrics and averages are recalculated
		 */
		public function get updateInterval():Number {
			return _timer.delay
		}
		
		public function set updateInterval(intervalInMilliseconds:Number):void {
			_timer.delay = intervalInMilliseconds;
		}
		
		/**
		 * Returns the NetStream sent in the constructor
		 */
		public function get netStream():NetStream{
			return _ns;
		}
				
		/**
		 * Returns the current index
		 */
		public function get currentIndex():uint{
			return _currentIndex;
		}
		
		public function set currentIndex(i:uint):void {
			_currentIndex = i;
		}
		
		/**
		 * Returns the maximum index value 
		 */
		public function get maxIndex():uint {
			return _dsi.streamCount -1 as uint
		}
		
		/**
		 * Returns the DynamicStreamItem which the class is referencing
		 */
		public function get dynamicStreamItem():DynamicStreamItem{
			return _dsi;
		}
		
		public function set dynamicStreamItem(dsi:DynamicStreamItem):void {
			_dsi= dsi;
		}
		
		/**
		 * Returns true if the target buffer has been reached by the stream
		 */
		public function get reachedTargetBufferFull():Boolean
		{
			return _reachedTargetBufferFull;
		}
		
		/**
		 * Returns the current bufferlength of the NetStream
		 */
		public function get bufferLength():Number
		{
			return _ns.bufferLength;
		}
		
		/**
		 * Retufns the current bufferTime of the NetStream
		 */
		public function get bufferTime():Number
		{
			return _ns.bufferTime;
		}
		
		/**
		 * Returns the target buffer time for the stream. This target is the buffer level at which the 
		 * stream is considered stable. 
		 */
		public function get targetBufferTime():Number
		{
			return _targetBufferTime;
		}
		
		public function set targetBufferTime(targetBufferTime:Number):void 
		{
			_targetBufferTime = targetBufferTime;
		}
		
		
		/**
		 * Flash player can have problems attempting to accurately estimate max bytes available with live streams. The server will buffer the 
		 * content and then dump it quickly to the client. The client sees this as an oscillating series of maxBytesPerSecond measurements, where
		 * the peak roughly corresponds to the true estimate of max bandwidth available. Setting this parameter to true will cause this class
		 * to optimize its estimate for averageMaxBandwidth. It should only be set true for live streams and should always be false for ondemand streams. 
		 */
		public function get optimizeForLivebandwidthEstimate ():Boolean
		{
			return _optimizeForLivebandwidthEstimate 
		}
		public function set optimizeForLivebandwidthEstimate (optimizeForLivebandwidthEstimate :Boolean):void 
		{
			_optimizeForLivebandwidthEstimate  = optimizeForLivebandwidthEstimate ;
		}
		
		/**
		 * Returns the expected frame rate for this NetStream. 
		 */
		public function get expectedFPS():Number
		{
			return _maxFrameRate;
		}
		
		/**
		 * Returns the frame drop rate calculated over the last interval.
		 */
		public function get droppedFPS():Number
		{
			return _frameDropRate;
		}
		
		/**
		 * Returns the average frame-drop rate
		 */
		public function get averageDroppedFPS():Number
		{
			return _avgDroppedFrameRate
		}
		
		/**
		 * Returns the last maximum bandwidth measurement, in kbps
		 */
		public function get maxBandwidth():Number
		{
			return _lastMaxBitrate;
		}
		
		/**
		 * Returns the average max bandwidth value, in kbps
		 */
		public function get averageMaxBandwidth():Number
		{
			return _avgMaxBitrate;
		}
		
		/**
		 * Returns a reference to the info property of the monitored NetStream
		 */
		public function get info():NetStreamInfo {
			return _ns.info;
		}
		
		/**
		 * The state of automatic framerate updates
		 */
		public function get autoFramerateUpdate():Boolean {
			return _autoFramerateUpdate;
		}

		public function set autoFramerateUpdate(b:Boolean):void {
			_autoFramerateUpdate = b;
		}
 		
 		/**
		 * The number of framerate samples that are used to calculate the average framerate
		 */
		public function get avgFramerateSampleSize():int {
			return _avgFramerateSampleSize;
		}

		public function set avgFramerateSampleSize(i:int):void {
			_avgFramerateSampleSize = i;
		}

		/**
		 * The number of bandwidth samples that are used to calculate the average max bandwidth
		 */
		public function get avgBandwidthSampleSize():int {
			return _avgBandwidthSampleSize;
		}
		
		public function set avgBandwidthSampleSize(i:int):void {
			_avgBandwidthSampleSize = i;
		}

		/**
		 * smoothStartupCap is used to help control spikes in the startup bandwidth measurement
		 * generally set it to ~ 1.5 times the highest available rendition.
		 */
		public function get smoothStartupCap():Number {
			return _smoothStartupCap;
		}

		public function set smoothStartupCap(cap:Number):void {
			_smoothStartupCap = cap;
		}
		
		/**
		 * The state of smoothStartup
		 */
		public function get smoothStartup():Boolean	{
			return _smoothStartup;
		}

		public function set smoothStartup(b:Boolean):void {
			_smoothStartup = b;
		}
		
		/**
		 * The current value of smoothStartup, this is the total bandwidth used in averaging
		 */
		public function get smoothStartupValue():Number {
			return _smoothStartupValue;
		}
		
		public function set smoothStartupValue(n:Number):void {
			_smoothStartupValue = n;
		}
		
		/**
		 * The minimum number of samples to collect before starting the smoothStartup average
		 */
		public function get smoothStartupSampleSize():int {
			return _smoothStartupSampleSize;
		}
		
		public function set smoothStartupSampleSize(i:int):void	{
			_smoothStartupSampleSize = i;
		}
		
		/**
		 * Enables this metrics engine.  The background processes will only resume on the next
		 * netStream.Play.Start event.
		 */
		public function enable(): void {
			_enabled = true;
		}
		
		/**
		 * Disables this metrics engine. The background averaging processes
		 * are stopped. 
		 */
		public function disable(): void {
			_enabled = false;
			_timer.stop();
		}
		
		/**
		 * @private
		 */
		private function netStatus(e:NetStatusEvent):void {
			switch (e.info.code) {
				case "NetStream.Buffer.Full":
					_reachedTargetBufferFull = _ns.bufferLength >= _targetBufferTime;
					break;
				case "NetStream.Buffer.Empty":
					_reachedTargetBufferFull = false;
					break;
				case "NetStream.Play.Start":
					_reachedTargetBufferFull = false;
					if (!_timer.running && _enabled) {
						_timer.start();
					}
					break;
				case "NetStream.Seek.Notify":
					_reachedTargetBufferFull = false;
					break;
				case "NetStream.Play.Stop":
					_timer.stop();
					break;
			}
		}
		
		/**
		 * Updates the bandwidth (and possibly framerate) data used by the switching rules.
		 */
		protected function update(e:TimerEvent):void 
		{
			try {
				// Average max bandwdith
				var currentMaxBitrate:Number = info.maxBytesPerSecond * 8 / 1024;
				// if the maxBytesPerSecond hasn't changed it usually indicates we are re-using stale data.
				// if  the current measured bandwidth is 0 it is ignored.
				//if (currentMaxBitrate != _lastMaxBitrate && currentMaxBitrate != 0){
				if (currentMaxBitrate != 0){
					
					// smoothStartup allows a very quick and resonably safe bandwidth measurement to take place before the averaging array is full
					// this measurement is restricted by the smoothStartupCap if set, but will be overridden by the standard bandwidth measurements
					// once they have enough data.
					if (_smoothStartup)
					{
						// startup bandwidth measuring, this is where bandwidth measurement fluctuations are most damaging.
						_startupCount ++;
						// if the smoothStartupCap hasn't been set we effectivly ignore it
						if (!_smoothStartupCap){_smoothStartupCap = Number.MAX_VALUE;}
						// if the current measurement is above the Cap we limit it's effect on the reported bandwidth to help control
						// for spikes in the measured bandwidth.
						if (currentMaxBitrate > _smoothStartupCap){currentMaxBitrate = _smoothStartupCap;}
						// calculate the capped available bandwidth							
						_smoothStartupValue += currentMaxBitrate;
						_avgMaxBitrate = _startupCount >= _smoothStartupSampleSize ? _smoothStartupValue/_startupCount : 0;
						// once the standard bandwidth measurement technique has sufficient data we can turn off smoothstart
						if (_startupCount >= _avgBandwidthSampleSize){
							_smoothStartup = false;
						}
					}
					
					// Standard bandwidth measurement technique 
					_avgMaxBitrateArray.unshift(currentMaxBitrate);
					
					if (_avgMaxBitrateArray.length > _avgBandwidthSampleSize) {
						_avgMaxBitrateArray.pop();
					}
					var totalMaxBitrate:Number = 0;
					var peakMaxBitrate:Number = 0;
					for (var b:uint=0;b<_avgMaxBitrateArray.length;b++) {
						totalMaxBitrate += _avgMaxBitrateArray[b];
						peakMaxBitrate = _avgMaxBitrateArray[b] > peakMaxBitrate ? _avgMaxBitrateArray[b]: peakMaxBitrate;
					}
					if (!_smoothStartup)
					{
						_avgMaxBitrate = _avgMaxBitrateArray.length < _avgBandwidthSampleSize ? 0:_optimizeForLivebandwidthEstimate ? peakMaxBitrate:totalMaxBitrate/_avgMaxBitrateArray.length;
					
					}
					_so.data.avgMaxBitrate = _avgMaxBitrate;
					
					// if automatic framerate updates are not disabled update the framerate data now
					if (_autoFramerateUpdate) { 
						updateFramerate(); 
					}
 				}
 				
 				_lastMaxBitrate = currentMaxBitrate;
 				
 			}
			catch (e:Error) {
				debug("org.openvideoplayer.net.dynamicstream.MetricsProvider.update() eating this exception: id="+e.errorID+" "+e.message);
			}
		}
		
		/**
		 * Because framerate is most important when the CPU is under a heavy load and this is also the time
		 * that a timer can see dramaticly increased lag updateFramerate is made public so that rules can  
		 * ensure that they have updated values on which to base their decisions.
		 */
		public function updateFramerate():void
		{
			try {
 				// Estimate max (true) framerate
 				_maxFrameRate = _ns.currentFPS > _maxFrameRate ? _ns.currentFPS:_maxFrameRate;
				
				// because Timer delay can't be relied upon to be accurate under CPU load this is 
				// probably a more accurate means of getting the delay
				var currentTime:int = new Date().time;
				var framerateDelay:int = currentTime - _framerateChecked;
				_framerateChecked = currentTime;
				
 				// Frame drop rate, per second, calculated over _avgFramerateSampleSize x 
				if (framerateDelay > 0) {
					_frameDropRate = (_ns.info.droppedFrames - _lastFrameDropValue)/framerateDelay;
 					_lastFrameDropValue = _ns.info.droppedFrames;
 					
					_avgDroppedFrameRateArray.unshift(_frameDropRate);
					if (_avgDroppedFrameRateArray.length > _avgFramerateSampleSize) {
						_avgDroppedFrameRateArray.pop();
					}
					var totalDroppedFrameRate:Number = 0;
					for (var f:uint=0;f<_avgDroppedFrameRateArray.length;f++) {
						totalDroppedFrameRate +=_avgDroppedFrameRateArray[f];
					}
 				}
				_avgDroppedFrameRate = _avgDroppedFrameRateArray.length < _avgFramerateSampleSize? 0:totalDroppedFrameRate/_avgDroppedFrameRateArray.length;
			} 
			catch (e:Error) {
				debug("org.openvideoplayer.net.dynamicstream.MetricsProvider.updateFramerate() eating this exception: id="+e.errorID+" "+e.message);
 			}
 		}

		/**
		 * Dispatches an OvpEvent.DEBUG event containing the message provided.
		 */
		protected function debug(msg:String):void {
			dispatchEvent(new OvpEvent(OvpEvent.DEBUG,msg));
		}
	}
}
