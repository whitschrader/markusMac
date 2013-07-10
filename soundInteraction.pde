//base, harmonic 

FftVar[] fftVar;
float fftVarAvg;

float gain = 1.;
float decay = 0.7;

float base = 1.;
float baseTemp = 0.;


float[] fftComp;
float[] fftCompTemp;

int avgAmount = 256;
boolean drawFFT = true;
boolean SR = false;

void initializeSoundAnalysis() {
  initializeSonia();

  fftVar = new FftVar[2];
  fftVar[0] = new FftVar(10, 5);
  fftVar[1] = new FftVar(50, 15);

  getSpectrum();
}
float[] features;
void soundAnalysis() {
  if (midiEnable) {
    midiMapSound();
  }
  baseTemp = 0.;
  getSpectrum();
  //  features = ps.getFeatures(); // get the data from the PowerSpectrum object


  fftVarAvg = 0;
  fftVarAvg = fftVar[0].getValue();
}

public class FftVar
{
  public int baseFreq;
  public float value;
  public float valuePre;
  public int fftRange;

  FftVar(int freq, int range)
  {
    baseFreq = freq;
    value = 0;
    fftRange = range;
  }

  float getValue()
  { 
    valuePre = 0;
    for (int i = -fftRange; i < fftRange; i++) {
      valuePre += (LiveInput.spectrum[i+baseFreq]*(1.-decay))*gain/(2*fftRange);
    }

    if (value < valuePre) {
      value = valuePre;
    } 
    else {
      value *= decay;
    }

    return value;
  }

  void setBase(int freq) {
    baseFreq = freq;
  }
}

public class SoundWaveInput {
  int bufSize;
  float[] soundBuf;
  int bufSpeed;

  SoundWaveInput(int bSize, int bSpeed) {
    bufSize = bSize;
    bufSpeed = bSpeed;
    soundBuf = new float[bufSize];
    for (int i = 0; i < bufSize; i++) {
      soundBuf[i] = 0.;
    }
  }

  float[] getSoundWave() {
    for (int i = 0; i < bufSize-bufSpeed; i++) {
      soundBuf[i] = soundBuf[i+bufSpeed];
    }
    soundBuf[bufSize-1] = getSoundLevel(0.9);
    return soundBuf;
  }
}

