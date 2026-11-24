
// ============================================================
// FOURIER SERIES MATHEMATICS LAB
// APDE - PROCESSING JAVA MODE - ANDROID
//
// PAGE 1: FOURIER SERIES
// PAGE 2: ANIMATED INTEGRATION
// PAGE 3: COEFFICIENT SELECTION + LIVE SYMBOLIC/NUMERIC EXPANSION
// PAGE 4: SYMBOLIC EXPANSION
// PAGE 5: ANIMATED NUMERICAL APPROXIMATION
//
// f(x) = 4/PI * SUM[sin(nx)/n], n odd
//
// F(x) = 4/PI * SUM[(1-cos(nx))/n^2], n odd
//
// Exact integrated function on [-PI, PI]: |x|
//
// ============================================================


// ============================================================
// GLOBAL VARIABLES
// ============================================================

int page = 0;

int harmonics = 5;
int maxHarmonics = 25;

int coefficientCount = 13;

boolean[] selected = new boolean[13];
float[] animatedWeight = new float[13];

boolean showOriginal = true;
boolean showComponents = true;
boolean animateIntegration = true;

// New toggle for coefficient-page expansion
boolean showNumericExpansion = false;

int integrationStep = 0;
int animationTick = 0;

float integrationProgress = 0;
float animationSpeed = 0.004;

float testX = 1.0;

// Drag and drop
int draggingIndex = -1;
boolean dragMoved = false;

float dragStartX;
float dragStartY;
float dragX;
float dragY;

// Graph
float leftX;
float rightX;
float plotTop;
float plotBottom;

// Colours
int bg = 0xFF101827;
int panel = 0xFF1A2940;

int cyan = 0xFF35D6E8;
int yellow = 0xFFFFCA58;
int green = 0xFF62E6A5;
int white = 0xFFF0F4FA;
int purple = 0xFFB69CFF;
int blue = 0xFF7186B5;


// ============================================================
// SETUP
// ============================================================

void setup() {

  fullScreen();
  smooth(4);

  textAlign(LEFT, CENTER);

  for (int i = 0; i < coefficientCount; i++) {
    selected[i] = false;
    animatedWeight[i] = 0;
  }
}


// ============================================================
// MAIN DRAW
// ============================================================

void draw() {

  background(bg);

  leftX = width * 0.05;
  rightX = width * 0.95;

  plotTop = height * 0.29;
  plotBottom = height * 0.68;

  drawHeader();

  if (page == 0) {
    drawFourierPage();
  }
  else if (page == 1) {
    drawIntegrationPage();
  }
  else if (page == 2) {
    drawCoefficientPage();
  }
  else if (page == 3) {
    drawExpansionPage();
  }
  else if (page == 4) {
    drawApproximationPage();
  }

  updateAnimatedWeights();

  if (draggingIndex >= 0 && dragMoved) {
    drawDraggedCoefficient();
  }

  drawNavigation();
}


// ============================================================
// FOURIER MATHEMATICS
// ============================================================

float squareWave(float x) {
  return sin(x) >= 0 ? 1 : -1;
}


float fourier(float x, int count) {

  float sum = 0;

  for (int n = 1; n <= count; n += 2) {
    sum += 4.0 / (PI * n) * sin(n * x);
  }

  return sum;
}


float harmonic(float x, int n) {

  if (n % 2 == 0) return 0;

  return 4.0 / (PI * n) * sin(n * x);
}


// ============================================================
// INTEGRATED FOURIER SERIES
// ============================================================

float coefficient(int n) {
  return 4.0 / (PI * n * n);
}


float integratedFourier(float x, int count) {

  float sum = 0;

  for (int n = 1; n <= count; n += 2) {

    sum += coefficient(n) *
           (1.0 - cos(n * x));
  }

  return sum;
}


float selectedApproximation(float x) {

  float sum = 0;

  for (int i = 0; i < coefficientCount; i++) {

    if (selected[i]) {

      int n = 2 * i + 1;

      sum += coefficient(n) *
             (1.0 - cos(n * x));
    }
  }

  return sum;
}


float animatedApproximation(float x) {

  float sum = 0;

  for (int i = 0; i < coefficientCount; i++) {

    int n = 2 * i + 1;

    float term =
      coefficient(n) *
      (1.0 - cos(n * x));

    sum += animatedWeight[i] * term;
  }

  return sum;
}


float exactIntegral(float x) {
  return abs(x);
}


