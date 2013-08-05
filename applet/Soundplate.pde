
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

float pStrokeAlfa = 255.;
float pFaceAlfa = 255.;
float noiseGain = 100.;
float soundWaveGain = 1000.;
float plateRotX = 0.;
float plateRotY = 0.;
boolean plateRotStopX = false;
boolean plateRotStopY = false;

float soundPlateVal = 0.;
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
    cp5.getController("preset5").setValue(1.);
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
            .setRange(0., 750.)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("NOISE")   
                  .setWindow(controlWindow); 

    cp5.addKnob("plateRotX")
      .setPosition(knobPosX[1]+visualSpecificParametersBoxX-knobWidth, knobPosY[1]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(-0.05, 0.05)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("VERTICAL ROTATION")  
                  .setWindow(controlWindow); 

    cp5.addKnob("plateRotY")
      .setPosition(knobPosX[2]+visualSpecificParametersBoxX-knobWidth, knobPosY[2]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(-0.05, 0.05)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("HORIZONTAL ROTATION")   
                  .setWindow(controlWindow); 


    rowIndex = 1; 
    columnIndex = 0; 
    columnIndex = 2; 
    cp5.addSlider("pFaceAlfa")
      .setPosition(sliderPosX[1]+visualSpecificParametersBoxX, sliderPosY[1]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0., 255.)
            .setCaptionLabel("         FACE\n TRANSPARENCY")   
              .setWindow(controlWindow); 
    cp5.getController("pFaceAlfa").captionLabel().getStyle().marginLeft = -27;

    columnIndex = 3; 
    cp5.addSlider("pStrokeAlfa")
      .setPosition(sliderPosX[0]+visualSpecificParametersBoxX, sliderPosY[0]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0., 255.)
            .setCaptionLabel("         LINE\n TRANSPARENCY")    
              .setWindow(controlWindow); 
    cp5.getController("pStrokeAlfa").captionLabel().getStyle().marginLeft = -25;

    columnIndex = 4; 
    cp5.addSlider("soundWaveGain")
      .setPosition(sliderPosX[2]+visualSpecificParametersBoxX, sliderPosY[2]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.01, 2.)
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
  float kp = 0.1;
  float inc = 0.;
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
      soundBuf[i] = 0.;
    }
  }


  void update() {

    inc += 0.01;

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
        offset[i].set((newNoise((frameCount*.01)+lineId*.1, i*.1, i*.1)*0+rad*lineId*5)*sin(map(i, 0, dotAmount, -PI, PI)), 
        0, 
        (newNoise((frameCount*.01)+lineId*.1, i*.1, i*.1)*0+rad*lineId*5)*cos(map(i, 0, dotAmount, -PI, PI)));
      } 
      else {
        offset[i].set((newNoise((frameCount*.01)+lineId*.1, i*.1, i*.1)*0+rad*lineId*5)*sin(map(i, 0, dotAmount, -PI, PI)), 
        (newNoise((float)i/13, frameCount*0.01, pow(lineId, 3)) * TWO_PI*noiseGain)- (soundWaveGain*soundLPFBuf[int(((lineId+10)%plateAmount)*spectrumLength/plateAmount)]), 
        (newNoise((frameCount*.01)+lineId*.1, i*.1, i*.1)*0+rad*lineId*5)*cos(map(i, 0, dotAmount, -PI, PI)));
      }

      error[i] = PVector.sub(target[i], pos[i]);
      error[i].mult(kp);
      pos[i].add(error[i]);
      //              float soundData = 1+(soundLPFBuf[int(j*spectrumLength/rRes)])*gain;
      //      pos[i].add(0,(soundLPFBuf[int(i*spectrumLength/dotAmount)])*gain,0);
    }
  }

  void draw() {

    for (int i = 0; i<dotAmount;i++) {
      stroke(255, 150);
      strokeWeight(1);
      curveVertex(getPos(i).x, getPos(i).y, getPos(i).z);
    }
  }

  PVector getPos(int ids) {
    finalPos[ids] = PVector.add(pos[ids], offset[ids]);
    return  finalPos[ids];
  }

  float getX(int ids) {
    return pos[ids].x+offset[ids].x;
  }
  float getY(int ids) {
    return pos[ids].y+offset[ids].y;
  }
  float getZ(int ids) {
    return pos[ids].z+offset[ids].z;
  }

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

  void initializeArrays() {
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

