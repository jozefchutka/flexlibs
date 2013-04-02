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

package org.openvideoplayer.events
{
	import flash.events.Event;

	/**
	 * The OvpEvent class is dispatched for all events in the Open Video Player code base.
	 * 
	 * The data property contains varying information depending on the specific event. For example, the <code>OvpEvent.BANDWIDTH</code> event
	 * provides bandwith and latency values via the data property:
	 * <listing>
	 * private function bandwidthHandler(e:OvpEvent):void {
	 * &#xA0;&#xA0;&#xA0;&#xA0;////trace("Bandwidth measured at " + e.data.bandwidth+ " kbps and latency is " + e.data.latency + " ms.");
	 * }
	 * </listing>
	 * See the public constants below for a description of the data object for each event type.
	 */

	public class OvpEvent extends Event
	{
		/** 
		 * The OvpEvent.ERROR constant defines the value of an error event's
		 * <code>type</code> property, which indicates that the class
		 * has encountered a run-time error. 
		 * 
		 * The data object will contain <code>errorNumber</code> and <code>errorDescription</code> properties.
		 * 
		 * @see OvpError
		 */
  		public static const ERROR:String = "error";
  		
  		/**
  		 * The OvpEvent.TIMEOUT constant defines the value of an error event's
  		 * <code>type</code> property, which indicates a timeout has occurred.
  		 */
		public static const TIMEOUT:String = "timeout";

		/** 
		 * The OvpEvent.BANDWIDTH constant defines the value of the OvpEvent's
		 * <code>type</code> property, which indicates the class
		 * has completed a bandwidth estimate. The <code>bandwidth</code> and <code>latency</code>
		 * values can be accessed via the data property, for example <code>event.data.bandwidth</code>
		 * and <code>event.data.latency</code>
		 * 
		 * @see org.openvideoplayer.net.OvpConnection#detectBandwidth()
		 */
  		public static const BANDWIDTH:String = "bandwidth";
  			 			  			
  		/** 
		 * The OvpEvent.COMPLETE constant defines the value of the OvpEvent's
		 * <code>type</code> property, which indicates that the end of the stream has been reached. 
		 * <br />
		 * This event can only be used for streaming and (not progressive downloads) and is dispatched
		 * whenever the <code>onPlayStatus</code> callback function of the NetStream object 
		 * issues a <code>NetStream.Play.Complete</code> code.
		 * 
		 */
  		public static const COMPLETE:String = "complete";
  			
  		/** 
		 * The OvpEvent.STREAM_LENGTH constant defines the value of the OvpEvent's
		 * <code>type</code> property, which indicates the class
		 * has completed a stream length request. The <code>streamLength</code> value
		 * can be accessed via the data property, for example <code>event.data.streamLength</code>.
		 * 
		 * @see org.openvideoplayer.net.OvpConnection#streamLengthAsTimeCode()
		 * 
		 */
  		public static const STREAM_LENGTH:String = "streamlength";
  			  			
  		/** 
		 * The OvpEvent.PROGRESS constant defines the value of the OvpEvent's
		 * <code>type</code> property, which indicates the class is actively playing a stream. This event is fired
		 * every <code>progressInterval</code> millseconds from when <code>play</code> is first called, to when
		 * <code>close()</code> is called. This event is designed to be an update interval to drive time and position displays
		 * which vary with the progress of the stream. 

		 * 
		 * @see org.openvideoplayer.net.OvpNetStream#progressInterval
		 * @see org.openvideoplayer.net.OvpNetStream#close()
		 */
  		public static const PROGRESS:String = "progress";
			
		/** 
		 * The OvpEvent.LOADED constant defines the value of the OvpEvent's
		 * <code>type</code> property, which indicates the class has successfully loaded external data, such
		 * as a MediaRSS feed. This event is fired before that data is parsed.
		 * 
		 */
  		public static const LOADED:String = "loaded";
  		
		/** 
		 * The OvpEvent.PARSED constant defines the value of the OvpEvent's
		 * <code>type</code> property, which indicates the class has successfully
		 * parsed some data, such as a Media RSS feed. 
		 * 
		 */
  		public static const PARSED:String = "parsed";
  		
  		/** 
		 * The OvpEvent.MP3_ID3 constant defines the value of an OvpEvent's
		 * <code>type</code> property, dispatched when the the class receives information about
		 * ID3 data embedded in an MP3 file. To trigger this event, first make a request to the
		 * <code>getMp3Id3Info</code> method.
		 * 
		 * @see org.openvideoplayer.net.OvpNetStream#getMp3Id3Info()
		 */
		public static const MP3_ID3:String = "id3";
		 		
  		/** 
		 * The OvpEvent.NETSTREAM_METADATA constant defines the value of an OvpEvent's
		 * <code>type</code> property, dispatched when the OvpNetStream class receives descriptive
		 * information embedded in the FLV file being played. This event is triggered after a call to
		 * the <code>NetStream.play()</code> method, but before the video playhead has advanced.
		 * In many cases, the duration value embedded in FLV metadata approximates the actual duration,
		 * but is not exact. In other words, it does not always match the value of the NetStream.time property
		 * when the playhead is at the end of the video stream. 
		 */		 		
		public static const NETSTREAM_METADATA:String = "metadata";

  		/** 
		 * The OvpEvent.NETSTREAM_CUEPOINT constant defines the value of an OvpEvent's
		 * <code>type</code> property, dispatched when an embedded cue point is reached while playing an FLV file.
		 * You can use this handler to trigger actions in your code when the video reaches a specific cue point,
		 * which lets you synchronize other actions in your application with video playback events. 
		 * The following types of cue points can be embedded in an FLV file:
		 * <ul><li>A navigation cue point specifies a keyframe within the FLV file, and the cue point's time
		 * property corresponds to that exact keyframe. Navigation cue points are often used as bookmarks or entry
		 * points to let users navigate through the video file. </li>
		 * <li>An event cue point is specified by time, whether or not that time corresponds to a specific keyframe.
		 * An event cue point usually represents a time in the video when something happens that could be used to
		 * trigger other application events.</li></ul>.
		 */		
		public static const NETSTREAM_CUEPOINT:String = "cuepoint";
		
  		/** 
		 * The OvpEvent.NETSTREAM_IMAGEDATA constant defines the value of an OvpEvent's
		 * <code>type</code> property, dispatched when the OvpNetStream class receives an image embedded
		 * in the H.264 file being played. The onImageData method is a callback like
		 * onMetaData that sends image data as a byte array through an AMF0 data channel. The image data
		 * can be in JPEG, PNG, or GIF formats. As the information is a byte array, this functionality is
		 * only supported for ActionScript 3.0 client SWFs. The <code>info</code> property of the event will
		 * hold the image data object and the imageData.data object holds the actual byte array.
		 */		
		public static const NETSTREAM_IMAGEDATA:String = "imagedata";
		
  		/** 
		 * The OvpEvent.NETSTREAM_TEXTDATA constant defines the value of an OvpEvent's
		 * <code>type</code> property, dispatched when the OvpNetStream class receives text data embedded
		 * in the H.264 file being played. The onTextData method is a callback like onMetaData that sends text
		 * data through an AMF0 data channel. The text data is always in UTF-8 format and can contain additional
		 * information about formatting based on the 3GP timed text specification. This functionality is fully
		 * supported in ActionScript 2.0 and 3.0 because it does not use a byte array.The <code>info</code> property of the event will
		 * hold the text data object and the textData.text object holds the actual text.
		 */		
		public static const NETSTREAM_TEXTDATA:String = "textdata";
		
		 /** 
		 * The OvpEvent.NETSTREAM_TEXTDATA constant defines the value of an OvpEvent's
		 * <code>type</code> property, dispatched when the NetStream receives information
		 * specific to Adobe Extensible Metadata Platform (XMP) embedded in the video being played.
		 * The associated event listener is triggered after a call to the NetStream.play() method,
		 * but before the video playhead has advanced.
		 * The data object passed in the event handling function has one data property, which is a string.
		 * The string is generated from a top-level UUID box which contains exactly one XML document represented
		 * as a null-terminated UTF-8 string.
		 */		
		public static const NETSTREAM_XMPDATA:String = "xmpdata";
		
  		/** 
		 * The OvpEvent.NETSTREAM_PLAYSTATUS constant defines the value of an OvpEvent's
		 * <code>type</code> property, dispatched when a NetStream object has completely played a stream,
		 * or when it switches to a different stream in a server-side playlist.
		 * This handler returns information objects that provide information in addition to what's returned
		 * by the netStatus event. You can use this handler to trigger actions in your code when a NetStream
		 * object has switched from one stream to another stream in a playlist (as indicated by the information
		 * object NetStream.Play.Switch) or when a NetStream object has played to the end (as indicated by the
		 * information object NetStream.Play.Complete). 
		 */
		public static const NETSTREAM_PLAYSTATUS:String = "playstatus";
		
  		/** 
		 * The OvpEvent.SUBSCRIBED constant defines the value of the OvpEvent's
		 * <code>type</code> property, which indicates the class has successfully subscribed to a live stream.
		 * 
		 */
		public static const SUBSCRIBED:String = "subscribed";
  			
  		/** 
		 * The OvpEvent.UNSUBSCRIBED constant defines the value of the OvpEvent's
		 * <code>type</code> property, which indicates the class has unsubscribed from a live stream.
		 * This may happen because the <code>unsubscribe</code> method was called by the parent or because the 
		 * publisher of the stream ceased publication. In the latter case, the OvpConnection class will automatically
		 * attempt to resubscribe to the live stream. It will do this until the <code>liveStreamMasterTimeout</code> period
		 * has been exceeded, after which it will dispatch an error event.
		 */
  		public static const UNSUBSCRIBED:String = "unsubscribed";

  		/** 
		 * The OvpEvent.SUBSCRIBE_ATTEMPT constant defines the value of the OvpEvent's
		 * <code>type</code> property, which indicates the class is making a new attempt to subscribe to a live stream.
		 * This will occur immediately after the first <code>play</code> request for a live stream, as well as after
		 * an OvpEvent.UNSUBSCRIBED event has been issued while the stream was still active.
		 * These resubscription attempts will occur roughly every 30 seconds until the <code>liveStreamMasterTimeout</code> period
		 * has been exceeded, after which an error event will be dispatched.
		 */
  		public static const SUBSCRIBE_ATTEMPT:String = "subscribeattempt";
  		
  		/** 
		 * @private
		 * Internal event for handling the "FCSubscribe" calls for playing live streams on some CDNs
		 */
		public static const FCSUBSCRIBE:String = "fcsubscribe";
		
  		/** 
		 * @private
		 * Internal event for handling the "FCUnsubscribe" calls for playing live streams on some CDNs
		 */
		public static const FCUNSUBSCRIBE:String = "fcunsubscribe";
  			
  		/** 
		 * The OvpEvent.DEBUG constant defines the value of the OvpEvent's
		 * <code>type</code> property, which indicates the class has a debug message
		 * for tranmission. The contents of the message are carried in the data object as a string.
		 * 
		 */
  		public static const DEBUG:String = "debug";
  		
  		/**
  		 * The OvpEvent.ASYNC_ERROR constant defines the value of the OvpEvent's
  		 * <code>type</code> property, which indicates an OVP class has a received
  		 * an AsyncErrorEvent.ASYNC_ERROR event.  The event text is carried in the data object as a string.
  		 */
  		public static const ASYNC_ERROR:String = "asyncerror";
  		
  		/**
  		 * Flash Media Live Encoder contains a special built-in handler, <code>onFI</code>, that subscribing clients can use 
  		 * in their ActionScript code to access timecode information. You can get timecode and system date and time 
  		 * information, if timecode and system date and time were embedded in the stream, by accessing the tc, sd, 
  		 * and st properties of the data object when handling this event:
  		 * <ul>
  		 * <li>data.tc; // timecode string formatted hh:mm:ss:ff</li>
  		 * <li>data.sd; // system Date string formatted as dd-mm-yy</li>
  		 * <li>data.st; // system Time string formatted as hh:mm:ss.ms</li>
  		 * </ul>
  		 */
  		public static const ONFI:String = "onfi";
  		
  		/**
  		 * Some FLV files have this callback embedded.
  		 */
  		public static const ONLASTSECOND:String = "onLastSecond";
  		
  		/**
  		 * Closed caption event. The data property will be a Caption object.
  		 * 
  		 * @see org.openvideoplayer.cc.Caption
  		 */
  		public static const CAPTION:String = "caption";
  		
		/** 
		 * For dynamic streaming, dispatched when either a manual switch has been requested or a 
		 * switching rule has requested a switch to a new index. 
		 * 
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
		 * For dynamic streaming, dispatched when the NetStream object receives a "NetStream.Play.Transition" event meaning the 
		 * server has acknowledged the switch request and is in the process of switching streams. 
		 * 
		 * The <code>data</code> object for the event will contain:
  		 * <ul>
  		 * <li>data.nsInfo;		// the info property from the NetStatusEvent object</li>
  		 * </ul>
		 */
		public static const SWITCH_ACKNOWLEDGED:String = "switchAcknowledged";
		
		/** 
		 * For dynamic streaming, dispatched when the NetStream object receives a "NetStream.Play.TransitionComplete" event
		 * meaning the switch is complete and is visible to the user.
		 * 
		 * The <code>data</code> object for the event will contain:
  		 * <ul>
  		 * <li>data.renderingIndex;		// the index of the switching profile that is currently rendering.</li>
  		 * <li>data.renderingBitrate;	// the bitrate of the currently rendering stream
  		 * </ul>
		 */
		public static const SWITCH_COMPLETE:String = "switchComplete";

  		/**
  		 * The RTMP protocol allows arbitrarily-named data messages to be embedded in both live and ondemand streams.
  		 * Typically, to listen for these, a public callback function must be created on the client object associated with the NetStream.
  		 * To avoid the rigidity of this system, with OVP you are able to subscribe to the DATA_MESSAGE event, which will carry the name and value
  		 * associated with any non-standard data message. Standard data messages not included in this event (since they have their own custome events)
  		 * include onMetaData, onCuePoint, onPlayStatus, onXMPData, onImageData, onTextData, onFI, onId3 and onLastSecond. 
  		 * <ul>
  		 * <li>data.name; // the name of the data message, as a String</li>
  		 * <li>data.value; // sthe payload value of the dat message, as an object</li>
  		 * </ul>
  		 */
  		public static const DATA_MESSAGE:String = "datamessage";


		/**
		 * Mapped over from HDEVENT
		 **/
		public static const NET_STATUS:String = "netstatus";
		public static const STREAM_NOT_FOUND:String = "streamnotfound";
		public static const IS_LIVE_STREAM:String = "islivestream";
	 	public static const IS_PLAYING_LIVE:String = "isplayinglive";
		public static const FAILURE:String = "failure";
		public static const IS_BUFFERING:String = "isbuffering";
		public static const SWITCH_START:String = "switchstart";
	 	public static const RESUME:String = "resume";
	 	public static const PAUSE:String = "pause";
		public static const SEEK:String = "seek";
		public static const METADATA:String = "metadata";
		public static const SUCCESS:String = "success";
	 	public static const REJECTED:String = "rejected";
		public static const RENDITION_CHANGE:String = "renditionchange";
		public static const RTT:String = "rtt";
		public static const STREAM_NAME_CHANGE:String = "streamnamechange";
		public static const STREAM_TYPE_CHANGE:String = "streamtypechange";
		public static const FAIL_OVER_TO_RTMP:String = "failovertortmp";
		public static const LOOP:String = "loop";
		public static const PLAY:String = "play";
		public static const CPU:String = "cpu";
		public static const REBUFFER:String = "rebuffer";
		public static const TAT:String = "tat";
		public static const SESSION_ID:String = "sessionid";
		public static const NETSESSION_CLIENT:String = "netsessionclient";
		public static const NETSESSION_EULA:String = "netsessioneula";
		public static const STREAM_START_TIME:String = "streamstarttime";
		// Duplicated Events
		//public static const DATA_MESSAGE:String = "datamessage";
		//public static const PARSED:String = "parsed";
		//public static const ERROR:String = "error";
		//public static const TIMEOUT:String = "timeout";
		//public static const DEBUG:String = "debug";
		//public static const PROGRESS:String = "progress";
		//public static const BANDWIDTH:String = "bandwidth";
		//public static const COMPLETE:String = "complete";
		//public static const SWITCH_COMPLETE:String = "switchcomplete";
		// End Mapping
	
		private var _data:Object;
		
		/**
		 * Returns the data for the event, which can differ based on the event type.
		 * See the event constants in this class for a description of the data object for each event type.
		 * 
		 */
		public function get data():Object { return _data; }
		
		/**
		 * Constructor.
		 * 
		 * @param type One of the event type constants defined in this class.
		 * @param data Corresponding data for the event. This can differ depending on the event type. See the event type definitions in this class.
		 */
		public function OvpEvent(type:String, data:Object=null)
		{
			_data = data;
			super(type);
		}
		
       /** 
        * Overrides the inherited clone() method.
        * @private
        */
        override public function clone():Event {
            return new OvpEvent(type, data);
        }		
	}
}
