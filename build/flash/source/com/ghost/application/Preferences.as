/**
 * Preferences
 * Prefence loader class
 * 
 * @author Taylan Pince (taylanpince@gmail.com)
 * @date May 10, 2008
 */

package com.ghost.application {

    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    
    public class Preferences {
    
        private var prefsXML:XML;
        private var prefsLoaded:Boolean;
        private var xmlLoader:URLLoader;
        
        private static var prefsInstance:Preferences;
        
        public function Preferences( xmlPath:String ) {
            var xmlRequest:URLRequest = new URLRequest(xmlPath);
            
            xmlLoader = new URLLoader();
            
            try {
                xmlLoader.load(xmlRequest);
            } catch (error:SecurityError) {
                trace("A security error occured.");
            }
            
            xmlLoader.addEventListener(Event.COMPLETE, loadCompleteHandler);
            xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
        }
        
        public static function getInstance( xmlPath:String="xml/preferences.xml" ):Preferences {
            if (!prefsInstance) {
    			prefsInstance = new Preferences(xmlPath);
    		}
            
    		return prefsInstance;
        }
        
        public function getPreference( key:String ):String {
            return prefsXML.pref.(@key == key).attribute("value");
        }
        
        public function isLoaded():Boolean {
            return prefsLoaded;
        }
        
        private function loadCompleteHandler( event:Event ):void {
            try {
                prefsXML = new XML(xmlLoader.data);
                prefsLoaded = true;
            } catch (error:TypeError) {
                trace("Unable to parse the XML file.");
            }
        }
        
        private function errorHandler( error:IOErrorEvent ):void {
            trace("Error loading the XML file!");
        }
    
    }

}