import processing.opengl.*;
import javax.media.opengl.*;
import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import toxi.geom.Vec2D;

int particleAmount = 250;

VerletPhysics2D physics;
AttractionBehavior mouseAttractor;
AttractionBehavior randomAttractor;
AttractionBehavior constantAttractor;

Vec2D constantVec;
Vec2D mousePos;

float colorness;

float fadeAmount = 0.;
float randomness = 0.02;
float rotAmount = 0.;
float lineLength = 1.;
float rotAng = 0.;
float sw = 0.1;
float swRand = 0.;
float constX = 0.01;
float constY = 0.01;

class Particle extends VisualEngine {

  protected Vector<controlP5.Controller> controllers;

  float localWidth = width/5;
  float localHeight = height/5;


  public Particle(PApplet myApplet, String name) {
    super(myApplet, name);
    println("Particle Constructor.");
    controllers = new Vector<controlP5.Controller>();
  }

  public void init() {
    physics = new VerletPhysics2D();
    physics.setDrag(0.01f);
    physics.setWorldBounds(new Rect(-localWidth/2, -localHeight/2, localWidth, localHeight));
    //     physics.setWorldBounds(new Rect(0,0,width,height));
    colorMode(HSB);
    smooth();
  }

  public void update() {
    if (midiEnable) {
//      midiMapDustParticles();

    }

    mapPresets();

    fill(0, 0, 0, 255*fadeAmount);
    noStroke();
    rect(0, 0, localWidth, localHeight);
    //     rect(0,0,width,height);

    noStroke();

    if (physics.particles.size() < particleAmount) {
      addParticle();
    } 
    else if (physics.particles.size() > particleAmount) {
      removeParticle();
    }
    constantVec = new Vec2D(localWidth/2+(200*sin(frameCount*constX)), localHeight/2+(200*cos(frameCount*constY)));

    createConstantAttractor();
    fill(255);
    //ellipse(constantVec.x,constantVec.y,10,10);

    physics.update();

    removeConstantAttractor();

    for (int i = 0; i < physics.particles.size(); i++) {
      VerletParticle2D p = physics.particles.get(i);
      Vec2D pPre = p.getPreviousPosition();
      //Vec2D randVel = new Vec2D(random(0.8,1.2)*randomness,random(0.8,1.2)*randomness);
      p.addVelocity(new Vec2D(random(-10, 10)*randomness, random(-10, 10)*randomness));
      colorness = dist(p.x, p.y, pPre.x, pPre.y) * 10;
      colorness = map(colorness, 0, 255, colorMin, colorMax);
      //ellipse(p.x, p.y, 5, 5);
      //p.setPreviousPosition(new Vec2D(p.x+random(0.1),p.y+random(0.1)));
      pushStyle();
      stroke(colorness, 255, 255);
      strokeWeight(sw+(random(10)*swRand));
      pushMatrix();
      //      translate(-76, -57);
      //      pushStyle();
      //      stroke(200, 200);
      //      fill(255);
      //      strokeWeight(20);
      //      point(0, 0);
      //      point(152,0);
      //      point(0, 114);
      //      point(152, 114);
      //      println(mouseX + "-" +mouseY);
      //      // ellipse(constantVec.x,constantVec.y,5,5);
      //      popStyle();
      translate(p.x, p.y);

      rotAng += rotAmount;
      rotate(rotAng);
      line(0, 0, (p.x-pPre.x)*lineLength, (p.y-pPre.y)*lineLength);
      popMatrix();
      popStyle();
    }
  }
  void addParticle() {
    VerletParticle2D p = new VerletParticle2D(Vec2D.randomVector().scale(5).addSelf(localWidth / 2, 0));
    physics.addParticle(p);
    // add a negative attraction force field around the new particle
    physics.addBehavior(new AttractionBehavior(p, 20, 0.f, 0.01f));
  }

  void removeParticle() {
    VerletParticle2D p = physics.particles.get(physics.particles.size()-1);
    physics.removeParticle(p);
  }

  void createRandomAttractor() {
    randomAttractor = new AttractionBehavior(new Vec2D(random(localWidth), random(localHeight)), 1000, 1.9f);
    physics.addBehavior(randomAttractor);
  }

  void removeRandomAttractor() {
    physics.removeBehavior(randomAttractor);
  }

