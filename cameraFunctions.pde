void printCamMatrix() {
//  println(cam.getPosition()[0] + " - " + cam.getPosition()[1] + " - " + cam.getPosition()[2]);
  println(cam.getLookAt()[0] + " - " + cam.getLookAt()[1] + " - " + cam.getLookAt()[2]);
  println(cam.getRotations()[0] + " - " + cam.getRotations()[1] + " - " + cam.getRotations()[2]);
  println(cam.getDistance());
//  printCamera();

//  println(cam.getState());
}

void getCamMatrix(float[] camLookAt, float[] camRot, float camDist){

  camLookAt[0] = cam.getLookAt()[0];
  camLookAt[1] = cam.getLookAt()[1];
  camLookAt[2] = cam.getLookAt()[2];

  camRot[0] = cam.getRotations()[0];
  camRot[1] = cam.getRotations()[1];
  camRot[2] = cam.getRotations()[2];
  
  camDist = (float)cam.getDistance();
}


void setCamMatrix(float[] camLookAt, float[] camRot, float camDist){

  cam.lookAt(camLookAt[0], camLookAt[1], camLookAt[2]);
  cam.setRotations(camRot[0], camRot[1], camRot[2]);
  cam.setDistance(camDist);
  
}
