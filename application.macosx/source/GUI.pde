import controlP5.*;

ControlP5 cp5;
ControlWindow controlWindow;
ControlWindowCanvas cc;
ControlFont fontLight, fontBold, fontRegular;
RadioButton r;
int radioButtonValue;
ArrayList<controlP5.Controller> cwControllers;
boolean cwVisible = false;
Range colorRange;

PImage thumb1, thumb2, logo, vsBg, about;
PFont pfontLight, pfontBold, pfontRegular;
int colorMin = 100;
int colorMax = 100;

final int soundReactionGUIOffset = 320;
final int visualSpecificGUIOffset = 450;

final float scaleGUI = 1680./1007.;
final int widthGUI = 1680;
final int heightGUI = 1007;

float borderMarginBig = 68;
float borderMarginSmall = 44;

float borderLinesThickness = 8;

float thumbnailBoxX = 8+68;
float thumbnailBoxY = 8;
float thumbnailBoxWidth = 1528;
float thumbnailBoxHeight = 292;

float visualSpecificParametersBoxX = 8+68;
float visualSpecificParametersBoxY = 8+292+47+236+47;
float visualSpecificParametersBoxWidth = 1528;
float visualSpecificParametersBoxHeight = 342;

float presetsBoxX = 8+68;
float presetsBoxY = 8+292+47;
float presetsBoxWidth = 320;
float presetsBoxHeight = 236;

float soundParametersBoxX = 8+68+320+44;
float soundParametersBoxY = 8+292+47;
float soundParametersBoxWidth = 426;
float soundParametersBoxHeight = 236;

float soundWaveBoxX = 8+68+320+44+426+44;
float soundWaveBoxY = 8+292+47;
float soundWaveBoxWidth = 694;
float soundWaveBoxHeight = 236;

color mainYellow;
color mainBlue;
color mainBackground;
color panelBackground;
color label;
color dimYellow;
color thinLines;
color inactive;
color textColor;

float thumbnailImageWidth = 185;
float thumbnailImageHeight = 104;
float thumbnailImageSpacing = 47;
int selectedThumbnail;
int selectedThumbnailPre;


void initializeGUI() {

  colorMode(HSB);
  mainYellow       = color(27, 228, 251);
  mainBlue         = color(137, 252, 100);
  mainBackground   = color(0, 0, 52);
  panelBackground  = color(156, 16, 48);
  label            = color(0, 0, 202);
  dimYellow        = color(27, 255, 148);
  thinLines        = color(0, 0, 102);
  inactive         = color(0, 0, 61);
  textColor        = color(255, 0, 176);
  cp5 = new ControlP5(this);
  cp5.disableShortcuts();
  controlWindow = cp5.addControlWindow("GUI", 0, 57, widthGUI, heightGUI, 60)
    .hideCoordinates()
      .setBackground(mainBackground);

  controlWindow.setUpdateMode(ControlWindow.NORMAL);
  cc = new MyCanvas();
  cc.pre();
  controlWindow.addCanvas(cc);
  pfontLight = createFont("PFDinTextCompPro-Light", 200, true); // use true/false for smooth/no-smooth
  pfontBold = createFont("PFDinTextCompPro-Bold", 200, true); // use true/false for smooth/no-smooth
  pfontRegular = createFont("PFDinTextCompPro-Regular", 200, true); // use true/false for smooth/no-smooth
  fontLight = new ControlFont(pfontLight, 200);
  fontBold = new ControlFont(pfontBold, 200);
  fontRegular = new ControlFont(pfontRegular, 200);
  cp5.setColorForeground(mainYellow);
  cp5.setColorActive(dimYellow);
  cp5.setColorBackground(mainBlue);
  cp5.setColorCaptionLabel(textColor);
  cp5.setColorValueLabel(textColor);
  cp5.setAutoDraw(false);

  cwControllers = new ArrayList<controlP5.Controller>();


  soundReactionGUI(cp5, controlWindow);
  presetsGUI(cp5, controlWindow);
  foregroundGUI(cp5, controlWindow);

  for (int i=0; i<engines.length; ++i) {
    engines[i].initGUI(cp5, controlWindow);
  }

  logo = loadImage("logo.png");
  vsBg = loadImage("vsGUIbg.png");
  about = loadImage("about.png");
  showCWGUI(false);
}


