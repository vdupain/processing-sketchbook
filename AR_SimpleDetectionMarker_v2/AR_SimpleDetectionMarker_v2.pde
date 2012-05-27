// Processing 1.5.1 + NyARToolkit 1.1.6 + GSVideo 1.0

import java.io.*; // for the loadPatternFilenames() function
import processing.opengl.*; // for OPENGL rendering
import jp.nyatla.nyar4psg.*; // the NyARToolkit Processing library
import codeanticode.gsvideo.*; // the GSVideo library


//----- chemin absolu fichier de paramètres de distorsion de la camera ----
String camParaPath = "/Users/vince/Dev/Arduino/NyAR4psg/data/camera_para.dat";
//----- chemin absolu fichiers de description des "patterns" ou "markers" ----
String patternPath = "/Users/vince/Dev/patternMaker/examples/ARToolKit_Patterns";


MultiMarker nya;
GSCapture cam;

PImage imgSrc, imgAR; // Objets PImages utiles

//--- taille de l'image webcam --- 
int widthCapture= 640; 
int heightCapture=480; 

//--- taille de l'image à utiliser pour la détection = plus petite pour plus rapide ---
int widthAR= 640; 
int heightAR=480; 

int numMarkers = 3; // le nombre de pattern markers à utiliser 
String[] nameMarkers= new String[numMarkers]; // pour mémoriser le nom des marker

float displayScale; // échelle d'affichage

// XXXXXXXXXXXXXXXXXXXXXX  Fonction SETUP XXXXXXXXXXXXXXXXXXXXXX 

