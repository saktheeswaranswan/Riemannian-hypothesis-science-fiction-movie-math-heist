
// ================================================================
// ADVANCED NUMERICAL ROOT FINDING LAB - VERSION 4
// APDE PROCESSING JAVA MODE - ANDROID LANDSCAPE
//
// METHODS:
// 1. Bisection
// 2. Secant
// 3. Newton-Raphson
//
// FEATURES:
// - Live polynomial graph
// - Bisection bracket approximation
// - Secant straight-line approximation
// - Newton tangent-line approximation
// - Plus / minus sign chart
// - Descartes Rule of Signs
// - Numerical iteration table
// - Error and convergence information
// - Touch controls
//
// ================================================================

// -------------------- COLORS --------------------

int bg = 0xFF101827;
int panel = 0xFF182538;
int gridColor = 0xFF30435A;
int cyan = 0xFF35D6E8;
int yellow = 0xFFFFCA58;
int green = 0xFF62E6A5;
int red = 0xFFFF667A;
int white = 0xFFF2F5FA;
int muted = 0xFF9AAEC2;
int purple = 0xFFB99CFF;

// -------------------- GLOBAL GRAPH VARIABLES --------------------

float plotX;
float plotY;
float plotW;
float plotH;

float graphMinX = -5;
float graphMaxX = 5;
float graphMinY = -8;
float graphMaxY = 8;

// -------------------- POLYNOMIAL --------------------

float[] coeff = new float[8];
int degree = 3;

String equationText = "";

int maxIterations = 30;
int selectedMethod = 0;

boolean solved = false;
boolean bracketFound = false;
boolean approximationAvailable = false;

String statusText = "READY";

// -------------------- SOLUTION VARIABLES --------------------

float root = 0;
float bracketA = 0;
float bracketB = 0;

float approximationX1 = 0;
float approximationY1 = 0;
float approximationX2 = 0;
float approximationY2 = 0;

float tangentX = 0;
float tangentY = 0;
float tangentSlope = 0;

int iteration = 0;

// -------------------- ITERATION TABLE --------------------

float[] tableX = new float[100];
float[] tableFX = new float[100];
float[] tableError = new float[100];
float[] tableA = new float[100];
float[] tableB = new float[100];

String[] tableSign = new String[100];

int tableCount = 0;

// ================================================================
// SETUP
// ================================================================

void settings() {
  fullScreen(LANDSCAPE);
}

void setup() {
  orientation(LANDSCAPE);

  textFont(createFont("SansSerif", 18));

  calculateLayout();
  generatePolynomial();
}

void calculateLayout() {

  // Graph occupies left side.
  plotX = width * 0.045f;
  plotY = height * 0.285f;
  plotW = width * 0.59f;
  plotH = height * 0.53f;
}

// ================================================================
// MAIN DRAW
// ================================================================

void draw() {

  background(bg);

  calculateLayout();

  drawHeader();
  drawButtons();
  drawGraphPanel();
  drawRightPanel();
  drawFooter();
}

// ================================================================
// HEADER
// ================================================================

void drawHeader() {

  fill(white);
  textAlign(LEFT, CENTER);
  textSize(height * 0.035f);

  text("ADVANCED NUMERICAL ROOT FINDING LAB",
       width * 0.035f,
       height * 0.055f);

  fill(cyan);
  textSize(height * 0.019f);

  text("Bisection | Secant | Newton-Raphson | Sign Analysis",
       width * 0.035f,
       height * 0.115f);

  stroke(gridColor);
  strokeWeight(1);

  line(0, height * 0.15f,
       width, height * 0.15f);
}

// ================================================================
// BUTTONS
// ================================================================

float buttonY() {
  return height * 0.18f;
}

float buttonH() {
  return height * 0.075f;
}

float buttonW() {
  return width * 0.175f;
}

float buttonGap() {
  return width * 0.012f;
}

float buttonStart() {
  return width * 0.035f;
}

float buttonPosition(int index) {
  return buttonStart() + index * (buttonW() + buttonGap());
}

void drawButtons() {

  float y = buttonY();
  float h = buttonH();
  float w = buttonW();

  drawButton("BISECTION",
             buttonPosition(0), y, w, h,
             selectedMethod == 0 ? cyan : panel);

  drawButton("SECANT",
             buttonPosition(1), y, w, h,
             selectedMethod == 1 ? cyan : panel);

  drawButton("NEWTON",
             buttonPosition(2), y, w, h,
             selectedMethod == 2 ? cyan : panel);

  drawButton("NEW POLYNOMIAL",
             buttonPosition(3), y, w, h,
             yellow);

  drawButton("SOLVE",
             buttonPosition(4), y, w, h,
             green);
}

