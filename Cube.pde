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
    // "cubeColor", //çift data birden olmuyor canım
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

    //   theApplet.rect(borderMargin, (522)*scaleGUI, 706*scaleGUI, heightGUI-borderMargin-(522)*scaleGUI);


    cp5.addKnob("cubeAmount")
      .setPosition(borderMargin+10, (522)*scaleGUI+30)
        .setRange(1, 250)
          .setRadius(20)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow)
                ;
    cp5.getController("cubeAmount")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;

    controllers.add(cp5.getController("cubeAmount"));

    cp5.addRange("cubeColor")
      .setBroadcast(false) 
        .setPosition(60, 680)
          .setSize(380, 20)
            .setHandleSize(10)
              .setRange(0, 255)
                .setRangeValues(0, 255)
                  .setBroadcast(true)
                    //                  .setColorForeground(color(255, 40))
                    //                    .setColorBackground(color(255, 40))  
                    .setWindow(controlWindow)
                      ;

    cp5.getController("cubeColor")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;

    controllers.add(cp5.getController("cubeColor"));

    cp5.addSlider("cubeSizeOffsetX")
      .setPosition(borderMargin+20, visualSpecificGUIOffset+10)
        .setRange(0.1, cubeCircleRad*6/10)
          .setSize(20, 185)
            .setWindow(controlWindow);

    cp5.getController("cubeSizeOffsetX")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;

    controllers.add(cp5.getController("cubeSizeOffsetX"));

    cp5.addSlider("cubeSizeOffsetY")
      .setPosition(borderMargin+100, visualSpecificGUIOffset+10)
        .setRange(0.1, cubeCircleRad*6/10)
          .setSize(20, 185)
            .setWindow(controlWindow);

    cp5.getController("cubeSizeOffsetY")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;

    controllers.add(cp5.getController("cubeSizeOffsetY"));

    cp5.addSlider("cubeSizeOffsetZ")
      .setPosition(borderMargin+180, visualSpecificGUIOffset+10)
        .setRange(0.1, cubeCircleRad*6/10)
          .setSize(20, 185)
            .setWindow(controlWindow);

    cp5.getController("cubeSizeOffsetZ")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;

    controllers.add(cp5.getController("cubeSizeOffsetZ"));

    cp5.addKnob("rotLimit")
      .setPosition(borderMargin+80, (522)*scaleGUI+30)
        .setRange(0., 4.)
          .setRadius(20)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.getController("rotLimit")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;

    controllers.add(cp5.getController("rotLimit"));

    cp5.addKnob("outlineStroke")
      .setPosition(borderMargin+360, (522)*scaleGUI+30)
        .setRange(0., 255.)
          .setRadius(20)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.getController("outlineStroke")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;

    controllers.add(cp5.getController("outlineStroke"));

    cp5.addKnob("outlineLength")
      .setPosition(borderMargin+430, (522)*scaleGUI+30)
        .setRange(0., 1.)
          .setRadius(20)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.getController("outlineLength")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;

    controllers.add(cp5.getController("outlineLength"));

    cp5.addKnob("rotSelf")
      .setPosition(borderMargin+150, (522)*scaleGUI+30)
        .setRange(-2., 2.)
          .setRadius(20)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.getController("rotSelf")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;

    controllers.add(cp5.getController("rotSelf"));

    cp5.addKnob("rotVariance")
      .setPosition(borderMargin+220, (522)*scaleGUI+30)
        .setRange(0., 30.)
          .setRadius(20)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.getController("rotVariance")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;

    controllers.add(cp5.getController("rotVariance"));

    cp5.addKnob("rotSpeed")
      .setPosition(borderMargin+290, (522)*scaleGUI+30)
        .setRange(-1., 1.)
          .setRadius(20)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.getController("rotSpeed")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;            

    controllers.add(cp5.getController("rotSpeed"));

    cp5.addSlider("cubeSizeVarianceX")
      .setPosition(borderMargin+260, visualSpecificGUIOffset+10)
        .setRange(0.1, cubeCircleRad*6/10)
          .setSize(20, 185)
            .setWindow(controlWindow);

    cp5.getController("cubeSizeVarianceX")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;

    controllers.add(cp5.getController("cubeSizeVarianceX"));

    cp5.addSlider("cubeSizeVarianceY")
      .setPosition(borderMargin+340, visualSpecificGUIOffset+10)
        .setRange(0.1, cubeCircleRad*6/10)
          .setSize(20, 185)
            .setWindow(controlWindow);

    cp5.getController("cubeSizeVarianceY")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;

    controllers.add(cp5.getController("cubeSizeVarianceY"));

    cp5.addSlider("cubeSizeVarianceZ")
      .setPosition(borderMargin+420, visualSpecificGUIOffset+10)
        .setRange(0.1, cubeCircleRad*6/10)
          .setSize(20, 185)
            .setWindow(controlWindow);

    cp5.getController("cubeSizeVarianceZ")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;

    controllers.add(cp5.getController("cubeSizeVarianceZ"));
    presetGUI(cp5, controlWindow);
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
      parameters = append(parameters, float(pieces[i]));
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
    //println(presetIndex);

    preset1Pre = preset1;
    preset2Pre = preset2;
    preset3Pre = preset3;
    preset4Pre = preset4;
    savePresetPre = savePreset;
  }

  public void presetGUI(ControlP5 cp5, ControlWindow controlWindow) {
    //    theApplet.rect(2*borderMargin+(706*scaleGUI), (9+441+72)*scaleGUI, 428*scaleGUI, 307*scaleGUI);

    cp5.addToggle("preset1")
      .setPosition(2*borderMargin+(706*scaleGUI)+(428*scaleGUI*1/4)-50, ((9+441+72)*scaleGUI)+(307*scaleGUI)*3/4)
        .setSize(20, 20)
          .setValue(false)
            .setWindow(controlWindow);

    cp5.getController("preset1")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    //    cp5.getController("preset1").captionLabel().getStyle().marginLeft = 25;
    //    cp5.getController("preset1").captionLabel().getStyle().marginTop = -25;

    controllers.add(cp5.getController("preset1"));

    cp5.addToggle("preset2")
      .setPosition(2*borderMargin+(706*scaleGUI)+(428*scaleGUI*2/4)-50, ((9+441+72)*scaleGUI)+(307*scaleGUI)*3/4)
        .setSize(20, 20)
          .setValue(false)
            .setWindow(controlWindow);

    cp5.getController("preset2")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    //    cp5.getController("preset2").captionLabel().getStyle().marginLeft = 25;
    //    cp5.getController("preset2").captionLabel().getStyle().marginTop = -25;

    controllers.add(cp5.getController("preset2"));

    cp5.addToggle("preset3")
      .setPosition(2*borderMargin+(706*scaleGUI)+(428*scaleGUI*3/4)-50, ((9+441+72)*scaleGUI)+(307*scaleGUI)*3/4)
        .setSize(20, 20)
          .setValue(false)
            .setWindow(controlWindow);

    cp5.getController("preset3")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    //    cp5.getController("preset3").captionLabel().getStyle().marginLeft = 25;
    //    cp5.getController("preset3").captionLabel().getStyle().marginTop = -25;

    controllers.add(cp5.getController("preset3"));

    cp5.addToggle("preset4")
      .setPosition(2*borderMargin+(706*scaleGUI)+(428*scaleGUI*4/4)-50, ((9+441+72)*scaleGUI)+(307*scaleGUI)*3/4)
        .setSize(20, 20)
          .setValue(false)
            .setWindow(controlWindow);

    cp5.getController("preset4")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    //    cp5.getController("preset4").captionLabel().getStyle().marginLeft = 25;
    //    cp5.getController("preset4").captionLabel().getStyle().marginTop = -25;

    controllers.add(cp5.getController("preset4"));

    cp5.addToggle("savePreset")
      .setPosition(2*borderMargin+(706*scaleGUI)+(428*scaleGUI*3/4)-50, ((9+441+72)*scaleGUI)+((307*scaleGUI)*1/4)-20)
        .setSize(90, 20)
          .setValue(false)
            .setWindow(controlWindow);

    cp5.getController("savePreset")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    //    cp5.getController("savePreset").captionLabel().getStyle().marginLeft = 25;
    //    cp5.getController("savePreset").captionLabel().getStyle().marginTop = -25;

    controllers.add(cp5.getController("savePreset"));

    cp5.addToggle("automatic")
      .setPosition(2*borderMargin+(706*scaleGUI)+(428*scaleGUI*1/4)-50, ((9+441+72)*scaleGUI)+((307*scaleGUI)*1/4)-20)
        .setSize(90, 20)
          .setValue(false)
            .setWindow(controlWindow);

    cp5.getController("automatic")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    //    cp5.getController("savePreset").captionLabel().getStyle().marginLeft = 25;
    //    cp5.getController("savePreset").captionLabel().getStyle().marginTop = -25;

    controllers.add(cp5.getController("automatic"));

    cp5.addSlider("transitionTime")
      .setPosition(2*borderMargin+(706*scaleGUI)+(428*scaleGUI*1/4)-50, ((9+441+72)*scaleGUI)+((307*scaleGUI)*2/4)-10)
        .setRange(0.1, cubeCircleRad*6/10)
          .setSize(250, 20)
            .setWindow(controlWindow);

    cp5.getController("transitionTime")
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    cp5.getController("transitionTime").captionLabel().getStyle().marginLeft = -255;
    cp5.getController("transitionTime").captionLabel().getStyle().marginTop = 25;
    controllers.add(cp5.getController("transitionTime"));
  }

  public void start() {
    println("Starting cubes");
  }

  public void exit() {
    println("Exitting cubes");
  }
}

