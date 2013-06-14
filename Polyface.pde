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
float forceFieldXFreq;
float forceFieldYFreq;
float forceFieldPower = 0.;
float ffx = 0.;
float ffy = 0.;

float movementAmount = 1000;
float polyRotX = 0.;
float polyRotY = 0.;


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
    "lineSize", 
    "polyRotX", 
    "polyRotY", 
    "movementAmount", 
    "lineThreshold", 
    "faceEnable", 
    "faceAmount", 
    "faceAnim", 
    "faceAlfa", 
    "resetGrid", 
    "containerX", 
    "containerY", 
    "forceFieldRange", 
    "forceFieldXFreq", 
    "forceFieldYFreq", 
    "forceFieldPower" 
    //    "palette1", 
    //    "palette2", 
    //    "palette3"
  };

  float[] parameters1 = new float[parameterNames.length];
  float[] parameters2 = new float[parameterNames.length];
  float[] parameters3 = new float[parameterNames.length];
  float[] parameters4 = new float[parameterNames.length];
  float[] parametersTemp = new float[parameterNames.length];


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
    cam.setMaximumDistance(50000);
    background(0);
    perspective(PI/3, width/height, 1, 50000);
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
  }    // setup function

  public void update() {
    background(0);
    
    mapPresets();
    
    cam.rotateX(polyRotX);
    cam.rotateY(polyRotY);

    //    pushStyle();

    ffx += forceFieldXFreq;
    ffy += forceFieldYFreq;
    forceFieldX = containerX * sin(ffx);
    forceFieldY = containerY * cos(ffy);
    if (showForceField) {
      stroke(255, 255, 255);
      strokeWeight(20);
      point(forceFieldX, forceFieldY, 0);
    }

    for (int i = 0; i<numLines;i++) {
      d[i].update();

      for (int j = 0; j<numDots;j++) {
        stroke(0, int(map(abs(d[i].getY(j)), 0, 12500, 0, 5))*50, 255, 200);
        strokeWeight((pointSize+pointSizeVariance*abs(noise(i+frameCount*0.01, j+frameCount*0.01)))/*/abs(cam.getPosition()[2])*/);
        if (pointEnable) {
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
            float alfa = (triangleArea(d[i].getPos(j), d[i+1].getPos(j), d[i].getPos(j+1))/(100*movementAmount)*faceAlfa);
            float hv1 = 0;
            float sv1 = int(map(abs(d[i].getY(j)), 0, 12500, 0, 5))*50;
            float bv1 = map(d[i].getZ(j), -10000, 10000, 50, 255);


            //            fill(0, 100, 200, alfa/*, 255-(newNoise(i*sin(frameCount*0.001), j, frameCount*0.01)*faceAnim)*/);


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


        if (lineEnable) {
          for (int k = 0; k<numLines;k++) {
            for (int l = 0; l<numDots;l++) {

              float dp = PVector.dist(d[i].getPos(j), d[k].getPos(l));
              if ((dp<lineThreshold)) {
                stroke(150, 255, map(dp, 0, lineThreshold, 255, 255), map(dp, 0, lineThreshold, 150, 0));
                //            strokeWeight(40000./abs(cam.getPosition()[2]));
                lineSizeVariance = map(mouseX, 0, width, 1, 1)*abs(noise(k+frameCount*0.01, l+frameCount*0.01));

                strokeWeight(lineSize+lineSizeVariance);
                fill(255, 100);
                beginShape(LINES);
                vertex(d[i].getPos(j).x, d[i].getPos(j).y, d[i].getPos(j).z);
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


    /* 
     

     "palette1", 
     "palette2", 
     "palette3"
     */

    cp5.addToggle("pointEnable")
      .setPosition(parameterPos[1][0].x-parameterSize[1].x/2, parameterPos[1][0].y-parameterSize[1].y/2)   
        .setSize((int)parameterSize[1].x, (int)parameterSize[1].y)
          .setValue(true)
            .setWindow(controlWindow);

    cp5.addToggle("lineEnable")
      .setPosition(parameterPos[1][1].x-parameterSize[1].x/2, parameterPos[1][1].y-parameterSize[1].y/2)   
        .setSize((int)parameterSize[1].x, (int)parameterSize[1].y)
          .setValue(false)
            .setWindow(controlWindow);

    cp5.addToggle("faceEnable")
      .setPosition(parameterPos[1][2].x-parameterSize[1].x/2, parameterPos[1][2].y-parameterSize[1].y/2)   
        .setSize((int)parameterSize[1].x, (int)parameterSize[1].y)
          .setValue(false)
            .setWindow(controlWindow);

    cp5.addToggle("resetGrid")
      .setPosition(parameterPos[1][3].x-parameterSize[1].x/2, parameterPos[1][3].y-parameterSize[1].y/2)   
        .setSize((int)parameterSize[1].x, (int)parameterSize[1].y)
          .setValue(false)
            .setWindow(controlWindow);

    cp5.addKnob("forceFieldPower")
      .setPosition(parameterPos[0][0].x-parameterSize[0].x/2, parameterPos[0][0].y-parameterSize[0].y/2)   
        .setRadius((int)parameterSize[0].x)
          .setRange(-1000., 1000.)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.addKnob("forceFieldRange")
      .setPosition(parameterPos[0][1].x-parameterSize[0].x/2, parameterPos[0][1].y-parameterSize[0].y/2)   
        .setRadius((int)parameterSize[0].x)
          .setRange(1, 10000)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.addKnob("forceFieldXFreq")
      .setPosition(parameterPos[0][2].x-parameterSize[0].x/2, parameterPos[0][2].y-parameterSize[0].y/2)   
        .setRadius((int)parameterSize[0].x)
          .setRange(0.0001, 0.1)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.addKnob("forceFieldYFreq")
      .setPosition(parameterPos[0][3].x-parameterSize[0].x/2, parameterPos[0][3].y-parameterSize[0].y/2)   
        .setRadius((int)parameterSize[0].x)
          .setRange(0.0001, 0.1)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.addKnob("containerX")
      .setPosition(parameterPos[0][4].x-parameterSize[0].x/2, parameterPos[0][4].y-parameterSize[0].y/2)   
        .setRadius((int)parameterSize[0].x)
          .setRange(100., 20000.)
            .setValue(10000.)
              .setViewStyle(Knob.ARC)
                .setWindow(controlWindow);

    cp5.addKnob("containerY")
      .setPosition(parameterPos[0][5].x-parameterSize[0].x/2, parameterPos[0][5].y-parameterSize[0].y/2)   
        .setRadius((int)parameterSize[0].x)
          .setRange(100., 20000.)
            .setValue(10000.)
              .setViewStyle(Knob.ARC)
                .setWindow(controlWindow);

    cp5.addKnob("polyRotX")
      .setPosition(parameterPos[0][6].x-parameterSize[0].x/2, parameterPos[0][6].y-parameterSize[0].y/2)   
        .setRadius((int)parameterSize[0].x)
          .setRange(-0.005, 0.005)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.addKnob("polyRotY")
      .setPosition(parameterPos[0][7].x-parameterSize[0].x/2, parameterPos[0][7].y-parameterSize[0].y/2)   
        .setRadius((int)parameterSize[0].x)
          .setRange(-0.005, 0.005)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.addSlider("pointSize")
      .setPosition(parameterPos[2][0].x-parameterSize[2].x/2, parameterPos[2][0].y-parameterSize[2].y/2)   
        .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
          .setRange(0., 30.)
            .setWindow(controlWindow);

    cp5.addSlider("pointSizeVariance")
      .setPosition(parameterPos[2][1].x-parameterSize[2].x/2, parameterPos[2][1].y-parameterSize[2].y/2)   
        .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
          .setRange(0, 100)
            .setWindow(controlWindow);

    cp5.addSlider("lineSize")
      .setPosition(parameterPos[2][2].x-parameterSize[2].x/2, parameterPos[2][2].y-parameterSize[2].y/2)   
        .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
          .setRange(0., 5.)
            .setWindow(controlWindow);

    cp5.addSlider("lineThreshold")
      .setPosition(parameterPos[2][3].x-parameterSize[2].x/2, parameterPos[2][3].y-parameterSize[2].y/2)   
        .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
          .setRange(0., 3000.)
            .setWindow(controlWindow);

    cp5.addSlider("faceAmount")
      .setPosition(parameterPos[2][4].x-parameterSize[2].x/2, parameterPos[2][4].y-parameterSize[2].y/2)   
        .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
          .setRange(0., 1.)
            .setWindow(controlWindow);

    cp5.addSlider("faceAnim")
      .setPosition(parameterPos[2][5].x-parameterSize[2].x/2, parameterPos[2][5].y-parameterSize[2].y/2)   
        .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
          .setRange(0., 1000.)
            .setWindow(controlWindow);

    cp5.addSlider("faceAlfa")
      .setPosition(parameterPos[2][6].x-parameterSize[2].x/2, parameterPos[2][6].y-parameterSize[2].y/2)   
        .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
          .setRange(0., 1.)
            .setWindow(controlWindow);

    cp5.addSlider("movementAmount")
      .setPosition(parameterPos[2][7].x-parameterSize[2].x/2, parameterPos[2][7].y-parameterSize[2].y/2)   
        .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
          .setRange(0, 3000)
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
      for (int i = 0; i < parameterNames.length-1; i++) {
        cp5.getController(parameterNames[i]).setValue(parameters1[i]);
      }
    } 
    else     if (preset2 && !preset2Pre) {
      presetIndex = 2;
      parameters2 =     loadPreset(presetDir, name, 2);
      for (int i = 0; i < parameterNames.length-1; i++) {
        cp5.getController(parameterNames[i]).setValue(parameters2[i]);
      }
    } 
    else     if (preset3 && !preset3Pre) {
      presetIndex = 3;
      parameters3 =     loadPreset(presetDir, name, 3);
      for (int i = 0; i < parameterNames.length-1; i++) {
        cp5.getController(parameterNames[i]).setValue(parameters3[i]);
        println("3- " + i);
      }
    } 
    else     if (preset4 && !preset4Pre) {
      presetIndex = 4;
      parameters4 =     loadPreset(presetDir, name, 4);
      for (int i = 0; i < parameterNames.length-1; i++) {
        cp5.getController(parameterNames[i]).setValue(parameters4[i]);
      }
    } 
    else if ( savePreset && !savePresetPre) {
      for (int i = 0; i < parameterNames.length-1; i++) {
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

  public void showGUI(boolean show) {
    for (controlP5.Controller c: controllers) {
      c.setVisible(show);
    }
  }

  public void start() {
    println("Starting " + name);
    hint(DISABLE_DEPTH_TEST);
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
  PVector sep;
  float kp = 0.05;
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

    sep.set(movementAmount, movementAmount, movementAmount*10);

    if (bang(900)) {
      for (int i = 0; i<dotAmount;i++) {
        target[i].set(random(-sep.x, sep.x), random(-sep.y, sep.y), random(-sep.z, sep.z));
      }
    }

    for (int i = 0; i<dotAmount;i++) {

      error[i] = PVector.sub(target[i], pos[i]);
      error[i].mult(kp);
      pos[i].add(error[i]);

      float dx = forceFieldX - getPos(i).x;
      float dy = forceFieldY - getPos(i).y;
      float d = mag(dx, dy);

      if (d > 0 && d < forceFieldRange) {
        // calculate force
        float s = d/forceFieldRange;
        float f = 1 / pow(s, 0.5) - 1;
        f = f / forceFieldRange;
        offset[i].add(dx*f*forceFieldPower*pow(sin(inc), 2), dy*f*forceFieldPower*pow(sin(inc), 2), 0);
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
    sep = new PVector(movementAmount, movementAmount, movementAmount*10);

    for (int i = 0; i < dotAmount; i++) {
      pos[i] = new PVector(0, 0, 0);
      error[i] = new PVector(0, 0, 0);
      target[i] = new PVector(0, 0, 0);
      offset[i] = new PVector(
      map(lineId, 0, numLines, -(sep.x*numLines)/2, (sep.x*numLines)/2), 
      map(i, 0, dotAmount, -(sep.y*(dotAmount))/2, (sep.y*(dotAmount))/2), 
      0);
    }
  }
}

