package sk.yoz.net
{
    import com.facebook.Facebook;
    import com.facebook.events.FacebookEvent;
    import com.facebook.utils.FacebookSessionUtil;
    
    import flash.display.LoaderInfo;
    import flash.events.EventDispatcher;
    
    import sk.yoz.events.FacebookLoggerEvent;
    
    public class FacebookLogger extends EventDispatcher
    {
        protected var facebook:Facebook;
        protected var session:FacebookSessionUtil;
        
        private var _connected:Boolean = false;
        
        public function FacebookLogger()
        {
            super();
        }
        
        [Bindable(event="FacebookLoggerEventCONNECTED")]
        public function get connected():Boolean
        {
            return _connected;
        }
        
        protected function set connected(value:Boolean):void
        {
            _connected = value;
            var type:String = FacebookLoggerEvent.CONNECTED;
            dispatchEvent(new FacebookLoggerEvent(type));
        }
        
        public function init(apiKey:String, appSecret:String, 
            loaderInfo:LoaderInfo):void
        {
            session = new FacebookSessionUtil(apiKey, appSecret, loaderInfo);
            session.addEventListener(FacebookEvent.CONNECT, connectHandler);
            facebook = session.facebook;
            
            if(loaderInfo.parameters.fb_sig_session_key)
                 session.verifySession();
            else
                login();
        }
        
        protected function login():void
        {
            session.login();
        }
        
        public function validate():void
        {
            session.validateLogin();
        }
        
        protected function connectHandler(event:FacebookEvent):void
        {
            if(!event.success) 
                return login();
            
            protected::connected = true;
        }
    }
}