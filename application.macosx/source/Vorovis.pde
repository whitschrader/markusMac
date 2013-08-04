/*  
 
 amount slider
 voro alfa
 bezier alfa
 stroke alfa
 center alfa
 star on off
 boid speed
 
 
 SOUND INTERACTION 
 
 bezierde ts
 normalde star center color
 
 
 */
import megamu.mesh.*;



boolean showDela;
boolean showVoro;
boolean showBezier;
boolean showStar;
int flockAmount = 10;
float voroAlfa;
float bezierAlfa;
float strokeAlfa;
float centerAlfa; 
float flockSpeed = 3.0;

int clipX = 2000;
int clipY = 1500;


class Vorovis extends VisualEngine {
  protected ArrayList<controlP5.Controller> controllers;
  String[] parameterNames = { 
    "flockAmount", 
    "showDela", 
    "showVoro", 
    "showBezier", 
    "showStar", 
    "voroAlfa", 
    "strokeAlfa", 
    "centerAlfa", 
    "flockSpeed"
  };

  Voronoi myVoronoi;
  Delaunay myDelaunay;
  Hull myHull;
  Flock flock;

  int numPoints = flockAmount;

  float[][] points;
  float[][] myEdges;
  MPolygon myRegions[], myHullRegion;
  int col[];

  float startX, startY, endX, endY;
  float[][] regionCoordinates;
  float[] regionHeights = new float[200];
  float[] targetHeights = new float[200];
  float[] errorHeights = new float[200];

  float kp = 0.1;

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
  public float camDistance = 2020.;

  public Vorovis(PApplet myApplet, String name) {
    super(myApplet, name);
    println("Vorovis Constructor.");
    controllers = new ArrayList<controlP5.Controller>();
  }

  public void init() {
    cam = new PeasyCam(myApplet, 50);
    cam.setMinimumDistance(1);
    cam.setMaximumDistance(5000000);
    background(0);
    perspective(PI/3, width/height, 1, 5000000);

    // initialize points and calculate diagrams
    initFlock();
    updateMesh();
    colorMode(HSB);

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

    cam.rotateX(0);
    cam.rotateY(0);
    if (mousePressed) {
      if (mouseButton == LEFT) {
        cam.setActive(false);
      } else {
        cam.setActive(true);
      }
    }


    mapPresets();
    frame.setTitle(int(frameRate) + "fps");
    background(0);

    updateMesh();
    drawVoro();

    for (int i = 0; i < flock.boids.size(); i++) {
      Boid bs = (Boid)flock.boids.get(i);
      bs.maxspeed = flockSpeed;
    }
  }  

  void updateMesh() {

    updateFlock();

    myVoronoi = new Voronoi( flock.bPos );
    myHull = new Hull( flock.bPos );
    myDelaunay = new Delaunay( flock.bPos );

    myRegions = myVoronoi.getRegions();
    myHullRegion = myHull.getRegion();
    myEdges = myDelaunay.getEdges();
  }

  void initFlock() {
    flock = new Flock();

    for (int i = 0; i < numPoints; i++) {
      flock.addBoid(new Boid(new PVector(0, 0), 3.0, 0.05));
    }
  }

  void updateFlock() {
    numPoints = flockAmount;

    if ((flock.boids.size()-flockAmount)<0) {
      //add
      for (int i = 0; i < abs(flock.boids.size()-flockAmount); i++) {
        flock.addBoid(new Boid(new PVector(0, 0), 3.0, 0.05));
      }
    } 
    else if ((flock.boids.size()-flockAmount)>0) {
      //remove
      for (int i = 0; i < abs(flock.boids.size()-flockAmount); i++) {
        flock.removeBoid((Boid)flock.boids.get(i));
      }
    }

    Boid bL = (Boid)flock.boids.get(0);
    bL.seek(new PVector(300*sin(frameCount*0.01), 300*cos(frameCount*0.01), 0));
    //    stroke(255);
    //    strokeWeight(10);
    point(bL.loc.x, bL.loc.y, 0);

    flock.run();

    if (bang(1000)) {
      //      stroke(255);
      for (int i = 1; i < abs(flock.boids.size()); i++) {
        Boid bF = (Boid)flock.boids.get(i);
        bF.seek(new PVector(bL.loc.x, bL.loc.y, 0));
        point(bF.loc.x, bF.loc.y, 0);
      }
    } 
    else {
      //      noStroke();
    }
  }



