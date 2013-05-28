import processing.opengl.*;
import peasy.*;

PeasyCam cam;

import hardcorepawn.fog.*;

fog myFog;
boolean fogEnable = false;
boolean preset1 = false;
boolean preset2 = false;
boolean preset3 = false;
boolean preset4 = false;
boolean preset1Pre = false;
boolean preset2Pre = false;
boolean preset3Pre = false;
boolean preset4Pre = false;
boolean savePreset = false;
boolean savePresetPre = false;
int presetIndex = 0;
class Cube extends VisualEngine {

  protected ArrayList<controlP5.Controller> controllers;
  String[] parameterNames = { 
    "cubeAmount", 
    "cubeColor", //çift data birden olmuyor canım
    "cubeSizeOffsetX", 
    "cubeSizeOffsetY", 
    "cubeSizeOffsetZ", 
    "outlineStroke", 
    "rotLimit", 
    "rotVariance", 
    "rotSpeed", 
    "cubeSizeVarianceX", 
    "cubeSizeVarianceY", 
    "cubeSizeVarianceZ", 
    "outlineLength", 
    "rotSelf"
  };

  float[] parameters1 = new float[parameterNames.length];
  float[] parameters2 = new float[parameterNames.length];
  float[] parameters3 = new float[parameterNames.length];
  float[] parameters4 = new float[parameterNames.length];
  float[] parametersTemp = new float[parameterNames.length];


  public Cube(PApplet myApplet, String name) {
    super(myApplet, name);
    println("Cube Constructor.");
    controllers = new ArrayList<controlP5.Controller>();
  }

  public void init() {
    cam = new PeasyCam(myApplet, 100);
    cam.setMinimumDistance(-5000);
    cam.setMaximumDistance(5000);
    background(0);
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

    cp5.addKnob("cubeAmount")
      .setPosition(parameterPos[0][0].x-parameterSize[0].x/2, parameterPos[0][0].y-parameterSize[0].y/2)   
        .setRadius((int)parameterSize[0].x)
          .setRange(1, 250)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.addKnob("rotLimit")
      .setPosition(parameterPos[0][1].x-parameterSize[0].x/2, parameterPos[0][1].y-parameterSize[0].y/2)   
        .setRadius((int)parameterSize[0].x)
          .setRange(0., 4.)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.addKnob("rotSelf")
      .setPosition(parameterPos[0][2].x-parameterSize[0].x/2, parameterPos[0][2].y-parameterSize[0].y/2)   
        .setRadius((int)parameterSize[0].x)
          .setRange(-2., 2.)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.addKnob("rotVariance")
      .setPosition(parameterPos[0][3].x-parameterSize[0].x/2, parameterPos[0][3].y-parameterSize[0].y/2)   
        .setRadius((int)parameterSize[0].x)
          .setRange(0., 30.)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.addKnob("rotSpeed")
      .setPosition(parameterPos[0][4].x-parameterSize[0].x/2, parameterPos[0][4].y-parameterSize[0].y/2)   
        .setRadius((int)parameterSize[0].x)
          .setRange(-1., 1.)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.addKnob("outlineStroke")
      .setPosition(parameterPos[0][5].x-parameterSize[0].x/2, parameterPos[0][5].y-parameterSize[0].y/2)   
        .setRadius((int)parameterSize[0].x)
          .setRange(0., 255.)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.addKnob("outlineLength")
      .setPosition(parameterPos[0][6].x-parameterSize[0].x/2, parameterPos[0][6].y-parameterSize[0].y/2)   
        .setRadius((int)parameterSize[0].x)
          .setRange(0., 1.)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);
              
    cp5.addSlider("cubeSizeOffsetX")
      .setPosition(parameterPos[1][0].x-parameterSize[1].x/2, parameterPos[1][0].y-parameterSize[1].y/2)   
        .setSize((int)parameterSize[1].x, (int)parameterSize[1].y)
          .setRange(0.1, cubeCircleRad*6/10)
            .setWindow(controlWindow);

    cp5.addSlider("cubeSizeOffsetY")
      .setPosition(parameterPos[1][1].x-parameterSize[1].x/2, parameterPos[1][1].y-parameterSize[1].y/2)   
        .setSize((int)parameterSize[1].x, (int)parameterSize[1].y)
          .setRange(0.1, cubeCircleRad*6/10)
            .setWindow(controlWindow);

    cp5.addSlider("cubeSizeOffsetZ")
      .setPosition(parameterPos[1][2].x-parameterSize[1].x/2, parameterPos[1][2].y-parameterSize[1].y/2)   
        .setSize((int)parameterSize[1].x, (int)parameterSize[1].y)
          .setRange(0.1, cubeCircleRad*6/10)
            .setWindow(controlWindow);