void setup() { // fonction d'initialisation exécutée 1 fois au démarrage

  // ---- initialisation paramètres graphiques utilisés
  colorMode(RGB, 255, 255, 255); // fixe format couleur R G B pour fill, stroke, etc...
  fill(0, 0, 255); // couleur remplissage RGB - noFill() si pas de remplissage
  stroke (0, 0, 0); // couleur pourtour RGB - noStroke() si pas de pourtour
  rectMode(CORNER); // origine rectangle : CORNER = coin sup gauche | CENTER : centre 
  imageMode(CORNER); // origine image : CORNER = coin sup gauche | CENTER : centre
  ellipseMode(CENTER); // origine cercles / ellipses : CENTER : centre (autres : RADIUS, CORNERS, CORNER
  //strokeWeight(0); // largeur pourtour
  frameRate(20);// Images par seconde - The default rate is 60 frames per second

  // --- initialisation fenêtre de base --- 
  size(widthCapture, heightCapture); // ouvre une fenêtre xpixels  x ypixels 
  background(bleu); // couleur fond fenetre

  //---- initialisation police utilisée ---- 
  textFont(createFont("Arial", 80)); // police utilisée 

  // --- initialisation des objets et fonctionnalités utilisées --- 

  //======== Initialisation Objets GSVideo (capture et/ou lecture video =========

  //GSCapture(this, int requestWidth, int requestHeight, [int frameRate], [String sourceName], [String cameraName]) 
  // cam1 = new GSCapture(this, width, height,20,"v4l2src","/dev/video0"); // Initialise objet GSCapture désignant webcam - avant GSVideo 1.0
  //cam1 = new GSCapture(this, widthCapture, heightCapture,"v4l2src","/dev/video0", 20); // Initialise objet GSCapture désignant webcam - depuis GSVideo 1.0
  cam1 = new GSCapture(this, widthCapture, heightCapture); // Initialise objet GSCapture désignant webcam - depuis GSVideo 1.0
  // largeur et hauteur doivent être compatible avec la webcam - typiquement 160x120 ou 320x240 ou 640x480...
  // NB : Framerate >=20 évite message erreur

  // cam1.play();  // démarre objet GSCapture = la webcam - version GSVideo avant 0.9
  cam1.start();  // démarre objet GSCapture = la webcam - version GSVideo après 0.9

  //pipe = new GSPipeline(this, "gnomevfssrc location=http://192.168.1.118/axis-cgi/mjpg/video.cgi?resolution=640x480 ! jpegdec ! ffmpegcolorspace"); 
  //pipe = new GSPipeline(this, "gnomevfssrc location=http://88.167.252.72:2203/video.mjpg ! jpegdec ! ffmpegcolorspace"); 
  //pipe = new GSPipeline(this, "gnomevfssrc location=http://88.167.252.72:2203/video.mjpg ! jpegdec ! ffmpegcolorspace ! autovideosink"); 
  //pipe = new GSPipeline(this, "souphttpsrc location=http://88.167.252.72:2203/video.mjpg ! jpegdec ! ffmpegcolorspace ! autovideosink"); 

  // http://88.167.252.72:2203/video.mjpg
  // "88.167.252.72:2203" tu peux l'administrer avec "admin" et "220369" 

  //=========== initialisation détection des markers =========================

  // création d'un objet MultiMarker avec résolution voulue, les paramètres caméra et le système de coordonnées voulu
  nya = new MultiMarker(this, widthAR, heightAR, camParaPath, NyAR4PsgConfig.CONFIG_DEFAULT);

  // fixe le nombre de fois qu'un marqueur ne doit plus petre détecté pour ne plus l'afficher. 
  //Par défaut = 10. Mettre à 1 pour visualisation immédiate
  nya.setLostDelay(1);

  // fixe le niveau de seuil de détection à utiliser. Valeur possible entre 0 et 255. Mettre -1 (=THLESHOLD_AUTO) pour seuil automatique 
  nya.setThreshold(MultiMarker.THLESHOLD_AUTO); 

  // fixe le niveau de seuil de confiance (= probabilité de correspondance) à utiliser pour la reconnaissance des markers. Valeur possible entre 0 et 1. 
  // Valeur par défaut = 0.51 (=.DEFAULT_CF_THRESHOLD). Plus le seuil est élevé et plus la détection est rigoureuse. 
  nya.setConfidenceThreshold(MultiMarker.DEFAULT_CF_THRESHOLD); 
  //nya.setConfidenceThreshold(0.8); // sélection exigeante 

  //-- chargement des fichiers de description des patterns 
  /*
        String[] patterns = loadPatternFilenames(patternPath); // tableau pour des noms des fichiers des pattern retrouvés dans le répertoire
   
   println ("------- Liste des fichiers trouvés ------------"); 
   
   for (int i=0; i<patterns.length; i++) { // défile le tableau des noms de fichiers 
   
   println ("" + i + ":" + patterns[i]); 
   
   } // fin for 
   */

  //--- pour charger n fichiers à la suite .. 
  //for (int i=0; i<numMarkers; i++) {

  //nya.addARMarker(patternPath + "/" + patterns[i], 80); // ajoute le fichier de description à l'objet principal de détection AR

  //} // fin for

  //--- pour chargement manuel des fichiers voulus 
  int widthMarker=135; // taille réelle du marker utilisé en mmm 
  //int sizeMarker=16; // résolution du marker - 16x16 par défaut - utiliser 16x16 
  //int borderMarker=25; // largeur du bord du marker - 25% par défaut 

  // nya.addARMarker(patternPath + "/" + patterns[40], 80); // ajoute le fichier de description à l'objet principal de détection AR
  //nameMarkers[0]= patterns[40]; // mémorise le nom du marker [i]
  nameMarkers[0]= "4x4_99.patt"; // mémorise le nom du fichier du marker voulu
  nya.addARMarker(patternPath + "/" + nameMarkers[0], widthMarker); // ajoute le fichier de description à l'objet principal de détection AR - bordure 25% et 16x16 par défaut
  //nya.addARMarker(patternPath + "/" + nameMarkers[0], sizeMarker, widthMarker); // ajoute le fichier de description à l'objet principal de détection AR - 16x16 par défaut
  //nya.addARMarker(patternPath + "/" + nameMarkers[0],sizeMarker,borderMarker, widthMarker); // ajoute le fichier de description à l'objet principal de détection AR 
  println ("Fichier chargé : " + nameMarkers[0]); 

  //nya.addARMarker(patternPath + "/" + patterns[83], 80); // ajoute le fichier de description à l'objet principal de détection AR
  //nameMarkers[1]= patterns[83]; // mémorise le nom du marker [i]
  nameMarkers[1]= "4x4_50.patt"; // mémorise le nom du fichier du marker voulu
  nya.addARMarker(patternPath + "/" + nameMarkers[1], widthMarker); // ajoute le fichier de description à l'objet principal de détection AR 
  //nya.addARMarker(patternPath + "/" + nameMarkers[1] , sizeMarker,widthMarker); // ajoute le fichier de description à l'objet principal de détection AR 
  //nya.addARMarker(patternPath + "/" + nameMarkers[1] , sizeMarker,borderMarker,widthMarker); // ajoute le fichier de description à l'objet principal de détection AR 

  println ("Fichier chargé : " + nameMarkers[1]); 

  //nya.addARMarker(patternPath + "/" + patterns[99], 80); // ajoute le fichier de description à l'objet principal de détection AR
  //nameMarkers[2]= patterns[99]; // mémorise le nom du marker [i]
  nameMarkers[2]= "4x4_83.patt"; // mémorise le nom du fichier du marker voulu
  nya.addARMarker(patternPath + "/" + nameMarkers[2], widthMarker); // ajoute le fichier de description à l'objet principal de détection AR 
  //nya.addARMarker(patternPath + "/" + nameMarkers[2], sizeMarker,widthMarker); // ajoute le fichier de description à l'objet principal de détection AR 
  //nya.addARMarker(patternPath + "/" + nameMarkers[2], sizeMarker,borderMarker,widthMarker); // ajoute le fichier de description à l'objet principal de détection AR 
  println ("Fichier chargé : " + nameMarkers[2]); 

  //noLoop();
} // fin fonction Setup

