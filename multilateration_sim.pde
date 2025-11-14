import garciadelcastillo.dashedlines.*;

ArrayList<AP> aps = new ArrayList<AP>();
ArrayList<Sensor> sensors = new ArrayList<Sensor>();

DashedLines dash;

Point nearest;

enum MODE {
  SELECT,
  ADD_AP,
  ADD_SENSOR,
  DELETE
}

MODE mode = MODE.SELECT;

boolean showHyperbolas = false;
boolean showPath = true;
boolean showCalc = false;
boolean showError = false;

boolean translating = false;
boolean moving = false;

PVector origin = new PVector(0, 0);

float scaleFactor = 1.0; // Initial scale factor
float minScale = 0.33;    // Minimum scale limit
float maxScale = 3.0;    // Maximum scale limit
 
void setup() {
  size(840, 480);
  dash = new DashedLines(this);
  dash.pattern(5, 5);
}

void draw() {
  push();
  // Apply the scaling transformation
  // This affects everything drawn after this point

  // translate
  if(translating) origin = new PVector(mouseX - clickOrigin.x, mouseY - clickOrigin.y);
  if(moving) nearest.setPos(new PVector((mouseX - origin.x)/scaleFactor, (mouseY - origin.y)/scaleFactor));
  
  translate(origin.x, origin.y);
  scale(scaleFactor);

  background(25);
  
  // TODO: fix grid
  drawGrid(25);
 
  // draw hyperbolas
  if(showHyperbolas) {
    for(int i = 0; i < sensors.size(); i++) {
      Sensor s = sensors.get(i);
      
      for(int j = 0; j < aps.size(); j++) {
        AP ap0 = aps.get(j);
        for(int k = j+1; k < aps.size(); k++) {
          AP ap1 = aps.get(k);
          drawHyperbola(ap0, ap1, s);
        }
      }
    }
  }
  
  // draw aps
  for(int i = 0; i < aps.size(); i++) {
    AP ap = aps.get(i);
    ap.draw();
  }
  
  // draw sensors
  for(int i = 0; i < sensors.size(); i++) {
    Sensor s = sensors.get(i);
    
    if(showPath && i+1 < sensors.size()) {
      Sensor s1 = sensors.get(i+1);
      s.drawPath(s1, showCalc);
    }
    
    s.draw(showCalc, showError);
  }
  
  pop();
  drawMenu(10, 10);
  if(!translating && ! moving) noLoop();
}

void drawGrid(int spacing) {
  push();
  stroke(80);
  
  PVector wOrigin = origin.copy().div(scaleFactor).mult(-1);
  PVector wDest = new PVector(width-origin.x, height-origin.y).div(scaleFactor);
  
  // vertical lines
  for(int i = (int) wOrigin.x/spacing; i < wDest.x/spacing; i++)
    line(i*spacing, wOrigin.y, i*spacing, wDest.y);
  
  // horizontal lines
  for(int i = (int) wOrigin.y/spacing; i < wDest.y/spacing; i++)
    line(wOrigin.x, i*spacing, wDest.x, i*spacing);
  
  pop();
}

void drawMenu(int x, int y) {
  push();
  fill(60, 200);
  noStroke();
  rect(x, y, 180, height-20, 12);
  fill(150);
  text("MODE:", x+10, y+20);
  fill(mode == MODE.SELECT ? color(0, 180, 0) : 255);
  text("(S)ELECT", x+70, y+20);
  fill(mode == MODE.ADD_AP ? color(0, 180, 0) : 255);
  text("ADD (A)P", x+70, y+35);
  fill(mode == MODE.ADD_SENSOR ? color(0, 180, 0) : 255);
  text("ADD S(E)NSOR", x+70, y+50);
  fill(mode == MODE.DELETE ? color(0, 180, 0) : 255);
  text("(D)ELETE", x+70, y+65);
  fill(150, 0, 0);
  text("(R)ESET", x+70, y+80);
  
  fill(150);
  text("OPTIONS:", x+10, y+100);
  fill(showHyperbolas ? color(0, 200, 0) : 0);
  stroke(255);
  circle(x+75, y+95, 10);
  fill(255);
  text("(H)YPERBOLAS", x+85, y+100);
  fill(showPath ? color(0, 200, 0) : 0);
  circle(x+75, y+110, 10);
  fill(255);
  text("(P)ATH", x+85, y+115);
  fill(showCalc ? color(0, 200, 0) : 0);
  circle(x+75, y+125, 10);
  fill(255);
  text("(C)ALCULATED", x+85, y+130);
  fill(showError ? color(0, 200, 0) : 0);
  circle(x+75, y+140, 10);
  fill(255);
  text("ERR(O)R", x+85, y+145);
  pop();
}

// Custom cosh and sinh functions
float cosh(float x) {
  return (exp(x) + exp(-x)) / 2.0;
}

float sinh(float x) {
  return (exp(x) - exp(-x)) / 2.0;
}

