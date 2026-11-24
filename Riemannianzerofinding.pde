// ============================================================================
// RIEMANN CRITICAL LINE & FOURIER PRIME STAIRCASE VISUALIZER (APDE ANDROID)
// Plots Re(s) = 1/2, first 50 Riemann zeros as Fourier cosine waves,
// conformal map w = e^s, and Chebyshev prime-counting staircase psi(x).
// ============================================================================

// First 50 non-trivial Riemann zeta zeros: s_k = 0.5 + i * gamma_k
final double[] RIEMANN_ZEROS = {
  14.134725142, 21.022039639, 25.010857580, 30.424876126, 32.935061588,
  37.586178159, 40.918719012, 43.327073281, 48.005150881, 49.773832478,
  52.970321478, 56.446247697, 59.347044003, 60.831778525, 65.112544048,
  67.079810529, 69.546401711, 72.067157674, 75.704690699, 77.144840069,
  79.337375020, 82.910380854, 84.735492981, 87.425274613, 88.809111208,
  92.491899271, 94.651344041, 95.870634228, 98.831194218, 101.317851006,
  103.725538040, 105.446623052, 107.168611184, 111.029535543, 111.874659177,
  114.320220915, 116.226680321, 118.790782866, 121.370125002, 122.946829294,
  124.256818554, 127.516683880, 129.578704200, 131.087688531, 133.497737203,
  134.756509753, 138.116042055, 139.736208952, 141.123707404, 143.111845808
};

double[] zeroModulus = new double[50];
double[] zeroPhase = new double[50];

// Interactive state
int numZeros = 12;
int xMax = 35;
boolean playing = false;
int stepIntervalMs = 260;
int lastStepTime = 0;

boolean showExact = true;
boolean showSpikes = true;
boolean showConformal = false;

int selectedZeroIdx = -1;
float inspectX = -1;
float pulsePhase = 0;
boolean draggingSlider = false;
boolean scrubbingStaircase = false;

// Screen coordinates for tap detection on plotted zeros
float[] zeroScreenX = new float[50];
float[] zeroScreenY = new float[50];

// Layout boxes (computed dynamically for portrait or landscape)
float headerH, controlH;
float leftX, leftY, leftW, leftH;
float topRightX, topRightY, topRightW, topRightH;
float botRightX, botRightY, botRightW, botRightH;

// UI Touch Control rectangles: [x, y, w, h]
float[] btnPlayRect = new float[4];
float[] btnResetRect = new float[4];
float[] btnMinusRect = new float[4];
float[] sliderRect = new float[4];
float[] btnPlusRect = new float[4];
float[] btnDomainRect = new float[4];
float[] btnExactRect = new float[4];
float[] btnSpikesRect = new float[4];
float[] btnMapRect = new float[4];

// Color Palette
int colBgPrimary = color(6, 10, 18);
int colBgPanel   = color(13, 20, 36);
int colBgCtrl    = color(19, 28, 49);
int colBorder    = color(31, 45, 74);
int colTextMain  = color(226, 232, 240);
int colTextMuted = color(148, 163, 184);
int colGold      = color(251, 191, 36);
int colCyan      = color(56, 189, 248);
int colEmerald   = color(16, 185, 129);
int colRose      = color(244, 63, 94);
int colViolet    = color(167, 139, 250);

void setup() {
  fullScreen();
  smooth(4);
  for (int k = 0; k < 50; k++) {
    double g = RIEMANN_ZEROS[k];
    zeroModulus[k] = Math.hypot(0.5, g);
    zeroPhase[k] = Math.atan2(g, 0.5);
  }
}

void draw() {
  background(colBgPrimary);
  pulsePhase += 0.08;

  if (playing && millis() - lastStepTime >= stepIntervalMs) {
    lastStepTime = millis();
    if (numZeros < 50) {
      numZeros++;
      selectedZeroIdx = -1;
    } else {
      playing = false;
    }
  }

  computeLayout();
  drawHeaderAndControls();
  drawZetaPanel();
  drawWavePanel();
  drawStaircasePanel();
}