public void showCWGUI(boolean show) {
  //  println(cwControllers.size());
  for (controlP5.Controller c: cwControllers) {
    c.setVisible(show);
  }
}

void controlEvent(ControlEvent theControlEvent) {
  engines[currentEngineIndex].controlEvent(theControlEvent);

  if (theControlEvent.isFrom(r)) {
    radioButtonValue = int(theControlEvent.group().value());
  }
}

class MyCanvas extends ControlWindowCanvas {

  public boolean mouseDragged() {
    return true;
  }

  public void drawThumbnails(PApplet theApplet) {
    theApplet.pushStyle();
    for (int i = 0; i < engines.length; i++) {
      //      float thumbX = thumbnailBoxX + (thumbnailBoxWidth/3) + thumbnailImageSpacing*2 + (thumbnailImageWidth + thumbnailImageSpacing)*(i%5);
      float thumbX = 320+thumbnailImageSpacing*2.6 + (thumbnailImageWidth + thumbnailImageSpacing)*(i%5);
      theApplet.image(engines[i].thumbnail, thumbX, (28+8)+(((int)i/5)*(thumbnailImageHeight+28)), thumbnailImageWidth, thumbnailImageHeight);

      if (theApplet.mousePressed)
        if ((theApplet.mouseX>thumbX)&&(theApplet.mouseX<thumbX+thumbnailImageWidth)&&(theApplet.mouseY>(28+8)+(((int)i/5)*(thumbnailImageHeight+28)))&&(theApplet.mouseY<(28+8)+(((int)i/5)*(thumbnailImageHeight+28))+thumbnailImageHeight)) {
          //        changeVisualEngine(i);
          selectedThumbnail = i;
        }

      theApplet.textFont(pfontLight, 18);
      if (i == currentEngineIndex) {
        theApplet.fill(textColor);
      } 
      else {
        theApplet.fill(mainYellow);
      }
      theApplet.text(engines[i].name, thumbX, (28+5)+(((int)i/5)*(thumbnailImageHeight+28))+thumbnailImageHeight+20);
    }

    theApplet.noFill();
    theApplet.stroke(mainYellow);
    theApplet.strokeWeight(2);
    theApplet.rectMode(CORNER);
    //    theApplet.rect(thumbnailBoxX + (thumbnailBoxWidth/3) + thumbnailImageSpacing*2 + (thumbnailImageWidth + thumbnailImageSpacing)*(currentEngineIndex%5), thumbnailBoxY+borderMarginBig+((int)currentEngineIndex/5)*(thumbnailImageHeight+borderMarginSmall), thumbnailImageWidth, thumbnailImageHeight);
    theApplet.rect(320+thumbnailImageSpacing*2.6 + (thumbnailImageWidth + thumbnailImageSpacing)*(currentEngineIndex%5), (28+8)+(((int)currentEngineIndex/5)*(thumbnailImageHeight+28)), thumbnailImageWidth, thumbnailImageHeight);

    theApplet.popStyle();
  }

