import processing.serial.*;
import processing.video.*;

Serial arduino;
String arduinoUSBPort = "/dev/tty.usbmodem1451";
Capture webcam;
String cameraName = "name=Logitech Camera,size=1920x1080,fps=30";
int pos = 0;
boolean go = false;
int currentPhoto = 0;

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
  if(webcam.available()){
    webcam.read();
  }
  image(webcam, 0, 0);
  if(pos < 150){
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
}