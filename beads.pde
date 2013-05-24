
import pitaru.sonia_v2_9.*; // automcatically added when importing the library from the processing menu.

void initializeSonia(){
   Sonia.start(this); // Start Sonia engine.
   LiveInput.start(256); // Start LiveInput and return 256 FFT frequency bands.
}

void drawSonia(){
   getMeterLevel(); // Show meter-level reading for Left/Right channels.
   getSpectrum(); // Show FFT reading   
}

void getSpectrum(){
   strokeWeight(0);
   stroke(255,0,0);

   LiveInput.getSpectrum();
   // draw a bar for each of the elements in the spectrum array.
   // Note - the current FFT math is done in Java and is very raw. expect optimized alternative soon.
   for ( int i = 0; i < LiveInput.spectrum.length; i++){
      line(i*2, height, i*2, height - LiveInput.spectrum[i]);
   }
}

void getMeterLevel(){
   // get Peak level for each channel (0 -> Left , 1 -> Right)
   // Value Range: float from 0.0 to 1.0
   // Note: use inputMeter.getLevel() to combine both channels (L+R) into one value.
   float meterDataLeft = LiveInput.getLevel();
   float meterDataRight = LiveInput.getLevel();

   // draw a volume-meter for each channel.
   fill(0,100,0);
   float lefta = meterDataLeft*height;
   float righta = meterDataRight*height; 
   rect(width/2 - 100, height, 100 , lefta*-1);
   rect(width/2 , height, 100, righta*-1);
}

// Safely close the sound engine upon Browser shutdown.
public void stop(){
    Sonia.stop();
    super.stop();
}

