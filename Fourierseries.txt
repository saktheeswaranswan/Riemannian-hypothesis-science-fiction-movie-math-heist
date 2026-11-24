
int harmonics = 5;
int maxHarmonics = 25;

float leftX, rightX;
float plotTop, plotBottom;

boolean showComponents = true;
boolean showOriginal = true;
boolean showCoefficients = true;

int bg = 0xFF101827;
int cyan = 0xFF35D6E8;
int yellow = 0xFFFFCA58;
int green = 0xFF62E6A5;
int white = 0xFFF0F4FA;

void setup() {
  fullScreen();
  smooth(4);

  textAlign(LEFT, CENTER);
  textSize(18);

  leftX = width * 0.06;
  rightX = width * 0.96;

  plotTop = height * 0.30;
  plotBottom = height * 0.72;
}

void draw() {
  background(bg);

  leftX = width * 0.06;
  rightX = width * 0.96;

  plotTop = height * 0.30;
  plotBottom = height * 0.72;

  drawHeader();
  drawGraph();
  drawControls();
  drawInformation();
}

// ---------------------------------
// FOURIER MATHEMATICS
// ---------------------------------

float squareWave(float x) {
  return sin(x) >= 0 ? 1 : -1;
}

float fourier(float x) {
  float sum = 0;

  for (int n = 1; n <= harmonics; n++) {
    if (n % 2 == 1) {
      sum += 4.0 / (PI * n) * sin(n * x);
    }
  }

  return sum;
}

float harmonic(float x, int n) {
  if (n % 2 == 0) {
    return 0;
  }

  return 4.0 / (PI * n) * sin(n * x);
}

float mapGraphX(float x) {
  return map(x, -PI, PI, leftX, rightX);
}

float mapGraphY(float y) {
  return map(y, -1.5, 1.5, plotBottom, plotTop);
}

// ---------------------------------
// HEADER
// ---------------------------------

void drawHeader() {
  fill(cyan);
  textSize(height * 0.035);

  text("FOURIER SERIES LAB",
       leftX, height * 0.06);

  fill(white);
  textSize(height * 0.019);

  text("Square Wave Reconstruction",
       leftX, height * 0.12);

  fill(yellow);

  text("N = " + harmonics,
       width * 0.82, height * 0.07);

  fill(green);
  textSize(height * 0.017);

  text("f(x) = 4/pi [sin(x) + sin(3x)/3 + sin(5x)/5 ...]",
       leftX, height * 0.21);
}

// ---------------------------------
// GRAPH
// ---------------------------------

void drawGraph() {

  // Grid
  stroke(0xFF35445A);
  strokeWeight(1);

  for (int i = -1; i <= 1; i++) {
    float y = mapGraphY(i);
    line(leftX, y, rightX, y);
  }

  for (int i = -2; i <= 2; i++) {
    float x = mapGraphX(i * PI / 2.0);
    line(x, plotTop, x, plotBottom);
  }

  // Axes
  stroke(white);
  strokeWeight(2);

  line(leftX, mapGraphY(0),
       rightX, mapGraphY(0));

  line(mapGraphX(0), plotTop,
       mapGraphX(0), plotBottom);

  // Original square wave
  if (showOriginal) {
    stroke(yellow);
    strokeWeight(2.5);
    noFill();

    beginShape();

    for (int i = 0; i <= 500; i++) {
      float x = map(i, 0, 500, -PI, PI);

      vertex(mapGraphX(x),
             mapGraphY(squareWave(x)));
    }

    endShape();
  }

  // Individual harmonics
  if (showComponents) {

    for (int n = 1; n <= harmonics; n += 2) {

      stroke(0xFF7186B5);
      strokeWeight(1.3);
      noFill();

      beginShape();

      for (int i = 0; i <= 400; i++) {
        float x = map(i, 0, 400, -PI, PI);

        vertex(mapGraphX(x),
               mapGraphY(harmonic(x, n)));
      }

      endShape();
    }
  }

  // Fourier sum
  stroke(cyan);
  strokeWeight(3);
  noFill();

  beginShape();

  for (int i = 0; i <= 600; i++) {
    float x = map(i, 0, 600, -PI, PI);

    vertex(mapGraphX(x),
           mapGraphY(fourier(x)));
  }

  endShape();

  // Axis labels
  fill(white);
  textSize(height * 0.018);

  text("-PI", mapGraphX(-PI), plotBottom + 18);
  text("0", mapGraphX(0), plotBottom + 18);
  text("+PI", mapGraphX(PI) - 20, plotBottom + 18);

  fill(yellow);
  text("Original", leftX, plotTop - 18);

  fill(cyan);
  text("Fourier approximation",
       leftX + 100, plotTop - 18);
}

// ---------------------------------
// BUTTONS
// ---------------------------------

void drawButton(float x, float y,
                float w, float h,
                String label) {

  fill(0xFF26374F);
  stroke(cyan);
  strokeWeight(1.5);

  rect(x, y, w, h, 10);

  fill(white);
  textAlign(CENTER, CENTER);
  textSize(height * 0.017);

  text(label, x + w / 2, y + h / 2);

  textAlign(LEFT, CENTER);
}

void drawControls() {

  float y = height * 0.79;
  float h = height * 0.075;

  drawButton(width * 0.05, y,
             width * 0.10, h, "-");

  drawButton(width * 0.17, y,
             width * 0.10, h, "+");

  drawButton(width * 0.32, y,
             width * 0.19, h,
             showComponents ? "Components ON" : "Components OFF");

  drawButton(width * 0.55, y,
             width * 0.17, h,
             showOriginal ? "Square ON" : "Square OFF");

  drawButton(width * 0.76, y,
             width * 0.19, h,
             showCoefficients ? "Coefficients ON" : "Coefficients OFF");
}

// ---------------------------------
// COEFFICIENT DISPLAY
// ---------------------------------

void drawInformation() {

  if (!showCoefficients) return;

  float y = height * 0.91;

  fill(green);
  textSize(height * 0.018);

  text("a0 = 0       an = 0",
       leftX, y);

  fill(white);

  String result = "bn: ";

  for (int n = 1; n <= min(harmonics, 15); n++) {

    float b = 0;

    if (n % 2 == 1) {
      b = 4.0 / (n * PI);
    }

    result += "b" + n + "=" +
              nf(b, 1, 3) + "   ";
  }

  textSize(height * 0.014);
  text(result, leftX, height * 0.96);

  fill(yellow);
  textSize(height * 0.016);

  text("ODD SYMMETRY: f(-x) = -f(x)",
       width * 0.65, height * 0.96);
}

// ---------------------------------
// TOUCH INPUT
// ---------------------------------

void mousePressed() {

  float y = height * 0.79;
  float h = height * 0.075;

  if (mouseY < y || mouseY > y + h) {
    return;
  }

  if (mouseX > width * 0.05 &&
      mouseX < width * 0.15) {

    harmonics = max(1, harmonics - 1);
  }

  else if (mouseX > width * 0.17 &&
           mouseX < width * 0.27) {

    harmonics = min(maxHarmonics, harmonics + 1);
  }

  else if (mouseX > width * 0.32 &&
           mouseX < width * 0.51) {

    showComponents = !showComponents;
  }

  else if (mouseX > width * 0.55 &&
           mouseX < width * 0.72) {

    showOriginal = !showOriginal;
  }

  else if (mouseX > width * 0.76 &&
           mouseX < width * 0.95) {

    showCoefficients = !showCoefficients;
  }
}