// ============================================================
// ANIMATED COEFFICIENT WEIGHTS
// ============================================================

void updateAnimatedWeights() {

  for (int i = 0; i < coefficientCount; i++) {

    float target = selected[i] ? 1.0 : 0.0;

    animatedWeight[i] =
      lerp(animatedWeight[i], target, 0.09);

    if (abs(animatedWeight[i] - target) < 0.001) {
      animatedWeight[i] = target;
    }
  }
}


// ============================================================
// SYMBOLIC AND NUMERIC EXPRESSIONS
// ============================================================

String coefficientSymbolic(int n) {

  return "4/(PI*" + n + "^2)";
}


String termSymbolic(int n) {

  return coefficientSymbolic(n) +
         " * [1-cos(" + n + "x)]";
}


String termNumeric(int n) {

  return numberText(coefficient(n)) +
         " * [1-cos(" + n + "x)]";
}


String numberText(float value) {
  return nf(value, 1, 5);
}


int selectedCount() {

  int count = 0;

  for (int i = 0; i < coefficientCount; i++) {
    if (selected[i]) count++;
  }

  return count;
}


String selectedSeries(boolean numeric) {

  String result = "F(x) = ";

  boolean first = true;

  for (int i = 0; i < coefficientCount; i++) {

    if (selected[i]) {

      int n = 2 * i + 1;

      if (!first) {
        result += " + ";
      }

      if (numeric) {
        result += "(" + termNumeric(n) + ")";
      }
      else {
        result += "(" + termSymbolic(n) + ")";
      }

      first = false;
    }
  }

  if (first) {
    result += "0";
  }

  return result;
}


// ============================================================
// GRAPH MAPPING
// ============================================================

float graphX(float x) {
  return map(x, -PI, PI, leftX, rightX);
}


float graphY(float y) {
  return map(y, -1.6, 1.6, plotBottom, plotTop);
}


float integralGraphY(float y) {
  return map(y, 0, PI * 1.15, plotBottom, plotTop);
}


// ============================================================
// HEADER
// ============================================================

void drawHeader() {

  fill(cyan);
  textSize(height * 0.027);

  text("FOURIER SERIES LAB",
       leftX, height * 0.055);

  fill(white);
  textSize(height * 0.017);

  String heading = "";

  if (page == 0) heading = "1. Fourier Series";
  if (page == 1) heading = "2. Animated Integration";
  if (page == 2) heading = "3. Coefficient Selection";
  if (page == 3) heading = "4. Symbolic Summation";
  if (page == 4) heading = "5. Animated Approximation";

  text(heading, leftX, height * 0.115);

  fill(yellow);
  textSize(height * 0.016);

  text("N = " + harmonics,
       width * 0.83, height * 0.065);

  fill(green);
  textSize(height * 0.014);

  text("Selected: " + selectedCount(),
       width * 0.72, height * 0.14);
}


// ============================================================
// PAGE 1: FOURIER SERIES
// ============================================================

void drawFourierPage() {

  fill(green);
  textSize(height * 0.018);

  text("f(x) = 4/PI [sin(x) + sin(3x)/3 + ...]",
       leftX, height * 0.205);

  drawStandardGrid();

  // Original square wave
  if (showOriginal) {

    stroke(yellow);
    strokeWeight(2.5);
    noFill();

    beginShape();

    for (int i = 0; i <= 500; i++) {

      float x = map(i, 0, 500, -PI, PI);

      vertex(graphX(x),
             graphY(squareWave(x)));
    }

    endShape();
  }

  // Individual harmonics
  if (showComponents) {

    for (int n = 1; n <= harmonics; n += 2) {

      stroke(blue);
      strokeWeight(1.2);
      noFill();

      beginShape();

      for (int i = 0; i <= 400; i++) {

        float x = map(i, 0, 400, -PI, PI);

        vertex(graphX(x),
               graphY(harmonic(x, n)));
      }

      endShape();
    }
  }

  // Fourier approximation
  stroke(cyan);
  strokeWeight(3);
  noFill();

  beginShape();

  for (int i = 0; i <= 600; i++) {

    float x = map(i, 0, 600, -PI, PI);

    vertex(graphX(x),
           graphY(fourier(x, harmonics)));
  }

  endShape();

  fill(yellow);
  textSize(height * 0.016);

  text("Original square wave",
       leftX, plotTop - 15);

  fill(cyan);

  text("Fourier approximation",
       leftX + width * 0.27, plotTop - 15);

  drawButton(width * 0.05, height * 0.79,
             width * 0.12, height * 0.07, "-");

  drawButton(width * 0.19, height * 0.79,
             width * 0.12, height * 0.07, "+");

  drawButton(width * 0.36, height * 0.79,
             width * 0.20, height * 0.07,
             showComponents ? "COMPONENTS ON" : "COMPONENTS OFF");

  drawButton(width * 0.60, height * 0.79,
             width * 0.20, height * 0.07,
             showOriginal ? "ORIGINAL ON" : "ORIGINAL OFF");
}


