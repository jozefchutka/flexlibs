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
package org.openvideoplayer.plugins {
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;

	/**
	 * Dispatched when an ActionScript cue point requested by the plug-in has been reached. Plug-ins can set ActionScript
	 * cue points via the addCuePoint method.
	 **/
	[Event(name="cuepoint", type="org.openvideoplayer.plugins.OvpPlayerEvent")]

	/**
	 * The player can dispatch serious errors if it wishes to. The data object will be an error message in this case.
	 **/
	[Event(name="error", type="org.openvideoplayer.plugins.OvpPlayerEvent")]

	/**
	 * The volume changed in the player. The data object will be an Number with a value from 0 (muted) to 1 (full volume);
	 */
	[Event(name="volumechange", type="org.openvideoplayer.plugins.OvpPlayerEvent")]

	/**
	 * The player can dispatch this event when it is playing multi-bitrate content (dynamic streaming). This event
	 * indicates a switch has been requested. The <code>data</code> object within the event object contains
	 * details of the switch request. See the <code>OvpPlayerEvent</code> class for properties on the 
	 * <code>data</code> object for this event.
	 */
	[Event(name="switchRequested", type="org.openvideoplayer.plugins.OvpPlayerEvent")]
	
	/**
	 * The player can dispatch this event when the server acknowledges the switch request. See the <code>OvpPlayerEvent</code>
	 * class for details on this event.
	 */
	[Event(name="switchAcknowledged", type="org.openvideoplayer.plugins.OvpPlayerEvent")]
	
	/**
	 * The player can dispatch this event when the switch has completed and is visible to the user.
	 * See the <code>OvpPlayerEvent</code> class for details on this event.
	 */
	[Event(name="switchComplete", type="org.openvideoplayer.plugins.OvpPlayerEvent")]
	
	/**
	 * Plug-ins can dispatch this event to allow a player to easily show an end-user what is happening. The data object
	 * will be the debug message as a String.
	 */
	[Event(name="debugmsg", type="org.openvideoplayer.plugins.OvpPlayerEvent")]

	/**
	 * The player dispatches this event when it's state has changed.  The data object will contain one
	 * of the STATE_CHANGE event data values found in the <code>OvpPlayerEvent</code> class.  See the
	 * <code>OvpPlayerEvent</code> class for the possible states for this event.
	 */
	[Event(name="statechange", type="org.openvideoplayer.plugins.OvpPlayerEvent")]

	/**
	 * The OVP player interface. This interface allows plug-ins to
	 * get properties from the player and listen for events.
	 */
	public interface IOvpPlayer extends IEventDispatcher {
		// Properties
		/**
		 * Returns an Array of Sprite objects.  Each object is the main display object
		 * for the plug-in.
		 */
		function get plugins():Array;

		/**
		 * Returns the flashvars passed into the player as an Object.
		 */
		function get flashvars():Object;

		/**
		 * Returns the bitrate of the currently loaded video, in kilobits per second, for example 500 means 500kbps.
		 * The player should return 0 if no video is loaded.
		 */
		function get currentBitrate():int;

		/**
		 * The duration of the currently rendering content.
		 */
		function get duration():Number;

		/**
		 * The current position of the rendering content.
		 */
		function get position():int;

		/**
		 * True if the player is in full screen mode.
		 */
		function get fullScreen():Boolean;

		/**
		 * True if the player is in caption mode (displaying closed captions).
		 */
		function get captionsActive():Boolean;

		/**
		 * True if the rendering content contains video.
		 */
		function get hasVideo():Boolean;

		/**
		 * True if the rendering content contains audio.
		 */
		function get hasAudio():Boolean;

		/**
		 * True if the rending content has caption, this does not
		 * necessary mean they are active.
		 * 
		 * @see #captionsActive
		 */
		function get hasCaptions():Boolean;

		/**
		 * Number of items in the current play list.
		 */
		function get itemCount():int;

		/**
		 * Number of items that have played.
		 */
		function get itemsPlayed():int;

		/**
		 * The current player width.
		 */
		function get playerWidth():int;
		
		/**
		 * The current player height.
		 */
		function get playerHeight():int;

		/**
		 * The rendering content's current width.
		 */
		function get contentWidth():int;
		
		/**
		 * The rendering content's current height.
		 */
		function get contentHeight():int;

		/**
		 * The rendering content's current title.
		 */
		function get contentTitle():String;

		/**
		 * The rendering content's URL.
		 */
		function get contentURL():String;

		/**
		 * Puts the player in advertising mode, meaning:<ol>
		 *  <li> the video is paused.</li>
		 *  <li> all transport controls are disabled</li>
		 * </ol>
		 */
		function set advertisingMode(value:Boolean):void;

		// Methods
		
		/**
		 * Starts the current content playing.
		 */
		function startPlayer():void;
		
		/**
		 * Pauses the current content.
		 */
		function pausePlayer():void;
		
		/**
		 * Resumes (after pause) the current content.
		 */
		function resumePlayer():void;
		
		/**
		 * Stops the current content.
		 */
		function stopPlayer():void;
		
		/**
		 * Adds an ActionScript cue point. 
		 */
		function addCuePoint(cuePoint:Object):void;
		
		/**
		 * Asks the player to return a specific sprite with the ID specified. This allows a plug-in to add
		 * itself as a child to a sprite in the player.
		 */
		function getSpriteById(id:String):Sprite;
	}
}