  void drawVoro() {

    //    if (showPoints) {
    //      for (int i = 0; i < flock.boids.size(); i++) {
    //        stroke(155, 255, 255);
    //        strokeWeight(3);
    //        point(flock.bPos[i][0], flock.bPos[i][1]);
    //      }
    //    }

    stroke(255, strokeAlfa);
    strokeWeight(1);

    for (int i=0; i< myRegions.length; i++) {
      regionCoordinates = myRegions[i].getCoords();
      PVector[] rc = new PVector[regionCoordinates.length];

      for (int j = 0; j < regionCoordinates.length;j++) {
        rc[j] = new PVector(regionCoordinates[j][0], regionCoordinates[j][1]);
      }
      float rcArea = polygonArea(rc);
      float areaMin = 2000;
      float areaMax = 300000;
      if (rcArea > 1000000) {
        fill(0);
      } 
      else {


        if (showVoro) {
          //        fill(map(rcArea, areaMin, areaMax, 0, 255), 255, 255, voroAlfa*soundLevelLPF); // use random color for each region
          fill(map(rcArea, areaMin, areaMax, 0, 255), map(abs(flock.bPos[i][1]), 0, 2000, 255, 0), 255, map(soundLPFBuf[int(i*spectrumLength/myRegions.length)], 10, 3000, areaMin, areaMax)-rcArea); // use random color for each region

          beginShape();
          for (int j = 0; j < regionCoordinates.length;j++) {
            vertex(regionCoordinates[j][0], regionCoordinates[j][1], 0);
          }
          endShape(CLOSE);
        }
        if (showStar) {
          beginShape(TRIANGLE_FAN);
          fill(map(rcArea, areaMin, areaMax, 0, 255), 255, 255, centerAlfa); // use random color for each region
          vertex(flock.bPos[i][0], flock.bPos[i][1]);
          for (int j = 0; j < regionCoordinates.length+1;j++) {
            fill(map(rcArea, areaMin, areaMax, 0, 255), 255, 255, voroAlfa); // use random color for each region

            vertex(regionCoordinates[j%regionCoordinates.length][0], regionCoordinates[j%regionCoordinates.length][1], 0);
          }
          endShape(CLOSE);
        }


        if (showBezier) {
          float ts = 0.1f;
          //          ts = map(mouseX, 0, width, 0., 1.);
          //          ts = 0;
          // calculate bezier points
          int nv = regionCoordinates.length;
          float x1, x2, y1, y2, x3, y3;
          beginShape();
          //        fill(map(rcArea,  areaMin, areaMax, 127, 190), 255, 255, bezierAlfa); // use random color for each region
          //          fill(map(rcArea, areaMin, areaMax, 0, 255), map(abs(flock.bPos[i][1]), 0, 2000, 255, 0), 255, map(soundLPFBuf[int(i*spectrumLength/myRegions.length)], 10, 100, areaMin, areaMax)-rcArea); // use random color for each region
          noFill();
          for (int j = 0; j < nv; j++) {
            PVector v1 = new PVector (regionCoordinates[j % nv][0], regionCoordinates[j % nv][1], 0);
            PVector v2 = new PVector (regionCoordinates[(j+1) % nv][0], regionCoordinates[(j+1) % nv][1], 0);
            PVector v3 = new PVector (regionCoordinates[(j+2) % nv][0], regionCoordinates[(j+2) % nv][1], 0);
            x1 =  lerp(lerp(v1.x, v2.x, 0.5f), flock.bPos[i][0], ts);
            y1 =  lerp(lerp(v1.y, v2.y, 0.5f), flock.bPos[i][1], ts);
            x2 =  lerp(v2.x, flock.bPos[i][0], ts);
            y2 =  lerp(v2.y, flock.bPos[i][1], ts);
            x3 =  lerp(lerp(v2.x, v3.x, 0.5f), flock.bPos[i][0], ts);
            y3 =  lerp(lerp(v2.y, v3.y, 0.5f), flock.bPos[i][1], ts);
            // evaluate bezier curve in 10 different points
            for (int k = 0; k < 10; k++) {
              float tt = k / (float) 10;
              float xpos = (1.0f - tt) * ( lerp(x1, x2, tt)) + tt
                * ( lerp(x2, x3, tt));
              float ypos = (1.0f - tt) * ( lerp(y1, y2, tt)) + tt
                * ( lerp(y2, y3, tt));
              vertex(xpos, ypos, 0);
            }
          }
          endShape(CLOSE);
        }
      }
    }



    // draw Voronoi as lines
    if (showDela) {
      strokeWeight(2);
      stroke(255, strokeAlfa);
      for (int i=0; i< myEdges.length; i++) {
        startX = myEdges[i][0];
        startY = myEdges[i][1];
        endX = myEdges[i][2];
        endY = myEdges[i][3];
        line(startX, startY, endX, endY);
      }
    }
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
    int vorovisGUISep = 30;
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
        parameterSize[i] = new PVector((visualSpecificParametersBoxWidth/parameterMatrix[i])-vorovisGUISep, (visualSpecificParametersBoxHeight/parameterMatrix.length)-vorovisGUISep);
        rectMode(CORNER);
      }
    }

    rowIndex = 0; 

    columnIndex = 0; 
    cp5.addKnob("flockAmount")
      .setPosition(knobPosX[0]+visualSpecificParametersBoxX-knobWidth, knobPosY[0]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(10, 150)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);
    columnIndex = 1; 
    cp5.addToggle("showDela")
      .setPosition(mRectPosX[0]+visualSpecificParametersBoxX, mRectPosY[0]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setWindow(controlWindow);
    columnIndex = 2; 
    cp5.addToggle("showVoro")
      .setPosition(mRectPosX[1]+visualSpecificParametersBoxX, mRectPosY[1]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(true)
            .setWindow(controlWindow);
    columnIndex = 3; 
    cp5.addToggle("showBezier")
      .setPosition(mRectPosX[2]+visualSpecificParametersBoxX, mRectPosY[2]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setWindow(controlWindow);
    columnIndex = 4; 
    cp5.addToggle("showStar")
      .setPosition(mRectPosX[3]+visualSpecificParametersBoxX, mRectPosY[3]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setWindow(controlWindow);

    rowIndex = 1; 
    columnIndex = 0; 
    cp5.addSlider("flockSpeed")
      .setPosition(sliderPosX[0]+visualSpecificParametersBoxX, sliderPosY[0]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.01, 100.)
            .setValue(3.)
              .setWindow(controlWindow);
    columnIndex = 1; 
    cp5.addSlider("voroAlfa")
      .setPosition(sliderPosX[1]+visualSpecificParametersBoxX, sliderPosY[1]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0., 255. )
            .setWindow(controlWindow);
    columnIndex = 3; 
    cp5.addSlider("strokeAlfa")
      .setPosition(sliderPosX[3]+visualSpecificParametersBoxX, sliderPosY[3]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0., 255. )
            .setWindow(controlWindow);
    columnIndex = 4; 
    cp5.addSlider("centerAlfa")
      .setPosition(sliderPosX[4]+visualSpecificParametersBoxX, sliderPosY[4]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0., 255. )
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

    cp5.getController("flockSpeed").setValue(cp5.getController("flockSpeed").getValue()+(map(   faderValDiff[0], 0, 127, 0, cp5.getController("flockSpeed").getMax()-cp5.getController("flockSpeed").getMin())));
    cp5.getController("voroAlfa").setValue(cp5.getController("voroAlfa").getValue()+(map(     faderValDiff[1], 0, 127, 0, cp5.getController("voroAlfa").getMax()-cp5.getController("voroAlfa").getMin())));
    cp5.getController("strokeAlfa").setValue(cp5.getController("strokeAlfa").getValue()+(map(   faderValDiff[3], 0, 127, 0, cp5.getController("strokeAlfa").getMax()-cp5.getController("strokeAlfa").getMin())));
    cp5.getController("centerAlfa").setValue(cp5.getController("centerAlfa").getValue()+(map(   faderValDiff[4], 0, 127, 0, cp5.getController("centerAlfa").getMax()-cp5.getController("centerAlfa").getMin())));

    cp5.getController("flockAmount").setValue(cp5.getController("flockAmount").getValue()+(map(  knobValDiff[0], 0, 127, 0, cp5.getController("flockAmount").getMax()-cp5.getController("flockAmount").getMin())));

    cp5.getController("showDela").setValue((cp5.getController("showDela").getValue()+abs(buttonsMValDiff[0]))%2);
    cp5.getController("showVoro").setValue((cp5.getController("showVoro").getValue()+abs(buttonsMValDiff[8]))%2);
    cp5.getController("showBezier").setValue((cp5.getController("showBezier").getValue()+abs(buttonsMValDiff[16]))%2);
    cp5.getController("showStar").setValue((cp5.getController("showStar").getValue()+abs(buttonsMValDiff[1]))%2);
  }

  public void start() {
    println("Starting " + name);
    hint(ENABLE_DEPTH_TEST);
    colorMode(HSB);
    camDistance = 2020.;
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


// The Boid class

class Boid {

  PVector loc;
  PVector vel;
  PVector acc;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed

    Boid(PVector l, float ms, float mf) {
    acc = new PVector(0, 0);
    vel = new PVector(random(-1, 1), random(-1, 1));
    loc = l.get();
    r = 2.0;
    maxspeed = ms;
    maxforce = mf;
  }

  void setForceSpeed(float speed, float force) {
    maxspeed = speed;
    maxforce = force;
  }

  void run(ArrayList boids) {
    flock(boids);
    update();
    borders();
    //    render();
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    // Add the force vectors to acceleration
    acc.add(sep);
    acc.add(ali);
    acc.add(coh);
  }

  // Method to update location
  void update() {
    // Update velocity
    vel.add(acc);
    // Limit speed
    vel.limit(maxspeed);
    loc.add(vel);
    // Reset accelertion to 0 each cycle
    acc.mult(0);
  }

  void seek(PVector target) {
    acc.add(steer(target, false));
  }

  void arrive(PVector target) {
    acc.add(steer(target, true));
  }

  // A method that calculates a steering vector towards a target
  // Takes a second argument, if true, it slows down as it approaches the target
  PVector steer(PVector target, boolean slowdown) {
    PVector steer;  // The steering vector
    PVector desired = target.sub(target, loc);  // A vector pointing from the location to the target
    float d = desired.mag(); // Distance from the target is the magnitude of the vector
    // If the distance is greater than 0, calc steering (otherwise return zero vector)
    if (d > 0) {
      // Normalize desired
      desired.normalize();
      // Two options for desired vector magnitude (1 -- based on distance, 2 -- maxspeed)
      if ((slowdown) && (d < 100.0)) desired.mult(maxspeed*(d/100.0)); // This damping is somewhat arbitrary
      else desired.mult(maxspeed);
      // Steering = Desired minus Velocity
      steer = target.sub(desired, vel);
      steer.limit(maxforce);  // Limit to maximum steering force
    } 
    else {
      steer = new PVector(0, 0);
    }
    return steer;
  }

  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = vel.heading2D() + PI/2;
    fill(200, 100);
    stroke(255);
    pushMatrix();
    translate(loc.x, loc.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
  }

  // Wraparound
  void borders() {

    int bLeft = -clipX;
    int bRight = clipX;
    int bTop = -clipY;
    int bBottom = clipY;


    //    if (loc.x < bLeft-r) loc.x = bRight+r;
    //    if (loc.y < bTop-r) loc.y = bBottom+r;
    //    if (loc.x > bRight+r) loc.x = bLeft-r;
    //    if (loc.y > bBottom+r) loc.y = bTop-r;

    if (loc.x < bLeft-r || loc.x > bRight+r) {
      vel.x = -vel.x;
    }
    if (loc.y < bTop-r || loc.y > bBottom+r) {
      vel.y = -vel.y;
    }
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList boids) {
    float desiredseparation = 20.0;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = PVector.dist(loc, other.loc);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(loc, other.loc);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(vel);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList boids) {
    float neighbordist = 25.0;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = PVector.dist(loc, other.loc);
      if ((d > 0) && (d < neighbordist)) {
        steer.add(other.vel);
        count++;
      }
    }
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(vel);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  PVector cohesion (ArrayList boids) {
    float neighbordist = 25.0;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = loc.dist(other.loc);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.loc); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      return steer(sum, false);  // Steer towards the location
    }
    return sum;
  }
}

// The Flock (a list of Boid objects)

class Flock {
  ArrayList boids; // An arraylist for all the boids
  public float[][] bPos;
  Flock() {
    boids = new ArrayList(); // Initialize the arraylist
  }

  void run() {
    bPos = new float[boids.size()][2];
    for (int i = 0; i < boids.size(); i++) {
      Boid b = (Boid) boids.get(i);  
      b.run(boids);  // Passing the entire list of boids to each boid individually
      bPos[i][0] = b.loc.x;
      bPos[i][1] = b.loc.y;
    }
  }

  void setFS( float sp, float f) {
    for (int i = 0; i < boids.size(); i++) {
      Boid b = (Boid) boids.get(i);  
      b.setForceSpeed(sp, f);  // Passing the entire list of boids to each boid individually
    }
  }

  void addBoid(Boid b) {
    boids.add(b);
  }

  void removeBoid(Boid b) {
    boids.remove(b);
  }
}