// ============================================================================
// 1. RESPONSIVE LAYOUT (ADAPTS AUTOMATICALLY TO PORTRAIT OR LANDSCAPE)
// ============================================================================
void computeLayout() {
  float pad = max(8, min(width, height) * 0.012);
  boolean isLandscape = width > height;

  headerH = isLandscape ? max(44, height * 0.065) : max(52, height * 0.055);
  controlH = isLandscape ? max(46, height * 0.07) : max(74, height * 0.08);

  float workY = headerH + controlH + pad;
  float workH = height - workY - pad;
  float workW = width - 2 * pad;

  if (isLandscape) {
    leftW = workW * 0.34;
    leftX = pad;
    leftY = workY;
    leftH = workH;

    float rightX = leftX + leftW + pad;
    float rightW = workW - leftW - pad;

    topRightX = rightX;
    topRightY = workY;
    topRightW = rightW;
    topRightH = (workH - pad) * 0.38;

    botRightX = rightX;
    botRightY = topRightY + topRightH + pad;
    botRightW = rightW;
    botRightH = workH - topRightH - pad;
  } else {
    leftX = pad;
    leftY = workY;
    leftW = workW;
    leftH = (workH - 2 * pad) * 0.34;

    topRightX = pad;
    topRightY = leftY + leftH + pad;
    topRightW = workW;
    topRightH = (workH - 2 * pad) * 0.26;

    botRightX = pad;
    botRightY = topRightY + topRightH + pad;
    botRightW = workW;
    botRightH = workH - leftH - topRightH - 2 * pad;
  }

  // Compute Touch Button Rectangles
  float cx = pad;
  float cy = headerH + 6;
  float bh = isLandscape ? controlH - 12 : (controlH - 18) * 0.5;
  float gap = 6;

  if (isLandscape) {
    float unit = (width - 2 * pad - 8 * gap) / 15.5;
    setRect(btnPlayRect,   cx, cy, unit * 2.1, bh); cx += unit * 2.1 + gap;
    setRect(btnResetRect,  cx, cy, unit * 1.4, bh); cx += unit * 1.4 + gap;
    setRect(btnMinusRect,  cx, cy, unit * 0.9, bh); cx += unit * 0.9 + gap;
    setRect(sliderRect,    cx, cy, unit * 3.8, bh); cx += unit * 3.8 + gap;
    setRect(btnPlusRect,   cx, cy, unit * 0.9, bh); cx += unit * 0.9 + gap;
    setRect(btnDomainRect, cx, cy, unit * 1.6, bh); cx += unit * 1.6 + gap;
    setRect(btnExactRect,  cx, cy, unit * 1.5, bh); cx += unit * 1.5 + gap;
    setRect(btnSpikesRect, cx, cy, unit * 1.6, bh); cx += unit * 1.6 + gap;
    setRect(btnMapRect,    cx, cy, unit * 1.7, bh);
  } else {
    // Row 1 of controls (Portrait)
    float r1Unit = (width - 2 * pad - 4 * gap) / 8.8;
    setRect(btnPlayRect,  cx, cy, r1Unit * 2.3, bh); cx += r1Unit * 2.3 + gap;
    setRect(btnResetRect, cx, cy, r1Unit * 1.4, bh); cx += r1Unit * 1.4 + gap;
    setRect(btnMinusRect, cx, cy, r1Unit * 0.9, bh); cx += r1Unit * 0.9 + gap;
    setRect(sliderRect,   cx, cy, r1Unit * 3.3, bh); cx += r1Unit * 3.3 + gap;
    setRect(btnPlusRect,  cx, cy, r1Unit * 0.9, bh);

    // Row 2 of controls (Portrait)
    cx = pad;
    float cy2 = cy + bh + 6;
    float r2Unit = (width - 2 * pad - 3 * gap) / 4.0;
    setRect(btnDomainRect, cx, cy2, r2Unit, bh); cx += r2Unit + gap;
    setRect(btnExactRect,  cx, cy2, r2Unit, bh); cx += r2Unit + gap;
    setRect(btnSpikesRect, cx, cy2, r2Unit, bh); cx += r2Unit + gap;
    setRect(btnMapRect,    cx, cy2, r2Unit, bh);
  }
}

void setRect(float[] r, float x, float y, float w, float h) {
  r[0] = x; r[1] = y; r[2] = w; r[3] = h;
}

