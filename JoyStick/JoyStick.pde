import procontroll.*;
import java.io.*;

ControllIO controll;
ControllDevice device;
ControllStick stick;
ControllButton button;

void setup(){
  size(400,400);
  
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
}

float totalX = width/2;
float totalY = height/2;

void draw(){
  background(255);
  
  if(button.pressed()){
    fill(255,0,0);
  }else{
    fill(0);
  }
  println("x=" + stick.getX() + " - y=" + stick.getY());
  totalX = constrain(totalX + stick.getX(),10,width-10);
  totalY = constrain(totalY + stick.getY(),10,height-10);
  
  rect(totalX,totalY,20,20);
}