// ============================================================
// STANDARD GRAPH GRID
// ============================================================

void drawStandardGrid() {

  stroke(0xFF35445A);
  strokeWeight(1);

  for (int i = -1; i <= 1; i++) {

    float y = graphY(i);

    line(leftX, y, rightX, y);
  }

  for (int i = -2; i <= 2; i++) {

    float x = graphX(i * PI / 2.0);

    line(x, plotTop, x, plotBottom);
  }

  stroke(white);
  strokeWeight(2);

  line(leftX, graphY(0),
       rightX, graphY(0));

  line(graphX(0), plotTop,
       graphX(0), plotBottom);

  fill(white);
  textSize(height * 0.015);

  text("-PI", leftX, plotBottom + 15);
  text("0", graphX(0), plotBottom + 15);
  text("+PI", rightX - 25, plotBottom + 15);
}


// ============================================================
// PAGE 2: ANIMATED INTEGRATION
// ============================================================

void drawIntegrationPage() {

  fill(green);
  textSize(height * 0.018);

  text("INTEGRATE EACH HARMONIC SEPARATELY",
       leftX, height * 0.19);

  fill(white);
  textSize(height * 0.019);

  text("Integral sin(nx)/n dx = -cos(nx)/n^2",
       leftX, height * 0.235);

  text("Integrated term = 4/(PI*n^2) [1-cos(nx)]",
       leftX, height * 0.275);

  drawIntegrationGraph();

  fill(yellow);
  textSize(height * 0.020);

  if (integrationStep > 0) {

    int n = 2 * integrationStep - 1;

    text("DISCOVERED: n = " + n,
         leftX, height * 0.735);

    fill(cyan);

    text("A" + n + " = " +
         numberText(coefficient(n)),
         width * 0.40, height * 0.735);
  }
  else {

    text("Waiting for integration...",
         leftX, height * 0.735);
  }

  drawButton(width * 0.05, height * 0.80,
             width * 0.20, height * 0.07,
             animateIntegration ? "PAUSE" : "ANIMATE");

  drawButton(width * 0.29, height * 0.80,
             width * 0.20, height * 0.07,
             "RESET");

  drawButton(width * 0.53, height * 0.80,
             width * 0.24, height * 0.07,
             "NEXT COEFFICIENT");

  if (animateIntegration &&
      integrationStep < coefficientCount) {

    animationTick++;

    if (animationTick >= 35) {

      integrationStep++;

      animationTick = 0;
    }
  }
}


// ============================================================
// INTEGRATION GRAPH
// ============================================================

void drawIntegrationGraph() {

  float top = height * 0.34;
  float bottom = height * 0.65;

  stroke(0xFF35445A);
  strokeWeight(1);

  for (int i = 0; i <= 4; i++) {

    float y = map(i, 0, 4, bottom, top);

    line(leftX, y, rightX, y);
  }

  int activeN = max(1, integrationStep * 2 - 1);

  float endX = map(integrationProgress,
                   0, 1, -PI, PI);

  // Integrated area
  noStroke();
  fill(53, 214, 232, 40);

  beginShape();

  vertex(graphX(-PI), bottom);

  for (int i = 0; i <= 300; i++) {

    float x = map(i, 0, 300, -PI, endX);

    vertex(graphX(x),
           integralGraphY(
             integratedFourier(x, activeN)
           ));
  }

  vertex(graphX(endX), bottom);

  endShape(CLOSE);

  // Integrated curve
  stroke(cyan);
  strokeWeight(3);
  noFill();

  beginShape();

  for (int i = 0; i <= 500; i++) {

    float x = map(i, 0, 500, -PI, PI);

    vertex(graphX(x),
           integralGraphY(
             integratedFourier(x, activeN)
           ));
  }

  endShape();

  // Animation progress
  if (animateIntegration) {

    integrationProgress += animationSpeed;

    if (integrationProgress > 1) {
      integrationProgress = 0;
    }
  }

  float markerX = graphX(endX);

  stroke(yellow);
  strokeWeight(2);

  line(markerX, top, markerX, bottom);

  fill(yellow);
  noStroke();

  ellipse(markerX,
          integralGraphY(
            integratedFourier(endX, activeN)
          ),
          14, 14);

  fill(white);
  textSize(height * 0.015);

  text("Integrated function F(x)",
       leftX, top - 12);
}


