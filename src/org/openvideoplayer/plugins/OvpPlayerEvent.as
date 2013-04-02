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
package org.openvideoplayer.plugins
{
	import flash.events.Event;

	/**
	 * Events dispatched by a Class implementing the IOvpPlayer interface.
	 */
	public class OvpPlayerEvent extends Event
	{
		/**
		 * The player can dispatch CUEPOINT events if you set a cue point on the object implemeting the IOvpPlayer interface.
		 * The <code>data</code> object for the event will contain whatever you passed to the addCuePoint method on the IOvpPlayer interface.
		 */
		public static const CUEPOINT:String = "cuepoint";

		/** 
		 * The player can dispatch serious errors if it wishes to. The data object will be an error message in this case.
		 */
		public static const ERROR:String = "error";
		
		/**
		 * The volume changed in the player. The data object will be an Number with a value from 0 (muted) to 1 (full volume);
		 */
		public static const VOLUME_CHANGE:String = "volumechange"; 
		
		/** 
		 * The player can dispatch this event when it is playing multi-bitrate content (dynamic streaming) and 
		 * either a manual switch has been requested or a switching rule has requested a switch to a new index.
		 * The <code>data</code> object for the event will contain these items:
  		 * <ul>
  		 * <li>data.targetIndex;	// The index we are trying to switch to.</li>
  		 * <li>data.streamName;		// The stream name we are trying to switch to.</li>
  		 * <li>data.firstPlay;		// True if this is the initial play request for the dynamic streaming profile.</li>
  		 * <li>data.reason;			// A textual description of the reason for the switch request.</li>
  		 * </ul>
		 */
		public static const SWITCH_REQUESTED:String = "switchRequested";
		
		/** 
		 * The player can dispatch this event when it receives a "NetStream.Play.Transition" event meaning the 
		 * server has acknowledged the switch request and is in the process of switching streams. 
		 * The <code>data</code> object for the event will contain:
  		 * <ul>
  		 * <li>data.nsInfo;		// the info property from the NetStatusEvent object</li>
  		 * </ul>
		 */
		public static const SWITCH_ACKNOWLEDGED:String = "switchAcknowledged";
		
		/** 
		 * The player can dispatch this event when it receives a "NetStream.Play.TransitionComplete" event
		 * meaning the switch is complete and is visible to the user.
		 * The <code>data</code> object for the event will contain:
  		 * <ul>
  		 * <li>data.renderingIndex;		// the index of the switching profile that is currently rendering.</li>
  		 * <li>data.renderingBitrate;	// the bitrate of the currently rendering stream
  		 * </ul>
		 */
		public static const SWITCH_COMPLETE:String = "switchComplete";
		
		/**
		 * Plug-ins can dispatch this event to allow a player to easily show an end-user what is happening. The data object
		 * will be the debug message as a String.
		 */
		public static const DEBUG_MSG:String = "debugmsg";
		
		/**
		 * The player can dispatch this event to expose the OvpConnection object used to connect to
		 * a server. If you are only interested in status, such as "connecting", "playing", etc.,
		 * listen for the STATE_CHANGE event.
		 * <p>
		 * The <code>data</code> object for the event will contain:
		 * <ul>
		 * <li>data.ovpConnection; 	// The OvpConnection object used by the player.</li>
		 * <li>data.uri;			// The URI used to connect to the server.</li>
		 * <li>data.arguments;		// Optional arguments passed to the NetConnection.connect() method.</li>
		 * </ul></p>
		 */
		public static const CONNECTION_CREATED:String = "connectionCreated";
		
		/**
		 * The player can dispatch this event to expose the OvpNetStream object used to
		 * play the media. If you are only interested in status, such as "playing", "paused",
		 * "seeking", etc., listen for the STATE_CHANGE event.
		 * <p>
		 * The <code>data</code> object for the event will contain:
		 * <ul>
		 * <li>data.netStream		// The OvpNetStream class instance used by the player.</li>
		 * <li>data.arguments		// The arguments passed to the <code>NetStream.play</code> method.</li>
		 * <ul>
		 * <li>data.arguments.name	// See the <code>NetStream.play</code> method in ActionScript 3 ASDocs.</li>
		 * <li>data.arguments.start	// See the <code>NetStream.play</code> method in ActionScript 3 ASDocs.</li>
		 * <li>data.arguments.len	// See the <code>NetStream.play</code> method in ActionScript 3 ASDocs.</li>
		 * <li>data.arguments.reset	// See the <code>NetStream.play</code> method in ActionScript 3 ASDocs.</li>
		 * </ul>
		 * <li>data.dsi				// For multi-bitrate content, this is the current DynamicStreamItem object to be rendered.</li>
		 * </ul>
		 */
		public static const NETSTREAM_CREATED:String = "netStreamCreated";
			
		/**
		 * The player dispatches a STATE_CHANGE event when it's state has changed.  The data object will contain one
		 * of the following values below to indicate state.
		 */
		public static const STATE_CHANGE:String = "statechange";
		
		/** 
		 * When listening for an OvpPlayerEvent.STATE_CHANGE event, the data object will be this value when a new 
		 * item in a playlist is starting or single content is starting.
		 */
		public static const START_NEW_ITEM:String = "startnewitem";
		/** 
		 * When listening for an OvpPlayerEvent.STATE_CHANGE event, the data object will be this value when 
		 * the player is in a wait state, such as waiting for an RSS playlist to parse.
		 */
		public static const WAITING:String = "waiting";
		/** 
		 * When listening for an OvpPlayerEvent.STATE_CHANGE event, the data object will be this value when
		 * the player is trying to connect. 
		 */
		public static const CONNECTING:String = "connecting";
		/** 
		 * When listening for an OvpPlayerEvent.STATE_CHANGE event, the data object will be this value when
		 * the player is buffering video data. 
		 */
		public static const BUFFERING:String = "buffering";
		/** 
		 * When listening for an OvpPlayerEvent.STATE_CHANGE event, the data object will be this value when
		 * the player is playing a video. 
		 */
		public static const PLAYING:String = "playing";
		/** 
		 * When listening for an OvpPlayerEvent.STATE_CHANGE event, the data object will be this value when
		 * the player has paused the video. 
		 */
		public static const PAUSED:String = "paused";
		/** 
		 * When listening for an OvpPlayerEvent.STATE_CHANGE event, the data object will be this value when
		 * the player is seeking. 
		 */
		public static const SEEKING:String = "seeking";
		/** 
		 * When listening for an OvpPlayerEvent.STATE_CHANGE event, the data object will be this value when
		 * a video has completed. 
		 */
		public static const COMPLETE:String = "complete";

		private var _data:Object;
				
		public function OvpPlayerEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_data = data;
			super(type, bubbles, cancelable);
		}
		
		public function get data():Object {
			return _data;
		}
		
	}
}