boolean inRect(float px, float py, float[] r) {
  return px >= r[0] && px <= r[0] + r[2] && py >= r[1] && py <= r[1] + r[3];
}

// ============================================================================
// 2. HEADER & TOUCH CONTROLS BAR
// ============================================================================
void drawHeaderAndControls() {
  // Header Bar
  fill(11, 18, 33);
  noStroke();
  rect(0, 0, width, headerH);
  stroke(colBorder);
  line(0, headerH, width, headerH);

  float titleSize = constrain(min(width, height) * 0.023, 13, 21);
  textSize(titleSize);
  textAlign(LEFT, CENTER);
  fill(248, 250, 252);
  text("Riemann Critical Line & ", 14, headerH * 0.36);
  float tw = textWidth("Riemann Critical Line & ");
  fill(colGold);
  text("Fourier Prime Staircase Lab", 14 + tw, headerH * 0.36);

  textSize(max(10, titleSize * 0.68));
  fill(colCyan);
  text("ψ_N(x) = x - Σ (2√x / |ρ_k|) cos(γ_k ln x - θ_k) - ln(2π)", 14, headerH * 0.74);

  // Controls Background
  fill(colBgPanel);
  noStroke();
  rect(0, headerH + 1, width, controlH);
  stroke(colBorder);
  line(0, headerH + controlH, width, headerH + controlH);

  // Buttons
  drawButton(btnPlayRect, playing ? "PAUSE" : "PLAY ZEROS", true, playing);
  drawButton(btnResetRect, "RESET", false, false);
  drawButton(btnMinusRect, "-", false, false);
  drawButton(btnPlusRect, "+", false, false);
  drawButton(btnDomainRect, "x <= " + xMax, false, false);
  drawButton(btnExactRect, "Exact ψ(x)", false, showExact);
  drawButton(btnSpikesRect, "Spikes ψ'", false, showSpikes);
  drawButton(btnMapRect, showConformal ? "Line Re=1/2" : "w = e^s Map", false, showConformal);

  // Slider Track & Knob
  fill(colBgCtrl);
  stroke(colBorder);
  rect(sliderRect[0], sliderRect[1], sliderRect[2], sliderRect[3], 6);

  float trackPad = 12;
  float tx0 = sliderRect[0] + trackPad;
  float tx1 = sliderRect[0] + sliderRect[2] - trackPad;
  float ty = sliderRect[1] + sliderRect[3] * 0.68;

  stroke(51, 65, 85);
  strokeWeight(3);
  line(tx0, ty, tx1, ty);

  float frac = numZeros / 50.0;
  float knobX = lerp(tx0, tx1, frac);
  stroke(colGold);
  line(tx0, ty, knobX, ty);

  noStroke();
  fill(colGold);
  ellipse(knobX, ty, 13, 13);

  textAlign(CENTER, TOP);
  textSize(max(10, sliderRect[3] * 0.28));
  fill(colGold);
  text("Zeros N = " + numZeros + " / 50", sliderRect[0] + sliderRect[2] * 0.5, sliderRect[1] + 3);
  textAlign(LEFT, BASELINE);
  strokeWeight(1);
}

void drawButton(float[] r, String label, boolean primary, boolean active) {
  if (primary) {
    fill(2, 132, 199);
    stroke(colCyan);
  } else if (active) {
    fill(66, 52, 22);
    stroke(colGold);
  } else {
    fill(30, 41, 59);
    stroke(51, 65, 85);
  }
  rect(r[0], r[1], r[2], r[3], 6);

  textAlign(CENTER, CENTER);
  textSize(constrain(r[3] * 0.34, 10, 15));
  fill(primary ? color(255) : (active ? colGold : colTextMain));
  text(label, r[0] + r[2] * 0.5, r[1] + r[3] * 0.5);
  textAlign(LEFT, BASELINE);
}

