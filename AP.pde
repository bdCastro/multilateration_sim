class AP extends Point{
  int clock;
  
  AP(int id, int clock, float x, float y) {
    this.id = id;
    this.clock = clock;
    this.pos = new PVector(x, y);
    this.radius = 15;
  }
  
  void draw() {
    push();
    noStroke();
    fill(0, 0, 200);
    circle(pos.x, pos.y, this.radius);
    fill(255);
    text("AP" + this.id, pos.x, pos.y + 20);
    pop();
  }
}
