/*
Yapılacaklar
 
 parameter
 sound
 post
 preset
 
 
// circleRad = 100
// buna göre tüm parametreleri update et
 
// rotationlar genelde iki yönlü olsun 
 
// FOG??
 
// küplerin hareketi perlin noise
// ışık toparla
 
// genel rotation düzelt rotSpeed
// kendi ekseni etrafındaki dönüşün rotation hızı parametresi
 
 dışarıdaki çizgilerin ışıktan etkilenmesi
 Visual Engine exit functions 
 farklı kamera açısı presetleri + free running mode 


 sound filter mouse interaction exceptions
 ışıkları kameraya bağla
  
 Presets: load,save,transition 
   visual specific parameters
   sound parameters
   filter base & range
 
 
 particle forces update
 
 */

boolean midiEnable = false;
boolean decorate = false;
boolean lightEnable = true;


//windows directory
//String presetDir = "C:/Users/kerim/Google Drive/djMarkusClass/presets/";
//mac directory
String presetDir = "/Users/kocosman/Documents/Processing/djMarkusClass/presets/";

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
  //  engines[currentEngineIndex].init();

    engines[previousEngineIndex].exit();
    engines[newIndex].start();

  for (int i = 0; i < engines.length; ++i) {
    engines[i].showGUI(i == newIndex);
  }
  
}


void setup() {
  java.util.Locale.setDefault(java.util.Locale.US);
  size(1680, 1050, OPENGL);
  frame.setLocation(1366, 0);
  frameRate(60);

  engines = new VisualEngine[] {
    new Cube(this, "Cubes"), 
    new Particle(this, "Particles")
    };

    if (midiEnable) {
      initializeMidi();
    }  


  initializeSoundAnalysis();
  for (VisualEngine ve: engines) {
    ve.init();
  }

  initializeGUI();
  changeVisualEngine(0);
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



