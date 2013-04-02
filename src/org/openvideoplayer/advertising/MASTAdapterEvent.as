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
	import flash.events.Event;

	/**
	 * This class represents an event fired by a class implementing 
	 * the IMASTAdapter interface.
	 */
	public class MASTAdapterEvent extends Event
	{
		/**
		 * Defined as anytime the play command is issued, even after a pause
		 */
		public static const OnPlay:String = "OnPlay";

		/**
		* The stop command is given
		*/
		public static const OnStop:String = "OnStop";

		/**
		* Athe pause command is given
		*/
		public static const OnPause:String = "OnPause";

		/**
		* The player was muted, or volume brought to 0
		*/
		public static const OnMute:String = "OnMute";

		/**
		* Volume was changed
		*/
		public static const OnVolumeChange:String = "OnVolumeChange";

		/**
		* The player has stopped naturally, with no new content
		*/
		public static const OnEnd:String = "OnEnd";

		/**
		* The player was manually seeked
		*/
		public static const OnSeek:String = "OnSeek";

		/**
		* A new item is being started
		*/
		public static const OnItemStart:String = "OnItemStart";

		/**
		* The current item is coming to the end
		*/
		public static const OnItemEnd:String = "OnItemEnd";

		/**
		* Fullscreen has been toggled
		*/
		public static const OnFullScreenChange:String = "OnFullScreenChange";

		/**
		* Player size has changed
		*/
		public static const OnPlayerSizeChanged:String = "OnPlayerSizeChanged";

		/**
		* An error has occurred, typically of enough severity to warrant display to the user
		*/
		public static const OnError:String = "OnError";

		/**
		 * A cue point event occurred.
		 */
		public static const OnCuePoint:String = "OnCuePoint";
		
		/**
		* The mouse has moved 
		*/
		public static const OnMouseOver:String = "OnMouseOver";
		
	    private var _data:Object;
		
		public function MASTAdapterEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_data = data;
	    }
	    
	    /**
	    * May contain information depending on the event.
	    */
	    public function get data():Object {
	      return _data;
	    }

	}
}
