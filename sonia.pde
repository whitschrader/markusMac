
import pitaru.sonia_v2_9.*; // automcatically added when importing the library from the processing menu.
float soundVal = 0;
void initializeSonia() {
  Sonia.start(this); // Start Sonia engine.
  LiveInput.start(256); // Start LiveInput and return 256 FFT frequency bands.
}

void drawSonia() {
  getMeterLevel(); // Show meter-level reading for Left/Right channels.
  getSpectrum(); // Show FFT reading
}

void getSpectrum() {

  LiveInput.getSpectrum(true, 1.5);
}

void getMeterLevel() {
  // get Peak level for each channel (0 -> Left , 1 -> Right)
  // Value Range: float from 0.0 to 1.0
  // Note: use inputMeter.getLevel() to combine both channels (L+R) into one value.
  float meterDataLeft = LiveInput.getLevel();
  float meterDataRight = LiveInput.getLevel();

  // draw a volume-meter for each channel.
  fill(0, 100, 0);
  float lefta = meterDataLeft*height;
  float righta = meterDataRight*height;
}

float getSoundLevel(float decay)
{
  float soundValPre = 0;
  // get Peak level for each channel (0 -> Left , 1 -> Right)
  // Value Range: float from 0.0 to 1.0
  // Note: use inputMeter.getLevel() to combine both channels (L+R) into one value.

  soundValPre += (LiveInput.getLevel()*(1.-decay));

  if (soundVal < soundValPre) {
    soundVal = soundValPre;
  } 
  else {
    soundVal *= decay;
  }

  return soundVal;
}



// Safely close the sound engine upon Browser shutdown.
public void stop() {
  Sonia.stop();
  super.stop();
}

