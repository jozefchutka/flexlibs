package sk.yoz.net
{
    import flash.net.NetConnection;
    import flash.net.NetStream;

    public class StratusStream extends NetStream
    {
        public var connected:Boolean = false;
        
        public function StratusStream(connection:NetConnection, peerID:String)
        {
            super(connection, peerID);
        }
    }
}