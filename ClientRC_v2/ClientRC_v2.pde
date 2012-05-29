import processing.net.*;
import procontroll.*;
import java.io.*;

ControllIO controll;
ControllDevice device;
ControllStick stick;
ControllButton button;
Client client;

void setup(){
  size(180,180);
  
  controll = ControllIO.getInstance(this);

  device = controll.getDevice(1);
  device.printSticks();
  device.setTolerance(0.05f);
  
  ControllSlider sliderX = device.getSlider(0);
  ControllSlider sliderY = device.getSlider(1);
  
  stick = new ControllStick(sliderX,sliderY);
  
  button = device.getButton("Left");
  
  fill(0);
  rectMode(CENTER);
    // Connect to the server's IP address and port
  client = new Client(this, "localhost", 12345); // Replace with your server's IP and port
}

float totalX = width/2;
float totalY = height/2;
float x,y;
String input;

void draw(){
  background(255);
  
  if(button.pressed()){
    fill(255,0,0);
  }else{
    fill(0);
  }
  
  totalX = constrain(totalX + stick.getX(),0,width);
  totalY = constrain(totalY + stick.getY(),0,height);
  println(totalX + "-" + totalY);
  rect(totalX,totalY,20,20);
  
  x = map(totalX, 0, 180, 0, 180);
  y = map(totalY, 0, 180, 0, 180);
  if (client!=null) {
    client.write("STICK:x=" + x + ":y=" + y  + "\n");
    // Receive data from server
    if (client.available() > 0) {
      input = client.readString();
      println(input);
    }
  }
  println("x=" + totalX + " y=" + totalY);
}