  public void drawFFT(PApplet theApplet) {
    soundWaveBoxHeight = soundWaveBoxHeight/2;
    soundWaveBoxY = soundWaveBoxY+1;
    for (int i = 0; i < LiveInput.spectrum.length; i++) {
      theApplet.pushStyle();
      theApplet.colorMode(HSB);
      theApplet.stroke(mainBlue);
      theApplet.strokeCap(RECT);
      theApplet.strokeWeight(soundWaveBoxWidth/LiveInput.spectrum.length);
      theApplet.fill(255);
      theApplet.line(
      (soundWaveBoxWidth/LiveInput.spectrum.length)*(i+1)+soundWaveBoxX, 
      soundWaveBoxY+(soundWaveBoxHeight/2), 
      (soundWaveBoxWidth/LiveInput.spectrum.length)*(i+1)+soundWaveBoxX, 
      (soundWaveBoxY+(soundWaveBoxHeight/2))-constrain(LiveInput.spectrum[i]*gain, 0, soundWaveBoxHeight/2)
        );
      theApplet.line(
      (soundWaveBoxWidth/LiveInput.spectrum.length)*(i+1)+soundWaveBoxX, 
      soundWaveBoxY+(soundWaveBoxHeight/2), 
      (soundWaveBoxWidth/LiveInput.spectrum.length)*(i+1)+soundWaveBoxX, 
      (soundWaveBoxY+(soundWaveBoxHeight/2))+constrain(LiveInput.spectrum[i]*gain, 0, soundWaveBoxHeight/2)
        );
      theApplet.popStyle();
    }
    soundWaveBoxY = soundWaveBoxY-1;
    soundWaveBoxHeight = soundWaveBoxHeight*2;
  }

  public void drawFFTLPF(PApplet theApplet) {
    soundWaveBoxHeight = soundWaveBoxHeight/2;
    soundWaveBoxY = soundWaveBoxY + soundWaveBoxHeight;

    for (int i = 0; i < LiveInput.spectrum.length; i++) {
      theApplet.pushStyle();
      theApplet.stroke(dimYellow);
      theApplet.strokeCap(RECT);
      theApplet.strokeWeight(soundWaveBoxWidth/LiveInput.spectrum.length);
      theApplet.fill(255);
      theApplet.line(
      (soundWaveBoxWidth/LiveInput.spectrum.length)*(i+1)+soundWaveBoxX, 
      soundWaveBoxY+(soundWaveBoxHeight/2), 
      (soundWaveBoxWidth/LiveInput.spectrum.length)*(i+1)+soundWaveBoxX, 
      (soundWaveBoxY+(soundWaveBoxHeight/2))-constrain(soundLPFBuf[i]*gain, 0, soundWaveBoxHeight/2)
        );
      theApplet.line(
      (soundWaveBoxWidth/LiveInput.spectrum.length)*(i+1)+soundWaveBoxX, 
      soundWaveBoxY+(soundWaveBoxHeight/2), 
      (soundWaveBoxWidth/LiveInput.spectrum.length)*(i+1)+soundWaveBoxX, 
      (soundWaveBoxY+(soundWaveBoxHeight/2))+constrain(soundLPFBuf[i]*gain, 0, soundWaveBoxHeight/2)
        );
      theApplet.popStyle();
    }
    soundWaveBoxY = soundWaveBoxY - soundWaveBoxHeight;
    soundWaveBoxHeight = soundWaveBoxHeight*2;
  }

