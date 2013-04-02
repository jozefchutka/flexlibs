
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
	
	import flash.utils.getTimer;
	
	/**
	 * This class provides a container to hold the constituents of a dynamic streaming package.
	 * It is based on the original class by Adobe Systems, but we have extended it to represent each item as an instance 
	 * of the new DynamicStreamBitrate class, so that each bitrate can store some infomration about itself and its state.
	 */
	
	public class DynamicStreamItem extends Object
	{
		private var _lockLevel:Number;
		private var _lastLockTime:Number;
	
		private const LOCK_INTERVAL:Number = 30000;
		
		
		/* Constructor
		 * 
		 * Usage:
		 * var ds:DynamicStream = new DynamicStream(nc);
		 * 
		 * var dsi:DynamicStreamItem = new DynamicStreamItem();
		 * 
		 * dsi.addStream("mp4:Sample Movie_800.f4v", 800);
		 * dsi.addStream("mp4:Sample Movie_1500.f4v", 1500);
		 * dsi.addStream("mp4:Sample Movie_2200.f4v", 2200);
		 * dsi.addStream("mp4:Sample Movie_5600.f4v", 5600);
		 * 
		 * ds.startPlay(dso);
		 * 
		 */
		public function DynamicStreamItem() {
			
			streamArray = new Array();	
			streamCount = NaN;
			start = -2;
			len = -1;
			reset = true;
			streamAuth = "";
			startingIndex = -1;
			_lastLockTime = 0;
			_lockLevel = int.MAX_VALUE;

		}
		
		/**
		 * streamArray
		 * Array of streams and bitrates
		 * 
		 */
		private var streamArray:Array;
		
		/**
		 * Start time for the stream
		 * Default is -2 to coincide with defaults for NetStream.play()
		 */		
		public var start:Number;
		
		/**
		 * Specifies stream auth params to use with this DSI. 
		 * Default is ""
		 */		
		public var streamAuth:String;
		
		/**
		 * len:Number
		 * Default is -1 to coincide with defaults for NetStream.play()
		 */		
		public var len:Number;
		
		/**
		 * reset:Boolean
		 * Default is true to coincide with defaults for NetStream.play()
		 */		
		public var reset:Boolean;
		
		/**
		 * Stores the preferred starting index
		 */	
		public var startingIndex:Number;
		
		/**
		 * Stores the number of items held by this class
		 */	
		public var streamCount:Number;
		
		/**
		 * Adds a stream and bitrate pair to the DynamicStreamItem object 
		 * @param streamName
		 * @param bitRate in kbps
		 * 
		 */		
		public function addStream(streamName:String, bitRate:Number):void {
            streamArray.push(new DynamicStreamBitrate(streamName,bitRate));
			streamArray.sortOn("rate", Array.NUMERIC)
			streamCount = streamArray.length;
		}
		
		/**
		 * Returns the array of DynamicStreamBitrate objects
		 * 
		 */		
		public function get streams():Array {
			return streamArray;
		}
		
		/**
		 * Returns the index associated with a bitrate name. The match will be tried both with and without a mp4: prefix.
		 * 
		 */		
		public function indexFromName(name:String):int {
			for (var i:int = 0; i < streamCount; i++) {
				if (name == streamArray[i].name || "mp4:" + name == streamArray[i].name) {
					return i
				}
			}
			return undefined;
		}
		
		/**
		 * Returns the bitrate of the stream at the given index
		 * 
		 */		
		public function getRateAt(index:int):Number {
			
			return index >= 0 && index < streamArray.length ? streamArray[index].rate as Number:undefined;
		}
		
		/**
		 * Returns the name of the stream at the given index
		 * 
		 */		
		public function getNameAt(index:uint):String{
			return streamArray[index].name as String;
		}
		
		/**
		 * Returns the DynamicStreamBitrate object at the requested index
		 * 
		 */		
		public function getBitrateAt(index:uint):DynamicStreamBitrate{
			return streamArray[index] as DynamicStreamBitrate;
		}
		
		/**
		 * Increments the failed counter at the requested index
		 * 
		 */		
		public function incrementFailCountAt(index:uint):void {
			getBitrateAt(index).incrementFailCount();
		}
		
		/**
		 * Sets the lock level at the provided index. Any item at this index or higher will be unavailable until the LOCK_INTERVAL
		 * has passed.
		 * 
		 */	
		public function lock(index:int):void {
			_lockLevel= index;
			_lastLockTime = getTimer();
		}
		
		/**
		 * Returns true if this index level is currently locked.
		 * 
		 */	
		public function isLockedAt(index:int):Boolean {
			return (index >= _lockLevel) && (getTimer() - _lastLockTime) < LOCK_INTERVAL;
		}
		
		/**
		 * Returns true if a index is available
		 * 
		 */	
		public function isAvailable(index:int):Boolean {
			return !isLockedAt(index) && streamArray[index].isAvailable;
		}
		
	}
}