void drawButton(String label,
                float x, float y,
                float w, float h,
                int c) {

  noStroke();
  fill(c);
  rect(x, y, w, h, 9);

  if (c == cyan || c == yellow || c == green) {
    fill(bg);
  } else {
    fill(white);
  }

  textAlign(CENTER, CENTER);
  textSize(height * 0.018f);

  text(label, x + w/2, y + h/2);
}

// ================================================================
// GRAPH PANEL
// ================================================================

void drawGraphPanel() {

  noStroke();
  fill(panel);

  rect(plotX - 12,
       plotY - 12,
       plotW + 24,
       plotH + 40,
       12);

  drawGrid();
  drawAxes();
  drawSignRegions();
  drawFunction();

  if (approximationAvailable) {
    drawApproximation();
  }

  if (solved) {
    drawRootMarker();
  }

  drawGraphLabels();
}

// ================================================================
// GRID
// ================================================================

void drawGrid() {

  stroke(gridColor);
  strokeWeight(1);

  // Vertical grid lines.

  for (int i = 0; i <= 10; i++) {

    float gx = plotX + plotW * i / 10.0f;

    line(gx, plotY,
         gx, plotY + plotH);
  }

  // Horizontal grid lines.

  for (int j = 0; j <= 8; j++) {

    float gy = plotY + plotH * j / 8.0f;

    line(plotX, gy,
         plotX + plotW, gy);
  }
}

// ================================================================
// COORDINATE CONVERSION
// ================================================================

float screenX(float x) {

  return map(x,
             graphMinX,
             graphMaxX,
             plotX,
             plotX + plotW);
}

float screenY(float y) {

  return map(y,
             graphMinY,
             graphMaxY,
             plotY + plotH,
             plotY);
}

// ================================================================
// AXES AND LABELS
// ================================================================

void drawAxes() {

  float zeroX = screenX(0);
  float zeroY = screenY(0);

  stroke(muted);
  strokeWeight(2);

  if (zeroX >= plotX &&
      zeroX <= plotX + plotW) {

    line(zeroX, plotY,
         zeroX, plotY + plotH);
  }

  if (zeroY >= plotY &&
      zeroY <= plotY + plotH) {

    line(plotX, zeroY,
         plotX + plotW, zeroY);
  }

  fill(muted);
  textSize(height * 0.014f);
  textAlign(CENTER, TOP);

  for (int i = 0; i <= 10; i++) {

    float xv = graphMinX +
      (graphMaxX - graphMinX) * i / 10.0f;

    float px = plotX + plotW * i / 10.0f;

    text(nf(xv, 0, 1),
         px,
         plotY + plotH + 5);
  }
}

void drawGraphLabels() {

  fill(cyan);
  textAlign(LEFT, TOP);
  textSize(height * 0.017f);

  text("f(x)", plotX + 8, plotY + 5);

  fill(yellow);

  text("x", plotX + plotW - 15,
       plotY + plotH + 5);
}

// ================================================================
// SIGN REGIONS
// ================================================================

void drawSignRegions() {

  float zeroY = screenY(0);

  if (zeroY < plotY ||
      zeroY > plotY + plotH) {
    return;
  }

  textAlign(CENTER, CENTER);
  textSize(height * 0.017f);

  for (int i = 0; i < 10; i++) {

    float xa = graphMinX +
      (graphMaxX - graphMinX) * i / 10.0f;

    float xb = graphMinX +
      (graphMaxX - graphMinX) * (i + 1) / 10.0f;

    float mid = (xa + xb) / 2.0f;

    float fy = functionValue(mid);

    float px = screenX(mid);

    if (fy > 0) {

      fill(green);
      text("+", px, zeroY - 15);

    } else if (fy < 0) {

      fill(red);
      text("−", px, zeroY + 15);

    }
  }
}

// ================================================================
// POLYNOMIAL GRAPH
// ================================================================

