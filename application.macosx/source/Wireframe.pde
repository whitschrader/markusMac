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
float wireRotX = 0.;
float wireRotY = 0.;
boolean wireRotStop = false;
float x, y, z;
float rotIncX = 0.;
float rotX = 0.;
float rotIncY = 0.;
float rotY = 0.;

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
    "wireRotStop"
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
  }    // setup function

  public void update() {    
    if (midiEnable) {
      mapMidiInterface();
    }
    mapPresets();
    frame.setTitle(int(frameRate) + "fps");
    background(0);
    if (!wireRotStop) {
      cam.rotateX(wireRotX);
      cam.rotateY(wireRotY);
    }

    rotX += rotIncX;
    rotY += rotIncY;
    //    float wireSoundVal = fftVar[0].getValue();
    float inLevelMax = 10.;
    float inLevelMin = 0.;

    colorMode(RGB);
    for (int i = 0; i < RRes; i++) {
      beginShape();
      fill(0, 0, 0);

      for (int j = 0; j < rRes; j++) {
        theta = (map(i, 0, RRes, 0, TWO_PI*th)+rotX)%TWO_PI;
        //      theta = (map(i, 0, RRes, 0, TWO_PI));
        //        phi = map(j, 0, rRes, 0, TWO_PI);
        phi = (map(j, 0, rRes, 0, TWO_PI*ph)+rotY)%TWO_PI;
        float soundData = 1+(soundLPFBuf[int(j*spectrumLength/rRes)])*gain;

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
        float soundData = 1+(soundLPFBuf[int(j*spectrumLength/rRes)])*gain;

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

  float LPF(float in) {
    lpfOut = (decay * in + (1-decay) * lpfOutPre)*gain;
    lpfOutPre = lpfOut;
    return lpfOut;
  }

  int timer = 0;
  int timerPre = 0;
  boolean bang(int dur) {
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
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);
    cp5.addKnob("Rad")
      .setPosition(knobPosX[1]+visualSpecificParametersBoxX-knobWidth, knobPosY[1]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(10, 350)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);
    cp5.addKnob("rRes")
      .setPosition(knobPosX[2]+visualSpecificParametersBoxX-knobWidth, knobPosY[2]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(5, 150)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);
    cp5.addKnob("RRes")
      .setPosition(knobPosX[3]+visualSpecificParametersBoxX-knobWidth, knobPosY[3]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(1, 150)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.addKnob("wireRotX")
      .setPosition(knobPosX[4]+visualSpecificParametersBoxX-knobWidth, knobPosY[4]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(-0.05, 0.05)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);
    cp5.addKnob("wireRotY")
      .setPosition(knobPosX[5]+visualSpecificParametersBoxX-knobWidth, knobPosY[5]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(-0.05, 0.05)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.addSlider("th")
      .setPosition(sliderPosX[0]+visualSpecificParametersBoxX, sliderPosY[0]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0., 1.)
            .setWindow(controlWindow);              
    cp5.addSlider("ph")
      .setPosition(sliderPosX[1]+visualSpecificParametersBoxX, sliderPosY[1]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0., 1. )
            .setWindow(controlWindow);              
    cp5.addSlider("rotIncX")
      .setPosition(sliderPosX[2]+visualSpecificParametersBoxX, sliderPosY[2]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(-0.05, 0.05 )
            .setWindow(controlWindow);              
    cp5.addSlider("rotIncY")
      .setPosition(sliderPosX[3]+visualSpecificParametersBoxX, sliderPosY[3]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(-0.05, 0.05 )
            .setWindow(controlWindow);  

    cp5.addToggle("wireRotStop")
      .setPosition(mRectPosX[0]+visualSpecificParametersBoxX, mRectPosY[0]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
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

    cp5.getController("wireRotStop").setValue((cp5.getController("wireRotStop").getValue()+abs(buttonsMValDiff[0]))%2);
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

