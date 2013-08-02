/*
Yapılacaklar
 
 parameter
 sound
 post
 preset
 
 
 presets update: transition, soundFilter base & range, camera angles 
 
 sound 'nteraction algorithm
 
 gui layout
 
 preview 
 
 */
import javax.media.opengl.GL;
import java.awt.*;
boolean removeVsync = true;
boolean vsyncset = false;

boolean midiEnable = false;
boolean midiPlugged = true;
boolean decorate = false;
boolean lightEnable = true;

float blackAlpha;
float logoAlpha;
PImage msLogo;
PImage preview;

//windows directory
//String presetDir = "C:/Users/kerim/Google Drive/djMarkusClass/presets/";
//mac directory
String presetDir = "/Users/kocosman/markusMac/presets/";

VisualEngine engines[];
int currentEngineIndex = 0;
int previousEngineIndex = 0;

void changeVisualEngine(int newIndex)
{
  if (newIndex < 0) return;
  if (newIndex >= engines.length) return;

  println("Changing to visual engine #" + newIndex);
  previousEngineIndex = currentEngineIndex;
  currentEngineIndex = newIndex;

  engines[previousEngineIndex].exit();
  engines[newIndex].start();

  for (int i = 0; i < engines.length; ++i) {
    engines[i].showGUI(i == newIndex);
  }
}  


void setup() {
  java.util.Locale.setDefault(java.util.Locale.US);
  size(1280, 1024, OPENGL);
  Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
  double displayWidth = screenSize.getWidth();
  double displayHeight = screenSize.getHeight();
  println(displayWidth);
  frame.setLocation((int)displayWidth, 0);



  frameRate(60);
  msLogo = loadImage("msLogo.png");
  engines = new VisualEngine[] {
    new Cube(this, "Cubes"), 
    new Polyface(this, "Polyface"), 
    new Deform(this, "Deform"), 
    new Soundplate(this, "Soundplate"), 
    new Vorovis(this, "Vorovis"), 
    new Splines(this, "Splines"), 
    new Wireframe(this, "Wireframe")
      //    new Particle(this, "Particles")
    };

    println("Engines length: " + engines.length);

  if (midiPlugged) {
    initializeMidi();
  }  


  initializeSoundAnalysis();
  for (VisualEngine ve: engines) {
    ve.init();
  }

  initializeGUI();
  changeVisualEngine(0);
  cursor(loadImage("cursorImg.jpg"));
  preview = createImage(width, height, HSB);
  //  noLoop();
}

void draw() {



  frame.setTitle(int(frameRate)+"fps");
  //    frame.setLocation(mouseX, 0);
  if (selectedThumbnail != selectedThumbnailPre) {
    changeVisualEngine(selectedThumbnail);
  }
  selectedThumbnailPre = selectedThumbnail;


  engines[currentEngineIndex].update();
  soundAnalysis();
  midiCalculator();

  //  loadPixels();
  //  arrayCopy(pixels, preview.pixels);
  //  preview.updatePixels();

  ////FOREGROUND
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();  
  noLights();
  specular(0);
  //  stroke(255);
  fill(0, blackAlpha);
  rect(-30, -30, 120, 120);
  tint(255, logoAlpha);
  image(msLogo,-msLogo.width/80,-msLogo.height/80,msLogo.width/40,msLogo.height/40);
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}


public void init() {
  //  if (decorate) {
  frame.removeNotify();
  frame.setUndecorated(true); // works.
  frame.addNotify();
  //  }
  // call PApplet.init() to take care of business
  super.init();
}

