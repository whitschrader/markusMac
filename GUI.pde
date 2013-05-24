import controlP5.*;

ControlP5 cp5;
ControlWindow controlWindow;
ControlWindowCanvas cc;
ControlFont fontLight, fontBold, fontRegular;

//Slider particleAmount;
Range colorRange;

PImage thumb1, thumb2, logo;
PFont pfontLight, pfontBold, pfontRegular;
int colorMin = 100;
int colorMax = 100;

final int soundReactionGUIOffset = 320;
final int visualSpecificGUIOffset = 450;

final float scaleGUI = 1280./1900.;
final int widthGUI = int(1900*scaleGUI);
final int heightGUI = int(1125*scaleGUI);
float borderMargin = (51.5+9)*scaleGUI;

color mainYellow;
color mainBlue;
color mainBackground;
color panelBackground;
color label;
color dimYellow;
color thinLines;


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
  controlWindow = cp5.addControlWindow("GUI", 0, 0, widthGUI, heightGUI, 60)
    .hideCoordinates()
      .setBackground(mainBackground);
  println(widthGUI + " - " + heightGUI);

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
  for (int i=0; i<engines.length; ++i) {
    engines[i].initGUI(cp5, controlWindow);
  }


  logo = loadImage("logo.png");
}




void controlEvent(ControlEvent theControlEvent) {
  engines[currentEngineIndex].controlEvent(theControlEvent);
}

class MyCanvas extends ControlWindowCanvas {

//  float widthScale = (widthGUI/LiveInput.spectrum.length)*4;
  float widthScale = (widthGUI/256)*4;
  float fftDrawLeft = 2*borderMargin+(706*scaleGUI);
  float fftDrawTop = (9+441+72+307+54)*scaleGUI;
  float fftDrawHeight =  (256-76)*scaleGUI;
  float fftDrawWidth = (1025-12)*scaleGUI;

  public boolean mouseDragged() {
    return true;
  }

  public void drawThumbnails(PApplet theApplet) {
    for (int i = 0; i < engines.length; i++) {
      float thumbX = borderMargin+(663*scaleGUI) + (i * (15+213)*scaleGUI);
      theApplet.image(engines[i].thumbnail, thumbX, 90*scaleGUI, 213*scaleGUI, 120*scaleGUI);
      theApplet.textFont(pfontLight, 20);
      theApplet.text(engines[i].name, thumbX, 240*scaleGUI);
    }
    theApplet.pushStyle();
    theApplet.noFill();
    theApplet.stroke(mainYellow);
    theApplet.strokeWeight(5);
    theApplet.rectMode(CORNER);
    theApplet.rect(borderMargin+(663*scaleGUI) + (currentEngineIndex * (15+213)*scaleGUI), 90*scaleGUI, 213*scaleGUI, 120*scaleGUI);
    theApplet.popStyle();
  }

  public void drawFFT(PApplet theApplet) {

//   for (int i = 0; i < LiveInput.spectrum.length; i++) {
          for (int i = 0; i < LiveInput.spectrum.length; i++) {
      theApplet.pushStyle();
      theApplet.stroke(thinLines);
      theApplet.strokeCap(RECT);
      theApplet.strokeWeight(fftDrawWidth/LiveInput.spectrum.length);
      theApplet.fill(255);
      theApplet.line(
      (fftDrawWidth/LiveInput.spectrum.length)*(i+1)+fftDrawLeft, 
      fftDrawTop+(fftDrawHeight/2), 
      (fftDrawWidth/LiveInput.spectrum.length)*(i+1)+fftDrawLeft, 
      (fftDrawTop+(fftDrawHeight/2))-constrain(LiveInput.spectrum[i], 0, fftDrawHeight/2)
        );
      theApplet.line(
      (fftDrawWidth/LiveInput.spectrum.length)*(i+1)+fftDrawLeft, 
      fftDrawTop+(fftDrawHeight/2), 
      (fftDrawWidth/LiveInput.spectrum.length)*(i+1)+fftDrawLeft, 
      (fftDrawTop+(fftDrawHeight/2))+constrain(LiveInput.spectrum[i], 0, fftDrawHeight/2)
        );
      theApplet.popStyle();
    }
  }

