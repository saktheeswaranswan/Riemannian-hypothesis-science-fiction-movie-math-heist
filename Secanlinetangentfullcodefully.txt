
/*
===============================================================
SECANT - TANGENT - INFINITE CURVE MATHEMATICS LAB
APDE ANDROID - PROCESSING JAVA MODE
STANDARD 2D RENDERER

NO P3D
NO LANDSCAPE RENDERER ARGUMENT
NO EXTERNAL LIBRARIES

MATHEMATICS:
f(x) = x*x

P = (a, f(a))
Q = (b, f(b))

SECANT:
m = (f(b)-f(a))/(b-a)

DERIVATIVE:
f'(a) = 2*a

LIMIT:
lim h->0 [f(a+h)-f(a)]/h = 2a

CURVES:
0 LINE
1 PARABOLIC ARC
2 CIRCULAR ARC
3 SINE WAVE
4 KOLAM LOOP
5 CUBIC S CURVE

CONTROLS:
PLAY / PAUSE
MOVE P LEFT / RIGHT
MOVE Q LEFT / RIGHT
DECREASE h
INCREASE h
TANGENT ON / OFF
TRIANGLE ON / OFF
TABLE ON / OFF
DRAG P AND Q

===============================================================
*/

// =============================================================
// GLOBAL VARIABLES
// =============================================================

float a = -1.0;

float h = 2.0;

float animationTime = 0;

float targetH = 2.0;

boolean animate = true;

boolean showTangent = true;

boolean showTriangle = true;

boolean showTable = true;

boolean showPoints = true;

boolean showGrid = true;

boolean showFormula = true;

boolean draggingP = false;

boolean draggingQ = false;

int selectedCurve = 0;

String[] curveNames = {
  "STRAIGHT LINE",
  "PARABOLIC ARC",
  "CIRCULAR ARC",
  "SINE WAVE",
  "KOLAM LOOP",
  "CUBIC S CURVE"
};

// =============================================================
// COLORS
// =============================================================

int bg = 0xFF101827;

int panel = 0xFF1B293A;

int panel2 = 0xFF24364A;

int white = 0xFFFFFFFF;

int cyan = 0xFF39D8F2;

int yellow = 0xFFFFD166;

int green = 0xFF62E6A5;

int pink = 0xFFFF7CA8;

int orange = 0xFFFFA45B;

int purple = 0xFFB79CFF;

int grey = 0xFF9EADBD;

// =============================================================
// SCREEN VARIABLES
// =============================================================

float graphLeft;

float graphRight;

float graphTop;

float graphBottom;

float unitScale;

float buttonY;

float buttonH;

float graphCenterX;

float graphCenterY;

float panelX;

float panelW;

// =============================================================
// SETUP
// =============================================================

void setup() {

  // IMPORTANT:
  // Standard Android 2D renderer.
  // Do not use fullScreen(LANDSCAPE).
  // Set Landscape in APDE sketch settings.

  fullScreen();

  smooth(4);

  textFont(createFont("SansSerif",16));

  initializeLayout();

}

// =============================================================
// INITIALIZE LAYOUT
// =============================================================

void initializeLayout() {

  graphLeft = width * 0.045;

  graphRight = width * 0.655;

  graphTop = height * 0.17;

  graphBottom = height * 0.85;

  graphCenterX = (graphLeft+graphRight)/2;

  graphCenterY = (graphTop+graphBottom)/2;

  unitScale = min(
    (graphRight-graphLeft)/8.0,
    (graphBottom-graphTop)/10.0
  );

  panelX = width*0.68;

  panelW = width*0.30;

  buttonY = height*0.91;

  buttonH = height*0.065;

}

// =============================================================
// DRAW
// =============================================================

void draw() {

  background(bg);

  animationTime += 0.025;

  if (animate && !draggingP && !draggingQ) {

    a = -1.0 + 0.65*sin(animationTime*0.5);

    targetH = 1.8 -
      1.65*(0.5+0.5*sin(animationTime*0.8));

    h = lerp(h,targetH,0.035);

  }

  h = constrain(h,0.015,3.0);

  drawHeader();

  drawGraph();

  drawInformation();

  drawTable();

  drawCurveSelector();

  drawControls();

}