// ============================================================
// PAGE 3: COEFFICIENT SELECTION
// WITH LIVE SYMBOLIC / NUMERIC EXPANSION
// ============================================================

void drawCoefficientPage() {

  fill(green);
  textSize(height * 0.017);

  text("TOUCH OR DRAG COEFFICIENTS INTO THE SUMMATION",
       leftX, height * 0.19);

  fill(white);
  textSize(height * 0.016);

  text("A(n) = 4/(PI*n^2)",
       leftX, height * 0.235);


  // ----------------------------------------------------------
  // COEFFICIENT GRID
  // Two columns, seven rows
  // ----------------------------------------------------------

  for (int i = 0; i < coefficientCount; i++) {

    int n = 2 * i + 1;

    int col = i / 7;
    int row = i % 7;

    float x = width * (col == 0 ? 0.05 : 0.52);

    float y = height * (0.29 + row * 0.047);

    float w = width * 0.42;
    float h = height * 0.041;

    boolean isDragging =
      draggingIndex == i && dragMoved;

    if (isDragging) {
      fill(0xFF604C85);
    }
    else if (selected[i]) {
      fill(0xFF185C62);
    }
    else {
      fill(panel);
    }

    if (isDragging) {
      stroke(yellow);
      strokeWeight(2.5);
    }
    else {
      stroke(selected[i] ? green : blue);
      strokeWeight(1.2);
    }

    rect(x, y, w, h, 8);

    fill(yellow);
    textSize(height * 0.013);

    text("n=" + n,
         x + 8, y + h / 2);

    fill(white);

    text("A" + n + "=" +
         numberText(coefficient(n)),
         x + w * 0.25, y + h / 2);

    fill(isDragging ? yellow :
         (selected[i] ? green : cyan));

    text(selected[i] ? "ADDED" : "DRAG",
         x + w * 0.78, y + h / 2);
  }


  // ----------------------------------------------------------
  // SUMMATION DROP ZONE
  // ----------------------------------------------------------

  float dropX = width * 0.05;
  float dropY = height * 0.625;
  float dropW = width * 0.90;
  float dropH = height * 0.085;

  fill(0xFF142F43);
  stroke(cyan);
  strokeWeight(2);

  rect(dropX, dropY, dropW, dropH, 12);

  fill(yellow);
  textSize(height * 0.016);

  text("SUMMATION DROP ZONE",
       dropX + 12, dropY + height * 0.022);

  fill(white);
  textSize(height * 0.014);

  text("F(x) = " + selectedCount() +
       " selected terms",
       dropX + 12, dropY + height * 0.055);

  drawButton(width * 0.76,
             dropY + height * 0.025,
             width * 0.16,
             height * 0.045,
             "CLEAR ALL");


  // ----------------------------------------------------------
  // LIVE EXPANSION PANEL
  // ----------------------------------------------------------

  drawLiveExpansionPanel();


  fill(green);
  textSize(height * 0.012);

  text("Tap to toggle. Drag a coefficient into the summation box.",
       leftX, height * 0.905);
}


// ============================================================
// LIVE EXPANSION PANEL
// ============================================================

