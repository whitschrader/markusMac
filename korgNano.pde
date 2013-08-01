import promidi.*;

MidiIO midiIO;

int faderStartAddress = 0;
int faderStopAddress = 7;
int[] faderVal = new int[8];
int[] faderValPre = new int[8];
int[] faderValDiff = new int[8];

int knobStartAddress = 16;
int knobStopAddress = 23;
int[] knobVal = new int[8];
int[] knobValPre = new int[8];
int[] knobValDiff = new int[8];

int[] buttonsMAdd = {
  32, 33, 34, 35, 36, 37, 38, 39, 48, 49, 50, 51, 52, 53, 54, 55, 64, 65, 66, 67, 68, 69, 70, 71
};
int[] buttonsMVal = new int[24];
int[] buttonsMValPre = new int[24];
int[] buttonsMValDiff = new int[24];

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

  for (int i = 0; i < buttonsMAdd.length; i++) {
    if (num == buttonsMAdd[i]) {
      if (buttonsMVal[i]==0) {
        buttonsMVal[i] = 1;
      } 
      else if (buttonsMVal[i]==1) {
        buttonsMVal[i] = 0;
      }
    }
  }
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
  for (int i = 0; i < buttonsMAdd.length; i++) {
    if (pit == buttonsMAdd[i]) {
      buttonsMVal[i] = 0;
    }
  }
}

void midiCalculator() {
  for (int i = 0; i<faderVal.length; i++) {
    faderValDiff[i] = faderVal[i] - faderValPre[i];
    faderValPre[i] = faderVal[i];
  }

  for (int i = 0; i<knobVal.length; i++) {
    knobValDiff[i] = knobVal[i] - knobValPre[i];
    knobValPre[i] = knobVal[i];
  }
  
    for (int i = 0; i<buttonsMVal.length; i++) {
      if(buttonsMVal[i] - buttonsMValPre[i] != -1){
          buttonsMValDiff[i] = buttonsMVal[i] - buttonsMValPre[i];

      }
    buttonsMValPre[i] = buttonsMVal[i];
  }
  
}

void midiMapSound() {
  cp5.getController("gain").setValue((map(faderVal[6], 0, 127, 0., 1.)));
  cp5.getController("decay").setValue((map(faderVal[7], 0, 127, 0.5, 1.)));
}