// XXXXXXXXXXXXXXXXXXXXXX Fonction Draw XXXXXXXXXXXXXXXXXXXX 

void  draw() { // fonction exécutée en boucle

  // Code type capture GSVideo - préférer utilisation de captureEvent()

  if (cam1.available() == true) { // si une nouvelle frame est disponible

      cam1.read(); // acquisition d'un frame 

    image(cam1, 0, 0); // affiche image
    //set(0, 0, cam); // plus rapide 

    println("debut="+millis()); 

    //println("seuil de binarisation actuel = " + nya.getCurrentThreshold()); 

    nya.detect(cam1); // detection des markers dans l'image à la résolution voulue 
    // l'image passée en paramètre doit avoir la même résolution que ce qui a été défini à l'initialisation du constructeur

    drawMarkers(); // dessiner les coordonnées des "markers" détectés

      //nya.drawBackground(cam1); 
    //image(cam1, 0, 0); // affiche image


    println("fin="+millis());
  } // fin if available


  /*
  if (pipe.available() == true) { // si une nouvelle frame est disponible
   pipe.read(); // acquisition d'un frame 
   image(pipe, 0, 0); // affiche image
   //set(0, 0, cam); // plus rapide 
   
   } // fin if available
   */
} // fin de la fonction draw()

// XXXXXXXXXXXXXXXXXXXXXX Autres Fonctions XXXXXXXXXXXXXXXXXXXXXX 

//---------- fonction de dessin de tous les markers détectés

void drawMarkers() {

  // paramètres affichage texte 
  textAlign(LEFT, TOP); // paramètre d'affichage du texte 
  textSize(10); // taille à utiliser pour le texte 

  // --- paramètre graphique 
  noStroke(); 

  // scale from AR detection size to sketch display size (changes the display of the coordinates, not the values)
  //scale(displayScale);

  // for all the markers...
  for (int i=0; i<numMarkers; i++) { // passe en revue les markers de référence 

    // if the marker does NOT exist (the ! exlamation mark negates it) continue to the next marker, aka do nothing
    if ((!nya.isExistMarker(i))) { 
      continue;
    } 

    // passe au marker suivant si le marker(i) n'est pas détecté

    // the following code is only reached and run if the marker DOES EXIST

    println ("Le marker " + nameMarkers[i] + " est détecté."); 

    println("seuil de confiance = " + nya.getConfidence(i)); // affiche le seuil de confiance de détection 

    // get the four marker coordinates into an array of 2D PVectors
    PVector[] pos2d = nya.getMarkerVertex2D(i);

    // draw each vector both textually and with a red dot
    for (int j=0; j<pos2d.length; j++) {

      String s = "(" + int(pos2d[j].x) + "," + int(pos2d[j].y) + ")";
      fill(255);
      rect(pos2d[j].x, pos2d[j].y, textWidth(s) + 3, textAscent() + textDescent() + 3);
      fill(0);
      text(s, pos2d[j].x + 2, pos2d[j].y + 2);
      fill(0, 0, 255);
      ellipse(pos2d[j].x, pos2d[j].y, 10, 10);
    } // fin for pos2d
  } // fin if numMarker
} // --- fin draw Markers ---



//--------- fonction loadPatternFilesnames() : charge l'ensemble des fichiers *.patt du répertoire
// this function loads .patt filenames into a list of Strings based on a full path to a directory (relies on java.io)
String[] loadPatternFilenames(String path) {

  File folder = new File(path);
  FilenameFilter pattFilter = new FilenameFilter() {

    public boolean accept(File dir, String name) {

      return name.toLowerCase().endsWith(".patt");
    }
  }; // fin filenameFilter

  return folder.list(pattFilter); // renvoi le tableau de String
} // fin loadPatternFilenames

/*
//--- évènement capture vidéo --- 
 void captureEvent(GSCapture cam) { // est appelée lorsqu'une capture survient 
 // cf doc librairie Video Processing - cf exemple Capture LivePocky
 
 // est appelée à chaque fois qu'une nouvelle frame est disponible, quelque soit la caméra
 // utiliser des conditions pour tester la caméra disponible 
 
 if (cam1.available() == true) cam1.read(); // acquisition d'une nouvelle frame 
 
 */

//------------- Fonction d'arret de Processing ---- 

public void stop() { // fonction d'arrêt de Processing

  //pipe.delete(); // efface l'objet GScapture
  cam1.delete(); 

  super.stop(); // obligatoire
} // fin fonction stop()


//XXXXXXXXXXXXXXXXXX Fin du programme XXXXXXXXXXXXXXXXX

