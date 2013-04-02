package com.data
{
import com.data.events.SOClientEvent;

import flash.events.EventDispatcher;
import flash.events.NetStatusEvent;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;

[Event(name="dataSaved", type="com.data.events.SOClientEvent")]

[Event(name="dataSaveError", type="com.data.events.SOClientEvent")]

public class SOClient extends EventDispatcher
{
    private var localSO:SharedObject;
    
    public function SOClient(name:String, path:String = null, crossDomain:Boolean = false)
    {
        if (!crossDomain)
        {
            localSO = SharedObject.getLocal(name, path, false);
        }
        else
        {
            localSO = SharedObject.getRemote(name, path, true, false);
        }
    }

    public function saveData(key:String, data:Object = null):void
    {
         localSO.data[key]=data;

         var flushStatus:String = null;  

         try
         {
             flushStatus = localSO.flush();  
         }
         catch (error:Error)
         {
             //output.appendText("Error...Could not write SharedObject to disk\n");  
             dispatchEvent(new SOClientEvent(SOClientEvent.DATA_SAVE_ERROR)); 
         }  

        if (flushStatus != null)
        {  
             switch (flushStatus)
             {
                 case SharedObjectFlushStatus.PENDING :
                 {
                    // output.appendText("Requesting permission to save object...\n");  
                     localSO.addEventListener(NetStatusEvent.NET_STATUS, localSO_netStatusHandler);  
                     break;
                 }
                 case SharedObjectFlushStatus.FLUSHED :
                 {  
                     //output.appendText("Value flushed to disk.\n");  
                     dispatchEvent(new SOClientEvent(SOClientEvent.DATA_SAVED));
                     break;
                 }  
             }  
        } 

    }
    private function localSO_netStatusHandler(event:NetStatusEvent):void 
    {
       //output.appendText("User closed permission dialog...\n");  
       switch (event.info.code)
       {  
           case "SharedObject.Flush.Success" :
           {
             // output.appendText("User granted permission -- value saved.\n");  
              dispatchEvent(new SOClientEvent(SOClientEvent.DATA_SAVED))
               break;
           }
           case "SharedObject.Flush.Failed" :
           {
               //output.appendText("User denied permission -- value not saved.\n"); 
                dispatchEvent(new SOClientEvent(SOClientEvent.DATA_SAVE_ERROR)); 
                break;
            }
        }

        localSO.removeEventListener(NetStatusEvent.NET_STATUS, localSO_netStatusHandler);
    }

    public function loadData(key:String):Object
    {
        return localSO.data[key];
    }

}
}