
/*
================================================================
STRAIGHT SECANT - TANGENT APPROXIMATION LAB
APDE ANDROID - PROCESSING JAVA MODE
STANDARD 2D RENDERER

COMPLETE CORRECTED VERSION

CURVES:
1. PARABOLA
2. SINE WAVE
3. COSINE WAVE
4. CIRCLE
5. ELLIPSE
6. S CURVE

FEATURES:
1. Straight secant line
2. Animated tangent approximation
3. Six curve selectors
4. P and Q points
5. Slope triangle
6. Live mathematics
7. Convergence table
8. Drag P and Q
9. Play / Pause
10. Change h
11. Reset
12. Parametric derivatives

NO P3D
NO EXTERNAL LIBRARIES
================================================================
*/

// ================================================================
// VARIABLES
// ================================================================

float a = -1.0;
float h = 1.5;

float animationTime = 0;
float targetH = 1.5;

boolean animate = true;
boolean showTangent = true;
boolean showTriangle = true;
boolean showTable = true;
boolean showPoints = true;
boolean showGrid = true;
boolean showReference = true;

boolean draggingP = false;
boolean draggingQ = false;

int selectedCurve = 0;

String[] curveNames = {
  "PARABOLA",
  "SINE WAVE",
  "COSINE WAVE",
  "CIRCLE",
  "ELLIPSE",
  "S CURVE"
};

// ================================================================
// COLORS
// ================================================================

int bg = 0xFF101827;
int panel = 0xFF1B293A;
int panel2 = 0xFF26384C;

int white = 0xFFFFFFFF;
int cyan = 0xFF39D8F2;
int yellow = 0xFFFFD166;
int green = 0xFF62E6A5;
int pink = 0xFFFF7CA8;
int orange = 0xFFFFA45B;
int purple = 0xFFB79CFF;
int grey = 0xFF9EADBD;

// ================================================================
// SCREEN VARIABLES
// ================================================================

float graphLeft;
float graphRight;
float graphTop;
float graphBottom;

float graphCenterX;
float graphCenterY;

float unitScale;

float panelX;
float panelW;

float buttonY;
float buttonH;

// ================================================================
// SETUP
// ================================================================

void setup() {

  fullScreen();
  smooth(4);

  textFont(createFont("SansSerif", 16));

  initializeLayout();
}

// ================================================================
// LAYOUT
// ================================================================

void initializeLayout() {

  graphLeft = width * 0.045;
  graphRight = width * 0.655;

  graphTop = height * 0.17;
  graphBottom = height * 0.85;

  graphCenterX = (graphLeft + graphRight) / 2.0;
  graphCenterY = (graphTop + graphBottom) / 2.0;

  unitScale = min(
    (graphRight - graphLeft) / 8.0,
    (graphBottom - graphTop) / 9.0
  );

  panelX = width * 0.68;
  panelW = width * 0.30;

  buttonY = height * 0.91;
  buttonH = height * 0.065;
}

// ================================================================
// DRAW
// ================================================================

void draw() {

  background(bg);

  animationTime += 0.025;

  if (animate && !draggingP && !draggingQ) {

    a = -1.0 + 0.55 * sin(animationTime * 0.5);

    targetH = 1.8 -
      1.77 * (0.5 + 0.5 * sin(animationTime * 0.7));

    h = lerp(h, targetH, 0.045);
  }

  h = constrain(h, 0.015, 3.0);

  drawHeader();
  drawCurveSelector();
  drawGraph();
  drawInformation();
  drawTable();
  drawControls();
}

// ================================================================
// HEADER
// ================================================================

void drawHeader() {

  noStroke();
  fill(panel);

  rect(0, 0, width, height * 0.12);

  fill(cyan);
  textAlign(LEFT, CENTER);
  textSize(21);

  text(
    "STRAIGHT SECANT - TANGENT LAB",
    18,
    height * 0.045
  );

  fill(white);
  textSize(11);

  text(
    "LINEAR APPROXIMATION | DERIVATIVES | LIMITS",
    20,
    height * 0.09
  );

  fill(green);
  textAlign(RIGHT, CENTER);
  textSize(12);

  text(
    "2D MATHEMATICS",
    width - 18,
    height * 0.06
  );
}