// ============================================================================
// 3. PANEL 1: CRITICAL LINE Re(s) = 1/2 (OR CONFORMAL MAP w = e^s)
// ============================================================================
void drawZetaPanel() {
  drawPanelFrame(leftX, leftY, leftW, leftH,
    showConformal ? "Conformal Map w = e^s (|w| = √e)" : "Critical Line Re(s) = 1/2",
    numZeros > 0 ? "γ_" + numZeros + " = " + nf((float)RIEMANN_ZEROS[numZeros - 1], 1, 4) : "N = 0",
    colGold);

  float headH = 26;
  float bx = leftX;
  float by = leftY + headH;
  float bw = leftW;
  float bh = leftH - headH;

  if (showConformal) {
    drawConformalMap(bx, by, bw, bh);
    return;
  }

  float padL = 42, padR = 18, padT = 20, padB = 26;
  float plotW = bw - padL - padR;
  float plotH = bh - padT - padB;

  float sigmaMin = -0.35;
  float sigmaMax = 1.35;
  float tMin = -6.0;
  float tMax = 150.0;

  // Critical Strip Shading: 0 < Re(s) < 1
  float x0 = bx + padL + ((0.0 - sigmaMin) / (sigmaMax - sigmaMin)) * plotW;
  float x1 = bx + padL + ((1.0 - sigmaMin) / (sigmaMax - sigmaMin)) * plotW;
  noStroke();
  fill(56, 189, 248, 16);
  rect(x0, by + padT, x1 - x0, plotH);

  // Horizontal Imaginary Axis Grid (0i to 150i)
  textSize(10);
  for (int t = 0; t <= 150; t += 25) {
    float py = by + padT + plotH - ((t - tMin) / (tMax - tMin)) * plotH;
    stroke(148, 163, 184, 30);
    line(bx + padL, py, bx + bw - padR, py);
    fill(colTextMuted);
    text(t + "i", bx + 8, py + 4);
  }

  // Real Axis (t = 0)
  float yZero = by + padT + plotH - ((0.0 - tMin) / (tMax - tMin)) * plotH;
  stroke(226, 232, 240, 90);
  line(bx + padL, yZero, bx + bw - padR, yZero);

  // Strip Boundaries Re(s) = 0 and Re(s) = 1
  stroke(56, 189, 248, 110);
  drawDashedVLine(x0, by + padT, by + padT + plotH, 4);
  drawDashedVLine(x1, by + padT, by + padT + plotH, 4);
  fill(colCyan);
  text("Re=0", x0 - 13, by + padT - 5);
  text("Re=1", x1 - 13, by + padT - 5);

  // Critical Line Re(s) = 1/2
  float xHalf = bx + padL + ((0.5 - sigmaMin) / (sigmaMax - sigmaMin)) * plotW;
  stroke(251, 191, 36, 80);
  strokeWeight(6);
  line(xHalf, by + padT, xHalf, by + padT + plotH);
  stroke(colGold);
  strokeWeight(2);
  line(xHalf, by + padT, xHalf, by + padT + plotH);
  strokeWeight(1);

  fill(colGold);
  text("Re(s)=1/2", xHalf - 25, by + padT - 5);

  // Plot First 50 Non-Trivial Zeros on Re(s) = 1/2
  float pulse = 0.5 + 0.5 * sin(pulsePhase);
  for (int k = 0; k < 50; k++) {
    float g = (float)RIEMANN_ZEROS[k];
    float py = by + padT + plotH - ((g - tMin) / (tMax - tMin)) * plotH;
    zeroScreenX[k] = xHalf;
    zeroScreenY[k] = py;

    boolean isActive = k < numZeros;
    boolean isLatest = k == numZeros - 1;
    boolean isSelected = k == selectedZeroIdx;

    noStroke();
    if (isLatest || isSelected) {
      fill(isSelected ? color(56, 189, 248, 75) : color(244, 63, 94, 80));
      ellipse(xHalf, py, 14 + pulse * 7, 14 + pulse * 7);
    }

    if (isSelected) fill(colCyan);
    else if (isLatest) fill(colRose);
    else if (isActive) fill(colGold);
    else fill(148, 163, 184, 90);

    float r = (isLatest || isSelected) ? 8.5 : (isActive ? 6.0 : 4.2);
    ellipse(xHalf, py, r, r);

    if (isLatest || isSelected || (k == 0 && numZeros >= 1)) {
      fill(isSelected ? colCyan : (isLatest ? color(253, 164, 175) : color(253, 230, 138)));
      text("ρ" + (k + 1) + " (" + nf(g, 1, 2) + "i)", xHalf + 9, py + 3);
    }
  }

  fill(colTextMuted);
  text("Tap any zero on Re(s)=1/2 to jump to N=k", bx + 12, by + bh - 7);
}