void drawLiveExpansionPanel() {

  float x = width * 0.05;
  float y = height * 0.72;

  float w = width * 0.90;
  float h = height * 0.175;

  fill(0xFF17253B);
  stroke(purple);
  strokeWeight(1.5);

  rect(x, y, w, h, 10);


  // Panel heading
  fill(purple);
  textSize(height * 0.015);

  text("LIVE FOURIER EXPANSION",
       x + 10, y + height * 0.018);


  // Toggle button
  drawButton(width * 0.72,
             y + height * 0.005,
             width * 0.21,
             height * 0.035,
             showNumericExpansion ? "NUMERIC" : "SYMBOLIC");


  // Current mode label
  fill(yellow);
  textSize(height * 0.012);

  if (showNumericExpansion) {

    text("Calculated coefficient values",
         x + 10, y + height * 0.043);
  }
  else {

    text("Exact symbolic coefficients",
         x + 10, y + height * 0.043);
  }


  // Display selected terms in two columns
  int shown = 0;

  for (int i = 0; i < coefficientCount; i++) {

    if (selected[i]) {

      int n = 2 * i + 1;

      int col = shown / 7;
      int row = shown % 7;

      float tx = width * (col == 0 ? 0.065 : 0.515);

      float ty = y + height * (0.066 + row * 0.0155);

      fill(cyan);
      textSize(height * 0.0105);

      String expression = "";

      if (showNumericExpansion) {
        expression = termNumeric(n);
      }
      else {
        expression = termSymbolic(n);
      }

      text(expression, tx, ty);

      shown++;
    }
  }


  if (shown == 0) {

    fill(white);
    textSize(height * 0.014);

    text("Select or drag coefficients above.",
         x + 12, y + height * 0.095);

    text("Your expansion will appear here automatically.",
         x + 12, y + height * 0.125);
  }
}


// ============================================================
// FLOATING COEFFICIENT DURING DRAG
// ============================================================

void drawDraggedCoefficient() {

  if (draggingIndex < 0) return;

  int n = 2 * draggingIndex + 1;

  float w = width * 0.25;
  float h = height * 0.055;

  rectMode(CENTER);

  fill(0xFF185C62);
  stroke(yellow);
  strokeWeight(2);

  rect(dragX, dragY, w, h, 10);

  fill(white);
  textAlign(CENTER, CENTER);

  textSize(height * 0.015);

  text("A" + n + " = " +
       numberText(coefficient(n)),
       dragX, dragY);

  textAlign(LEFT, CENTER);
  rectMode(CORNER);
}


// ============================================================
// PAGE 4: SYMBOLIC EXPANSION
// ============================================================

void drawExpansionPage() {

  fill(green);
  textSize(height * 0.020);

  text("YOUR SELECTED FOURIER INTEGRATION SERIES",
       leftX, height * 0.19);

  fill(yellow);
  textSize(height * 0.017);

  text("F(x) = SUM A(n) [1-cos(nx)]",
       leftX, height * 0.24);

  fill(cyan);
  textSize(height * 0.016);

  text("A(n) = 4/(PI*n^2)",
       leftX, height * 0.285);

  int shown = 0;

  for (int i = 0; i < coefficientCount; i++) {

    if (selected[i]) {

      int n = 2 * i + 1;

      int col = shown / 7;
      int row = shown % 7;

      float x = width * (col == 0 ? 0.05 : 0.52);

      float y = height * (0.36 + row * 0.060);

      fill(white);
      textSize(height * 0.014);

      text(shown == 0 ? "F(x) =" : "+",
           x, y);

      fill(purple);

      text(termSymbolic(n),
           x + width * 0.075, y);

      shown++;
    }
  }

  if (shown == 0) {

    fill(yellow);
    textSize(height * 0.021);

    text("No terms selected. Go BACK and select coefficients.",
         leftX, height * 0.48);
  }

  fill(green);
  textSize(height * 0.016);

  text("SELECTED TERMS: " + selectedCount(),
       leftX, height * 0.80);

  drawButton(width * 0.05, height * 0.84,
             width * 0.27, height * 0.06,
             "SELECT ALL");

  drawButton(width * 0.36, height * 0.84,
             width * 0.27, height * 0.06,
             "CLEAR ALL");
}


// ============================================================
// PAGE 5: ANIMATED NUMERICAL APPROXIMATION
// ============================================================

void drawApproximationPage() {

  fill(green);
  textSize(height * 0.019);

  text("LIVE FOURIER APPROXIMATION",
       leftX, height * 0.19);

  fill(white);
  textSize(height * 0.016);

  text("Test x = " + numberText(testX),
       leftX, height * 0.235);

  float approx = animatedApproximation(testX);
  float exact = exactIntegral(testX);

  fill(cyan);

  text("Animated approximation = " +
       numberText(approx),
       leftX, height * 0.275);

  fill(yellow);

  text("Exact |x| = " + numberText(exact),
       width * 0.52, height * 0.275);

  fill(green);

  text("Absolute error = " +
       numberText(abs(exact - approx)),
       leftX, height * 0.315);

  drawApproximationGraph();

  drawButton(width * 0.05, height * 0.79,
             width * 0.13, height * 0.07,
             "X -");

  drawButton(width * 0.21, height * 0.79,
             width * 0.13, height * 0.07,
             "X +");

  drawButton(width * 0.39, height * 0.79,
             width * 0.20, height * 0.07,
             "ADD ALL TERMS");

  drawButton(width * 0.64, height * 0.79,
             width * 0.20, height * 0.07,
             "CLEAR TERMS");
}


