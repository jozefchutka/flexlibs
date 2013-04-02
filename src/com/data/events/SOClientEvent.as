package com.data.events
{
import flash.events.Event;
    
public class SOClientEvent extends Event
{
    public static const DATA_SAVED:String="dataSaved";

    public static const DATA_SAVE_ERROR:String="dataSaveError";

    private var _data:Object;

    public function SOClientEvent(type:String,data:Object=null):void
    {
        super(type);
        _data=data;
    }

    public function set data(v:Object):void
    {
        if (v)
            _data=v;

    }

    public function get data():Object
    {
        return _data;
    }

}
}