void drawFunction() {

  stroke(cyan);
  strokeWeight(3);
  noFill();

  boolean drawing = false;

  beginShape();

  for (int i = 0; i <= 500; i++) {

    float x = graphMinX +
      (graphMaxX - graphMinX) * i / 500.0f;

    float y = functionValue(x);

    if (Float.isNaN(y) ||
        Float.isInfinite(y) ||
        abs(y) > 100000) {

      if (drawing) {
        endShape();
        beginShape();
        drawing = false;
      }

      continue;
    }

    float px = screenX(x);
    float py = screenY(y);

    if (py < plotY - plotH * 5 ||
        py > plotY + plotH * 5) {

      if (drawing) {
        endShape();
        beginShape();
        drawing = false;
      }

      continue;
    }

    vertex(px, py);
    drawing = true;
  }

  endShape();
}

// ================================================================
// APPROXIMATION LINES
// ================================================================

void drawApproximation() {

  // BISECTION: draw bracket and midpoint.

  if (selectedMethod == 0) {

    float xa = screenX(bracketA);
    float xb = screenX(bracketB);
    float zeroY = screenY(0);

    stroke(yellow);
    strokeWeight(3);

    line(xa, plotY,
         xa, plotY + plotH);

    line(xb, plotY,
         xb, plotY + plotH);

    fill(yellow);
    noStroke();

    ellipse(screenX(root), zeroY, 13, 13);
  }

  // SECANT: straight-line approximation.

  if (selectedMethod == 1) {

    drawLineSegment(
      approximationX1,
      approximationY1,
      approximationX2,
      approximationY2,
      yellow
    );

    drawPoint(approximationX1,
              approximationY1,
              yellow);

    drawPoint(approximationX2,
              approximationY2,
              yellow);
  }

  // NEWTON: tangent line approximation.

  if (selectedMethod == 2) {

    float x1 = graphMinX;
    float x2 = graphMaxX;

    float y1 = tangentY +
      tangentSlope * (x1 - tangentX);

    float y2 = tangentY +
      tangentSlope * (x2 - tangentX);

    drawLineSegment(x1, y1, x2, y2, yellow);

    drawPoint(tangentX, tangentY, purple);
  }
}

void drawLineSegment(float x1, float y1,
                     float x2, float y2,
                     int c) {

  float sx1 = screenX(x1);
  float sy1 = screenY(y1);

  float sx2 = screenX(x2);
  float sy2 = screenY(y2);

  stroke(c);
  strokeWeight(2);

  line(sx1, sy1, sx2, sy2);
}

void drawPoint(float x, float y, int c) {

  float px = screenX(x);
  float py = screenY(y);

  noStroke();
  fill(c);

  ellipse(px, py, 11, 11);
}

// ================================================================
// ROOT MARKER
// ================================================================

void drawRootMarker() {

  float px = screenX(root);
  float py = screenY(0);

  if (px >= plotX && px <= plotX + plotW) {

    stroke(green);
    strokeWeight(2);

    line(px, plotY,
         px, plotY + plotH);

    noStroke();
    fill(green);

    ellipse(px, py, 17, 17);
  }
}

// ================================================================
// RIGHT INFORMATION PANEL
// ================================================================

void drawRightPanel() {

  float x = width * 0.68f;
  float y = height * 0.275f;
  float w = width * 0.285f;
  float h = height * 0.55f;

  noStroke();
  fill(panel);

  rect(x, y, w, h, 12);

  drawAnalysis(x, y, w);
  drawIterationTable(x, y, w);
}

// ================================================================
// ANALYSIS INFORMATION
// ================================================================

void drawAnalysis(float x, float y, float w) {

  fill(white);
  textAlign(LEFT, CENTER);
  textSize(height * 0.022f);

  text("POLYNOMIAL ANALYSIS",
       x + 12, y + 19);

  fill(cyan);
  textSize(height * 0.019f);

  text(equationText,
       x + 12, y + 47);

  fill(muted);
  textSize(height * 0.016f);

  text("METHOD: " + methodName(),
       x + 12, y + 76);

  fill(green);

  text("ROOT: " + nf(root, 0, 6),
       x + 12, y + 101);

  fill(white);

  text("f(root): " +
       nf(functionValue(root), 0, 6),
       x + 12, y + 126);

  fill(yellow);

  text("STATUS: " + statusText,
       x + 12, y + 151);

  drawDescartesSigns(x, y, w);
}

// ================================================================
// DESCARTES SIGN TABLE
// ================================================================

