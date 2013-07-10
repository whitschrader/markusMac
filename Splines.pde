int ribbonCount = 60;
float ribbonSpeed;
int ribbonLength;
float ribbonSound;
float ribbonSpaceX;
float ribbonSpaceY;
float ribbonSpaceZ;
float ribbonCX;
float ribbonCY;
boolean ribbonHelix;
boolean ribbonCycloid;
boolean ribbonNoise;


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
    "ribbonNoise"
  };

  float[] parameters1 = new float[parameterNames.length];
  float[] parameters2 = new float[parameterNames.length];
  float[] parameters3 = new float[parameterNames.length];
  float[] parameters4 = new float[parameterNames.length];
  float[] parametersTemp = new float[parameterNames.length];

  float[] camRotations = new float[3];
  float[] camLookAt = new float[3];
  public float camDistance;

  // ------ agents ------
  Ribbon[] agents = new Ribbon[1000];

  // ------ mouse interaction ------
  int offsetX = 0, offsetY = 0, clickX = 0, clickY = 0, zoom = -450;
  float stepSize;

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

    //    colorMode(HSB, 360, 100, 100);
    for (int i=0; i<agents.length; i++) {
      agents[i]=new  Ribbon (i, new PVector(random(-ribbonSpaceX, ribbonSpaceX), random(-ribbonSpaceY, ribbonSpaceY), random(-ribbonSpaceZ, ribbonSpaceZ)), 
      (int)70);
    }
  }

  public void update() {
    background(0);
    mapPresets();
    lights();
    for (int i=0; i<ribbonCount; i++) {
      if (ribbonHelix)
        agents[i].updateHelix();

      if (ribbonCycloid)
        agents[i].updateCircloid();

      if (ribbonNoise)
        agents[i].updateNoise();

      //          agents[i].updateCircle1();
      //          agents[i].updateCircle2();

      agents[i].draw();
    }
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
        rectMode(CORNER);
      }
    }

    rowIndex = 0; 
    columnIndex = 0; 
    cp5.addKnob("ribbonCount")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setRadius((int)parameterSize[rowIndex].x*0.7)
          .setRange(0., 60.)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    columnIndex = 1;       
    cp5.addKnob("ribbonSpeed")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setRadius((int)parameterSize[rowIndex].x*0.7)
          .setRange(0., 1.)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    columnIndex = 2; 
    cp5.addToggle("ribbonHelix")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setValue(true)
            .setWindow(controlWindow);

    columnIndex = 3; 
    cp5.addToggle("ribbonCycloid")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setValue(false)
            .setWindow(controlWindow);

    columnIndex = 4; 
    cp5.addToggle("ribbonNoise")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setValue(false)
            .setWindow(controlWindow);            



    rowIndex = 1; 
    columnIndex = 0; 
    cp5.addSlider("ribbonCX")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(0.00001, 0.01)
            .setWindow(controlWindow);

    columnIndex = 1; 
    cp5.addSlider("ribbonCY")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(0.00001, 0.01)
            .setWindow(controlWindow);    

    columnIndex = 2; 
    cp5.addSlider("ribbonLength")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(1., 70.)
            .setWindow(controlWindow);

    columnIndex = 3; 
    cp5.addSlider("ribbonSound")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(0., 1000.)
            .setWindow(controlWindow);

    columnIndex = 4; 
    cp5.addSlider("ribbonSpaceX")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(100., 1000.)
            .setWindow(controlWindow);

    columnIndex = 5; 
    cp5.addSlider("ribbonSpaceY")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(100., 1000)
            .setWindow(controlWindow);

    columnIndex = 6; 
    cp5.addSlider("ribbonSpaceZ")
      .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
        .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
          .setRange(100., 1000)
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


/* --------------------- */

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

    float r = random(1.0);
    if (r < 0.4) col = color(random(190, 200), random(80, 100), random(200, 255));
    else if (r < 0.5) col = color(52, 100, random(200, 255));
    else col = color(273, random(50, 80), random(200, 255));

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
    inc = (inc + id)%TWO_PI;

    float x = ribbonSpaceX*sin(xInc*0.01);
    if (x > ribbonSpaceX) {
      //      isOutside = true;
      xInc = -ribbonSpaceX;
    }
    float y = ((rY+LiveInput.getLevel()*ribbonSound)*sin(inc));
    float z = ((rZ+LiveInput.getLevel()*ribbonSound)*cos(inc));

    float rmx = ribbonCX;
    float rmy = ribbonCY;

    float theta = (frameCount+xInc)*rmx*id*0.01;
    float psi = ((frameCount+xInc)*rmy*id*0.01)/2;

    float r = rX+LiveInput.getLevel()*ribbonSound;

    float cx = r* cos(theta) * sin(psi);
    float cy = r* sin(theta) * sin(psi);
    float cz = r* cos(psi);


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

    float r = rX+LiveInput.getLevel()*ribbonSound;

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
    float soundEffect = LiveInput.getLevel()*ribbonSound;
    soundEffect = 0;
    target.x = (rY*2-soundEffect) * cos(theta) * sin(psi);
    target.z = (rY*2-soundEffect) * sin(theta) * sin(psi);
    target.y = (rY*2-soundEffect) * cos(psi);

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
    angleY = noise(id + ref.x/950, ref.y/950, ref.z/950) * 30 * ribbonSpeed; 
    noiseSeed(13);
    angleZ = noise(id + ref.x/950+offset+n, ref.y/950, ref.z/950) * 30 * ribbonSpeed; 

    target.x +=  cos(angleY) * (5 + LiveInput.getLevel()*100);
    target.y += sin(angleZ) * (5 + LiveInput.getLevel()*100);
    target.z += cos(angleZ)  * (5 + LiveInput.getLevel()*100);

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
    int fader = 1;

    beginShape(TRIANGLE_STRIP);
    for (int i=0; i<ribbonLength-1; i++) {
      // if the point was wraped -> finish the mesh an start a new one

      float ribbonAlfa = 200;

      if (i < fader) 
        fill(theMeshCol, ribbonAlfa-(fader-i)*fader);
      else if (count - i < fader)
        fill(theMeshCol, ribbonAlfa-(fader-(count-i))*fader);
      else
        fill(theMeshCol, ribbonAlfa);

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

