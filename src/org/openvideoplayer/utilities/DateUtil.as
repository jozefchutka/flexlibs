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

package org.openvideoplayer.utilities
{
	/**
	 *  The DateUtil utility class is an all-static class with methods for
	 *  working with Date objects.
	 *  You do not create instances of DateUtil;
	 *  instead you call methods such as 
	 *  the <code>DateUtil.compare()</code> method.  
	 */
	public class DateUtil
	{
	    /**
	     *  Compares two dates.
	     *
	     *  @param d1 The first date to compare. 
	     *
	     *  @param d2 The second date to compare.
	     *
	     *  @return -1 if the first date is earlier than the second. 0 if the dates are equal. 1 if the first date is later than the second.
	     */
	     public static function compare(d1:Date, d2:Date) : Number {
	     	var d1Ts:Number = d1.getTime();
	     	var d2Ts:Number = d2.getTime();
	     	
	     	var result:Number = -1;
	     	
	     	if (d1Ts == d2Ts)
	     		result = 0;
	     	else if (d1Ts > d2Ts)
	     		result = 1;
	     		
	     	return result;
	     }

	}
}
