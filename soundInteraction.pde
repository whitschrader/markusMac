//base, harmonic 

//import ddf.minim.analysis.*;
//import ddf.minim.*;
//
//Minim minim;
//AudioInput in;
//FFT fft;
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
//  minim = new Minim(this);
//  in = minim.getLineIn(Minim.STEREO, 2048);
//  fft = new FFT(in.bufferSize(), in.sampleRate()); //2048 - 22050
//  fft.linAverages(avgAmount);

initializeSonia();

  //  fftComp = new float[fft.avgSize()];
  fftVar = new FftVar[2];
  fftVar[0] = new FftVar(10, 5);
  fftVar[1] = new FftVar(50, 15);

  //  for (int i = 0; i < fft.avgSize(); i++) {
  //    fftVar[i] = new FftVar(i);
  //    //fftVar[i].Update();
  //    fftComp[i] = 0.1;
  //  }
  getSpectrum();

}
float[] features;
void soundAnalysis() {
  if (midiEnable) {
    midiMapSound();
  }
  baseTemp = 0.;
//  fft.linAverages(avgAmount);
//  fft.forward(in.mix);
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
     //valuePre += (fft.getAvg(i+baseFreq)*(1.-decay))*gain*100/(2*fftRange);
      valuePre += (LiveInput.spectrum[i+baseFreq]*(1.-decay))*gain*100/(2*fftRange);

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

//void stop()
//{
//  // always close Minim audio classes when you are done with them
//  in.close();
//  minim.stop();
//
//  super.stop();
//}

