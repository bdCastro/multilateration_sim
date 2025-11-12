import garciadelcastillo.dashedlines.*;

class Sensor extends Point {
  PVector calc;
  DashedLines dash;
 
  Sensor(int id, float x, float y, DashedLines dash) {
    this.id = id;
    this.pos = new PVector(x, y);
    this.radius = 10;
    this.calc = this.pos.copy().add(50, 50);
    this.dash = dash;
  }
  
  @Override
  public void setPos(PVector pos) {
    super.setPos(pos);
    this.calc = this.pos.copy().add(50, 50);
  }
  
  void draw() {
    this.draw(false, false);
  }
  
  void draw(boolean showCalc, boolean showError) {
    push();
    stroke(200);
    if(showCalc && showError) drawDash();
    noStroke();
    fill(0, 160, 0);
    circle(pos.x, pos.y, this.radius);
    fill(255);
    text("S" + this.id, pos.x, pos.y + 15);
    if(showCalc) drawCalc();
    pop();
  }
  
  void drawPath(Sensor s, boolean showCalc) {
    push();
    stroke(0, 140, 0);
    line(pos.x, pos.y, s.pos.x, s.pos.y);
    if(showCalc) {
      stroke(180);
      line(calc.x, calc.y, s.calc.x, s.calc.y);
    }
    pop();
  }
  
  void drawCalc() {
    noStroke();
    fill(200);
    circle(calc.x, calc.y, this.radius);
    fill(255);
    text("C" + this.id, calc.x, calc.y + 15);
  }
  
  void drawDash() {
    dash.line(pos.x, pos.y, calc.x, calc.y);
    push();
    float angle = atan2(calc.y - pos.y, calc.x - pos.x);
    translate(pos.x, pos.y);
    rotate(angle);
    textAlign(CENTER, BOTTOM);
    text(String.format("%.2fpx", dist(pos.x, pos.y, calc.x, calc.y)), (calc.x-pos.x)/2 + 10, (calc.y-pos.y)/2 - 25);
    pop();
  }
}