void drawDescartesSigns(float x, float y, float w) {

  float top = y + 174;

  fill(cyan);
  textSize(height * 0.017f);
  textAlign(LEFT, CENTER);

  text("DESCARTES RULE OF SIGNS",
       x + 12, top);

  String positive = coefficientSignString(false);
  String negative = coefficientSignString(true);

  fill(white);
  textSize(height * 0.015f);

  text("f(x):  " + positive,
       x + 12, top + 24);

  fill(yellow);

  text("Changes: " + signChanges(false) +
       "  (positive roots maximum)",
       x + 12, top + 46);

  fill(white);

  text("f(-x): " + negative,
       x + 12, top + 68);

  fill(yellow);

  text("Changes: " + signChanges(true) +
       "  (negative roots maximum)",
       x + 12, top + 90);
}

String coefficientSignString(boolean negative) {

  String result = "";

  for (int i = degree; i >= 0; i--) {

    float c = coeff[i];

    if (negative && i % 2 == 1) {
      c = -c;
    }

    if (abs(c) < 0.0001f) {
      continue;
    }

    if (c > 0) {
      result += "+ ";
    } else {
      result += "− ";
    }
  }

  return result;
}

int signChanges(boolean negative) {

  int changes = 0;
  int previous = 0;

  for (int i = degree; i >= 0; i--) {

    float c = coeff[i];

    if (negative && i % 2 == 1) {
      c = -c;
    }

    if (abs(c) < 0.0001f) {
      continue;
    }

    int current = c > 0 ? 1 : -1;

    if (previous != 0 &&
        current != previous) {
      changes++;
    }

    previous = current;
  }

  return changes;
}

// ================================================================
// ITERATION TABLE
// ================================================================

void drawIterationTable(float x, float y, float w) {

  float top = y + height * 0.36f;

  stroke(gridColor);
  strokeWeight(1);

  line(x + 10, top - 12,
       x + w - 10, top - 12);

  fill(cyan);
  textAlign(LEFT, CENTER);
  textSize(height * 0.018f);

  text("ITERATION TABLE",
       x + 12, top);

  float headerY = top + 25;

  fill(muted);
  textSize(height * 0.0135f);

  text("n", x + 12, headerY);
  text("x(n)", x + 48, headerY);
  text("f(x)", x + 112, headerY);
  text("ERROR", x + 178, headerY);
  text("SIGN", x + w - 55, headerY);

  stroke(gridColor);

  line(x + 10, headerY + 12,
       x + w - 10, headerY + 12);

  int visibleRows = 5;
  int first = max(0, tableCount - visibleRows);

  for (int i = first; i < tableCount; i++) {

    int row = i - first;

    float ry = headerY + 31 + row * height * 0.031f;

    fill(white);
    textSize(height * 0.0135f);

    text(str(i + 1), x + 12, ry);

    text(nf(tableX[i], 0, 3),
         x + 48, ry);

    float fy = tableFX[i];

    if (fy > 0) {
      fill(green);
    } else if (fy < 0) {
      fill(red);
    } else {
      fill(yellow);
    }

    text(nf(fy, 0, 3),
         x + 112, ry);

    fill(white);

    text(nf(tableError[i], 0, 4),
         x + 178, ry);

    if (tableSign[i].equals("+")) {
      fill(green);
    } else if (tableSign[i].equals("−")) {
      fill(red);
    } else {
      fill(yellow);
    }

    text(tableSign[i],
         x + w - 55, ry);
  }

  if (tableCount == 0) {

    fill(muted);
    textSize(height * 0.015f);

    text("Press SOLVE to populate the table.",
         x + 12, headerY + 43);
  }
}

// ================================================================
// FOOTER
// ================================================================

void drawFooter() {

  fill(muted);
  textAlign(LEFT, CENTER);
  textSize(height * 0.016f);

  text("CYAN: f(x)   YELLOW: approximation line   GREEN: positive   RED: negative",
       width * 0.035f,
       height * 0.94f);
}

// ================================================================
// POLYNOMIAL GENERATION
// ================================================================

void generatePolynomial() {

  // Construct a polynomial from known real roots.
  // This helps create useful real-root examples.

  for (int i = 0; i < coeff.length; i++) {
    coeff[i] = 0;
  }

  coeff[0] = 1;
  degree = 0;

  int numberRoots = int(random(2, 4));

  for (int r = 0; r < numberRoots; r++) {

    float newRoot = random(-3.0f, 3.0f);

    float[] next = new float[8];

    for (int i = 0; i <= degree; i++) {

      next[i] += -newRoot * coeff[i];
      next[i + 1] += coeff[i];
    }

    degree++;

    for (int i = 0; i < coeff.length; i++) {
      coeff[i] = next[i];
    }
  }

  // Scale the polynomial moderately.

  float scale = random(0.7f, 1.5f);

  for (int i = 0; i <= degree; i++) {
    coeff[i] *= scale;
  }

  equationText = makeEquation();

  resetSolution();

  graphMinX = -5;
  graphMaxX = 5;
  graphMinY = -8;
  graphMaxY = 8;

  statusText = "NEW POLYNOMIAL";
}