  public void drawFFTFilters(PApplet theApplet) {

    for (int i = 0; i < fftVar.length; i++) {

      float filterVisualRange = (soundWaveBoxWidth/LiveInput.spectrum.length)*fftVar[i].fftRange*2;
      float filterVisualWmin = ((soundWaveBoxWidth/LiveInput.spectrum.length)*(fftVar[i].baseFreq-fftVar[i].fftRange));
      float filterVisualWmax =  ((soundWaveBoxWidth/LiveInput.spectrum.length)*(fftVar[i].baseFreq+fftVar[i].fftRange));

      theApplet.pushStyle();
      theApplet.strokeCap(RECT);
      theApplet.strokeWeight(filterVisualRange);
      theApplet.stroke(dimYellow, 150);

      theApplet.line(
      ((soundWaveBoxWidth/LiveInput.spectrum.length))*(fftVar[i].baseFreq)+soundWaveBoxX, 
      (soundWaveBoxHeight*(i+1)/(fftVar.length+1))+soundWaveBoxY, 
      ((soundWaveBoxWidth/LiveInput.spectrum.length))*(fftVar[i].baseFreq)+soundWaveBoxX, 
      (soundWaveBoxHeight*(i+1)/(fftVar.length+1))+soundWaveBoxY-constrain(fftVar[i].getValue(), 0, soundWaveBoxHeight/2)
        );

      theApplet.line(
      ((soundWaveBoxWidth/LiveInput.spectrum.length))*(fftVar[i].baseFreq)+soundWaveBoxX, 
      (soundWaveBoxHeight*(i+1)/(fftVar.length+1))+soundWaveBoxY, 
      ((soundWaveBoxWidth/LiveInput.spectrum.length))*(fftVar[i].baseFreq)+soundWaveBoxX, 
      (soundWaveBoxHeight*(i+1)/(fftVar.length+1))+soundWaveBoxY+constrain(fftVar[i].getValue(), 0, soundWaveBoxHeight/2)
        );      

      if ((theApplet.mouseX < filterVisualWmax+soundWaveBoxX)&&(theApplet.mouseX > filterVisualWmin+soundWaveBoxX)) {
        if ((theApplet.mouseY < (soundWaveBoxHeight*(i+1)/(fftVar.length+1))+5+soundWaveBoxY)&&(theApplet.mouseY > (soundWaveBoxHeight*(i+1)/(fftVar.length+1))-5+soundWaveBoxY)) {
          theApplet.stroke(mainYellow, 150);
          if (theApplet.mousePressed) {
            if ((theApplet.mouseX-(soundWaveBoxWidth/LiveInput.spectrum.length)*fftVar[i].fftRange > soundWaveBoxX)&&(theApplet.mouseX+(soundWaveBoxWidth/LiveInput.spectrum.length)*fftVar[i].fftRange < soundWaveBoxX+soundWaveBoxWidth)) {
              fftVar[i].setBase(int((theApplet.mouseX-soundWaveBoxX)/(soundWaveBoxWidth/LiveInput.spectrum.length)));
            }
          }
        }      
        else {
          theApplet.stroke(mainYellow);
        }
      }  
      else {
        theApplet.stroke(mainYellow);
      }       



      theApplet.line(
      ((soundWaveBoxWidth/LiveInput.spectrum.length))*(fftVar[i].baseFreq)+soundWaveBoxX, 
      (soundWaveBoxHeight*(i+1)/(fftVar.length+1))-5+soundWaveBoxY, 
      ((soundWaveBoxWidth/LiveInput.spectrum.length))*(fftVar[i].baseFreq)+soundWaveBoxX, 
      (soundWaveBoxHeight*(i+1)/(fftVar.length+1))+5+soundWaveBoxY
        );



      theApplet.popStyle();
    }
  }


