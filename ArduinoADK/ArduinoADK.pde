// Augmented Reality RGBCube OOP Example by Amnon Owed (21/12/11)
// Processing 1.5.1 + NyARToolkit 1.1.6 + GSVideo 1.0

import java.io.*; // for the loadPatternFilenames() function
import processing.opengl.*; // for OPENGL rendering
import jp.nyatla.nyar4psg.*; // the NyARToolkit Processing library
import codeanticode.gsvideo.*; // the GSVideo library
import monclubelec.javacvPro.*;

MultiMarker nya;
GSCapture cam;
OpenCV opencv;

// this is the arraylist that holds all the objects
ArrayList <ARObject> ars = new ArrayList <ARObject> ();

// a central location is used for the camera_para.dat and pattern files, so you don't have to copy them to each individual sketch
// Make sure to change both the camPara and the patternPath String to where the files are on YOUR computer
// the full path to the camera_para.dat file
String camPara = "/Users/vince/Dev/Arduino/NyAR4psg/data/camera_para.dat";
// the full path to the .patt pattern files
String patternPath = "/Users/vince/Dev/patternMaker/examples/ARToolKit_Patterns";
// the dimensions at which the AR will take place. with the current library 1280x720 is about the highest possible resolution.
int arWidth = 640;
int arHeight = 480;
// the number of pattern markers (from the complete list of .patt files) that will be detected, here the first 10 from the list.
int numMarkers = 100;

//----- variables pour calibration webcam ----- 
 float ouvertureX=19.43; // ouverture largeur en degres - Hercules DualPix Exchange
//float ouvertureX=22.53; // ouverture largeur en degres -  Logitech C270 

// calculé avec tan angle= largeur réelle / 2 * distance camera
// exemple Logitech C270 : 1/2 largeur réelle = 83cm  distance = 200 cm
// d'où tan angle = 0.415 et d'où angle = 22.53 deg

Marker[] markersArray = new Marker[numMarkers]; // tableau pour stockage des paramètres des markers détectés avec ARToolkit - classe javacvPro !
float realWidthMarker=50; // taille réelle du marker utilisé en mmm - on aura un correspondance 1 mm = 1 pixel ou cran dans le repère 3D du marker

int jaune=color(255,255,0); 
int vert=color(0,255,0); 
int rouge=color(255,0,0); 
int bleu=color(0,0,255); 
int noir=color(0,0,0); 
int blanc=color(255,255,255); 
int bleuclair=color(0,255,255); 
int violet=color(255,0,255); 

void setup() {
  size(640, 480, OPENGL); // the sketch will resize correctly, so for example setting it to 1920 x 1080 will work as well
  cam = new GSCapture(this, 640, 480); // initialize the webcam capture at a specific resolution (correct and/or possible settings depend on YOUR webcam)
  cam.start(); // start capturing
  // initialize the MultiMarker at a specific resolution (make sure to input images for detection EXACTLY at this resolution)
  nya = new MultiMarker(this, arWidth, arHeight, camPara, NyAR4PsgConfig.CONFIG_DEFAULT);
  // set the delay after which a lost marker is no longer displayed. by default set to something higher, but here manually set to immediate.
  nya.setLostDelay(1);
  // load the pattern filenames (markers)
  String[] patterns = loadPatternFilenames(patternPath);
  // for the selected number of markers...
  for (int i=0; i<numMarkers; i++) {
    // add the marker for detection
    nya.addARMarker(patternPath + "/" + patterns[i], 0);
    // and create an ARObject with the corresponding 'ID'
    ars.add(new ARObject(i));
    markersArray[i]=new Marker(); 
    markersArray[i].realWidth=realWidthMarker; 
  }
  // set the color range to 1 (instead of 255), saves typing for the coloring of the cube
  colorMode(RGB, 1);
  // turn off stroke for the rest of the sketch
  noStroke();
  
  opencv = new OpenCV(this); // initialise objet OpenCV à partir du parent This
  opencv.allocate(800,600); // crée les buffers image de la taille voulue
}

PImage input;