void drawConformalMap(float bx, float by, float bw, float bh) {
  float cx = bx + bw * 0.5;
  float cy = by + bh * 0.48;
  float scale = min(bw, bh) * 0.25;

  // Axes
  stroke(148, 163, 184, 60);
  line(bx + 14, cy, bx + bw - 14, cy);
  line(cx, by + 14, cx, by + bh - 22);

  // Circles |w|=1 (Re=0), |w|=sqrt(e) (Re=1/2), |w|=e (Re=1)
  noFill();
  stroke(56, 189, 248, 95);
  ellipse(cx, cy, 2 * scale, 2 * scale);
  ellipse(cx, cy, 2 * (float)Math.E * scale, 2 * (float)Math.E * scale);

  float rCrit = (float)Math.sqrt(Math.E) * scale;
  stroke(251, 191, 36, 70);
  strokeWeight(5);
  ellipse(cx, cy, 2 * rCrit, 2 * rCrit);
  stroke(colGold);
  strokeWeight(2);
  ellipse(cx, cy, 2 * rCrit, 2 * rCrit);
  strokeWeight(1);

  for (int k = 0; k < 50; k++) {
    float g = (float)RIEMANN_ZEROS[k];
    float px = cx + rCrit * cos(g);
    float py = cy - rCrit * sin(g);
    zeroScreenX[k] = px;
    zeroScreenY[k] = py;

    boolean isActive = k < numZeros;
    boolean isLatest = k == numZeros - 1;
    noStroke();
    fill(isLatest ? colRose : (isActive ? colGold : color(148, 163, 184, 80)));
    ellipse(px, py, isLatest ? 9 : (isActive ? 6 : 4), isLatest ? 9 : (isActive ? 6 : 4));
  }

  fill(colGold);
  textSize(10);
  text("w = e^(1/2 + iγ) maps Critical Line to circle r = √e", bx + 12, by + bh - 8);
}

// ============================================================================
// 4. PANEL 2: FOURIER COSINE HARMONIC WAVES
// ============================================================================
void drawWavePanel() {
  int focusIdx = selectedZeroIdx >= 0 ? selectedZeroIdx : (numZeros > 0 ? numZeros - 1 : -1);
  String sub = focusIdx >= 0
    ? "k=" + (focusIdx + 1) + ": -(2√x/" + nf((float)zeroModulus[focusIdx], 1, 1) + ")cos(" + nf((float)RIEMANN_ZEROS[focusIdx], 1, 2) + " ln x)"
    : "No active waves";

  drawPanelFrame(topRightX, topRightY, topRightW, topRightH, "Riemann Zero Fourier Cosine Waves", sub, colViolet);

  float headH = 26;
  float bx = topRightX;
  float by = topRightY + headH;
  float bw = topRightW;
  float bh = topRightH - headH;

  float padL = 40, padR = 14, padT = 12, padB = 16;
  float plotW = bw - padL - padR;
  float plotH = bh - padT - padB;
  float yMid = by + padT + plotH * 0.5;

  stroke(148, 163, 184, 65);
  line(bx + padL, yMid, bx + bw - padR, yMid);
  fill(colTextMuted);
  textSize(9);
  text("+2.0", bx + 8, by + padT + 6);
  text(" 0.0", bx + 8, yMid + 3);
  text("-2.0", bx + 8, by + padT + plotH);

  int samples = 260;
  float xMin = 2.0;

  // Faint overlay of recent active harmonics
  noFill();
  int startIdx = max(0, numZeros - 16);
  for (int k = startIdx; k < numZeros - 1; k++) {
    stroke(167, 139, 250, 55);
    beginShape();
    for (int i = 0; i <= samples; i++) {
      float x = xMin + (i / (float)samples) * (xMax - xMin);
      float val = zeroWaveTerm(x, k);
      float px = bx + padL + (i / (float)samples) * plotW;
      float py = yMid - (val / 2.2) * (plotH * 0.46);
      vertex(px, py);
    }
    endShape();
  }

  // Highlighted wave (latest zero k = N or tapped zero)
  if (focusIdx >= 0) {
    stroke(selectedZeroIdx >= 0 ? colCyan : colGold);
    strokeWeight(2);
    beginShape();
    for (int i = 0; i <= samples; i++) {
      float x = xMin + (i / (float)samples) * (xMax - xMin);
      float val = zeroWaveTerm(x, focusIdx);
      float px = bx + padL + (i / (float)samples) * plotW;
      float py = yMid - (val / 2.2) * (plotH * 0.46);
      vertex(px, py);
    }
    endShape();
    strokeWeight(1);
  }
}

