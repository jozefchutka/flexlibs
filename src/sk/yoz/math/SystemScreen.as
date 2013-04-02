package sk.yoz.math
{
    import flash.system.Capabilities;

    public class SystemScreen
    {
        public static const INCH_TO_CENTIMETERS:Number = 2.54;
        public static const INCH_TO_PIXELS:Number = Capabilities.screenDPI;
        
        public static const CENTIMETER_TO_INCHES:Number = 0.393700787;
        public static const CENTIMETER_TO_PIXELS:Number = Capabilities.screenDPI * 0.393700787;
        
        public static const PIXEL_TO_INCHES:Number = 1 / Capabilities.screenDPI;
        public static const PIXEL_TO_CENTIMETERS:Number = 2.54 / Capabilities.screenDPI;
        
        public static const SCREEN_SIZE_IN_PIXELS:Number = Math.sqrt(
            Capabilities.screenResolutionX * Capabilities.screenResolutionX +
            Capabilities.screenResolutionY * Capabilities.screenResolutionY);
        
        public function SystemScreen()
        {
        }
    }
}