// ================================================================
// CURVE SELECTOR
// ================================================================

void drawCurveSelector() {

  float x = panelX;
  float y = height * 0.125;

  float bw = panelW / 6.0;

  for (int i = 0; i < 6; i++) {

    float bx = x + i * bw;

    fill(selectedCurve == i ? cyan : panel2);
    noStroke();

    rect(
      bx + 2,
      y + 2,
      bw - 4,
      height * 0.025,
      4
    );

    fill(selectedCurve == i ? bg : white);

    textAlign(CENTER, CENTER);
    textSize(11);

    text(
      str(i + 1),
      bx + bw / 2,
      y + height * 0.014
    );
  }
}

// ================================================================
// GRAPH
// ================================================================

void drawGraph() {

  noStroke();
  fill(panel);

  rect(
    graphLeft - 12,
    graphTop - 12,
    graphRight - graphLeft + 24,
    graphBottom - graphTop + 24,
    12
  );

  if (showGrid) {
    drawGrid();
  }

  drawAxes();

  if (showReference) {
    drawReferenceCurve();
  }

  // CORRECT POINT CALCULATION

  PVector P = getPoint(a);
  PVector Q = getPoint(a + h);

  // STRAIGHT SECANT

  drawSecant(P, Q);

  // TANGENT

  if (showTangent) {
    drawTangent(a);
  }

  // SLOPE TRIANGLE

  if (showTriangle) {
    drawSlopeTriangle(P, Q);
  }

  // POINTS

  if (showPoints) {

    drawPoint(P.x, P.y, "P", yellow);
    drawPoint(Q.x, Q.y, "Q", pink);
  }

  fill(cyan);
  textAlign(LEFT, TOP);
  textSize(13);

  text(
    curveNames[selectedCurve],
    graphLeft,
    graphTop - 10
  );
}

// ================================================================
// CURVE MATHEMATICS
// ================================================================

PVector getPoint(float u) {

  float x = 0;
  float y = 0;

  if (selectedCurve == 0) {

    // PARABOLA
    x = u;
    y = x * x;
  }

  else if (selectedCurve == 1) {

    // SINE
    x = u;
    y = sin(x);
  }

  else if (selectedCurve == 2) {

    // COSINE
    x = u;
    y = cos(x);
  }

  else if (selectedCurve == 3) {

    // CIRCLE
    float r = 2.0;

    x = r * cos(u);
    y = r * sin(u);
  }

  else if (selectedCurve == 4) {

    // ELLIPSE
    float rx = 3.0;
    float ry = 1.8;

    x = rx * cos(u);
    y = ry * sin(u);
  }

  else if (selectedCurve == 5) {

    // S CURVE
    x = u;
    y = 0.12 * x * x * x;
  }

  return new PVector(x, y);
}

// ================================================================
// DERIVATIVE VECTOR
// ================================================================

PVector getDerivative(float u) {

  float dx = 1;
  float dy = 0;

  if (selectedCurve == 0) {

    dx = 1;
    dy = 2 * u;
  }

  else if (selectedCurve == 1) {

    dx = 1;
    dy = cos(u);
  }

  else if (selectedCurve == 2) {

    dx = 1;
    dy = -sin(u);
  }

  else if (selectedCurve == 3) {

    float r = 2.0;

    dx = -r * sin(u);
    dy = r * cos(u);
  }

  else if (selectedCurve == 4) {

    float rx = 3.0;
    float ry = 1.8;

    dx = -rx * sin(u);
    dy = ry * cos(u);
  }

  else if (selectedCurve == 5) {

    dx = 1;
    dy = 0.36 * u * u;
  }

  return new PVector(dx, dy);
}

