import processing.opengl.*;
import peasy.*;

PeasyCam cam;

import hardcorepawn.fog.*;

fog myFog;

float nearDist;
float farDist; 
color fogColor;

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
float rotSpeedX = 0.;
float rotSpeedY = 0.;

float rotVariance;
float rotSelf = 0.;
float rotLimit = 2.;
float cubeCircleRad = 300.;
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
    cp5.getController("preset5").setValue(1.);
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
          .setRange(0., 4.)
            .setViewStyle(Knob.ARC)
              .setColorValueLabel(valueLabel)
                .setCaptionLabel("SELF ROTATION LIMIT")
                  .setWindow(controlWindow);

    cp5.addKnob("rotSelf")
      .setPosition(knobPosX[1]+visualSpecificParametersBoxX-knobWidth, knobPosY[1]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(-2., 2.)
            .setColorValueLabel(valueLabel)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("SELF ROTATION SPEED")
                  .setWindow(controlWindow);

    cp5.addKnob("rotVariance")
      .setPosition(knobPosX[2]+visualSpecificParametersBoxX-knobWidth, knobPosY[2]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(0., 30.)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("SHAPE DISTORTION")
                  .setWindow(controlWindow);
    cp5.addKnob("rotSpeedX")
      .setPosition(knobPosX[3]+visualSpecificParametersBoxX-knobWidth, knobPosY[3]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(-1., 1.)
              .setViewStyle(Knob.ARC)        
                .setCaptionLabel("VERTICAL ROTATION")
                  .setWindow(controlWindow);
    cp5.addKnob("rotSpeedY")
      .setPosition(knobPosX[4]+visualSpecificParametersBoxX-knobWidth, knobPosY[4]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(-1., 1.)
            .setColorValueLabel(valueLabel)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("HORIZONTAL ROTATION")
                  .setWindow(controlWindow);

    cp5.addKnob("outlineStroke")
      .setPosition(knobPosX[5]+visualSpecificParametersBoxX-knobWidth, knobPosY[5]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(0., 255.)
            .setColorValueLabel(valueLabel)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("OUTLINE TRANSPARENCY")
                  .setWindow(controlWindow);

    cp5.addKnob("outlineColor")
      .setPosition(knobPosX[6]+visualSpecificParametersBoxX-knobWidth, knobPosY[6]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(0., 255.)
            .setColorValueLabel(valueLabel)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("OUTLINE COLOR")
                  .setWindow(controlWindow);

    cp5.addKnob("outlineScale")
      .setPosition(knobPosX[7]+visualSpecificParametersBoxX-knobWidth, knobPosY[7]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(0., 1.)
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
          .setRange(0.1, cubeCircleRad*6/10)
            .setCaptionLabel("SIZE OFFSET X")
              .setWindow(controlWindow);
  cp5.getController("cubeSizeOffsetX").captionLabel().getStyle().marginLeft = -18;

    cp5.addSlider("cubeSizeOffsetY")
      .setPosition(sliderPosX[2]+visualSpecificParametersBoxX, sliderPosY[2]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.1, cubeCircleRad*6/10)
            .setCaptionLabel("SIZE OFFSET Y")
              .setWindow(controlWindow);
  cp5.getController("cubeSizeOffsetY").captionLabel().getStyle().marginLeft = -18;

    cp5.addSlider("cubeSizeOffsetZ")
      .setPosition(sliderPosX[3]+visualSpecificParametersBoxX, sliderPosY[3]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.1, cubeCircleRad*6/10)
            .setCaptionLabel("SIZE OFFSET Z")
              .setWindow(controlWindow);
  cp5.getController("cubeSizeOffsetZ").captionLabel().getStyle().marginLeft = -18;

    cp5.addSlider("cubeSizeVarianceX")
      .setPosition(sliderPosX[4]+visualSpecificParametersBoxX, sliderPosY[4]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.1, cubeCircleRad*6/10)
            .setCaptionLabel("SIZE VARIANCE X")
              .setWindow(controlWindow);
  cp5.getController("cubeSizeVarianceX").captionLabel().getStyle().marginLeft = -25;

    cp5.addSlider("cubeSizeVarianceY")
      .setPosition(sliderPosX[5]+visualSpecificParametersBoxX, sliderPosY[5]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.1, cubeCircleRad*6/10)
            .setCaptionLabel("SIZE VARIANCE Y")
              .setWindow(controlWindow);
  cp5.getController("cubeSizeVarianceY").captionLabel().getStyle().marginLeft = -25;

    cp5.addSlider("cubeSizeVarianceZ")
      .setPosition(sliderPosX[6]+visualSpecificParametersBoxX, sliderPosY[6]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.1, cubeCircleRad*6/10)
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
      cam.rotateX(rotSpeedX*0.05);
    } 
    if (!cubeRotStopY) {
      cam.rotateY(rotSpeedY*0.05);
    } 



    rX += rotSelf*0.01;

    for (int i = 0; i < (int)cubeAmount; i++) {
      pushMatrix();
      translate(cubeCircleRad*sin(map(i, 0, cubeAmount, 0, 2*PI)+rS), rotVariance*sin((frameCount*0.01)+map(i, 0, cubeAmount, 0, 4*PI)), rotVariance*3*cos((frameCount*0.01)+map(i, 0, cubeAmount, 0, 4*PI))+cubeCircleRad*cos(map(i, 0, cubeAmount, 0, 2*PI)+rS));
      float angle = newNoise((float)i/50, rX, 0) * TWO_PI*rotLimit; //newNoise is smoother

      rotateX(angle);
      rectMode(CENTER);
      pushStyle();
      fill(0, 255, 255);
      noStroke();

      outlineLength         = soundLPFBuf[int(i*spectrumLength/(int)cubeAmount)]*gain;

      box(cubeSizeOffsetX+cubeSizeVarianceX*(sin((frameCount*0.01)+map(i, 0, cubeAmount, 4*PI, 0))), cubeSizeOffsetY + outlineLength* 10+cubeSizeVarianceY*(sin((frameCount*0.01)+map(i, 0, cubeAmount, 4*PI, 0))), cubeSizeOffsetZ+cubeSizeVarianceZ*(sin((frameCount*0.01)+map(i, 0, cubeAmount, 4*PI, 0))));
      popStyle();

      pushStyle();
      //      stroke(map(i, 0, cubeAmount, cubeColorMin, cubeColorMax), 255, 255, outlineStroke);
      stroke(map(abs(i-(cubeAmount/2)), 0, cubeAmount/2, 0, 100)+outlineColor, 255, 255, outlineStroke);
      if (outlineStroke<2.)noStroke();
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
      cp5.getController("preset2").setValue(0.);
      cp5.getController("preset3").setValue(0.);
      cp5.getController("preset4").setValue(0.);
      cp5.getController("preset5").setValue(0.);
      cp5.getController("preset6").setValue(0.);
      cp5.getController("preset7").setValue(0.);
      cp5.getController("preset8").setValue(0.);
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
      cp5.getController("preset1").setValue(0.);
      cp5.getController("preset3").setValue(0.);
      cp5.getController("preset4").setValue(0.);
      cp5.getController("preset5").setValue(0.);
      cp5.getController("preset6").setValue(0.);
      cp5.getController("preset7").setValue(0.);
      cp5.getController("preset8").setValue(0.);
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
      cp5.getController("preset1").setValue(0.);
      cp5.getController("preset2").setValue(0.);
      cp5.getController("preset4").setValue(0.);
      cp5.getController("preset5").setValue(0.);
      cp5.getController("preset6").setValue(0.);
      cp5.getController("preset7").setValue(0.);
      cp5.getController("preset8").setValue(0.);
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
      cp5.getController("preset1").setValue(0.);
      cp5.getController("preset2").setValue(0.);
      cp5.getController("preset3").setValue(0.);
      cp5.getController("preset5").setValue(0.);
      cp5.getController("preset6").setValue(0.);
      cp5.getController("preset7").setValue(0.);
      cp5.getController("preset8").setValue(0.);
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
      cp5.getController("preset1").setValue(0.);
      cp5.getController("preset2").setValue(0.);
      cp5.getController("preset3").setValue(0.);
      cp5.getController("preset4").setValue(0.);
      cp5.getController("preset6").setValue(0.);
      cp5.getController("preset7").setValue(0.);
      cp5.getController("preset8").setValue(0.);
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
      cp5.getController("preset1").setValue(0.);
      cp5.getController("preset2").setValue(0.);
      cp5.getController("preset3").setValue(0.);
      cp5.getController("preset4").setValue(0.);
      cp5.getController("preset5").setValue(0.);
      cp5.getController("preset7").setValue(0.);
      cp5.getController("preset8").setValue(0.);
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
      cp5.getController("preset1").setValue(0.);
      cp5.getController("preset2").setValue(0.);
      cp5.getController("preset3").setValue(0.);
      cp5.getController("preset4").setValue(0.);
      cp5.getController("preset5").setValue(0.);
      cp5.getController("preset6").setValue(0.);
      cp5.getController("preset8").setValue(0.);
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
      cp5.getController("preset1").setValue(0.);
      cp5.getController("preset2").setValue(0.);
      cp5.getController("preset3").setValue(0.);
      cp5.getController("preset4").setValue(0.);
      cp5.getController("preset5").setValue(0.);
      cp5.getController("preset6").setValue(0.);
      cp5.getController("preset7").setValue(0.);
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