  void createConstantAttractor() {
    constantAttractor = new AttractionBehavior(constantVec, 1000, base/200.);
    physics.addBehavior(constantAttractor);
  }

  void removeConstantAttractor() {
    physics.removeBehavior(constantAttractor);
  }
  public void initGUI(ControlP5 cp5, ControlWindow controlWindow) {
    cp5.addSlider("randomness")
      .setPosition(260, visualSpecificGUIOffset+50)
        .setRange(0., 0.1)
          .setSize(100, 20)
            .setWindow(controlWindow);

    cp5.getController("randomness")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    controllers.add(cp5.getController("randomness"));
    cp5.addSlider("fadeAmount")
      .setPosition(260, visualSpecificGUIOffset+20)
        .setRange(0., 1.)
          .setValue(0.8)
            .setSize(100, 20)
              .setWindow(controlWindow);

    cp5.getController("fadeAmount")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    controllers.add(cp5.getController("fadeAmount"));
    cp5.addSlider("sw")
      .setPosition(30, visualSpecificGUIOffset+110)
        .setRange(0., 10.)
          .setSize(100, 20)
            .setWindow(controlWindow);

    cp5.getController("sw")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    controllers.add(cp5.getController("sw"));
    cp5.addSlider("lineLength")
      .setPosition(30, visualSpecificGUIOffset+80)
        .setRange(1., 20.)
          .setSize(100, 20)
            .setWindow(controlWindow);

    cp5.getController("lineLength")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    controllers.add(cp5.getController("lineLength"));
    cp5.addSlider("rotAmount")
      .setPosition(260, visualSpecificGUIOffset+80)
        .setRange(0., 0.0005)
          .setSize(100, 20)
            .setWindow(controlWindow); 

    cp5.getController("rotAmount")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    controllers.add(cp5.getController("rotAmount"));
    cp5.addSlider("constX")
      .setPosition(260, visualSpecificGUIOffset+110)
        .setValue(0.001)
          .setRange(0., 0.1)
            .setSize(100, 20)
              .setWindow(controlWindow);  

    cp5.getController("constX")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    controllers.add(cp5.getController("constX"));
    cp5.addSlider("constY")
      .setPosition(260, visualSpecificGUIOffset+140)
        .setValue(0.001)
          .setRange(0., 0.1)
            .setSize(100, 20)
              .setWindow(controlWindow);            

    cp5.getController("constY")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    controllers.add(cp5.getController("constY"));
    cp5.addSlider("particleAmount")
      .setPosition(30, visualSpecificGUIOffset+20)
        .setRange(0, 500)
          .setSize(100, 20)
            .setWindow(controlWindow);    

    cp5.getController("particleAmount").getCaptionLabel().setFont(fontLight)
      .toUpperCase(false)
        .setSize(18)
          ;
    controllers.add(cp5.getController("particleAmount"));

    cp5.addSlider("swRand")
      .setPosition(30, visualSpecificGUIOffset+140)
        .setRange(0., 1.)
          .setSize(100, 20)
            .setWindow(controlWindow);  

    cp5.getController("swRand")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    controllers.add(cp5.getController("swRand"));
    cp5.addRange("colorRange")
      .setBroadcast(false) 
        .setPosition(30, visualSpecificGUIOffset+50)
          .setSize(100, 20)
            .setHandleSize(10)
              .setRange(0, 255)
                .setRangeValues(0, 255)
                  .setBroadcast(true)
                    //                  .setColorForeground(color(255, 40))
                    //                    .setColorBackground(color(255, 40))  
                    .setWindow(controlWindow)
                      ;

    cp5.getController("colorRange")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    controllers.add(cp5.getController("colorRange"));
    showGUI(false);
  }

  public void showGUI(boolean show) {
    for (controlP5.Controller c: controllers) {
      c.setVisible(show);
    }
  }

  public void controlEvent(ControlEvent theControlEvent) {
    if (theControlEvent.isFrom("colorRange")) {
      colorMin = int(theControlEvent.getController().getArrayValue(0));
      colorMax = int(theControlEvent.getController().getArrayValue(1));
    }
  }
  public float[] loadPreset(String dir, String name, int presetNumber){return null;}
  public void savePreset(String dir, String name, int presetNumber, float[] params){}
  public void mapPresets(){}
  
  public void mapMidiInterface(){
  
  }
  public void start() {
    println("Starting " + name);
  }

  public void exit() {
    println("Exitting " + name);
  }
}