// ================================================================
// SECANT SLOPE
// ================================================================

float secantSlope() {

  PVector P = getPoint(a);
  PVector Q = getPoint(a + h);

  float dx = Q.x - P.x;
  float dy = Q.y - P.y;

  if (abs(dx) < 0.00001) {
    return 999999;
  }

  return dy / dx;
}

// ================================================================
// TANGENT SLOPE
// ================================================================

float tangentSlope() {

  PVector D = getDerivative(a);

  if (abs(D.x) < 0.00001) {
    return 999999;
  }

  return D.y / D.x;
}

// ================================================================
// REFERENCE CURVE
// ================================================================

void drawReferenceCurve() {

  noFill();
  stroke(cyan);
  strokeWeight(3);

  beginShape();

  if (
    selectedCurve == 0 ||
    selectedCurve == 1 ||
    selectedCurve == 2 ||
    selectedCurve == 5
  ) {

    for (float u = -4; u <= 4; u += 0.02) {

      PVector p = getPoint(u);

      vertex(
        sx(p.x),
        sy(p.y)
      );
    }
  }

  else {

    for (float u = 0; u <= TWO_PI + 0.02; u += 0.02) {

      PVector p = getPoint(u);

      vertex(
        sx(p.x),
        sy(p.y)
      );
    }
  }

  endShape();
}

// ================================================================
// GRID
// ================================================================

void drawGrid() {

  stroke(255, 25);
  strokeWeight(1);

  for (float x = -4; x <= 4; x += 0.5) {

    line(
      sx(x), graphTop,
      sx(x), graphBottom
    );
  }

  for (float y = -4; y <= 5; y += 0.5) {

    line(
      graphLeft, sy(y),
      graphRight, sy(y)
    );
  }
}

// ================================================================
// AXES
// ================================================================

void drawAxes() {

  stroke(grey);
  strokeWeight(2);

  line(
    sx(-4), sy(0),
    sx(4), sy(0)
  );

  line(
    sx(0), sy(-4),
    sx(0), sy(5)
  );

  fill(white);
  textSize(10);

  textAlign(CENTER, TOP);

  for (int i = -4; i <= 4; i++) {

    text(
      str(i),
      sx(i),
      sy(0) + 5
    );
  }

  textAlign(RIGHT, CENTER);

  for (int i = -4; i <= 5; i++) {

    text(
      str(i),
      sx(0) - 5,
      sy(i)
    );
  }
}

// ================================================================
// STRAIGHT SECANT LINE
// ================================================================

void drawSecant(PVector P, PVector Q) {

  float dx = Q.x - P.x;
  float dy = Q.y - P.y;

  float len = sqrt(dx * dx + dy * dy);

  if (len < 0.00001) return;

  dx /= len;
  dy /= len;

  float extension = 8.0;

  float x1 = P.x - dx * extension;
  float y1 = P.y - dy * extension;

  float x2 = P.x + dx * extension;
  float y2 = P.y + dy * extension;

  stroke(yellow);
  strokeWeight(3);

  line(
    sx(x1), sy(y1),
    sx(x2), sy(y2)
  );

  // ACTUAL P-Q SEGMENT

  stroke(white);
  strokeWeight(1.5);

  line(
    sx(P.x), sy(P.y),
    sx(Q.x), sy(Q.y)
  );
}

// ================================================================
// STRAIGHT TANGENT LINE
// ================================================================

void drawTangent(float u) {

  PVector P = getPoint(u);
  PVector D = getDerivative(u);

  float len = sqrt(D.x * D.x + D.y * D.y);

  if (len < 0.00001) return;

  D.x /= len;
  D.y /= len;

  float extension = 8.0;

  float x1 = P.x - D.x * extension;
  float y1 = P.y - D.y * extension;

  float x2 = P.x + D.x * extension;
  float y2 = P.y + D.y * extension;

  stroke(green);
  strokeWeight(3);

  line(
    sx(x1), sy(y1),
    sx(x2), sy(y2)
  );
}

