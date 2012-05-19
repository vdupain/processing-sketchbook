import processing.net.*;
import procontroll.*;
import java.io.*;

ControllIO controll;
ControllDevice device;
ControllStick stick;
ControllButton button;
Client client;
String input;
int data[];

float totalX;
float totalY;

void setup() 
{
  controll = ControllIO.getInstance(this);
  device = controll.getDevice("PLAYSTATION(R)3 Controller");
  device.printSticks();
  device.setTolerance(0.05f);
  ControllSlider sliderX = device.getSlider(0);
  ControllSlider sliderY = device.getSlider(3);
  stick = new ControllStick(sliderX, sliderY);

  // Connect to the server's IP address and port
  client = new Client(this, "192.168.1.150", 12345); // Replace with your server's IP and port
}

void draw() 
{
  totalX = map(stick.getX(), -1, 1, 0, 1);
  totalY = map(-stick.getY(), -1, 1, 0, 1);


  if (client!=null) {
    client.write("JOYSTICK:x=" + totalX + ":y=" + totalY  + "\n");
    // Receive data from server
    if (client.available() > 0) {
      input = client.readString();
      println(input);
    }
  }
  println("x=" + totalX + " y=" + totalY);
}

