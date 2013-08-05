void keyPressed() {
  switch(key) {
  case 'f':
    drawFFT = !drawFFT;
    break;
  case 'r':
    //FIXME
    //      particles.createRandomAttractor();
    break;
  }
}

void keyReleased() {
  switch(key) {
  case 'r':
    //FIXME
    //      particles.removeRandomAttractor();
    break;

  case 'd':
    decorate = !decorate;
    break;

  case '+':
    changeVisualEngine(currentEngineIndex + 1);
    break;

  case '-':
    changeVisualEngine(currentEngineIndex - 1);
    break;
  }
}

