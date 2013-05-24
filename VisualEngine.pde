import java.util.Vector;

abstract class VisualEngine {

  protected PApplet myApplet;
  protected String name;
  protected PImage thumbnail;
  
  public VisualEngine(PApplet myApplet, String name) {
    this.myApplet = myApplet;
    this.name = name;
    this.thumbnail = loadImage(name + ".jpg");
  }
  
  public abstract void init();
  public abstract void start();
  public abstract void update();
  
  public abstract void initGUI(ControlP5 cp5, ControlWindow controlWindow);
  public abstract void showGUI(boolean show);
  public abstract void controlEvent(ControlEvent theControlEvent);
  public abstract void exit();
  public abstract float[] loadPreset(String dir, String name, int presetNumber);
  public abstract void savePreset(String dir, String name, int presetNumber, float[] params);
  public abstract void mapPresets();
} 

