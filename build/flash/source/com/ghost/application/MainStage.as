/**
 * Main Stage
 * Main application class
 * 
 * @author Taylan Pince (taylanpince@gmail.com)
 * @date May 10, 2008
 */

package com.ghost.application {

    import flash.display.Sprite;
    import flash.display.SimpleButton;
    import flash.display.Bitmap;
    import flash.display.BitmapData
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.media.Camera;
    import flash.media.Video;
    import flash.geom.Matrix;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.system.fscommand;
    import flash.printing.PrintJob;
    import flash.printing.PrintJobOptions;
    
    import com.ghost.application.Preferences;
    
    public class MainStage extends Sprite {
    
        private var videoOutput:Video;
        private var detectorOutput:Bitmap;
        private var imageList:Array;
        private var imageMatrix:Matrix;
        private var currentSnapShot:BitmapData;
        private var outputSnapShot:BitmapData;
        private var previousSnapShot:BitmapData;
        
        public function MainStage() {
            var camera:Camera = Camera.getCamera();
            
            if (camera != null) {
                videoOutput = new Video(camera.width * 2, camera.height * 2);
                videoOutput.attachCamera(camera);
                addChild(videoOutput);
                
                Preferences.getInstance();
                addEventListener(Event.ENTER_FRAME, init);
                
                printButton.addEventListener(MouseEvent.MOUSE_UP, printFrame);
            } else {
                trace("Camera could not be found.");
            }
        }
        
        private function init( event:Event ):void {
            if (Preferences.getInstance().isLoaded()) {
                removeEventListener(Event.ENTER_FRAME, init);
                initDetector();
            }
        }
        
        private function initDetector():void {
        	imageList = new Array();
        	imageMatrix = new Matrix();
        	
        	imageMatrix.scale(videoOutput.scaleX, videoOutput.scaleY);

        	currentSnapShot = new BitmapData(videoOutput.width, videoOutput.height);
        	outputSnapShot = new BitmapData(videoOutput.width, videoOutput.height);
        	
        	currentSnapShot.draw(videoOutput, imageMatrix);
        	previousSnapShot = currentSnapShot.clone();
        	
        	detectorOutput = new Bitmap(outputSnapShot);
        	addChild(detectorOutput);

        	detectorOutput.x = videoOutput.width;
        	detectorOutput.y = videoOutput.y;
        	
        	thresholdOutput.text = Preferences.getInstance().getPreference("MOTION_THRESHOLD");

        	var updateTimer:Timer = new Timer(100, 0);
        	updateTimer.addEventListener(TimerEvent.TIMER, updateDetector);
        	updateTimer.start();
        }

        private function updateDetector( event:TimerEvent ):void {
        	currentSnapShot.draw(videoOutput, imageMatrix);

        	var currentSnapShotClone = currentSnapShot.clone();

        	currentSnapShotClone.draw(previousSnapShot, imageMatrix, null, "difference");
        	motionOutput.text = currentSnapShotClone.threshold(currentSnapShotClone, currentSnapShotClone.rect, currentSnapShotClone.rect.topLeft, ">", 0xFF111111, 0xFF00FF00, 0x00FFFFFF, false);

        	previousSnapShot = currentSnapShot.clone();

    		outputSnapShot.draw(currentSnapShotClone, imageMatrix);
        }
        
        private function printFrame( event:MouseEvent ):void {
            fscommand("exec", "Print.app");
            
            var printTimer:Timer = new Timer(1000, 1);
        	printTimer.addEventListener(TimerEvent.TIMER, printStart);
        	printTimer.start();
        }
        
        private function printStart( event:TimerEvent ):void {
            var printProcess:PrintJob = new PrintJob();
            
            printProcess.start();
            printProcess.send();
        }
    
    }

}