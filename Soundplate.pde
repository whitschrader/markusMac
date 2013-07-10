
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

float vLineAlfa = 255.;
float hLineAlfa = 255.;
float pFaceAlfa = 255.;
float pPointAlfa = 255.;
float noiseGain = 100.;
float soundWaveGain = 1000.;

float soundPlateVal = 0.;
class Soundplate extends VisualEngine {
  protected ArrayList<controlP5.Controller> controllers;

  String[] parameterNames = { 
    "vLineEnable", 
    "hLineEnable", 
    "pFaceEnable", 
    "pPointEnable", 
    "vLineAlfa", 
    "hLineAlfa", 
    "pFaceAlfa", 
    "pPointAlfa", 
    "noiseGain", 
    "soundWaveGain"
  };

  int dotsPerPlate = 200;
  int plateAmount = 20;
  dotPlate[] dp = new dotPlate[numLines];


  float[] parameters1 = new float[parameterNames.length];
  float[] parameters2 = new float[parameterNames.length];
  float[] parameters3 = new float[parameterNames.length];
  float[] parameters4 = new float[parameterNames.length];
  float[] parametersTemp = new float[parameterNames.length];

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
    cam.setMaximumDistance(500000);

    for (int i = 0; i<plateAmount;i++) {
      dp[i] = new dotPlate(dotsPerPlate, i);
    }
    colorMode(HSB);
    hint(ENABLE_DEPTH_TEST); 
    background(0);
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
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setValue(false)
            .setWindow(controlWindow);
    columnIndex = 1; 
    cp5.addToggle("hLineEnable")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setValue(false)
            .setWindow(controlWindow);
    columnIndex = 2; 
    cp5.addToggle("pFaceEnable")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setValue(false)
            .setWindow(controlWindow);
    columnIndex = 3; 
    cp5.addToggle("pPointEnable")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setValue(true)
            .setWindow(controlWindow);
    columnIndex = 4; 
    cp5.addKnob("noiseGain")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setRadius((int)parameterSize[rowIndex].x*0.7)
          .setRange(0., 5000.)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);
    rowIndex = 1; 
    columnIndex = 0; 
    cp5.addSlider("vLineAlfa")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(0., 255.)
            .setWindow(controlWindow);
    columnIndex = 1; 
    cp5.addSlider("hLineAlfa")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(0., 255.)
            .setWindow(controlWindow);
    columnIndex = 2; 
    cp5.addSlider("pFaceAlfa")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(0., 255.)
            .setWindow(controlWindow);
    columnIndex = 3; 
    cp5.addSlider("pPointAlfa")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(0., 255.)
            .setWindow(controlWindow);
    columnIndex = 4; 
    cp5.addSlider("soundWaveGain")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(0., 1000.)
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

  public void update() {
    background(0);
    mapPresets();
    soundPlateVal = fftVar[0].getValue();
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
        }

        // Horizontal Lines
        if (hLineEnable) {
          beginShape(LINES);
          vertexC(i, j); 
          vertexC(i, (j+1)%dotsPerPlate); 
          endShape();
        }  

        if (i < plateAmount - 1) {
          // Vertical Lines
          if (vLineEnable) {
            beginShape(LINES);
            vertexC(i%plateAmount, j%dotsPerPlate); 
            vertexC((i+1)%plateAmount, j%dotsPerPlate); 
            endShape();
          }

          if (pFaceEnable) {
            noStroke();
            beginShape(QUAD_STRIP);
            vertexC(i%plateAmount, j%dotsPerPlate); 
            vertexC((i+1)%plateAmount, j%dotsPerPlate); 
            vertexC(i%plateAmount, (j+1)%dotsPerPlate); 
            vertexC((i+1)%plateAmount, (j+1)%dotsPerPlate); 
            endShape();
          }
        }
      }
    }
  }

  public void colorVertex(int i, int j) {

    if (pPointEnable) {
      stroke(map(j, 0, dotsPerPlate, 0, 255), 255, map(dist(dp[i].getX(j), dp[i].getY(j), dp[i].getZ(j), 0, 0, 0), scaler, scaler+50, 0, 255), pPointAlfa);
      strokeWeight(3);
    }
    if (hLineEnable) {
      stroke(map(j, 0, dotsPerPlate, 0, 255), 255, map(dist(dp[i].getX(j), dp[i].getY(j), dp[i].getZ(j), 0, 0, 0), scaler, scaler+50, 0, 255), hLineAlfa);
      strokeWeight(1);
    }
    if (vLineEnable) {
      stroke(map(j, 0, dotsPerPlate, 0, 255), 255, map(dist(dp[i].getX(j), dp[i].getY(j), dp[i].getZ(j), 0, 0, 0), scaler, scaler+50, 0, 255), vLineAlfa);
      strokeWeight(1);
    }
    if (pFaceEnable) {
      fill(map(j, 0, dotsPerPlate, 0, 255), 255, map(dist(dp[i].getX(j), dp[i].getY(j), dp[i].getZ(j), 0, 0, 0), scaler, scaler+50, 0, 255), pFaceAlfa);
    }
  }

  public void vertexC(int i, int j) {
    float x = dp[i].getX(j);
    float y = dp[i].getY(j);
    float z = dp[i].getZ(j);
    colorVertex(i, j);
    vertex(x, y, z);
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
      for (int i = 0; i < parameterNames.length; i++) {
        cp5.getController(parameterNames[i]).setValue(parameters1[i]);
      }
    } 
    else     if (preset2 && !preset2Pre) {
      presetIndex = 2;
      parameters2 =     loadPreset(presetDir, name, 2);
      for (int i = 0; i < parameterNames.length; i++) {
        cp5.getController(parameterNames[i]).setValue(parameters2[i]);
      }
    } 
    else     if (preset3 && !preset3Pre) {
      presetIndex = 3;
      parameters3 =     loadPreset(presetDir, name, 3);
      for (int i = 0; i < parameterNames.length; i++) {
        cp5.getController(parameterNames[i]).setValue(parameters3[i]);
        println("3- " + i);
      }
    } 
    else     if (preset4 && !preset4Pre) {
      presetIndex = 4;
      parameters4 =     loadPreset(presetDir, name, 4);
      for (int i = 0; i < parameterNames.length; i++) {
        cp5.getController(parameterNames[i]).setValue(parameters4[i]);
      }
    } 
    else if ( savePreset && !savePresetPre) {
      for (int i = 0; i < parameterNames.length; i++) {
        parametersTemp[i] = cp5.getController(parameterNames[i]).getValue();
      }
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

      if (i <dotAmount - bufSpeed)
        soundBuf[i] = soundBuf[i+bufSpeed];
      //      }
      //      soundBuf[bufSize-1] = getSoundLevel(0.9);
      soundBuf[bufSize-1] = map(soundPlateVal, 0, 5, 0., 1.);


      offset[i].set((newNoise((frameCount*.01)+lineId*.1, i*.1, i*.1)*0+rad*lineId*5)*sin(map(i, 0, dotAmount, -PI, PI)), 
      (newNoise((float)i/13, frameCount*0.01, pow(lineId, 3)) * TWO_PI*noiseGain)- (soundWaveGain * soundBuf[i]), 
      (newNoise((frameCount*.01)+lineId*.1, i*.1, i*.1)*0+rad*lineId*5)*cos(map(i, 0, dotAmount, -PI, PI)));

      error[i] = PVector.sub(target[i], pos[i]);
      error[i].mult(kp);
      pos[i].add(error[i]);
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