    cp5.addSlider("cubeSizeVarianceX")
      .setPosition(parameterPos[1][3].x-parameterSize[1].x/2, parameterPos[1][3].y-parameterSize[1].y/2)   
        .setSize((int)parameterSize[1].x, (int)parameterSize[1].y)
          .setRange(0.1, cubeCircleRad*6/10)
            .setWindow(controlWindow);

    cp5.addSlider("cubeSizeVarianceY")
      .setPosition(parameterPos[1][4].x-parameterSize[1].x/2, parameterPos[1][4].y-parameterSize[1].y/2)   
        .setSize((int)parameterSize[1].x, (int)parameterSize[1].y)
          .setRange(0.1, cubeCircleRad*6/10)
            .setWindow(controlWindow);

    cp5.addSlider("cubeSizeVarianceZ")
      .setPosition(parameterPos[1][5].x-parameterSize[1].x/2, parameterPos[1][5].y-parameterSize[1].y/2)   
        .setSize((int)parameterSize[1].x, (int)parameterSize[1].y)
          .setRange(0.1, cubeCircleRad*6/10)
            .setWindow(controlWindow);
            
    cp5.addRange("cubeColor")
      .setBroadcast(false) 
        .setPosition(parameterPos[2][0].x-parameterSize[2].x/2, parameterPos[2][0].y-parameterSize[2].y/2)   
          .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
            .setHandleSize(10)
              .setRange(0, 255)
                .setRangeValues(0, 255)
                  .setBroadcast(true)
                    .setWindow(controlWindow);
                    
    for (int i = 0; i < parameterNames.length; i++) {
      cp5.getController(parameterNames[i])
        .getCaptionLabel()
          .setFont(fontLight)
            .toUpperCase(false)
              .setSize(15);
      controllers.add(cp5.getController(parameterNames[i]));
    }

