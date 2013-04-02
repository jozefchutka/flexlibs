package sk.yoz.net
{
    import flash.events.IEventDispatcher;
    
    public interface IP2PMulticastPersistence extends IEventDispatcher
    {
        function saveClientList(list:Array):void;
        function getClientList():void;
    }
}