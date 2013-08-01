int dotsPerCircle = 80;
int circleAmount = 80;

float tet = TWO_PI / dotsPerCircle;
float phi = PI / circleAmount;
dotCircle[] dc = new dotCircle[circleAmount];


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
float deformRotX;
float deformRotY;
float posTemp;
float posMin = 1000.;
float posMax = 0.;

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
    "linesEnable", 
    "facesEnable", 
    "deformRotX", 
    "deformRotY", 
    "linesAlfa", 
    "facesAlfa"
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

  PImage tex;

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
    parameters1 =     loadPreset(presetDir, name, 1);
    parameters2 =     loadPreset(presetDir, name, 2);
    parameters3 =     loadPreset(presetDir, name, 3);
    parameters4 =     loadPreset(presetDir, name, 4);
    parameters5 =     loadPreset(presetDir, name, 5);
    parameters6 =     loadPreset(presetDir, name, 6);
    parameters7 =     loadPreset(presetDir, name, 7);
    parameters8 =     loadPreset(presetDir, name, 8);

    tex = loadImage("Deform.jpg");
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
      .setPosition(sliderPosX[0]+visualSpecificParametersBoxX, sliderPosY[0]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.01, 20.)
            .setWindow(controlWindow);
    columnIndex = 1; 
    cp5.addSlider("n11")
      .setPosition(sliderPosX[1]+visualSpecificParametersBoxX, sliderPosY[1]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.01, 20.)
            .setWindow(controlWindow);
    columnIndex = 2; 
    cp5.addSlider("n12")
      .setPosition(sliderPosX[2]+visualSpecificParametersBoxX, sliderPosY[2]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.01, 20.)
            .setWindow(controlWindow);
    columnIndex = 3; 
    cp5.addSlider("n13")
      .setPosition(sliderPosX[3]+visualSpecificParametersBoxX, sliderPosY[3]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.01, 20.)
            .setWindow(controlWindow);

    rowIndex = 2; 
    columnIndex = 0; 
    cp5.addSlider("m2")
      .setPosition(sliderPosX[4]+visualSpecificParametersBoxX, sliderPosY[4]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.01, 20.)
            .setWindow(controlWindow);
    columnIndex = 1; 
    cp5.addSlider("n21")
      .setPosition(sliderPosX[5]+visualSpecificParametersBoxX, sliderPosY[5]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.01, 20.)
            .setWindow(controlWindow);
    columnIndex = 2; 
    cp5.addSlider("n22")
      .setPosition(sliderPosX[6]+visualSpecificParametersBoxX, sliderPosY[6]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.01, 20.)
            .setWindow(controlWindow);
    columnIndex = 3; 
    cp5.addSlider("n23")
      .setPosition(sliderPosX[7]+visualSpecificParametersBoxX, sliderPosY[7]+visualSpecificParametersBoxY)   
        .setSize(sliderWidth, sliderHeight)
          .setRange(0.01, 20.)
            .setWindow(controlWindow);

    rowIndex = 0; 
    columnIndex = 0; 
    cp5.addToggle("linesEnable")
      .setPosition(mRectPosX[0]+visualSpecificParametersBoxX, mRectPosY[0]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(false)
            .setWindow(controlWindow);
    columnIndex = 1; 
    cp5.addToggle("facesEnable")
      .setPosition(mRectPosX[1]+visualSpecificParametersBoxX, mRectPosY[1]+visualSpecificParametersBoxY)   
        .setSize(mRectWidth, mRectHeight)
          .setValue(true)
            .setWindow(controlWindow);
    columnIndex = 2; 
    cp5.addKnob("linesAlfa")
      .setPosition(knobPosX[0]+visualSpecificParametersBoxX-knobWidth, knobPosY[0]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(0., 255.)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);
    columnIndex = 3; 
    cp5.addKnob("facesAlfa")
      .setPosition(knobPosX[1]+visualSpecificParametersBoxX-knobWidth, knobPosY[1]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(0., 255.)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);
              
    cp5.addKnob("deformRotX")
      .setPosition(knobPosX[2]+visualSpecificParametersBoxX-knobWidth, knobPosY[2]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(-0.05, 0.05)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    cp5.addKnob("deformRotY")
      .setPosition(knobPosX[3]+visualSpecificParametersBoxX-knobWidth, knobPosY[3]+visualSpecificParametersBoxY-knobHeight)   
        .setRadius(knobWidth)
          .setRange(-0.05, 0.05)
            .setViewStyle(Knob.ARC)
              .setWindow(controlWindow);

    columnIndex = 4; 
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

    if (midiEnable) {
      mapMidiInterface();
    }
    mapPresets();

    cam.rotateX(deformRotX);
    cam.rotateY(deformRotY);

    for (int i = 0; i<circleAmount;i++) {
      dc[i].update();
    }

    rotateY(PI);
    //    lightSettings();

    for (int i = 0; i<circleAmount;i++) {
      //      beginShape(POINTS);
      //      for (int j = 0; j<dotsPerCircle;j++) {
      //        stroke(255, 200);
      //        strokeWeight(10);
      //        //                 curveVertex(dc[i].getPos(j).x, dc[i].getPos(j).y, dc[i].getPos(j).z);
      //        vertex(dc[i].getPos(j).x, dc[i].getPos(j).y, dc[i].getPos(j).z);
      //      }
      //      endShape();
      textureMode(NORMAL);
      beginShape(TRIANGLE_STRIP);
      for (int j = 0; j<dotsPerCircle;j++) {
        if (i == circleAmount/2) {
          println(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0));
        }
        posTemp = dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0);

        if (posMin > posTemp) {
          posMin = posTemp;
        }

        if (posMax < posTemp) {
          posMax = posTemp;
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
          colorVertex(0, 0);
          vertex(dc[0].getPos(0).x, dc[0].getPos(0).y, -dc[0].getPos(0).z);          
          vertexC(circleAmount-1, j);
          if ((j == dotsPerCircle-1)) {
            colorVertex(0, 0);
            vertex(dc[0].getPos(0).x, dc[0].getPos(0).y, -dc[0].getPos(0).z);
            vertexC(circleAmount-1, 0);
          }
        }
      }
      endShape();
    }
  }

  public void colorVertex(int i, int j) {
    //    fill(map(j, 0, dotsPerCircle, 0, 255), 255, map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0),0.5,2,0,255), facesAlfa);    
//    fill(map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 20, 200, 50, 150), 255, map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 50, 200, 0, 255), facesAlfa);    
    fill(map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 20, 200, 50, 150), facesAlfa, facesAlfa, 255);    

    //    tint(map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 20, 100, 50, 150), 255, map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 50, 200, 0, 255), facesAlfa);    

    if (!facesEnable) {
      noFill();
    }
    //    stroke(map(j, 0, dotsPerCircle, 0, 255), 255, map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0),0,2,0,255), linesAlfa);    
    stroke(map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 20, 200, 50, 150), 255, map(dist(dc[i].getX(j), dc[i].getY(j), dc[i].getZ(j), 0, 0, 0), 50, 200, 0, 255), linesAlfa);    
    if (!linesEnable) {
      //      noStroke();
    }
  }

  public void vertexC(int i, int j) {
    float x = dc[i].getX(j);
    float y = dc[i].getY(j);
    float z = dc[i].getZ(j);
    colorVertex(i, j);
    //    texture(tex);
    //    vertex(x, y, z, map(i,0,circleAmount,0.,1.),map(j,0,dotsPerCircle,0.,1.));
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
    cp5.getController("m1").setValue(cp5.getController("m1").getValue()+(map(   faderValDiff[0], 0, 127, 0, cp5.getController("m1").getMax()-cp5.getController("m1").getMin())));
    cp5.getController("n11").setValue(cp5.getController("n11").getValue()+(map(   faderValDiff[1], 0, 127, 0, cp5.getController("n11").getMax()-cp5.getController("n11").getMin())));
    cp5.getController("n12").setValue(cp5.getController("n12").getValue()+(map(   faderValDiff[2], 0, 127, 0, cp5.getController("n12").getMax()-cp5.getController("n12").getMin())));
    cp5.getController("n13").setValue(cp5.getController("n13").getValue()+(map( faderValDiff[3], 0, 127, 0, cp5.getController("n13").getMax()-cp5.getController("n13").getMin())));
    cp5.getController("m2").setValue(cp5.getController("m2").getValue()+(map( faderValDiff[4], 0, 127, 0, cp5.getController("m2").getMax()-cp5.getController("m2").getMin())));
    cp5.getController("n21").setValue(cp5.getController("n21").getValue()+(map( faderValDiff[5], 0, 127, 0, cp5.getController("n21").getMax()-cp5.getController("n21").getMin())));
    cp5.getController("n22").setValue(cp5.getController("n22").getValue()+(map( faderValDiff[6], 0, 127, 0, cp5.getController("n22").getMax()-cp5.getController("n22").getMin())));
    cp5.getController("n23").setValue(cp5.getController("n23").getValue()+(map( faderValDiff[7], 0, 127, 0, cp5.getController("n23").getMax()-cp5.getController("n23").getMin())));

    cp5.getController("linesAlfa").setValue(cp5.getController("linesAlfa").getValue()+(map(   knobValDiff[0], 0, 127, 0, cp5.getController("linesAlfa").getMax()-cp5.getController("linesAlfa").getMin())));
    cp5.getController("facesAlfa").setValue(cp5.getController("facesAlfa").getValue()+(map(   knobValDiff[1], 0, 127, 0, cp5.getController("facesAlfa").getMax()-cp5.getController("facesAlfa").getMin())));
    cp5.getController("deformRotX").setValue(cp5.getController("deformRotX").getValue()+(map(   knobValDiff[2], 0, 127, 0, cp5.getController("deformRotX").getMax()-cp5.getController("deformRotX").getMin())));
    cp5.getController("deformRotY").setValue(cp5.getController("deformRotY").getValue()+(map(   knobValDiff[3], 0, 127, 0, cp5.getController("deformRotY").getMax()-cp5.getController("deformRotY").getMin())));

    cp5.getController("linesEnable").setValue(    buttonsMVal[0]);
    cp5.getController("facesEnable").setValue(    buttonsMVal[8]);
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

      float soundData = 1+(soundLPFBuf[int(((lineId+inc*10)%circleAmount)*spectrumLength/circleAmount)])*gain*0.1;
      float soundDataV = 1+(soundLPFBuf[int(((i+inc*10)%dotAmount)*spectrumLength/dotAmount)])*gain*0.05;

      float tempTet = (tet * i);
      float tempPhi = (phi * lineId);

      //      float soundData = 1+(soundLPFBuf[int(j*spectrumLength/rRes)])*gain;
      float rr1 = superformulaPointR(m1, n11, n12, n13, tet*i)*soundDataV;
      float rr2 = superformulaPointR(m2, n21, n22, n23, phi*lineId)*soundData;

      target[i].set(cos(tempTet)*sin(tempPhi)*rr1*rr2, sin(tempTet)*sin(tempPhi)*rr1*rr2, cos(tempPhi)*rr2);
      target[i].mult(100);
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
      target[i].mult(100);
    }
  }
}


// cos sin - sin sin - cos