// ============================================================
// APPROXIMATION GRAPH
// ============================================================

void drawApproximationGraph() {

  float top = height * 0.38;
  float bottom = height * 0.69;

  stroke(0xFF35445A);
  strokeWeight(1);

  for (int i = 0; i <= 3; i++) {

    float y = map(i, 0, 3, bottom, top);

    line(leftX, y, rightX, y);
  }

  // Exact integral |x|
  stroke(yellow);
  strokeWeight(3);
  noFill();

  beginShape();

  for (int i = 0; i <= 500; i++) {

    float x = map(i, 0, 500, -PI, PI);

    float y = exactIntegral(x);

    vertex(graphX(x),
           map(y, 0, PI * 1.15, bottom, top));
  }

  endShape();

  // Animated Fourier approximation
  stroke(cyan);
  strokeWeight(3);
  noFill();

  beginShape();

  for (int i = 0; i <= 500; i++) {

    float x = map(i, 0, 500, -PI, PI);

    float y = animatedApproximation(x);

    vertex(graphX(x),
           map(y, 0, PI * 1.15, bottom, top));
  }

  endShape();

  // Test point
  float px = graphX(testX);

  float py = map(animatedApproximation(testX),
                 0, PI * 1.15, bottom, top);

  stroke(purple);
  strokeWeight(2);

  line(px, top, px, bottom);

  fill(purple);
  noStroke();

  ellipse(px, py, 13, 13);

  fill(yellow);
  textSize(height * 0.014);

  text("EXACT |x|",
       leftX, bottom + 14);

  fill(cyan);

  text("ANIMATED FOURIER SERIES",
       leftX + width * 0.20, bottom + 14);
}


// ============================================================
// BUTTON DRAWING
// ============================================================

void drawButton(float x, float y,
                float w, float h,
                String label) {

  fill(panel);
  stroke(cyan);
  strokeWeight(1.4);

  rect(x, y, w, h, 9);

  fill(white);

  textAlign(CENTER, CENTER);

  textSize(height * 0.013);

  text(label, x + w / 2, y + h / 2);

  textAlign(LEFT, CENTER);
}


// ============================================================
// NAVIGATION
// ============================================================

void drawNavigation() {

  float y = height * 0.925;
  float h = height * 0.055;

  drawButton(width * 0.67, y,
             width * 0.13, h, "BACK");

  drawButton(width * 0.82, y,
             width * 0.13, h, "NEXT");

  fill(green);
  textSize(height * 0.014);

  text("PAGE " + (page + 1) + " / 5",
       width * 0.43, y + h / 2);
}


// ============================================================
// TOUCH INPUT: PRESS
// ============================================================