  public void draw(PApplet theApplet) {
    //    theApplet.frame.setTitle(int(frameRate)+"fps");
    theApplet.frame.setTitle("NOS Visual Engine");
    if (theApplet.frameCount<10) {
      theApplet.image(about, theApplet.width/2-about.width/2, theApplet.height/2-about.height/2);
      cwVisible = true;
      showCWGUI(false);
      engines[currentEngineIndex].showGUI(false);
    } 
    else {
      cwVisible = false;
      showCWGUI(true);
      engines[currentEngineIndex].showGUI(true);


      theApplet.colorMode(HSB);
      theApplet.background(mainBackground);

      theApplet.pushStyle();
      theApplet.noStroke();
      theApplet.fill(mainYellow);
      theApplet.rect(borderLinesThickness+borderMarginBig, 0, thumbnailBoxWidth, borderLinesThickness);
      theApplet.rect(borderLinesThickness+borderMarginBig, heightGUI-borderLinesThickness, thumbnailBoxWidth, heightGUI);
      theApplet.fill(mainBlue);
      theApplet.rect(0, 0, borderLinesThickness, heightGUI-borderMarginSmall-borderLinesThickness);
      theApplet.rect(widthGUI-borderLinesThickness, 0, widthGUI, heightGUI-borderMarginSmall-borderLinesThickness);

      theApplet.fill(panelBackground);
      theApplet.rect(thumbnailBoxX, thumbnailBoxY, thumbnailBoxWidth, thumbnailBoxHeight);
      //    theApplet.rect(visualSpecificParametersBoxX, visualSpecificParametersBoxY, visualSpecificParametersBoxWidth, visualSpecificParametersBoxHeight);
      theApplet.image(vsBg, visualSpecificParametersBoxX, visualSpecificParametersBoxY, visualSpecificParametersBoxWidth, visualSpecificParametersBoxHeight);
      theApplet.rect(presetsBoxX, presetsBoxY, presetsBoxWidth, presetsBoxHeight);
      theApplet.rect(soundParametersBoxX, soundParametersBoxY, soundParametersBoxWidth, soundParametersBoxHeight);
      theApplet.rect(soundWaveBoxX, soundWaveBoxY, soundWaveBoxWidth, soundWaveBoxHeight);

      theApplet.stroke(mainYellow);
      theApplet.strokeWeight(1);
      theApplet.strokeCap(RECT);

      theApplet.line(visualSpecificParametersBoxX, visualSpecificParametersBoxY, visualSpecificParametersBoxX+visualSpecificParametersBoxWidth, visualSpecificParametersBoxY);
      theApplet.line(presetsBoxX, presetsBoxY, presetsBoxX+presetsBoxWidth, presetsBoxY);
      theApplet.line(soundParametersBoxX, soundParametersBoxY, soundParametersBoxX+soundParametersBoxWidth, soundParametersBoxY);
      theApplet.line(soundWaveBoxX, soundWaveBoxY, soundWaveBoxX+soundWaveBoxWidth, soundWaveBoxY);

      theApplet.stroke(thinLines);
      theApplet.line(thumbnailBoxX, thumbnailBoxY+thumbnailBoxHeight, thumbnailBoxX+thumbnailBoxWidth, thumbnailBoxY+thumbnailBoxHeight);
      theApplet.line(visualSpecificParametersBoxX, visualSpecificParametersBoxY+visualSpecificParametersBoxHeight, visualSpecificParametersBoxX+visualSpecificParametersBoxWidth, visualSpecificParametersBoxY+visualSpecificParametersBoxHeight);
      theApplet.line(presetsBoxX, presetsBoxY+presetsBoxHeight, presetsBoxX+presetsBoxWidth, presetsBoxY+presetsBoxHeight);
      theApplet.line(soundParametersBoxX, soundParametersBoxY+soundParametersBoxHeight, soundParametersBoxX+soundParametersBoxWidth, soundParametersBoxY+soundParametersBoxHeight);
      theApplet.line(soundWaveBoxX, soundWaveBoxY+soundWaveBoxHeight, soundWaveBoxX+soundWaveBoxWidth, soundWaveBoxY+soundWaveBoxHeight);
      //    theApplet.line(thumbnailBoxX+thumbnailBoxWidth/3, thumbnailBoxY+borderMarginBig, thumbnailBoxX+thumbnailBoxWidth/3, thumbnailBoxY+thumbnailBoxHeight-borderMarginSmall);
      theApplet.line(320+76, 28+8, 320+76, 300-14);

      theApplet.popStyle();

      theApplet.image(logo, borderLinesThickness+borderMarginBig, borderLinesThickness+28);

      drawThumbnails(theApplet);
      drawFFT(theApplet);
      drawFFTLPF(theApplet);
      //    drawFFTFilters(theApplet);

      theApplet.pushStyle();
      theApplet.stroke(255);
      theApplet.fill(textColor);
      theApplet.textFont(pfontLight, 24);
      theApplet.text("VISUAL SPECIFIC PARAMETERS", visualSpecificParametersBoxX, visualSpecificParametersBoxY-2);
      theApplet.text("SOUND REACTION", soundParametersBoxX, soundParametersBoxY-2);
      theApplet.text("PRESETS", presetsBoxX, presetsBoxY-2);
      theApplet.text("SOUND REACTION ADJUSTMENT", soundWaveBoxX, soundWaveBoxY-2);
      theApplet.textFont(pfontLight, 20);
      theApplet.text("v1.0", borderLinesThickness+borderMarginBig+100, borderLinesThickness+80);
      //      theApplet.text("fps: " + (int)frameRate, borderLinesThickness+borderMarginBig+10, borderLinesThickness+280);
      theApplet.textFont(pfontLight, 18);
      theApplet.text("fps: " + (int)frameRate, theApplet.width-116, theApplet.height-14);
      //    theApplet.text("No Preview Available.", 170, 170);

      //    theApplet.image(preview,thumbnailBoxX, (thumbnailBoxY+borderMarginBig),373,207);
      theApplet.popStyle();
    }
  }
}


