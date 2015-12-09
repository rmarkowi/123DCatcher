import processing.serial.*;
import processing.video.*;

Serial arduino;

void setup(){
  for(int i = 0; i < Serial.list().length; i++){
    println(Serial.list()[i]);
    if(Serial.list()[i] == "dev/tty.usbmodem1451"){
      arduino = new Serial(this, Serial.list()[i], 115200);
    }
  }
}

void draw(){
  
}