// ============================================================================
// 5. PANEL 3: CHEBYSHEV PRIME STAIRCASE & DERIVATIVE SPIKE DETECTOR
// ============================================================================
void drawStaircasePanel() {
  drawPanelFrame(botRightX, botRightY, botRightW, botRightH,
    "Prime-Counting Staircase ψ(x) & Prime Spikes",
    "Green: Exact ψ | Cyan: Fourier ψ_N | Red: Spikes",
    colCyan);

  float headH = 26;
  float bx = botRightX;
  float by = botRightY + headH;
  float bw = botRightW;
  float bh = botRightH - headH;

  float padL = 40, padR = 14, padT = 14, padB = 34;
  float plotW = bw - padL - padR;
  float plotH = bh - padT - padB;

  float xMin = 2.0;
  float yMax = xMax * 1.06;

  // Horizontal Grid
  textSize(9);
  int yStep = xMax <= 25 ? 5 : 10;
  for (int yv = 0; yv <= yMax; yv += yStep) {
    float py = by + padT + plotH - (yv / yMax) * plotH;
    stroke(148, 163, 184, 28);
    line(bx + padL, py, bx + bw - padR, py);
    fill(colTextMuted);
    text(yv, bx + 12, py + 3);
  }

  // Prime Grid Markers along X-axis
  for (int p = 2; p <= xMax; p++) {
    if (isPrime(p)) {
      float px = bx + padL + ((p - xMin) / (xMax - xMin)) * plotW;
      stroke(16, 185, 129, 40);
      line(px, by + padT, px, by + padT + plotH);
      fill(colEmerald);
      text(p, px - (p >= 10 ? 5 : 2), by + padT + plotH + 12);
    }
  }

  int samples = 360;
  noFill();

  // 1. Prime Spike Detector psi'_N(x) (Rose Red)
  if (showSpikes && numZeros > 0) {
    stroke(244, 63, 94, 200);
    strokeWeight(1.4);
    float spikeScale = plotH / (2.5 * sqrt(numZeros + 4));
    float baseY = by + padT + plotH;
    beginShape();
    for (int i = 0; i <= samples; i++) {
      float x = xMin + (i / (float)samples) * (xMax - xMin);
      float dVal = max(0, fourierPrimeDetector(x, numZeros));
      float px = bx + padL + (i / (float)samples) * plotW;
      float py = max(by + padT, baseY - dVal * spikeScale);
      vertex(px, py);
    }
    endShape();
    strokeWeight(1);
  }

  // 2. Exact Chebyshev Staircase psi(x) (Emerald Green)
  if (showExact) {
    stroke(colEmerald);
    strokeWeight(1.8);
    beginShape();
    float prevPsi = exactChebyshevPsi(xMin);
    vertex(bx + padL, by + padT + plotH - (prevPsi / yMax) * plotH);
    for (int i = 1; i <= samples; i++) {
      float x = xMin + (i / (float)samples) * (xMax - xMin);
      float curPsi = exactChebyshevPsi(x);
      float px = bx + padL + (i / (float)samples) * plotW;
      if (abs(curPsi - prevPsi) > 1e-4) {
        vertex(px, by + padT + plotH - (prevPsi / yMax) * plotH);
      }
      vertex(px, by + padT + plotH - (curPsi / yMax) * plotH);
      prevPsi = curPsi;
    }
    endShape();
    strokeWeight(1);
  }

  // 3. Fourier Reconstructed Staircase psi_N(x) (Glowing Cyan)
  stroke(56, 189, 248, 75);
  strokeWeight(5);
  beginShape();
  for (int i = 0; i <= samples; i++) {
    float x = xMin + (i / (float)samples) * (xMax - xMin);
    float approx = fourierChebyshevPsi(x, numZeros);
    float px = bx + padL + (i / (float)samples) * plotW;
    float py = by + padT + plotH - (approx / yMax) * plotH;
    vertex(px, py);
  }
  endShape();

  stroke(colCyan);
  strokeWeight(2.2);
  beginShape();
  for (int i = 0; i <= samples; i++) {
    float x = xMin + (i / (float)samples) * (xMax - xMin);
    float approx = fourierChebyshevPsi(x, numZeros);
    float px = bx + padL + (i / (float)samples) * plotW;
    float py = by + padT + plotH - (approx / yMax) * plotH;
    vertex(px, py);
  }
  endShape();
  strokeWeight(1);

  // Touch Scrubbing Inspector
  if (inspectX >= xMin && inspectX <= xMax) {
    float px = bx + padL + ((inspectX - xMin) / (xMax - xMin)) * plotW;
    float approxVal = fourierChebyshevPsi(inspectX, numZeros);
    float exactVal = exactChebyshevPsi(inspectX);
    int nearInt = round(inspectX);
    String pTag = (abs(inspectX - nearInt) < 0.22 && isPrime(nearInt)) ? " [PRIME " + nearInt + "]" : "";

    stroke(colGold);
    line(px, by + padT, px, by + padT + plotH);
    fill(colCyan);
    noStroke();
    ellipse(px, by + padT + plotH - (approxVal / yMax) * plotH, 8, 8);

    fill(colGold);
    textSize(10);
    text("x=" + nf(inspectX, 1, 2) + pTag + " | Exact ψ=" + nf(exactVal, 1, 2) + " | Fourier ψ_" + numZeros + "=" + nf(approxVal, 1, 2),
      bx + 12, by + bh - 6);
  } else {
    fill(colTextMuted);
    textSize(10);
    text("Touch & drag across staircase to inspect prime jumps", bx + 12, by + bh - 6);
  }
}