// Function to draw a hyperbola
void drawHyperbola(AP ap0, AP ap1, Sensor s) {
  // Center of the hyperbola
  PVector center = PVector.add(ap0.pos, ap1.pos);
  center.div(2);
  
  // Parameters for the hyperbola
  float d1 = dist(ap0.pos.x, ap0.pos.y, s.pos.x, s.pos.y);
  float d2 = dist(ap1.pos.x, ap1.pos.y, s.pos.x, s.pos.y);
  
  float a = abs(d1-d2) / 2;
  float c = dist(ap0.pos.x, ap0.pos.y, ap1.pos.x, ap1.pos.y)/2;
  float b = sqrt(c*c - a*a);
  
  float angle = atan2(ap1.pos.y - ap0.pos.y, ap1.pos.x - ap0.pos.x); 
  
  // Apply transformations
  push(); // Save current transformation state
  translate(center.x, center.y); // Move origin to center
  rotate(angle); // Rotate the canvas
  
  stroke(255, 0, 0, 75);
  strokeWeight(1);
  noFill();

  // Draw the right branch using parametric equations (cosh/sinh work well)
  beginShape();
  for (float t = -2; t <= 2; t += 0.01) {
    float x = a * cosh(t);
    float y = b * sinh(t);
    vertex(x, y);
  }
  endShape();

  // Draw the left branch
  beginShape();
  for (float t = -2; t <= 2; t += 0.01) {
    float x = -a * cosh(t); // Use negative 'a*cosh(t)' for the other branch
    float y = b * sinh(t);
    vertex(x, y);
  }
  endShape();
  
  pop(); // Restore original transformation state
}

Point findNearest(PVector mousePos) {
  Point nearest = null;
  float nearDist = 999999;
  
  for(int i = 0; i < aps.size(); i++) {
    Point p = aps.get(i);
    float dist = p.distTo(mousePos);
    
    if(dist < nearDist) {
      nearest = p;
      nearDist = dist;
    }
  }
  
  for(int i = 0; i < sensors.size(); i++) {
    Point p = sensors.get(i);
    float dist = p.distTo(mousePos);
    
    if(dist < nearDist) {
      nearest = p;
      nearDist = dist;
    }
  }
  
  return nearest;
}

PVector clickOrigin;
void mousePressed() {
  if(mouseButton == RIGHT) {
    if(!translating) {
      translating = true;
      clickOrigin = new PVector(mouseX-origin.x, mouseY-origin.y);
    } else {
      origin = new PVector(mouseX-clickOrigin.x, mouseY-clickOrigin.y);
    }
  }
  
  if(mouseButton == LEFT) {
    PVector mousePos = new PVector((mouseX - origin.x)/scaleFactor, (mouseY - origin.y)/scaleFactor);
    switch(mode) {
      case SELECT:
        if(aps.size() > 0 || sensors.size() > 0) {
          nearest = findNearest(mousePos);
          moving = nearest.clicked(mousePos);
        }
        break;
      case ADD_AP:
        aps.add(new AP(aps.size(), 0, mousePos.x, mousePos.y));
        break;
      case ADD_SENSOR:
        sensors.add(new Sensor(sensors.size(), mousePos.x, mousePos.y, dash));
        break;
      case DELETE:
        if(aps.size() > 0 || sensors.size() > 0) {
          nearest = findNearest(mousePos);
          
          if(nearest.clicked(mousePos)) {
            // deleting in the right list
            if(nearest instanceof AP) aps.remove(nearest);
            else sensors.remove(nearest); 
          }
        }
        break;
      default:
        break;
    }
  }
  
  loop();
}

void mouseReleased() {
  if(mouseButton == RIGHT) {
    translating = false;
    origin = new PVector(mouseX - clickOrigin.x, mouseY - clickOrigin.y);
  } else if(mouseButton == LEFT) moving = false;
}

void keyPressed() {
  switch(key) {
    case 'a':
      mode = MODE.ADD_AP;
      break;
    case 's':
      mode = MODE.SELECT;
      break;
    case 'e':
      mode = MODE.ADD_SENSOR;
      break;
    case 'r':
      aps.clear();
      sensors.clear();
      break;
    case 'h':
      showHyperbolas = !showHyperbolas;
      break;
    case 'p':
      showPath = ! showPath;
      break;
    case 'd':
      mode = MODE.DELETE;
      break;
    case 'c':
      showCalc = !showCalc;
      break;
    case 'o':
      showError = !showError;
      break;
  }
  
  loop();
}

// This function is called automatically when the mouse wheel moves
void mouseWheel(MouseEvent event) {
  // Get the amount of scroll; positive for down, negative for up (on some systems)
  float change = event.getCount();
  float oldScaleFactor = scaleFactor;
  
  // Adjust the scale factor based on the scroll amount
  // We use a small increment to make the zoom smooth
  scaleFactor -= change * 0.05;

  // Constrain the scale factor within a sensible range
  scaleFactor = constrain(scaleFactor, minScale, maxScale);
  float sf = scaleFactor / oldScaleFactor;
  origin = new PVector((origin.x-mouseX)*sf + mouseX, (origin.y-mouseY)*sf + mouseY);

  loop();
}