// =============================================================
// HEADER
// =============================================================

void drawHeader() {

  noStroke();

  fill(panel);

  rect(0,0,width,height*0.12);

  fill(cyan);

  textSize(21);

  textAlign(LEFT,CENTER);

  text(
    "SECANT TO TANGENT LAB",
    18,height*0.045
  );

  fill(white);

  textSize(11);

  text(
    "INFINITE CURVES | DERIVATIVES | LIMITS",
    20,height*0.09
  );

  fill(green);

  textAlign(RIGHT,CENTER);

  textSize(12);

  text(
    "2D CALCULUS LAB",
    width-18,height*0.06
  );

}

// =============================================================
// GRAPH
// =============================================================

void drawGraph() {

  fill(panel);

  noStroke();

  rect(
    graphLeft-12,
    graphTop-12,
    graphRight-graphLeft+24,
    graphBottom-graphTop+24,
    12
  );

  if (showGrid) {

    drawGrid();

  }

  drawAxes();

  drawOriginalParabola();

  float b = a+h;

  float x1 = a;

  float x2 = b;

  float y1 = functionF(x1);

  float y2 = functionF(x2);

  // Selected connecting curve

  drawConnectingCurve(
    x1,y1,x2,y2
  );

  // Secant

  drawSecant();

  // Tangent

  if (showTangent) {

    drawTangent(a);

  }

  // Slope triangle

  if (showTriangle) {

    drawSlopeTriangle(
      x1,y1,x2,y2
    );

  }

  // Points

  if (showPoints) {

    drawPoint(
      x1,y1,"P",yellow
    );

    drawPoint(
      x2,y2,"Q",pink
    );

  }

  fill(cyan);

  textSize(13);

  textAlign(LEFT,TOP);

  text(
    "f(x) = x²",
    graphLeft,
    graphTop-10
  );

}

// =============================================================
// FUNCTION
// =============================================================

float functionF(float x) {

  return x*x;

}

// =============================================================
// GRID
// =============================================================

void drawGrid() {

  stroke(255,25);

  strokeWeight(1);

  for (float x=-4; x<=4; x+=0.5) {

    line(
      sx(x),graphTop,
      sx(x),graphBottom
    );

  }

  for (float y=-2; y<=10; y+=0.5) {

    line(
      graphLeft,sy(y),
      graphRight,sy(y)
    );

  }

}

// =============================================================
// AXES
// =============================================================

void drawAxes() {

  stroke(grey);

  strokeWeight(2);

  line(
    sx(-4),sy(0),
    sx(4),sy(0)
  );

  line(
    sx(0),sy(-2),
    sx(0),sy(10)
  );

  fill(white);

  textSize(10);

  textAlign(CENTER,TOP);

  for (int i=-4;i<=4;i++) {

    text(
      str(i),
      sx(i),
      sy(0)+5
    );

  }

  textAlign(RIGHT,CENTER);

  for (int i=-2;i<=10;i+=2) {

    text(
      str(i),
      sx(0)-5,
      sy(i)
    );

  }

}

// =============================================================
// ORIGINAL PARABOLA
// =============================================================

void drawOriginalParabola() {

  noFill();

  stroke(cyan);

  strokeWeight(3);

  beginShape();

  for (float x=-4;x<=4;x+=0.025) {

    vertex(
      sx(x),
      sy(functionF(x))
    );

  }

  endShape();

}

// =============================================================
// CONNECTING CURVE
// =============================================================

void drawConnectingCurve(
  float x1,float y1,
  float x2,float y2
) {

  if (selectedCurve==0) {

    stroke(yellow);

    strokeWeight(4);

    line(
      sx(x1),sy(y1),
      sx(x2),sy(y2)
    );

    return;

  }

  if (selectedCurve==1) stroke(green);

  if (selectedCurve==2) stroke(orange);

  if (selectedCurve==3) stroke(purple);

  if (selectedCurve==4) stroke(pink);

  if (selectedCurve==5) stroke(white);

  strokeWeight(4);

  noFill();

  beginShape();

  for (int i=0;i<=180;i++) {

    float t=i/180.0;

    PVector p = makeCurve(
      x1,y1,x2,y2,t
    );

    vertex(
      sx(p.x),
      sy(p.y)
    );

  }

  endShape();

}

