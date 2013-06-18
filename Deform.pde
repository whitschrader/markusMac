int dotsPerCircle = 60;
int circleAmount = 25;

float tet = TWO_PI / dotsPerCircle;
float phi = PI / circleAmount;
dotCircle[] dc = new dotCircle[circleAmount];

float scaler = 100;
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
    "scaler", 
    "linesEnable", 
    "facesEnable", 
    "linesAlfa", 
    "facesAlfa"
  };

  float[] parameters1 = new float[parameterNames.length];
  float[] parameters2 = new float[parameterNames.length];
  float[] parameters3 = new float[parameterNames.length];
  float[] parameters4 = new float[parameterNames.length];
  float[] parametersTemp = new float[parameterNames.length];

  float[] camRotations = new float[3];
  float[] camLookAt = new float[3];
  public float camDistance;

  public Deform(PApplet myApplet, String name) {
    super(myApplet, name);
    println("Deform Constructor.");
    controllers = new ArrayList<controlP5.Controller>();
  }

  public void init() {
    cam = new PeasyCam(myApplet, 50);
    cam.setMinimumDistance(1);
    cam.setMaximumDistance(500000);

    for (int i = 0; i<circleAmount;i++) {
      dc[i] = new dotCircle(dotsPerCircle, i);
    }
    colorMode(HSB);
    hint(ENABLE_DEPTH_TEST);
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


    rowIndex = 1; 
    columnIndex = 0; 
    cp5.addSlider("m1")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(0., 20.)
            .setWindow(controlWindow);
    columnIndex = 1; 
    cp5.addSlider("n11")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(0., 100.)
            .setWindow(controlWindow);
    columnIndex = 2; 
    cp5.addSlider("n12")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(0., 100.)
            .setWindow(controlWindow);
    columnIndex = 3; 
    cp5.addSlider("n13")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(0., 100.)
            .setWindow(controlWindow);

    rowIndex = 2; 
    columnIndex = 0; 
    cp5.addSlider("m2")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(0., 20.)
            .setWindow(controlWindow);
    columnIndex = 1; 
    cp5.addSlider("n21")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(0., 100.)
            .setWindow(controlWindow);
    columnIndex = 2; 
    cp5.addSlider("n22")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(0., 100.)
            .setWindow(controlWindow);
    columnIndex = 3; 
    cp5.addSlider("n23")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(0., 100.)
            .setWindow(controlWindow);

    rowIndex = 0; 
    columnIndex = 0; 
    cp5.addToggle("linesEnable")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setValue(false)
            .setWindow(controlWindow);
    columnIndex = 1; 
    cp5.addToggle("facesEnable")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setValue(true)
            .setWindow(controlWindow);
    columnIndex = 2; 
    cp5.addKnob("linesAlfa")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setRadius((int)parameterSize[rowIndex].x*0.7)
          .setRange(0., 255.)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);
    columnIndex = 3; 
    cp5.addKnob("facesAlfa")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setRadius((int)parameterSize[rowIndex].x*0.7)
          .setRange(0., 255.)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);
    columnIndex = 4; 
    cp5.addKnob("scaler")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setRadius((int)parameterSize[rowIndex].x*0.7)
          .setRange(0., 1000.)
            .setViewStyle(Knob.ARC)
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

    for (int i = 0; i<circleAmount;i++) {
      dc[i].update();
    }

    rotateY(PI);
    lightSettings();
    for (int i = 0; i<circleAmount;i++) {
      //      beginShape(POINTS);
      //      for (int j = 0; j<dotsPerCircle;j++) {
      //        stroke(255, 200);
      //        strokeWeight(10);
      //        //                 curveVertex(dc[i].getPos(j).x, dc[i].getPos(j).y, dc[i].getPos(j).z);
      //        vertex(dc[i].getPos(j).x, dc[i].getPos(j).y, dc[i].getPos(j).z);
      //      }
      //      endShape();

      beginShape(QUAD_STRIP);
      for (int j = 0; j<dotsPerCircle;j++) {
        if (linesEnable) {
          stroke(map(j, 0, dotsPerCircle, 0, 255), 50+map(i, 0, circleAmount, 0, 200), 100, linesAlfa);
          strokeWeight(1);
        } 
        else {
          noStroke();
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
          fill(map(j, 0, dotsPerCircle, 0, 255), 50+map(i, 0, circleAmount, 0, 200), 100, facesAlfa);    
          if (!facesEnable) {
            noFill();
          }          
          vertex(dc[0].getPos(0).x, dc[0].getPos(0).y, -dc[0].getPos(0).z);          
          vertexC(circleAmount-1, j);
          if ((j == dotsPerCircle-1)) {
            fill(map(j, 0, dotsPerCircle, 0, 255), 50+map(i, 0, circleAmount, 0, 200), 100, facesAlfa);    
            if (!facesEnable) {
              noFill();
            }            
            vertex(dc[0].getPos(0).x, dc[0].getPos(0).y, -dc[0].getPos(0).z);
            vertexC(circleAmount-1, 0);
          }
        }
      }
      endShape();
    }
  }


  public void vertexC(int i, int j) {
    float x = dc[i].getX(j);
    float y = dc[i].getY(j);
    float z = dc[i].getZ(j);

    fill(map(j, 0, dotsPerCircle, 0, 255), 50+map(i, 0, circleAmount, 0, 200), 100, facesAlfa);    
    if (!facesEnable) {
      noFill();
    }
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
  float kp = 0.1;
  float inc = 0.;

  dotCircle(int nd, int id) {
    dotAmount = nd;
    lineId = id;
    initializeArrays();
  }


  void update() {

    inc += 0.01;

    for (int i = 0; i<dotAmount;i++) {
      float rr1 = superformulaPointR(m1, n11, n12, n13, tet*i);
      float rr2 = superformulaPointR(m2, n21, n22, n23, phi*lineId);

      target[i].set(cos(tet*i)*sin(phi*lineId)*rr1*rr2, sin(tet*i)*sin(phi*lineId)*rr1*rr2, cos(phi*lineId)*rr2);
      target[i].mult(scaler);

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
      target[i]=new PVector(cos(tet*i)*sin(phi*lineId), sin(tet*i)*sin(phi*lineId), cos(phi*lineId));
      target[i].mult(scaler);
    }
  }
}


// cos sin - sin sin - cos