  public void drawFFTFilters(PApplet theApplet) {

    for (int i = 0; i < fftVar.length; i++) {

      float filterVisualRange = (fftDrawWidth/LiveInput.spectrum.length)*fftVar[i].fftRange*2;
      float filterVisualWmin = ((fftDrawWidth/LiveInput.spectrum.length)*(fftVar[i].baseFreq-fftVar[i].fftRange));
      float filterVisualWmax =  ((fftDrawWidth/LiveInput.spectrum.length)*(fftVar[i].baseFreq+fftVar[i].fftRange));

      theApplet.pushStyle();
      theApplet.strokeCap(RECT);
      theApplet.strokeWeight(filterVisualRange);
      theApplet.stroke(mainBlue, 150);

      theApplet.line(
      ((fftDrawWidth/LiveInput.spectrum.length))*(fftVar[i].baseFreq)+fftDrawLeft, 
      (fftDrawHeight*(i+1)/(fftVar.length+1))+fftDrawTop, 
      ((fftDrawWidth/LiveInput.spectrum.length))*(fftVar[i].baseFreq)+fftDrawLeft, 
      (fftDrawHeight*(i+1)/(fftVar.length+1))+fftDrawTop-constrain(fftVar[i].getValue(), 0, fftDrawHeight/2)
        );

      theApplet.line(
      ((fftDrawWidth/LiveInput.spectrum.length))*(fftVar[i].baseFreq)+fftDrawLeft, 
      (fftDrawHeight*(i+1)/(fftVar.length+1))+fftDrawTop, 
      ((fftDrawWidth/LiveInput.spectrum.length))*(fftVar[i].baseFreq)+fftDrawLeft, 
      (fftDrawHeight*(i+1)/(fftVar.length+1))+fftDrawTop+constrain(fftVar[i].getValue(), 0, fftDrawHeight/2)
        );      

      if ((theApplet.mouseX < filterVisualWmax+fftDrawLeft)&&(theApplet.mouseX > filterVisualWmin+fftDrawLeft)) {
        if ((theApplet.mouseY < (fftDrawHeight*(i+1)/(fftVar.length+1))+5+fftDrawTop)&&(theApplet.mouseY > (fftDrawHeight*(i+1)/(fftVar.length+1))-5+fftDrawTop)) {
          theApplet.stroke(mainYellow, 150);
          if (theApplet.mousePressed) {
            if ((theApplet.mouseX-(fftDrawWidth/LiveInput.spectrum.length)*fftVar[i].fftRange > fftDrawLeft)&&(theApplet.mouseX+(fftDrawWidth/LiveInput.spectrum.length)*fftVar[i].fftRange < fftDrawLeft+fftDrawWidth)) {
              fftVar[i].setBase(int((theApplet.mouseX-fftDrawLeft)/(fftDrawWidth/LiveInput.spectrum.length)));
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
      ((fftDrawWidth/LiveInput.spectrum.length))*(fftVar[i].baseFreq)+fftDrawLeft, 
      (fftDrawHeight*(i+1)/(fftVar.length+1))-5+fftDrawTop, 
      ((fftDrawWidth/LiveInput.spectrum.length))*(fftVar[i].baseFreq)+fftDrawLeft, 
      (fftDrawHeight*(i+1)/(fftVar.length+1))+5+fftDrawTop
        );



      theApplet.popStyle();
    }
  }


  public void draw(PApplet theApplet) {
    theApplet.frame.setTitle(int(frameRate)+"fps");
    theApplet.colorMode(HSB);
    theApplet.background(mainBackground);

    theApplet.pushStyle();
    theApplet.stroke(mainYellow);
    theApplet.strokeWeight(9);
    theApplet.strokeCap(RECT);
    theApplet.line(borderMargin, 0, widthGUI-borderMargin, 0);
    theApplet.line(borderMargin, heightGUI, widthGUI-borderMargin, heightGUI);
    theApplet.stroke(mainBlue);
    theApplet.line(0, 0, 0, heightGUI-borderMargin);
    theApplet.line(widthGUI, 0, widthGUI, heightGUI-borderMargin);

    theApplet.noStroke();
    theApplet.fill(panelBackground);
    theApplet.rect(borderMargin, 9, widthGUI-borderMargin*2, 450*scaleGUI);
    theApplet.rect(borderMargin, (9+441+72)*scaleGUI, 706*scaleGUI, heightGUI-borderMargin-(9+441+72)*scaleGUI);
    theApplet.rect(2*borderMargin+(706*scaleGUI), (9+441+72)*scaleGUI, 428*scaleGUI, 307*scaleGUI);
    theApplet.rect(3*borderMargin+((706+428)*scaleGUI), (9+441+72)*scaleGUI, (541-16)*scaleGUI, 307*scaleGUI);
    theApplet.rect(2*borderMargin+(706*scaleGUI), (9+441+72+307+54)*scaleGUI, (1025-12)*scaleGUI, (256-76)*scaleGUI);

    theApplet.stroke(mainYellow);
    theApplet.strokeWeight(1);
    theApplet.strokeCap(RECT);

    theApplet.line(borderMargin, (9+441+72)*scaleGUI, borderMargin+706*scaleGUI, (9+441+72)*scaleGUI);
    theApplet.line(2*borderMargin+(706*scaleGUI), (9+441+72)*scaleGUI, 2*borderMargin+(706*scaleGUI)+428*scaleGUI, (9+441+72)*scaleGUI);
    theApplet.line(3*borderMargin+((706+428)*scaleGUI), (9+441+72)*scaleGUI, 3*borderMargin+((706+428)*scaleGUI)+(541-16)*scaleGUI, (9+441+72)*scaleGUI);
    theApplet.line(2*borderMargin+(706*scaleGUI), (9+441+72+307+54)*scaleGUI, 2*borderMargin+(706*scaleGUI)+(1025-12)*scaleGUI, (9+441+72+307+54)*scaleGUI);

    theApplet.stroke(thinLines);
    theApplet.line(borderMargin, 9+450*scaleGUI, widthGUI-borderMargin, 9+450*scaleGUI);
    theApplet.line(borderMargin, (9+441+72)*scaleGUI+ heightGUI-borderMargin-(9+441+72)*scaleGUI, 706*scaleGUI+borderMargin, (9+441+72)*scaleGUI+ heightGUI-borderMargin-(9+441+72)*scaleGUI);
    theApplet.line(2*borderMargin+(706*scaleGUI), (9+441+72)*scaleGUI+ 307*scaleGUI, 428*scaleGUI+2*borderMargin+(706*scaleGUI), (9+441+72)*scaleGUI+ 307*scaleGUI);
    theApplet.line(3*borderMargin+((706+428)*scaleGUI), (9+441+72)*scaleGUI+307*scaleGUI, (541-16)*scaleGUI+3*borderMargin+((706+428)*scaleGUI), (9+441+72)*scaleGUI+307*scaleGUI);
    theApplet.line(2*borderMargin+(706*scaleGUI), (9+441+72+307+54)*scaleGUI+(256-76)*scaleGUI, (1025-12)*scaleGUI+2*borderMargin+(706*scaleGUI), (9+441+72+307+54)*scaleGUI+(256-76)*scaleGUI);
    theApplet.line(borderMargin+(621*scaleGUI), (9+79)*scaleGUI, borderMargin+(621*scaleGUI), 420*scaleGUI);
    theApplet.popStyle();

    theApplet.image(logo, borderMargin+1, 10, 131*scaleGUI, 72*scaleGUI);

    drawThumbnails(theApplet);
    drawFFT(theApplet);
    drawFFTFilters(theApplet);

    theApplet.pushStyle();
    theApplet.stroke(255);
    theApplet.fill(255);
    theApplet.textFont(pfontLight, 24);
    theApplet.text("SOUND REACTION", 3*borderMargin+((706+428)*scaleGUI), (9+441+72)*scaleGUI-5);
    theApplet.text("VISUAL SPECIFIC PARAMETERS", borderMargin, (9+441+72)*scaleGUI-5);
    theApplet.text("PRESETS", 2*borderMargin+(706*scaleGUI), (9+441+72)*scaleGUI-5);
    theApplet.text("SOUND REACTION ADJUSTMENT", 2*borderMargin+(706*scaleGUI), (9+441+72+307+54)*scaleGUI-5);
    theApplet.text("No Preview Available.", 170, 170);
    theApplet.popStyle();
  }
}


void soundReactionGUI() {

  //      theApplet.rect(3*borderMargin+((706+428)*scaleGUI), (9+441+72)*scaleGUI, (541-16)*scaleGUI, 307*scaleGUI);


  cp5.addSlider("gain")
    .setPosition(3*borderMargin+((706+428)*scaleGUI)+30, (9+441+72)*scaleGUI+(307*scaleGUI*3/4)-20)
      .setRange(0., 1.)
        .setSize(200, 20)
          .setWindow(controlWindow);  

  cp5.getController("gain")
    .getCaptionLabel()
      .setFont(fontLight)
        .toUpperCase(false)
          .setSize(18)
            ;

  cp5.addSlider("decay")
    .setPosition(3*borderMargin+((706+428)*scaleGUI)+30, (9+441+72)*scaleGUI+(307*scaleGUI*2/4)-20)
      .setRange(0.5, 1.)
        .setSize(200, 20)
          .setWindow(controlWindow);  

  cp5.getController("decay")
    .getCaptionLabel()
      .setFont(fontLight)
        .toUpperCase(false)
          .setSize(18)
            ;

  cp5.addToggle("SR")
    .setPosition(3*borderMargin+((706+428)*scaleGUI)+30, (9+441+72)*scaleGUI+(307*scaleGUI*1/4)-20)
      .setSize(20, 20)
        .setValue(true)
          .setWindow(controlWindow);

  cp5.getController("SR")
    .getCaptionLabel()
      .setFont(fontLight)
        .toUpperCase(false)
          .setSize(18)
            ;
  cp5.getController("SR").captionLabel().getStyle().marginLeft = 25;
  cp5.getController("SR").captionLabel().getStyle().marginTop = -25;
}

