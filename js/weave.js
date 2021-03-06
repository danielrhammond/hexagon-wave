// by dw @ bees & bombs

int[][] result;
float t;

float ease(float p) {
  return 3*p*p - 2*p*p*p;
}

float ease(float p, float g) {
  if (p < 0.5) 
    return 0.5 * pow(2*p, g);
  else
    return 1 - 0.5 * pow(2*(1 - p), g);
}

float mn = .5*sqrt(3);

void setup() {
  setup_();
  result = new int[width*height][3];
}

void draw() {

  if (!recording) {
    t = mouseX*1.0/width;
    draw_();
  } else {
    for (int i=0; i<width*height; i++)
      for (int a=0; a<3; a++)
        result[i][a] = 0;

    for (int sa=0; sa<samplesPerFrame; sa++) {
      t = map(frameCount-1 + sa*shutterAngle/samplesPerFrame, 0, numFrames, 0, 1);
      draw_();
      loadPixels();
      for (int i=0; i<pixels.length; i++) {
        result[i][0] += pixels[i] >> 16 & 0xff;
        result[i][1] += pixels[i] >> 8 & 0xff;
        result[i][2] += pixels[i] & 0xff;
      }
    }

    loadPixels();
    for (int i=0; i<pixels.length; i++)
      pixels[i] = 0xff << 24 | 
        int(result[i][0]*1.0/samplesPerFrame) << 16 | 
        int(result[i][1]*1.0/samplesPerFrame) << 8 | 
        int(result[i][2]*1.0/samplesPerFrame);
    updatePixels();

    saveFrame("f###.gif");
    if (frameCount==numFrames)
      exit();
  }
}

//////////////////////////////////////////////////////////////////////////////

int samplesPerFrame = 8;
int numFrames = 170;        
float shutterAngle = .8;

boolean recording = true;

void setup_() {
  size(600, 500, P3D);
  rectMode(CENTER);
  fill(255);
  smooth(4);
  noStroke();
}

float x, y, z, tt;
float sp = 24, d = 4;
int N = 12;
float di, df = 0.045;
float ll = 0.2;
float mh = 100;
float mdi = 121;
color c1 = color(32), c2 = color(40,120,180), c3 = color(150,50,60);

void draw_() {
  background(250); 
  pushMatrix();
  translate(width/2, height/2-30);
  scale(1.5);
  rotateX(.676);
  rotate(TWO_PI*t/3);
  for (int i=-N; i<=N; i++) {
    for (int j=-N; j<=N; j++) {
      fill(c1);
      y = i*sp;
      x = (j)*mn*sp;
      if (j%2 != 0)
        y += .5*sp;
      di = max(abs(y), abs(.5*y+mn*x), abs(.5*y-mn*x));
      z = map(sin(TWO_PI*t-df*di), -1, 1, -mh/2, mh/2)*exp(-ll*df*di);
      pushMatrix();
      translate(x, y, z);
      if (di<mdi)
        sphere(d);
      popMatrix();

      fill(c2);
      y = i*sp;
      x = (j-2/3.0)*mn*sp;
      if (j%2 != 0)
        y += .5*sp;
      di = max(abs(y), abs(.5*y+mn*x), abs(.5*y-mn*x));
      z = map(sin(TWO_PI*t-df*di), -1, 1, -mh/2, mh/2)*exp(-ll*df*di);
      pushMatrix();
      translate(x, y, z);
      if (di<mdi)
        sphere(d);
      popMatrix();

      fill(c3);
      y = i*sp;
      x = (j+2/3.0)*mn*sp;
      if (j%2 != 0)
        y += .5*sp;
      di = max(abs(y), abs(.5*y+mn*x), abs(.5*y-mn*x));
      z = map(sin(TWO_PI*t-df*di), -1, 1, -mh/2, mh/2)*exp(-ll*df*di);
      pushMatrix();
      translate(x, y, z);
      if (di<mdi)
        sphere(d);
      popMatrix();
    }
  }

  popMatrix();
}