// =============================================================
// CURVE GENERATOR
// =============================================================

PVector makeCurve(
  float x1,float y1,
  float x2,float y2,
  float t
) {

  float x = lerp(x1,x2,t);

  float baseY = lerp(y1,y2,t);

  float envelope = sin(PI*t);

  float arch = 0;

  float amplitude = 0.55;

  // -----------------------------------------------------------
  // 1. PARABOLIC ARCH
  // -----------------------------------------------------------

  if (selectedCurve==1) {

    arch = amplitude*4*t*(1-t);

  }

  // -----------------------------------------------------------
  // 2. TRUE CIRCULAR ARC
  // -----------------------------------------------------------

  if (selectedCurve==2) {

    // Upper semicircle:
    // y = sqrt(1-u*u)
    // u = 2t-1

    float u = 2*t-1;

    arch = amplitude*2*
      sqrt(max(0,1-u*u));

  }

  // -----------------------------------------------------------
  // 3. SINE WAVE
  // -----------------------------------------------------------

  if (selectedCurve==3) {

    arch = amplitude*
      sin(2*PI*t);

  }

  // -----------------------------------------------------------
  // 4. KOLAM INSPIRED LOOP
  // -----------------------------------------------------------

  if (selectedCurve==4) {

    arch = amplitude*(
      0.75*sin(4*PI*t)+
      0.25*sin(8*PI*t)
    );

    x += 0.22*sin(4*PI*t)*envelope;

  }

  // -----------------------------------------------------------
  // 5. CUBIC S CURVE
  // -----------------------------------------------------------

  if (selectedCurve==5) {

    float u = 2*t-1;

    arch = amplitude*1.8*
      u*(1-u*u);

  }

  // Endpoints remain exactly connected.

  return new PVector(
    x,
    baseY+arch*envelope
  );

}

// =============================================================
// SECANT LINE
// =============================================================

void drawSecant() {

  float b=a+h;

  float y=functionF(a);

  float m=secantSlope();

  float left=-4;

  float right=4;

  stroke(yellow);

  strokeWeight(2);

  line(
    sx(left),
    sy(y+m*(left-a)),
    sx(right),
    sy(y+m*(right-a))
  );

}

// =============================================================
// TANGENT LINE
// =============================================================

void drawTangent(float x) {

  float y=functionF(x);

  float m=derivative(x);

  stroke(green);

  strokeWeight(3);

  float left=-4;

  float right=4;

  line(
    sx(left),
    sy(y+m*(left-x)),
    sx(right),
    sy(y+m*(right-x))
  );

}

// =============================================================
// SLOPE TRIANGLE
// =============================================================

void drawSlopeTriangle(
  float x1,float y1,
  float x2,float y2
) {

  stroke(pink);

  strokeWeight(2);

  noFill();

  line(
    sx(x1),sy(y1),
    sx(x2),sy(y1)
  );

  line(
    sx(x2),sy(y1),
    sx(x2),sy(y2)
  );

  line(
    sx(x1),sy(y1),
    sx(x2),sy(y2)
  );

  fill(yellow);

  textSize(12);

  textAlign(CENTER,TOP);

  text(
    "Δx",
    (sx(x1)+sx(x2))/2,
    sy(y1)+5
  );

  textAlign(LEFT,CENTER);

  text(
    "Δy",
    sx(x2)+4,
    (sy(y1)+sy(y2))/2
  );

}

// =============================================================
// POINTS
// =============================================================

void drawPoint(
  float x,float y,
  String name,
  int c
) {

  fill(c);

  stroke(white);

  strokeWeight(2);

  ellipse(
    sx(x),sy(y),
    14,14
  );

  fill(white);

  textSize(12);

  textAlign(LEFT,CENTER);

  text(
    name+" ("+
    nf(x,1,3)+","+
    nf(y,1,3)+")",
    sx(x)+10,
    sy(y)-14
  );

}

// =============================================================
// SCREEN COORDINATES
// =============================================================

float sx(float x) {

  return graphCenterX+x*unitScale;

}

float sy(float y) {

  return graphCenterY-y*unitScale;

}

// =============================================================
// MATHEMATICS
// =============================================================