void soundReactionGUI(ControlP5 cp5, ControlWindow controlWindow) {

  String[] parameterNames = {
    "SR", "gain", "decay"
  };
  int soundReactionGUISep = 50;

  int[] parameterMatrix = {
    1, 1, 1
  };    //x = 1; y = 3

  PVector[][] parameterPos = new PVector[parameterMatrix.length][max(parameterMatrix)]; 
  PVector[] parameterSize = new PVector[parameterMatrix.length]; 

  for (int i = 0; i < parameterMatrix.length; i++) {
    for (int j = 0; j < parameterMatrix[i]; j++) {
      parameterPos[i][j] = new PVector(soundParametersBoxX + (soundParametersBoxWidth/(parameterMatrix[i]*2)*(j*2+1)), soundParametersBoxY +(soundParametersBoxHeight/(parameterMatrix.length*2)*(i*2+1)));
      parameterSize[i] = new PVector((soundParametersBoxWidth/parameterMatrix[i])-soundReactionGUISep, (soundParametersBoxHeight/parameterMatrix.length)-soundReactionGUISep);
      noStroke();
      fill(127);
      rectMode(CORNER);
    }
  }


  cp5.addToggle("SR")
    .setPosition(parameterPos[0][0].x-parameterSize[0].x/2, parameterPos[0][0].y-parameterSize[0].y/2)   
      .setSize((int)parameterSize[0].y, (int)parameterSize[0].y)
        .setValue(true)
          .setWindow(controlWindow);

  cp5.addSlider("gain")
    .setPosition(parameterPos[1][0].x-parameterSize[1].x/2, parameterPos[1][0].y-parameterSize[1].y/2)   
      .setRange(0., 0.5)
        .setSize((int)parameterSize[1].x, (int)parameterSize[1].y)
          .setWindow(controlWindow);  

  cp5.addSlider("decay")
    .setPosition(parameterPos[2][0].x-parameterSize[2].x/2, parameterPos[2][0].y-parameterSize[2].y/2)   
      .setRange(0.01, 0.5)
        .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
          .setWindow(controlWindow);  

  cp5.getController("SR").captionLabel().getStyle().marginLeft = 0;
  cp5.getController("SR").captionLabel().getStyle().marginTop = 0;

  cp5.getController("gain").captionLabel().getStyle().marginLeft = -(int)parameterSize[1].x-4;
  cp5.getController("gain").captionLabel().getStyle().marginTop = 24;

  cp5.getController("decay").captionLabel().getStyle().marginLeft = -(int)parameterSize[2].x-4;
  cp5.getController("decay").captionLabel().getStyle().marginTop = 24;


  for (int i = 0; i < parameterNames.length; i++) {
    cp5.getController(parameterNames[i])
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    cwControllers.add(cp5.getController(parameterNames[i]));
  }
}