void draw() {
  // if there is a cam image coming in...
  if (cam.available()) {
    cam.read(); // read the cam image
    opencv.copy(cam);
    background(0); // a background call is needed for correct display of the marker results
    image(cam, 0, 0, width, height); // display the image at the width and height of the sketch window
    // create a copy of the cam image at the resolution of the AR detection (otherwise nya.detect will throw an assertion error!)
    PImage cSmall = cam.get();
    cSmall.resize(arWidth, arHeight);
    nya.detect(cSmall); // detect markers in the image
    
    opencv.updateMarkers(nya, markersArray, false);
    opencv.draw2DMarkers(nya, markersArray); // trace les markers - javacvPro
    opencv.distanceMarkers(nya, markersArray, ouvertureX, 800, false);  // calcule et mémorise la distance réelle des Markers à la caméra - javacvPro
    
    if (opencv.isExistMarker(nya, markersArray,83)) { // détecte si marker détecté à partir de son numero (pas l'indice)
      Marker selectedMarker = opencv.selectMarker(markersArray,83); // sélectionne le marker voulu
      println("Le marker " + selectedMarker.name + " est détecté !"); // le nom du fichier de description du marker
      println("Le centre est en x=" + selectedMarker.center2D.x + " | y="+ selectedMarker.center2D.y); // affiche les coordonnées du centre  
      opencv.drawCircle (
                    selectedMarker.center2D, // le centre du cercle à tracer
                        0, 0, // les coordonnées du cercle à tracer
                        1, // l'échelle à utiliser
                        10, // rayon à utiliser
                        jaune,1, // couleur et épaisseur du pourtour du cercle
                        true, rouge, // drapeau de remplissage et couleur de remplissage
                        false // drapeau d'affichage des messages
                                ); 


   }

    // run all the ARObjects's in the arraylist => most things are handled inside the ARObject (see the class for more info)
    for (ARObject ar : ars) { 
      ar.run();
    }
    // reset to the default perspective
    perspective();
    //fill(255,255,255);
    stroke(255, 0, 0); 
    noFill();
    rect(width/2-15, 0, 60, height);
    rect(0, height/2-15, width, 60);
    //rect(width/2-15, height/2-15, 60, 60);
  }
}

// this function loads .patt filenames into a list of Strings based on a full path to a directory (relies on java.io)
String[] loadPatternFilenames(String path) {
  File folder = new File(path);
  FilenameFilter pattFilter = new FilenameFilter() {
    public boolean accept(File dir, String name) {
      return name.toLowerCase().endsWith(".patt");
    }
  };
  return folder.list(pattFilter);
}

// class that defines the AROBject, both the AR detection and display are handled inside this class
class ARObject {
  int ID; // keep track of the current the ID of the object (corresponds with the ID i of the marker)
  PVector rot, speed; // in this example the cube has a certain rotation and rotates at a certain speed

    ARObject(int ID) {
    this.ID = ID; // set the ID
  }

  void run() {
    // checks the object's corresponding marker through the ID
    // if the marker is found, display the cube
    if (nya.isExistMarker(ID)) { 
      //display();
    }
  }

  void display () {
    
    // get the four marker coordinates into an array of 2D PVectors
    PVector[] pos2d = nya.getMarkerVertex2D(ID);    
    // draw each vector both textually and with a red dot
    String s;
    for (int j=0; j<pos2d.length; j++) {
      s = "(" + int(pos2d[j].x) + "," + int(pos2d[j].y) + ")";
      fill(255, 255, 255);
      rect(pos2d[j].x, pos2d[j].y, textWidth(s) + 3, textAscent() + textDescent() + 3);
      fill(0);
      text(s, pos2d[j].x + 2, pos2d[j].y + 10);
      //fill(255, 0, 0);
      fill(255, 0, 0, 127);
      ellipse(pos2d[j].x, pos2d[j].y, 10, 10);
    } // fin for pos2d

    //center
    float centerX = (pos2d[0].x+pos2d[2].x)/2;
    float centerY = (pos2d[0].y+pos2d[2].y)/2;
    s = "(" + int(centerX) + "," + int(centerY) + ")";
    fill(255, 255, 255);
    rect(centerX, centerY, textWidth(s) + 3, textAscent() + textDescent() + 3);
    fill(0);
    text(s, centerX + 2, centerY + 10);
    //fill(255, 0, 0);
    fill(255, 0, 0, 127);
    ellipse(centerX, centerY, 10, 10);

    if (centerX<((width/2)-30)) { // si on est vers la gauche - la valeur retranchée évite oscillation sur centre...
      //--- plus l'angle utilisé ici est grand, plus c'est rapide... mais si trop grand, trop par "à coup"... 2 ou 3 degrès = bon compromis)
      println("+++");
    }
    else if (centerX>((width/2)+30)) { // si on est vers la droite - la valeur retranchée évite oscillation sur centre...
      println("---");
    } 
    else {
      println("position ok");
    }
  }
}