float secantSlope() {

  float b=a+h;

  return (
    functionF(b)-functionF(a)
  )/h;

}

float derivative(float x) {

  return 2*x;

}

// =============================================================
// INFORMATION PANEL
// =============================================================

void drawInformation() {

  float x=panelX;

  float y=height*0.155;

  float w=panelW;

  float boxH=height*0.39;

  fill(panel);

  noStroke();

  rect(x,y,w,boxH,12);

  fill(cyan);

  textSize(15);

  textAlign(LEFT,TOP);

  text(
    "LIVE MATHEMATICS",
    x+12,y+12
  );

  float b=a+h;

  float dx=h;

  float dy=functionF(b)-functionF(a);

  float m=secantSlope();

  float d=derivative(a);

  float yy=y+45;

  infoRow("Point P",
    "("+nf(a,1,3)+","+nf(functionF(a),1,3)+")",
    yellow,x,yy,w);

  yy+=29;

  infoRow("Point Q",
    "("+nf(b,1,3)+","+nf(functionF(b),1,3)+")",
    pink,x,yy,w);

  yy+=29;

  infoRow("Delta X",
    nf(dx,1,5),
    white,x,yy,w);

  yy+=29;

  infoRow("Delta Y",
    nf(dy,1,5),
    white,x,yy,w);

  yy+=29;

  infoRow("Secant slope",
    nf(m,1,6),
    yellow,x,yy,w);

  yy+=29;

  infoRow("Tangent slope",
    nf(d,1,6),
    green,x,yy,w);

  yy+=29;

  infoRow("Slope error",
    nf(abs(m-d),1,7),
    orange,x,yy,w);

  yy+=32;

  stroke(grey);

  line(x+10,yy,x+w-10,yy);

  yy+=10;

  fill(purple);

  textSize(12);

  text(
    curveNames[selectedCurve],
    x+12,yy
  );

  if (showFormula) {

    yy+=21;

    fill(green);

    textSize(12);

    text(
      "f(x) = x²     f'(x) = 2x",
      x+12,yy
    );

  }

}

// =============================================================
// INFORMATION ROW
// =============================================================

void infoRow(
  String label,
  String value,
  int c,
  float x,float y,float w
) {

  fill(grey);

  textSize(11);

  textAlign(LEFT,CENTER);

  text(label,x+12,y);

  fill(c);

  textAlign(RIGHT,CENTER);

  text(
    value,
    x+w-12,y
  );

}

// =============================================================
// CONVERGENCE TABLE
// =============================================================

void drawTable() {

  if (!showTable) return;

  float x=panelX;

  float y=height*0.565;

  float w=panelW;

  float boxH=height*0.315;

  fill(panel);

  noStroke();

  rect(x,y,w,boxH,12);

  fill(cyan);

  textSize(14);

  textAlign(LEFT,TOP);

  text(
    "INFINITESIMAL LIMIT",
    x+10,y+10
  );

  fill(grey);

  textSize(9);

  text(
    "h       SECANT      TANGENT      ERROR",
    x+10,y+36
  );

  float[] steps = {
    1.0,
    0.5,
    0.1,
    0.01,
    0.001,
    0.0001
  };

  float yy=y+57;

  for (int i=0;i<steps.length;i++) {

    float step=steps[i];

    // Exact secant for f(x)=x²

    float sec=2*a+step;

    float tangent=2*a;

    float error=abs(sec-tangent);

    if (i%2==0) {

      fill(panel2);

      rect(
        x+7,yy-8,
        w-14,19,3
      );

    }

    textSize(10);

    textAlign(LEFT,CENTER);

    fill(white);

    text(
      nf(step,1,4),
      x+11,yy
    );

    fill(yellow);

    text(
      nf(sec,1,4),
      x+w*0.34,yy
    );

    fill(green);

    text(
      nf(tangent,1,4),
      x+w*0.58,yy
    );

    fill(orange);

    text(
      nf(error,1,5),
      x+w*0.80,yy
    );

    yy+=22;

  }

}

// =============================================================
// CURVE SELECTOR
// =============================================================