void drawPanelFrame(float x, float y, float w, float h, String title, String sub, int dotCol) {
  fill(colBgPanel);
  stroke(colBorder);
  rect(x, y, w, h, 8);

  fill(19, 28, 49);
  noStroke();
  rect(x + 1, y + 1, w - 2, 24, 8, 8, 0, 0);
  stroke(colBorder);
  line(x, y + 25, x + w, y + 25);

  fill(dotCol);
  noStroke();
  ellipse(x + 13, y + 13, 8, 8);

  fill(colTextMain);
  textSize(11);
  textAlign(LEFT, CENTER);
  text(title, x + 23, y + 13);

  fill(colTextMuted);
  textSize(10);
  textAlign(RIGHT, CENTER);
  text(sub, x + w - 10, y + 13);
  textAlign(LEFT, BASELINE);
}

void drawDashedVLine(float x, float y1, float y2, float dashLen) {
  for (float y = y1; y < y2; y += dashLen * 2) {
    line(x, y, x, min(y2, y + dashLen));
  }
}

// ============================================================================
// 6. NUMBER THEORY & FOURIER EXPLICIT FORMULA MATH ENGINE
// ============================================================================
boolean isPrime(int n) {
  if (n < 2) return false;
  if (n == 2) return true;
  if (n % 2 == 0) return false;
  for (int d = 3; d * d <= n; d += 2) {
    if (n % d == 0) return false;
  }
  return true;
}

float exactChebyshevPsi(float x) {
  double sum = 0.0;
  int limit = (int)Math.floor(x + 1e-6);
  for (int p = 2; p <= limit; p++) {
    if (isPrime(p)) {
      int pk = p;
      double logP = Math.log(p);
      while (pk <= limit) {
        sum += logP;
        pk *= p;
      }
    }
  }
  return (float)sum;
}

float zeroWaveTerm(float x, int k) {
  double lnX = Math.log(x);
  return (float)(-(2.0 * Math.sqrt(x) / zeroModulus[k]) * Math.cos(RIEMANN_ZEROS[k] * lnX - zeroPhase[k]));
}