public void presetsGUI(ControlP5 cp5, ControlWindow controlWindow) {


  String[] parameterNames = {
    "preset1", 
    "preset2", 
    "preset3", 
    "preset4", 
    "preset5", 
    "preset6", 
    "preset7", 
    "preset8", 
    "savePreset", 
    "automatic", 
    "transitionTime"
  };
  int presetGUISep = 35;

  int[] parameterMatrix = {
    2, 1, 4, 4
  };    //x = 1; y = 3

  PVector[][] parameterPos = new PVector[parameterMatrix.length][max(parameterMatrix)]; 
  PVector[] parameterSize = new PVector[parameterMatrix.length]; 

  for (int i = 0; i < parameterMatrix.length; i++) {
    for (int j = 0; j < parameterMatrix[i]; j++) {
      parameterPos[i][j] = new PVector(presetsBoxX + (presetsBoxWidth/(parameterMatrix[i]*2)*(j*2+1)), presetsBoxY + ((presetsBoxHeight-10)/(parameterMatrix.length*2)*(i*2+1)));
      parameterSize[i] = new PVector((presetsBoxWidth/parameterMatrix[i])-presetGUISep, (presetsBoxHeight/parameterMatrix.length)-presetGUISep);
      noStroke();
      fill(127);
      rectMode(CORNER);
    }
  }

  cp5.addToggle("preset1")
    .setPosition(parameterPos[2][0].x-parameterSize[2].x/2, parameterPos[2][0].y-parameterSize[2].y/2)   
      .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
        .setValue(false)
          .setWindow(controlWindow);

  cp5.addToggle("preset2")
    .setPosition(parameterPos[2][1].x-parameterSize[2].x/2, parameterPos[2][1].y-parameterSize[2].y/2)   
      .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
        .setValue(false)
          .setWindow(controlWindow);

  cp5.addToggle("preset3")
    .setPosition(parameterPos[2][2].x-parameterSize[2].x/2, parameterPos[2][2].y-parameterSize[2].y/2)   
      .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
        .setValue(false)
          .setWindow(controlWindow);

  cp5.addToggle("preset4")
    .setPosition(parameterPos[2][3].x-parameterSize[2].x/2, parameterPos[2][3].y-parameterSize[2].y/2)   
      .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
        .setValue(false)
          .setWindow(controlWindow);

  cp5.addToggle("preset5")
    .setPosition(parameterPos[3][0].x-parameterSize[3].x/2, parameterPos[3][0].y-parameterSize[3].y/2)   
      .setSize((int)parameterSize[3].x, (int)parameterSize[3].y)
        .setValue(false)
          .setWindow(controlWindow);

  cp5.addToggle("preset6")
    .setPosition(parameterPos[3][1].x-parameterSize[3].x/2, parameterPos[3][1].y-parameterSize[3].y/2)   
      .setSize((int)parameterSize[3].x, (int)parameterSize[3].y)
        .setValue(false)
          .setWindow(controlWindow);

  cp5.addToggle("preset7")
    .setPosition(parameterPos[3][2].x-parameterSize[3].x/2, parameterPos[3][2].y-parameterSize[3].y/2)   
      .setSize((int)parameterSize[3].x, (int)parameterSize[3].y)
        .setValue(false)
          .setWindow(controlWindow);

  cp5.addToggle("preset8")
    .setPosition(parameterPos[3][3].x-parameterSize[3].x/2, parameterPos[3][3].y-parameterSize[3].y/2)   
      .setSize((int)parameterSize[3].x, (int)parameterSize[3].y)
        .setValue(false)
          .setWindow(controlWindow);          

  cp5.addToggle("savePreset")
    .setPosition(parameterPos[0][1].x-parameterSize[0].x/2, parameterPos[0][1].y-parameterSize[0].y/2)   
      .setSize((int)parameterSize[0].x, (int)parameterSize[0].y)
        .setValue(false)
          .setWindow(controlWindow);

  cp5.addToggle("automatic")
    .setPosition(parameterPos[0][0].x-parameterSize[0].x/2, parameterPos[0][0].y-parameterSize[0].y/2)   
      .setSize((int)parameterSize[0].x, (int)parameterSize[0].y)
        .setValue(false)
          .setWindow(controlWindow);

  cp5.addSlider("transitionTime")
    .setPosition(parameterPos[1][0].x-parameterSize[1].x/2, parameterPos[1][0].y-parameterSize[1].y/2)   
      .setSize((int)parameterSize[1].x, (int)parameterSize[1].y)
        .setRange(0.1, cubeCircleRad*6/10)
          .setWindow(controlWindow);

  cp5.getController("transitionTime").captionLabel().getStyle().marginLeft = -(int)parameterSize[1].x-4;
  cp5.getController("transitionTime").captionLabel().getStyle().marginTop = 22;

  for (int i = 0; i < parameterNames.length; i++) {
    cp5.getController(parameterNames[i])
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    cwControllers.add(cp5.getController(parameterNames[i]));
  }
}


