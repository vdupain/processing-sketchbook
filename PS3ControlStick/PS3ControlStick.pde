import procontroll.*;
import java.io.*;

ControllIO controll;
ControllDevice device;
ControllStick stick;
ControllButton button;

void setup() {
  size(400, 400);

  controll = ControllIO.getInstance(this);

  device = controll.getDevice("PLAYSTATION(R)3 Controller");
  println(device.getName()+" has:");
  println(" " + device.getNumberOfSliders() + " sliders");
  println(" " + device.getNumberOfButtons() + " buttons");
  println(" " + device.getNumberOfSticks() + " sticks");
  device.printSliders();
  device.printButtons();
  device.printSticks();

  device.setTolerance(0.05f);

  ControllSlider sliderX = device.getSlider(0);
  ControllSlider sliderY = device.getSlider(3);

  stick = new ControllStick(sliderX, sliderY);

  button = device.getButton(1);

  fill(0);
  rectMode(CENTER);
}

float totalX = width/2;
float totalY = height/2;

void draw() {
  background(255);

  if (button.pressed()) {
    fill(255, 0, 0);
  }
  else {
    fill(0);
  }

  totalX = constrain(totalX + stick.getX(), 10, width-10);
  totalY = constrain(totalY + stick.getY(), 10, height-10);
  float x = map(stick.getX(), -1, 1, 0, 180);
  float y = map(-stick.getY(), -1, 1, 0, 180);
  println("x=" + x + " y=" + y);
  rect(totalX, totalY, 20, 20);
}