    showGUI(false);
  }

  float rX = 0;  // rotateX incrementer
  float rS = 0;  // rotSpeed incrementer

  public void update() {
    if (midiEnable) {
      midiMapCubes();
    }

    mapPresets();
    colorMode(HSB);
    background(0, 0, 20);
    if (lightEnable) {
      lightSetting();
    }
    rS +=rotSpeed*0.05;
    rX += rotSelf*0.01;

    for (int i = 0; i < cubeAmount; i++) {
      pushMatrix();
      translate(cubeCircleRad*sin(map(i, 0, cubeAmount, 0, 2*PI)+rS), rotVariance*sin((frameCount*0.01)+map(i, 0, cubeAmount, 0, 4*PI)), rotVariance*3*cos((frameCount*0.01)+map(i, 0, cubeAmount, 0, 4*PI))+cubeCircleRad*cos(map(i, 0, cubeAmount, 0, 2*PI)+rS));
      float angle = newNoise((float)i/50, rX, 0) * TWO_PI*rotLimit; //newNoise is smoother

      rotateX(angle);
      rectMode(CENTER);
      pushStyle();
      fill(0, 255, 255);
      noStroke();


      //      cubeSizeOffsetX       = map(fftVar[0].getValue(), 0, 5, 1., 60.);
      //      cubeSizeOffsetY       = map(fftVar[0].getValue(), 0, 50, 1., 60.);
      //      cubeSizeOffsetZ       = map(fftVar[0].getValue(), 0, 5, 1., 60.);
      //      cubeSizeVarianceX     = map(fftVar[0].getValue(), 0, 5, 0., 60.);
      //      cubeSizeVarianceY     = map(fftVar[0].getValue(), 0, 5, 0., 60.);
      //      cubeSizeVarianceZ     = map(fftVar[0].getValue(), 0, 5, 0., 60.);
      //      rotLimit              = map(fftVar[0].getValue(), 0, 5, 0., 4.);
      //      rotVariance           = map(fftVar[0].getValue(), 0, 5, 0., 40.);
      //      rotSpeed              = map(fftVar[0].getValue(), 0, 5, -1., 1.);
      //      outlineStroke         = map(fftVar[0].getValue(), 0, 5, 0., 255.);
      outlineLength         = map(fftVar[0].getValue(), 0, 5, 0., 1.);
      //      rotSelf               = map(fftVar[0].getValue(), 0, 5, -2, 2.);

      box(cubeSizeOffsetX+cubeSizeVarianceX*(sin((frameCount*0.01)+map(i, 0, cubeAmount, 4*PI, 0))), cubeSizeOffsetY+cubeSizeVarianceY*(sin((frameCount*0.01)+map(i, 0, cubeAmount, 4*PI, 0))), cubeSizeOffsetZ+cubeSizeVarianceZ*(sin((frameCount*0.01)+map(i, 0, cubeAmount, 4*PI, 0))));
      popStyle();

      pushStyle();
      stroke(map(i, 0, cubeAmount, cubeColorMin, cubeColorMax), 255, 255, outlineStroke);
      if (outlineStroke<2.)noStroke();
      noFill();
      pushMatrix();
      rotateY(PI/2);
      strokeWeight(2);  
      float lineSizeX = cubeSizeOffsetX+cubeSizeVarianceX;
      float lineSizeY = cubeSizeOffsetY+cubeSizeVarianceY;
      line(-lineSizeX, -lineSizeY, -lineSizeX, -lineSizeY+(lineSizeY*2*outlineLength));
      line(-lineSizeX, lineSizeY, -lineSizeX+(lineSizeX*2*outlineLength), lineSizeY);
      line(lineSizeX, -lineSizeY, lineSizeX-(lineSizeX*2*outlineLength), -lineSizeY);  
      line(lineSizeX, lineSizeY, lineSizeX, lineSizeY-(lineSizeY*2*outlineLength));
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
    //directionalLight(255, 0, 50, 0, -1, 0); 
    ambientLight(0, 255, 20);
    int lightY = 150;
    int lightYBr = 255;
    int lightYCon = 100;

    spotLight(255, 0, 255, // Color
    0, 100, 150, // Position
    0, -0.3, -1, // Direction
    PI, 20); // Angle, concentration
    //    point(0, 10, 150);

    //    if ( key == 'q') {
    spotLight(255, 0, lightYBr, // Color
    0, -lightY, 0, // Position
    0, 1, 0, // Direction
    PI, 6); // Angle, concentration
    //    point(0, -lightY, 0);

    //    } else if ( key == 'w') {
    spotLight(255, 0, lightYBr, // Color
    cubeCircleRad, -lightY, 0, // Position
    0, 1, 0, // Direction
    PI, lightYCon); // Angle, concentration
    //    point(cubeCircleRad, -lightY, 0);
    //    } else if ( key == 'e') {
    spotLight(255, 0, lightYBr, // Color
    -cubeCircleRad, -lightY, 0, // Position
    0, 1, 0, // Direction
    PI, lightYCon); // Angle, concentration
    //    point(-cubeCircleRad, -lightY, 0);
    //    } else if ( key == 'r') {
    spotLight(255, 0, lightYBr, // Color
    0, -lightY, cubeCircleRad, // Position
    0, 1, 0, // Direction
    PI, lightYCon); // Angle, concentration
    //    point(0, -lightY, cubeCircleRad);
    //    } else if ( key == 't') {
    spotLight(255, 0, lightYBr, // Color
    0, -lightY, -cubeCircleRad, // Position
    0, 1, 0, // Direction
    PI, lightYCon); // Angle, concentration
    //    point(0, -lightY, -cubeCircleRad);
    //}
  }


  public void showGUI(boolean show) {
    for (controlP5.Controller c: controllers) {
      c.setVisible(show);
    }
  }

  public void controlEvent(ControlEvent theControlEvent) {
    if (theControlEvent.isFrom("cubeColor")) {
      cubeColorMin = int(theControlEvent.getController().getArrayValue(0));
      cubeColorMax = int(theControlEvent.getController().getArrayValue(1));
    }
  }


  public void mapPresets() {

    if (preset1 && !preset1Pre) {
      presetIndex = 1;
      parameters1 =     loadPreset(presetDir, name, 1);
      cp5.getController("cubeAmount").setValue((int)parameters1[0]);
      cp5.getController("cubeSizeOffsetX").setValue(parameters1[1]);
      cp5.getController("cubeSizeOffsetY").setValue(parameters1[2]);
      cp5.getController("cubeSizeOffsetZ").setValue(parameters1[3]); 
      cp5.getController("outlineStroke").setValue(parameters1[4]); 
      cp5.getController("rotLimit").setValue(parameters1[5]); 	
      cp5.getController("rotVariance").setValue(parameters1[6]); 	
      cp5.getController("rotSpeed").setValue(parameters1[7]); 		
      cp5.getController("cubeSizeVarianceX").setValue(parameters1[8]); 		
      cp5.getController("cubeSizeVarianceY").setValue(parameters1[9]); 		
      cp5.getController("cubeSizeVarianceZ").setValue(parameters1[10]);		
      cp5.getController("outlineLength").setValue(parameters1[11]);	
      cp5.getController("rotSelf").setValue(parameters1[12]);
    } 
    else     if (preset2 && !preset2Pre) {
      presetIndex = 2;
      parameters2 =     loadPreset(presetDir, name, 2);
      cp5.getController("cubeAmount").setValue((int)parameters2[0]);
      cp5.getController("cubeSizeOffsetX").setValue(parameters2[1]);
      cp5.getController("cubeSizeOffsetY").setValue(parameters2[2]);
      cp5.getController("cubeSizeOffsetZ").setValue(parameters2[3]); 
      cp5.getController("outlineStroke").setValue(parameters2[4]); 
      cp5.getController("rotLimit").setValue(parameters2[5]); 	
      cp5.getController("rotVariance").setValue(parameters2[6]); 	
      cp5.getController("rotSpeed").setValue(parameters2[7]); 		
      cp5.getController("cubeSizeVarianceX").setValue(parameters2[8]); 		
      cp5.getController("cubeSizeVarianceY").setValue(parameters2[9]); 		
      cp5.getController("cubeSizeVarianceZ").setValue(parameters2[10]);		
      cp5.getController("outlineLength").setValue(parameters2[11]);	
      cp5.getController("rotSelf").setValue(parameters2[12]);
    } 
    else     if (preset3 && !preset3Pre) {
      presetIndex = 3;
      parameters3 =     loadPreset(presetDir, name, 3);
      cp5.getController("cubeAmount").setValue((int)parameters3[0]);
      cp5.getController("cubeSizeOffsetX").setValue(parameters3[1]);
      cp5.getController("cubeSizeOffsetY").setValue(parameters3[2]);
      cp5.getController("cubeSizeOffsetZ").setValue(parameters3[3]); 
      cp5.getController("outlineStroke").setValue(parameters3[4]); 
      cp5.getController("rotLimit").setValue(parameters3[5]); 	
      cp5.getController("rotVariance").setValue(parameters3[6]); 	
      cp5.getController("rotSpeed").setValue(parameters3[7]); 		
      cp5.getController("cubeSizeVarianceX").setValue(parameters3[8]); 		
      cp5.getController("cubeSizeVarianceY").setValue(parameters3[9]); 		
      cp5.getController("cubeSizeVarianceZ").setValue(parameters3[10]);		
      cp5.getController("outlineLength").setValue(parameters3[11]);	
      cp5.getController("rotSelf").setValue(parameters3[12]);
    } 
    else     if (preset4 && !preset4Pre) {
      presetIndex = 4;
      parameters4 =     loadPreset(presetDir, name, 4);
      cp5.getController("cubeAmount").setValue((int)parameters4[0]);
      cp5.getController("cubeSizeOffsetX").setValue(parameters4[1]);
      cp5.getController("cubeSizeOffsetY").setValue(parameters4[2]);
      cp5.getController("cubeSizeOffsetZ").setValue(parameters4[3]); 
      cp5.getController("outlineStroke").setValue(parameters4[4]); 
      cp5.getController("rotLimit").setValue(parameters4[5]); 	
      cp5.getController("rotVariance").setValue(parameters4[6]); 	
      cp5.getController("rotSpeed").setValue(parameters4[7]); 		
      cp5.getController("cubeSizeVarianceX").setValue(parameters4[8]); 		
      cp5.getController("cubeSizeVarianceY").setValue(parameters4[9]); 		
      cp5.getController("cubeSizeVarianceZ").setValue(parameters4[10]);		
      cp5.getController("outlineLength").setValue(parameters4[11]);	
      cp5.getController("rotSelf").setValue(parameters4[12]);
    } 
    else if ( savePreset && !savePresetPre) {
      parametersTemp[0] = cubeAmount;
      parametersTemp[1] = cubeSizeOffsetX;
      parametersTemp[2] = cubeSizeOffsetY;
      parametersTemp[3] = cubeSizeOffsetZ;
      parametersTemp[4] = outlineStroke;
      parametersTemp[5] = rotLimit;
      parametersTemp[6] = rotVariance;
      parametersTemp[7] = rotSpeed;
      parametersTemp[8] = cubeSizeVarianceX;
      parametersTemp[9] = cubeSizeVarianceY;
      parametersTemp[10] = cubeSizeVarianceZ;
      parametersTemp[11] = outlineLength;
      parametersTemp[12] = rotSelf;
      savePreset(presetDir, name, presetIndex, parametersTemp) ;
    } 
    else if ((!preset1 && !preset2 && !preset3 && !preset4)) {
      presetIndex = 0;
    }

    preset1Pre = preset1;
    preset2Pre = preset2;
    preset3Pre = preset3;
    preset4Pre = preset4;
    savePresetPre = savePreset;
  }

  public void start() {
    println("Starting cubes");
  }

  public void exit() {
    println("Exitting cubes");
  }
}