void drawCurveSelector() {

  float x=panelX;

  float y=height*0.125;

  fill(panel);

  noStroke();

  rect(
    x,y,panelW,height*0.022,5
  );

  float bw=panelW/6.0;

  for (int i=0;i<6;i++) {

    float bx=x+i*bw;

    fill(selectedCurve==i?cyan:panel2);

    rect(
      bx+2,y+2,
      bw-4,height*0.018,4
    );

    fill(selectedCurve==i?bg:white);

    textAlign(CENTER,CENTER);

    textSize(11);

    text(
      str(i+1),
      bx+bw/2,
      y+height*0.011
    );

  }

}

// =============================================================
// BUTTONS
// =============================================================

void drawControls() {

  float gap=4;

  float x=8;

  float totalWidth=width-16;

  float bw=(totalWidth-gap*7)/8.0;

  buttonY=height*0.91;

  buttonH=height*0.065;

  drawButton(x,bw,"PLAY",animate?green:cyan);

  x+=bw+gap;

  drawButton(x,bw,"P LEFT",yellow);

  x+=bw+gap;

  drawButton(x,bw,"P RIGHT",yellow);

  x+=bw+gap;

  drawButton(x,bw,"Q LEFT",pink);

  x+=bw+gap;

  drawButton(x,bw,"Q RIGHT",pink);

  x+=bw+gap;

  drawButton(x,bw,"h -",orange);

  x+=bw+gap;

  drawButton(x,bw,"h +",orange);

  x+=bw+gap;

  drawButton(x,bw,"RESET",purple);

}

void drawButton(
  float x,float w,
  String label,int c
) {

  fill(c);

  noStroke();

  rect(
    x,buttonY,
    w,buttonH,7
  );

  fill(bg);

  textAlign(CENTER,CENTER);

  textSize(10);

  text(
    label,
    x+w/2,
    buttonY+buttonH/2
  );

}

// =============================================================
// TOUCH
// =============================================================

void mousePressed() {

  // Curve selection

  float cx=panelX;

  float cy=height*0.125;

  float bw=panelW/6.0;

  if (
    mouseY>=cy &&
    mouseY<=cy+height*0.022 &&
    mouseX>=cx &&
    mouseX<=cx+panelW
  ) {

    int id=int((mouseX-cx)/bw);

    selectedCurve=constrain(id,0,5);

    return;

  }

  // Bottom controls

  float gap=4;

  float totalWidth=width-16;

  float buttonW=(totalWidth-gap*7)/8.0;

  if (
    mouseY>=buttonY &&
    mouseY<=buttonY+buttonH
  ) {

    int id=int((mouseX-8)/(buttonW+gap));

    if (id==0) {

      animate=!animate;

    }

    if (id==1) {

      animate=false;

      a-=0.2;

    }

    if (id==2) {

      animate=false;

      a+=0.2;

    }

    if (id==3) {

      animate=false;

      h=max(0.015,h-0.2);

    }

    if (id==4) {

      animate=false;

      h=min(3.0,h+0.2);

    }

    if (id==5) {

      animate=false;

      h=max(0.015,h-0.05);

    }

    if (id==6) {

      animate=false;

      h=min(3.0,h+0.05);

    }

    if (id==7) {

      a=-1;

      h=2;

      selectedCurve=0;

      animate=true;

    }

    return;

  }

  // Drag points

  float px=sx(a);

  float py=sy(functionF(a));

  float qx=sx(a+h);

  float qy=sy(functionF(a+h));

  if (dist(mouseX,mouseY,px,py)<35) {

    draggingP=true;

    animate=false;

  }

  else if (dist(mouseX,mouseY,qx,qy)<35) {

    draggingQ=true;

    animate=false;

  }

}

// =============================================================
// DRAG
// =============================================================

void mouseDragged() {

  if (draggingP) {

    float nx=(mouseX-graphCenterX)/unitScale;

    a=constrain(nx,-3.5,3.5);

  }

  if (draggingQ) {

    float nx=(mouseX-graphCenterX)/unitScale;

    float newH=nx-a;

    h=constrain(newH,0.015,3.0);

  }

}

// =============================================================
// RELEASE
// =============================================================

void mouseReleased() {

  draggingP=false;

  draggingQ=false;

}

// =============================================================
// END OF SECANT TANGENT LAB
// =============================================================