// ================================================================
// SLOPE TRIANGLE
// ================================================================

void drawSlopeTriangle(PVector P, PVector Q) {

  stroke(pink);
  strokeWeight(2);
  noFill();

  line(
    sx(P.x), sy(P.y),
    sx(Q.x), sy(P.y)
  );

  line(
    sx(Q.x), sy(P.y),
    sx(Q.x), sy(Q.y)
  );

  line(
    sx(P.x), sy(P.y),
    sx(Q.x), sy(Q.y)
  );

  fill(yellow);
  textSize(12);

  textAlign(CENTER, TOP);

  text(
    "Δx",
    (sx(P.x) + sx(Q.x)) / 2,
    sy(P.y) + 5
  );

  textAlign(LEFT, CENTER);

  text(
    "Δy",
    sx(Q.x) + 4,
    (sy(P.y) + sy(Q.y)) / 2
  );
}

// ================================================================
// POINT DRAWING
// ================================================================

void drawPoint(
  float x,
  float y,
  String name,
  int c
) {

  fill(c);
  stroke(white);
  strokeWeight(2);

  ellipse(
    sx(x),
    sy(y),
    14,
    14
  );

  fill(white);
  textSize(12);
  textAlign(LEFT, CENTER);

  text(
    name + " (" +
    nf(x, 1, 3) + "," +
    nf(y, 1, 3) + ")",
    sx(x) + 10,
    sy(y) - 14
  );
}

// ================================================================
// SCREEN COORDINATES
// ================================================================

float sx(float x) {

  return graphCenterX + x * unitScale;
}

float sy(float y) {

  return graphCenterY - y * unitScale;
}

// ================================================================
// INFORMATION PANEL
// ================================================================

void drawInformation() {

  float x = panelX;
  float y = height * 0.155;

  float w = panelW;
  float boxH = height * 0.39;

  fill(panel);
  noStroke();

  rect(x, y, w, boxH, 12);

  fill(cyan);
  textAlign(LEFT, TOP);
  textSize(15);

  text(
    "LIVE MATHEMATICS",
    x + 12,
    y + 12
  );

  PVector P = getPoint(a);
  PVector Q = getPoint(a + h);

  float dx = Q.x - P.x;
  float dy = Q.y - P.y;

  float sec = secantSlope();
  float tan = tangentSlope();

  float yy = y + 45;

  infoRow(
    "Point P",
    nf(P.x, 1, 3) + "," + nf(P.y, 1, 3),
    yellow, x, yy, w
  );

  yy += 28;

  infoRow(
    "Point Q",
    nf(Q.x, 1, 3) + "," + nf(Q.y, 1, 3),
    pink, x, yy, w
  );

  yy += 28;

  infoRow(
    "Delta X",
    nf(dx, 1, 5),
    white, x, yy, w
  );

  yy += 28;

  infoRow(
    "Delta Y",
    nf(dy, 1, 5),
    white, x, yy, w
  );

  yy += 28;

  infoRow(
    "Secant slope",
    sec == 999999 ? "VERTICAL" : nf(sec, 1, 5),
    yellow, x, yy, w
  );

  yy += 28;

  infoRow(
    "Tangent slope",
    tan == 999999 ? "VERTICAL" : nf(tan, 1, 5),
    green, x, yy, w
  );

  yy += 28;

  float error;

  if (sec == 999999 || tan == 999999) {
    error = abs(dx);
  } else {
    error = abs(sec - tan);
  }

  infoRow(
    "Slope error",
    nf(error, 1, 6),
    orange, x, yy, w
  );

  yy += 32;

  stroke(grey);

  line(
    x + 10, yy,
    x + w - 10, yy
  );

  yy += 10;

  fill(purple);
  textSize(12);

  text(
    curveNames[selectedCurve],
    x + 12,
    yy
  );

  yy += 22;

  fill(green);
  textSize(11);

  if (selectedCurve == 0) {

    text(
      "y = x²     dy/dx = 2x",
      x + 12, yy
    );
  }

  else if (selectedCurve == 1) {

    text(
      "y = sin(x)   y' = cos(x)",
      x + 12, yy
    );
  }

  else if (selectedCurve == 2) {

    text(
      "y = cos(x)   y' = -sin(x)",
      x + 12, yy
    );
  }

  else if (selectedCurve == 3) {

    text(
      "x = 2cos(t), y = 2sin(t)",
      x + 12, yy
    );
  }

  else if (selectedCurve == 4) {

    text(
      "x = 3cos(t), y = 1.8sin(t)",
      x + 12, yy
    );
  }

  else if (selectedCurve == 5) {

    text(
      "y = 0.12x³   y' = 0.36x²",
      x + 12, yy
    );
  }
}

