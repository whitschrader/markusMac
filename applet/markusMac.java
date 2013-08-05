import processing.core.*; 
import processing.xml.*; 

import javax.media.opengl.GL; 
import java.awt.*; 
import processing.opengl.*; 
import peasy.*; 
import hardcorepawn.fog.*; 
import controlP5.*; 
import processing.opengl.*; 
import javax.media.opengl.*; 
import toxi.geom.*; 
import toxi.physics2d.*; 
import toxi.physics2d.behaviors.*; 
import toxi.geom.Vec2D; 
import megamu.mesh.*; 
import promidi.*; 
import pitaru.sonia_v2_9.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class markusMac extends PApplet {

/*
Yap\u0131lacaklar
 
 parameter
 sound
 post
 preset
 
 
 presets update: transition, soundFilter base & range, camera angles 
 
 sound 'nteraction algorithm
 
 gui layout
 
 preview 
 
 */


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

public void changeVisualEngine(int newIndex)
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


public void setup() {
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
    new Cube(this, "CUBES"), 
    new Polyface(this, "POLYFACE"), 
    new Deform(this, "DEFORM"), 
    new Soundplate(this, "SOUNDPLATE"), 
    new Vorovis(this, "VOROVIS"), 
    new Splines(this, "SPLINES"), 
    new Wireframe(this, "WIREFRAME")
      //    new Particle(this, "Particles")
    };

    println("Engines length: " + engines.length);

  if (midiPlugged) {
    initializeMidi();
  }  

  initializeGUI();

  initializeSoundAnalysis();
  for (VisualEngine ve: engines) {
    ve.init();
  }

  changeVisualEngine(2);
  cursor(loadImage("cursorImg.jpg"));
  preview = createImage(width, height, HSB);
  //  noLoop();
}

