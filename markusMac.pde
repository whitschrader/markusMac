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

boolean midiEnable = false;
boolean decorate = false;
boolean lightEnable = true;


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
  size(1680, 1050, OPENGL);
  frame.setLocation(1680, 0);
  frameRate(60);

  engines = new VisualEngine[] {
    new Cube(this, "Cubes"), 
    new Polyface(this, "Polyface"),
    new Particle(this, "Particles")
    };

  println("Engines length: " + engines.length);

    if (midiEnable) {
      initializeMidi();
    }  


  initializeSoundAnalysis();
  for (VisualEngine ve: engines) {
    ve.init();
  }

  initializeGUI();
  changeVisualEngine(1);
  
  noCursor();
  
}

void draw() {
  frame.setTitle(int(frameRate)+"fps");
  
  engines[currentEngineIndex].update();

  soundAnalysis();
}


public void init() {
  if (decorate) {
    frame.removeNotify();
    frame.setUndecorated(true); // works.
    frame.addNotify();
  }
  // call PApplet.init() to take care of business
  super.init();
}