// ================================================================
// INFORMATION ROW
// ================================================================

void infoRow(
  String label,
  String value,
  int c,
  float x,
  float y,
  float w
) {

  fill(grey);
  textSize(11);
  textAlign(LEFT, CENTER);

  text(
    label,
    x + 12,
    y
  );

  fill(c);
  textAlign(RIGHT, CENTER);

  text(
    value,
    x + w - 12,
    y
  );
}

// ================================================================
// CONVERGENCE TABLE
// ================================================================

void drawTable() {

  if (!showTable) return;

  float x = panelX;
  float y = height * 0.565;

  float w = panelW;
  float boxH = height * 0.315;

  fill(panel);
  noStroke();

  rect(x, y, w, boxH, 12);

  fill(cyan);
  textAlign(LEFT, TOP);
  textSize(14);

  text(
    "SECANT -> TANGENT LIMIT",
    x + 10,
    y + 10
  );

  fill(grey);
  textSize(9);

  text(
    "h       SECANT       ERROR",
    x + 10,
    y + 36
  );

  float[] steps = {
    1.0,
    0.5,
    0.1,
    0.01,
    0.001,
    0.0001
  };

  float yy = y + 57;

  for (int i = 0; i < steps.length; i++) {

    float step = steps[i];

    PVector P = getPoint(a);
    PVector Q = getPoint(a + step);

    float dx = Q.x - P.x;
    float dy = Q.y - P.y;

    float sec;

    if (abs(dx) < 0.00001) {
      sec = 999999;
    } else {
      sec = dy / dx;
    }

    float tan = tangentSlope();

    float error;

    if (sec == 999999 || tan == 999999) {
      error = abs(dx);
    } else {
      error = abs(sec - tan);
    }

    if (i % 2 == 0) {

      fill(panel2);

      rect(
        x + 7,
        yy - 8,
        w - 14,
        19,
        3
      );
    }

    textSize(10);
    textAlign(LEFT, CENTER);

    fill(white);

    text(
      nf(step, 1, 4),
      x + 11,
      yy
    );

    fill(yellow);

    text(
      sec == 999999 ? "VERT" : nf(sec, 1, 4),
      x + w * 0.36,
      yy
    );

    fill(orange);

    text(
      nf(error, 1, 5),
      x + w * 0.70,
      yy
    );

    yy += 22;
  }
}

// ================================================================
// BOTTOM BUTTONS
// ================================================================

void drawControls() {

  float gap = 4;
  float x = 8;

  float totalWidth = width - 16;

  float bw = (totalWidth - gap * 7) / 8.0;

  buttonY = height * 0.91;
  buttonH = height * 0.065;

  drawButton(x, bw, "PLAY", animate ? green : cyan);
  x += bw + gap;

  drawButton(x, bw, "P LEFT", yellow);
  x += bw + gap;

  drawButton(x, bw, "P RIGHT", yellow);
  x += bw + gap;

  drawButton(x, bw, "Q LEFT", pink);
  x += bw + gap;

  drawButton(x, bw, "Q RIGHT", pink);
  x += bw + gap;

  drawButton(x, bw, "h -", orange);
  x += bw + gap;

  drawButton(x, bw, "h +", orange);
  x += bw + gap;

  drawButton(x, bw, "RESET", purple);
}

