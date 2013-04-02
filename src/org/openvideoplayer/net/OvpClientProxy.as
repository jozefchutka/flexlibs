//
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

package org.openvideoplayer.net
{
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	/**
	 * This proxy class is used privately by OVpNetStream to listen for capture 
	 * client object callbacks. 
	 * 
	 */	
	dynamic public class OvpClientProxy extends Proxy
	{
		/**
		 * Adds a handler for the specified callback name.
		 * 
		 * @param name Name of callback to handle.
		 * @param handler Handler to add.
		 */		
		public function addHandler(name:String,handler:Function):void
		{
			var handlersForName:Array 
				= handlers.hasOwnProperty(name)
					? handlers[name]
					: (handlers[name] = []);
			
			if (handlersForName.indexOf(handler) == -1)
			{
				handlersForName.push(handler);
			}
		}
		
		/**
		 * Removes a handler method for the specified callback name.
		 * 
		 * @param name Name of callback for whose handler is being removed.
		 * @param handler Handler to remove.
		 * @return Returns <code>true</code> if the specified handler was found and
		 * successfully removed. 
		 */		
		public function removeHandler(name:String,handler:Function):Boolean
		{
			var result:Boolean;
			
			if (handlers.hasOwnProperty(name) )
			{
				var handlersForName:Array = handlers[name];
				var index:int = handlersForName.indexOf(handler);
			
				if (index != -1)
				{
					handlersForName.splice(index,1);
					
					result = true;
				}
			}
			
			return result;	
		}
	
		/**
		 * @private
		 */		
		override flash_proxy function callProperty(methodName:*, ... args):*
		{
			return invokeHandlers(methodName,args);
        }
        
        /**
		 * @private
		 */
		override flash_proxy function getProperty(name:*):* 
		{
			var result:*;			
				result 
					=  function():*
						{
							return invokeHandlers(arguments.callee.name,arguments);
						}
				
				result.name = name;
			return result;
		}
			
		
		/**
		 * @private
		 * 
		 * Holds an array of handlers per callback name. 
		 */		
		private var handlers:Dictionary = new Dictionary();
		
		/**
		 * @private
		 * 
		 * Utility method that invokes the handlers for the specified
		 * callback name. The reserved name "all" will match all callbacks. 
		 *  
		 * @param name The callback name to invoke the handlers for.
		 * @param args The arguments to pass to the individual handlers on
		 * invoking them.
		 * @return <code>null</code> if no handlers have been added for the
		 * specified callback, or otherwise an array holding the result of
		 * each individual handler invokation. 
		 * 
		 */				
		private function invokeHandlers(name:String,args:Array):*
		{
			var result:Array;
			var handler:Function;
			var handlersForName:Array;
        	if (handlers.hasOwnProperty(name))
			{
				result = [];
				handlersForName = handlers[name];
				for each (handler in handlersForName)
				{
					result.push(handler.apply(null,args));
				}
			}
			if (handlers.hasOwnProperty("all"))
			{
				result = [];
				handlersForName = handlers["all"];
				for each (handler in handlersForName)
				{
					args.unshift(name);
					result.push(handler.apply(null,args));
				}
			}
			
			return result;
		}
	}
}