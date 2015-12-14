import processing.video.*;
import processing.serial.*;

Serial arduino;
String arduinoUSBPort = "COM7";
Capture webcam;
String cameraName = "name=Logitech HD Webcam C615,size=1920x1080,fps=30";
int pos = 0;
boolean go = false;
int currentPhoto = 0;
int numImages = 400;
boolean doTakePhoto = false;
boolean doComposite = true;
int stepIncrementer = 1;
int serialDelay = 1000;

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
        delay(serialDelay);
        break;
      }
    }
  }
  loadPixels();
  println("Done setting up!");
}

void draw(){
  if(doTakePhoto){
    println("Take Photos...");
    takePhotos();
  }
  else if(doComposite){
    println("Compositing...");
    composite();
  }
}

void takePhotos(){
  if(pos < (numImages * stepIncrementer)){
    if(webcam.available()){
      webcam.read();
    }
    image(webcam, 0, 0);
    pos += stepIncrementer;
    String message = "G0 Y" + pos + "\n";
    byte[] messageBytes = message.getBytes();
    arduino.write(messageBytes);
    println("Sent " + message);
    delay(3000);
    saveFrame("data/image_" + currentPhoto + ".jpg");
    println("Saving data/image_" + currentPhoto + ".jpg");
    currentPhoto += 1;
  }
  else{
    doTakePhoto = false;
    doComposite = true;
  }
}

void composite(){
  PImage imageToLoad;
  int numXPixelsToLoad = 1920 / numImages;
  float fnumXPixelsToLoad = 1920.0 / numImages;
  println("fnumXPixelsToLoad: " + fnumXPixelsToLoad);
  int numImagesNeedingExtra = (numImages - (1920 - (numXPixelsToLoad * numImages))) * 4;
  println("numImagesNeedingExtra: " + numImagesNeedingExtra);
  int startXPixelToLoad = ((1920 / 2) - (numXPixelsToLoad / 2));
  int startXPixelToPlace = 1919;
  int xPixelToLoad;
  int xPixelToPlace;
  int pixelToLoad;
  int pixelToPlace;
  println("Number of Pixels to Load: " + numXPixelsToLoad);
  for(int images = (numImages - 1); images >= 0; images--){
    println("Loading image: " + images);
    imageToLoad = loadImage("data/image_" + images + ".jpg");
    imageToLoad.loadPixels();
    if(images >= numImagesNeedingExtra){
      startXPixelToPlace = 1920 - (numXPixelsToLoad * (numImages - images));
    }
    else{
      startXPixelToPlace = (1920 - ((numXPixelsToLoad) * (numImages - images))) - (numImagesNeedingExtra - images);
    }
    println(startXPixelToPlace);
    for(int yPixel = 0; yPixel < 1080; yPixel++){
      for(int xPixel = 0; xPixel < numXPixelsToLoad; xPixel++){
      xPixelToLoad = xPixel + startXPixelToLoad;
      xPixelToPlace = xPixel + startXPixelToPlace;
        pixelToLoad = (yPixel * 1920) + xPixelToLoad;
        pixelToPlace = (yPixel * 1920) + xPixelToPlace;
        pixels[pixelToPlace] = imageToLoad.pixels[pixelToLoad];
      }
    }
    updatePixels();
  }
  doComposite = false;
}