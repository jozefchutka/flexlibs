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
package org.openvideoplayer.advertising
{
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
		
	/**
	 * Defined as anytime the play command is issued, even after a pause
	 */
	[Event(name="OnPlay", type="org.openvideoplayer.advertising.MASTAdapterEvent")]
	 
	/**
	* The stop command is given
	*/
	[Event(name="OnStop", type="org.openvideoplayer.advertising.MASTAdapterEvent")]
	
	/**
	* Athe pause command is given
	*/
	[Event(name="OnPause", type="org.openvideoplayer.advertising.MASTAdapterEvent")]
	
	/**
	* The player was muted, or volume brought to 0
	*/
	[Event(name="OnMute", type="org.openvideoplayer.advertising.MASTAdapterEvent")]
	
	/**
	* Volume was changed
	*/
	[Event(name="OnVolumeChange", type="org.openvideoplayer.advertising.MASTAdapterEvent")]
	
	/**
	* The player has stopped naturally, with no new content
	*/
	[Event(name="OnEnd", type="org.openvideoplayer.advertising.MASTAdapterEvent")]
	
	/**
	* The player was manually seeked
	*/
	[Event(name="OnSeek", type="org.openvideoplayer.advertising.MASTAdapterEvent")]
	
	/**
	* A new item is being started
	*/
	[Event(name="OnItemStart", type="org.openvideoplayer.advertising.MASTAdapterEvent")]
	
	/**
	* The current item is coming to the end
	*/
	[Event(name="OnItemEnd", type="org.openvideoplayer.advertising.MASTAdapterEvent")]
	
	/**
	* Fullscreen has been toggled
	*/
	[Event(name="OnFullScreenChange", type="org.openvideoplayer.advertising.MASTAdapterEvent")]

	/**
	* Player size has changed
	*/
	[Event(name="OnPlayerSizeChanged", type="org.openvideoplayer.advertising.MASTAdapterEvent")]
	
	/**
	* An error has occurred, typically of enough severity to warrant display to the user
	*/
	[Event(name="OnError", type="org.openvideoplayer.advertising.MASTAdapterEvent")]
	
	/**
	 * A cue point event occurred.
	 */
	[Event(name="OnCuePoint", type="org.openvideoplayer.advertising.MASTAdapterEvent")]
	
	/**
	* The mouse has moved 
	*/
	[Event(name="OnMouseOver", type="org.openvideoplayer.advertising.MASTAdapterEvent")]

	
	/**
	 * The purpose of the IMASTAdapter interface is to provide
	 * an adapter between the player and the MAST engine.
	 */ 
	public interface IMASTAdapter extends IEventDispatcher
	{
		// Properties
		
		/**
		* The duration of the current content
		*/
		function get duration():Number;

		/**
		* The position of the current content
		*/
		function get position():Number;

		/**
		* The amount of time that this item has rendered, regardless of seeks
		*/
		function get watchedTime():Number;

		/**
		* The total amount of content that has been rendered in this session
		*/
		function get totalWatchedTime():Number;

		/**
		* The current system time
		*/
		function get systemTime():Date;

		/**
		* True if the player is fullscreen
		*/
		function get fullScreen():Boolean;

		/**
		* True if the player is playing content
		*/
		function get isPlaying():Boolean;

		/**
		* True if the player is paused
		*/
		function get isPaused():Boolean;

		/**
		* True if the player is stopped, or not yet started
		*/
		function get isStopped():Boolean;

		/**
		* True if captions are active and being shown
		*/
		function get captionsActive():Boolean;

		/**
		* True if the current content has a video stream
		*/
		function get hasVideo():Boolean;

		/**
		* True if the current content has an audio stream
		*/
		function get hasAudio():Boolean;

		/**
		* True if the current content has captions available
		*/
		function get hasCaptions():Boolean;

		/**
		* The count of items that have been displayed in full or part.
		*/
		function get itemsPlayed():int;

		/**
		* The physical width of the player applciation
		*/
		function get playerWidth():int;

		/**
		* The physical height of the player applciation
		*/
		function get playerHeight():int;

		/**
		* The native width of the current content
		*/
		function get contentWidth():int;

		/**
		* The native height of the current content
		*/
		function get contentHeight():int;

		/**
		* The bitrate-in-use of the current content
		*/
		function get contentBitrate():int;

		/**
		* The title of the current content
		*/
		function get contentTitle():String;

		/**
		* The URL that the current content was received from 
		*/
		function get contentUrl():String;

		/**
		 * The frequency in milliseconds, a MAST engine will poll
		 * top-level property triggers.
		 */
		function get pollingFrequency():int;

		// Methods

		/**
		 * Add a dynamic cue point.
		 */		
		function addCuePoint(cp:Object):void;
		 
		/**
		* Called by Mainsail when a trigger is being activated
		*/
		function activateTrigger(trigger:IMASTTrigger):void;

		/**
		* Called by Mainsail or by the payload handler when a trigger/payload is complete or being deactivated
		*/
		function deactivateTrigger(trigger:IMASTTrigger):void;
		
		/**
		 * Called by a plug-in that wishes to add an ad display object to the player.
		 */
		 function getTargetRegionMovieClip(region:String):Sprite;
	}
}
