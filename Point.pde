abstract class Point {
  int id;
  int radius;
  PVector pos;
  
  abstract void draw();
  
  void setPos(PVector pos) {
    this.pos = pos;
  }
  
  boolean clicked(PVector mousePos) {
    return this.distTo(mousePos) < this.radius;
  }
  
  float distTo(PVector p) {
    return dist(this.pos.x, this.pos.y, p.x, p.y);
  }
}
