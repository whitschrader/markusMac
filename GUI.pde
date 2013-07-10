import controlP5.*;

ControlP5 cp5;
ControlWindow controlWindow;
ControlWindowCanvas cc;
ControlFont fontLight, fontBold, fontRegular;

Range colorRange;

PImage thumb1, thumb2, logo;
PFont pfontLight, pfontBold, pfontRegular;
int colorMin = 100;
int colorMax = 100;

final int soundReactionGUIOffset = 320;
final int visualSpecificGUIOffset = 450;

final float scaleGUI = 1280./1900.;
final int widthGUI = 1280;
final int heightGUI = 757;

float borderMarginBig = 51;
float borderMarginSmall = 34;

float borderLinesThickness = 6;

float thumbnailBoxWidth = 1166;
float thumbnailBoxHeight = 275;

float visualSpecificParametersBoxWidth = 443;
float visualSpecificParametersBoxHeight = 378;

float presetsBoxWidth = 313;
float presetsBoxHeight = 187;

float soundParametersBoxWidth = 342;
float soundParametersBoxHeight = 187;

float soundWaveBoxWidth = 689;
float soundWaveBoxHeight = 157;

color mainYellow;
color mainBlue;
color mainBackground;
color panelBackground;
color label;
color dimYellow;
color thinLines;

float thumbnailBoxX = borderLinesThickness+borderMarginBig;
float thumbnailBoxY = borderLinesThickness;
float visualSpecificParametersBoxX = borderLinesThickness+borderMarginBig;
float visualSpecificParametersBoxY = borderLinesThickness+thumbnailBoxHeight+borderMarginBig;
float presetsBoxX = borderLinesThickness+borderMarginBig+visualSpecificParametersBoxWidth+borderMarginSmall;
float presetsBoxY = borderLinesThickness+thumbnailBoxHeight+borderMarginBig;
float soundParametersBoxX = borderLinesThickness+borderMarginBig+visualSpecificParametersBoxWidth+borderMarginSmall*2+presetsBoxWidth;
float soundParametersBoxY = borderLinesThickness+thumbnailBoxHeight+borderMarginBig;
float soundWaveBoxX = borderLinesThickness+borderMarginBig+visualSpecificParametersBoxWidth+borderMarginSmall;
float soundWaveBoxY = borderLinesThickness+thumbnailBoxHeight+borderMarginBig+borderMarginSmall+presetsBoxHeight;

float thumbnailImageWidth = 143;
float thumbnailImageHeight = 79;
float thumbnailImageSpacing = 10;
void initializeGUI() {

  colorMode(HSB);
  mainYellow       = color(27, 228, 251);
  mainBlue         = color(137, 252, 100);
  mainBackground   = color(0, 0, 52);
  panelBackground  = color(156, 16, 48);
  label            = color(0, 0, 202);
  dimYellow        = color(27, 255, 148);
  thinLines        = color(0, 0, 102);

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

  soundReactionGUI();
  presetsGUI(cp5, controlWindow);
  for (int i=0; i<engines.length; ++i) {
    engines[i].initGUI(cp5, controlWindow);
  }


  logo = loadImage("logo.png");
}




void controlEvent(ControlEvent theControlEvent) {
  engines[currentEngineIndex].controlEvent(theControlEvent);
}

class MyCanvas extends ControlWindowCanvas {

  public boolean mouseDragged() {
    return true;
  }

  public void drawThumbnails(PApplet theApplet) {
    theApplet.pushStyle();
    for (int i = 0; i < engines.length; i++) {
      float thumbX = thumbnailBoxX + (thumbnailBoxWidth/3) + thumbnailImageSpacing*2 + (thumbnailImageWidth + thumbnailImageSpacing)*(i%5);
      theApplet.image(engines[i].thumbnail, thumbX, (thumbnailBoxY+borderMarginBig)+(((int)i/5)*(thumbnailImageHeight+borderMarginSmall)), thumbnailImageWidth, thumbnailImageHeight);
      theApplet.textFont(pfontLight, 18);
      if (i == currentEngineIndex) {
        theApplet.fill(255);
      } 
      else {
        theApplet.fill(mainYellow);
      }
      theApplet.text(engines[i].name, thumbX, (thumbnailBoxY+borderMarginBig)+(((int)i/5)*(thumbnailImageHeight+borderMarginSmall))+thumbnailImageHeight+thumbnailImageSpacing*2);
    }

    theApplet.noFill();
    theApplet.stroke(mainYellow);
    theApplet.strokeWeight(5);
    theApplet.rectMode(CORNER);
    theApplet.rect(thumbnailBoxX + (thumbnailBoxWidth/3) + thumbnailImageSpacing*2 + (thumbnailImageWidth + thumbnailImageSpacing)*(currentEngineIndex%5), thumbnailBoxY+borderMarginBig+((int)currentEngineIndex/5)*(thumbnailImageHeight+borderMarginSmall), thumbnailImageWidth, thumbnailImageHeight);
    theApplet.popStyle();
  }