void resetSolution() {

  solved = false;
  bracketFound = false;
  approximationAvailable = false;

  iteration = 0;
  tableCount = 0;

  root = 0;

  statusText = "READY";
}

// ================================================================
// EQUATION FORMATTING
// ================================================================

String makeEquation() {

  String s = "";

  for (int i = degree; i >= 0; i--) {

    float c = coeff[i];

    if (abs(c) < 0.0001f) {
      continue;
    }

    if (s.length() > 0) {

      if (c >= 0) {
        s += " + ";
      } else {
        s += " − ";
      }

    } else if (c < 0) {

      s += "−";
    }

    s += nf(abs(c), 0, 2);

    if (i == 1) {
      s += "x";
    } else if (i > 1) {
      s += "x^" + i;
    }
  }

  return s + " = 0";
}

// ================================================================
// FUNCTION EVALUATION - HORNER'S METHOD
// ================================================================

float functionValue(float x) {

  float result = 0;

  for (int i = degree; i >= 0; i--) {
    result = result * x + coeff[i];
  }

  return result;
}

// ================================================================
// FIRST DERIVATIVE
// ================================================================

float derivativeValue(float x) {

  float result = 0;

  for (int i = degree; i >= 1; i--) {
    result = result * x + i * coeff[i];
  }

  return result;
}

// ================================================================
// SECOND DERIVATIVE
// ================================================================

float secondDerivativeValue(float x) {

  float result = 0;

  for (int i = degree; i >= 2; i--) {
    result = result * x +
      i * (i - 1) * coeff[i];
  }

  return result;
}

// ================================================================
// STORE TABLE ROW
// ================================================================

void addTableRow(float x,
                 float error,
                 float a,
                 float b) {

  if (tableCount >= 100) {
    return;
  }

  float fx = functionValue(x);

  tableX[tableCount] = x;
  tableFX[tableCount] = fx;
  tableError[tableCount] = abs(error);

  tableA[tableCount] = a;
  tableB[tableCount] = b;

  if (fx > 0.0000001f) {
    tableSign[tableCount] = "+";
  } else if (fx < -0.0000001f) {
    tableSign[tableCount] = "−";
  } else {
    tableSign[tableCount] = "0";
  }

  tableCount++;
}

// ================================================================
// FIND SIGN-CHANGING BRACKET
// ================================================================

boolean findBracket() {

  float previousX = graphMinX;
  float previousY = functionValue(previousX);

  for (int i = 1; i <= 1000; i++) {

    float x = graphMinX +
      (graphMaxX - graphMinX) * i / 1000.0f;

    float y = functionValue(x);

    if (abs(previousY) < 0.000001f) {

      bracketA = previousX;
      bracketB = previousX;

      return true;
    }

    if (previousY * y < 0) {

      bracketA = previousX;
      bracketB = x;

      return true;
    }

    previousX = x;
    previousY = y;
  }

  return false;
}

// ================================================================
// SOLVE
// ================================================================

void solve() {

  resetSolution();

  statusText = "CALCULATING";

  if (selectedMethod == 0) {
    solveBisection();
  } else if (selectedMethod == 1) {
    solveSecant();
  } else {
    solveNewton();
  }
}

// ================================================================
// BISECTION METHOD
// ================================================================

void solveBisection() {

  if (!findBracket()) {

    statusText = "NO SIGN CHANGE";
    return;
  }

  float a = bracketA;
  float b = bracketB;

  float fa = functionValue(a);
  float fb = functionValue(b);

  bracketFound = true;

  if (abs(fa) < 0.000001f) {

    root = a;
    solved = true;
    statusText = "EXACT ROOT";
    return;
  }

  if (abs(fb) < 0.000001f) {

    root = b;
    solved = true;
    statusText = "EXACT ROOT";
    return;
  }

  for (int i = 0; i < maxIterations; i++) {

    float previous = root;

    float c = (a + b) / 2.0f;
    float fc = functionValue(c);

    root = c;
    iteration = i + 1;

    float error = i == 0 ? b - a : root - previous;

    bracketA = a;
    bracketB = b;

    addTableRow(c, error, a, b);

    approximationAvailable = true;

    if (abs(fc) < 0.000001f ||
        abs(b - a) < 0.000001f) {

      solved = true;
      statusText = "CONVERGED";
      return;
    }

    if (fa * fc < 0) {

      b = c;
      fb = fc;

    } else {

      a = c;
      fa = fc;
    }
  }

  solved = true;
  statusText = "MAX ITERATIONS";
}