// ================================================================
// BUTTON DRAWING
// ================================================================

void drawButton(
  float x,
  float w,
  String label,
  int c
) {

  fill(c);
  noStroke();

  rect(
    x,
    buttonY,
    w,
    buttonH,
    7
  );

  fill(bg);
  textAlign(CENTER, CENTER);
  textSize(10);

  text(
    label,
    x + w / 2,
    buttonY + buttonH / 2
  );
}

// ================================================================
// TOUCH INPUT
// ================================================================

void mousePressed() {

  // CURVE SELECTION

  float cx = panelX;
  float cy = height * 0.125;

  float bw = panelW / 6.0;

  if (
    mouseY >= cy &&
    mouseY <= cy + height * 0.03 &&
    mouseX >= cx &&
    mouseX <= cx + panelW
  ) {

    int id = int((mouseX - cx) / bw);

    selectedCurve = constrain(id, 0, 5);

    a = -1;
    h = 1.5;

    animate = false;

    return;
  }

  // BOTTOM BUTTONS

  float gap = 4;
  float totalWidth = width - 16;

  float buttonW = (totalWidth - gap * 7) / 8.0;

  if (
    mouseY >= buttonY &&
    mouseY <= buttonY + buttonH
  ) {

    int id = int((mouseX - 8) / (buttonW + gap));

    if (id < 0 || id > 7) return;

    if (id == 0) {

      animate = !animate;
    }

    else if (id == 1) {

      animate = false;
      a -= 0.2;
    }

    else if (id == 2) {

      animate = false;
      a += 0.2;
    }

    else if (id == 3) {

      animate = false;
      h = max(0.015, h - 0.2);
    }

    else if (id == 4) {

      animate = false;
      h = min(3.0, h + 0.2);
    }

    else if (id == 5) {

      animate = false;
      h = max(0.015, h - 0.05);
    }

    else if (id == 6) {

      animate = false;
      h = min(3.0, h + 0.05);
    }

    else if (id == 7) {

      a = -1;
      h = 1.5;

      selectedCurve = 0;
      animate = true;
    }

    return;
  }

  // DETECT P AND Q

  PVector P = getPoint(a);
  PVector Q = getPoint(a + h);

  if (
    dist(
      mouseX,
      mouseY,
      sx(P.x),
      sy(P.y)
    ) < 35
  ) {

    draggingP = true;
    animate = false;
  }

  else if (
    dist(
      mouseX,
      mouseY,
      sx(Q.x),
      sy(Q.y)
    ) < 35
  ) {

    draggingQ = true;
    animate = false;
  }
}

// ================================================================
// DRAGGING
// ================================================================

void mouseDragged() {

  if (draggingP) {

    float mx = (mouseX - graphCenterX) / unitScale;
    float my = (graphCenterY - mouseY) / unitScale;

    if (selectedCurve == 3 || selectedCurve == 4) {

      a = atan2(my, mx);

    } else {

      a = constrain(mx, -3.5, 3.5);
    }
  }

  if (draggingQ) {

    float mx = (mouseX - graphCenterX) / unitScale;
    float my = (graphCenterY - mouseY) / unitScale;

    if (selectedCurve == 3 || selectedCurve == 4) {

      float newAngle = atan2(my, mx);

      float difference = newAngle - a;

      while (difference < 0) {
        difference += TWO_PI;
      }

      while (difference > TWO_PI) {
        difference -= TWO_PI;
      }

      h = constrain(difference, 0.015, TWO_PI);

    } else {

      h = constrain(mx - a, 0.015, 3.0);
    }
  }
}

// ================================================================
// RELEASE
// ================================================================

void mouseReleased() {

  draggingP = false;
  draggingQ = false;
}

// ================================================================
// END OF COMPLETE PROGRAM
// ================================================================
