import processing.video.*;

import processing.serial.*;

Serial arduino;
String arduinoUSBPort = "COM3";
Capture webcam;
String cameraName = "name=Logitech HD Webcam C615,size=1920x1080,fps=30";
int pos = 0;
boolean go = false;
int currentPhoto = 0;
int numImages = 28;

void setup(){
  size(1920, 1080);
  println("Getting the arduino, looking at: " + arduinoUSBPort); 
  for(int i = 0; i < Serial.list().length; i++){
    println(Serial.list()[i]);
    if(Serial.list()[i].equals(arduinoUSBPort)){
      arduino = new Serial(this, Serial.list()[i], 115200);
      println("Opened " + arduinoUSBPort);
    }
  }
  println("Checking for cameras...");
  printArray(Capture.list());
  if(Capture.list().length < 1){
    println("NO CAMERAS");
  }
  else{
    String[] cameraList = Capture.list();
    for(int i = 0; i < cameraList.length; i++){
      println("Checking camera " + cameraList[i]);
      if(cameraList[i].equals(cameraName)){
        webcam = new Capture(this, cameraList[i]);
        webcam.start();
        println("Started " + cameraName);
        if(webcam.available()){
          webcam.read();
        }
        image(webcam, 0, 0);
        delay(2000);
        break;
      }
    }
  }
  println("Done setting up!");
}

void draw(){
  if(pos < numImages){
    if(webcam.available()){
      webcam.read();
    }
    image(webcam, 0, 0);
    pos += 2;
    String message = "G0 Y" + pos + "\n";
    byte[] messageBytes = message.getBytes();
    arduino.write(messageBytes);
    println("Sent " + message);
    delay(3000);
    saveFrame("data/image_" + currentPhoto + ".jpg");
    println("Saving data/image_" + currentPhoto + ".jpg");
    currentPhoto += 1;
  }
  else if(pos == numImages){
    int numPixelsToTake = 1920 / numImages;
    int pixelLocation = 1920;
    int startPixelToPullFrom = ((1920 / 2) - (numPixelsToTake / 2));
    println("Pulling " + numPixelsToTake + " pixels from each image.");
    for(int i = (numImages - 1); i >= 0; i++){
      println("Pulling Image " + i);
      pixelLocation -= numPixelsToTake;
      println("Placing Image at " + pixelLocation);
      for(int xPixel = startPixelToPullFrom; xPixel < (startPixelToPullFrom + numPixelsToTake); xPixel++){
        for(int yPixel = 0; yPixel < 1080; yPixel++)
    }
  }
}