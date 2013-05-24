import processing.opengl.*;
import javax.media.opengl.*;
import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import toxi.geom.Vec2D;

int particleAmount = 250;

VerletPhysics2D physics;
AttractionBehavior mouseAttractor;
AttractionBehavior randomAttractor;
AttractionBehavior constantAttractor;

Vec2D constantVec;
Vec2D mousePos;

float colorness;

float fadeAmount = 0.;
float randomness = 0.02;
float rotAmount = 0.;
float lineLength = 1.;
float rotAng = 0.;
float sw = 0.1;
float swRand = 0.;
float constX = 0.01;
float constY = 0.01;


