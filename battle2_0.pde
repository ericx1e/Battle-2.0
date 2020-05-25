import java.util.*;

HashSet<Troop> blue = new HashSet();
HashSet<Troop> red = new HashSet();
HashSet<Button> buttons = new HashSet();
Button startButton = new Button(1712.5, 912.5, 75, 75);

boolean startGame = false;

class Button {
  float x, y, xs, ys;
  boolean toggle;

  Button(float xx, float yy, float xss, float yss) {
    x = xx;
    y = yy;
    xs = xss;
    ys = yss;
    toggle = false;
  }

  void pressed() {
    if(mouseX>x&&mouseX<x+xs&&mouseY>y&&mouseY<y+ys) {
      toggle = !toggle;
    }
  }

  void display() {
    rectMode(CORNER);
    rect(x, y, xs, ys);
  }
}

abstract class Troop {
  float x, y, xSpd, ySpd, hp, atk, atkRange, atkSpd, initAtk, range, collRange, spd, def;
  Troop e;

  Troop(float xx, float yy) {
    x = xx;
    y = yy;
  }

  abstract void display(color c);

  abstract void attack();

  void move() {
    x += xSpd;
    y += ySpd;
    xSpd = -(x-e.x)/(dist(x, y, e.x, e.y)/spd);
    ySpd = -(y-e.y)/(dist(x, y, e.x, e.y)/spd);
  }

  void collide() {
    xSpd *= random(-2, 2);
    ySpd *= random(-2, 2);
  }
}

class Dummy extends Troop {
  Dummy(float x, float y) {
    super(x, y);
  }
  void display(color c) {
  }
  void attack() {
  }
}

/*
    e = new Dummy(-1000000000, -1000000000);
 hp =
 atk =
 atkRange =
 atkSpd =
 initAtk = (int)random(0, 59);
 range =
 collRange =
 spd =
 def = 
 */

class Soldier extends Troop {
  Soldier(float x, float y) {
    super(x, y);
    e = new Dummy(-1000000000, -1000000000);
    hp = 1000;
    atk = 100;
    atkRange = 35;
    atkSpd = 25;
    initAtk = (int)random(0, 59);
    range = 25;
    collRange = 25;
    spd = 4;
    def = 0;
  }

  void display(color c) {
    troopDispSettings(c);
    ellipse(x, y, 25, 25);
  }

  void attack() {
    if ((frameCount-initAtk)%atkSpd != 0) {
      return;
    }
    e.hp-=Math.max(0, atk-e.def);
  }
}

class Spear extends Troop {
  Spear(float x, float y) {
    super(x, y);
    e = new Dummy(-1000000000, -1000000000);
    hp = 700;
    atk = 150;
    atkRange = 100;
    atkSpd = 50;
    initAtk = (int)random(0, 59);
    range = 90;
    collRange = 25;
    spd = 2;
    def = 0;
  }

  void display(color c) {
    troopDispSettings(c);
    ellipse(x, y, 25, 25);
    translate(x, y);
    rotate(atan2(y-e.y, x-e.x));
    rectMode(CORNER);
    rect(10, 12, -100, 5);
    resetMatrix();
  }

  void attack() {
    if ((frameCount-initAtk)%atkSpd != 0) {
      return;
    }
    e.hp-=Math.max(0, atk-e.def);
  }
}

class Shield extends Troop {
  Shield(float x, float y) {
    super(x, y);
    e = new Dummy(-1000000000, -1000000000);
    hp = 3000;
    atk = 50;
    atkRange = 35;
    atkSpd = 100;
    initAtk = (int)random(0, 59);
    range = 25;
    collRange = 25;
    spd = 2;
    def = 25;
  }

  void display(color c) {
    troopDispSettings(c);
    rectMode(CENTER);
    rect(x, y, 25, 25);
  }

  void attack() {
    if ((frameCount-initAtk)%atkSpd != 0) {
      return;
    }
    e.hp-=Math.max(0, atk-e.def);
  }
}

