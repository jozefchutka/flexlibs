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
	 * VPAID Event class for dispatching and listening for events on an object that implements the IVPAID interface.
	 * 
	 * Sample ad dispatch call from a function within ad’s VPAID class:
	 * <p>
	 * <code>
	 * dispatchEvent(new VPAIDEvent(VPAIDEvent.AdStarted));<br />
	 * dispatchEvent(new VPAIDEvent(VPAIDEvent.AdClickThru, {url:myurl,id:myid,playerHandles:true})); <br />
	 * </code>
	 * </p>
	 * @see IVPAID
	 */
	public class VPAIDEvent extends Event
	{
	    public static const AdLoaded : String         = "AdLoaded";
	    public static const AdStarted : String        = "AdStarted";
	    public static const AdStopped : String        = "AdStopped";
	    public static const AdLinearChange : String   = "AdLinearChange";
	    public static const AdExpandedChange : String = "AdExpandedChange";
	    public static const AdRemainingTimeChange : String= "AdRemainingTimeChange";
	    public static const AdVolumeChange : String   = "AdVolumeChange";
	    public static const AdImpression : String     = "AdImpression";
	    public static const AdVideoStart : String     = "AdVideoStart";
	    public static const AdVideoFirstQuartile : String= "AdVideoFirstQuartile";
	    public static const AdVideoMidpoint : String  = "AdVideoMidpoint";
	    public static const AdVideoThirdQuartile : String= "AdVideoThirdQuartile";
	    public static const AdVideoComplete : String  = "AdVideoComplete";
	    public static const AdClickThru : String      = "AdClickThru";
	    public static const AdUserAcceptInvitation : String= "AdUserAcceptInvitation";
	    public static const AdUserMinimize : String   = "AdUserMinimize";
	    public static const AdUserClose : String      = "AdUserClose";
	    public static const AdPaused : String         = "AdPaused";
	    public static const AdPlaying : String        = "AdPlaying";
	    public static const AdLog : String            = "AdLog";
	    public static const AdError : String          = "AdError";
	
	    private var _data:Object;

	    public function VPAIDEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
	      super(type, bubbles, cancelable);
	      _data = data;
	    }
	    
	    public function get data():Object {
	      return _data;
	    }
	}
}

