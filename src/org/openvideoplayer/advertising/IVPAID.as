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
package org.openvideoplayer.advertising {

	import flash.events.IEventDispatcher;
	
	/**
	 * The AdLoaded event is sent by the ad to notify the player that the ad has finished any
	 * loading of assets and is ready for display. The ad does not attempt to load assets until
	 * the player calls the init method.
	 */ 
	[Event(name="AdLoaded", type="org.openvideoplayer.advertising.VPAIDEvent")]
	
	/**
	 * The AdStarted event is sent by the ad to notify the player that the ad is displaying. 
	 */
	[Event(name="AdStarted", type="org.openvideoplayer.advertising.VPAIDEvent")]
	
	/**
	 * The AdStopped event is sent by the ad to notify the player that the ad has stopped
	 * displaying, and all ad resources have been cleaned up.
	 */  	
	[Event(name="AdStopped", type="org.openvideoplayer.advertising.VPAIDEvent")]
	
	/**
	 * The AdLinearChange event is sent by the ad to notify the player that the ad has
	 * changed playback mode. The player must get the adLinear property and update its UI
	 * accordingly. 
	 */
	[Event(name="AdLinearChange", type="org.openvideoplayer.advertising.VPAIDEvent")]
	
	/**
	 * The AdExpandedChange event is sent by the ad to notify the player that the ad’s
	 * expanded state has changed. The player may get the adExpanded property and
	 * update its UI accordingly.
	 */
	[Event(name="AdExpandedChange", type="org.openvideoplayer.advertising.VPAIDEvent")]
	
	/**
	 * The AdRemainingTimeChange event is sent by the ad to notify the player that the ad’s
	 * remaining playback time has changed. The player may get the adRemainingTime
	 * property and update its UI accordingly.
	 */
	[Event(name="AdRemainingTimeChange", type="org.openvideoplayer.advertising.VPAIDEvent")]
	
	/**
	 * The AdVolumeChange event is sent by the ad to notify the player that the ad has
	 * changed its volume, if the ad supports volume. The player may get the adVolume
	 * property and update its UI accordingly.
	 */ 
	[Event(name="AdVolumeChange", type="org.openvideoplayer.advertising.VPAIDEvent")]
	
	/**
	 * The AdImpression event is used to notify the player that the user-visible phase of the ad
	 * has begun.
	 */ 
	[Event(name="AdImpression", type="org.openvideoplayer.advertising.VPAIDEvent")]
	
	/**
	 * AdVideoStart, AdVideoFirstQuartile, AdVideoMidpoint, AdVideoThirdQuartile, AdVideoComplete
	 * These five events are sent by the ad to notify the player of ad’s video progress. They
	 * match the VAST events of the same names, as well as the “Percent complete”
	 * events in Digital Video In-Stream Ad Metrics Definitions, and must be implemented
	 * to be IAB compliant. These strictly apply to the video portion of the ad experience, if
	 * any.
	 */ 
	[Event(name="AdVideoStart", type="org.openvideoplayer.advertising.VPAIDEvent")]
	
	/**
	 * AdVideoStart, AdVideoFirstQuartile, AdVideoMidpoint, AdVideoThirdQuartile, AdVideoComplete
	 * These five events are sent by the ad to notify the player of ad’s video progress. They
	 * match the VAST events of the same names, as well as the “Percent complete”
	 * events in Digital Video In-Stream Ad Metrics Definitions, and must be implemented
	 * to be IAB compliant. These strictly apply to the video portion of the ad experience, if
	 * any.
	 */ 
	[Event(name="AdVideoFirstQuartile", type="org.openvideoplayer.advertising.VPAIDEvent")]
	/**
	 * AdVideoStart, AdVideoFirstQuartile, AdVideoMidpoint, AdVideoThirdQuartile, AdVideoComplete
	 * These five events are sent by the ad to notify the player of ad’s video progress. They
	 * match the VAST events of the same names, as well as the “Percent complete”
	 * events in Digital Video In-Stream Ad Metrics Definitions, and must be implemented
	 * to be IAB compliant. These strictly apply to the video portion of the ad experience, if
	 * any.
	 */ 
	[Event(name="AdVideoMidpoint", type="org.openvideoplayer.advertising.VPAIDEvent")]
	/**
	 * AdVideoStart, AdVideoFirstQuartile, AdVideoMidpoint, AdVideoThirdQuartile, AdVideoComplete
	 * These five events are sent by the ad to notify the player of ad’s video progress. They
	 * match the VAST events of the same names, as well as the “Percent complete”
	 * events in Digital Video In-Stream Ad Metrics Definitions, and must be implemented
	 * to be IAB compliant. These strictly apply to the video portion of the ad experience, if
	 * any.
	 */ 
	[Event(name="AdVideoThirdQuartile", type="org.openvideoplayer.advertising.VPAIDEvent")]
	/**
	 * AdVideoStart, AdVideoFirstQuartile, AdVideoMidpoint, AdVideoThirdQuartile, AdVideoComplete
	 * These five events are sent by the ad to notify the player of ad’s video progress. They
	 * match the VAST events of the same names, as well as the “Percent complete”
	 * events in Digital Video In-Stream Ad Metrics Definitions, and must be implemented
	 * to be IAB compliant. These strictly apply to the video portion of the ad experience, if
	 * any.
	 */ 
	[Event(name="AdVideoComplete", type="org.openvideoplayer.advertising.VPAIDEvent")]
	
	/**
	 * The AdClickThru event is sent by the ad when a click thru occurs.
	 */
	[Event(name="AdClickThru", type="org.openvideoplayer.advertising.VPAIDEvent")]
	
	/**
	 * The AdUserAcceptInvitation, AdUserMinimize and AdUserClose events are sent by the
	 * ad when it meets the requirement of the same names as set in Digital Video In-Stream
	 * Ad Metrics Definitions. Each of these is a reporting by the ad to the player of a
	 * user-initiated action.
	 */ 
	[Event(name="AdUserAcceptInvitation", type="org.openvideoplayer.advertising.VPAIDEvent")]
	/**
	 * The AdUserAcceptInvitation, AdUserMinimize and AdUserClose events are sent by the
	 * ad when it meets the requirement of the same names as set in Digital Video In-Stream
	 * Ad Metrics Definitions. Each of these is a reporting by the ad to the player of a
	 * user-initiated action.
	 */ 
	[Event(name="AdUserMinimize", type="org.openvideoplayer.advertising.VPAIDEvent")]
	/**
	 * The AdUserAcceptInvitation, AdUserMinimize and AdUserClose events are sent by the
	 * ad when it meets the requirement of the same names as set in Digital Video In-Stream
	 * Ad Metrics Definitions. Each of these is a reporting by the ad to the player of a
	 * user-initiated action.
	 */ 
	[Event(name="AdUserClose", type="org.openvideoplayer.advertising.VPAIDEvent")]
	
	/**
	 * The AdPaused and AdPlaying events are sent in response to method calls to pauseAd
	 * and resumeAd, respectively, to indicate the action has taken effect.
	 */
	[Event(name="AdPaused", type="org.openvideoplayer.advertising.VPAIDEvent")]
	/**
	 * The AdPaused and AdPlaying events are sent in response to method calls to pauseAd
	 * and resumeAd, respectively, to indicate the action has taken effect.
	 */
	[Event(name="AdPlaying", type="org.openvideoplayer.advertising.VPAIDEvent")]
	
	/**
	 * The AdLog event is optionally sent by the ad to the player to relay debugging
	 * information, in a parameter String message.
	 */
	[Event(name="AdLog", type="org.openvideoplayer.advertising.VPAIDEvent")]
	
	/**
	 * The AdError event is sent when the ad has experienced a fatal error. Before the ad
	 * sends AdError it must clean up all resources and cancel any pending ad playback.
	 */ 
	[Event(name="AdError", type="org.openvideoplayer.advertising.VPAIDEvent")]
	
	/**
	 * The IAB standard IVPAID interface for OVP players.
	 *
	 * @see http://www.iab.net/vpaid
	 */
	public interface IVPAID extends IEventDispatcher
	{
	    // Properties
	    
	    /**
	    * Indicates the ad’s current linear vs. non-linear mode of
	    * operation. adLinear when true indicates the ad is in a linear playback mode, false
	    * nonlinear.
	    */ 
	    function get adLinear() : Boolean;
	    
		/** 
		 * Indicates whether the ad is in a state where it
		 * occupies more UI area than its smallest area. If the ad has multiple expanded states,
		 * all expanded states show adExpanded being true.
		 */ 	    
	    function get adExpanded() : Boolean;
	    
	    /**
	    * The player may use the adRemainingTime property to update player UI during ad
	    * playback. The adRemainingTime property is in seconds and is relative to the time the
	    * property is accessed.
	    */ 
	    function get adRemainingTime() : Number;
	    
	    /**
	    * The player uses the adVolume property to attempt to set or get the ad volume. The
	    * adVolume value is between 0 and 1 and is linear.
	    */
	    function get adVolume() : Number;
	    function set adVolume(value : Number) : void; 

	    // Methods
	    
	    /**
	    * The player calls handshakeVersion immediately after loading the ad to indicate to the
	    * ad that VPAID will be used. The player passes in its latest VPAID version string. The ad
	    * returns a version string minimally set to “1.0”, and of the form “major.minor.patch”.
	    * The player must verify that it supports the particular version of VPAID or cancel the ad.
	    */
	    function handshakeVersion(playerVPAIDVersion : String) : String;
	    
	    /**
	    * After the ad is loaded and the player calls handshakeVersion, the player calls initAd to
	    * initialize the ad experience. The player may pre-load the ad and delay calling initAd
	    * until nearing the ad playback time, however, the ad does not load its assets until initAd
	    * is called.
	    */ 
	    function initAd(width : Number, height : Number, viewMode : String, desiredBitrate : Number, creativeData : String, environmentVars : String) : void;
	    
	    /**
	    * Following a resize of the ad UI container, the player calls resizeAd to allow the ad to
	    * scale or reposition itself within its display area. The width and height always matches
	    * the maximum display area allotted for the ad, and resizeAd is only called when the
	    * player changes its video content container sizing.
	    */
	    function resizeAd(width : Number, height : Number, viewMode : String) : void;
	    
	    /**
	    * startAd is called by the player and is called when the player wants the ad to start
	    * displaying.
	    */ 
	    function startAd() : void;
	    
	    /**
	    * stopAd is called by the player when it will no longer display the ad. stopAd is also
	    * called if the player needs to cancel an ad.
	    */
	    function stopAd() : void;
	    
	    /**
	    * pauseAd is called to pause ad playback. 
	    */
	    function pauseAd() : void;
	    
	    /**
	    * resumeAd is called to continue ad playback following a call to pauseAd.
	    */
	    function resumeAd() : void;
	    
	    /**
	    * expandAd is called by the player to request that the ad switch to its larger UI size.
	    */
	    function expandAd() : void;
	    
	    /**
	    * collapseAd is called by the player to request that the ad return to its smallest UI size. 
	    */
	    function collapseAd() : void;
	}
}
