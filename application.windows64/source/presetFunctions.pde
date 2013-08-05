boolean preset1 = false;
boolean preset2 = false;
boolean preset3 = false;
boolean preset4 = false;
boolean preset5 = false;
boolean preset6 = false;
boolean preset7 = false;
boolean preset8 = false;
boolean preset1Pre = false;
boolean preset2Pre = false;
boolean preset3Pre = false;
boolean preset4Pre = false;
boolean preset5Pre = false;
boolean preset6Pre = false;
boolean preset7Pre = false;
boolean preset8Pre = false;
boolean savePreset = false;
boolean savePresetPre = false;
int presetIndex = 0;

public float[] loadPreset(String dir, String name, int presetNumber) {
  float[] parameters = {
  };
  String[] lines;
  String[] pieces;
  String fullAddress = dir + name + presetNumber + ".txt"; 
  lines = loadStrings(fullAddress);
  println(sketchPath);
  println(fullAddress);
  pieces = split(lines[0], ' ');
  for (int i = 0; i < pieces.length; i++) {
    parameters = append(parameters, float(pieces[i]));
  }
  return parameters;
}

public void savePreset(String dir, String name, int presetNumber, float[] parameters) {
  String fullAddress = dir + name + presetNumber + ".txt"; 
  String[] toWrite00 = {
    ""
  };
  for (int i = 0; i < parameters.length; i++) {
    toWrite00[0] += parameters[i];
    if (i != parameters.length-1)
      toWrite00[0] += ' ';
  }
  saveStrings(fullAddress, toWrite00);
}

