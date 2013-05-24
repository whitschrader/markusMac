import promidi.*;

MidiIO midiIO;

int faderStartAddress = 0;
int faderStopAddress = 7;
int[] faderVal = new int[8];

int knobStartAddress = 16;
int knobStopAddress = 23;
int[] knobVal = new int[8];

void initializeMidi() {
  midiIO = MidiIO.getInstance(this);
  midiIO.printDevices();
  midiIO.openInput(0, 0);

  midiIO.plug(this, "noteOff", 0, 0);
  midiIO.plug(this, "controllerIn", 0, 0);
}

void controllerIn(
promidi.Controller midiController 
) {
  int num = midiController.getNumber();
  int val = midiController.getValue();

  if ((num <= faderStopAddress)&&(num >= faderStartAddress)) {
    faderVal[num-faderStartAddress] = val;
  }  
  else if ((num <= knobStopAddress)&&(num >= knobStartAddress)) {
    knobVal[num-knobStartAddress] = val;
  }
  //midiMapDustParticles();
}

void noteOff(
Note note
) {
  int pit = note.getPitch();

  if ((pit <= faderStopAddress)&&(pit >= faderStartAddress)) {
    faderVal[pit-faderStartAddress] = 0;
  }  
  else if ((pit <= knobStopAddress)&&(pit >= knobStartAddress)) {
    knobVal[pit-knobStartAddress] = 0;
  }
  midiMapDustParticles();
}

void midiMapDustParticles() {
  cp5.getController("particleAmount").setValue((int(map(faderVal[0], 0, 127, 0, 500))));
  cp5.getController("fadeAmount").setValue((map(faderVal[1], 0, 127, 0., 1.)));
  cp5.getController("sw").setValue((map(faderVal[2], 0, 127, 0., 10.)));
  cp5.getController("lineLength").setValue((map(faderVal[3], 0, 127, 1., 20.)));
  cp5.getController("randomness").setValue((map(faderVal[4], 0, 127, 0., 0.1)));
}

void midiMapCubes() {
  cp5.getController("cubeAmount").setValue((map(knobVal[0], 0, 127, 0, 250)));
  cp5.getController("cubeSizeOffsetX").setValue((map(faderVal[0], 0, 127, 1., 60.)));
  cp5.getController("cubeSizeOffsetY").setValue((map(faderVal[1], 0, 127, 1., 60.)));
  cp5.getController("cubeSizeOffsetZ").setValue((map(faderVal[2], 0, 127, 1., 60.)));
  cp5.getController("cubeSizeVarianceX").setValue((map(faderVal[3], 0, 127, 0., 60.)));
  cp5.getController("cubeSizeVarianceY").setValue((map(faderVal[4], 0, 127, 0., 60.)));
  cp5.getController("cubeSizeVarianceZ").setValue((map(faderVal[5], 0, 127, 0., 60.)));
  cp5.getController("outlineStroke").setValue((map(knobVal[5], 0, 127, 0., 255.)));
  cp5.getController("outlineLength").setValue((map(knobVal[6], 0, 127, 0., 1.)));
  cp5.getController("rotVariance").setValue((map(knobVal[3], 0, 127, 0., 40.)));
  cp5.getController("rotSpeed").setValue((map(knobVal[4], 0, 127, -1., 1.)));
  cp5.getController("rotLimit").setValue((map(knobVal[1], 0, 127, 0., 4.)));
  cp5.getController("rotSelf").setValue((map(knobVal[2], 0, 127, -2., 2.)));
}

void midiMapSound() {
  cp5.getController("gain").setValue((map(faderVal[6], 0, 127, 0., 1.)));
  cp5.getController("decay").setValue((map(faderVal[7], 0, 127, 0.5, 1.)));
}

