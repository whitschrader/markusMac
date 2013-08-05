PVector superformulaPoint(float mm, float nn1, float nn2, float nn3, float phi) {
  float t1, t2;
  float a=1, b=1;
  float x = 0;
  float y = 0;
  float r;

  t1 = cos(mm * phi / 4) / a;
  t1 = abs(t1);
  t1 = pow(t1, nn2);

  t2 = sin(mm * phi / 4) / b;
  t2 = abs(t2);
  t2 = pow(t2, nn3);

  r = pow(t1+t2, 1/nn1);
  if (abs(r) == 0) {
    x = 0;
    y = 0;
  }  
  else {
    r = 1 / r;
    x = r * cos(phi);
    y = r * sin(phi);
  }

  return new PVector(x, y);
}

float superformulaPointR(float mm, float nn1, float nn2, float nn3, float phi) {
  float t1, t2;
  float a=1, b=1;
  float x = 0;
  float y = 0;
  float r;

  t1 = cos(mm * phi / 4) / a;
  t1 = abs(t1);
  t1 = pow(t1, nn2);

  t2 = sin(mm * phi / 4) / b;
  t2 = abs(t2);
  t2 = pow(t2, nn3);

  r = pow(t1+t2, 1/nn1);
  if (abs(r) == 0) {
    x = 0;
    y = 0;
  }  
  else {
    r = 1 / r;
    x = r * cos(phi);
    y = r * sin(phi);
  }

  return r;
}


float[] mapArrays(float[] inputArray, int outputArraySize){
  return null;
}



float triangleArea(PVector v1, PVector v2, PVector v3) {
  PVector a = PVector.sub(v1, v2);
  PVector b = PVector.sub(v1, v3);

  return 0.5*(sqrt(pow(a.y*b.z-a.z*b.y, 2)+pow(a.z*b.x-a.x*b.z, 2)+pow(a.x*b.y-a.y*b.x, 2)));
}

float polygonArea(PVector[] p) {
  float result = 0;
  for (int i = 0; i < p.length; i++) {
    result += ((p[i].x*p[(i+1)%p.length].y)-(p[i].y*p[(i+1)%p.length].x))/2;
  }
  return abs(result);
}

float newNoise(float x, float y, float z) {
  if (newNoiseNotInitialized) initNewNoise();
  int X = (int)Math.floor(x) & 255;
  int Y = (int)Math.floor(y) & 255;
  int Z = (int)Math.floor(z) & 255;
  x -= Math.floor(x);
  y -= Math.floor(y);
  z -= Math.floor(z);
  float u = newNoise_fade(x);
  float v = newNoise_fade(y);
  float w = newNoise_fade(z);   
  int A = newNoise_p[X]+Y;
  int AA = newNoise_p[A]+Z;
  int AB = newNoise_p[A+1]+Z;
  int B = newNoise_p[X+1]+Y;
  int BA = newNoise_p[B]+Z;
  int BB = newNoise_p[B+1]+Z;
  return newNoise_lerp2(w, newNoise_lerp2(v, newNoise_lerp2(u, newNoise_grad(newNoise_p[AA], x, y, z), newNoise_grad(newNoise_p[BA], x-1, y, z)), 
  newNoise_lerp2(u, newNoise_grad(newNoise_p[AB], x, y-1, z), newNoise_grad(newNoise_p[BB], x-1, y-1, z))), 
  newNoise_lerp2(v, newNoise_lerp2(u, newNoise_grad(newNoise_p[AA+1], x, y, z-1), newNoise_grad(newNoise_p[BA+1], x-1, y, z-1)), 
  newNoise_lerp2(u, newNoise_grad(newNoise_p[AB+1], x, y-1, z-1), newNoise_grad(newNoise_p[BB+1], x-1, y-1, z-1))));
}

float newNoise_fade(float t) {
  return t * t * t * (t * (t * 6 - 15) + 10);
}

float newNoise_lerp2(float t, float a, float b) {
  return (b - a)*t + a;
}

float newNoise_grad(int hash, float x, float y, float z) {
  int h = hash & 15;
  float u = h<8 ? x : y;
  float v = h<4 ? y : h==12||h==14 ? x : z;
  return ((h&1) == 0 ? u : -u) + ((h&2) == 0 ? v : -v);
}

void initNewNoise() {
  for (int i=0; i < 256 ; i++) {
    newNoise_permutation[i] = int(random(256));
    newNoise_p[256+i] = newNoise_p[i] = newNoise_permutation[i];
  }
  newNoiseNotInitialized = false;
}

int newNoise_p[] = new int[512];
int newNoise_permutation[] = new int[512];
boolean newNoiseNotInitialized = true;