void mousePressed() {

  // Navigation
  float navY = height * 0.925;
  float navH = height * 0.055;

  if (mouseY >= navY && mouseY <= navY + navH) {

    if (mouseX >= width * 0.67 &&
        mouseX <= width * 0.80) {

      page = max(0, page - 1);
      return;
    }

    if (mouseX >= width * 0.82 &&
        mouseX <= width * 0.95) {

      page = min(4, page + 1);
      return;
    }
  }


  // PAGE 1: FOURIER CONTROLS
  if (page == 0) {

    float y = height * 0.79;
    float h = height * 0.07;

    if (mouseY >= y && mouseY <= y + h) {

      if (mouseX < width * 0.17) {

        harmonics = max(1, harmonics - 2);
      }
      else if (mouseX < width * 0.32) {

        harmonics = min(maxHarmonics, harmonics + 2);
      }
      else if (mouseX < width * 0.58) {

        showComponents = !showComponents;
      }
      else if (mouseX < width * 0.83) {

        showOriginal = !showOriginal;
      }
    }
  }


  // PAGE 2: INTEGRATION CONTROLS
  else if (page == 1) {

    float y = height * 0.80;
    float h = height * 0.07;

    if (mouseY >= y && mouseY <= y + h) {

      if (mouseX < width * 0.27) {

        animateIntegration = !animateIntegration;
      }
      else if (mouseX < width * 0.51) {

        integrationStep = 0;
        integrationProgress = 0;
        animationTick = 0;
      }
      else if (mouseX < width * 0.79) {

        integrationStep =
          min(coefficientCount, integrationStep + 1);

        integrationProgress = 0;
      }
    }
  }


  // PAGE 3: COEFFICIENT SELECTION
  else if (page == 2) {

    float dropY = height * 0.625;

    // Clear all button
    if (mouseY >= dropY + height * 0.025 &&
        mouseY <= dropY + height * 0.070 &&
        mouseX >= width * 0.76 &&
        mouseX <= width * 0.92) {

      clearAllCoefficients();
      return;
    }

    // Symbolic/numeric toggle
    float panelY = height * 0.72;

    if (mouseY >= panelY + height * 0.005 &&
        mouseY <= panelY + height * 0.040 &&
        mouseX >= width * 0.72 &&
        mouseX <= width * 0.93) {

      showNumericExpansion = !showNumericExpansion;
      return;
    }

    // Coefficient selection
    for (int i = 0; i < coefficientCount; i++) {

      int col = i / 7;
      int row = i % 7;

      float x = width * (col == 0 ? 0.05 : 0.52);

      float y = height * (0.29 + row * 0.047);

      float w = width * 0.42;
      float h = height * 0.041;

      if (mouseX >= x && mouseX <= x + w &&
          mouseY >= y && mouseY <= y + h) {

        draggingIndex = i;
        dragMoved = false;

        dragStartX = mouseX;
        dragStartY = mouseY;

        dragX = mouseX;
        dragY = mouseY;

        break;
      }
    }
  }


  // PAGE 4: EXPANSION CONTROLS
  else if (page == 3) {

    float y = height * 0.84;
    float h = height * 0.06;

    if (mouseY >= y && mouseY <= y + h) {

      if (mouseX < width * 0.33) {

        selectAllCoefficients();
      }
      else if (mouseX < width * 0.64) {

        clearAllCoefficients();
      }
    }
  }


  // PAGE 5: APPROXIMATION CONTROLS
  else if (page == 4) {

    float y = height * 0.79;
    float h = height * 0.07;

    if (mouseY >= y && mouseY <= y + h) {

      if (mouseX < width * 0.19) {

        testX = max(-PI, testX - 0.25);
      }
      else if (mouseX < width * 0.35) {

        testX = min(PI, testX + 0.25);
      }
      else if (mouseX < width * 0.61) {

        selectAllCoefficients();
      }
      else if (mouseX < width * 0.87) {

        clearAllCoefficients();
      }
    }
  }
}


// ============================================================
// TOUCH INPUT: DRAG
// ============================================================

void mouseDragged() {

  if (page == 2 && draggingIndex >= 0) {

    dragX = mouseX;
    dragY = mouseY;

    float distance = dist(
      dragStartX,
      dragStartY,
      mouseX,
      mouseY
    );

    if (distance > 12) {
      dragMoved = true;
    }
  }
}


// ============================================================
// TOUCH INPUT: RELEASE
// ============================================================

void mouseReleased() {

  if (page == 2 && draggingIndex >= 0) {

    float dropY = height * 0.625;
    float dropBottom = height * 0.710;

    // Drop into summation zone
    if (dragMoved &&
        mouseY >= dropY &&
        mouseY <= dropBottom &&
        mouseX >= width * 0.05 &&
        mouseX <= width * 0.95) {

      selected[draggingIndex] = true;
    }

    // Tap to toggle
    else if (!dragMoved) {

      selected[draggingIndex] =
        !selected[draggingIndex];
    }

    draggingIndex = -1;
    dragMoved = false;
  }
}


// ============================================================
// SELECT ALL COEFFICIENTS
// ============================================================

void selectAllCoefficients() {

  for (int i = 0; i < coefficientCount; i++) {
    selected[i] = true;
  }
}


// ============================================================
// CLEAR ALL COEFFICIENTS
// ============================================================

void clearAllCoefficients() {

  for (int i = 0; i < coefficientCount; i++) {
    selected[i] = false;
  }
}


// ============================================================
// ANDROID BACK KEY
// ============================================================

void keyPressed() {

  if (keyCode == BACK) {

    if (page > 0) {
      page--;
    }
  }
}