float fourierChebyshevPsi(float x, int N) {
  double val = x - Math.log(2.0 * Math.PI) - 0.5 * Math.log(1.0 - 1.0 / (x * x));
  double lnX = Math.log(x);
  double twoSqrtX = 2.0 * Math.sqrt(x);
  for (int k = 0; k < N; k++) {
    val -= (twoSqrtX / zeroModulus[k]) * Math.cos(RIEMANN_ZEROS[k] * lnX - zeroPhase[k]);
  }
  return (float)val;
}

float fourierPrimeDetector(float x, int N) {
  double deriv = 1.0 - 1.0 / (x * (x * x - 1.0));
  double lnX = Math.log(x);
  double cosSum = 0.0;
  for (int k = 0; k < N; k++) {
    cosSum += Math.cos(RIEMANN_ZEROS[k] * lnX);
  }
  deriv -= (2.0 / Math.sqrt(x)) * cosSum;
  return (float)deriv;
}

// ============================================================================
// 7. ANDROID TOUCH & DRAG INTERACTION
// ============================================================================
void mousePressed() {
  if (inRect(mouseX, mouseY, btnPlayRect)) {
    playing = !playing;
    if (playing && numZeros >= 50) numZeros = 0;
    lastStepTime = millis();
  } else if (inRect(mouseX, mouseY, btnResetRect)) {
    playing = false;
    numZeros = 0;
    selectedZeroIdx = -1;
  } else if (inRect(mouseX, mouseY, btnMinusRect)) {
    playing = false;
    numZeros = max(0, numZeros - 1);
    selectedZeroIdx = -1;
  } else if (inRect(mouseX, mouseY, btnPlusRect)) {
    playing = false;
    numZeros = min(50, numZeros + 1);
    selectedZeroIdx = -1;
  } else if (inRect(mouseX, mouseY, sliderRect)) {
    draggingSlider = true;
    playing = false;
    updateSliderFromTouch(mouseX);
  } else if (inRect(mouseX, mouseY, btnDomainRect)) {
    xMax = (xMax == 25) ? 35 : (xMax == 35 ? 50 : 25);
  } else if (inRect(mouseX, mouseY, btnExactRect)) {
    showExact = !showExact;
  } else if (inRect(mouseX, mouseY, btnSpikesRect)) {
    showSpikes = !showSpikes;
  } else if (inRect(mouseX, mouseY, btnMapRect)) {
    showConformal = !showConformal;
  } else if (mouseX >= leftX && mouseX <= leftX + leftW && mouseY >= leftY && mouseY <= leftY + leftH) {
    // Check tap on any Riemann zero on Re(s) = 1/2 or Conformal circle
    int closest = -1;
    float minDist = 26;
    for (int k = 0; k < 50; k++) {
      float d = dist(mouseX, mouseY, zeroScreenX[k], zeroScreenY[k]);
      if (d < minDist) {
        minDist = d;
        closest = k;
      }
    }
    if (closest >= 0) {
      playing = false;
      selectedZeroIdx = closest;
      numZeros = closest + 1;
    }
  } else if (mouseX >= botRightX && mouseX <= botRightX + botRightW && mouseY >= botRightY && mouseY <= botRightY + botRightH) {
    scrubbingStaircase = true;
    updateStaircaseInspect(mouseX);
  }
}

void mouseDragged() {
  if (draggingSlider) {
    updateSliderFromTouch(mouseX);
  } else if (scrubbingStaircase) {
    updateStaircaseInspect(mouseX);
  }
}

void mouseReleased() {
  draggingSlider = false;
  scrubbingStaircase = false;
}

void updateSliderFromTouch(float tx) {
  float tx0 = sliderRect[0] + 12;
  float tx1 = sliderRect[0] + sliderRect[2] - 12;
  float frac = constrain((tx - tx0) / (tx1 - tx0), 0, 1);
  numZeros = round(frac * 50);
  selectedZeroIdx = -1;
}

void updateStaircaseInspect(float tx) {
  float padL = 40, padR = 14;
  float plotW = botRightW - padL - padR;
  float frac = constrain((tx - (botRightX + padL)) / plotW, 0, 1);
  inspectX = 2.0 + frac * (xMax - 2.0);
}
