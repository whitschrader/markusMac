int numDots = 20;
int numLines = 20;

boolean pointEnable = true;
float pointSize = 0.;  //100-100000
float pointSizeVariance;

boolean lineEnable;
float lineSize = 3;
float lineSizeVariance = 0;
float lineThreshold = 1500;

boolean faceEnable;
float faceAmount;
float faceAnim = 1000;
float faceAlfa = 0.;

float containerX = 10000.;
float containerY = 10000.;

boolean resetGrid;

boolean showForceField = false;
float forceFieldRange = 2000;
float forceFieldX;
float forceFieldY;
float forceFieldZ;
float forceFieldXFreq;
float forceFieldYFreq;
float forceFieldPower = 0.;
float ffx = 0.;
float ffy = 0.;

float movementAmount = 1000;
float polyRotX = 0.;
float polyRotY = 0.;
boolean polyRotStopX = false;
boolean polyRotStopY = false;
float[][] polySoundMatrix = new float[numLines][numDots];

color[] palette1;
color[] palette2;
color[] palette3;

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
    cp5.getController("preset5").setValue(1.);
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
        polySoundMatrix[numLines-1][j] = (soundLPFBuf[int(j*spectrumLength/numDots)])*gain;
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
        strokeWeight((pointSize+pointSizeVariance*abs(noise(i+frameCount*0.01, j+frameCount*0.01)))/*/abs(cam.getPosition()[2])*/);
        if (pointEnable) {
          stroke(0, int(map(abs(d[i].getY(j)), 0, 12500, 0, 5))*50, 255, 200);
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
            float sv1 = int(map(abs(d[i].getY(j)), 0, 12500, 0, 5))*50;
            float bv1 = map(d[i].getZ(j), -10000, 10000, 50, 255);

            fill(hv1, sv1, bv1, alfa/*, 255-(newNoise(i*sin(frameCount*0.001), j, frameCount*0.01)*faceAnim)*/);
            vertex(d[i].getX(j), d[i].getY(j), d[i].getZ(j));
            fill(0, int(map(abs(d[i+1].getY(j)), 0, 12500, 0, 255)), map(d[i+1].getZ(j), -10000, 10000, 50, 255), alfa/*, 255-(newNoise(j*cos(frameCount*0.001), i, frameCount*0.01)*faceAnim)*/);
            vertex(d[i+1].getX(j), d[i+1].getY(j), d[i+1].getZ(j));
            fill(0, int(map(abs(d[i].getY(j+1)), 0, 12500, 0, 255)), map(d[i].getZ(j+1), -10000, 10000, 50, 255), alfa/*, 255-(newNoise(i*sin(frameCount*0.001), j, frameCount*0.001)*faceAnim)*/);
            vertex(d[i].getX(j+1), d[i].getY(j+1), d[i].getZ(j+1));
            //fill(0, int(map(abs(d[i+1].getY(j+1)), 0, 12500, 0, 255)), map(d[i+1].getZ(j+1), -10000, 10000, 50, 255), 255-(newNoise(i*sin(frameCount*0.001), j, frameCount*0.001)*faceAnim));
            //vertex(d[i+1].getX(j+1), d[i+1].getY(j+1), d[i+1].getZ(j+1));
            endShape();
          }
        }

        float lineThresholdMap = map(containerX*containerY, 10000, 20000*20000, 0., lineThreshold);

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
                stroke(150, int(map(abs(d[i].getY(j)), 0, 12500, 0, 255)), map(d[i].getZ(j), -10000, 10000, 100, 200), linesAlfa);
                vertex(d[i].getPos(j).x, d[i].getPos(j).y, d[i].getPos(j).z);
                stroke(150, int(map(abs(d[k].getY(l)), 0, 12500, 0, 255)), map(d[k].getZ(l), -10000, 10000, 100, 20), linesAlfa);
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
          .setRange(-1000., 1000.)
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
            .setRange(0.0001, 0.1)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel(" VERTICAL ATTRACTION FREQ")
                  .setWindow(controlWindow);

    cp5.addKnob("forceFieldYFreq")
      .setPosition(knobPosX[3]+visualSpecificParametersBoxX-knobWidth, knobPosY[3]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(0.0001, 0.1)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("HORIZONTAL ATTRACTION FREQ")
                  .setWindow(controlWindow);

    cp5.addKnob("containerX")
      .setPosition(knobPosX[4]+visualSpecificParametersBoxX-knobWidth, knobPosY[4]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(2000., 20000.)
            .setColorValueLabel(valueLabel)
              .setValue(10000.)
                .setViewStyle(Knob.ARC)
                  .setCaptionLabel("HORIZONTAL LIMIT")
                    .setWindow(controlWindow);

    cp5.addKnob("containerY")
      .setPosition(knobPosX[5]+visualSpecificParametersBoxX-knobWidth, knobPosY[5]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(2000., 20000.)
            .setColorValueLabel(valueLabel)
              .setValue(10000.)
                .setViewStyle(Knob.ARC)
                  .setCaptionLabel("VERTICAL LIMIT")
                    .setWindow(controlWindow);

    cp5.addKnob("polyRotX")
      .setPosition(knobPosX[6]+visualSpecificParametersBoxX-knobWidth, knobPosY[6]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setColorValueLabel(valueLabel)
            .setRange(-0.05, 0.05)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("VERTICAL ROTATION")
                  .setWindow(controlWindow);

    cp5.addKnob("polyRotY")
      .setPosition(knobPosX[7]+visualSpecificParametersBoxX-knobWidth, knobPosY[7]+visualSpecificParametersBoxY-knobHeight)   
        .setColorValueLabel(valueLabel)
          .setRadius(knobWidth)
            .setRange(-0.05, 0.05)
              .setViewStyle(Knob.ARC)
                .setCaptionLabel("HORIZONTAL ROTATION")
                  .setWindow(controlWindow);

    cp5.addSlider("pointSize")
      .setPosition(sliderPosX[0]+visualSpecificParametersBoxX, sliderPosY[0]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0., 30.)
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
          .setRange(0., 3000.)
            .setCaptionLabel("LINES THRESHOLD")
              .setWindow(controlWindow);
    cp5.getController("lineThreshold").captionLabel().getStyle().marginLeft = -28;

    cp5.addSlider("faceAlfa")
      .setPosition(sliderPosX[3]+visualSpecificParametersBoxX, sliderPosY[3]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0., 1.)
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
    else if ( savePreset && !savePresetPre && (presetIndex > 4)) {
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
  float kp = 0.5;
  float inc = 0.;


  dotLines(int nd, int id) {
    dotAmount = nd;
    lineId = id;
    initializeArrays();
  }


  void update() {
    //    dotAmount = mouseX;
    //    initializeArrays();
    //    inc += 0.01 + (1./(float)cam.getDistance());
    inc += 0.01;

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
        float f = 1 / pow(s, 0.5) - 1;
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

  void draw() {
    //    pushStyle();
    for (int i = 0; i<dotAmount;i++) {
      stroke(0, int(map(abs(d[lineId].getZ(i)), 0, 10000, 0, 255)), /*map(d[lineId].getZ(i), -10000, 10000, 0, 255)*/255, 200);

      //strokeWeight((50000./abs(cam.getPosition()[2]/10.))+(newNoise(lineId, i, inc))*0);
      strokeWeight(int(map(abs(d[lineId].getZ(i)), 0, 10000, 1, 30)));

      //point(getX(i), getY(i), getZ(i));
      point(getPos(i).x, getPos(i).y, getPos(i).z);
    }
    //    popStyle();
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