// ================================================================
// SECANT METHOD
// ================================================================

void solveSecant() {

  if (!findBracket()) {

    statusText = "NO SIGN CHANGE";
    return;
  }

  float a = bracketA;
  float b = bracketB;

  float fa = functionValue(a);
  float fb = functionValue(b);

  approximationX1 = a;
  approximationY1 = fa;

  approximationX2 = b;
  approximationY2 = fb;

  for (int i = 0; i < maxIterations; i++) {

    float denominator = fb - fa;

    if (abs(denominator) < 0.0000001f) {

      statusText = "ZERO DENOMINATOR";
      return;
    }

    float c = b - fb * (b - a) / denominator;

    if (Float.isNaN(c) ||
        Float.isInfinite(c) ||
        abs(c) > 100000) {

      statusText = "DIVERGED";
      return;
    }

    float fc = functionValue(c);

    root = c;
    iteration = i + 1;

    approximationX1 = a;
    approximationY1 = fa;

    approximationX2 = b;
    approximationY2 = fb;

    approximationAvailable = true;

    addTableRow(c, c - b, a, b);

    if (abs(fc) < 0.000001f) {

      solved = true;
      statusText = "CONVERGED";
      return;
    }

    a = b;
    fa = fb;

    b = c;
    fb = fc;
  }

  solved = true;
  statusText = "MAX ITERATIONS";
}

// ================================================================
// NEWTON-RAPHSON METHOD
// ================================================================

void solveNewton() {

  if (!findBracket()) {

    statusText = "NO SIGN CHANGE";
    return;
  }

  float a = bracketA;
  float b = bracketB;

  float x = (a + b) / 2.0f;

  for (int i = 0; i < maxIterations; i++) {

    float fx = functionValue(x);
    float dfx = derivativeValue(x);

    if (abs(dfx) < 0.0000001f) {

      statusText = "DERIVATIVE ZERO";
      return;
    }

    float nextX = x - fx / dfx;

    if (Float.isNaN(nextX) ||
        Float.isInfinite(nextX) ||
        abs(nextX) > 100000) {

      statusText = "DIVERGED";
      return;
    }

    float nextY = functionValue(nextX);

    tangentX = x;
    tangentY = fx;
    tangentSlope = dfx;

    approximationAvailable = true;

    root = nextX;
    iteration = i + 1;

    addTableRow(nextX, nextX - x, a, b);

    if (abs(nextY) < 0.000001f ||
        abs(nextX - x) < 0.000001f) {

      solved = true;
      statusText = "CONVERGED";
      return;
    }

    x = nextX;
  }

  solved = true;
  statusText = "MAX ITERATIONS";
}

// ================================================================
// METHOD NAME
// ================================================================

String methodName() {

  if (selectedMethod == 0) {
    return "BISECTION";
  }

  if (selectedMethod == 1) {
    return "SECANT";
  }

  return "NEWTON-RAPHSON";
}

// ================================================================
// TOUCH CONTROL
// ================================================================

void mousePressed() {

  float y = buttonY();
  float h = buttonH();
  float w = buttonW();

  for (int i = 0; i < 3; i++) {

    float x = buttonPosition(i);

    if (mouseX >= x &&
        mouseX <= x + w &&
        mouseY >= y &&
        mouseY <= y + h) {

      selectedMethod = i;

      resetSolution();

      statusText = "METHOD SELECTED";

      return;
    }
  }

  float generateX = buttonPosition(3);

  if (mouseX >= generateX &&
      mouseX <= generateX + w &&
      mouseY >= y &&
      mouseY <= y + h) {

    generatePolynomial();

    return;
  }

  float solveX = buttonPosition(4);

  if (mouseX >= solveX &&
      mouseX <= solveX + w &&
      mouseY >= y &&
      mouseY <= y + h) {

    solve();

    return;
  }
}

// ================================================================
// END OF SKETCH
// ================================================================
