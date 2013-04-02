
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
	 * DynamicStreamBitrate Class
     * Defines an individual bitrate in a DynamicStreamItem
	 */
	public class DynamicStreamBitrate {
		
		/**
         * Constructor for DynamicStreamBitrate
         * requires the stream name and the bitrate.
		 * 
		 * @param streamName
		 * @param bitrate, in kbps
         */
        public function DynamicStreamBitrate(streamName:String, bitRate:Number) {
            _stream = streamName;
            _bitrate = bitRate;
        }
        
        /**
         * Stores the bitrate value, set only in the constructor
         */
        private var _bitrate:Number;
        
        /**
         * Stores the stream name, set only in the constructor
         */
        private var _stream:String;
        
		/**
		 * Stores the number of times this bitrate has failed to render properly
		 * in the client.
		 */
		private var _failedCount:Number = 0;
		
		/**
		 *Stores the number of allowed fails before lockout triggers
		 */
		private var _allowedFails:Number = 3; //default to 3
		
		/**
		 * Enables a bitrate for switching, see the get enabled property below
		 * for details.
		 */
		private var _enabled:Boolean = true;
        
        /**
         * Stores the number of seconds required to pass before the bitrate can
         * be considered to be stable.  Used by rules to determine panic mode.
         */
        private var _timeToSteadyState:Number = 4000;   //defaults to 4 seconds
        
        /**
         * Stores the relative time that play started for this bitrate.  Used to
         * determine if the bitrate has been playing long enough to be stable.
         */
        private var _startedPlay:Number;
        
        /**
         * gets the relative time that play started for this bitrate.
         */
        public function get startedPlay():Number {
            return _startedPlay;
        }
        /**
         * sets the relative time that play started for this bitrate.
         */
        public function set startedPlay(time:Number):void {
            _startedPlay = time;
        }
        
        /**
         * gets the number of seconds until the bitrate is considered stable
         */
        public function get timeToSteadyState():Number {
            return _timeToSteadyState/1000;
        }
        /**
         * sets the number of seconds until the bitrate is considered stable
         */
        public function set timeToSteadyState(seconds:Number):void {
            _timeToSteadyState = seconds*1000;  //convert seconds to time internally
        }
        
		/**
		 * gets the number of times the bitrate has failed to play
		 */
		public function get failedCount():Number {
			return _failedCount;
		}
		
		/**
		 * sets the number of times the bitrate has failed to play
		 */
		public function set failedCount(count:Number):void {
			_failedCount = count;
		}
				
		/**
		 * gets the number of allowed failures before lockout initiates
		 */
		public function get allowedFails():Number {
			return _allowedFails;
		}
		/**
		 * sets the number of allowed failures before lockout initiates
		 */
		public function set allowedFails(count:Number):void {
			_allowedFails = count;
		}
       
        /**
         * gets the bitrate set from the constructor
         */
        public function get rate():Number {
            return _bitrate;
        }
        
        /**
         * gets the stream name set from the constructor
         */
        public function get name():String {
            return _stream;
        }

        /**
         * Sets the timer that this bitrate has started playing
         */
        public function start():void {
            _startedPlay = getTimer();
        }
        
        /**
         * Returns whether this stream is in steady state or not.
         */
        public function get isSteadyState():Boolean {
            return (_startedPlay > (getTimer()-_timeToSteadyState));
        }
        
       /**
         * Returns whether this stream has exceeded its allowed number of fails.
         */
        public function get isAvailable():Boolean {
            return _failedCount <= _allowedFails;
        }
        
		/**
		 * Simply increments the times the stream has failed to play.
		 */
		public function incrementFailCount():void {
			_failedCount++;
		}
		
		/**
		* Stores the enabled state of this bitrate. Enabled == true implies that the
		* bitrate can be considered a valid destination for ISwitchingRules. Setting it to false
		* will essentially filter it out of any later switching decisions. This property therefore
		* allows for the dynamic filtering of bitrates within a dynamic streaming item.
		*<p/>
		* A note about the seemingly similar isAvailable() property. That property is only concerned
		* with whether the lock limit has been reached for this bitrate. The name is being maintained for
		* backwards compatibility. A bitrate can therefore have isAvilable = true and enabled  = false. This
		* means is has not been locked out, but a switching rules has decided that it should not be considered
		* as a viable target for a switch.
		*/
		public function get enabled():Boolean
		{
			return _enabled
		}
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
		}
    }
}