void troopDispSettings(color c) {
  fill(c);
  stroke(c);
  strokeWeight(4);
  fill(c, 120);
}

void setup() {
  size(1800, 1000);
  buttons.add(startButton);
  background(255);
  //blue.add(new Soldier(random(100, 600), 100));
  //blue.add(new Soldier(random(100, 600), 200));
  //blue.add(new Soldier(random(100, 600), 300));
  //blue.add(new Soldier(random(100, 600), 400));
  //blue.add(new Soldier(random(100, 600), 500));
  //blue.add(new Soldier(random(100, 600), 600));
  //blue.add(new Soldier(random(600, 1800), 100));
  //red.add(new Soldier(random(600, 1800), 200));
  //red.add(new Soldier(random(600, 1800), 300));
  //red.add(new Soldier(random(600, 1800), 400));
  //red.add(new Soldier(random(600, 1800), 500));
  //red.add(new Soldier(random(600, 1800), 600));
  //red.add(new Spear(1300, 100));
  //red.add(new Soldier(1200, 600));
}

void draw() {
  //if(blue.isEmpty()||red.isEmpty()) {
  //  exit();
  //}
  background(255);
  stroke(0);
  strokeWeight(10);
  line(width/2, 0, width/2, height);
  noStroke();
  rectMode(CORNER);
  fill(120);
  rect(0, height-100, width, 100);
  if (startGame) {
    update(blue, red, color(0, 0, 255)); //color of first array troops
    update(red, blue, color(255, 0, 0));
    fill(255, 0, 0);
  } else {
    display(blue, color(0, 0, 255));
    display(red, color(255, 0, 0));
    fill(0, 255, 0);
  }
  stroke(0);
  strokeWeight(5);
  for (Button i : buttons) {
    i.display();
  }
  startGame = startButton.toggle;
}

void update(HashSet<Troop> a, HashSet<Troop> b, color c) {
  HashSet<Troop> toRemove = new HashSet();
  for (Troop i : a) {
    if (i.hp < 1) {
      toRemove.add(i);
    }
    i.display(c);
    Troop min = i.e;
    if (!b.contains(min)) {
      min = new Dummy(-1000000000, -1000000000);
    }
    float dist = dist(i.x, i.y, min.x, min.y);
    for (Troop j : b) {
      float temp = dist(i.x, i.y, j.x, j.y);
      if (temp<dist) {
        dist = temp;
        min = j;
      }
      i.e = min;
    }
    if (dist>i.range) {
      i.move();
    }
    if (dist<i.atkRange) {
      i.attack();
    }
    for (Troop j : a) {
      if (i == j) continue;
      if (dist(i.x, i.y, j.x, j.y)<i.collRange) {
        i.collide();
      }
    }
  }
  a.removeAll(toRemove);
}

void keyReleased() {
  if (key == '1') selected = 1;
  if (key == '2') selected = 2;
  if (key == '3') selected = 3;
}

boolean pause = false;

void pause() {
  pause = !pause;
  if (pause) {
    fill(0, 150);
    rect(0, 0, width, height);
    fill(255);
    textMode(2);
    textSize(144);
    text("PAUSED", 650, 500);
    noLoop();
  } else {
    loop();
  }
}

void display(HashSet<Troop> a, color c) {
  for (Troop i : a) {
    i.display(c);
  }
}

int selected = 1;

void mouseReleased() {
  for (Button i : buttons) {
    i.display();
    i.pressed();
  }
  if (startGame) {
    return;
  }
  HashSet<Troop> temp = new HashSet();
  if (mouseY>height-100) {
    return;
  }
  if (mouseX<=width/2) {
    temp = blue;
  } else {
    temp = red;
  }
  if (selected == 1) {
    temp.add(new Soldier(mouseX, mouseY));
  } else if (selected == 2) {
    temp.add(new Spear(mouseX, mouseY));
  } else if (selected == 3) {
    temp.add(new Shield(mouseX, mouseY));
  }
}
