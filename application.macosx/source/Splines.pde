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
    "ribbonRotY"
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
    cam.setMaximumDistance(500000);


    colorMode(HSB);
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

    //    colorMode(HSB, 360, 100, 100);
    for (int i=0; i<agents.length; i++) {
      agents[i]=new  Ribbon (i, new PVector(random(-ribbonSpaceX, ribbonSpaceX), random(-ribbonSpaceY, ribbonSpaceY), random(-ribbonSpaceZ, ribbonSpaceZ)), 
      int(random(50, 70)));
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
    cam.rotateX(ribbonRotX);
    cam.rotateY(ribbonRotY);
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
        cp5.getController("ribbonCycloid").setValue(0.);
        cp5.getController("ribbonNoise").setValue(0.);

        agents[i].updateHelix();
      }


      if (cycloidEnable) {
        cp5.getController("ribbonHelix").setValue(0.);
        cp5.getController("ribbonNoise").setValue(0.);

        agents[i].updateCircloid();
      }


      if (noiseEnable) {
        cp5.getController("ribbonCycloid").setValue(0.);
        cp5.getController("ribbonHelix").setValue(0.);

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

    lightSpecular(0, 0, 255);
    shininess(255);
    specular(255);
    //    pointLight(0, 255, 255, // Color
    //    200, 0, 0); // Position
    //    point(2000, 0, 0);
    //    directionalLight(255, 0, 50, 0, -1, -1);
    //directionalLight(255, 0, 50, 0, -1, 0); 
    ambientLight(0, 0, 100);
    directionalLight(0, 0, 200, 0, -1, -1); 
//    directionalLight(0, 0, 200, 0, 1, -1); 
    directionalLight(0, 0, 200, 1, 0, -1); 

//    int lightY = 150;
//    int lightYBr = 255;
//    int lightYCon = 100;
//
//    spotLight(255, 0, 255, // Color
//    0, 100, 150, // Position
//    0, -0.3, -1, // Direction
//    PI, 20); // Angle, concentration
//    //    point(0, 10, 150);
//
//    //    if ( key == 'q') {
//    spotLight(255, 0, lightYBr, // Color
//    0, -lightY, 0, // Position
//    0, 1, 0, // Direction
//    PI, 6); // Angle, concentration
//    //    point(0, -lightY, 0);
//
//    //    } else if ( key == 'w') {
//    spotLight(255, 0, lightYBr, // Color
//    cubeCircleRad, -lightY, 0, // Position
//    0, 1, 0, // Direction
//    PI, lightYCon); // Angle, concentration
//    //    point(cubeCircleRad, -lightY, 0);
//    //    } else if ( key == 'e') {
//    spotLight(255, 0, lightYBr, // Color
//    -cubeCircleRad, -lightY, 0, // Position
//    0, 1, 0, // Direction
//    PI, lightYCon); // Angle, concentration
//    //    point(-cubeCircleRad, -lightY, 0);
//    //    } else if ( key == 'r') {
//    spotLight(255, 0, lightYBr, // Color
//    0, -lightY, cubeCircleRad, // Position
//    0, 1, 0, // Direction
//    PI, lightYCon); // Angle, concentration
//    //    point(0, -lightY, cubeCircleRad);
//    //    } else if ( key == 't') {
//    spotLight(255, 0, lightYBr, // Color
//    0, -lightY, -cubeCircleRad, // Position
//    0, 1, 0, // Direction
//    PI, lightYCon); // Angle, concentration
//    //    point(0, -lightY, -cubeCircleRad);
//    //}
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
          .setRange(0., 60.)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);


    columnIndex = 1;       
    cp5.addKnob("ribbonSpeed")
      .setPosition(knobPosX[1]+visualSpecificParametersBoxX-knobWidth, knobPosY[1]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(0., 1.)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.addKnob("ribbonRotX")
      .setPosition(knobPosX[2]+visualSpecificParametersBoxX-knobWidth, knobPosY[2]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(-0.01, 0.01)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.addKnob("ribbonRotY")
      .setPosition(knobPosX[3]+visualSpecificParametersBoxX-knobWidth, knobPosY[3]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(-0.01, 0.01)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    columnIndex = 2; 
    cp5.addToggle("ribbonHelix")
      .setPosition(mRectPosX[0]+visualSpecificParametersBoxX, mRectPosY[0]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(true)
            .setWindow(controlWindow);

    columnIndex = 3; 
    cp5.addToggle("ribbonCycloid")
      .setPosition(mRectPosX[1]+visualSpecificParametersBoxX, mRectPosY[1]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setWindow(controlWindow);

    columnIndex = 4; 
    cp5.addToggle("ribbonNoise")
      .setPosition(mRectPosX[2]+visualSpecificParametersBoxX, mRectPosY[2]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setWindow(controlWindow);            



    rowIndex = 1; 
    columnIndex = 0; 
    cp5.addSlider("ribbonCX")
      .setPosition(sliderPosX[0]+visualSpecificParametersBoxX, sliderPosY[0]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.00001, 0.01)
            .setWindow(controlWindow);

    columnIndex = 1; 
    cp5.addSlider("ribbonCY")
      .setPosition(sliderPosX[1]+visualSpecificParametersBoxX, sliderPosY[1]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.00001, 0.01)
            .setWindow(controlWindow);    

    columnIndex = 2; 
    cp5.addSlider("ribbonLength")
      .setPosition(sliderPosX[2]+visualSpecificParametersBoxX, sliderPosY[2]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0., 1.)
            .setWindow(controlWindow);

    columnIndex = 3; 
    cp5.addSlider("ribbonSound")
      .setPosition(sliderPosX[3]+visualSpecificParametersBoxX, sliderPosY[3]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0., 100.)
            .setWindow(controlWindow);

    columnIndex = 4; 
    cp5.addSlider("ribbonSpaceX")
      .setPosition(sliderPosX[4]+visualSpecificParametersBoxX, sliderPosY[4]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(100., 10000.)
            .setWindow(controlWindow);

    columnIndex = 5; 
    cp5.addSlider("ribbonSpaceY")
      .setPosition(sliderPosX[5]+visualSpecificParametersBoxX, sliderPosY[5]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(100., 10000)
            .setWindow(controlWindow);

    columnIndex = 6; 
    cp5.addSlider("ribbonSpaceZ")
      .setPosition(sliderPosX[6]+visualSpecificParametersBoxX, sliderPosY[6]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(100., 10000)
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
    //    "ribbonCount", 
    //    "ribbonSpeed", 
    //    "ribbonLength", 
    //    "ribbonSound", 
    //    "ribbonSpaceX", 
    //    "ribbonSpaceY", 
    //    "ribbonSpaceZ", 
    //    "ribbonHelix", 
    //    "ribbonCycloid", 
    //    "ribbonCX", 
    //    "ribbonCY", 
    //    "ribbonNoise"

    cp5.getController("ribbonCX").setValue(cp5.getController("ribbonCX").getValue()+(map(       faderValDiff[0], 0, 127, 0, cp5.getController("ribbonCX").getMax()-cp5.getController("ribbonCX").getMin())));
    cp5.getController("ribbonCY").setValue(cp5.getController("ribbonCY").getValue()+(map(       faderValDiff[1], 0, 127, 0, cp5.getController("ribbonCY").getMax()-cp5.getController("ribbonCY").getMin())));
    cp5.getController("ribbonLength").setValue(cp5.getController("ribbonLength").getValue()+(map(   faderValDiff[2], 0, 127, 0, cp5.getController("ribbonLength").getMax()-cp5.getController("ribbonLength").getMin())));
    cp5.getController("ribbonSound").setValue(cp5.getController("ribbonSound").getValue()+(map(    faderValDiff[3], 0, 127, 0, cp5.getController("ribbonSound").getMax()-cp5.getController("ribbonSound").getMin())));
    cp5.getController("ribbonSpaceX").setValue(cp5.getController("ribbonSpaceX").getValue()+(map(   faderValDiff[4], 0, 127, 0, cp5.getController("ribbonSpaceX").getMax()-cp5.getController("ribbonSpaceX").getMin())));
    cp5.getController("ribbonSpaceY").setValue(cp5.getController("ribbonSpaceY").getValue()+(map(   faderValDiff[5], 0, 127, 0, cp5.getController("ribbonSpaceY").getMax()-cp5.getController("ribbonSpaceY").getMin())));
    cp5.getController("ribbonSpaceZ").setValue(cp5.getController("ribbonSpaceZ").getValue()+(map(   faderValDiff[6], 0, 127, 0, cp5.getController("ribbonSpaceZ").getMax()-cp5.getController("ribbonSpaceZ").getMin())));

    cp5.getController("ribbonCount").setValue(cp5.getController("ribbonCount").getValue()+(map(   knobValDiff[0], 0, 127, 0, cp5.getController("ribbonCount").getMax()-cp5.getController("ribbonCount").getMin())));
    cp5.getController("ribbonSpeed").setValue(cp5.getController("ribbonSpeed").getValue()+(map(   knobValDiff[1], 0, 127, 0, cp5.getController("ribbonSpeed").getMax()-cp5.getController("ribbonSpeed").getMin())));

    cp5.getController("ribbonHelix").setValue(    buttonsMVal[0]);
    cp5.getController("ribbonCycloid").setValue(    buttonsMVal[8]);
    cp5.getController("ribbonNoise").setValue(  buttonsMVal[16]);
  }

  public void start() {
    println("Starting " + name);
    hint(ENABLE_DEPTH_TEST);
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
  color col;
  float strokeW;
  float kp = 0.1;
  float rX, rY, rZ;
  float colR;

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
    offsetVelocity = 0.05;
    float stepSize = random(5, 20);
    colR = map(i, 0, ribbonCount, 0., 255.);
    strokeW = random(1.0);
    //    rX = random(ribbonSpaceX/5, ribbonSpaceX/2);
    //    rY = random(ribbonSpaceY/5, ribbonSpaceY/2);
    //    rZ = random(ribbonSpaceZ/5, ribbonSpaceZ/2);
    rX = random(-500, 500);
    rY = random(-250, 250);
    rZ = random(-250, 250);
  }


  float xInc = 0;

  void updateHelix() { 

    xInc = (xInc+10*ribbonSpeed);
    float inc = map(ref.x, 0, ribbonSpaceX, 0, TWO_PI);
    //    float soundData = 1+(soundLPFBuf[int(j*spectrumLength/rRes)])*gain;

    inc = (inc + id)%TWO_PI;

    float x = ribbonSpaceX*sin(xInc*0.001);
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

  void updateCircloid() { 
    circleInc += ribbonSpeed*10;

    float rmx = ribbonCX;
    float rmy = ribbonCY;

    float theta = (circleInc)*rmx*id*0.1;
    float psi = ((circleInc)*rmy*id*0.1)/2;

    float r = rX+soundLevelLPF*ribbonSound;

    float cx = r* cos(theta) * sin(psi);
    float cy = r* sin(theta) * sin(psi);
    float cz = r* cos(psi);


    target.x = cx;
    target.y = cy;
    target.z = cz;


    updateRibbon();
  }

  void updateCircle1() { 

    counter += 0.1;
    float theta = counter;
    float psi = map(id, 0, ribbonCount, 0, PI);
    target.x = (rY*2-soundLevelLPF*ribbonSound) * cos(theta) * sin(psi);
    target.z = (rY*2-soundLevelLPF*ribbonSound) * sin(theta) * sin(psi);
    target.y = (rY*2-soundLevelLPF*ribbonSound) * cos(psi);

    //    ref.x += (ribbonSpaceX/2*sin(counter)*cos(map(ref.y, -ribbonSpaceY, ribbonSpaceY, -PI/2, PI/2))-ref.x)/10;
    //    ref.z += (ribbonSpaceZ/2*cos(counter)*cos(map(ref.y, -ribbonSpaceY, ribbonSpaceY, -PI/2, PI/2))-ref.z)/10;

    updateRibbon();
  }

  void updateTorus() { 


    counter += 0.1;
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

  void updateCircle2() { 

    counter += 0.1;
    float theta = counter;
    randomSeed(2);
    float psi = map(id, 0, ribbonCount, 0, PI);
    float idGain = map(id, 0, ribbonCount, 1, 1.);
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


  void updateNoise() { 
    n += 0.1;
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

  void updateRibbon() {
    // create ribbons

    error = PVector.sub(target, ref);
    error.mult(kp);
    ref.add(error);

    boundingBox();
    update(ref, isOutside);
    isOutside = false;
  }


  void update(PVector theP, boolean theIsWraped) {
    // shift the values to the right side
    for (int i=count-1; i>0; i--) {
      //    for (int i=ribbonLength-1; i>0; i--) {

      p[i].set(p[i-1]);
      isGap[i] = isGap[i-1];
    }
    p[0].set(theP);

    isGap[0] = theIsWraped;
  }


  void boundingBox() {
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

  void draw() {
    drawMeshRibbon(col, map(strokeW, 0, 1, 3, 12));
  }

  void drawMeshRibbon(color theMeshCol, float theWidth) {
    // draw the ribbons with meshes
    int colorFader = 30;
    float colorFadeDiff = 100;

    int alfaFader = 30;
    float alfaFadeDiff = 0;

    int widthFader = 5;
    float widthFadeDiff = 15;



    beginShape(TRIANGLE_STRIP);
    for (int i=0; i<int(count*ribbonLength)-1; i++) {
      // if the point was wraped -> finish the mesh an start a new one

      float ribbonAlfa = 255;

      if (i < alfaFader) 
        ribbonAlfa = ribbonAlfa -(alfaFader-i)*(alfaFadeDiff)/alfaFader;
      else if (count*ribbonLength - i < alfaFader)
        ribbonAlfa = ribbonAlfa -(alfaFader-abs(count*ribbonLength-i))*(alfaFadeDiff)/alfaFader;
      //      else
      //        ribbonAlfa = 255;

      colR = map(id, 0, ribbonCount, 0., 200.);
      colR = 127;
      if (i < colorFader) 
        colR = colR -(colorFader-i)*(colorFadeDiff)/colorFader;
//      else if (count*ribbonLength - i < colorFader)
//        colR = colR -(colorFader-abs(count*ribbonLength-i))*(colorFadeDiff)/colorFader;
      //      else
      //        colR = 255;

      fill(colR, 255, 255, ribbonAlfa);


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

  void setRandomPostition() {
    ref.x=random(-ribbonSpaceX, ribbonSpaceX);
    ref.y=random(-ribbonSpaceY, ribbonSpaceY);
    ref.z=random(-ribbonSpaceZ, ribbonSpaceZ);
  }
}