void foregroundGUI(ControlP5 cp5, ControlWindow controlWindow) {

  String[] parameterNames = {
    "blackAlpha", "logoAlpha", "midiEnable"
  };
  //    theApplet.line(320+76, 28+8, 320+76, 300-14);

  float parametersBoxX = 220;
  float parametersBoxY = 25;
  float parametersBoxWidth = 150;
  float parametersBoxHeight = 250;  

  int GUISep = 50;
  int rowIndex;
  int columnIndex;
  int[] parameterMatrix = {
    2
  };    //x = 1; y = 3

  PVector[][] parameterPos = new PVector[parameterMatrix.length][max(parameterMatrix)]; 
  PVector[] parameterSize = new PVector[parameterMatrix.length]; 

  for (int i = 0; i < parameterMatrix.length; i++) {
    for (int j = 0; j < parameterMatrix[i]; j++) {
      parameterPos[i][j] = new PVector(parametersBoxX + (parametersBoxWidth/(parameterMatrix[i]*2)*(j*2+1)), parametersBoxY +(parametersBoxHeight/(parameterMatrix.length*2)*(i*2+1)));
      parameterSize[i] = new PVector((parametersBoxWidth/parameterMatrix[i])-GUISep, (parametersBoxHeight/parameterMatrix.length)-GUISep);
      noStroke();
      fill(127);
      rectMode(CORNER);
    }
  }

  rowIndex = 0; 
  columnIndex = 0; 

  cp5.addSlider("blackAlpha")
    .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
      .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
        .setRange(0., 255.)
          .setWindow(controlWindow);

  columnIndex = 1; 

  cp5.addSlider("logoAlpha")
    .setPosition(parameterPos[rowIndex][columnIndex].x-parameterSize[rowIndex].x/2, parameterPos[rowIndex][columnIndex].y-parameterSize[rowIndex].y/2)   
      .setSize((int)parameterSize[rowIndex].x, (int)parameterSize[rowIndex].y)
        .setRange(0., 255.)
          .setWindow(controlWindow);

  cp5.addToggle("midiEnable")
    .setPosition(visualSpecificParametersBoxX+sRectWidth/2+6, visualSpecificParametersBoxY+sRectWidth)   
      .setSize(sRectWidth, sRectHeight)
        .setValue(false)
          .setWindow(controlWindow);

  //  cp5.getController("SR").captionLabel().getStyle().marginLeft = 0;
  //  cp5.getController("SR").captionLabel().getStyle().marginTop = 0;

  for (int i = 0; i < parameterNames.length; i++) {
    cp5.getController(parameterNames[i])
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
    cwControllers.add(cp5.getController(parameterNames[i]));
  }
}


int[] sRectPosX = {
  25, 83, 25, 141, 199, 257
};
int[] sRectPosY = {
  134, 134, 203, 203, 203, 203
};

int[] mRectPosX = {
  355, 355, 355, 506, 506, 506, 657, 657, 657, 808, 808, 808, 959, 959, 959, 1110, 1110, 1110, 1261, 1261, 1261, 1412, 1412, 1412
};
int[] mRectPosY = {
  130, 199, 268, 130, 199, 268, 130, 199, 268, 130, 199, 268, 130, 199, 268, 130, 199, 268, 130, 199, 268, 130, 199, 268
};

int[] lRectPosX = {
  25, 83, 141, 199, 257
};
int[] lRectPosY = {
  254, 254, 254, 254, 254
};

int[] sliderPosX = {
  412, 563, 714, 865, 1016, 1167, 1318, 1469
};
int[] sliderPosY = {
  130, 130, 130, 130, 130, 130, 130, 130
};

int[] knobPosX = {
  395, 546, 697, 848, 999, 1150, 1301, 1452
};
int[] knobPosY = {
  40, 40, 40, 40, 40, 40, 40, 40
};

int sRectWidth = 38;
int sRectHeight = 20;

int mRectWidth = 24;
int mRectHeight = 24;

int lRectWidth = 38;
int lRectHeight = 38;

int sliderWidth = 24;
int sliderHeight = 162;

int knobWidth = 25;
int knobHeight = 25;

