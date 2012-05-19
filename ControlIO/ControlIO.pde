import procontroll.*;
import java.io.*;

ControllIO controll;
ControllDevice device;
ControllStick stick;
ControllButton button;

void setup(){
  size(180,180);
  
  controll = ControllIO.getInstance(this);

  device = controll.getDevice(1);
  device.printSticks();
  device.setTolerance(0.05f);
  
  ControllSlider sliderX = device.getSlider(0);
  ControllSlider sliderY = device.getSlider(1);
  
  stick = new ControllStick(sliderX,sliderY);
  println("x=" + stick.getTotalX() + " y=" + stick.getTotalY());
  println(stick);

  button = device.getButton("Left");
  
  fill(0);
  rectMode(CENTER);
}

float totalX = 180/2;
float totalY = 180/2;

void draw(){
  background(255);
  
  if(button.pressed()){
    fill(255,0,0);
  }else{
    fill(0);
  }
  
  totalX = constrain(totalX + stick.getX(),0,width);
  totalY = constrain(totalY + stick.getY(),0,height);
  
  println("x=" + totalX + " y=" + totalY);
  //println("x=" + stick.getX() + " y=" + stick.getY());

  rect(totalX,totalY,20,20);
}