public void draw() {



  frame.setTitle(PApplet.parseInt(frameRate)+"fps");
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
  image(msLogo, -msLogo.width/80, -msLogo.height/80, msLogo.width/40, msLogo.height/40);
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




PeasyCam cam;



fog myFog;

float nearDist;
float farDist; 
int fogColor;

PImage bg;
PImage f;
float cubeAmount = 50;
//float cubeColorMin;
//float cubeColorMax;

float cubeSizeOffsetX = 10;
float cubeSizeOffsetY = 10;
float cubeSizeOffsetZ = 10;

float cubeSizeVarianceX;
float cubeSizeVarianceY;
float cubeSizeVarianceZ;

float outlineStroke;
float outlineLength;
float outlineColor;
float outlineScale;
float rotSpeedX = 0.f;
float rotSpeedY = 0.f;

float rotVariance;
float rotSelf = 0.f;
float rotLimit = 2.f;
float cubeCircleRad = 300.f;
boolean cubeRotStopX = false;
boolean cubeRotStopY = false;


boolean fogEnable = false;

class Cube extends VisualEngine {

  protected ArrayList<controlP5.Controller> controllers;
  String[] parameterNames = { 
    "cubeAmount", 
    "cubeSizeOffsetX", 
    "cubeSizeOffsetY", 
    "cubeSizeOffsetZ", 
    "outlineStroke", 
    "rotLimit", 
    "rotVariance", 
    "rotSpeedY", 
    "cubeSizeVarianceX", 
    "cubeSizeVarianceY", 
    "cubeSizeVarianceZ", 
    "outlineColor", 
    "outlineScale", 
    "rotSelf", 
    "cubeRotStopX", 
    "rotSpeedX", 
    "cubeRotStopY"
  };

  int presetSize = parameterNames.length+9;

  float[] parameters1 = new float[presetSize];
  float[] parameters2 = new float[presetSize];
  float[] parameters3 = new float[presetSize];
  float[] parameters4 = new float[presetSize];
  float[] parameters5 = new float[presetSize];
  float[] parameters6 = new float[presetSize];
  float[] parameters7 = new float[presetSize];
  float[] parameters8 = new float[presetSize];
  float[] parametersTemp = new float[presetSize];
  //  float[] parametersTemp = new float[presetSize];
  //  float[] parametersTemp = new float[presetSize];

  float[] camRotations = new float[3];
  float[] camLookAt = new float[3];
  public float camDistance;

  public Cube(PApplet myApplet, String name) {
    super(myApplet, name);
    println("Cube Constructor.");
    controllers = new ArrayList<controlP5.Controller>();
  }

  public void init() {
    cam = new PeasyCam(myApplet, 50);
    cam.setMinimumDistance(1);
    cam.setMaximumDistance(5000000);
    background(0);
    perspective(PI/3, width/height, 1, 5000000);
    bg = loadImage("cubesBG.jpg");
    f = loadImage("cfp.png");
    smooth();
    if (fogEnable) {
      myFog=new fog(myApplet);
      nearDist=90;
      farDist=300;
      myFog.setupFog(nearDist, farDist);
      fogColor=color(0);
      myFog.setColor(fogColor);
    }

    parameters1 =     loadPreset(presetDir, name, 1);
    parameters2 =     loadPreset(presetDir, name, 2);
    parameters3 =     loadPreset(presetDir, name, 3);
    parameters4 =     loadPreset(presetDir, name, 4);
    parameters5 =     loadPreset(presetDir, name, 5);
    parameters6 =     loadPreset(presetDir, name, 6);
    parameters7 =     loadPreset(presetDir, name, 7);
    parameters8 =     loadPreset(presetDir, name, 8);
    cp5.getController("preset5").setValue(1.f);
  }

  public void initGUI(ControlP5 cp5, ControlWindow controlWindow) {

    int cubeGUISep = 45;

    int[] parameterMatrix = {
      7, 6, 1
    };    

    PVector[][] parameterPos = new PVector[parameterMatrix.length][max(parameterMatrix)]; 
    PVector[] parameterSize = new PVector[parameterMatrix.length]; 

    for (int i = 0; i < parameterMatrix.length; i++) {
      for (int j = 0; j < parameterMatrix[i]; j++) {
        parameterPos[i][j] = new PVector(visualSpecificParametersBoxX-10 + (visualSpecificParametersBoxWidth/(parameterMatrix[i]*2)*(j*2+1)), visualSpecificParametersBoxY +(visualSpecificParametersBoxHeight/(parameterMatrix.length*2)*(i*2+1)));
        parameterSize[i] = new PVector((visualSpecificParametersBoxWidth/parameterMatrix[i])-cubeGUISep, (visualSpecificParametersBoxHeight/parameterMatrix.length)-cubeGUISep);
        noStroke();
        fill(127);
        rectMode(CORNER);
      }
    }

    cp5.addKnob("rotLimit")
      .setPosition(knobPosX[0]+visualSpecificParametersBoxX-knobWidth, knobPosY[0]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(0.f, 4.f)
            .setViewStyle(Knob.ARC)
              .setColorValueLabel(valueLabel)
                .setCaptionLabel("SELF ROTATION LIMIT")
                  .setWindow(controlWindow);

    cp5.addKnob("rotSelf")
      .setPosition(knobPosX[1]+visualSpecificParametersBoxX-knobWidth, knobPosY[1]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(-2.f, 2.f)
            .setColorValueLabel(valueLabel)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("SELF ROTATION SPEED")
                  .setWindow(controlWindow);

    cp5.addKnob("rotVariance")
      .setPosition(knobPosX[2]+visualSpecificParametersBoxX-knobWidth, knobPosY[2]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(0.f, 30.f)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("SHAPE DISTORTION")
                  .setWindow(controlWindow);
    cp5.addKnob("rotSpeedX")
      .setPosition(knobPosX[3]+visualSpecificParametersBoxX-knobWidth, knobPosY[3]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(-1.f, 1.f)
              .setViewStyle(Knob.ARC)        
                .setCaptionLabel("VERTICAL ROTATION")
                  .setWindow(controlWindow);
    cp5.addKnob("rotSpeedY")
      .setPosition(knobPosX[4]+visualSpecificParametersBoxX-knobWidth, knobPosY[4]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(-1.f, 1.f)
            .setColorValueLabel(valueLabel)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("HORIZONTAL ROTATION")
                  .setWindow(controlWindow);

    cp5.addKnob("outlineStroke")
      .setPosition(knobPosX[5]+visualSpecificParametersBoxX-knobWidth, knobPosY[5]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(0.f, 255.f)
            .setColorValueLabel(valueLabel)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("OUTLINE TRANSPARENCY")
                  .setWindow(controlWindow);

    cp5.addKnob("outlineColor")
      .setPosition(knobPosX[6]+visualSpecificParametersBoxX-knobWidth, knobPosY[6]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(0.f, 255.f)
            .setColorValueLabel(valueLabel)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("OUTLINE COLOR")
                  .setWindow(controlWindow);

    cp5.addKnob("outlineScale")
      .setPosition(knobPosX[7]+visualSpecificParametersBoxX-knobWidth, knobPosY[7]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(0.f, 1.f)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("OUTLINE LENGTH")
                  .setWindow(controlWindow);

    cp5.addSlider("cubeAmount")
      .setPosition(sliderPosX[0]+visualSpecificParametersBoxX, sliderPosY[0]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(1, 250)
            .setCaptionLabel("CUBE AMOUNT")
              .setWindow(controlWindow);
  cp5.getController("cubeAmount").captionLabel().getStyle().marginLeft = -20;

    cp5.addSlider("cubeSizeOffsetX")
      .setPosition(sliderPosX[1]+visualSpecificParametersBoxX, sliderPosY[1]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.1f, cubeCircleRad*6/10)
            .setCaptionLabel("SIZE OFFSET X")
              .setWindow(controlWindow);
  cp5.getController("cubeSizeOffsetX").captionLabel().getStyle().marginLeft = -18;

    cp5.addSlider("cubeSizeOffsetY")
      .setPosition(sliderPosX[2]+visualSpecificParametersBoxX, sliderPosY[2]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.1f, cubeCircleRad*6/10)
            .setCaptionLabel("SIZE OFFSET Y")
              .setWindow(controlWindow);
  cp5.getController("cubeSizeOffsetY").captionLabel().getStyle().marginLeft = -18;

    cp5.addSlider("cubeSizeOffsetZ")
      .setPosition(sliderPosX[3]+visualSpecificParametersBoxX, sliderPosY[3]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.1f, cubeCircleRad*6/10)
            .setCaptionLabel("SIZE OFFSET Z")
              .setWindow(controlWindow);
  cp5.getController("cubeSizeOffsetZ").captionLabel().getStyle().marginLeft = -18;

    cp5.addSlider("cubeSizeVarianceX")
      .setPosition(sliderPosX[4]+visualSpecificParametersBoxX, sliderPosY[4]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.1f, cubeCircleRad*6/10)
            .setCaptionLabel("SIZE VARIANCE X")
              .setWindow(controlWindow);
  cp5.getController("cubeSizeVarianceX").captionLabel().getStyle().marginLeft = -25;

    cp5.addSlider("cubeSizeVarianceY")
      .setPosition(sliderPosX[5]+visualSpecificParametersBoxX, sliderPosY[5]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.1f, cubeCircleRad*6/10)
            .setCaptionLabel("SIZE VARIANCE Y")
              .setWindow(controlWindow);
  cp5.getController("cubeSizeVarianceY").captionLabel().getStyle().marginLeft = -25;

    cp5.addSlider("cubeSizeVarianceZ")
      .setPosition(sliderPosX[6]+visualSpecificParametersBoxX, sliderPosY[6]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.1f, cubeCircleRad*6/10)
            .setCaptionLabel("SIZE VARIANCE Z")
              .setWindow(controlWindow);
  cp5.getController("cubeSizeVarianceZ").captionLabel().getStyle().marginLeft = -25;

    cp5.addToggle("cubeRotStopX")
      .setPosition(mRectPosX[0]+visualSpecificParametersBoxX, mRectPosY[0]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setCaptionLabel("STOP VERTICAL\n    ROTATION")
              .setWindow(controlWindow);
  cp5.getController("cubeRotStopX").captionLabel().getStyle().marginLeft = -20;
  
    cp5.addToggle("cubeRotStopY")
      .setPosition(mRectPosX[1]+visualSpecificParametersBoxX, mRectPosY[1]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setCaptionLabel("STOP HORIZONTAL\n      ROTATION")
              .setWindow(controlWindow);            
  cp5.getController("cubeRotStopY").captionLabel().getStyle().marginLeft = -28;


    for (int i = 0; i < parameterNames.length; i++) {
      cp5.getController(parameterNames[i])
        .getCaptionLabel()
          .setFont(fontLight) 
            //            .toUpperCase(false)
            .setSize(15);
      controllers.add(cp5.getController(parameterNames[i]));
    }

    showGUI(false);
  }

  float rX = 0;  // rotateX incrementer
  float rS = 0;  // rotSpeed incrementer

  public void update() {
    if (midiEnable) {
      mapMidiInterface();
    }

    mapPresets();
    colorMode(HSB);
    background(0, 0, 20);
    noLights();
    if (lightEnable) {
      lightSetting();
    } 

    if (!cubeRotStopX) {
      cam.rotateX(rotSpeedX*0.05f);
    } 
    if (!cubeRotStopY) {
      cam.rotateY(rotSpeedY*0.05f);
    } 



    rX += rotSelf*0.01f;

    for (int i = 0; i < (int)cubeAmount; i++) {
      pushMatrix();
      translate(cubeCircleRad*sin(map(i, 0, cubeAmount, 0, 2*PI)+rS), rotVariance*sin((frameCount*0.01f)+map(i, 0, cubeAmount, 0, 4*PI)), rotVariance*3*cos((frameCount*0.01f)+map(i, 0, cubeAmount, 0, 4*PI))+cubeCircleRad*cos(map(i, 0, cubeAmount, 0, 2*PI)+rS));
      float angle = newNoise((float)i/50, rX, 0) * TWO_PI*rotLimit; //newNoise is smoother

      rotateX(angle);
      rectMode(CENTER);
      pushStyle();
      fill(0, 255, 255);
      noStroke();

      outlineLength         = soundLPFBuf[PApplet.parseInt(i*spectrumLength/(int)cubeAmount)]*gain;

      box(cubeSizeOffsetX+cubeSizeVarianceX*(sin((frameCount*0.01f)+map(i, 0, cubeAmount, 4*PI, 0))), cubeSizeOffsetY + outlineLength* 10+cubeSizeVarianceY*(sin((frameCount*0.01f)+map(i, 0, cubeAmount, 4*PI, 0))), cubeSizeOffsetZ+cubeSizeVarianceZ*(sin((frameCount*0.01f)+map(i, 0, cubeAmount, 4*PI, 0))));
      popStyle();

      pushStyle();
      //      stroke(map(i, 0, cubeAmount, cubeColorMin, cubeColorMax), 255, 255, outlineStroke);
      stroke(map(abs(i-(cubeAmount/2)), 0, cubeAmount/2, 0, 100)+outlineColor, 255, 255, outlineStroke);
      if (outlineStroke<2.f)noStroke();
      noFill();
      pushMatrix();
      rotateY(PI/2);
      strokeWeight(2);  
      float lineSizeX = cubeSizeOffsetY+cubeSizeVarianceY;
      float lineSizeY = cubeSizeOffsetZ+cubeSizeVarianceZ;
      line(-lineSizeX, -lineSizeY, -lineSizeX, -lineSizeY+(lineSizeY*outlineScale*outlineLength));
      line(-lineSizeX, lineSizeY, -lineSizeX+(lineSizeX*outlineScale*outlineLength), lineSizeY);
      line(lineSizeX, -lineSizeY, lineSizeX-(lineSizeX*outlineScale*outlineLength), -lineSizeY);  
      line(lineSizeX, lineSizeY, lineSizeX, lineSizeY-(lineSizeY*outlineScale*outlineLength));
      popMatrix();
      popStyle();

      popMatrix();
    }

    if (fogEnable)
      myFog.doFog();

    //    hint(DISABLE_DEPTH_TEST);
    //    noLights();
    //    cam.beginHUD();  
    //    //tint();
    //    //image(f, 0, 0, width, height);
    //    cam.endHUD();
    //    hint(ENABLE_DEPTH_TEST);
  }

  public void lightSetting() {

    stroke(255);
    strokeWeight(20);

    float hLimit = (PI/3)*cam.getPosition()[2];

    lightSpecular(0, 0, 255);
    shininess(255);
    specular(255);
    //    pointLight(0, 255, 255, // Color
    //    200, 0, 0); // Position
    //    point(2000, 0, 0);
    //    directionalLight(255, 0, 50, 0, -1, -1);
    //    directionalLight(255, 0, 50, 1, 0, 0); 
    ambientLight(0, 255, 20);
    int lightY = 250;
    int lightYBr = 100;
    int lightYCon = 5;

    spotLight(255, 0, 200, // Color
    (cubeCircleRad+500), 0, 0, // Position
    -1, 0, 0, // Direction
    PI, lightYCon); // Angle, concentration
    //    point((cubeCircleRad+500), 0, 0);
    //    } else if ( key == 'e') {

    spotLight(255, 0, 100, // Color
    -(cubeCircleRad+500), 0, 0, // Position
    1, 0, 0, // Direction
    PI, lightYCon); // Angle, concentration
    //    point(-(cubeCircleRad+500), 0, 0);

    //    } else if ( key == 'r') {
    spotLight(255, 0, 150, // Color
    0, 0, (cubeCircleRad+500), // Position
    0, 0, -1, // Direction
    PI, lightYCon); // Angle, concentration
    //    point(0, 0, (cubeCircleRad+500));
    //    } else if ( key == 't') {

    spotLight(255, 0, 50, // Color
    0, 0, -(cubeCircleRad+500), // Position
    0, 0, 1, // Direction
    PI, lightYCon); // Angle, concentration
    //    point(0, 0, -(cubeCircleRad+500));

    //}
  }


  public void showGUI(boolean show) {
    for (controlP5.Controller c: controllers) {
      c.setVisible(show);
    }
  }

  public void controlEvent(ControlEvent theControlEvent) {
    //    if (theControlEvent.isFrom("cubeColor")) {
    //      cubeColorMin = int(theControlEvent.getController().getArrayValue(0));
    //      cubeColorMax = int(theControlEvent.getController().getArrayValue(1));
    //    }
  }


  public void mapPresets() {

    if (preset1 && !preset1Pre) {
      presetIndex = 1;
      parameters1 =     loadPreset(presetDir, name, 1);
      cam.lookAt(parameters1[0], parameters1[1], parameters1[2]);
      cam.setRotations(parameters1[3], parameters1[4], parameters1[5]);
      cam.setDistance(parameters1[6]);
      cp5.getController("gain").setValue(parameters1[7]);
      cp5.getController("decay").setValue(parameters1[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters1[i]);
      }
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset2 && !preset2Pre) {
      presetIndex = 2;
      parameters2 =     loadPreset(presetDir, name, 2);
      cam.lookAt(parameters2[0], parameters2[1], parameters2[2]);
      cam.setRotations(parameters2[3], parameters2[4], parameters2[5]);
      cam.setDistance(parameters2[6]);
      cp5.getController("gain").setValue(parameters2[7]);
      cp5.getController("decay").setValue(parameters2[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters2[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset3 && !preset3Pre) {
      presetIndex = 3;
      parameters3 =     loadPreset(presetDir, name, 3);
      cam.lookAt(parameters3[0], parameters3[1], parameters3[2]);
      cam.setRotations(parameters3[3], parameters3[4], parameters3[5]);
      cam.setDistance(parameters3[6]);
      cp5.getController("gain").setValue(parameters3[7]);
      cp5.getController("decay").setValue(parameters3[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters3[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset4 && !preset4Pre) {
      presetIndex = 4;
      parameters4 =     loadPreset(presetDir, name, 4);
      cam.lookAt(parameters4[0], parameters4[1], parameters4[2]);
      cam.setRotations(parameters4[3], parameters4[4], parameters4[5]);
      cam.setDistance(parameters4[6]);
      cp5.getController("gain").setValue(parameters4[7]);
      cp5.getController("decay").setValue(parameters4[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters4[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset5 && !preset5Pre) {
      presetIndex = 5;
      parameters5 =     loadPreset(presetDir, name, 5);
      cam.lookAt(parameters5[0], parameters5[1], parameters5[2]);
      cam.setRotations(parameters5[3], parameters5[4], parameters5[5]);
      cam.setDistance(parameters5[6]);
      cp5.getController("gain").setValue(parameters5[7]);
      cp5.getController("decay").setValue(parameters5[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters5[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset6 && !preset6Pre) {
      presetIndex = 6;
      parameters6 =     loadPreset(presetDir, name, 6);
      cam.lookAt(parameters6[0], parameters6[1], parameters6[2]);
      cam.setRotations(parameters6[3], parameters6[4], parameters6[5]);
      cam.setDistance(parameters6[6]);
      cp5.getController("gain").setValue(parameters6[7]);
      cp5.getController("decay").setValue(parameters6[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters6[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset7 && !preset7Pre) {
      presetIndex = 7;
      parameters7 =     loadPreset(presetDir, name, 7);
      cam.lookAt(parameters7[0], parameters7[1], parameters7[2]);
      cam.setRotations(parameters7[3], parameters7[4], parameters7[5]);
      cam.setDistance(parameters7[6]);
      cp5.getController("gain").setValue(parameters7[7]);
      cp5.getController("decay").setValue(parameters7[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters7[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset8 && !preset8Pre) {
      presetIndex = 8;
      parameters8 =     loadPreset(presetDir, name, 8);
      cam.lookAt(parameters8[0], parameters8[1], parameters8[2]);
      cam.setRotations(parameters8[3], parameters8[4], parameters8[5]);
      cam.setDistance(parameters8[6]);
      cp5.getController("gain").setValue(parameters8[7]);
      cp5.getController("decay").setValue(parameters8[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters8[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
    } 
    else if ( savePreset && !savePresetPre) {
      parametersTemp[0] = cam.getLookAt()[0];
      parametersTemp[1] = cam.getLookAt()[1];
      parametersTemp[2] = cam.getLookAt()[2];
      parametersTemp[3] = cam.getRotations()[0];
      parametersTemp[4] = cam.getRotations()[1];
      parametersTemp[5] = cam.getRotations()[2];
      parametersTemp[6] = (float)cam.getDistance();
      parametersTemp[7] = cp5.getController("gain").getValue();
      parametersTemp[8] = cp5.getController("decay").getValue();
      for (int i = 9; i < presetSize; i++) {
        parametersTemp[i] = cp5.getController(parameterNames[i-9]).getValue();
      }
      savePreset(presetDir, name, presetIndex, parametersTemp) ;
    } 
    else if ((!preset1 && !preset2 && !preset3 && !preset4 && !preset5 && !preset6 && !preset7 && !preset8)) {
      presetIndex = 0;
    }

    preset1Pre = preset1;
    preset2Pre = preset2;
    preset3Pre = preset3;
    preset4Pre = preset4;
    preset5Pre = preset5;
    preset6Pre = preset6;
    preset7Pre = preset7;
    preset8Pre = preset8;    
    savePresetPre = savePreset;
  }

  public void mapMidiInterface() { 
    cp5.getController("cubeAmount").setValue(cp5.getController("cubeAmount").getValue()+(map(                      faderValDiff[0], 0, 127, 0, cp5.getController("cubeAmount").getMax()-cp5.getController("cubeAmount").getMin())));
    cp5.getController("cubeSizeOffsetX").setValue(cp5.getController("cubeSizeOffsetX").getValue()+(map(            faderValDiff[1], 0, 127, 0, cp5.getController("cubeSizeOffsetX").getMax()-cp5.getController("cubeSizeOffsetX").getMin())));
    cp5.getController("cubeSizeOffsetY").setValue(cp5.getController("cubeSizeOffsetY").getValue()+(map(            faderValDiff[2], 0, 127, 0, cp5.getController("cubeSizeOffsetY").getMax()-cp5.getController("cubeSizeOffsetY").getMin())));
    cp5.getController("cubeSizeOffsetZ").setValue(cp5.getController("cubeSizeOffsetZ").getValue()+(map(            faderValDiff[3], 0, 127, 0, cp5.getController("cubeSizeOffsetZ").getMax()-cp5.getController("cubeSizeOffsetZ").getMin())));
    cp5.getController("cubeSizeVarianceX").setValue(cp5.getController("cubeSizeVarianceX").getValue()+(map(        faderValDiff[4], 0, 127, 0, cp5.getController("cubeSizeVarianceX").getMax()-cp5.getController("cubeSizeVarianceX").getMin())));
    cp5.getController("cubeSizeVarianceY").setValue(cp5.getController("cubeSizeVarianceY").getValue()+(map(        faderValDiff[5], 0, 127, 0, cp5.getController("cubeSizeVarianceY").getMax()-cp5.getController("cubeSizeVarianceY").getMin())));
    cp5.getController("cubeSizeVarianceZ").setValue(cp5.getController("cubeSizeVarianceZ").getValue()+(map(        faderValDiff[6], 0, 127, 0, cp5.getController("cubeSizeVarianceZ").getMax()-cp5.getController("cubeSizeVarianceZ").getMin())));
    cp5.getController("outlineStroke").setValue(cp5.getController("outlineStroke").getValue()+(map(                knobValDiff[5], 0, 127, 0, cp5.getController("outlineStroke").getMax()-cp5.getController("outlineStroke").getMin())));
    cp5.getController("outlineColor").setValue(cp5.getController("outlineColor").getValue()+(map(                  knobValDiff[6], 0, 127, 0, cp5.getController("outlineColor").getMax()-cp5.getController("outlineColor").getMin())));
    cp5.getController("outlineScale").setValue(cp5.getController("outlineScale").getValue()+(map(                  knobValDiff[7], 0, 127, 0, cp5.getController("outlineScale").getMax()-cp5.getController("outlineScale").getMin())));
    cp5.getController("rotVariance").setValue(cp5.getController("rotVariance").getValue()+(map(                    knobValDiff[2], 0, 127, 0, cp5.getController("rotVariance").getMax()-cp5.getController("rotVariance").getMin())));
    cp5.getController("rotSpeedX").setValue(cp5.getController("rotSpeedX").getValue()+(map(                          knobValDiff[3], 0, 127, 0, cp5.getController("rotSpeedX").getMax()-cp5.getController("rotSpeedX").getMin())));
    cp5.getController("rotSpeedY").setValue(cp5.getController("rotSpeedY").getValue()+(map(                          knobValDiff[4], 0, 127, 0, cp5.getController("rotSpeedY").getMax()-cp5.getController("rotSpeedY").getMin())));
    cp5.getController("rotLimit").setValue(cp5.getController("rotLimit").getValue()+(map(                          knobValDiff[0], 0, 127, 0, cp5.getController("rotLimit").getMax()-cp5.getController("rotLimit").getMin())));
    cp5.getController("rotSelf").setValue(cp5.getController("rotSelf").getValue()+(map(                            knobValDiff[1], 0, 127, 0, cp5.getController("rotSelf").getMax()-cp5.getController("rotSelf").getMin())));

    cp5.getController("cubeRotStopX").setValue((cp5.getController("cubeRotStopX").getValue()+abs(buttonsMValDiff[0]))%2);
    cp5.getController("cubeRotStopY").setValue((cp5.getController("cubeRotStopY").getValue()+abs(buttonsMValDiff[8]))%2);
  }

  public void start() {
    println("Starting " + name);
    hint(ENABLE_DEPTH_TEST);
    colorMode(HSB);
    cam.lookAt(camLookAt[0], camLookAt[1], camLookAt[2]);
    cam.setRotations(camRotations[0], camRotations[1], camRotations[2]);
    cam.setDistance(camDistance);
  }

  public void exit() {
    println("Exitting " + name);

    specular(0);

    //    getCamMatrix(camLookAt, camRotations, camDistance);  

    camLookAt[0] = cam.getLookAt()[0];
    camLookAt[1] = cam.getLookAt()[1];
    camLookAt[2] = cam.getLookAt()[2];

    camRotations[0] = cam.getRotations()[0];
    camRotations[1] = cam.getRotations()[1];
    camRotations[2] = cam.getRotations()[2];

    camDistance = (float)cam.getDistance();

    println("CUBES CAM");
    println(camLookAt);
    println(camRotations);
    println(camDistance);
    //    noLights();
  }
}

int dotsPerCircle = 80;
int circleAmount = 80;

float tet = TWO_PI / dotsPerCircle;
float phi = PI / circleAmount;
dotCircle[] dc = new dotCircle[circleAmount];


float m1 = 2;
float n11 = 18;
float n12 = 1;
float n13 = 1;
float m2 = 2;
float n21 = 18;
float n22 = 1;
float n23 = 1;
boolean linesEnable = false;
boolean facesEnable = true;
float linesAlfa = 255;
float facesAlfa = 255;
float deformRotX;
float deformRotY;
boolean deformRotStopX = false;
boolean deformRotStopY = false;
float posTemp;
float posMin = 1000.f;
float posMax = 0.f;

class Deform extends VisualEngine {
  protected ArrayList<controlP5.Controller> controllers;

  String[] parameterNames = { 
    "m1", 
    "n11", 
    "n12", 
    "n13", 
    "m2", 
    "n21", 
    "n22", 
    "n23", 
    "linesEnable", 
    "facesEnable", 
    "deformRotX", 
    "deformRotY", 
    "linesAlfa", 
    "facesAlfa", 
    "deformRotStopX", 
    "deformRotStopY"
  };

  int presetSize = parameterNames.length+9;

  float[] parameters1 = new float[presetSize];
  float[] parameters2 = new float[presetSize];
  float[] parameters3 = new float[presetSize];
  float[] parameters4 = new float[presetSize];
  float[] parameters5 = new float[presetSize];
  float[] parameters6 = new float[presetSize];
  float[] parameters7 = new float[presetSize];
  float[] parameters8 = new float[presetSize];
  float[] parametersTemp = new float[presetSize];

  float[] camRotations = new float[3];
  float[] camLookAt = new float[3];
  public float camDistance;

  PImage tex;

  public Deform(PApplet myApplet, String name) {
    super(myApplet, name);
    println("Deform Constructor.");
    controllers = new ArrayList<controlP5.Controller>();
  }

  public void init() {
    cam = new PeasyCam(myApplet, 50);
    cam.setMinimumDistance(1);
    cam.setMaximumDistance(5000000);
    background(0);
    perspective(PI/3, width/height, 1, 5000000);
    for (int i = 0; i<circleAmount;i++) {
      dc[i] = new dotCircle(dotsPerCircle, i);
    }
    colorMode(RGB);
    hint(ENABLE_DEPTH_TEST);
    parameters1 =     loadPreset(presetDir, name, 1);
    parameters2 =     loadPreset(presetDir, name, 2);
    parameters3 =     loadPreset(presetDir, name, 3);
    parameters4 =     loadPreset(presetDir, name, 4);
    parameters5 =     loadPreset(presetDir, name, 5);
    parameters6 =     loadPreset(presetDir, name, 6);
    parameters7 =     loadPreset(presetDir, name, 7);
    parameters8 =     loadPreset(presetDir, name, 8);
    cp5.getController("preset5").setValue(1.f);

    //    tex = loadImage("Deform.jpg");
  }

  public void initGUI(ControlP5 cp5, ControlWindow controlWindow) {
    int deformGUISep = 30;
    int rowIndex;
    int columnIndex;
    int[] parameterMatrix = {
      5, 4, 4
    };    

    PVector[][] parameterPos = new PVector[parameterMatrix.length][max(parameterMatrix)]; 
    PVector[] parameterSize = new PVector[parameterMatrix.length]; 

    for (int i = 0; i < parameterMatrix.length; i++) {
      for (int j = 0; j < parameterMatrix[i]; j++) {
        parameterPos[i][j] = new PVector(visualSpecificParametersBoxX + (visualSpecificParametersBoxWidth/(parameterMatrix[i]*2)*(j*2+1)), visualSpecificParametersBoxY +(visualSpecificParametersBoxHeight/(parameterMatrix.length*2)*(i*2+1)));
        parameterSize[i] = new PVector((visualSpecificParametersBoxWidth/parameterMatrix[i])-deformGUISep, (visualSpecificParametersBoxHeight/parameterMatrix.length)-deformGUISep);
        rectMode(CORNER);
      }
    }


    cp5.addSlider("m1")
      .setPosition(sliderPosX[0]+visualSpecificParametersBoxX, sliderPosY[0]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.01f, 20.f)
            .setCaptionLabel("H. SPIKE AMOUNT")
              .setWindow(controlWindow);
    cp5.getController("m1").captionLabel().getStyle().marginLeft = -26;

    cp5.addSlider("n11")
      .setPosition(sliderPosX[1]+visualSpecificParametersBoxX, sliderPosY[1]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(5.f, 20.f)
            .setCaptionLabel("H. SPIKE DAMP")        
              .setWindow(controlWindow); 
    cp5.getController("n11").captionLabel().getStyle().marginLeft = -20;

    cp5.addSlider("n12")
      .setPosition(sliderPosX[2]+visualSpecificParametersBoxX, sliderPosY[2]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.01f, 20.f)
            .setCaptionLabel("H. SPIKE GAIN\n     COARSE")         
              .setWindow(controlWindow); 
    cp5.getController("n12").captionLabel().getStyle().marginLeft = -22;

    cp5.addSlider("n13")
      .setPosition(sliderPosX[3]+visualSpecificParametersBoxX, sliderPosY[3]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.01f, 20.f)
            .setCaptionLabel("H. SPIKE GAIN\n        FINE")        
              .setWindow(controlWindow); 
    cp5.getController("n13").captionLabel().getStyle().marginLeft = -22;

    cp5.addSlider("m2")
      .setPosition(sliderPosX[4]+visualSpecificParametersBoxX, sliderPosY[4]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.01f, 20.f)
            .setCaptionLabel("V. SPIKE AMOUNT")
              .setWindow(controlWindow); 
    cp5.getController("m2").captionLabel().getStyle().marginLeft = -26;
    
    cp5.addSlider("n21")
      .setPosition(sliderPosX[5]+visualSpecificParametersBoxX, sliderPosY[5]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(5.f, 20.f)
            .setCaptionLabel("V. SPIKE DAMP")        
              .setWindow(controlWindow); 
    cp5.getController("n21").captionLabel().getStyle().marginLeft = -20;
    
    cp5.addSlider("n22")
      .setPosition(sliderPosX[6]+visualSpecificParametersBoxX, sliderPosY[6]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.01f, 20.f)
            .setCaptionLabel("V. SPIKE GAIN\n     COARSE")         
              .setWindow(controlWindow); 
    cp5.getController("n22").captionLabel().getStyle().marginLeft = -22;
    
    cp5.addSlider("n23")
      .setPosition(sliderPosX[7]+visualSpecificParametersBoxX, sliderPosY[7]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.01f, 20.f)
            .setCaptionLabel("V. SPIKE GAIN\n        FINE")        
              .setWindow(controlWindow); 
    cp5.getController("n23").captionLabel().getStyle().marginLeft = -22;

    cp5.addToggle("linesEnable")
      .setPosition(mRectPosX[0]+visualSpecificParametersBoxX, mRectPosY[0]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setCaptionLabel("ENABLE LINES")          
              .setWindow(controlWindow); 
    cp5.getController("linesEnable").captionLabel().getStyle().marginLeft = -20;
    
    cp5.addToggle("facesEnable")
      .setPosition(mRectPosX[1]+visualSpecificParametersBoxX, mRectPosY[1]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(true)
            .setCaptionLabel("ENABLE FACES")          
              .setWindow(controlWindow); 
    cp5.getController("facesEnable").captionLabel().getStyle().marginLeft = -20;

    cp5.addToggle("deformRotStopX")
      .setPosition(mRectPosX[3]+visualSpecificParametersBoxX, mRectPosY[3]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(true)
            .setCaptionLabel("STOP VERTICAL\n    ROTATION")         
              .setWindow(controlWindow); 
    cp5.getController("deformRotStopX").captionLabel().getStyle().marginLeft = -20;

    cp5.addToggle("deformRotStopY")
      .setPosition(mRectPosX[4]+visualSpecificParametersBoxX, mRectPosY[4]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(true)
            .setCaptionLabel("STOP HORIZONTAL\n      ROTATION")        
              .setWindow(controlWindow);             
    cp5.getController("deformRotStopY").captionLabel().getStyle().marginLeft = -28;
    
    cp5.addKnob("linesAlfa")
      .setPosition(knobPosX[0]+visualSpecificParametersBoxX-knobWidth, knobPosY[0]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(0.f, 255.f)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("LINES TRANSPARENCY")        
                  .setWindow(controlWindow); 
    columnIndex = 3; 
    cp5.addKnob("facesAlfa")
      .setPosition(knobPosX[1]+visualSpecificParametersBoxX-knobWidth, knobPosY[1]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(0.f, 255.f)
            .setColorValueLabel(valueLabel)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("FACES TRANSPARENCY")       
                  .setWindow(controlWindow); 

    cp5.addKnob("deformRotX")
      .setPosition(knobPosX[2]+visualSpecificParametersBoxX-knobWidth, knobPosY[2]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(-0.05f, 0.05f)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("VERTICAL ROTATION")       
                  .setWindow(controlWindow); 

    cp5.addKnob("deformRotY")
      .setPosition(knobPosX[3]+visualSpecificParametersBoxX-knobWidth, knobPosY[3]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(-0.05f, 0.05f)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("HORIZONTAL ROTATION")       
                  .setWindow(controlWindow); 

    columnIndex = 4; 
    for (int i = 0; i < parameterNames.length; i++) {
      cp5.getController(parameterNames[i])
        .getCaptionLabel()
          .setFont(fontLight)
            //            .toUpperCase(false)
            .setSize(15);
      controllers.add(cp5.getController(parameterNames[i]));
    }

    showGUI(false);
  }

  public void update() {
    background(0);

    if (midiEnable) {
      mapMidiInterface();
    }
    mapPresets();

    if (!deformRotStopX) {
      cam.rotateX(deformRotX);
    }
    if (!deformRotStopY) {
      cam.rotateY(deformRotY);
    }

    for (int i = 0; i<circleAmount;i++) {
      dc[i].update();
    }

    rotateY(PI);
//    lightSettings();

    for (int i = 0; i<circleAmount;i++) {
      //      beginShape(POINTS);
      //      for (int j = 0; j<dotsPerCircle;j++) {
      //        stroke(255, 200);
      //        strokeWeight(10);
      //        //                 curveVertex(dc[i].getPos(j).x, dc[i].getPos(j).y, dc[i].getPos(j).z);
      //        vertex(dc[i].getPos(j).x, dc[i].getPos(j).y, dc[i].getPos(j).z);
      //      }
      //      endShape();
      textureMode(NORMAL);
      beginShape(TRIANGLE_STRIP);
      for (int j = 0; j<dotsPerCircle;j++) {
        if (i == circleAmount/2) {
          println(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0));
        }
        posTemp = dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0);

        if (posMin > posTemp) {
          posMin = posTemp;
        }

        if (posMax < posTemp) {
          posMax = posTemp;
        }

        if ((i<circleAmount-1)) {
          vertexC(i+1, j);
          vertexC(i, j);
          if ((j == dotsPerCircle-1)) {
            vertexC(i, j);
            vertexC(i, 0);
            vertexC(i+1, j);
            vertexC(i+1, 0);
          }
        } 
        else {
          colorVertex(0, 0);
          vertex(dc[0].getPos(0).x, dc[0].getPos(0).y, -dc[0].getPos(0).z);          
          vertexC(circleAmount-1, j);
          if ((j == dotsPerCircle-1)) {
            colorVertex(0, 0);
            vertex(dc[0].getPos(0).x, dc[0].getPos(0).y, -dc[0].getPos(0).z);
            vertexC(circleAmount-1, 0);
          }
        }
      }
      endShape();
    }
  }

  public void colorVertex(int i, int j) {
    //    fill(map(j, 0, dotsPerCircle, 0, 255), 255, map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0),0.5,2,0,255), facesAlfa);    
    //    fill(map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 20, 200, 50, 150), 255, map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 50, 200, 0, 255), facesAlfa);    
//    fill(map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 20, 200, 50, 150), 50, facesAlfa, 255);    

    fill(map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 20, 300, 0, 220), map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 20, 300, 200, 40), map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 20, 300, 250, 50), facesAlfa);    
    //    tint(map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 20, 100, 50, 150), 255, map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 50, 200, 0, 255), facesAlfa);    

    if (!facesEnable) {
      noFill();
    }
    //    stroke(map(j, 0, dotsPerCircle, 0, 255), 255, map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0),0,2,0,255), linesAlfa);    
//    stroke(map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 20, 200, 50, 150), 50, map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 50, 200, 0, 255), linesAlfa);    
    stroke(map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 20, 200, 50, 150), 50, map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 50, 200, 0, 255), linesAlfa);    
    strokeWeight(2);
    if (!linesEnable) {
      //      noStroke();
    }
  }

  public void vertexC(int i, int j) {
    float x = dc[i].getX(j);
    float y = dc[i].getY(j);
    float z = dc[i].getZ(j);
    colorVertex(i, j);
    //    texture(tex);
    //    vertex(x, y, z, map(i,0,circleAmount,0.,1.),map(j,0,dotsPerCircle,0.,1.));
    vertex(x, y, z);
  }

  public void lightSettings() {

    //    stroke(255);
    //    strokeWeight(20);

    lightSpecular(0, 0, 255);
    shininess(255);
    specular(255);

    ambientLight(0, 0, 150);
    int lightY = 150;
    int lightYBr = 255;
    int lightYCon = 100;
    int lightPos = 100;
    spotLight(255, 0, 255, // Color
    0, 100, 150, // Position
    norm(0, 0, 200), norm(100, 0, 200), norm(150, 0, 200), 
    PI, 20); // Angle, concentration
    //    point(0, 10, 150);

    //    if ( key == 'q') {
    spotLight(255, 0, lightYBr, // Color
    0, -lightY, 0, // Position
    norm(0, 0, 200), norm(lightY, 0, 200), norm(0, 0, 200), 
    PI, 6); // Angle, concentration
    //    point(0, -lightY, 0);

    //    } else if ( key == 'w') {
    spotLight(255, 0, lightYBr, // Color
    lightPos, -lightY, 0, // Position
    norm(-lightPos, 0, 200), norm(lightY, 0, 200), norm(0, 0, 200), 
    PI, lightYCon); // Angle, concentration
    //    point(lightPos, -lightY, 0);
    //    } else if ( key == 'e') {
    spotLight(255, 0, lightYBr, // Color
    -lightPos, -lightY, 0, // Position
    norm(lightPos, 0, 200), norm(lightY, 0, 200), norm(0, 0, 200), 
    PI, lightYCon); // Angle, concentration
    //    point(-lightPos, -lightY, 0);
    //    } else if ( key == 'r') {
    spotLight(255, 0, lightYBr, // Color
    0, -lightY, lightPos, // Position
    norm(0, 0, 200), norm(lightY, 0, 200), norm(-lightPos, 0, 200), 
    PI, lightYCon); // Angle, concentration
    //    point(0, -lightY, lightPos);
    //    } else if ( key == 't') {
    spotLight(255, 0, lightYBr, // Color
    0, -lightY, -lightPos, // Position
    norm(0, 0, 200), norm(lightY, 0, 200), norm(lightPos, 0, 200), 
    PI, lightYCon); // Angle, concentration
    //    point(0, -lightY, -lightPos);
    //}
  }

  public void showGUI(boolean show) {
    for (controlP5.Controller c: controllers) {
      c.setVisible(show);
    }
  }

  public void controlEvent(ControlEvent theControlEvent) {
  }

  public void mapPresets() {

    if (preset1 && !preset1Pre) {
      presetIndex = 1;
      parameters1 =     loadPreset(presetDir, name, 1);
      cam.lookAt(parameters1[0], parameters1[1], parameters1[2]);
      cam.setRotations(parameters1[3], parameters1[4], parameters1[5]);
      cam.setDistance(parameters1[6]);
      cp5.getController("gain").setValue(parameters1[7]);
      cp5.getController("decay").setValue(parameters1[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters1[i]);
      }
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset2 && !preset2Pre) {
      presetIndex = 2;
      parameters2 =     loadPreset(presetDir, name, 2);
      cam.lookAt(parameters2[0], parameters2[1], parameters2[2]);
      cam.setRotations(parameters2[3], parameters2[4], parameters2[5]);
      cam.setDistance(parameters2[6]);
      cp5.getController("gain").setValue(parameters2[7]);
      cp5.getController("decay").setValue(parameters2[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters2[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset3 && !preset3Pre) {
      presetIndex = 3;
      parameters3 =     loadPreset(presetDir, name, 3);
      cam.lookAt(parameters3[0], parameters3[1], parameters3[2]);
      cam.setRotations(parameters3[3], parameters3[4], parameters3[5]);
      cam.setDistance(parameters3[6]);
      cp5.getController("gain").setValue(parameters3[7]);
      cp5.getController("decay").setValue(parameters3[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters3[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset4 && !preset4Pre) {
      presetIndex = 4;
      parameters4 =     loadPreset(presetDir, name, 4);
      cam.lookAt(parameters4[0], parameters4[1], parameters4[2]);
      cam.setRotations(parameters4[3], parameters4[4], parameters4[5]);
      cam.setDistance(parameters4[6]);
      cp5.getController("gain").setValue(parameters4[7]);
      cp5.getController("decay").setValue(parameters4[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters4[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset5 && !preset5Pre) {
      presetIndex = 5;
      parameters5 =     loadPreset(presetDir, name, 5);
      cam.lookAt(parameters5[0], parameters5[1], parameters5[2]);
      cam.setRotations(parameters5[3], parameters5[4], parameters5[5]);
      cam.setDistance(parameters5[6]);
      cp5.getController("gain").setValue(parameters5[7]);
      cp5.getController("decay").setValue(parameters5[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters5[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset6 && !preset6Pre) {
      presetIndex = 6;
      parameters6 =     loadPreset(presetDir, name, 6);
      cam.lookAt(parameters6[0], parameters6[1], parameters6[2]);
      cam.setRotations(parameters6[3], parameters6[4], parameters6[5]);
      cam.setDistance(parameters6[6]);
      cp5.getController("gain").setValue(parameters6[7]);
      cp5.getController("decay").setValue(parameters6[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters6[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset7 && !preset7Pre) {
      presetIndex = 7;
      parameters7 =     loadPreset(presetDir, name, 7);
      cam.lookAt(parameters7[0], parameters7[1], parameters7[2]);
      cam.setRotations(parameters7[3], parameters7[4], parameters7[5]);
      cam.setDistance(parameters7[6]);
      cp5.getController("gain").setValue(parameters7[7]);
      cp5.getController("decay").setValue(parameters7[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters7[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset8 && !preset8Pre) {
      presetIndex = 8;
      parameters8 =     loadPreset(presetDir, name, 8);
      cam.lookAt(parameters8[0], parameters8[1], parameters8[2]);
      cam.setRotations(parameters8[3], parameters8[4], parameters8[5]);
      cam.setDistance(parameters8[6]);
      cp5.getController("gain").setValue(parameters8[7]);
      cp5.getController("decay").setValue(parameters8[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters8[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
    } 
    else if ( savePreset && !savePresetPre) {
      parametersTemp[0] = cam.getLookAt()[0];
      parametersTemp[1] = cam.getLookAt()[1];
      parametersTemp[2] = cam.getLookAt()[2];
      parametersTemp[3] = cam.getRotations()[0];
      parametersTemp[4] = cam.getRotations()[1];
      parametersTemp[5] = cam.getRotations()[2];
      parametersTemp[6] = (float)cam.getDistance();
      parametersTemp[7] = cp5.getController("gain").getValue();
      parametersTemp[8] = cp5.getController("decay").getValue();
      for (int i = 9; i < presetSize; i++) {
        parametersTemp[i] = cp5.getController(parameterNames[i-9]).getValue();
      }
      savePreset(presetDir, name, presetIndex, parametersTemp) ;
    } 
    else if ((!preset1 && !preset2 && !preset3 && !preset4 && !preset5 && !preset6 && !preset7 && !preset8)) {
      presetIndex = 0;
    }

    preset1Pre = preset1;
    preset2Pre = preset2;
    preset3Pre = preset3;
    preset4Pre = preset4;
    preset5Pre = preset5;
    preset6Pre = preset6;
    preset7Pre = preset7;
    preset8Pre = preset8;    
    savePresetPre = savePreset;
  }

  public void mapMidiInterface() {
    cp5.getController("m1").setValue(cp5.getController("m1").getValue()+(map(   faderValDiff[0], 0, 127, 0, cp5.getController("m1").getMax()-cp5.getController("m1").getMin())));
    cp5.getController("n11").setValue(cp5.getController("n11").getValue()+(map(   faderValDiff[1], 0, 127, 0, cp5.getController("n11").getMax()-cp5.getController("n11").getMin())));
    cp5.getController("n12").setValue(cp5.getController("n12").getValue()+(map(   faderValDiff[2], 0, 127, 0, cp5.getController("n12").getMax()-cp5.getController("n12").getMin())));
    cp5.getController("n13").setValue(cp5.getController("n13").getValue()+(map( faderValDiff[3], 0, 127, 0, cp5.getController("n13").getMax()-cp5.getController("n13").getMin())));
    cp5.getController("m2").setValue(cp5.getController("m2").getValue()+(map( faderValDiff[4], 0, 127, 0, cp5.getController("m2").getMax()-cp5.getController("m2").getMin())));
    cp5.getController("n21").setValue(cp5.getController("n21").getValue()+(map( faderValDiff[5], 0, 127, 0, cp5.getController("n21").getMax()-cp5.getController("n21").getMin())));
    cp5.getController("n22").setValue(cp5.getController("n22").getValue()+(map( faderValDiff[6], 0, 127, 0, cp5.getController("n22").getMax()-cp5.getController("n22").getMin())));
    cp5.getController("n23").setValue(cp5.getController("n23").getValue()+(map( faderValDiff[7], 0, 127, 0, cp5.getController("n23").getMax()-cp5.getController("n23").getMin())));

    cp5.getController("linesAlfa").setValue(cp5.getController("linesAlfa").getValue()+(map(   knobValDiff[0], 0, 127, 0, cp5.getController("linesAlfa").getMax()-cp5.getController("linesAlfa").getMin())));
    cp5.getController("facesAlfa").setValue(cp5.getController("facesAlfa").getValue()+(map(   knobValDiff[1], 0, 127, 0, cp5.getController("facesAlfa").getMax()-cp5.getController("facesAlfa").getMin())));
    cp5.getController("deformRotX").setValue(cp5.getController("deformRotX").getValue()+(map(   knobValDiff[2], 0, 127, 0, cp5.getController("deformRotX").getMax()-cp5.getController("deformRotX").getMin())));
    cp5.getController("deformRotY").setValue(cp5.getController("deformRotY").getValue()+(map(   knobValDiff[3], 0, 127, 0, cp5.getController("deformRotY").getMax()-cp5.getController("deformRotY").getMin())));


    cp5.getController("linesEnable").setValue((cp5.getController("linesEnable").getValue()+abs(buttonsMValDiff[0]))%2);
    cp5.getController("facesEnable").setValue((cp5.getController("facesEnable").getValue()+abs(buttonsMValDiff[8]))%2);
    cp5.getController("deformRotStopX").setValue((cp5.getController("deformRotStopX").getValue()+abs(buttonsMValDiff[1]))%2);
    cp5.getController("deformRotStopY").setValue((cp5.getController("deformRotStopY").getValue()+abs(buttonsMValDiff[9]))%2);
  }

  public void start() {
    println("Starting " + name);
    hint(ENABLE_DEPTH_TEST);
    colorMode(RGB);

    cam.lookAt(camLookAt[0], camLookAt[1], camLookAt[2]);
    cam.setRotations(camRotations[0], camRotations[1], camRotations[2]);
    cam.setDistance(camDistance);
  }
  public void exit() {
    println("Exitting " + name);
    //    getCamMatrix(camLookAt, camRotations, camDistance);
    specular(0);

    camLookAt[0] = cam.getLookAt()[0];
    camLookAt[1] = cam.getLookAt()[1];
    camLookAt[2] = cam.getLookAt()[2];

    camRotations[0] = cam.getRotations()[0];
    camRotations[1] = cam.getRotations()[1];
    camRotations[2] = cam.getRotations()[2];

    camDistance = (float)cam.getDistance();
  }
}

class dotCircle {

  int dotAmount;
  int lineId;
  float angleY;
  float angleZ;
  int timer = 0;
  int timerPre = 0;
  PVector[] pos;
  PVector[] error;
  PVector[] target;
  PVector[] offset;
  PVector[] finalPos;
  PVector sep;
  float kp = 0.1f;
  float inc = 0.f;

  dotCircle(int nd, int id) {
    dotAmount = nd;
    lineId = id;
    initializeArrays();
  }


  public void update() {

    inc += 0.01f;

    for (int i = 0; i<dotAmount;i++) {

      float soundData = 1+(soundLPFBuf[PApplet.parseInt(((lineId+inc*10)%circleAmount)*spectrumLength/circleAmount)])*gain*0.1f;
      float soundDataV = 1+(soundLPFBuf[PApplet.parseInt(((i+inc*10)%dotAmount)*spectrumLength/dotAmount)])*gain*0.05f;

      float tempTet = (tet * i);
      float tempPhi = (phi * lineId);

      //      float soundData = 1+(`LPFBuf[int(j*spectrumLength/rRes)])*gain;
      float rr1 = constrain(superformulaPointR(m1, n11, n12, n13, tet*i)*soundDataV, 0.f, 1000000.f);
      float rr2 = constrain(superformulaPointR(m2, n21, n22, n23, phi*lineId)*soundData, 0.f, 1000000.f);

      target[i].set(cos(tempTet)*sin(tempPhi)*rr1*rr2, sin(tempTet)*sin(tempPhi)*rr1*rr2, cos(tempPhi)*rr2);
      target[i].mult(100);
      error[i] = PVector.sub(target[i], pos[i]);
      error[i].mult(kp);
      pos[i].add(error[i]);
    }
  }

  public void draw() {

    for (int i = 0; i<dotAmount;i++) {
      stroke(255, 150);
      strokeWeight(1);
      curveVertex(getPos(i).x, getPos(i).y, getPos(i).z);
    }
  }

  public PVector getPos(int ids) {
    finalPos[ids] = PVector.add(pos[ids], offset[ids]);
    return  finalPos[ids];
  }

  public float getX(int ids) {
    return pos[ids].x+offset[ids].x;
  }
  public float getY(int ids) {
    return pos[ids].y+offset[ids].y;
  }
  public float getZ(int ids) {
    return pos[ids].z+offset[ids].z;
  }

  public boolean bang(int dur) {
    timer = millis();
    if ((timer - timerPre)>dur) {
      timerPre = timer;
      return true;
    } 
    else {
      return false;
    }
  }

  public void initializeArrays() {
    pos = new PVector[dotAmount];
    error = new PVector[dotAmount];
    target = new PVector[dotAmount];
    offset = new PVector[dotAmount];
    finalPos = new PVector[dotAmount];
    sep = new PVector(0, 0, 0);

    for (int i = 0; i < dotAmount; i++) {
      pos[i] = new PVector(0, 0, 0);
      error[i] = new PVector(0, 0, 0);
      offset[i] = new PVector(0, 0, 0);
      target[i]=new PVector(cos(tet*i)*sin(phi*lineId), sin(tet*i)*sin(phi*lineId), cos(phi*lineId));
      target[i].mult(100);
    }
  }
}



ControlP5 cp5;
ControlWindow controlWindow;
ControlWindowCanvas cc;
ControlFont fontLight, fontBold, fontRegular;
RadioButton r;
int radioButtonValue;
ArrayList<controlP5.Controller> cwControllers;
boolean cwVisible = false;
Range colorRange;

PImage thumb1, thumb2, logo, vsBg, about;
PFont pfontLight, pfontBold, pfontRegular;
int colorMin = 100;
int colorMax = 100;

final int soundReactionGUIOffset = 320;
final int visualSpecificGUIOffset = 450;

final float scaleGUI = 1680.f/1007.f;
final int widthGUI = 1680;
final int heightGUI = 1007;

float borderMarginBig = 68;
float borderMarginSmall = 44;

float borderLinesThickness = 8;

float thumbnailBoxX = 8+68;
float thumbnailBoxY = 8;
float thumbnailBoxWidth = 1528;
float thumbnailBoxHeight = 292;

float visualSpecificParametersBoxX = 8+68;
float visualSpecificParametersBoxY = 8+292+47+236+47;
float visualSpecificParametersBoxWidth = 1528;
float visualSpecificParametersBoxHeight = 342;

float presetsBoxX = 8+68;
float presetsBoxY = 8+292+47;
float presetsBoxWidth = 320;
float presetsBoxHeight = 236;

float soundParametersBoxX = 8+68+320+44;
float soundParametersBoxY = 8+292+47;
float soundParametersBoxWidth = 426;
float soundParametersBoxHeight = 236;

float soundWaveBoxX = 8+68+320+44+426+44;
float soundWaveBoxY = 8+292+47;
float soundWaveBoxWidth = 694;
float soundWaveBoxHeight = 236;

int mainYellow;
int mainBlue;
int mainBackground;
int panelBackground;
int label;
int dimYellow;
int thinLines;
int inactive;
int textColor;
int valueLabel;
float thumbnailImageWidth = 185;
float thumbnailImageHeight = 104;
float thumbnailImageSpacing = 47;
int selectedThumbnail;
int selectedThumbnailPre;


public void initializeGUI() {

  colorMode(HSB);
  mainYellow       = color(27, 228, 251);
  mainBlue         = color(137, 252, 100);
  mainBackground   = color(0, 0, 52);
  panelBackground  = color(156, 16, 48);
  label            = color(0, 0, 202);
  dimYellow        = color(27, 255, 148);
  thinLines        = color(0, 0, 102);
  inactive         = color(0, 0, 61);
  textColor        = color(255, 0, 176);
  valueLabel       = color(27, 219, 220);
  cp5 = new ControlP5(this);
  cp5.disableShortcuts();
  controlWindow = cp5.addControlWindow("GUI", 0, 57, widthGUI, heightGUI, 60)
    .hideCoordinates()
      .setBackground(mainBackground);

  controlWindow.setUpdateMode(ControlWindow.NORMAL);
  cc = new MyCanvas();
  cc.pre();
  controlWindow.addCanvas(cc);
  pfontLight = createFont("PFDinTextCompPro-Light", 200, true); // use true/false for smooth/no-smooth
  pfontBold = createFont("PFDinTextCompPro-Bold", 200, true); // use true/false for smooth/no-smooth
  pfontRegular = createFont("PFDinTextCompPro-Regular", 200, true); // use true/false for smooth/no-smooth
  fontLight = new ControlFont(pfontLight, 18);
  fontBold = new ControlFont(pfontBold, 18);
  fontRegular = new ControlFont(pfontRegular, 18);
  cp5.setColorForeground(mainYellow);
  cp5.setColorActive(dimYellow);
  cp5.setColorBackground(mainBlue);
  cp5.setColorCaptionLabel(textColor);
  cp5.setColorValueLabel(valueLabel);
  cp5.setAutoDraw(false);

  cwControllers = new ArrayList<controlP5.Controller>();


  soundReactionGUI(cp5, controlWindow);
  presetsGUI(cp5, controlWindow);
  foregroundGUI(cp5, controlWindow);

  for (int i=0; i<engines.length; ++i) {
    engines[i].initGUI(cp5, controlWindow);
  }

  logo = loadImage("logo.png");
  vsBg = loadImage("vsGUIbg.png");
  about = loadImage("about.png");
  showCWGUI(false);
}


public void showCWGUI(boolean show) {
  //  println(cwControllers.size());
  for (controlP5.Controller c: cwControllers) {
    c.setVisible(show);
  }
}

public void controlEvent(ControlEvent theControlEvent) {
  engines[currentEngineIndex].controlEvent(theControlEvent);

  if (theControlEvent.isFrom(r)) {
    radioButtonValue = PApplet.parseInt(theControlEvent.group().value());
  }
}

class MyCanvas extends ControlWindowCanvas {

  public boolean mouseDragged() {
    return true;
  }

  public void drawThumbnails(PApplet theApplet) {
    theApplet.pushStyle();
    for (int i = 0; i < engines.length; i++) {
      //      float thumbX = thumbnailBoxX + (thumbnailBoxWidth/3) + thumbnailImageSpacing*2 + (thumbnailImageWidth + thumbnailImageSpacing)*(i%5);
      float thumbX = 320+thumbnailImageSpacing*2.6f + (thumbnailImageWidth + thumbnailImageSpacing)*(i%5);
      theApplet.image(engines[i].thumbnail, thumbX, (28+8)+(((int)i/5)*(thumbnailImageHeight+28)), thumbnailImageWidth, thumbnailImageHeight);

      if (theApplet.mousePressed)
        if ((theApplet.mouseX>thumbX)&&(theApplet.mouseX<thumbX+thumbnailImageWidth)&&(theApplet.mouseY>(28+8)+(((int)i/5)*(thumbnailImageHeight+28)))&&(theApplet.mouseY<(28+8)+(((int)i/5)*(thumbnailImageHeight+28))+thumbnailImageHeight)) {
          //        changeVisualEngine(i);
          selectedThumbnail = i;
        }

      theApplet.textFont(pfontLight, 18);
      if (i == currentEngineIndex) {
        theApplet.fill(textColor);
      } 
      else {
        theApplet.fill(mainYellow);
      }
      theApplet.text(engines[i].name, thumbX, (28+5)+(((int)i/5)*(thumbnailImageHeight+28))+thumbnailImageHeight+22);
    }

    theApplet.noFill();
    theApplet.stroke(mainYellow);
    theApplet.strokeWeight(2);
    theApplet.rectMode(CORNER);
    //    theApplet.rect(thumbnailBoxX + (thumbnailBoxWidth/3) + thumbnailImageSpacing*2 + (thumbnailImageWidth + thumbnailImageSpacing)*(currentEngineIndex%5), thumbnailBoxY+borderMarginBig+((int)currentEngineIndex/5)*(thumbnailImageHeight+borderMarginSmall), thumbnailImageWidth, thumbnailImageHeight);
    theApplet.rect(320+thumbnailImageSpacing*2.6f + (thumbnailImageWidth + thumbnailImageSpacing)*(currentEngineIndex%5), (28+8)+(((int)currentEngineIndex/5)*(thumbnailImageHeight+28)), thumbnailImageWidth, thumbnailImageHeight);

    theApplet.popStyle();
  }

  public void drawFFT(PApplet theApplet) {
    soundWaveBoxHeight = soundWaveBoxHeight/2;
    soundWaveBoxY = soundWaveBoxY+1;
    for (int i = 0; i < LiveInput.spectrum.length; i++) {
      theApplet.pushStyle();
      theApplet.colorMode(HSB);
      theApplet.stroke(mainBlue);
      theApplet.strokeCap(RECT);
      theApplet.strokeWeight(soundWaveBoxWidth/LiveInput.spectrum.length);
      theApplet.fill(255);
      theApplet.line(
      (soundWaveBoxWidth/LiveInput.spectrum.length)*(i+1)+soundWaveBoxX, 
      soundWaveBoxY+(soundWaveBoxHeight/2), 
      (soundWaveBoxWidth/LiveInput.spectrum.length)*(i+1)+soundWaveBoxX, 
      (soundWaveBoxY+(soundWaveBoxHeight/2))-constrain(LiveInput.spectrum[i]*gain, 0, soundWaveBoxHeight/2)
        );
      theApplet.line(
      (soundWaveBoxWidth/LiveInput.spectrum.length)*(i+1)+soundWaveBoxX, 
      soundWaveBoxY+(soundWaveBoxHeight/2), 
      (soundWaveBoxWidth/LiveInput.spectrum.length)*(i+1)+soundWaveBoxX, 
      (soundWaveBoxY+(soundWaveBoxHeight/2))+constrain(LiveInput.spectrum[i]*gain, 0, soundWaveBoxHeight/2)
        );
      theApplet.popStyle();
    }
    soundWaveBoxY = soundWaveBoxY-1;
    soundWaveBoxHeight = soundWaveBoxHeight*2;
  }

  public void drawFFTLPF(PApplet theApplet) {
    soundWaveBoxHeight = soundWaveBoxHeight/2;
    soundWaveBoxY = soundWaveBoxY + soundWaveBoxHeight;

    for (int i = 0; i < LiveInput.spectrum.length; i++) {
      theApplet.pushStyle();
      theApplet.stroke(dimYellow);
      theApplet.strokeCap(RECT);
      theApplet.strokeWeight(soundWaveBoxWidth/LiveInput.spectrum.length);
      theApplet.fill(255);
      theApplet.line(
      (soundWaveBoxWidth/LiveInput.spectrum.length)*(i+1)+soundWaveBoxX, 
      soundWaveBoxY+(soundWaveBoxHeight/2), 
      (soundWaveBoxWidth/LiveInput.spectrum.length)*(i+1)+soundWaveBoxX, 
      (soundWaveBoxY+(soundWaveBoxHeight/2))-constrain(soundLPFBuf[i]*gain, 0, soundWaveBoxHeight/2)
        );
      theApplet.line(
      (soundWaveBoxWidth/LiveInput.spectrum.length)*(i+1)+soundWaveBoxX, 
      soundWaveBoxY+(soundWaveBoxHeight/2), 
      (soundWaveBoxWidth/LiveInput.spectrum.length)*(i+1)+soundWaveBoxX, 
      (soundWaveBoxY+(soundWaveBoxHeight/2))+constrain(soundLPFBuf[i]*gain, 0, soundWaveBoxHeight/2)
        );
      theApplet.popStyle();
    }
    soundWaveBoxY = soundWaveBoxY - soundWaveBoxHeight;
    soundWaveBoxHeight = soundWaveBoxHeight*2;
  }

  public void drawFFTFilters(PApplet theApplet) {

    for (int i = 0; i < fftVar.length; i++) {

      float filterVisualRange = (soundWaveBoxWidth/LiveInput.spectrum.length)*fftVar[i].fftRange*2;
      float filterVisualWmin = ((soundWaveBoxWidth/LiveInput.spectrum.length)*(fftVar[i].baseFreq-fftVar[i].fftRange));
      float filterVisualWmax =  ((soundWaveBoxWidth/LiveInput.spectrum.length)*(fftVar[i].baseFreq+fftVar[i].fftRange));

      theApplet.pushStyle();
      theApplet.strokeCap(RECT);
      theApplet.strokeWeight(filterVisualRange);
      theApplet.stroke(dimYellow, 150);

      theApplet.line(
      ((soundWaveBoxWidth/LiveInput.spectrum.length))*(fftVar[i].baseFreq)+soundWaveBoxX, 
      (soundWaveBoxHeight*(i+1)/(fftVar.length+1))+soundWaveBoxY, 
      ((soundWaveBoxWidth/LiveInput.spectrum.length))*(fftVar[i].baseFreq)+soundWaveBoxX, 
      (soundWaveBoxHeight*(i+1)/(fftVar.length+1))+soundWaveBoxY-constrain(fftVar[i].getValue(), 0, soundWaveBoxHeight/2)
        );

      theApplet.line(
      ((soundWaveBoxWidth/LiveInput.spectrum.length))*(fftVar[i].baseFreq)+soundWaveBoxX, 
      (soundWaveBoxHeight*(i+1)/(fftVar.length+1))+soundWaveBoxY, 
      ((soundWaveBoxWidth/LiveInput.spectrum.length))*(fftVar[i].baseFreq)+soundWaveBoxX, 
      (soundWaveBoxHeight*(i+1)/(fftVar.length+1))+soundWaveBoxY+constrain(fftVar[i].getValue(), 0, soundWaveBoxHeight/2)
        );      

      if ((theApplet.mouseX < filterVisualWmax+soundWaveBoxX)&&(theApplet.mouseX > filterVisualWmin+soundWaveBoxX)) {
        if ((theApplet.mouseY < (soundWaveBoxHeight*(i+1)/(fftVar.length+1))+5+soundWaveBoxY)&&(theApplet.mouseY > (soundWaveBoxHeight*(i+1)/(fftVar.length+1))-5+soundWaveBoxY)) {
          theApplet.stroke(mainYellow, 150);
          if (theApplet.mousePressed) {
            if ((theApplet.mouseX-(soundWaveBoxWidth/LiveInput.spectrum.length)*fftVar[i].fftRange > soundWaveBoxX)&&(theApplet.mouseX+(soundWaveBoxWidth/LiveInput.spectrum.length)*fftVar[i].fftRange < soundWaveBoxX+soundWaveBoxWidth)) {
              fftVar[i].setBase(PApplet.parseInt((theApplet.mouseX-soundWaveBoxX)/(soundWaveBoxWidth/LiveInput.spectrum.length)));
            }
          }
        }      
        else {
          theApplet.stroke(mainYellow);
        }
      }  
      else {
        theApplet.stroke(mainYellow);
      }       



      theApplet.line(
      ((soundWaveBoxWidth/LiveInput.spectrum.length))*(fftVar[i].baseFreq)+soundWaveBoxX, 
      (soundWaveBoxHeight*(i+1)/(fftVar.length+1))-5+soundWaveBoxY, 
      ((soundWaveBoxWidth/LiveInput.spectrum.length))*(fftVar[i].baseFreq)+soundWaveBoxX, 
      (soundWaveBoxHeight*(i+1)/(fftVar.length+1))+5+soundWaveBoxY
        );



      theApplet.popStyle();
    }
  }


  public void draw(PApplet theApplet) {
    //    theApplet.frame.setTitle(int(frameRate)+"fps");
    theApplet.frame.setTitle("NOS Visual Engine");
    if (theApplet.frameCount<10) {
      theApplet.image(about, theApplet.width/2-about.width/2, theApplet.height/2-about.height/2);
      cwVisible = true;
      showCWGUI(false);
      engines[currentEngineIndex].showGUI(false);
    } 
    else {
      cwVisible = false;
      showCWGUI(true);
      engines[currentEngineIndex].showGUI(true);


      theApplet.colorMode(HSB);
      theApplet.background(mainBackground);

      theApplet.pushStyle();
      theApplet.noStroke();
      theApplet.fill(mainYellow);
      theApplet.rect(borderLinesThickness+borderMarginBig, 0, thumbnailBoxWidth, borderLinesThickness);
      theApplet.rect(borderLinesThickness+borderMarginBig, heightGUI-borderLinesThickness, thumbnailBoxWidth, heightGUI);
      theApplet.fill(mainBlue);
      theApplet.rect(0, 0, borderLinesThickness, heightGUI-borderMarginSmall-borderLinesThickness);
      theApplet.rect(widthGUI-borderLinesThickness, 0, widthGUI, heightGUI-borderMarginSmall-borderLinesThickness);

      theApplet.fill(panelBackground);
      theApplet.rect(thumbnailBoxX, thumbnailBoxY, thumbnailBoxWidth, thumbnailBoxHeight);
      //    theApplet.rect(visualSpecificParametersBoxX, visualSpecificParametersBoxY, visualSpecificParametersBoxWidth, visualSpecificParametersBoxHeight);
      theApplet.image(vsBg, visualSpecificParametersBoxX, visualSpecificParametersBoxY, visualSpecificParametersBoxWidth, visualSpecificParametersBoxHeight);
      theApplet.rect(presetsBoxX, presetsBoxY, presetsBoxWidth, presetsBoxHeight);
      theApplet.rect(soundParametersBoxX, soundParametersBoxY, soundParametersBoxWidth, soundParametersBoxHeight);
      theApplet.rect(soundWaveBoxX, soundWaveBoxY, soundWaveBoxWidth, soundWaveBoxHeight);

      theApplet.stroke(mainYellow);
      theApplet.strokeWeight(1);
      theApplet.strokeCap(RECT);

      theApplet.line(visualSpecificParametersBoxX, visualSpecificParametersBoxY, visualSpecificParametersBoxX+visualSpecificParametersBoxWidth, visualSpecificParametersBoxY);
      theApplet.line(presetsBoxX, presetsBoxY, presetsBoxX+presetsBoxWidth, presetsBoxY);
      theApplet.line(soundParametersBoxX, soundParametersBoxY, soundParametersBoxX+soundParametersBoxWidth, soundParametersBoxY);
      theApplet.line(soundWaveBoxX, soundWaveBoxY, soundWaveBoxX+soundWaveBoxWidth, soundWaveBoxY);

      theApplet.stroke(thinLines);
      theApplet.line(thumbnailBoxX, thumbnailBoxY+thumbnailBoxHeight, thumbnailBoxX+thumbnailBoxWidth, thumbnailBoxY+thumbnailBoxHeight);
      theApplet.line(visualSpecificParametersBoxX, visualSpecificParametersBoxY+visualSpecificParametersBoxHeight, visualSpecificParametersBoxX+visualSpecificParametersBoxWidth, visualSpecificParametersBoxY+visualSpecificParametersBoxHeight);
      theApplet.line(presetsBoxX, presetsBoxY+presetsBoxHeight, presetsBoxX+presetsBoxWidth, presetsBoxY+presetsBoxHeight);
      theApplet.line(soundParametersBoxX, soundParametersBoxY+soundParametersBoxHeight, soundParametersBoxX+soundParametersBoxWidth, soundParametersBoxY+soundParametersBoxHeight);
      theApplet.line(soundWaveBoxX, soundWaveBoxY+soundWaveBoxHeight, soundWaveBoxX+soundWaveBoxWidth, soundWaveBoxY+soundWaveBoxHeight);
      //    theApplet.line(thumbnailBoxX+thumbnailBoxWidth/3, thumbnailBoxY+borderMarginBig, thumbnailBoxX+thumbnailBoxWidth/3, thumbnailBoxY+thumbnailBoxHeight-borderMarginSmall);
      theApplet.line(320+76, 28+8, 320+76, 300-14);

      theApplet.popStyle();

      theApplet.image(logo, borderLinesThickness+borderMarginBig, borderLinesThickness+28);

      drawThumbnails(theApplet);
      drawFFT(theApplet);
      drawFFTLPF(theApplet);
      //    drawFFTFilters(theApplet);

      theApplet.pushStyle();
      theApplet.stroke(255);
      theApplet.fill(textColor);
      theApplet.textFont(pfontLight, 24);
      theApplet.text("VISUAL SPECIFIC PARAMETERS", visualSpecificParametersBoxX, visualSpecificParametersBoxY-2);
      theApplet.text("SOUND REACTION", soundParametersBoxX, soundParametersBoxY-2);
      theApplet.text("PRESETS", presetsBoxX, presetsBoxY-2);
      theApplet.text("SOUND REACTION ADJUSTMENT", soundWaveBoxX, soundWaveBoxY-2);
      theApplet.textFont(pfontLight, 20);
      theApplet.text("v1.0", borderLinesThickness+borderMarginBig+100, borderLinesThickness+80);
      //      theApplet.text("fps: " + (int)frameRate, borderLinesThickness+borderMarginBig+10, borderLinesThickness+280);
      theApplet.textFont(pfontLight, 18);
      theApplet.text("fps: " + (int)frameRate, theApplet.width-116, theApplet.height-14);
      //    theApplet.text("No Preview Available.", 170, 170);

      //    theApplet.image(preview,thumbnailBoxX, (thumbnailBoxY+borderMarginBig),373,207);
      theApplet.popStyle();

      //      if (currentEngineIndex == 0) {
      //        theApplet.text("asd", 100, 100);
      //        theApplet.text("asdasd", 200, 200);
      //        theApplet.text("asdasdasd", 300, 300);
      //      }
    }
  }
}


public void soundReactionGUI(ControlP5 cp5, ControlWindow controlWindow) {

  String[] parameterNames = {
    "SR", "gain", "decay"
  };
  int soundReactionGUISep = 50;

  int[] parameterMatrix = {
    1, 1, 1
  };    //x = 1; y = 3

  PVector[][] parameterPos = new PVector[parameterMatrix.length][max(parameterMatrix)]; 
  PVector[] parameterSize = new PVector[parameterMatrix.length]; 

  for (int i = 0; i < parameterMatrix.length; i++) {
    for (int j = 0; j < parameterMatrix[i]; j++) {
      parameterPos[i][j] = new PVector(soundParametersBoxX + (soundParametersBoxWidth/(parameterMatrix[i]*2)*(j*2+1)), soundParametersBoxY +(soundParametersBoxHeight/(parameterMatrix.length*2)*(i*2+1)));
      parameterSize[i] = new PVector((soundParametersBoxWidth/parameterMatrix[i])-soundReactionGUISep, (soundParametersBoxHeight/parameterMatrix.length)-soundReactionGUISep);
      noStroke();
      fill(127);
      rectMode(CORNER);
    }
  }


  cp5.addToggle("SR")
    .setPosition(parameterPos[0][0].x-parameterSize[0].x/2, parameterPos[0][0].y-parameterSize[0].y/2)   
      .setSize((int)parameterSize[0].y, (int)parameterSize[0].y)
        .setValue(true)
          .setCaptionLabel("ON/OFF")
            .setColorActive(inactive)
              .setColorForeground(inactive)
                .setColorBackground(inactive)
                  .setWindow(controlWindow);

  cp5.addSlider("gain")
    .setPosition(parameterPos[1][0].x-parameterSize[1].x/2, parameterPos[1][0].y-parameterSize[1].y/2)   
      .setRange(0.f, 0.5f)
        .setSize((int)parameterSize[1].x, (int)parameterSize[1].y)
          .setCaptionLabel("GAIN")
            .setWindow(controlWindow);  

  cp5.addSlider("decay")
    .setPosition(parameterPos[2][0].x-parameterSize[2].x/2, parameterPos[2][0].y-parameterSize[2].y/2)   
      .setRange(0.01f, 0.5f)
        .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
          .setCaptionLabel("DECAY")
            .setWindow(controlWindow);  

  cp5.getController("SR").captionLabel().getStyle().marginLeft = 0;
  cp5.getController("SR").captionLabel().getStyle().marginTop = 0;

  cp5.getController("gain").captionLabel().getStyle().marginLeft = -(int)parameterSize[1].x-4;
  cp5.getController("gain").captionLabel().getStyle().marginTop = 26;

  cp5.getController("decay").captionLabel().getStyle().marginLeft = -(int)parameterSize[2].x-4;
  cp5.getController("decay").captionLabel().getStyle().marginTop = 26;


  for (int i = 0; i < parameterNames.length; i++) {
    cp5.getController(parameterNames[i])
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    cwControllers.add(cp5.getController(parameterNames[i]));
  }
}

public void presetsGUI(ControlP5 cp5, ControlWindow controlWindow) {


  String[] parameterNames = {
    "preset1", 
    "preset2", 
    "preset3", 
    "preset4", 
    "preset5", 
    "preset6", 
    "preset7", 
    "preset8", 
    "savePreset", 
    "automatic", 
    "transitionTime"
  };
  int presetGUISep = 35;

  int[] parameterMatrix = {
    2, 1, 4, 4
  };    //x = 1; y = 3

  PVector[][] parameterPos = new PVector[parameterMatrix.length][max(parameterMatrix)]; 
  PVector[] parameterSize = new PVector[parameterMatrix.length]; 

  for (int i = 0; i < parameterMatrix.length; i++) {
    for (int j = 0; j < parameterMatrix[i]; j++) {
      parameterPos[i][j] = new PVector(presetsBoxX + (presetsBoxWidth/(parameterMatrix[i]*2)*(j*2+1)), presetsBoxY + ((presetsBoxHeight-10)/(parameterMatrix.length*2)*(i*2+1)));
      parameterSize[i] = new PVector((presetsBoxWidth/parameterMatrix[i])-presetGUISep, (presetsBoxHeight/parameterMatrix.length)-presetGUISep);
      noStroke();
      fill(127);
      rectMode(CORNER);
    }
  }

  cp5.addToggle("preset1")
    .setPosition(parameterPos[2][0].x-parameterSize[2].x/2, parameterPos[2][0].y-parameterSize[2].y/2)   
      .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
        .setValue(false)
          .setCaptionLabel("    1")
            .setWindow(controlWindow);

  cp5.addToggle("preset2")
    .setPosition(parameterPos[2][1].x-parameterSize[2].x/2, parameterPos[2][1].y-parameterSize[2].y/2)   
      .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
        .setValue(false)       
          .setCaptionLabel("    2")
            .setWindow(controlWindow);

  cp5.addToggle("preset3")
    .setPosition(parameterPos[2][2].x-parameterSize[2].x/2, parameterPos[2][2].y-parameterSize[2].y/2)   
      .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
        .setValue(false)
          .setCaptionLabel("    3")
            .setWindow(controlWindow);

  cp5.addToggle("preset4")
    .setPosition(parameterPos[2][3].x-parameterSize[2].x/2, parameterPos[2][3].y-parameterSize[2].y/2)   
      .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
        .setValue(false)
          .setCaptionLabel("    4")
            .setWindow(controlWindow);

  cp5.addToggle("preset5")
    .setPosition(parameterPos[3][0].x-parameterSize[3].x/2, parameterPos[3][0].y-parameterSize[3].y/2)   
      .setSize((int)parameterSize[3].x, (int)parameterSize[3].y)
        .setValue(false)
          .setCaptionLabel("    5")
            .setWindow(controlWindow);

  cp5.addToggle("preset6")
    .setPosition(parameterPos[3][1].x-parameterSize[3].x/2, parameterPos[3][1].y-parameterSize[3].y/2)   
      .setSize((int)parameterSize[3].x, (int)parameterSize[3].y)
        .setValue(false)
          .setCaptionLabel("    6")
            .setWindow(controlWindow);

  cp5.addToggle("preset7")
    .setPosition(parameterPos[3][2].x-parameterSize[3].x/2, parameterPos[3][2].y-parameterSize[3].y/2)   
      .setSize((int)parameterSize[3].x, (int)parameterSize[3].y)
        .setValue(false)
          .setCaptionLabel("   7")
            .setWindow(controlWindow);

  cp5.addToggle("preset8")
    .setPosition(parameterPos[3][3].x-parameterSize[3].x/2, parameterPos[3][3].y-parameterSize[3].y/2)   
      .setSize((int)parameterSize[3].x, (int)parameterSize[3].y)
        .setValue(false)
          .setCaptionLabel("    8")
            .setWindow(controlWindow);          

  cp5.addToggle("savePreset")
    .setPosition(parameterPos[0][1].x-parameterSize[0].x/2, parameterPos[0][1].y-parameterSize[0].y/2)   
      .setSize((int)parameterSize[0].x, (int)parameterSize[0].y)
        .setCaptionLabel("SAVE")
          .setValue(false)
            .setWindow(controlWindow);

  cp5.addToggle("automatic")
    .setPosition(parameterPos[0][0].x-parameterSize[0].x/2, parameterPos[0][0].y-parameterSize[0].y/2)   
      .setSize((int)parameterSize[0].x, (int)parameterSize[0].y)
        .setValue(false)
          .setColorActive(inactive)
            .setColorForeground(inactive)
              .setColorBackground(inactive)
                .setCaptionLabel("AUTO")
                  .setWindow(controlWindow);

  cp5.addSlider("transitionTime")
    .setPosition(parameterPos[1][0].x-parameterSize[1].x/2, parameterPos[1][0].y-parameterSize[1].y/2)   
      .setSize((int)parameterSize[1].x, (int)parameterSize[1].y)
        .setCaptionLabel("TRANSITION TIME")
          .setColorActive(inactive)
            .setColorForeground(inactive)
              .setColorBackground(inactive)
                .setRange(0.1f, cubeCircleRad*6/10)
                  .setWindow(controlWindow);

  cp5.getController("transitionTime").captionLabel().getStyle().marginLeft = -(int)parameterSize[1].x-4;
  cp5.getController("transitionTime").captionLabel().getStyle().marginTop = 25;

  for (int i = 0; i < parameterNames.length; i++) {
    cp5.getController(parameterNames[i])
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    cwControllers.add(cp5.getController(parameterNames[i]));
  }
}


public void foregroundGUI(ControlP5 cp5, ControlWindow controlWindow) {

  String[] parameterNames = {
    "blackAlpha", "logoAlpha", "midiEnable"
  };
  //    theApplet.line(320+76, 28+8, 320+76, 300-14);

  float parametersBoxX = 220;
  float parametersBoxY = 25;
  float parametersBoxWidth = 150;
  float parametersBoxHeight = 250;  

  int GUISep = 50;
  int rowIndex;
  int columnIndex;
  int[] parameterMatrix = {
    2
  };    //x = 1; y = 3

  PVector[][] parameterPos = new PVector[parameterMatrix.length][max(parameterMatrix)]; 
  PVector[] parameterSize = new PVector[parameterMatrix.length]; 

  for (int i = 0; i < parameterMatrix.length; i++) {
    for (int j = 0; j < parameterMatrix[i]; j++) {
      parameterPos[i][j] = new PVector(parametersBoxX + (parametersBoxWidth/(parameterMatrix[i]*2)*(j*2+1)), parametersBoxY +(parametersBoxHeight/(parameterMatrix.length*2)*(i*2+1)));
      parameterSize[i] = new PVector((parametersBoxWidth/parameterMatrix[i])-GUISep, (parametersBoxHeight/parameterMatrix.length)-GUISep);
      noStroke();
      fill(127);
      rectMode(CORNER);
    }
  }

  rowIndex = 0; 
  columnIndex = 0; 

  cp5.addSlider("blackAlpha")
    .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2-14)   
      .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y+27)
        .setCaptionLabel("BLACK")
          .setRange(0.f, 255.f)
            .setWindow(controlWindow);
  cp5.getController("blackAlpha").captionLabel().getStyle().marginLeft = -4;

  columnIndex = 1; 

  cp5.addSlider("logoAlpha")
    .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2-14)   
      .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y+27)
        .setCaptionLabel("LOGO")
          .setRange(0.f, 255.f)
            .setWindow(controlWindow);
  cp5.getController("logoAlpha").captionLabel().getStyle().marginLeft = -2;

  cp5.addToggle("midiEnable")
    .setPosition(visualSpecificParametersBoxX+sRectWidth/2+6, visualSpecificParametersBoxY+sRectWidth)   
      .setSize(sRectWidth, sRectHeight)
        .setCaptionLabel("MIDI ENABLE")
          .setValue(false)
            .setWindow(controlWindow);
  cp5.getController("midiEnable").captionLabel().getStyle().marginLeft = -15;

  //  cp5.getController("SR").captionLabel().getStyle().marginLeft = 0;
  //  cp5.getController("SR").captionLabel().getStyle().marginTop = 0;

  for (int i = 0; i < parameterNames.length; i++) {
    cp5.getController(parameterNames[i])
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    cwControllers.add(cp5.getController(parameterNames[i]));
  }
}


int[] sRectPosX = {
  25, 83, 25, 141, 199, 257
};
int[] sRectPosY = {
  134, 134, 203, 203, 203, 203
};

int[] mRectPosX = {
  355, 355, 355, 506, 506, 506, 657, 657, 657, 808, 808, 808, 959, 959, 959, 1110, 1110, 1110, 1261, 1261, 1261, 1412, 1412, 1412
};
int[] mRectPosY = {
  130, 199, 268, 130, 199, 268, 130, 199, 268, 130, 199, 268, 130, 199, 268, 130, 199, 268, 130, 199, 268, 130, 199, 268
};

int[] lRectPosX = {
  25, 83, 141, 199, 257
};
int[] lRectPosY = {
  254, 254, 254, 254, 254
};

int[] sliderPosX = {
  412, 563, 714, 865, 1016, 1167, 1318, 1469
};
int[] sliderPosY = {
  130, 130, 130, 130, 130, 130, 130, 130
};

int[] knobPosX = {
  395, 546, 697, 848, 999, 1150, 1301, 1452
};
int[] knobPosY = {
  40, 40, 40, 40, 40, 40, 40, 40
};

int sRectWidth = 38;
int sRectHeight = 20;

int mRectWidth = 24;
int mRectHeight = 24;

int lRectWidth = 38;
int lRectHeight = 38;

int sliderWidth = 24;
int sliderHeight = 162;

int knobWidth = 25;
int knobHeight = 25;








int particleAmount = 250;

VerletPhysics2D physics;
AttractionBehavior mouseAttractor;
AttractionBehavior randomAttractor;
AttractionBehavior constantAttractor;

Vec2D constantVec;
Vec2D mousePos;

float colorness;

float fadeAmount = 0.f;
float randomness = 0.02f;
float rotAmount = 0.f;
float lineLength = 1.f;
float rotAng = 0.f;
float sw = 0.1f;
float swRand = 0.f;
float constX = 0.01f;
float constY = 0.01f;

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
  public void addParticle() {
    VerletParticle2D p = new VerletParticle2D(Vec2D.randomVector().scale(5).addSelf(localWidth / 2, 0));
    physics.addParticle(p);
    // add a negative attraction force field around the new particle
    physics.addBehavior(new AttractionBehavior(p, 20, 0.f, 0.01f));
  }

  public void removeParticle() {
    VerletParticle2D p = physics.particles.get(physics.particles.size()-1);
    physics.removeParticle(p);
  }

  public void createRandomAttractor() {
    randomAttractor = new AttractionBehavior(new Vec2D(random(localWidth), random(localHeight)), 1000, 1.9f);
    physics.addBehavior(randomAttractor);
  }

  public void removeRandomAttractor() {
    physics.removeBehavior(randomAttractor);
  }

  public void createConstantAttractor() {
    constantAttractor = new AttractionBehavior(constantVec, 1000, base/200.f);
    physics.addBehavior(constantAttractor);
  }

  public void removeConstantAttractor() {
    physics.removeBehavior(constantAttractor);
  }
  public void initGUI(ControlP5 cp5, ControlWindow controlWindow) {
    cp5.addSlider("randomness")
      .setPosition(260, visualSpecificGUIOffset+50)
        .setRange(0.f, 0.1f)
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
        .setRange(0.f, 1.f)
          .setValue(0.8f)
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
        .setRange(0.f, 10.f)
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
        .setRange(1.f, 20.f)
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
        .setRange(0.f, 0.0005f)
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
        .setValue(0.001f)
          .setRange(0.f, 0.1f)
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
        .setValue(0.001f)
          .setRange(0.f, 0.1f)
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
        .setRange(0.f, 1.f)
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
      colorMin = PApplet.parseInt(theControlEvent.getController().getArrayValue(0));
      colorMax = PApplet.parseInt(theControlEvent.getController().getArrayValue(1));
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

int numDots = 20;
int numLines = 20;

boolean pointEnable = true;
float pointSize = 0.f;  //100-100000
float pointSizeVariance;

boolean lineEnable;
float lineSize = 3;
float lineSizeVariance = 0;
float lineThreshold = 1500;

boolean faceEnable;
float faceAmount;
float faceAnim = 1000;
float faceAlfa = 0.f;

float containerX = 10000.f;
float containerY = 10000.f;

boolean resetGrid;

boolean showForceField = false;
float forceFieldRange = 2000;
float forceFieldX;
float forceFieldY;
float forceFieldZ;
float forceFieldXFreq;
float forceFieldYFreq;
float forceFieldPower = 0.f;
float ffx = 0.f;
float ffy = 0.f;

float movementAmount = 1000;
float polyRotX = 0.f;
float polyRotY = 0.f;
boolean polyRotStopX = false;
boolean polyRotStopY = false;
float[][] polySoundMatrix = new float[numLines][numDots];

int[] palette1;
int[] palette2;
int[] palette3;

boolean rotateEnable = false;
dotLines[] d = new dotLines[numLines];


class Polyface extends VisualEngine {
  protected ArrayList<controlP5.Controller> controllers;

  String[] parameterNames = { 
    "pointEnable", 
    "pointSize", //100-100000
    "pointSizeVariance", 
    "lineEnable", 
    "polyRotX", 
    "polyRotY", 
    "lineThreshold", 
    "faceEnable", 
    "faceAlfa", 
    "resetGrid", 
    "containerX", 
    "containerY", 
    "forceFieldRange", 
    "forceFieldXFreq", 
    "forceFieldYFreq", 
    "forceFieldPower", 
    "polyRotStopX", 
    "polyRotStopY" 
      //    "palette1", 
    //    "palette2", 
    //    "palette3"
  };

  int presetSize = parameterNames.length+9;

  float[] parameters1 = new float[presetSize];
  float[] parameters2 = new float[presetSize];
  float[] parameters3 = new float[presetSize];
  float[] parameters4 = new float[presetSize];
  float[] parameters5 = new float[presetSize];
  float[] parameters6 = new float[presetSize];
  float[] parameters7 = new float[presetSize];
  float[] parameters8 = new float[presetSize];
  float[] parametersTemp = new float[presetSize];


  float[] camRotations = new float[3];
  float[] camLookAt = new float[3];
  public float camDistance;

  public Polyface(PApplet myApplet, String name) {
    super(myApplet, name);
    println("Polyface Constructor.");
    controllers = new ArrayList<controlP5.Controller>();
  }

  public void init() {
    cam = new PeasyCam(myApplet, 50);
    cam.setMinimumDistance(1);
    cam.setMaximumDistance(5000000);
    background(0);
    perspective(PI/3, width/height, 1, 5000000);
    for (int i = 0; i<numLines;i++) {
      d[i] = new dotLines(numDots, i);
    }
    colorMode(HSB);
    hint(DISABLE_DEPTH_TEST);
    //    randomSeed(2);

    parameters1 =     loadPreset(presetDir, name, 1);
    parameters2 =     loadPreset(presetDir, name, 2);
    parameters3 =     loadPreset(presetDir, name, 3);
    parameters4 =     loadPreset(presetDir, name, 4);
    parameters5 =     loadPreset(presetDir, name, 5);
    parameters6 =     loadPreset(presetDir, name, 6);
    parameters7 =     loadPreset(presetDir, name, 7);
    parameters8 =     loadPreset(presetDir, name, 8);
    cp5.getController("preset5").setValue(1.f);
  }    // setup function

  public void update() {

    background(0);

    if (midiEnable) {
      mapMidiInterface();
    }

    hint(DISABLE_DEPTH_TEST);

    mapPresets();

    if (!polyRotStopX) {
      cam.rotateX(polyRotX);
    }
    if (!polyRotStopY) {
      cam.rotateY(polyRotY);
    }    

    for (int i = 0; i < numLines-1; i++) {
      for (int j = 0; j < numDots-1; j++) {
        polySoundMatrix[i][j] = polySoundMatrix[i+1][j];
        polySoundMatrix[numLines-1][j] = (soundLPFBuf[PApplet.parseInt(j*spectrumLength/numDots)])*gain;
      }
    }

    ffx += forceFieldXFreq;
    ffy += forceFieldYFreq;
    forceFieldX = containerX * sin(ffx);
    forceFieldY = containerY * cos(ffy);
    forceFieldZ = -100;
    if (showForceField) {
      stroke(255, 255, 255);
      strokeWeight(20);
      point(forceFieldX, forceFieldY, forceFieldZ);
    }

    //    for (int i = 0; i<numLines;i++) {
    //    }
    for (int i = 0; i<numLines;i++) {
      d[i].update();

      for (int j = 0; j<numDots;j++) {
        strokeWeight((pointSize+pointSizeVariance*abs(noise(i+frameCount*0.01f, j+frameCount*0.01f)))/*/abs(cam.getPosition()[2])*/);
        if (pointEnable) {
          stroke(0, PApplet.parseInt(map(abs(d[i].getY(j)), 0, 12500, 0, 5))*50, 255, 200);
          point(d[i].getPos(j).x, d[i].getPos(j).y, d[i].getPos(j).z);
        }


        if ((i<numLines-1)&&(j<numDots-1)) {
          if (faceEnable) {
            //            pushStyle();
            beginShape(TRIANGLE_STRIP);
            //            noStroke();
            //      stroke(255,100);

            //            fill(map(mouseX, 0, width, 0, 255), 255, 255);
            //            stroke(map(mouseX, 0, width, 0, 255), 255, 255);
            noStroke();
            float alfa = (triangleArea(d[i].getPos(j), d[i+1].getPos(j), d[i].getPos(j+1))/(10000)*faceAlfa);
            float hv1 = 0;
            float sv1 = PApplet.parseInt(map(abs(d[i].getY(j)), 0, 12500, 0, 5))*50;
            float bv1 = map(d[i].getZ(j), -10000, 10000, 50, 255);

            fill(hv1, sv1, bv1, alfa/*, 255-(newNoise(i*sin(frameCount*0.001), j, frameCount*0.01)*faceAnim)*/);
            vertex(d[i].getX(j), d[i].getY(j), d[i].getZ(j));
            fill(0, PApplet.parseInt(map(abs(d[i+1].getY(j)), 0, 12500, 0, 255)), map(d[i+1].getZ(j), -10000, 10000, 50, 255), alfa/*, 255-(newNoise(j*cos(frameCount*0.001), i, frameCount*0.01)*faceAnim)*/);
            vertex(d[i+1].getX(j), d[i+1].getY(j), d[i+1].getZ(j));
            fill(0, PApplet.parseInt(map(abs(d[i].getY(j+1)), 0, 12500, 0, 255)), map(d[i].getZ(j+1), -10000, 10000, 50, 255), alfa/*, 255-(newNoise(i*sin(frameCount*0.001), j, frameCount*0.001)*faceAnim)*/);
            vertex(d[i].getX(j+1), d[i].getY(j+1), d[i].getZ(j+1));
            //fill(0, int(map(abs(d[i+1].getY(j+1)), 0, 12500, 0, 255)), map(d[i+1].getZ(j+1), -10000, 10000, 50, 255), 255-(newNoise(i*sin(frameCount*0.001), j, frameCount*0.001)*faceAnim));
            //vertex(d[i+1].getX(j+1), d[i+1].getY(j+1), d[i+1].getZ(j+1));
            endShape();
          }
        }

        float lineThresholdMap = map(containerX*containerY, 10000, 20000*20000, 0.f, lineThreshold);

        if (lineEnable) {
          for (int k = 0; k<numLines;k++) {
            for (int l = 0; l<numDots;l++) {
              colorMode(HSB);
              float dp = PVector.dist(d[i].getPos(j), d[k].getPos(l));
              if ((dp<lineThresholdMap)) {

                strokeWeight(2);
                float linesAlfa = map(dp, 0, lineThresholdMap, 220, 0);
                noFill();
                beginShape(LINES);
                stroke(150, PApplet.parseInt(map(abs(d[i].getY(j)), 0, 12500, 0, 255)), map(d[i].getZ(j), -10000, 10000, 100, 200), linesAlfa);
                vertex(d[i].getPos(j).x, d[i].getPos(j).y, d[i].getPos(j).z);
                stroke(150, PApplet.parseInt(map(abs(d[k].getY(l)), 0, 12500, 0, 255)), map(d[k].getZ(l), -10000, 10000, 100, 20), linesAlfa);
                vertex(d[k].getPos(l).x, d[k].getPos(l).y, d[k].getPos(l).z);
                endShape(CLOSE);
              }
            }
          }
        }
      }
    }

    //    popStyle();
  }  // draw function

  public void initGUI(ControlP5 cp5, ControlWindow controlWindow) {

    int polyfaceGUISep = 30;

    int[] parameterMatrix = {
      8, 4, 8
    };    

    PVector[][] parameterPos = new PVector[parameterMatrix.length][max(parameterMatrix)]; 
    PVector[] parameterSize = new PVector[parameterMatrix.length]; 

    for (int i = 0; i < parameterMatrix.length; i++) {
      for (int j = 0; j < parameterMatrix[i]; j++) {
        parameterPos[i][j] = new PVector(visualSpecificParametersBoxX-10 + (visualSpecificParametersBoxWidth/(parameterMatrix[i]*2)*(j*2+1)), visualSpecificParametersBoxY +(visualSpecificParametersBoxHeight/(parameterMatrix.length*2)*(i*2+1)));
        parameterSize[i] = new PVector((visualSpecificParametersBoxWidth/parameterMatrix[i])-polyfaceGUISep, (visualSpecificParametersBoxHeight/parameterMatrix.length)-polyfaceGUISep);
        //        noStroke();
        //        fill(127);
        rectMode(CORNER);
      }
    }


    cp5.addToggle("pointEnable")
      .setPosition(mRectPosX[0]+visualSpecificParametersBoxX, mRectPosY[0]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(true)
            .setCaptionLabel("ENABLE POINTS")
              .setWindow(controlWindow);
    cp5.getController("pointEnable").captionLabel().getStyle().marginLeft = -20;

    cp5.addToggle("lineEnable")
      .setPosition(mRectPosX[1]+visualSpecificParametersBoxX, mRectPosY[1]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setCaptionLabel("ENABLE LINES")
              .setWindow(controlWindow);
    cp5.getController("lineEnable").captionLabel().getStyle().marginLeft = -18;

    cp5.addToggle("faceEnable")
      .setPosition(mRectPosX[2]+visualSpecificParametersBoxX, mRectPosY[2]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setCaptionLabel("ENABLE FACES")
              .setWindow(controlWindow);
    cp5.getController("faceEnable").captionLabel().getStyle().marginLeft = -17;

    cp5.addToggle("resetGrid")
      .setPosition(mRectPosX[3]+visualSpecificParametersBoxX, mRectPosY[3]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setCaptionLabel("RESET TO GRID")
              .setWindow(controlWindow);
    cp5.getController("resetGrid").captionLabel().getStyle().marginLeft = -17;

    cp5.addToggle("polyRotStopX")
      .setPosition(mRectPosX[4]+visualSpecificParametersBoxX, mRectPosY[4]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(true)
            .setCaptionLabel("STOP V.ROT.")
              .setWindow(controlWindow);
    cp5.getController("polyRotStopX").captionLabel().getStyle().marginLeft = -13;

    cp5.addToggle("polyRotStopY")
      .setPosition(mRectPosX[5]+visualSpecificParametersBoxX, mRectPosY[5]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(true)
            .setCaptionLabel("STOP H.ROT.")
              .setWindow(controlWindow);
    cp5.getController("polyRotStopY").captionLabel().getStyle().marginLeft = -15;

    cp5.addKnob("forceFieldPower")
      .setPosition(knobPosX[0]+visualSpecificParametersBoxX-knobWidth, knobPosY[0]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(-1000.f, 1000.f)
            .setColorValueLabel(valueLabel)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("ATTRACTION POWER")
                  .setWindow(controlWindow);

    cp5.addKnob("forceFieldRange")
      .setPosition(knobPosX[1]+visualSpecificParametersBoxX-knobWidth, knobPosY[1]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(1, 10000)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("ATTRACION RANGE")
                  .setWindow(controlWindow);

    cp5.addKnob("forceFieldXFreq")
      .setPosition(knobPosX[2]+visualSpecificParametersBoxX-knobWidth, knobPosY[2]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(0.0001f, 0.1f)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel(" VERTICAL ATTRACTION FREQ")
                  .setWindow(controlWindow);

    cp5.addKnob("forceFieldYFreq")
      .setPosition(knobPosX[3]+visualSpecificParametersBoxX-knobWidth, knobPosY[3]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(0.0001f, 0.1f)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("HORIZONTAL ATTRACTION FREQ")
                  .setWindow(controlWindow);

    cp5.addKnob("containerX")
      .setPosition(knobPosX[4]+visualSpecificParametersBoxX-knobWidth, knobPosY[4]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(2000.f, 20000.f)
            .setColorValueLabel(valueLabel)
              .setValue(10000.f)
                .setViewStyle(Knob.ARC)
                  .setCaptionLabel("HORIZONTAL LIMIT")
                    .setWindow(controlWindow);

    cp5.addKnob("containerY")
      .setPosition(knobPosX[5]+visualSpecificParametersBoxX-knobWidth, knobPosY[5]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(2000.f, 20000.f)
            .setColorValueLabel(valueLabel)
              .setValue(10000.f)
                .setViewStyle(Knob.ARC)
                  .setCaptionLabel("VERTICAL LIMIT")
                    .setWindow(controlWindow);

    cp5.addKnob("polyRotX")
      .setPosition(knobPosX[6]+visualSpecificParametersBoxX-knobWidth, knobPosY[6]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(-0.05f, 0.05f)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("VERTICAL ROTATION")
                  .setWindow(controlWindow);

    cp5.addKnob("polyRotY")
      .setPosition(knobPosX[7]+visualSpecificParametersBoxX-knobWidth, knobPosY[7]+visualSpecificParametersBoxY-knobHeight)   
        .setColorValueLabel(valueLabel)
          .setRadius(knobWidth)
            .setRange(-0.05f, 0.05f)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("HORIZONTAL ROTATION")
                  .setWindow(controlWindow);

    cp5.addSlider("pointSize")
      .setPosition(sliderPosX[0]+visualSpecificParametersBoxX, sliderPosY[0]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.f, 30.f)
            .setCaptionLabel("POINTS SIZE")
              .setWindow(controlWindow);

    cp5.addSlider("pointSizeVariance")
      .setPosition(sliderPosX[1]+visualSpecificParametersBoxX, sliderPosY[1]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0, 100)
            .setCaptionLabel("POINTS SIZE\n VARIANCE")
              .setWindow(controlWindow);
    cp5.getController("pointSizeVariance").captionLabel().getStyle().marginLeft = -12;

    cp5.addSlider("lineThreshold")
      .setPosition(sliderPosX[2]+visualSpecificParametersBoxX, sliderPosY[2]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.f, 3000.f)
            .setCaptionLabel("LINES THRESHOLD")
              .setWindow(controlWindow);
    cp5.getController("lineThreshold").captionLabel().getStyle().marginLeft = -28;

    cp5.addSlider("faceAlfa")
      .setPosition(sliderPosX[3]+visualSpecificParametersBoxX, sliderPosY[3]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.f, 1.f)
            .setCaptionLabel("FACES TRANSPARENCY")
              .setWindow(controlWindow);
    cp5.getController("faceAlfa").captionLabel().getStyle().marginLeft = -36;

    for (int i = 0; i < parameterNames.length; i++) {
      cp5.getController(parameterNames[i])
        .getCaptionLabel()
          .setFont(fontLight)
            //            .toUpperCase(false)
            .setSize(15);
      controllers.add(cp5.getController(parameterNames[i]));
    }

    showGUI(false);
  }


  public void controlEvent(ControlEvent theControlEvent) {
  }


  public void mapPresets() {

    if (preset1 && !preset1Pre) {
      presetIndex = 1;
      parameters1 =     loadPreset(presetDir, name, 1);
      cam.lookAt(parameters1[0], parameters1[1], parameters1[2]);
      cam.setRotations(parameters1[3], parameters1[4], parameters1[5]);
      cam.setDistance(parameters1[6]);
      cp5.getController("gain").setValue(parameters1[7]);
      cp5.getController("decay").setValue(parameters1[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters1[i]);
      }
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset2 && !preset2Pre) {
      presetIndex = 2;
      parameters2 =     loadPreset(presetDir, name, 2);
      cam.lookAt(parameters2[0], parameters2[1], parameters2[2]);
      cam.setRotations(parameters2[3], parameters2[4], parameters2[5]);
      cam.setDistance(parameters2[6]);
      cp5.getController("gain").setValue(parameters2[7]);
      cp5.getController("decay").setValue(parameters2[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters2[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset3 && !preset3Pre) {
      presetIndex = 3;
      parameters3 =     loadPreset(presetDir, name, 3);
      cam.lookAt(parameters3[0], parameters3[1], parameters3[2]);
      cam.setRotations(parameters3[3], parameters3[4], parameters3[5]);
      cam.setDistance(parameters3[6]);
      cp5.getController("gain").setValue(parameters3[7]);
      cp5.getController("decay").setValue(parameters3[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters3[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset4 && !preset4Pre) {
      presetIndex = 4;
      parameters4 =     loadPreset(presetDir, name, 4);
      cam.lookAt(parameters4[0], parameters4[1], parameters4[2]);
      cam.setRotations(parameters4[3], parameters4[4], parameters4[5]);
      cam.setDistance(parameters4[6]);
      cp5.getController("gain").setValue(parameters4[7]);
      cp5.getController("decay").setValue(parameters4[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters4[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset5 && !preset5Pre) {
      presetIndex = 5;
      parameters5 =     loadPreset(presetDir, name, 5);
      cam.lookAt(parameters5[0], parameters5[1], parameters5[2]);
      cam.setRotations(parameters5[3], parameters5[4], parameters5[5]);
      cam.setDistance(parameters5[6]);
      cp5.getController("gain").setValue(parameters5[7]);
      cp5.getController("decay").setValue(parameters5[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters5[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset6 && !preset6Pre) {
      presetIndex = 6;
      parameters6 =     loadPreset(presetDir, name, 6);
      cam.lookAt(parameters6[0], parameters6[1], parameters6[2]);
      cam.setRotations(parameters6[3], parameters6[4], parameters6[5]);
      cam.setDistance(parameters6[6]);
      cp5.getController("gain").setValue(parameters6[7]);
      cp5.getController("decay").setValue(parameters6[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters6[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset7 && !preset7Pre) {
      presetIndex = 7;
      parameters7 =     loadPreset(presetDir, name, 7);
      cam.lookAt(parameters7[0], parameters7[1], parameters7[2]);
      cam.setRotations(parameters7[3], parameters7[4], parameters7[5]);
      cam.setDistance(parameters7[6]);
      cp5.getController("gain").setValue(parameters7[7]);
      cp5.getController("decay").setValue(parameters7[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters7[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset8 && !preset8Pre) {
      presetIndex = 8;
      parameters8 =     loadPreset(presetDir, name, 8);
      cam.lookAt(parameters8[0], parameters8[1], parameters8[2]);
      cam.setRotations(parameters8[3], parameters8[4], parameters8[5]);
      cam.setDistance(parameters8[6]);
      cp5.getController("gain").setValue(parameters8[7]);
      cp5.getController("decay").setValue(parameters8[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters8[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
    } 
    else if ( savePreset && !savePresetPre) {
      parametersTemp[0] = cam.getLookAt()[0];
      parametersTemp[1] = cam.getLookAt()[1];
      parametersTemp[2] = cam.getLookAt()[2];
      parametersTemp[3] = cam.getRotations()[0];
      parametersTemp[4] = cam.getRotations()[1];
      parametersTemp[5] = cam.getRotations()[2];
      parametersTemp[6] = (float)cam.getDistance();
      parametersTemp[7] = cp5.getController("gain").getValue();
      parametersTemp[8] = cp5.getController("decay").getValue();
      for (int i = 9; i < presetSize; i++) {
        parametersTemp[i] = cp5.getController(parameterNames[i-9]).getValue();
      }
      savePreset(presetDir, name, presetIndex, parametersTemp) ;
    } 
    else if ((!preset1 && !preset2 && !preset3 && !preset4 && !preset5 && !preset6 && !preset7 && !preset8)) {
      presetIndex = 0;
    }

    preset1Pre = preset1;
    preset2Pre = preset2;
    preset3Pre = preset3;
    preset4Pre = preset4;
    preset5Pre = preset5;
    preset6Pre = preset6;
    preset7Pre = preset7;
    preset8Pre = preset8;    
    savePresetPre = savePreset;
  }

  public void showGUI(boolean show) {
    for (controlP5.Controller c: controllers) {
      c.setVisible(show);
    }
  }

  public void mapMidiInterface() {

    cp5.getController("forceFieldPower").setValue(cp5.getController("forceFieldPower").getValue()+(map(   knobValDiff[0], 0, 127, 0, cp5.getController("forceFieldPower").getMax()-cp5.getController("forceFieldPower").getMin()    )));
    cp5.getController("forceFieldRange").setValue(cp5.getController("forceFieldRange").getValue()+(map(   knobValDiff[1], 0, 127, 0, cp5.getController("forceFieldRange").getMax()-cp5.getController("forceFieldRange").getMin()    )));
    cp5.getController("forceFieldXFreq").setValue(cp5.getController("forceFieldXFreq").getValue()+(map(   knobValDiff[2], 0, 127, 0, cp5.getController("forceFieldXFreq").getMax()-cp5.getController("forceFieldXFreq").getMin()    )));
    cp5.getController("forceFieldYFreq").setValue(cp5.getController("forceFieldYFreq").getValue()+(map(   knobValDiff[3], 0, 127, 0, cp5.getController("forceFieldYFreq").getMax()-cp5.getController("forceFieldYFreq").getMin()    )));
    cp5.getController("containerX").setValue(cp5.getController("containerX").getValue()+(map(        knobValDiff[4], 0, 127, 0, cp5.getController("containerX").getMax()-cp5.getController("containerX").getMin()              )));
    cp5.getController("containerY").setValue(cp5.getController("containerY").getValue()+(map(        knobValDiff[5], 0, 127, 0, cp5.getController("containerY").getMax()-cp5.getController("containerY").getMin()              )));
    cp5.getController("polyRotX").setValue(cp5.getController("polyRotX").getValue()+(map(          knobValDiff[6], 0, 127, 0, cp5.getController("polyRotX").getMax()-cp5.getController("polyRotX").getMin()                  )));
    cp5.getController("polyRotY").setValue(cp5.getController("polyRotY").getValue()+(map(          knobValDiff[7], 0, 127, 0, cp5.getController("polyRotY").getMax()-cp5.getController("polyRotY").getMin()                  )));

    cp5.getController("pointSize").setValue(cp5.getController("pointSize").getValue()+(map(           faderValDiff[0], 0, 127, 0, cp5.getController("pointSize").getMax()-cp5.getController("pointSize").getMin()             )));
    cp5.getController("pointSizeVariance").setValue(cp5.getController("pointSizeVariance").getValue()+(map(   faderValDiff[1], 0, 127, 0, cp5.getController("pointSizeVariance").getMax()-cp5.getController("pointSizeVariance").getMin())));
    cp5.getController("lineThreshold").setValue(cp5.getController("lineThreshold").getValue()+(map(       faderValDiff[2], 0, 127, 0, cp5.getController("lineThreshold").getMax()-cp5.getController("lineThreshold").getMin()      )));
    cp5.getController("faceAlfa").setValue(cp5.getController("faceAlfa").getValue()+(map(            faderValDiff[3], 0, 127, 0, cp5.getController("faceAlfa").getMax()-cp5.getController("faceAlfa").getMin()                )));

    cp5.getController("pointEnable").setValue((cp5.getController("pointEnable").getValue()+abs(buttonsMValDiff[0]))%2);
    cp5.getController("lineEnable").setValue(  (  cp5.getController("lineEnable").getValue()+abs(buttonsMValDiff[8]))%2);
    cp5.getController("faceEnable").setValue( (cp5.getController("faceEnable").getValue()+abs(buttonsMValDiff[16]))%2);
    cp5.getController("resetGrid").setValue(  ( cp5.getController("resetGrid").getValue()+ abs(buttonsMValDiff[1]))%2);
    cp5.getController("polyRotStopX").setValue((cp5.getController("polyRotStopX").getValue()+abs(buttonsMValDiff[9]))%2);
    cp5.getController("polyRotStopY").setValue((cp5.getController("polyRotStopY").getValue()+abs(buttonsMValDiff[17]))%2);
  }

  public void start() {
    println("Starting " + name);
    hint(DISABLE_DEPTH_TEST);
    colorMode(HSB);

    cam.lookAt(camLookAt[0], camLookAt[1], camLookAt[2]);
    cam.setRotations(camRotations[0], camRotations[1], camRotations[2]);
    cam.setDistance(camDistance);
    //    lights();
  }

  public void exit() {
    println("Exitting " + name);
    //    getCamMatrix(camLookAt, camRotations, camDistance);

    camLookAt[0] = cam.getLookAt()[0];
    camLookAt[1] = cam.getLookAt()[1];
    camLookAt[2] = cam.getLookAt()[2];

    camRotations[0] = cam.getRotations()[0];
    camRotations[1] = cam.getRotations()[1];
    camRotations[2] = cam.getRotations()[2];

    camDistance = (float)cam.getDistance();
  }
}

class dotLines {

  int dotAmount;
  int lineId;
  float angleY;
  float angleZ;
  int timer = 0;
  int timerPre = 0;
  PVector[] pos;
  PVector[] error;
  PVector[] target;
  PVector[] offset;
  PVector[] finalPos;
  float kp = 0.5f;
  float inc = 0.f;


  dotLines(int nd, int id) {
    dotAmount = nd;
    lineId = id;
    initializeArrays();
  }


  public void update() {
    //    dotAmount = mouseX;
    //    initializeArrays();
    //    inc += 0.01 + (1./(float)cam.getDistance());
    inc += 0.01f;

    for (int i = 0; i<dotAmount;i++) {
      target[i].set(0, 0, 100*polySoundMatrix[lineId][i]);
      error[i] = PVector.sub(target[i], pos[i]);
      error[i].mult(kp);
      pos[i].add(error[i]);

      float dx = forceFieldX - getPos(i).x;
      float dy = forceFieldY - getPos(i).y;
      float dz = forceFieldZ - getPos(i).z;
      float d = mag(dx, dy, dz);

      if (d > 0 && d < forceFieldRange) {
        // calculate force
        float s = d/forceFieldRange;
        float f = 1 / pow(s, 0.5f) - 1;
        f = f / forceFieldRange;
        offset[i].add(dx*f*forceFieldPower, dy*f*forceFieldPower, dz*f*forceFieldPower);
      }

      //container
      offset[i].set(constrain(offset[i].x, -containerX, containerX), constrain(offset[i].y, -containerY, containerY), offset[i].z);

      if (resetGrid) {
        PVector rv = new PVector(
        map(lineId, 0, numLines, -(containerX), (containerX)), 
        map(i, 0, dotAmount, -(containerY), (containerY)), 
        0);
        offset[i].add(PVector.mult(PVector.sub(rv, offset[i]), kp));
      }
    }
  }

  public void draw() {
    //    pushStyle();
    for (int i = 0; i<dotAmount;i++) {
      stroke(0, PApplet.parseInt(map(abs(d[lineId].getZ(i)), 0, 10000, 0, 255)), /*map(d[lineId].getZ(i), -10000, 10000, 0, 255)*/255, 200);

      //strokeWeight((50000./abs(cam.getPosition()[2]/10.))+(newNoise(lineId, i, inc))*0);
      strokeWeight(PApplet.parseInt(map(abs(d[lineId].getZ(i)), 0, 10000, 1, 30)));

      //point(getX(i), getY(i), getZ(i));
      point(getPos(i).x, getPos(i).y, getPos(i).z);
    }
    //    popStyle();
  }

  public PVector getPos(int ids) {
    finalPos[ids] = PVector.add(pos[ids], offset[ids]);
    return  finalPos[ids];
  }

  public float getX(int ids) {
    return pos[ids].x+offset[ids].x;
  }
  public float getY(int ids) {
    return pos[ids].y+offset[ids].y;
  }
  public float getZ(int ids) {
    return pos[ids].z+offset[ids].z;
  }

  public boolean bang(int dur) {
    timer = millis();
    if ((timer - timerPre)>dur) {
      timerPre = timer;
      return true;
    } 
    else {
      return false;
    }
  }

  public void initializeArrays() {
    pos = new PVector[dotAmount];
    error = new PVector[dotAmount];
    target = new PVector[dotAmount];
    offset = new PVector[dotAmount];
    finalPos = new PVector[dotAmount];

    for (int i = 0; i < dotAmount; i++) {
      pos[i] = new PVector(0, 0, 0);
      error[i] = new PVector(0, 0, 0);
      target[i] = new PVector(0, 0, 0);
      offset[i] = new PVector(
      map(lineId, 0, numLines, -containerX, containerX), 
      map(i, 0, dotAmount, -containerY, containerY), 
      0);
    }
  }
}


/*

 verticalLineEnable
 horizontalLineEnable
 faceEnable
 pointEnable
 alfas
 color palette
 noiseGain
 
 */

boolean vLineEnable = true;
boolean hLineEnable = true;
boolean pFaceEnable = true;
boolean pPointEnable = true;

float pStrokeAlfa = 255.f;
float pFaceAlfa = 255.f;
float noiseGain = 100.f;
float soundWaveGain = 1000.f;
float plateRotX = 0.f;
float plateRotY = 0.f;
boolean plateRotStopX = false;
boolean plateRotStopY = false;

float soundPlateVal = 0.f;
int dotsPerPlate = 100;
int plateAmount = 20;

class Soundplate extends VisualEngine {
  protected ArrayList<controlP5.Controller> controllers;

  String[] parameterNames = { 
    "vLineEnable", 
    "hLineEnable", 
    "pFaceEnable", 
    "pPointEnable", 
    "pFaceAlfa", 
    "pStrokeAlfa", 
    "noiseGain", 
    "soundWaveGain", 
    "plateRotX", 
    "plateRotY", 
    "plateRotStopX", 
    "plateRotStopY"
  };


  dotPlate[] dp = new dotPlate[numLines];


  int presetSize = parameterNames.length+9;

  float[] parameters1 = new float[presetSize];
  float[] parameters2 = new float[presetSize];
  float[] parameters3 = new float[presetSize];
  float[] parameters4 = new float[presetSize];
  float[] parameters5 = new float[presetSize];
  float[] parameters6 = new float[presetSize];
  float[] parameters7 = new float[presetSize];
  float[] parameters8 = new float[presetSize];
  float[] parametersTemp = new float[presetSize];

  float[] camRotations = new float[3];
  float[] camLookAt = new float[3];

  public float camDistance;

  public Soundplate(PApplet myApplet, String name) {
    super(myApplet, name);
    println("Soundplate Constructor.");
    controllers = new ArrayList<controlP5.Controller>();
  }

  public void init() {
    cam = new PeasyCam(myApplet, 50);
    cam.setMinimumDistance(1);
    cam.setMaximumDistance(5000000);
    background(0);
    perspective(PI/3, width/height, 1, 5000000);
    for (int i = 0; i<plateAmount;i++) {
      dp[i] = new dotPlate(dotsPerPlate, i);
    }
    colorMode(HSB);
    hint(DISABLE_DEPTH_TEST); 
    background(0);

    parameters1 =     loadPreset(presetDir, name, 1);
    parameters2 =     loadPreset(presetDir, name, 2);
    parameters3 =     loadPreset(presetDir, name, 3);
    parameters4 =     loadPreset(presetDir, name, 4);
    parameters5 =     loadPreset(presetDir, name, 5);
    parameters6 =     loadPreset(presetDir, name, 6);
    parameters7 =     loadPreset(presetDir, name, 7);
    parameters8 =     loadPreset(presetDir, name, 8);
    cp5.getController("preset5").setValue(1.f);
  }

  public void initGUI(ControlP5 cp5, ControlWindow controlWindow) {
    int soundplateGUISep = 30;
    int rowIndex;
    int columnIndex;
    int[] parameterMatrix = {
      5, 5
    };    

    PVector[][] parameterPos = new PVector[parameterMatrix.length][max(parameterMatrix)]; 
    PVector[] parameterSize = new PVector[parameterMatrix.length]; 

    for (int i = 0; i < parameterMatrix.length; i++) {
      for (int j = 0; j < parameterMatrix[i]; j++) {
        parameterPos[i][j] = new PVector(visualSpecificParametersBoxX + (visualSpecificParametersBoxWidth/(parameterMatrix[i]*2)*(j*2+1)), visualSpecificParametersBoxY +(visualSpecificParametersBoxHeight/(parameterMatrix.length*2)*(i*2+1)));
        parameterSize[i] = new PVector((visualSpecificParametersBoxWidth/parameterMatrix[i])-soundplateGUISep, (visualSpecificParametersBoxHeight/parameterMatrix.length)-soundplateGUISep);
        rectMode(CORNER);
      }
    }

    rowIndex = 0; 
    columnIndex = 0; 
    cp5.addToggle("vLineEnable")
      .setPosition(mRectPosX[0]+visualSpecificParametersBoxX, mRectPosY[0]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setCaptionLabel("V. LINES")  
              .setWindow(controlWindow);     
    cp5.getController("vLineEnable").captionLabel().getStyle().marginLeft = -5;

    columnIndex = 1; 
    cp5.addToggle("hLineEnable")
      .setPosition(mRectPosX[1]+visualSpecificParametersBoxX, mRectPosY[1]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setCaptionLabel("H. LINES")    
              .setWindow(controlWindow); 
    cp5.getController("hLineEnable").captionLabel().getStyle().marginLeft = -5;

    columnIndex = 2; 
    cp5.addToggle("pPointEnable")
      .setPosition(mRectPosX[2]+visualSpecificParametersBoxX, mRectPosY[2]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setCaptionLabel("POINTS")   
              .setWindow(controlWindow); 
    cp5.getController("pPointEnable").captionLabel().getStyle().marginLeft = -5;

    columnIndex = 3; 
    cp5.addToggle("pFaceEnable")
      .setPosition(mRectPosX[3]+visualSpecificParametersBoxX, mRectPosY[3]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(true)
            .setCaptionLabel("FACES")   
              .setWindow(controlWindow); 
    cp5.getController("pFaceEnable").captionLabel().getStyle().marginLeft = -2;

    cp5.addToggle("plateRotStopX")
      .setPosition(mRectPosX[4]+visualSpecificParametersBoxX, mRectPosY[4]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setCaptionLabel("STOP V. ROT.")  
              .setWindow(controlWindow); 
    cp5.getController("plateRotStopX").captionLabel().getStyle().marginLeft = -16;

    cp5.addToggle("plateRotStopY")
      .setPosition(mRectPosX[5]+visualSpecificParametersBoxX, mRectPosY[5]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setCaptionLabel("STOP H. ROT.")  
              .setWindow(controlWindow); 
    cp5.getController("plateRotStopY").captionLabel().getStyle().marginLeft = -16;

    columnIndex = 4; 
    cp5.addKnob("noiseGain")
      .setPosition(knobPosX[0]+visualSpecificParametersBoxX-knobWidth, knobPosY[0]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(0.f, 750.f)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("NOISE")   
                  .setWindow(controlWindow); 

    cp5.addKnob("plateRotX")
      .setPosition(knobPosX[1]+visualSpecificParametersBoxX-knobWidth, knobPosY[1]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(-0.05f, 0.05f)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("VERTICAL ROTATION")  
                  .setWindow(controlWindow); 

    cp5.addKnob("plateRotY")
      .setPosition(knobPosX[2]+visualSpecificParametersBoxX-knobWidth, knobPosY[2]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(-0.05f, 0.05f)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("HORIZONTAL ROTATION")   
                  .setWindow(controlWindow); 


    rowIndex = 1; 
    columnIndex = 0; 
    columnIndex = 2; 
    cp5.addSlider("pFaceAlfa")
      .setPosition(sliderPosX[1]+visualSpecificParametersBoxX, sliderPosY[1]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.f, 255.f)
            .setCaptionLabel("         FACE\n TRANSPARENCY")   
              .setWindow(controlWindow); 
    cp5.getController("pFaceAlfa").captionLabel().getStyle().marginLeft = -27;

    columnIndex = 3; 
    cp5.addSlider("pStrokeAlfa")
      .setPosition(sliderPosX[0]+visualSpecificParametersBoxX, sliderPosY[0]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.f, 255.f)
            .setCaptionLabel("         LINE\n TRANSPARENCY")    
              .setWindow(controlWindow); 
    cp5.getController("pStrokeAlfa").captionLabel().getStyle().marginLeft = -25;

    columnIndex = 4; 
    cp5.addSlider("soundWaveGain")
      .setPosition(sliderPosX[2]+visualSpecificParametersBoxX, sliderPosY[2]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.01f, 2.f)
            .setCaptionLabel("SOUND GAIN")   
              .setWindow(controlWindow); 
    cp5.getController("soundWaveGain").captionLabel().getStyle().marginLeft = -16;


    for (int i = 0; i < parameterNames.length; i++) {
      cp5.getController(parameterNames[i])
        .getCaptionLabel()
          .setFont(fontLight)
            //            .toUpperCase(false)
            .setSize(15);
      controllers.add(cp5.getController(parameterNames[i]));
    }

    showGUI(false);
  }

  public void update() {
    background(0);
    if (midiEnable) {
      mapMidiInterface();
    }
    mapPresets();
    if (!plateRotStopX) {
      cam.rotateX(plateRotX);
    }
    if (!plateRotStopY) {
      cam.rotateY(plateRotY);
    }
    //    soundPlateVal = fftVar[0].getValue();
    //    soundPlateVal = map(mouseX, 0, width, 0., 10.);

    for (int i = 0; i<plateAmount;i++) {
      dp[i].update();
    }

    for (int i = 0; i<plateAmount;i++) {
      for (int j = 0; j<dotsPerPlate;j++) {

        if (pPointEnable) {
          beginShape(POINTS);
          vertexC(i, j); 
          endShape();

          beginShape(POINTS);
          vertexCSym(i, j); 
          endShape();
        }

        // Horizontal Lines
        if (hLineEnable) {
          beginShape(LINES);
          vertexC(i, j); 
          vertexC(i, (j+1)%dotsPerPlate); 
          endShape();

          beginShape(LINES);
          vertexCSym(i, j); 
          vertexCSym(i, (j+1)%dotsPerPlate); 
          endShape();
        }  

        if (i < plateAmount - 1) {
          // Vertical Lines
          if (vLineEnable) {
            beginShape(LINES);
            vertexC(i%plateAmount, j%dotsPerPlate); 
            vertexC((i+1)%plateAmount, j%dotsPerPlate); 
            endShape();

            beginShape(LINES);
            vertexCSym(i%plateAmount, j%dotsPerPlate); 
            vertexCSym((i+1)%plateAmount, j%dotsPerPlate); 
            endShape();
          }

          if (pFaceEnable) {
            noStroke();

            //            PVector[] pQ = new PVector[4];
            //            pQ[0] = new PVector(dp[i].getX(j), dp[i].getY(j), dp[i].getZ(j));
            //            pQ[1] = new PVector(dp[i+1].getX(j), dp[i+1].getY(j), dp[i+1].getZ(j));
            //            pQ[2] = new PVector(dp[i].getX(j+1), dp[i].getY(j+1), dp[i].getZ(j+1));
            //            pQ[3] = new PVector(dp[i+1].getX(j+1), dp[i+1].getY(j+1), dp[i+1].getZ(j+1));
            float rectDiag = dist(dp[i%plateAmount].getX(j%dotsPerPlate), dp[i%plateAmount].getY(j%dotsPerPlate), dp[i%plateAmount].getZ(j%dotsPerPlate), dp[(i+1)%plateAmount].getX((j+1)%dotsPerPlate), dp[(i+1)%plateAmount].getY((j+1)%dotsPerPlate), dp[(i+1)%plateAmount].getZ((j+1)%dotsPerPlate));
            alfaCoef = (rectDiag*rectDiag)/200000;

            beginShape(QUAD_STRIP);
            vertexC(i%plateAmount, j%dotsPerPlate); 
            vertexC((i+1)%plateAmount, j%dotsPerPlate); 
            vertexC(i%plateAmount, (j+1)%dotsPerPlate); 
            vertexC((i+1)%plateAmount, (j+1)%dotsPerPlate); 
            endShape();

            beginShape(QUAD_STRIP);
            int iTemp = i;
            int jTemp = j;
            vertexCSym(iTemp%plateAmount, jTemp%dotsPerPlate); 
            vertexCSym((iTemp+1)%plateAmount, jTemp%dotsPerPlate); 
            vertexCSym(iTemp%plateAmount, (jTemp+1)%dotsPerPlate); 
            vertexCSym((iTemp+1)%plateAmount, (jTemp+1)%dotsPerPlate); 
            endShape();
          }
        }
      }
    }
  }

  float alfaCoef;

  public void colorVertex(int i, int j) {

    if (pFaceEnable) {
      //      fill(map(j, 0, dotsPerPlate, 0, 255), 255, 255, 255-pFaceAlfa);
      noStroke();
      fill(map(i, 0, plateAmount, 0, 255), 255, map(abs(dp[i].getY(j)), 200, 2000, 0, 255), pFaceAlfa);
    }
    if (pPointEnable) {
      stroke(map(i, 0, plateAmount, 0, 255), 255, 255, pStrokeAlfa);
      strokeWeight(3);
    }
    if (hLineEnable) {
      stroke(map(i, 0, plateAmount, 0, 255), 255, 255, pStrokeAlfa);
      strokeWeight(1);
    }
    if (vLineEnable) {
      stroke(map(i, 0, plateAmount, 0, 255), 255, 255, pStrokeAlfa);
      strokeWeight(1);
    }
  }

  public void vertexC(int i, int j) {
    float x = dp[i].getX(j);
    float y = dp[i].getY(j);
    float z = dp[i].getZ(j);
    colorVertex(i, j);
    vertex(x, y, z);
  }

  public void vertexCSym(int i, int j) {
    float x = dp[i].getX(j);
    float y = dp[i].getY(j);
    float z = dp[i].getZ(j);
    colorVertex(i, j);
    vertex(x, -y, z);
  }

  public void lightSettings() {

    stroke(255);
    strokeWeight(20);
    lightSpecular(0, 0, 255);
    shininess(255);
    specular(255);

    ambientLight(0, 0, 150);
    int lightY = 150;
    int lightYBr = 255;
    int lightYCon = 100;
    int lightPos = 100;
    spotLight(255, 0, 255, // Color
    0, 100, 150, // Position
    norm(0, 0, 200), norm(100, 0, 200), norm(150, 0, 200), 
    PI, 20); // Angle, concentration
    //    point(0, 10, 150);

    //    if ( key == 'q') {
    spotLight(255, 0, lightYBr, // Color
    0, -lightY, 0, // Position
    norm(0, 0, 200), norm(lightY, 0, 200), norm(0, 0, 200), 
    PI, 6); // Angle, concentration
    //    point(0, -lightY, 0);

    //    } else if ( key == 'w') {
    spotLight(255, 0, lightYBr, // Color
    lightPos, -lightY, 0, // Position
    norm(-lightPos, 0, 200), norm(lightY, 0, 200), norm(0, 0, 200), 
    PI, lightYCon); // Angle, concentration
    //    point(lightPos, -lightY, 0);
    //    } else if ( key == 'e') {
    spotLight(255, 0, lightYBr, // Color
    -lightPos, -lightY, 0, // Position
    norm(lightPos, 0, 200), norm(lightY, 0, 200), norm(0, 0, 200), 
    PI, lightYCon); // Angle, concentration
    //    point(-lightPos, -lightY, 0);
    //    } else if ( key == 'r') {
    spotLight(255, 0, lightYBr, // Color
    0, -lightY, lightPos, // Position
    norm(0, 0, 200), norm(lightY, 0, 200), norm(-lightPos, 0, 200), 
    PI, lightYCon); // Angle, concentration
    //    point(0, -lightY, lightPos);
    //    } else if ( key == 't') {
    spotLight(255, 0, lightYBr, // Color
    0, -lightY, -lightPos, // Position
    norm(0, 0, 200), norm(lightY, 0, 200), norm(lightPos, 0, 200), 
    PI, lightYCon); // Angle, concentration
    //    point(0, -lightY, -lightPos);
    //}
  }

  public void showGUI(boolean show) {
    for (controlP5.Controller c: controllers) {
      c.setVisible(show);
    }
  }

  public void controlEvent(ControlEvent theControlEvent) {
  }

  public void mapPresets() {

    if (preset1 && !preset1Pre) {
      presetIndex = 1;
      parameters1 =     loadPreset(presetDir, name, 1);
      cam.lookAt(parameters1[0], parameters1[1], parameters1[2]);
      cam.setRotations(parameters1[3], parameters1[4], parameters1[5]);
      cam.setDistance(parameters1[6]);
      cp5.getController("gain").setValue(parameters1[7]);
      cp5.getController("decay").setValue(parameters1[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters1[i]);
      }
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset2 && !preset2Pre) {
      presetIndex = 2;
      parameters2 =     loadPreset(presetDir, name, 2);
      cam.lookAt(parameters2[0], parameters2[1], parameters2[2]);
      cam.setRotations(parameters2[3], parameters2[4], parameters2[5]);
      cam.setDistance(parameters2[6]);
      cp5.getController("gain").setValue(parameters2[7]);
      cp5.getController("decay").setValue(parameters2[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters2[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset3 && !preset3Pre) {
      presetIndex = 3;
      parameters3 =     loadPreset(presetDir, name, 3);
      cam.lookAt(parameters3[0], parameters3[1], parameters3[2]);
      cam.setRotations(parameters3[3], parameters3[4], parameters3[5]);
      cam.setDistance(parameters3[6]);
      cp5.getController("gain").setValue(parameters3[7]);
      cp5.getController("decay").setValue(parameters3[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters3[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset4 && !preset4Pre) {
      presetIndex = 4;
      parameters4 =     loadPreset(presetDir, name, 4);
      cam.lookAt(parameters4[0], parameters4[1], parameters4[2]);
      cam.setRotations(parameters4[3], parameters4[4], parameters4[5]);
      cam.setDistance(parameters4[6]);
      cp5.getController("gain").setValue(parameters4[7]);
      cp5.getController("decay").setValue(parameters4[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters4[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset5 && !preset5Pre) {
      presetIndex = 5;
      parameters5 =     loadPreset(presetDir, name, 5);
      cam.lookAt(parameters5[0], parameters5[1], parameters5[2]);
      cam.setRotations(parameters5[3], parameters5[4], parameters5[5]);
      cam.setDistance(parameters5[6]);
      cp5.getController("gain").setValue(parameters5[7]);
      cp5.getController("decay").setValue(parameters5[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters5[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset6 && !preset6Pre) {
      presetIndex = 6;
      parameters6 =     loadPreset(presetDir, name, 6);
      cam.lookAt(parameters6[0], parameters6[1], parameters6[2]);
      cam.setRotations(parameters6[3], parameters6[4], parameters6[5]);
      cam.setDistance(parameters6[6]);
      cp5.getController("gain").setValue(parameters6[7]);
      cp5.getController("decay").setValue(parameters6[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters6[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset7 && !preset7Pre) {
      presetIndex = 7;
      parameters7 =     loadPreset(presetDir, name, 7);
      cam.lookAt(parameters7[0], parameters7[1], parameters7[2]);
      cam.setRotations(parameters7[3], parameters7[4], parameters7[5]);
      cam.setDistance(parameters7[6]);
      cp5.getController("gain").setValue(parameters7[7]);
      cp5.getController("decay").setValue(parameters7[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters7[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset8 && !preset8Pre) {
      presetIndex = 8;
      parameters8 =     loadPreset(presetDir, name, 8);
      cam.lookAt(parameters8[0], parameters8[1], parameters8[2]);
      cam.setRotations(parameters8[3], parameters8[4], parameters8[5]);
      cam.setDistance(parameters8[6]);
      cp5.getController("gain").setValue(parameters8[7]);
      cp5.getController("decay").setValue(parameters8[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters8[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
    } 
    else if ( savePreset && !savePresetPre) {
      parametersTemp[0] = cam.getLookAt()[0];
      parametersTemp[1] = cam.getLookAt()[1];
      parametersTemp[2] = cam.getLookAt()[2];
      parametersTemp[3] = cam.getRotations()[0];
      parametersTemp[4] = cam.getRotations()[1];
      parametersTemp[5] = cam.getRotations()[2];
      parametersTemp[6] = (float)cam.getDistance();
      parametersTemp[7] = cp5.getController("gain").getValue();
      parametersTemp[8] = cp5.getController("decay").getValue();
      for (int i = 9; i < presetSize; i++) {
        parametersTemp[i] = cp5.getController(parameterNames[i-9]).getValue();
      }
      savePreset(presetDir, name, presetIndex, parametersTemp) ;
    } 
    else if ((!preset1 && !preset2 && !preset3 && !preset4 && !preset5 && !preset6 && !preset7 && !preset8)) {
      presetIndex = 0;
    }

    preset1Pre = preset1;
    preset2Pre = preset2;
    preset3Pre = preset3;
    preset4Pre = preset4;
    preset5Pre = preset5;
    preset6Pre = preset6;
    preset7Pre = preset7;
    preset8Pre = preset8;    
    savePresetPre = savePreset;
  }

  public void mapMidiInterface() {

    cp5.getController("pFaceAlfa").setValue(cp5.getController("pFaceAlfa").getValue()+(map(       faderValDiff[1], 0, 127, 0, cp5.getController("pFaceAlfa").getMax()-cp5.getController("pFaceAlfa").getMin())));
    cp5.getController("pStrokeAlfa").setValue(cp5.getController("pStrokeAlfa").getValue()+(map(      faderValDiff[0], 0, 127, 0, cp5.getController("pStrokeAlfa").getMax()-cp5.getController("pStrokeAlfa").getMin())));
    cp5.getController("soundWaveGain").setValue(cp5.getController("soundWaveGain").getValue()+(map(   faderValDiff[2], 0, 127, 0, cp5.getController("soundWaveGain").getMax()-cp5.getController("soundWaveGain").getMin())));

    cp5.getController("noiseGain").setValue(cp5.getController("noiseGain").getValue()+(map(   knobValDiff[0], 0, 127, 0, cp5.getController("noiseGain").getMax()-cp5.getController("noiseGain").getMin())));
    cp5.getController("plateRotX").setValue(cp5.getController("plateRotX").getValue()+(map(   knobValDiff[1], 0, 127, 0, cp5.getController("plateRotX").getMax()-cp5.getController("plateRotX").getMin())));
    cp5.getController("plateRotY").setValue(cp5.getController("plateRotY").getValue()+(map(   knobValDiff[2], 0, 127, 0, cp5.getController("plateRotY").getMax()-cp5.getController("plateRotY").getMin())));

    cp5.getController("vLineEnable").setValue((cp5.getController("vLineEnable").getValue()+abs(buttonsMValDiff[0]))%2);
    cp5.getController("hLineEnable").setValue((cp5.getController("hLineEnable").getValue()+abs(buttonsMValDiff[8]))%2);
    cp5.getController("pFaceEnable").setValue((cp5.getController("pFaceEnable").getValue()+abs(buttonsMValDiff[1]))%2);
    cp5.getController("pPointEnable").setValue((cp5.getController("pPointEnable").getValue()+abs(buttonsMValDiff[16]))%2);
    cp5.getController("plateRotStopX").setValue((cp5.getController("plateRotStopX").getValue()+abs(buttonsMValDiff[9]))%2);
    cp5.getController("plateRotStopY").setValue((cp5.getController("plateRotStopY").getValue()+abs(buttonsMValDiff[17]))%2);
  }

  public void start() {
    println("Starting " + name);
    hint(DISABLE_DEPTH_TEST);
    colorMode(HSB);

    cam.lookAt(camLookAt[0], camLookAt[1], camLookAt[2]);
    cam.setRotations(camRotations[0], camRotations[1], camRotations[2]);
    cam.setDistance(camDistance);
  }
  public void exit() {
    println("Exitting " + name);
    //    getCamMatrix(camLookAt, camRotations, camDistance);
    specular(0);

    camLookAt[0] = cam.getLookAt()[0];
    camLookAt[1] = cam.getLookAt()[1];
    camLookAt[2] = cam.getLookAt()[2];

    camRotations[0] = cam.getRotations()[0];
    camRotations[1] = cam.getRotations()[1];
    camRotations[2] = cam.getRotations()[2];

    camDistance = (float)cam.getDistance();
  }
}

class dotPlate {

  int dotAmount;
  int lineId;
  float angleY;
  float angleZ;
  int timer = 0;
  int timerPre = 0;
  PVector[] pos;
  PVector[] error;
  PVector[] target;
  PVector[] offset;
  PVector[] finalPos;
  PVector sep;
  float kp = 0.1f;
  float inc = 0.f;
  int rad = 50;
  int bufSize;
  float[] soundBuf;
  int bufSpeed = 1;
  dotPlate(int nd, int id) {
    dotAmount = nd;
    lineId = id;
    initializeArrays();
    bufSize = dotAmount;
    soundBuf = new float[bufSize];
    for (int i = 0; i < bufSize; i++) {
      soundBuf[i] = 0.f;
    }
  }


  public void update() {

    inc += 0.01f;

    for (int i = 0; i<dotAmount;i++) {

      //      if (i <dotAmount - bufSpeed)
      //        soundBuf[i] = soundBuf[i+bufSpeed];
      //      }
      //      soundBuf[bufSize-1] = getSoundLevel(0.9);
      //      soundBuf[bufSize-1] = map(soundPlateVal, 0, 5, 0., 1.);


      //      offset[i].set((newNoise((frameCount*.01)+lineId*.1, i*.1, i*.1)*0+rad*lineId*5)*sin(map(i, 0, dotAmount, -PI, PI)), 
      //      (newNoise((float)i/13, frameCount*0.01, pow(lineId, 3)) * TWO_PI*noiseGain)- (soundWaveGain * soundBuf[i]), 
      //      (newNoise((frameCount*.01)+lineId*.1, i*.1, i*.1)*0+rad*lineId*5)*cos(map(i, 0, dotAmount, -PI, PI)));

      if (lineId == 19) {
        offset[i].set((newNoise((frameCount*.01f)+lineId*.1f, i*.1f, i*.1f)*0+rad*lineId*5)*sin(map(i, 0, dotAmount, -PI, PI)), 
        0, 
        (newNoise((frameCount*.01f)+lineId*.1f, i*.1f, i*.1f)*0+rad*lineId*5)*cos(map(i, 0, dotAmount, -PI, PI)));
      } 
      else {
        offset[i].set((newNoise((frameCount*.01f)+lineId*.1f, i*.1f, i*.1f)*0+rad*lineId*5)*sin(map(i, 0, dotAmount, -PI, PI)), 
        (newNoise((float)i/13, frameCount*0.01f, pow(lineId, 3)) * TWO_PI*noiseGain)- (soundWaveGain*soundLPFBuf[PApplet.parseInt(((lineId+10)%plateAmount)*spectrumLength/plateAmount)]), 
        (newNoise((frameCount*.01f)+lineId*.1f, i*.1f, i*.1f)*0+rad*lineId*5)*cos(map(i, 0, dotAmount, -PI, PI)));
      }

      error[i] = PVector.sub(target[i], pos[i]);
      error[i].mult(kp);
      pos[i].add(error[i]);
      //              float soundData = 1+(soundLPFBuf[int(j*spectrumLength/rRes)])*gain;
      //      pos[i].add(0,(soundLPFBuf[int(i*spectrumLength/dotAmount)])*gain,0);
    }
  }

  public void draw() {

    for (int i = 0; i<dotAmount;i++) {
      stroke(255, 150);
      strokeWeight(1);
      curveVertex(getPos(i).x, getPos(i).y, getPos(i).z);
    }
  }

  public PVector getPos(int ids) {
    finalPos[ids] = PVector.add(pos[ids], offset[ids]);
    return  finalPos[ids];
  }

  public float getX(int ids) {
    return pos[ids].x+offset[ids].x;
  }
  public float getY(int ids) {
    return pos[ids].y+offset[ids].y;
  }
  public float getZ(int ids) {
    return pos[ids].z+offset[ids].z;
  }

  public boolean bang(int dur) {
    timer = millis();
    if ((timer - timerPre)>dur) {
      timerPre = timer;
      return true;
    } 
    else {
      return false;
    }
  }

  public void initializeArrays() {
    pos = new PVector[dotAmount];
    error = new PVector[dotAmount];
    target = new PVector[dotAmount];
    offset = new PVector[dotAmount];
    finalPos = new PVector[dotAmount];
    sep = new PVector(0, 0, 0);

    for (int i = 0; i < dotAmount; i++) {
      pos[i] = new PVector(0, 0, 0);
      error[i] = new PVector(0, 0, 0);
      offset[i] = new PVector(0, 0, 0);
      target[i]=new PVector(rad*sin(map(i, 0, dotAmount, -PI, PI)), 0, rad*cos(map(i, 0, dotAmount, -PI, PI)));
    }
  }
}

int ribbonCount = 60;
float ribbonSpeed;
float ribbonLength;
float ribbonSound;
float ribbonSpaceX;
float ribbonSpaceY;
float ribbonSpaceZ;
float ribbonCX;
float ribbonCY;
boolean ribbonHelix;
boolean ribbonCycloid;
boolean ribbonNoise;
float ribbonRotX;
float ribbonRotY;
boolean ribbonRotStopX = false;
boolean ribbonRotStopY = false;

class Splines extends VisualEngine {
  protected ArrayList<controlP5.Controller> controllers;

  String[] parameterNames = { 
    "ribbonCount", 
    "ribbonSpeed", 
    "ribbonLength", 
    "ribbonSound", 
    "ribbonSpaceX", 
    "ribbonSpaceY", 
    "ribbonSpaceZ", 
    "ribbonHelix", 
    "ribbonCycloid", 
    "ribbonCX", 
    "ribbonCY", 
    "ribbonNoise", 
    "ribbonRotX", 
    "ribbonRotY", 
    "ribbonRotStopX", 
    "ribbonRotStopY"
  };

  int presetSize = parameterNames.length+9;

  float[] parameters1 = new float[presetSize];
  float[] parameters2 = new float[presetSize];
  float[] parameters3 = new float[presetSize];
  float[] parameters4 = new float[presetSize];
  float[] parameters5 = new float[presetSize];
  float[] parameters6 = new float[presetSize];
  float[] parameters7 = new float[presetSize];
  float[] parameters8 = new float[presetSize];
  float[] parametersTemp = new float[presetSize];

  float[] camRotations = new float[3];
  float[] camLookAt = new float[3];
  public float camDistance;

  Ribbon[] agents = new Ribbon[1000];

  int offsetX = 0, offsetY = 0, clickX = 0, clickY = 0, zoom = -450;
  float stepSize;
  boolean ribbonHelixPre;
  boolean ribbonCycloidPre;
  boolean ribbonNoisePre;
  boolean helixEnable;
  boolean cycloidEnable;
  boolean noiseEnable;

  public Splines(PApplet myApplet, String name) {
    super(myApplet, name);
    println("Soundplate Constructor.");
    controllers = new ArrayList<controlP5.Controller>();
  }

  public void init() {
    cam = new PeasyCam(myApplet, 50);
    cam.setMinimumDistance(1);
    cam.setMaximumDistance(5000000);
    background(0);
    perspective(PI/3, width/height, 1, 5000000);

    colorMode(RGB);
    hint(ENABLE_DEPTH_TEST); 
    background(0);


    parameters1 =     loadPreset(presetDir, name, 1);
    parameters2 =     loadPreset(presetDir, name, 2);
    parameters3 =     loadPreset(presetDir, name, 3);
    parameters4 =     loadPreset(presetDir, name, 4);
    parameters5 =     loadPreset(presetDir, name, 5);
    parameters6 =     loadPreset(presetDir, name, 6);
    parameters7 =     loadPreset(presetDir, name, 7);
    parameters8 =     loadPreset(presetDir, name, 8);   
    cp5.getController("preset5").setValue(1.f);

    //    colorMode(HSB, 360, 100, 100);
    for (int i=0; i<agents.length; i++) {
      agents[i]=new  Ribbon (i, new PVector(random(-ribbonSpaceX, ribbonSpaceX), random(-ribbonSpaceY, ribbonSpaceY), random(-ribbonSpaceZ, ribbonSpaceZ)), 
      PApplet.parseInt(random(50, 70)));
    }
  }

  public void update() {
    background(0);

    //    if(ribbonCount < 60){
    //      if(frameCount%2 == 0){
    //      cp5.getController("ribbonCount").setValue(ribbonCount++);
    //      }
    //    }

    if (midiEnable) {
      mapMidiInterface();
    }
    mapPresets();

    if (!ribbonRotStopX) {
      cam.rotateX(ribbonRotX);
    }
    if (!ribbonRotStopY) {
      cam.rotateY(ribbonRotY);
    }

    lightSetting();
    for (int i=0; i<ribbonCount; i++) {

      if (ribbonHelix && !ribbonHelixPre) {
        helixEnable = true;
        cycloidEnable = false;
        noiseEnable = false;
      }

      if (ribbonCycloid && !ribbonCycloidPre) {
        helixEnable = false;
        cycloidEnable = true;
        noiseEnable = false;
      }

      if (ribbonNoise && !ribbonNoisePre) {
        helixEnable = false;
        cycloidEnable = false;
        noiseEnable = true;
      }



      if (helixEnable) {
        cp5.getController("ribbonCycloid").setValue(0.f);
        cp5.getController("ribbonNoise").setValue(0.f);

        agents[i].updateHelix();
      }


      if (cycloidEnable) {
        cp5.getController("ribbonHelix").setValue(0.f);
        cp5.getController("ribbonNoise").setValue(0.f);

        agents[i].updateCircloid();
      }


      if (noiseEnable) {
        cp5.getController("ribbonCycloid").setValue(0.f);
        cp5.getController("ribbonHelix").setValue(0.f);

        agents[i].updateNoise();
      }


      //          agents[i].updateCircle1();
      //          agents[i].updateCircle2();
      ribbonHelixPre = ribbonHelix;
      ribbonCycloidPre = ribbonCycloid;
      ribbonNoisePre = ribbonNoise;
      agents[i].draw();
    }
  }

  public void lightSetting() {

    lightSpecular(255,150,50);
    shininess(255);
    specular(255);
    //    pointLight(0, 255, 255, // Color
    //    200, 0, 0); // Position
    //    point(2000, 0, 0);
    //    directionalLight(255, 0, 50, 0, -1, -1);
    //directionalLight(255, 0, 50, 0, -1, 0); 
    ambientLight(100, 100, 100);
    directionalLight(200, 200, 200, 0, -1, -1); 
    //    directionalLight(0, 0, 200, 0, 1, -1); 
    directionalLight(200, 200, 200, 1, 0, -1);
  }


  public void initGUI(ControlP5 cp5, ControlWindow controlWindow) {
    int soundplateGUISep = 30;
    int rowIndex;
    int columnIndex;
    int[] parameterMatrix = {
      5, 7
    };    

    PVector[][] parameterPos = new PVector[parameterMatrix.length][max(parameterMatrix)]; 
    PVector[] parameterSize = new PVector[parameterMatrix.length]; 

    for (int i = 0; i < parameterMatrix.length; i++) {
      for (int j = 0; j < parameterMatrix[i]; j++) {
        parameterPos[i][j] = new PVector(visualSpecificParametersBoxX + (visualSpecificParametersBoxWidth/(parameterMatrix[i]*2)*(j*2+1)), visualSpecificParametersBoxY +(visualSpecificParametersBoxHeight/(parameterMatrix.length*2)*(i*2+1)));
        parameterSize[i] = new PVector((visualSpecificParametersBoxWidth/parameterMatrix[i])-soundplateGUISep, (visualSpecificParametersBoxHeight/parameterMatrix.length)-soundplateGUISep);

        parameterPos[i][j] = new PVector(5, 5);
        parameterSize[i] = new PVector(5, 5);

        rectMode(CORNER);
      }
    }

    rowIndex = 0; 
    columnIndex = 0; 
    cp5.addKnob("ribbonCount")
      .setPosition(knobPosX[0]+visualSpecificParametersBoxX-knobWidth, knobPosY[0]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(0.f, 60.f)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("AMOUNT")   
                  .setWindow(controlWindow);


    columnIndex = 1;       
    cp5.addKnob("ribbonSpeed")
      .setPosition(knobPosX[1]+visualSpecificParametersBoxX-knobWidth, knobPosY[1]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(0.f, 1.f)
            .setColorValueLabel(valueLabel)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("SPEED")   
                  .setWindow(controlWindow);

    cp5.addKnob("ribbonRotX")
      .setPosition(knobPosX[2]+visualSpecificParametersBoxX-knobWidth, knobPosY[2]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(-0.01f, 0.01f)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("V. ROT.")   
                  .setWindow(controlWindow);

    cp5.addKnob("ribbonRotY")
      .setPosition(knobPosX[3]+visualSpecificParametersBoxX-knobWidth, knobPosY[3]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(-0.01f, 0.01f)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("H. ROT.")   
                  .setWindow(controlWindow);

    columnIndex = 2; 
    cp5.addToggle("ribbonHelix")
      .setPosition(mRectPosX[0]+visualSpecificParametersBoxX, mRectPosY[0]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(true)
            .setCaptionLabel("HELIX")   
              .setWindow(controlWindow);
    cp5.getController("ribbonHelix").captionLabel().getStyle().marginLeft = 0;

    columnIndex = 3; 
    cp5.addToggle("ribbonCycloid")
      .setPosition(mRectPosX[1]+visualSpecificParametersBoxX, mRectPosY[1]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setCaptionLabel("CYCLOID")   
              .setWindow(controlWindow);
    cp5.getController("ribbonCycloid").captionLabel().getStyle().marginLeft = -7;

    columnIndex = 4; 
    cp5.addToggle("ribbonNoise")
      .setPosition(mRectPosX[2]+visualSpecificParametersBoxX, mRectPosY[2]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setCaptionLabel("NOISE")   
              .setWindow(controlWindow);            
    cp5.getController("ribbonNoise").captionLabel().getStyle().marginLeft = 0;

    cp5.addToggle("ribbonRotStopX")
      .setPosition(mRectPosX[3]+visualSpecificParametersBoxX, mRectPosY[3]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(true)
            .setCaptionLabel("STOP V. ROT.")   
              .setWindow(controlWindow);
    cp5.getController("ribbonRotStopX").captionLabel().getStyle().marginLeft = -13;

    cp5.addToggle("ribbonRotStopY")
      .setPosition(mRectPosX[4]+visualSpecificParametersBoxX, mRectPosY[4]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(true)
            .setCaptionLabel("STOP H. ROT.")   
              .setWindow(controlWindow);
    cp5.getController("ribbonRotStopY").captionLabel().getStyle().marginLeft = -13;

    rowIndex = 1; 
    columnIndex = 0; 
    cp5.addSlider("ribbonCX")
      .setPosition(sliderPosX[0]+visualSpecificParametersBoxX, sliderPosY[0]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.00001f, 0.01f)
            .setCaptionLabel("CYCLOID X")   
              .setWindow(controlWindow);
    cp5.getController("ribbonCX").captionLabel().getStyle().marginLeft = -13;

    columnIndex = 1; 
    cp5.addSlider("ribbonCY")
      .setPosition(sliderPosX[1]+visualSpecificParametersBoxX, sliderPosY[1]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.00001f, 0.01f)
            .setCaptionLabel("CYCLOID Y")   
              .setWindow(controlWindow);    
    cp5.getController("ribbonCY").captionLabel().getStyle().marginLeft = -13;

    columnIndex = 2; 
    cp5.addSlider("ribbonLength")
      .setPosition(sliderPosX[2]+visualSpecificParametersBoxX, sliderPosY[2]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.f, 1.f)
            .setCaptionLabel(" LENGTH")   
              .setWindow(controlWindow);
    cp5.getController("ribbonLength").captionLabel().getStyle().marginLeft = -7;

    columnIndex = 3; 
    cp5.addSlider("ribbonSound")
      .setPosition(sliderPosX[3]+visualSpecificParametersBoxX, sliderPosY[3]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.f, 30.f)
            .setCaptionLabel("SOUND GAIN")   
              .setWindow(controlWindow);
    cp5.getController("ribbonSound").captionLabel().getStyle().marginLeft = -15;

    columnIndex = 4; 
    cp5.addSlider("ribbonSpaceX")
      .setPosition(sliderPosX[4]+visualSpecificParametersBoxX, sliderPosY[4]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(100.f, 10000.f)
            .setCaptionLabel(" SPACE X")   
              .setWindow(controlWindow);
    cp5.getController("ribbonSpaceX").captionLabel().getStyle().marginLeft = -8;

    columnIndex = 5; 
    cp5.addSlider("ribbonSpaceY")
      .setPosition(sliderPosX[5]+visualSpecificParametersBoxX, sliderPosY[5]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(100.f, 10000)
            .setCaptionLabel("SPACE Y")   
              .setWindow(controlWindow);
    cp5.getController("ribbonSpaceY").captionLabel().getStyle().marginLeft = -8;

    columnIndex = 6; 
    cp5.addSlider("ribbonSpaceZ")
      .setPosition(sliderPosX[6]+visualSpecificParametersBoxX, sliderPosY[6]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(100.f, 10000)
            .setCaptionLabel("SPACE Z")   
              .setWindow(controlWindow);          
    cp5.getController("ribbonSpaceZ").captionLabel().getStyle().marginLeft = -8;


    for (int i = 0; i < parameterNames.length; i++) {
      cp5.getController(parameterNames[i])
        .getCaptionLabel()
          .setFont(fontLight)
            //            .toUpperCase(false)
            .setSize(15);
      controllers.add(cp5.getController(parameterNames[i]));
    }

    showGUI(false);
  }



  public void showGUI(boolean show) {
    for (controlP5.Controller c: controllers) {
      c.setVisible(show);
    }
  }

  public void controlEvent(ControlEvent theControlEvent) {
  }

  public void mapPresets() {

    if (preset1 && !preset1Pre) {
      presetIndex = 1;
      parameters1 =     loadPreset(presetDir, name, 1);
      cam.lookAt(parameters1[0], parameters1[1], parameters1[2]);
      cam.setRotations(parameters1[3], parameters1[4], parameters1[5]);
      cam.setDistance(parameters1[6]);
      cp5.getController("gain").setValue(parameters1[7]);
      cp5.getController("decay").setValue(parameters1[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters1[i]);
      }
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset2 && !preset2Pre) {
      presetIndex = 2;
      parameters2 =     loadPreset(presetDir, name, 2);
      cam.lookAt(parameters2[0], parameters2[1], parameters2[2]);
      cam.setRotations(parameters2[3], parameters2[4], parameters2[5]);
      cam.setDistance(parameters2[6]);
      cp5.getController("gain").setValue(parameters2[7]);
      cp5.getController("decay").setValue(parameters2[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters2[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset3 && !preset3Pre) {
      presetIndex = 3;
      parameters3 =     loadPreset(presetDir, name, 3);
      cam.lookAt(parameters3[0], parameters3[1], parameters3[2]);
      cam.setRotations(parameters3[3], parameters3[4], parameters3[5]);
      cam.setDistance(parameters3[6]);
      cp5.getController("gain").setValue(parameters3[7]);
      cp5.getController("decay").setValue(parameters3[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters3[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset4 && !preset4Pre) {
      presetIndex = 4;
      parameters4 =     loadPreset(presetDir, name, 4);
      cam.lookAt(parameters4[0], parameters4[1], parameters4[2]);
      cam.setRotations(parameters4[3], parameters4[4], parameters4[5]);
      cam.setDistance(parameters4[6]);
      cp5.getController("gain").setValue(parameters4[7]);
      cp5.getController("decay").setValue(parameters4[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters4[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset5 && !preset5Pre) {
      presetIndex = 5;
      parameters5 =     loadPreset(presetDir, name, 5);
      cam.lookAt(parameters5[0], parameters5[1], parameters5[2]);
      cam.setRotations(parameters5[3], parameters5[4], parameters5[5]);
      cam.setDistance(parameters5[6]);
      cp5.getController("gain").setValue(parameters5[7]);
      cp5.getController("decay").setValue(parameters5[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters5[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset6 && !preset6Pre) {
      presetIndex = 6;
      parameters6 =     loadPreset(presetDir, name, 6);
      cam.lookAt(parameters6[0], parameters6[1], parameters6[2]);
      cam.setRotations(parameters6[3], parameters6[4], parameters6[5]);
      cam.setDistance(parameters6[6]);
      cp5.getController("gain").setValue(parameters6[7]);
      cp5.getController("decay").setValue(parameters6[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters6[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset7 && !preset7Pre) {
      presetIndex = 7;
      parameters7 =     loadPreset(presetDir, name, 7);
      cam.lookAt(parameters7[0], parameters7[1], parameters7[2]);
      cam.setRotations(parameters7[3], parameters7[4], parameters7[5]);
      cam.setDistance(parameters7[6]);
      cp5.getController("gain").setValue(parameters7[7]);
      cp5.getController("decay").setValue(parameters7[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters7[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset8 && !preset8Pre) {
      presetIndex = 8;
      parameters8 =     loadPreset(presetDir, name, 8);
      cam.lookAt(parameters8[0], parameters8[1], parameters8[2]);
      cam.setRotations(parameters8[3], parameters8[4], parameters8[5]);
      cam.setDistance(parameters8[6]);
      cp5.getController("gain").setValue(parameters8[7]);
      cp5.getController("decay").setValue(parameters8[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters8[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
    } 
    else if ( savePreset && !savePresetPre) {
      parametersTemp[0] = cam.getLookAt()[0];
      parametersTemp[1] = cam.getLookAt()[1];
      parametersTemp[2] = cam.getLookAt()[2];
      parametersTemp[3] = cam.getRotations()[0];
      parametersTemp[4] = cam.getRotations()[1];
      parametersTemp[5] = cam.getRotations()[2];
      parametersTemp[6] = (float)cam.getDistance();
      parametersTemp[7] = cp5.getController("gain").getValue();
      parametersTemp[8] = cp5.getController("decay").getValue();
      for (int i = 9; i < presetSize; i++) {
        parametersTemp[i] = cp5.getController(parameterNames[i-9]).getValue();
      }
      savePreset(presetDir, name, presetIndex, parametersTemp) ;
    } 
    else if ((!preset1 && !preset2 && !preset3 && !preset4 && !preset5 && !preset6 && !preset7 && !preset8)) {
      presetIndex = 0;
    }

    preset1Pre = preset1;
    preset2Pre = preset2;
    preset3Pre = preset3;
    preset4Pre = preset4;
    preset5Pre = preset5;
    preset6Pre = preset6;
    preset7Pre = preset7;
    preset8Pre = preset8;    
    savePresetPre = savePreset;
  }

  public void mapMidiInterface() {

    cp5.getController("ribbonCX").setValue(cp5.getController("ribbonCX").getValue()+(map(       faderValDiff[0], 0, 127, 0, cp5.getController("ribbonCX").getMax()-cp5.getController("ribbonCX").getMin())));
    cp5.getController("ribbonCY").setValue(cp5.getController("ribbonCY").getValue()+(map(       faderValDiff[1], 0, 127, 0, cp5.getController("ribbonCY").getMax()-cp5.getController("ribbonCY").getMin())));
    cp5.getController("ribbonLength").setValue(cp5.getController("ribbonLength").getValue()+(map(   faderValDiff[2], 0, 127, 0, cp5.getController("ribbonLength").getMax()-cp5.getController("ribbonLength").getMin())));
    cp5.getController("ribbonSound").setValue(cp5.getController("ribbonSound").getValue()+(map(    faderValDiff[3], 0, 127, 0, cp5.getController("ribbonSound").getMax()-cp5.getController("ribbonSound").getMin())));
    cp5.getController("ribbonSpaceX").setValue(cp5.getController("ribbonSpaceX").getValue()+(map(   faderValDiff[4], 0, 127, 0, cp5.getController("ribbonSpaceX").getMax()-cp5.getController("ribbonSpaceX").getMin())));
    cp5.getController("ribbonSpaceY").setValue(cp5.getController("ribbonSpaceY").getValue()+(map(   faderValDiff[5], 0, 127, 0, cp5.getController("ribbonSpaceY").getMax()-cp5.getController("ribbonSpaceY").getMin())));
    cp5.getController("ribbonSpaceZ").setValue(cp5.getController("ribbonSpaceZ").getValue()+(map(   faderValDiff[6], 0, 127, 0, cp5.getController("ribbonSpaceZ").getMax()-cp5.getController("ribbonSpaceZ").getMin())));

    cp5.getController("ribbonCount").setValue(cp5.getController("ribbonCount").getValue()+(map(   knobValDiff[0], 0, 127, 0, cp5.getController("ribbonCount").getMax()-cp5.getController("ribbonCount").getMin())));
    cp5.getController("ribbonSpeed").setValue(cp5.getController("ribbonSpeed").getValue()+(map(   knobValDiff[1], 0, 127, 0, cp5.getController("ribbonSpeed").getMax()-cp5.getController("ribbonSpeed").getMin())));
    cp5.getController("ribbonRotX").setValue(cp5.getController("ribbonRotX").getValue()+(map(   knobValDiff[2], 0, 127, 0, cp5.getController("ribbonRotX").getMax()-cp5.getController("ribbonRotX").getMin())));
    cp5.getController("ribbonRotY").setValue(cp5.getController("ribbonRotY").getValue()+(map(   knobValDiff[3], 0, 127, 0, cp5.getController("ribbonRotY").getMax()-cp5.getController("ribbonRotY").getMin())));

    cp5.getController("ribbonHelix").setValue((cp5.getController("ribbonHelix").getValue()+abs(buttonsMValDiff[0]))%2);
    cp5.getController("ribbonCycloid").setValue((cp5.getController("ribbonCycloid").getValue()+abs(buttonsMValDiff[8]))%2);
    cp5.getController("ribbonNoise").setValue((cp5.getController("ribbonNoise").getValue()+abs(buttonsMValDiff[16]))%2);
    cp5.getController("ribbonRotStopX").setValue((cp5.getController("ribbonRotStopX").getValue()+abs(buttonsMValDiff[1]))%2);
    cp5.getController("ribbonRotStopY").setValue((cp5.getController("ribbonRotStopY").getValue()+abs(buttonsMValDiff[9]))%2);
  }

  public void start() {
    println("Starting " + name);
    hint(ENABLE_DEPTH_TEST);
    colorMode(RGB);

    cam.lookAt(camLookAt[0], camLookAt[1], camLookAt[2]);
    cam.setRotations(camRotations[0], camRotations[1], camRotations[2]);
    cam.setDistance(camDistance);
  }
  public void exit() {
    println("Exitting " + name);
    //    getCamMatrix(camLookAt, camRotations, camDistance);
    specular(0);

    camLookAt[0] = cam.getLookAt()[0];
    camLookAt[1] = cam.getLookAt()[1];
    camLookAt[2] = cam.getLookAt()[2];

    camRotations[0] = cam.getRotations()[0];
    camRotations[1] = cam.getRotations()[1];
    camRotations[2] = cam.getRotations()[2];

    camDistance = (float)cam.getDistance();
  }
}


class Ribbon {
  int count; // how many points has the ribbon
  PVector[] p;

  boolean[] isGap;
  int id;
  PVector ref, target, error;
  boolean isOutside = false;
  float offset, offsetVelocity, angleY, angleZ;
  int col;
  float strokeW;
  float kp = 0.1f;
  float rX, rY, rZ;
  float colR;
  float colG;
  float colB;
  Ribbon (int i, PVector theP, int theCount) {
    id = i;
    ref = new PVector(0, 0, 0);
    target = new PVector(0, 0, 0);
    error = new PVector(0, 0, 0);
    setRandomPostition();
    count = theCount; 
    p = new PVector[count];
    isGap = new boolean[count];
    for (int j=0; j<count; j++) {
      p[j] = new PVector(theP.x, theP.y, theP.z);
      isGap[j] = false;
    }

    offset = 10000;
    offsetVelocity = 0.05f;
    float stepSize = random(5, 20);
    colR = map(i, 0, ribbonCount, 0.f, 255.f);
    strokeW = random(1.0f);
    //    rX = random(ribbonSpaceX/5, ribbonSpaceX/2);
    //    rY = random(ribbonSpaceY/5, ribbonSpaceY/2);
    //    rZ = random(ribbonSpaceZ/5, ribbonSpaceZ/2);
    rX = random(-500, 500);
    rY = random(-250, 250);
    rZ = random(-250, 250);
  }


  float xInc = 0;

  public void updateHelix() { 

    xInc = (xInc+10*ribbonSpeed);
    float inc = map(ref.x, 0, ribbonSpaceX, 0, TWO_PI);
    //    float soundData = 1+(soundLPFBuf[int(j*spectrumLength/rRes)])*gain;

    inc = (inc + id)%TWO_PI;

    float x = ribbonSpaceX*sin(xInc*0.001f);
    if (x > ribbonSpaceX) {
      //      isOutside = true;
      xInc = -ribbonSpaceX;
    }
    float y = ((rY+soundLevelLPF*ribbonSound*10)*sin(inc));
    float z = ((rZ+soundLevelLPF*ribbonSound*10)*cos(inc));

    target.x = x;
    target.y = y;
    target.z = z;


    updateRibbon();
  }

  float circleInc = 0;

  public void updateCircloid() { 
    circleInc += ribbonSpeed*10;

    float rmx = ribbonCX;
    float rmy = ribbonCY;

    float theta = (circleInc)*rmx*id*0.1f;
    float psi = ((circleInc)*rmy*id*0.1f)/2;

    float r = rX+soundLevelLPF*ribbonSound;

    float cx = r* cos(theta) * sin(psi);
    float cy = r* sin(theta) * sin(psi);
    float cz = r* cos(psi);


    target.x = cx;
    target.y = cy;
    target.z = cz;


    updateRibbon();
  }

  public void updateCircle1() { 

    counter += 0.1f;
    float theta = counter;
    float psi = map(id, 0, ribbonCount, 0, PI);
    target.x = (rY*2-soundLevelLPF*ribbonSound) * cos(theta) * sin(psi);
    target.z = (rY*2-soundLevelLPF*ribbonSound) * sin(theta) * sin(psi);
    target.y = (rY*2-soundLevelLPF*ribbonSound) * cos(psi);

    //    ref.x += (ribbonSpaceX/2*sin(counter)*cos(map(ref.y, -ribbonSpaceY, ribbonSpaceY, -PI/2, PI/2))-ref.x)/10;
    //    ref.z += (ribbonSpaceZ/2*cos(counter)*cos(map(ref.y, -ribbonSpaceY, ribbonSpaceY, -PI/2, PI/2))-ref.z)/10;

    updateRibbon();
  }

  public void updateTorus() { 


    counter += 0.1f;
    float psi = counter;
    randomSeed(2);
    float theta = map(id, 0, ribbonCount, 0, TWO_PI);

    float R = 400+LiveInput.getLevel()*ribbonSound;
    float r = R/2;

    float x = (R + r*cos(psi*2))*cos(theta);
    float y = (R + r*cos(psi))*sin(theta);
    float z = (r*sin(psi*2));

    target.x = x;
    target.y = z;
    target.z = y;

    updateRibbon();
  }

  float counter = 0;

  public void updateCircle2() { 

    counter += 0.1f;
    float theta = counter;
    randomSeed(2);
    float psi = map(id, 0, ribbonCount, 0, PI);
    float idGain = map(id, 0, ribbonCount, 1, 1.f);
    //    psi = id;
    float soundEffect = LiveInput.getLevel()*ribbonSound;
    soundEffect = 0;
    float x = (idGain*rY-soundEffect) * cos(theta) * sin(psi);
    float y = (idGain*rY-soundEffect) * sin(theta) * sin(psi);
    float z = (idGain*rY-soundEffect) * cos(psi);

    if (id%3 == 0) {
      target.x = x;
      target.y = y;
      target.z = z;
    } 
    else     if (id%3 == 1) {
      target.x = z;
      target.y = x+y/2;
      target.z = y+z/2;
    } 
    else     if (id%3 == 2) {
      target.x = y;
      target.y = z;
      target.z = x;
    } 

    //    ref.x += (ribbonSpaceX/2*sin(counter)*cos(map(ref.y, -ribbonSpaceY, ribbonSpaceY, -PI/2, PI/2))-ref.x)/10;
    //    ref.z += (ribbonSpaceZ/2*cos(counter)*cos(map(ref.y, -ribbonSpaceY, ribbonSpaceY, -PI/2, PI/2))-ref.z)/10;
    updateRibbon();
  }

  float n = 0;


  public void updateNoise() { 
    n += 0.1f;
    noiseSeed(10);
    angleY = noise(id + ref.x/950, ref.y/950, ref.z/950) * 300 * ribbonSpeed; 
    noiseSeed(13);
    angleZ = noise(id + ref.x/950+offset+n, ref.y/950, ref.z/950) * 300 * ribbonSpeed; 

    target.x +=  cos(angleY) * (1 + soundLevelLPF) * ribbonSound;
    target.y += sin(angleZ) * (1 + soundLevelLPF) * ribbonSound;
    target.z += cos(angleZ)  * (1 + soundLevelLPF) * ribbonSound;

    //    target.x = x;
    //    target.y = y;
    //    target.z = z;

    updateRibbon();
  }

  public void updateRibbon() {
    // create ribbons

    error = PVector.sub(target, ref);
    error.mult(kp);
    ref.add(error);

    boundingBox();
    update(ref, isOutside);
    isOutside = false;
  }


  public void update(PVector theP, boolean theIsWraped) {
    // shift the values to the right side
    for (int i=count-1; i>0; i--) {
      //    for (int i=ribbonLength-1; i>0; i--) {

      p[i].set(p[i-1]);
      isGap[i] = isGap[i-1];
    }
    p[0].set(theP);

    isGap[0] = theIsWraped;
  }


  public void boundingBox() {
    // boundingbox wrap
    if (ref.x<-ribbonSpaceX) {
      ref.x=ribbonSpaceX;
      target.x = ribbonSpaceX;
      isOutside = true;
    }
    if (ref.x>ribbonSpaceX) {
      ref.x=-ribbonSpaceX;
      target.x = -ribbonSpaceX;
      isOutside = true;
    }
    if (ref.y<-ribbonSpaceY) {
      ref.y=ribbonSpaceY;
      target.y = ribbonSpaceY;
      isOutside = true;
    }  
    if (ref.y>ribbonSpaceY) {
      ref.y=-ribbonSpaceY;
      target.y = -ribbonSpaceY;
      isOutside = true;
    }
    if (ref.z<-ribbonSpaceZ) {
      ref.z=ribbonSpaceZ;
      target.z = ribbonSpaceZ;
      isOutside = true;
    }
    if (ref.z>ribbonSpaceZ) {
      ref.z=-ribbonSpaceZ;
      target.z = -ribbonSpaceZ;
      isOutside = true;
    }
  }

  public void draw() {
    drawMeshRibbon(col, map(strokeW, 0, 1, 3, 12));
  }

  public void drawMeshRibbon(int theMeshCol, float theWidth) {
    // draw the ribbons with meshes
    int colorFader = 30;

    int alfaFader = 30;
    float alfaFadeDiff = 0;

    int widthFader = 5;
    float widthFadeDiff = 15;



    beginShape(TRIANGLE_STRIP);
    for (int i=0; i<PApplet.parseInt(count*ribbonLength)-1; i++) {
      // if the point was wraped -> finish the mesh an start a new one

      float ribbonAlfa = 255;

      if (i < alfaFader) 
        ribbonAlfa = ribbonAlfa -(alfaFader-i)*(alfaFadeDiff)/alfaFader;
      else if (count*ribbonLength - i < alfaFader)
        ribbonAlfa = ribbonAlfa -(alfaFader-abs(count*ribbonLength-i))*(alfaFadeDiff)/alfaFader;
      //      else
      //        ribbonAlfa = 255;

      colR = 0;
      colG = 120;
      colB = 150;
      float colorFadeDiffR = -200;
      float colorFadeDiffG = 100;
      float colorFadeDiffB = 150;

      if (i < colorFader) {
        colR = colR -(colorFader-i)*(colorFadeDiffR)/colorFader;
        colG = colG -(colorFader-i)*(colorFadeDiffG)/colorFader;
        colB = colB -(colorFader-i)*(colorFadeDiffB)/colorFader;
        //      else if (count*ribbonLength - i < colorFader)
        //        colR = colR -(colorFader-abs(count*ribbonLength-i))*(colorFadeDiff)/colorFader;
        //      else
        //        colR = 255;
      }
      fill(colR, colG, colB, ribbonAlfa);


      theWidth = widthFadeDiff;

      if (i < widthFader) 
        theWidth = theWidth -(widthFader-i)*(widthFadeDiff)/widthFader;
      //      else 
      //      if (count*ribbonLength - i < colorFader)
      //        theWidth = theWidth -(widthFader-abs(count*ribbonLength-i))*(widthFadeDiff)/widthFader;
      //      else
      //        theWidth = 255;

      noStroke();
      //      stroke(theMeshCol);

      if (isGap[i] == true) {
        vertex(p[i].x, p[i].y, p[i].z);
        vertex(p[i].x, p[i].y, p[i].z);
        endShape();
        beginShape(TRIANGLE_STRIP);
      } 
      else {        
        PVector v1 = PVector.sub(p[i], p[i+1]);
        PVector v2 = PVector.add(p[i+1], p[i]);
        PVector v3 = v1.cross(v2);      
        v2 = v1.cross(v3);
        v1.normalize();
        v2.normalize();
        v3.normalize();

        v1.mult(theWidth);
        v2.mult(theWidth);
        v3.mult(theWidth);

        vertex(p[i].x+v2.x, p[i].y+v2.y, p[i].z+v2.z);
        vertex(p[i].x-v2.x, p[i].y-v2.y, p[i].z-v2.z);
      }
    }
    endShape();
  }

  public void setRandomPostition() {
    ref.x=random(-ribbonSpaceX, ribbonSpaceX);
    ref.y=random(-ribbonSpaceY, ribbonSpaceY);
    ref.z=random(-ribbonSpaceZ, ribbonSpaceZ);
  }
}




abstract class VisualEngine {

  protected PApplet myApplet;
  protected String name;
  protected PImage thumbnail;
  
  public float[] camRotations = new float[3];
  public float[] camLookAt = new float[3];
  public float camDistance;
  
  public VisualEngine(PApplet myApplet, String name) {
    this.myApplet = myApplet;
    this.name = name;
    this.thumbnail = loadImage(name + ".jpg");
  }
  
  public abstract void init();    // setup function
  public abstract void start();
  public abstract void update();  // draw function
  
  public abstract void initGUI(ControlP5 cp5, ControlWindow controlWindow);
  public abstract void showGUI(boolean show);
  public abstract void controlEvent(ControlEvent theControlEvent);
  public abstract void exit();

//  public abstract float[] loadPreset(String dir, String name, int presetNumber);
//  public abstract void savePreset(String dir, String name, int presetNumber, float[] params);
  
  public abstract void mapPresets();
  public abstract void mapMidiInterface();
} 

/*  
 
 amount slider
 voro alfa
 bezier alfa
 stroke alfa
 center alfa
 star on off
 boid speed
 
 
 SOUND INTERACTION 
 
 bezierde ts
 normalde star center color
 
 
 */




boolean showDela;
boolean showVoro;
boolean showBezier;
boolean showStar;
int flockAmount = 10;
float voroAlfa;
float bezierAlfa;
float strokeAlfa;
float centerAlfa; 
float flockSpeed = 3.0f;

int clipX = 2000;
int clipY = 1500;


class Vorovis extends VisualEngine {
  protected ArrayList<controlP5.Controller> controllers;
  String[] parameterNames = { 
    "flockAmount", 
    "showDela", 
    "showVoro", 
    "showBezier", 
    "showStar", 
    "voroAlfa", 
    "strokeAlfa", 
    "centerAlfa", 
    "flockSpeed"
  };

  Voronoi myVoronoi;
  Delaunay myDelaunay;
  Hull myHull;
  Flock flock;

  int numPoints = flockAmount;

  float[][] points;
  float[][] myEdges;
  MPolygon myRegions[], myHullRegion;
  int col[];

  float startX, startY, endX, endY;
  float[][] regionCoordinates;
  float[] regionHeights = new float[200];
  float[] targetHeights = new float[200];
  float[] errorHeights = new float[200];

  float kp = 0.1f;

  int presetSize = parameterNames.length+9;

  float[] parameters1 = new float[presetSize];
  float[] parameters2 = new float[presetSize];
  float[] parameters3 = new float[presetSize];
  float[] parameters4 = new float[presetSize];
  float[] parameters5 = new float[presetSize];
  float[] parameters6 = new float[presetSize];
  float[] parameters7 = new float[presetSize];
  float[] parameters8 = new float[presetSize];
  float[] parametersTemp = new float[presetSize];

  float[] camRotations = new float[3];
  float[] camLookAt = new float[3];
  public float camDistance = 2020.f;

  public Vorovis(PApplet myApplet, String name) {
    super(myApplet, name);
    println("Vorovis Constructor.");
    controllers = new ArrayList<controlP5.Controller>();
  }

  public void init() {
    cam = new PeasyCam(myApplet, 50);
    cam.setMinimumDistance(1);
    cam.setMaximumDistance(5000000);
    background(0);
    perspective(PI/3, width/height, 1, 5000000);

    // initialize points and calculate diagrams
    initFlock();
    updateMesh();
    colorMode(HSB);

    parameters1 =     loadPreset(presetDir, name, 1);
    parameters2 =     loadPreset(presetDir, name, 2);
    parameters3 =     loadPreset(presetDir, name, 3);
    parameters4 =     loadPreset(presetDir, name, 4);
    parameters5 =     loadPreset(presetDir, name, 5);
    parameters6 =     loadPreset(presetDir, name, 6);
    parameters7 =     loadPreset(presetDir, name, 7);
    parameters8 =     loadPreset(presetDir, name, 8);
    cp5.getController("preset5").setValue(1.f);
  }    // setup function

  public void update() {    
    if (midiEnable) {
      mapMidiInterface();
    }

    cam.rotateX(0);
    cam.rotateY(0);
    if (mousePressed) {
      if (mouseButton == LEFT) {
        cam.setActive(false);
      } 
      else {
        cam.setActive(true);
      }
    }


    mapPresets();
    frame.setTitle(PApplet.parseInt(frameRate) + "fps");
    background(0);

    updateMesh();
    drawVoro();

    for (int i = 0; i < flock.boids.size(); i++) {
      Boid bs = (Boid)flock.boids.get(i);
      bs.maxspeed = flockSpeed;
    }
  }  

  public void updateMesh() {

    updateFlock();

    myVoronoi = new Voronoi( flock.bPos );
    myHull = new Hull( flock.bPos );
    myDelaunay = new Delaunay( flock.bPos );

    myRegions = myVoronoi.getRegions();
    myHullRegion = myHull.getRegion();
    myEdges = myDelaunay.getEdges();
  }

  public void initFlock() {
    flock = new Flock();

    for (int i = 0; i < numPoints; i++) {
      flock.addBoid(new Boid(new PVector(0, 0), 3.0f, 0.05f));
    }
  }

  public void updateFlock() {
    numPoints = flockAmount;

    if ((flock.boids.size()-flockAmount)<0) {
      //add
      for (int i = 0; i < abs(flock.boids.size()-flockAmount); i++) {
        flock.addBoid(new Boid(new PVector(0, 0), 3.0f, 0.05f));
      }
    } 
    else if ((flock.boids.size()-flockAmount)>0) {
      //remove
      for (int i = 0; i < abs(flock.boids.size()-flockAmount); i++) {
        flock.removeBoid((Boid)flock.boids.get(i));
      }
    }

    Boid bL = (Boid)flock.boids.get(0);
    bL.seek(new PVector(300*sin(frameCount*0.01f), 300*cos(frameCount*0.01f), 0));
    //    stroke(255);
    //    strokeWeight(10);
    point(bL.loc.x, bL.loc.y, 0);

    flock.run();

    if (bang(1000)) {
      //      stroke(255);
      for (int i = 1; i < abs(flock.boids.size()); i++) {
        Boid bF = (Boid)flock.boids.get(i);
        bF.seek(new PVector(bL.loc.x, bL.loc.y, 0));
        point(bF.loc.x, bF.loc.y, 0);
      }
    } 
    else {
      //      noStroke();
    }
  }



  public void drawVoro() {

    //    if (showPoints) {
    //      for (int i = 0; i < flock.boids.size(); i++) {
    //        stroke(155, 255, 255);
    //        strokeWeight(3);
    //        point(flock.bPos[i][0], flock.bPos[i][1]);
    //      }
    //    }

    stroke(255, strokeAlfa);
    strokeWeight(1);

    for (int i=0; i< myRegions.length; i++) {
      regionCoordinates = myRegions[i].getCoords();
      PVector[] rc = new PVector[regionCoordinates.length];

      for (int j = 0; j < regionCoordinates.length;j++) {
        rc[j] = new PVector(regionCoordinates[j][0], regionCoordinates[j][1]);
      }
      float rcArea = polygonArea(rc);
      float areaMin = 2000;
      float areaMax = 300000;
      if (rcArea > 1000000) {
        fill(0);
      } 
      else {


        if (showVoro) {
          //        fill(map(rcArea, areaMin, areaMax, 0, 255), 255, 255, voroAlfa*soundLevelLPF); // use random color for each region
          fill(map(rcArea, areaMin, areaMax, 0, 255), map(abs(flock.bPos[i][1]), 0, 2000, 255, 0), 255, map(soundLPFBuf[PApplet.parseInt(i*spectrumLength/myRegions.length)], 10, 3000, areaMin, areaMax)-rcArea); // use random color for each region

          beginShape();
          for (int j = 0; j < regionCoordinates.length;j++) {
            vertex(regionCoordinates[j][0], regionCoordinates[j][1], 0);
          }
          endShape(CLOSE);
        }
        if (showStar) {
          beginShape(TRIANGLE_FAN);
          fill(map(rcArea, areaMin, areaMax, 0, 255), 255, 255, centerAlfa); // use random color for each region
          vertex(flock.bPos[i][0], flock.bPos[i][1]);
          for (int j = 0; j < regionCoordinates.length+1;j++) {
            fill(map(rcArea, areaMin, areaMax, 0, 255), 255, 255, voroAlfa); // use random color for each region

            vertex(regionCoordinates[j%regionCoordinates.length][0], regionCoordinates[j%regionCoordinates.length][1], 0);
          }
          endShape(CLOSE);
        }


        if (showBezier) {
          float ts = 0.1f;
          //          ts = map(mouseX, 0, width, 0., 1.);
          //          ts = 0;
          // calculate bezier points
          int nv = regionCoordinates.length;
          float x1, x2, y1, y2, x3, y3;
          beginShape();
          //        fill(map(rcArea,  areaMin, areaMax, 127, 190), 255, 255, bezierAlfa); // use random color for each region
          //          fill(map(rcArea, areaMin, areaMax, 0, 255), map(abs(flock.bPos[i][1]), 0, 2000, 255, 0), 255, map(soundLPFBuf[int(i*spectrumLength/myRegions.length)], 10, 100, areaMin, areaMax)-rcArea); // use random color for each region
          noFill();
          for (int j = 0; j < nv; j++) {
            PVector v1 = new PVector (regionCoordinates[j % nv][0], regionCoordinates[j % nv][1], 0);
            PVector v2 = new PVector (regionCoordinates[(j+1) % nv][0], regionCoordinates[(j+1) % nv][1], 0);
            PVector v3 = new PVector (regionCoordinates[(j+2) % nv][0], regionCoordinates[(j+2) % nv][1], 0);
            x1 =  lerp(lerp(v1.x, v2.x, 0.5f), flock.bPos[i][0], ts);
            y1 =  lerp(lerp(v1.y, v2.y, 0.5f), flock.bPos[i][1], ts);
            x2 =  lerp(v2.x, flock.bPos[i][0], ts);
            y2 =  lerp(v2.y, flock.bPos[i][1], ts);
            x3 =  lerp(lerp(v2.x, v3.x, 0.5f), flock.bPos[i][0], ts);
            y3 =  lerp(lerp(v2.y, v3.y, 0.5f), flock.bPos[i][1], ts);
            // evaluate bezier curve in 10 different points
            for (int k = 0; k < 10; k++) {
              float tt = k / (float) 10;
              float xpos = (1.0f - tt) * ( lerp(x1, x2, tt)) + tt
                * ( lerp(x2, x3, tt));
              float ypos = (1.0f - tt) * ( lerp(y1, y2, tt)) + tt
                * ( lerp(y2, y3, tt));
              vertex(xpos, ypos, 0);
            }
          }
          endShape(CLOSE);
        }
      }
    }



    // draw Voronoi as lines
    if (showDela) {
      strokeWeight(2);
      stroke(255, strokeAlfa);
      for (int i=0; i< myEdges.length; i++) {
        startX = myEdges[i][0];
        startY = myEdges[i][1];
        endX = myEdges[i][2];
        endY = myEdges[i][3];
        line(startX, startY, endX, endY);
      }
    }
  }


  int timer = 0;
  int timerPre = 0;
  public boolean bang(int dur) {
    timer = millis();
    if ((timer - timerPre)>dur) {
      timerPre = timer;
      return true;
    } 
    else {
      return false;
    }
  }



  public void initGUI(ControlP5 cp5, ControlWindow controlWindow) {
    int vorovisGUISep = 30;
    int rowIndex;
    int columnIndex;
    int[] parameterMatrix = {
      5, 5
    };    

    PVector[][] parameterPos = new PVector[parameterMatrix.length][max(parameterMatrix)]; 
    PVector[] parameterSize = new PVector[parameterMatrix.length]; 

    for (int i = 0; i < parameterMatrix.length; i++) {
      for (int j = 0; j < parameterMatrix[i]; j++) {
        parameterPos[i][j] = new PVector(visualSpecificParametersBoxX + (visualSpecificParametersBoxWidth/(parameterMatrix[i]*2)*(j*2+1)), visualSpecificParametersBoxY +(visualSpecificParametersBoxHeight/(parameterMatrix.length*2)*(i*2+1)));
        parameterSize[i] = new PVector((visualSpecificParametersBoxWidth/parameterMatrix[i])-vorovisGUISep, (visualSpecificParametersBoxHeight/parameterMatrix.length)-vorovisGUISep);
        rectMode(CORNER);
      }
    }

    rowIndex = 0; 

    columnIndex = 0; 
    cp5.addKnob("flockAmount")
      .setPosition(knobPosX[0]+visualSpecificParametersBoxX-knobWidth, knobPosY[0]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(10, 150)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("FLOCK AMOUNT")    
                  .setWindow(controlWindow);
    columnIndex = 1; 
    cp5.addToggle("showDela")
      .setPosition(mRectPosX[0]+visualSpecificParametersBoxX, mRectPosY[0]+visualSpecificParametersBoxY)   
        .setColorValueLabel(valueLabel)
          .setSize(mRectWidth, mRectHeight)
            .setValue(false)
              .setCaptionLabel("DELAUNAY")    
                .setWindow(controlWindow);
    cp5.getController("showDela").captionLabel().getStyle().marginLeft = -12;

    columnIndex = 2; 
    cp5.addToggle("showVoro")
      .setPosition(mRectPosX[1]+visualSpecificParametersBoxX, mRectPosY[1]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setColorValueLabel(valueLabel)
            .setValue(true)
              .setCaptionLabel("VORONOI")    
                .setWindow(controlWindow);
    cp5.getController("showVoro").captionLabel().getStyle().marginLeft = -7;

    columnIndex = 3; 
    cp5.addToggle("showBezier")
      .setPosition(mRectPosX[2]+visualSpecificParametersBoxX, mRectPosY[2]+visualSpecificParametersBoxY)   
        .setColorValueLabel(valueLabel)
          .setSize(mRectWidth, mRectHeight)
            .setValue(false)
              .setCaptionLabel("BEZIER")    
                .setWindow(controlWindow);
    cp5.getController("showBezier").captionLabel().getStyle().marginLeft = -3;

    columnIndex = 4; 
    cp5.addToggle("showStar")
      .setPosition(mRectPosX[3]+visualSpecificParametersBoxX, mRectPosY[3]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setColorValueLabel(valueLabel)
            .setValue(false)
              .setCaptionLabel("STAR")    
                .setWindow(controlWindow);
    cp5.getController("showStar").captionLabel().getStyle().marginLeft = 0;

    rowIndex = 1; 
    columnIndex = 0; 
    cp5.addSlider("flockSpeed")
      .setPosition(sliderPosX[0]+visualSpecificParametersBoxX, sliderPosY[0]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.01f, 100.f)
            .setValue(3.f)
              .setCaptionLabel("SPEED")    
                .setWindow(controlWindow);
    cp5.getController("flockSpeed").captionLabel().getStyle().marginLeft = -3;

    columnIndex = 1; 
    cp5.addSlider("voroAlfa")
      .setPosition(sliderPosX[1]+visualSpecificParametersBoxX, sliderPosY[1]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.f, 255.f )
            .setCaptionLabel("      VORONOI\n TRANSPARENCY")    
              .setWindow(controlWindow);
    cp5.getController("voroAlfa").captionLabel().getStyle().marginLeft = -27;

    columnIndex = 3; 
    cp5.addSlider("strokeAlfa")
      .setPosition(sliderPosX[2]+visualSpecificParametersBoxX, sliderPosY[2]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.f, 255.f )
            .setCaptionLabel("         LINE\n TRANSPARENCY")    
              .setWindow(controlWindow);
    cp5.getController("strokeAlfa").captionLabel().getStyle().marginLeft = -24;

    columnIndex = 4; 
    cp5.addSlider("centerAlfa")
      .setPosition(sliderPosX[3]+visualSpecificParametersBoxX, sliderPosY[3]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.f, 255.f )
            .setCaptionLabel("       CENTER\n TRANSPARENCY")    
              .setWindow(controlWindow);
    cp5.getController("centerAlfa").captionLabel().getStyle().marginLeft = -27;


    for (int i = 0; i < parameterNames.length; i++) {
      cp5.getController(parameterNames[i])
        .getCaptionLabel()
          .setFont(fontLight)
            //            .toUpperCase(false)
            .setSize(15);
      controllers.add(cp5.getController(parameterNames[i]));
    }

    showGUI(false);
  }


  public void controlEvent(ControlEvent theControlEvent) {
  }


  public void mapPresets() {

    if (preset1 && !preset1Pre) {
      presetIndex = 1;
      parameters1 =     loadPreset(presetDir, name, 1);
      cam.lookAt(parameters1[0], parameters1[1], parameters1[2]);
      cam.setRotations(parameters1[3], parameters1[4], parameters1[5]);
      cam.setDistance(parameters1[6]);
      cp5.getController("gain").setValue(parameters1[7]);
      cp5.getController("decay").setValue(parameters1[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters1[i]);
      }
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset2 && !preset2Pre) {
      presetIndex = 2;
      parameters2 =     loadPreset(presetDir, name, 2);
      cam.lookAt(parameters2[0], parameters2[1], parameters2[2]);
      cam.setRotations(parameters2[3], parameters2[4], parameters2[5]);
      cam.setDistance(parameters2[6]);
      cp5.getController("gain").setValue(parameters2[7]);
      cp5.getController("decay").setValue(parameters2[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters2[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset3 && !preset3Pre) {
      presetIndex = 3;
      parameters3 =     loadPreset(presetDir, name, 3);
      cam.lookAt(parameters3[0], parameters3[1], parameters3[2]);
      cam.setRotations(parameters3[3], parameters3[4], parameters3[5]);
      cam.setDistance(parameters3[6]);
      cp5.getController("gain").setValue(parameters3[7]);
      cp5.getController("decay").setValue(parameters3[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters3[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset4 && !preset4Pre) {
      presetIndex = 4;
      parameters4 =     loadPreset(presetDir, name, 4);
      cam.lookAt(parameters4[0], parameters4[1], parameters4[2]);
      cam.setRotations(parameters4[3], parameters4[4], parameters4[5]);
      cam.setDistance(parameters4[6]);
      cp5.getController("gain").setValue(parameters4[7]);
      cp5.getController("decay").setValue(parameters4[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters4[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset5 && !preset5Pre) {
      presetIndex = 5;
      parameters5 =     loadPreset(presetDir, name, 5);
      cam.lookAt(parameters5[0], parameters5[1], parameters5[2]);
      cam.setRotations(parameters5[3], parameters5[4], parameters5[5]);
      cam.setDistance(parameters5[6]);
      cp5.getController("gain").setValue(parameters5[7]);
      cp5.getController("decay").setValue(parameters5[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters5[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset6 && !preset6Pre) {
      presetIndex = 6;
      parameters6 =     loadPreset(presetDir, name, 6);
      cam.lookAt(parameters6[0], parameters6[1], parameters6[2]);
      cam.setRotations(parameters6[3], parameters6[4], parameters6[5]);
      cam.setDistance(parameters6[6]);
      cp5.getController("gain").setValue(parameters6[7]);
      cp5.getController("decay").setValue(parameters6[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters6[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset7 && !preset7Pre) {
      presetIndex = 7;
      parameters7 =     loadPreset(presetDir, name, 7);
      cam.lookAt(parameters7[0], parameters7[1], parameters7[2]);
      cam.setRotations(parameters7[3], parameters7[4], parameters7[5]);
      cam.setDistance(parameters7[6]);
      cp5.getController("gain").setValue(parameters7[7]);
      cp5.getController("decay").setValue(parameters7[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters7[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset8 && !preset8Pre) {
      presetIndex = 8;
      parameters8 =     loadPreset(presetDir, name, 8);
      cam.lookAt(parameters8[0], parameters8[1], parameters8[2]);
      cam.setRotations(parameters8[3], parameters8[4], parameters8[5]);
      cam.setDistance(parameters8[6]);
      cp5.getController("gain").setValue(parameters8[7]);
      cp5.getController("decay").setValue(parameters8[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters8[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
    } 
    else if ( savePreset && !savePresetPre) {
      parametersTemp[0] = cam.getLookAt()[0];
      parametersTemp[1] = cam.getLookAt()[1];
      parametersTemp[2] = cam.getLookAt()[2];
      parametersTemp[3] = cam.getRotations()[0];
      parametersTemp[4] = cam.getRotations()[1];
      parametersTemp[5] = cam.getRotations()[2];
      parametersTemp[6] = (float)cam.getDistance();
      parametersTemp[7] = cp5.getController("gain").getValue();
      parametersTemp[8] = cp5.getController("decay").getValue();
      for (int i = 9; i < presetSize; i++) {
        parametersTemp[i] = cp5.getController(parameterNames[i-9]).getValue();
      }
      savePreset(presetDir, name, presetIndex, parametersTemp) ;
    } 
    else if ((!preset1 && !preset2 && !preset3 && !preset4 && !preset5 && !preset6 && !preset7 && !preset8)) {
      presetIndex = 0;
    }

    preset1Pre = preset1;
    preset2Pre = preset2;
    preset3Pre = preset3;
    preset4Pre = preset4;
    preset5Pre = preset5;
    preset6Pre = preset6;
    preset7Pre = preset7;
    preset8Pre = preset8;    
    savePresetPre = savePreset;
  }

  public void showGUI(boolean show) {
    for (controlP5.Controller c: controllers) {
      c.setVisible(show);
    }
  }

  public void mapMidiInterface() {

    cp5.getController("flockSpeed").setValue(cp5.getController("flockSpeed").getValue()+(map(   faderValDiff[0], 0, 127, 0, cp5.getController("flockSpeed").getMax()-cp5.getController("flockSpeed").getMin())));
    cp5.getController("voroAlfa").setValue(cp5.getController("voroAlfa").getValue()+(map(     faderValDiff[1], 0, 127, 0, cp5.getController("voroAlfa").getMax()-cp5.getController("voroAlfa").getMin())));
    cp5.getController("strokeAlfa").setValue(cp5.getController("strokeAlfa").getValue()+(map(   faderValDiff[2], 0, 127, 0, cp5.getController("strokeAlfa").getMax()-cp5.getController("strokeAlfa").getMin())));
    cp5.getController("centerAlfa").setValue(cp5.getController("centerAlfa").getValue()+(map(   faderValDiff[3], 0, 127, 0, cp5.getController("centerAlfa").getMax()-cp5.getController("centerAlfa").getMin())));

    cp5.getController("flockAmount").setValue(cp5.getController("flockAmount").getValue()+(map(  knobValDiff[0], 0, 127, 0, cp5.getController("flockAmount").getMax()-cp5.getController("flockAmount").getMin())));

    cp5.getController("showDela").setValue((cp5.getController("showDela").getValue()+abs(buttonsMValDiff[0]))%2);
    cp5.getController("showVoro").setValue((cp5.getController("showVoro").getValue()+abs(buttonsMValDiff[8]))%2);
    cp5.getController("showBezier").setValue((cp5.getController("showBezier").getValue()+abs(buttonsMValDiff[16]))%2);
    cp5.getController("showStar").setValue((cp5.getController("showStar").getValue()+abs(buttonsMValDiff[1]))%2);
  }

  public void start() {
    println("Starting " + name);
    hint(ENABLE_DEPTH_TEST);
    colorMode(HSB);
    camDistance = 2020.f;
    cam.lookAt(camLookAt[0], camLookAt[1], camLookAt[2]);
    cam.setRotations(camRotations[0], camRotations[1], camRotations[2]);
    cam.setDistance(camDistance);
    //    lights();
  }

  public void exit() {
    println("Exitting " + name);
    //    getCamMatrix(camLookAt, camRotations, camDistance);

    camLookAt[0] = cam.getLookAt()[0];
    camLookAt[1] = cam.getLookAt()[1];
    camLookAt[2] = cam.getLookAt()[2];

    camRotations[0] = cam.getRotations()[0];
    camRotations[1] = cam.getRotations()[1];
    camRotations[2] = cam.getRotations()[2];

    camDistance = (float)cam.getDistance();
  }
}


// The Boid class

class Boid {

  PVector loc;
  PVector vel;
  PVector acc;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed

    Boid(PVector l, float ms, float mf) {
    acc = new PVector(0, 0);
    vel = new PVector(random(-1, 1), random(-1, 1));
    loc = l.get();
    r = 2.0f;
    maxspeed = ms;
    maxforce = mf;
  }

  public void setForceSpeed(float speed, float force) {
    maxspeed = speed;
    maxforce = force;
  }

  public void run(ArrayList boids) {
    flock(boids);
    update();
    borders();
    //    render();
  }

  // We accumulate a new acceleration each time based on three rules
  public void flock(ArrayList boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(1.5f);
    ali.mult(1.0f);
    coh.mult(1.0f);
    // Add the force vectors to acceleration
    acc.add(sep);
    acc.add(ali);
    acc.add(coh);
  }

  // Method to update location
  public void update() {
    // Update velocity
    vel.add(acc);
    // Limit speed
    vel.limit(maxspeed);
    loc.add(vel);
    // Reset accelertion to 0 each cycle
    acc.mult(0);
  }

  public void seek(PVector target) {
    acc.add(steer(target, false));
  }

  public void arrive(PVector target) {
    acc.add(steer(target, true));
  }

  // A method that calculates a steering vector towards a target
  // Takes a second argument, if true, it slows down as it approaches the target
  public PVector steer(PVector target, boolean slowdown) {
    PVector steer;  // The steering vector
    PVector desired = target.sub(target, loc);  // A vector pointing from the location to the target
    float d = desired.mag(); // Distance from the target is the magnitude of the vector
    // If the distance is greater than 0, calc steering (otherwise return zero vector)
    if (d > 0) {
      // Normalize desired
      desired.normalize();
      // Two options for desired vector magnitude (1 -- based on distance, 2 -- maxspeed)
      if ((slowdown) && (d < 100.0f)) desired.mult(maxspeed*(d/100.0f)); // This damping is somewhat arbitrary
      else desired.mult(maxspeed);
      // Steering = Desired minus Velocity
      steer = target.sub(desired, vel);
      steer.limit(maxforce);  // Limit to maximum steering force
    } 
    else {
      steer = new PVector(0, 0);
    }
    return steer;
  }

  public void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = vel.heading2D() + PI/2;
    fill(200, 100);
    stroke(255);
    pushMatrix();
    translate(loc.x, loc.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
  }

  // Wraparound
  public void borders() {

    int bLeft = -clipX;
    int bRight = clipX;
    int bTop = -clipY;
    int bBottom = clipY;


    //    if (loc.x < bLeft-r) loc.x = bRight+r;
    //    if (loc.y < bTop-r) loc.y = bBottom+r;
    //    if (loc.x > bRight+r) loc.x = bLeft-r;
    //    if (loc.y > bBottom+r) loc.y = bTop-r;

    if (loc.x < bLeft-r || loc.x > bRight+r) {
      vel.x = -vel.x;
    }
    if (loc.y < bTop-r || loc.y > bBottom+r) {
      vel.y = -vel.y;
    }
  }

  // Separation
  // Method checks for nearby boids and steers away
  public PVector separate (ArrayList boids) {
    float desiredseparation = 20.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = PVector.dist(loc, other.loc);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(loc, other.loc);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(vel);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  public PVector align (ArrayList boids) {
    float neighbordist = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = PVector.dist(loc, other.loc);
      if ((d > 0) && (d < neighbordist)) {
        steer.add(other.vel);
        count++;
      }
    }
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(vel);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  public PVector cohesion (ArrayList boids) {
    float neighbordist = 25.0f;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = loc.dist(other.loc);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.loc); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      return steer(sum, false);  // Steer towards the location
    }
    return sum;
  }
}

// The Flock (a list of Boid objects)

class Flock {
  ArrayList boids; // An arraylist for all the boids
  public float[][] bPos;
  Flock() {
    boids = new ArrayList(); // Initialize the arraylist
  }

  public void run() {
    bPos = new float[boids.size()][2];
    for (int i = 0; i < boids.size(); i++) {
      Boid b = (Boid) boids.get(i);  
      b.run(boids);  // Passing the entire list of boids to each boid individually
      bPos[i][0] = b.loc.x;
      bPos[i][1] = b.loc.y;
    }
  }

  public void setFS( float sp, float f) {
    for (int i = 0; i < boids.size(); i++) {
      Boid b = (Boid) boids.get(i);  
      b.setForceSpeed(sp, f);  // Passing the entire list of boids to each boid individually
    }
  }

  public void addBoid(Boid b) {
    boids.add(b);
  }

  public void removeBoid(Boid b) {
    boids.remove(b);
  }
}

/*

 renk
 ses smoothness
 torus knot veya noise
 
 */


float rad = 200;
float Rad = 500;
float th;
float ph;
int rRes = 40;
int RRes = 20;
float wireRotX = 0.f;
float wireRotY = 0.f;
boolean wireRotStopX = false;
boolean wireRotStopY = false;
float x, y, z;
float rotIncX = 0.f;
float rotX = 0.f;
float rotIncY = 0.f;
float rotY = 0.f;
boolean rotYStop = false;
class Wireframe extends VisualEngine {
  protected ArrayList<controlP5.Controller> controllers;
  String[] parameterNames = {
    "rad", 
    "Rad", 
    "th", 
    "ph", 
    "rRes", 
    "RRes", 
    "rotIncX", 
    "rotIncY", 
    "wireRotX", 
    "wireRotY", 
    "wireRotStopX", 
    "rotYStop", 
    "wireRotStopY"
  };

  int presetSize = parameterNames.length+9;

  float[] parameters1 = new float[presetSize];
  float[] parameters2 = new float[presetSize];
  float[] parameters3 = new float[presetSize];
  float[] parameters4 = new float[presetSize];
  float[] parameters5 = new float[presetSize];
  float[] parameters6 = new float[presetSize];
  float[] parameters7 = new float[presetSize];
  float[] parameters8 = new float[presetSize];
  float[] parametersTemp = new float[presetSize];

  float[] camRotations = new float[3];
  float[] camLookAt = new float[3];
  public float camDistance;

  float theta;
  float phi;

  public Wireframe(PApplet myApplet, String name) {
    super(myApplet, name);
    println("Wireframe Constructor.");
    controllers = new ArrayList<controlP5.Controller>();
  }

  public void init() {
    cam = new PeasyCam(myApplet, 50);
    cam.setMinimumDistance(1);
    cam.setMaximumDistance(5000000);
    background(0);
    perspective(PI/3, width/height, 1, 5000000);

    colorMode(RGB);
    parameters1 =     loadPreset(presetDir, name, 1);
    parameters2 =     loadPreset(presetDir, name, 2);
    parameters3 =     loadPreset(presetDir, name, 3);
    parameters4 =     loadPreset(presetDir, name, 4);
    parameters5 =     loadPreset(presetDir, name, 5);
    parameters6 =     loadPreset(presetDir, name, 6);
    parameters7 =     loadPreset(presetDir, name, 7);
    parameters8 =     loadPreset(presetDir, name, 8);
    cp5.getController("preset5").setValue(1.f);
  }    // setup function

  public void update() {    
    if (midiEnable) {
      mapMidiInterface();
    }
    mapPresets();
    frame.setTitle(PApplet.parseInt(frameRate) + "fps");
    background(0);
    if (!wireRotStopX) {
      cam.rotateX(wireRotX);
    }
    if (!wireRotStopY) {
      cam.rotateY(wireRotY);
    }

    rotX += rotIncX;
    if (!rotYStop) {
      rotY += rotIncY;
    }

    //    float wireSoundVal = fftVar[0].getValue();
    float inLevelMax = 10.f;
    float inLevelMin = 0.f;

    colorMode(RGB);
    for (int i = 0; i < RRes; i++) {
      beginShape();
      fill(0, 0, 0);

      for (int j = 0; j < rRes; j++) {
        theta = (map(i, 0, RRes, 0, TWO_PI*th)+rotX)%TWO_PI;
        //      theta = (map(i, 0, RRes, 0, TWO_PI));
        //        phi = map(j, 0, rRes, 0, TWO_PI);
        phi = (map(j, 0, rRes, 0, TWO_PI*ph)+rotY)%TWO_PI;
        float soundData = 1+(soundLPFBuf[PApplet.parseInt(j*spectrumLength/rRes)])*gain;

        x = (Rad+soundData*rad*cos(phi))*cos(theta);
        z = (Rad+soundData*rad*cos(phi))*sin(theta);
        y = soundData*rad*sin(phi);

        strokeWeight(2);
        stroke((map(soundData, inLevelMin, inLevelMax, 255, 0)), 
        (map(soundData, inLevelMin, inLevelMax, 120, 170)), 
        (map(soundData, inLevelMin, inLevelMax, 0, 170)));
        noStroke();
        vertex(x, y, z);
      }
      endShape(CLOSE);
    }

    for (int i = 0; i < RRes; i++) {
      beginShape(LINES);
      //      fill(0, 0, 0);
      noFill();
      for (int j = 0; j < rRes; j++) {
        theta = (map(i, 0, RRes, 0, TWO_PI*th)+rotX)%TWO_PI;
        //      theta = (map(i, 0, RRes, 0, TWO_PI));
        //        phi = map(j, 0, rRes, 0, TWO_PI);
        phi = (map(j, 0, rRes, 0, TWO_PI*ph)+rotY)%TWO_PI;
        float soundData = 1+(soundLPFBuf[PApplet.parseInt(j*spectrumLength/rRes)])*gain;

        x = (Rad+soundData*rad*cos(phi))*cos(theta);
        z = (Rad+soundData*rad*cos(phi))*sin(theta);
        y = soundData*rad*sin(phi);

        strokeWeight(2);
        stroke((map(soundData, inLevelMin, inLevelMax, 255, 0)), 
        (map(soundData, inLevelMin, inLevelMax, 120, 170)), 
        (map(soundData, inLevelMin, inLevelMax, 0, 170)));

        vertex(x, y, z);
      }
      endShape(CLOSE);
    }
  }  

  float lpfOutPre;
  float lpfOut;

  public float LPF(float in) {
    lpfOut = (decay * in + (1-decay) * lpfOutPre)*gain;
    lpfOutPre = lpfOut;
    return lpfOut;
  }

  int timer = 0;
  int timerPre = 0;
  public boolean bang(int dur) {
    timer = millis();
    if ((timer - timerPre)>dur) {
      timerPre = timer;
      return true;
    } 
    else {
      return false;
    }
  }



  public void initGUI(ControlP5 cp5, ControlWindow controlWindow) {

    //    "rad", 
    //    "Rad", 
    //    "rRes", 
    //    "RRes", 
    //    "th", 
    //    "ph", 
    //    "rotInc"

    cp5.addKnob("rad")
      .setPosition(knobPosX[0]+visualSpecificParametersBoxX-knobWidth, knobPosY[0]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(10, 350)
            .setColorValueLabel(valueLabel)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("INNER RADIUS")    
                  .setWindow(controlWindow);

    cp5.addKnob("Rad")
      .setPosition(knobPosX[1]+visualSpecificParametersBoxX-knobWidth, knobPosY[1]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(10, 350)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("OUTER RADIUS")    
                  .setWindow(controlWindow);

    cp5.addKnob("rRes")
      .setPosition(knobPosX[2]+visualSpecificParametersBoxX-knobWidth, knobPosY[2]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(5, 150)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("V. RES.")    
                  .setWindow(controlWindow);

    cp5.addKnob("RRes")
      .setPosition(knobPosX[3]+visualSpecificParametersBoxX-knobWidth, knobPosY[3]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(1, 150)
            .setColorValueLabel(valueLabel)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("H. RES.")    
                  .setWindow(controlWindow);

    cp5.addKnob("wireRotX")
      .setPosition(knobPosX[4]+visualSpecificParametersBoxX-knobWidth, knobPosY[4]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(-0.05f, 0.05f)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("V. ROT.")    
                  .setWindow(controlWindow);

    cp5.addKnob("wireRotY")
      .setPosition(knobPosX[5]+visualSpecificParametersBoxX-knobWidth, knobPosY[5]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(-0.05f, 0.05f)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("H. ROT.")    
                  .setWindow(controlWindow);

    cp5.addSlider("th")
      .setPosition(sliderPosX[0]+visualSpecificParametersBoxX, sliderPosY[0]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.f, 1.f)
            .setCaptionLabel("H. SLICE")    
              .setWindow(controlWindow);              
    cp5.getController("th").captionLabel().getStyle().marginLeft = -5;

    cp5.addSlider("ph")
      .setPosition(sliderPosX[1]+visualSpecificParametersBoxX, sliderPosY[1]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.f, 1.f )
            .setCaptionLabel("V. SLICE")    
              .setWindow(controlWindow);              
    cp5.getController("ph").captionLabel().getStyle().marginLeft = -5;

    cp5.addSlider("rotIncX")
      .setPosition(sliderPosX[2]+visualSpecificParametersBoxX, sliderPosY[2]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(-0.05f, 0.05f )
            .setCaptionLabel("SELF V. ROT.")    
              .setWindow(controlWindow);              
    cp5.getController("rotIncX").captionLabel().getStyle().marginLeft = -15;

    cp5.addSlider("rotIncY")
      .setPosition(sliderPosX[3]+visualSpecificParametersBoxX, sliderPosY[3]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(-0.05f, 0.05f )
            .setCaptionLabel("SELF H. ROT.")    
              .setWindow(controlWindow);  
    cp5.getController("rotIncY").captionLabel().getStyle().marginLeft = -15;

    cp5.addToggle("wireRotStopX")
      .setPosition(mRectPosX[0]+visualSpecificParametersBoxX, mRectPosY[0]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setCaptionLabel("STOP V. ROT.")    
              .setWindow(controlWindow);
    cp5.getController("wireRotStopX").captionLabel().getStyle().marginLeft = -15;

    cp5.addToggle("wireRotStopY")
      .setPosition(mRectPosX[1]+visualSpecificParametersBoxX, mRectPosY[1]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setCaptionLabel("STOP H. ROT.")    
              .setWindow(controlWindow);
    cp5.getController("wireRotStopY").captionLabel().getStyle().marginLeft = -15;

    cp5.addToggle("rotYStop")
      .setPosition(mRectPosX[9]+visualSpecificParametersBoxX, mRectPosY[9]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setCaptionLabel("STOP SELF ROT.")    
              .setWindow(controlWindow);
    cp5.getController("rotYStop").captionLabel().getStyle().marginLeft = -17;

    for (int i = 0; i < parameterNames.length; i++) {
      cp5.getController(parameterNames[i])
        .getCaptionLabel()
          .setFont(fontLight)
            //            .toUpperCase(false)
            .setSize(15);
      controllers.add(cp5.getController(parameterNames[i]));
    }

    showGUI(false);
  }


  public void controlEvent(ControlEvent theControlEvent) {
  }


  public void mapPresets() {

    if (preset1 && !preset1Pre) {
      presetIndex = 1;
      parameters1 =     loadPreset(presetDir, name, 1);
      cam.lookAt(parameters1[0], parameters1[1], parameters1[2]);
      cam.setRotations(parameters1[3], parameters1[4], parameters1[5]);
      cam.setDistance(parameters1[6]);
      cp5.getController("gain").setValue(parameters1[7]);
      cp5.getController("decay").setValue(parameters1[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters1[i]);
      }
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset2 && !preset2Pre) {
      presetIndex = 2;
      parameters2 =     loadPreset(presetDir, name, 2);
      cam.lookAt(parameters2[0], parameters2[1], parameters2[2]);
      cam.setRotations(parameters2[3], parameters2[4], parameters2[5]);
      cam.setDistance(parameters2[6]);
      cp5.getController("gain").setValue(parameters2[7]);
      cp5.getController("decay").setValue(parameters2[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters2[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset3 && !preset3Pre) {
      presetIndex = 3;
      parameters3 =     loadPreset(presetDir, name, 3);
      cam.lookAt(parameters3[0], parameters3[1], parameters3[2]);
      cam.setRotations(parameters3[3], parameters3[4], parameters3[5]);
      cam.setDistance(parameters3[6]);
      cp5.getController("gain").setValue(parameters3[7]);
      cp5.getController("decay").setValue(parameters3[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters3[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset4 && !preset4Pre) {
      presetIndex = 4;
      parameters4 =     loadPreset(presetDir, name, 4);
      cam.lookAt(parameters4[0], parameters4[1], parameters4[2]);
      cam.setRotations(parameters4[3], parameters4[4], parameters4[5]);
      cam.setDistance(parameters4[6]);
      cp5.getController("gain").setValue(parameters4[7]);
      cp5.getController("decay").setValue(parameters4[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters4[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    } 
    else     if (preset5 && !preset5Pre) {
      presetIndex = 5;
      parameters5 =     loadPreset(presetDir, name, 5);
      cam.lookAt(parameters5[0], parameters5[1], parameters5[2]);
      cam.setRotations(parameters5[3], parameters5[4], parameters5[5]);
      cam.setDistance(parameters5[6]);
      cp5.getController("gain").setValue(parameters5[7]);
      cp5.getController("decay").setValue(parameters5[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters5[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset6 && !preset6Pre) {
      presetIndex = 6;
      parameters6 =     loadPreset(presetDir, name, 6);
      cam.lookAt(parameters6[0], parameters6[1], parameters6[2]);
      cam.setRotations(parameters6[3], parameters6[4], parameters6[5]);
      cam.setDistance(parameters6[6]);
      cp5.getController("gain").setValue(parameters6[7]);
      cp5.getController("decay").setValue(parameters6[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters6[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset7 && !preset7Pre) {
      presetIndex = 7;
      parameters7 =     loadPreset(presetDir, name, 7);
      cam.lookAt(parameters7[0], parameters7[1], parameters7[2]);
      cam.setRotations(parameters7[3], parameters7[4], parameters7[5]);
      cam.setDistance(parameters7[6]);
      cp5.getController("gain").setValue(parameters7[7]);
      cp5.getController("decay").setValue(parameters7[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters7[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset8").setValue(0.f);
    }     
    else     if (preset8 && !preset8Pre) {
      presetIndex = 8;
      parameters8 =     loadPreset(presetDir, name, 8);
      cam.lookAt(parameters8[0], parameters8[1], parameters8[2]);
      cam.setRotations(parameters8[3], parameters8[4], parameters8[5]);
      cam.setDistance(parameters8[6]);
      cp5.getController("gain").setValue(parameters8[7]);
      cp5.getController("decay").setValue(parameters8[8]);
      for (int i = 9; i < presetSize; i++) {
        cp5.getController(parameterNames[i-9]).setValue(parameters8[i]);
      }
      cp5.getController("preset1").setValue(0.f);
      cp5.getController("preset2").setValue(0.f);
      cp5.getController("preset3").setValue(0.f);
      cp5.getController("preset4").setValue(0.f);
      cp5.getController("preset5").setValue(0.f);
      cp5.getController("preset6").setValue(0.f);
      cp5.getController("preset7").setValue(0.f);
    } 
    else if ( savePreset && !savePresetPre) {
      parametersTemp[0] = cam.getLookAt()[0];
      parametersTemp[1] = cam.getLookAt()[1];
      parametersTemp[2] = cam.getLookAt()[2];
      parametersTemp[3] = cam.getRotations()[0];
      parametersTemp[4] = cam.getRotations()[1];
      parametersTemp[5] = cam.getRotations()[2];
      parametersTemp[6] = (float)cam.getDistance();
      parametersTemp[7] = cp5.getController("gain").getValue();
      parametersTemp[8] = cp5.getController("decay").getValue();
      for (int i = 9; i < presetSize; i++) {
        parametersTemp[i] = cp5.getController(parameterNames[i-9]).getValue();
      }
      savePreset(presetDir, name, presetIndex, parametersTemp) ;
    } 
    else if ((!preset1 && !preset2 && !preset3 && !preset4 && !preset5 && !preset6 && !preset7 && !preset8)) {
      presetIndex = 0;
    }

    preset1Pre = preset1;
    preset2Pre = preset2;
    preset3Pre = preset3;
    preset4Pre = preset4;
    preset5Pre = preset5;
    preset6Pre = preset6;
    preset7Pre = preset7;
    preset8Pre = preset8;    
    savePresetPre = savePreset;
  }

  public void showGUI(boolean show) {
    for (controlP5.Controller c: controllers) {
      c.setVisible(show);
    }
  }

  public void mapMidiInterface() {

    cp5.getController("rad").setValue(cp5.getController("rad").getValue()+(map(   knobValDiff[0], 0, 127, 0, cp5.getController("rad").getMax()-cp5.getController("rad").getMin())));
    cp5.getController("Rad").setValue(cp5.getController("Rad").getValue()+(map(   knobValDiff[1], 0, 127, 0, cp5.getController("Rad").getMax()-cp5.getController("Rad").getMin())));
    cp5.getController("rRes").setValue(cp5.getController("rRes").getValue()+(map(  knobValDiff[2], 0, 127, 0, cp5.getController("rRes").getMax()-cp5.getController("rRes").getMin())));
    cp5.getController("RRes").setValue(cp5.getController("RRes").getValue()+(map(  knobValDiff[3], 0, 127, 0, cp5.getController("RRes").getMax()-cp5.getController("RRes").getMin())));
    cp5.getController("wireRotX").setValue(cp5.getController("wireRotX").getValue()+(map(  knobValDiff[4], 0, 127, 0, cp5.getController("wireRotX").getMax()-cp5.getController("wireRotX").getMin())));
    cp5.getController("wireRotY").setValue(cp5.getController("wireRotY").getValue()+(map(  knobValDiff[5], 0, 127, 0, cp5.getController("wireRotY").getMax()-cp5.getController("wireRotY").getMin())));

    cp5.getController("th").setValue(cp5.getController("th").getValue()+(map(         faderValDiff[0], 0, 127, 0, cp5.getController("th").getMax()-cp5.getController("th").getMin())));
    cp5.getController("ph").setValue(cp5.getController("ph").getValue()+(map(         faderValDiff[1], 0, 127, 0, cp5.getController("ph").getMax()-cp5.getController("ph").getMin())));
    cp5.getController("rotIncX").setValue(cp5.getController("rotIncX").getValue()+(map(   faderValDiff[2], 0, 127, 0, cp5.getController("rotIncX").getMax()-cp5.getController("rotIncX").getMin())));
    cp5.getController("rotIncY").setValue(cp5.getController("rotIncY").getValue()+(map(   faderValDiff[3], 0, 127, 0, cp5.getController("rotIncY").getMax()-cp5.getController("rotIncY").getMin())));

    cp5.getController("wireRotStopX").setValue((cp5.getController("wireRotStopX").getValue()+abs(buttonsMValDiff[0]))%2);
    cp5.getController("wireRotStopY").setValue((cp5.getController("wireRotStopY").getValue()+abs(buttonsMValDiff[8]))%2);
    cp5.getController("rotYStop").setValue((cp5.getController("rotYStop").getValue()+abs(buttonsMValDiff[3]))%2);
  }

  public void start() {
    println("Starting " + name);
    hint(ENABLE_DEPTH_TEST);
    colorMode(RGB);
    cam.lookAt(camLookAt[0], camLookAt[1], camLookAt[2]);
    cam.setRotations(camRotations[0], camRotations[1], camRotations[2]);
    cam.setDistance(camDistance);
    //    lights();
  }

  public void exit() {
    println("Exitting " + name);
    //    getCamMatrix(camLookAt, camRotations, camDistance);

    camLookAt[0] = cam.getLookAt()[0];
    camLookAt[1] = cam.getLookAt()[1];
    camLookAt[2] = cam.getLookAt()[2];

    camRotations[0] = cam.getRotations()[0];
    camRotations[1] = cam.getRotations()[1];
    camRotations[2] = cam.getRotations()[2];

    camDistance = (float)cam.getDistance();
  }
}

public void printCamMatrix() {
//  println(cam.getPosition()[0] + " - " + cam.getPosition()[1] + " - " + cam.getPosition()[2]);
  println(cam.getLookAt()[0] + " - " + cam.getLookAt()[1] + " - " + cam.getLookAt()[2]);
  println(cam.getRotations()[0] + " - " + cam.getRotations()[1] + " - " + cam.getRotations()[2]);
  println(cam.getDistance());
//  printCamera();

//  println(cam.getState());
}

public void getCamMatrix(float[] camLookAt, float[] camRot, float camDist){

  camLookAt[0] = cam.getLookAt()[0];
  camLookAt[1] = cam.getLookAt()[1];
  camLookAt[2] = cam.getLookAt()[2];

  camRot[0] = cam.getRotations()[0];
  camRot[1] = cam.getRotations()[1];
  camRot[2] = cam.getRotations()[2];
  
  camDist = (float)cam.getDistance();
}


public void setCamMatrix(float[] camLookAt, float[] camRot, float camDist){

  cam.lookAt(camLookAt[0], camLookAt[1], camLookAt[2]);
  cam.setRotations(camRot[0], camRot[1], camRot[2]);
  cam.setDistance(camDist);
  
}
public PVector superformulaPoint(float mm, float nn1, float nn2, float nn3, float phi) {
  float t1, t2;
  float a=1, b=1;
  float x = 0;
  float y = 0;
  float r;

  t1 = cos(mm * phi / 4) / a;
  t1 = abs(t1);
  t1 = pow(t1, nn2);

  t2 = sin(mm * phi / 4) / b;
  t2 = abs(t2);
  t2 = pow(t2, nn3);

  r = pow(t1+t2, 1/nn1);
  if (abs(r) == 0) {
    x = 0;
    y = 0;
  }  
  else {
    r = 1 / r;
    x = r * cos(phi);
    y = r * sin(phi);
  }

  return new PVector(x, y);
}

public float superformulaPointR(float mm, float nn1, float nn2, float nn3, float phi) {
  float t1, t2;
  float a=1, b=1;
  float x = 0;
  float y = 0;
  float r;

  t1 = cos(mm * phi / 4) / a;
  t1 = abs(t1);
  t1 = pow(t1, nn2);

  t2 = sin(mm * phi / 4) / b;
  t2 = abs(t2);
  t2 = pow(t2, nn3);

  r = pow(t1+t2, 1/nn1);
  if (abs(r) == 0) {
    x = 0;
    y = 0;
  }  
  else {
    r = 1 / r;
    x = r * cos(phi);
    y = r * sin(phi);
  }

  return r;
}


public float[] mapArrays(float[] inputArray, int outputArraySize){
  return null;
}



public float triangleArea(PVector v1, PVector v2, PVector v3) {
  PVector a = PVector.sub(v1, v2);
  PVector b = PVector.sub(v1, v3);

  return 0.5f*(sqrt(pow(a.y*b.z-a.z*b.y, 2)+pow(a.z*b.x-a.x*b.z, 2)+pow(a.x*b.y-a.y*b.x, 2)));
}

public float polygonArea(PVector[] p) {
  float result = 0;
  for (int i = 0; i < p.length; i++) {
    result += ((p[i].x*p[(i+1)%p.length].y)-(p[i].y*p[(i+1)%p.length].x))/2;
  }
  return abs(result);
}

public float newNoise(float x, float y, float z) {
  if (newNoiseNotInitialized) initNewNoise();
  int X = (int)Math.floor(x) & 255;
  int Y = (int)Math.floor(y) & 255;
  int Z = (int)Math.floor(z) & 255;
  x -= Math.floor(x);
  y -= Math.floor(y);
  z -= Math.floor(z);
  float u = newNoise_fade(x);
  float v = newNoise_fade(y);
  float w = newNoise_fade(z);   
  int A = newNoise_p[X]+Y;
  int AA = newNoise_p[A]+Z;
  int AB = newNoise_p[A+1]+Z;
  int B = newNoise_p[X+1]+Y;
  int BA = newNoise_p[B]+Z;
  int BB = newNoise_p[B+1]+Z;
  return newNoise_lerp2(w, newNoise_lerp2(v, newNoise_lerp2(u, newNoise_grad(newNoise_p[AA], x, y, z), newNoise_grad(newNoise_p[BA], x-1, y, z)), 
  newNoise_lerp2(u, newNoise_grad(newNoise_p[AB], x, y-1, z), newNoise_grad(newNoise_p[BB], x-1, y-1, z))), 
  newNoise_lerp2(v, newNoise_lerp2(u, newNoise_grad(newNoise_p[AA+1], x, y, z-1), newNoise_grad(newNoise_p[BA+1], x-1, y, z-1)), 
  newNoise_lerp2(u, newNoise_grad(newNoise_p[AB+1], x, y-1, z-1), newNoise_grad(newNoise_p[BB+1], x-1, y-1, z-1))));
}

public float newNoise_fade(float t) {
  return t * t * t * (t * (t * 6 - 15) + 10);
}

public float newNoise_lerp2(float t, float a, float b) {
  return (b - a)*t + a;
}

public float newNoise_grad(int hash, float x, float y, float z) {
  int h = hash & 15;
  float u = h<8 ? x : y;
  float v = h<4 ? y : h==12||h==14 ? x : z;
  return ((h&1) == 0 ? u : -u) + ((h&2) == 0 ? v : -v);
}

public void initNewNoise() {
  for (int i=0; i < 256 ; i++) {
    newNoise_permutation[i] = PApplet.parseInt(random(256));
    newNoise_p[256+i] = newNoise_p[i] = newNoise_permutation[i];
  }
  newNoiseNotInitialized = false;
}

int newNoise_p[] = new int[512];
int newNoise_permutation[] = new int[512];
boolean newNoiseNotInitialized = true;

public void keyPressed() {
  switch(key) {
  case 'f':
    drawFFT = !drawFFT;
    break;
  case 'r':
    //FIXME
    //      particles.createRandomAttractor();
    break;
  }
}

public void keyReleased() {
  switch(key) {
  case 'r':
    //FIXME
    //      particles.removeRandomAttractor();
    break;

  case 'd':
    decorate = !decorate;
    break;

  case '+':
    changeVisualEngine(currentEngineIndex + 1);
    break;

  case '-':
    changeVisualEngine(currentEngineIndex - 1);
    break;
  }
}



MidiIO midiIO;

int faderStartAddress = 0;
int faderStopAddress = 7;
int[] faderVal = new int[8];
int[] faderValPre = new int[8];
int[] faderValDiff = new int[8];

int knobStartAddress = 16;
int knobStopAddress = 23;
int[] knobVal = new int[8];
int[] knobValPre = new int[8];
int[] knobValDiff = new int[8];

int[] buttonsMAdd = {
  32, 33, 34, 35, 36, 37, 38, 39, 48, 49, 50, 51, 52, 53, 54, 55, 64, 65, 66, 67, 68, 69, 70, 71
};
int[] buttonsMVal = new int[24];
int[] buttonsMValPre = new int[24];
int[] buttonsMValDiff = new int[24];

public void initializeMidi() {
  midiIO = MidiIO.getInstance(this);
  midiIO.printDevices();
  midiIO.openInput(0, 0);

  midiIO.plug(this, "noteOff", 0, 0);
  midiIO.plug(this, "controllerIn", 0, 0);
}

public void controllerIn(
promidi.Controller midiController 
) {
  int num = midiController.getNumber();
  int val = midiController.getValue();

  if ((num <= faderStopAddress)&&(num >= faderStartAddress)) {
    faderVal[num-faderStartAddress] = val;
  }  
  else if ((num <= knobStopAddress)&&(num >= knobStartAddress)) {
    knobVal[num-knobStartAddress] = val;
  }

  for (int i = 0; i < buttonsMAdd.length; i++) {
    if (num == buttonsMAdd[i]) {
      if (buttonsMVal[i]==0) {
        buttonsMVal[i] = 1;
      } 
      else if (buttonsMVal[i]==1) {
        buttonsMVal[i] = 0;
      }
    }
  }
}

public void noteOff(
Note note
) {
  int pit = note.getPitch();

  if ((pit <= faderStopAddress)&&(pit >= faderStartAddress)) {
    faderVal[pit-faderStartAddress] = 0;
  }  
  else if ((pit <= knobStopAddress)&&(pit >= knobStartAddress)) {
    knobVal[pit-knobStartAddress] = 0;
  }
  for (int i = 0; i < buttonsMAdd.length; i++) {
    if (pit == buttonsMAdd[i]) {
      buttonsMVal[i] = 0;
    }
  }
}

public void midiCalculator() {
  for (int i = 0; i<faderVal.length; i++) {
    faderValDiff[i] = faderVal[i] - faderValPre[i];
    faderValPre[i] = faderVal[i];
  }

  for (int i = 0; i<knobVal.length; i++) {
    knobValDiff[i] = knobVal[i] - knobValPre[i];
    knobValPre[i] = knobVal[i];
  }
  
    for (int i = 0; i<buttonsMVal.length; i++) {
      if(buttonsMVal[i] - buttonsMValPre[i] != -1){
          buttonsMValDiff[i] = buttonsMVal[i] - buttonsMValPre[i];

      }
    buttonsMValPre[i] = buttonsMVal[i];
  }
  
}

public void midiMapSound() {
  cp5.getController("gain").setValue((map(faderVal[6], 0, 127, 0.f, 1.f)));
  cp5.getController("decay").setValue((map(faderVal[7], 0, 127, 0.5f, 1.f)));
}

boolean preset1 = false;
boolean preset2 = false;
boolean preset3 = false;
boolean preset4 = false;
boolean preset5 = false;
boolean preset6 = false;
boolean preset7 = false;
boolean preset8 = false;
boolean preset1Pre = false;
boolean preset2Pre = false;
boolean preset3Pre = false;
boolean preset4Pre = false;
boolean preset5Pre = false;
boolean preset6Pre = false;
boolean preset7Pre = false;
boolean preset8Pre = false;
boolean savePreset = false;
boolean savePresetPre = false;
int presetIndex = 0;

public float[] loadPreset(String dir, String name, int presetNumber) {
  float[] parameters = {
  };
  String[] lines;
  String[] pieces;
  String fullAddress = dir + name + presetNumber + ".txt"; 
  lines = loadStrings(fullAddress);
  println(sketchPath);
  println(fullAddress);
  pieces = split(lines[0], ' ');
  for (int i = 0; i < pieces.length; i++) {
    parameters = append(parameters, PApplet.parseFloat(pieces[i]));
  }
  return parameters;
}

public void savePreset(String dir, String name, int presetNumber, float[] parameters) {
  String fullAddress = dir + name + presetNumber + ".txt"; 
  String[] toWrite00 = {
    ""
  };
  for (int i = 0; i < parameters.length; i++) {
    toWrite00[0] += parameters[i];
    if (i != parameters.length-1)
      toWrite00[0] += ' ';
  }
  saveStrings(fullAddress, toWrite00);
}


 // automcatically added when importing the library from the processing menu.
float soundVal = 0;
int spectrumLength = 256;
float soundLevelLPF = 0;
float[] soundLPFBuf = new float[spectrumLength];

public void initializeSonia() {
  Sonia.start(this); // Start Sonia engine.
  LiveInput.start(spectrumLength); // Start LiveInput and return 256 FFT frequency bands.
}

public void drawSonia() {
  getMeterLevel(); // Show meter-level reading for Left/Right channels.
  getSpectrum(); // Show FFT reading
  soundLPFBuf = LPFArray(LiveInput.spectrum);
  soundLevelLPF = 0;
  for(int i = 0; i<spectrumLength; i++){
    soundLevelLPF += (soundLPFBuf[i]/spectrumLength)*gain;
  }
  
}

public void getSpectrum() {

  LiveInput.getSpectrum();
}

public void getMeterLevel() {
  // get Peak level for each channel (0 -> Left , 1 -> Right)
  // Value Range: float from 0.0 to 1.0
  // Note: use inputMeter.getLevel() to combine both channels (L+R) into one value.
  float meterDataLeft = LiveInput.getLevel();
  float meterDataRight = LiveInput.getLevel();

  // draw a volume-meter for each channel.
  fill(0, 100, 0);
  float lefta = meterDataLeft*height;
  float righta = meterDataRight*height;
}

public float getSoundLevel(float decay)
{
  float soundValPre = 0;
  // get Peak level for each channel (0 -> Left , 1 -> Right)
  // Value Range: float from 0.0 to 1.0
  // Note: use inputMeter.getLevel() to combine both channels (L+R) into one value.

  soundValPre += (LiveInput.getLevel()*(1.f-decay));

  if (soundVal < soundValPre) {
    soundVal = soundValPre;
  } 
  else {
    soundVal *= decay;
  }

  return soundVal;
}

// Safely close the sound engine upon Browser shutdown.
public void stop() {
  Sonia.stop();
  super.stop();
}


float[] lpfOutPreArray = new float[spectrumLength];
float[] lpfOutArray = new float[spectrumLength];
float soundAlfa = 0.2f;

public float[] LPFArray(float[] in) {
  for (int i = 0; i < in.length; i++) {
    lpfOutArray[i] = decay * in[i] + (1-decay) * lpfOutPreArray[i];
    lpfOutPreArray[i] = lpfOutArray[i];
  }

  return lpfOutArray;
}
//base, harmonic 

FftVar[] fftVar;
float fftVarAvg;

float gain = 0.05f;
float decay = 0.9f;

float base = 1.f;
float baseTemp = 0.f;


float[] fftComp;
float[] fftCompTemp;

int avgAmount = 256;
boolean drawFFT = true;
boolean SR = false;

public void initializeSoundAnalysis() {
  initializeSonia();

  fftVar = new FftVar[2];
  fftVar[0] = new FftVar(10, 5);
  fftVar[1] = new FftVar(50, 15);

  getSpectrum();
}

float[] features;
public void soundAnalysis() {
  if (midiEnable) {
    //    midiMapSound();
  }
  baseTemp = 0.f;
  drawSonia();  


  fftVarAvg = 0;
  fftVarAvg = fftVar[0].getValue();
}

public class FftVar
{
  public int baseFreq;
  public float value;
  public float valuePre;
  public int fftRange;

  FftVar(int freq, int range)
  {
    baseFreq = freq;
    value = 0;
    fftRange = range;
  }

  public float getValue()
  { 
    valuePre = 0;
    for (int i = -fftRange; i < fftRange; i++) {
      valuePre += (LiveInput.spectrum[i+baseFreq]*(1.f-decay))*gain/(2*fftRange);
    }

    if (value < valuePre) {
      value = valuePre;
    } 
    else {
      value *= decay;
    }

    return value;
  }

  public void setBase(int freq) {
    baseFreq = freq;
  }

  float fftVarAcc;
  public float getValueLPF() {
    for (int i = -fftRange; i < fftRange; i++) {
      fftVarAcc += (LiveInput.spectrum[i+baseFreq])*gain/(2*fftRange);
    }
    float result = LPF(fftVarAcc);
    fftVarAcc = 0;
    return result;
  }

  float lpfOutPre;
  float lpfOut;

  public float LPF(float in) {
    lpfOut = decay * in + (1-decay) * lpfOutPre;
    lpfOutPre = lpfOut;
    return lpfOut;
  }
}

public class SoundWaveInput {
  int bufSize;
  float[] soundBuf;
  int bufSpeed;

  SoundWaveInput(int bSize, int bSpeed) {
    bufSize = bSize;
    bufSpeed = bSpeed;
    soundBuf = new float[bufSize];
    for (int i = 0; i < bufSize; i++) {
      soundBuf[i] = 0.f;
    }
  }

  public float[] getSoundWave() {
    for (int i = 0; i < bufSize-bufSpeed; i++) {
      soundBuf[i] = soundBuf[i+bufSpeed];
    }
    soundBuf[bufSize-1] = getSoundLevel(0.9f);
    return soundBuf;
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "markusMac" });
  }
}