  public void drawFFT(PApplet theApplet) {

    for (int i = 0; i < LiveInput.spectrum.length; i++) {
      theApplet.pushStyle();
      theApplet.stroke(thinLines);
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
  }

  public void drawFFTFilters(PApplet theApplet) {

    for (int i = 0; i < fftVar.length; i++) {

      float filterVisualRange = (soundWaveBoxWidth/LiveInput.spectrum.length)*fftVar[i].fftRange*2;
      float filterVisualWmin = ((soundWaveBoxWidth/LiveInput.spectrum.length)*(fftVar[i].baseFreq-fftVar[i].fftRange));
      float filterVisualWmax =  ((soundWaveBoxWidth/LiveInput.spectrum.length)*(fftVar[i].baseFreq+fftVar[i].fftRange));

      theApplet.pushStyle();
      theApplet.strokeCap(RECT);
      theApplet.strokeWeight(filterVisualRange);
      theApplet.stroke(mainBlue, 150);

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
    theApplet.frame.setTitle(int(frameRate)+"fps");
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
    theApplet.rect(visualSpecificParametersBoxX, visualSpecificParametersBoxY, visualSpecificParametersBoxWidth, visualSpecificParametersBoxHeight);
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
    theApplet.line(thumbnailBoxX+thumbnailBoxWidth/3, thumbnailBoxY+borderMarginBig, thumbnailBoxX+thumbnailBoxWidth/3, thumbnailBoxY+thumbnailBoxHeight-borderMarginSmall);

    theApplet.popStyle();

    theApplet.image(logo, thumbnailBoxX, thumbnailBoxY*2, 60, 33);

    drawThumbnails(theApplet);
    drawFFT(theApplet);
    drawFFTFilters(theApplet);

    theApplet.pushStyle();
    theApplet.stroke(255);
    theApplet.fill(255);
    theApplet.textFont(pfontLight, 24);
    theApplet.text("VISUAL SPECIFIC PARAMETERS", visualSpecificParametersBoxX, visualSpecificParametersBoxY-2);
    theApplet.text("SOUND REACTION", soundParametersBoxX, soundParametersBoxY-2);
    theApplet.text("PRESETS", presetsBoxX, presetsBoxY-2);
    theApplet.text("SOUND REACTION ADJUSTMENT", soundWaveBoxX, soundWaveBoxY-2);
    theApplet.text("No Preview Available.", 170, 170);
//    theApplet.image(preview,thumbnailBoxX, (thumbnailBoxY+borderMarginBig),373,207);
    theApplet.popStyle();
  }
}


void soundReactionGUI() {

  String[] parameterNames = {
    "SR", "gain", "decay"
  };
  int soundReactionGUISep = 40;

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
      .setSize((int)parameterSize[0].x, (int)parameterSize[0].y)
        .setValue(true)
          .setWindow(controlWindow);

  cp5.addSlider("gain")
    .setPosition(parameterPos[1][0].x-parameterSize[1].x/2, parameterPos[1][0].y-parameterSize[1].y/2)   
      .setRange(0., 1.)
        .setSize((int)parameterSize[1].x, (int)parameterSize[1].y)
          .setWindow(controlWindow);  

  cp5.addSlider("decay")
    .setPosition(parameterPos[2][0].x-parameterSize[2].x/2, parameterPos[2][0].y-parameterSize[2].y/2)   
      .setRange(0.5, 1.)
        .setSize((int)parameterSize[2].x, (int)parameterSize[2].y)
          .setWindow(controlWindow);  

  cp5.getController("SR").captionLabel().getStyle().marginLeft = 0;
  cp5.getController("SR").captionLabel().getStyle().marginTop = 0;

  cp5.getController("gain").captionLabel().getStyle().marginLeft = -(int)parameterSize[1].x-4;
  cp5.getController("gain").captionLabel().getStyle().marginTop = 22;

  cp5.getController("decay").captionLabel().getStyle().marginLeft = -(int)parameterSize[2].x-4;
  cp5.getController("decay").captionLabel().getStyle().marginTop = 22;


  for (int i = 0; i < parameterNames.length; i++) {
    cp5.getController(parameterNames[i])
      .getCaptionLabel()
        .setFont(fontLight)
          .toUpperCase(false)
            .setSize(18)
              ;
  }
}

public void presetsGUI(ControlP5 cp5, ControlWindow controlWindow) {
  String[] parameterNames = {
    "preset1", "preset2", "preset3", "preset4", "savePreset", "automatic", "transitionTime"
  };
  int presetGUISep = 40;

  int[] parameterMatrix = {
    2, 1, 4
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
  }
}



