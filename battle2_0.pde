import java.util.*;

HashMap<Troop, Integer> frozen = new HashMap();
HashSet<Troop> blue = new HashSet();
HashSet<Troop> red = new HashSet();
HashSet<Troop> bToAdd = new HashSet();
HashSet<Troop> rToAdd = new HashSet();
HashSet<Proj> bProj = new HashSet();
HashSet<Proj> rProj = new HashSet();
HashSet<Blast> bBlast = new HashSet();
HashSet<Blast> rBlast = new HashSet();
HashSet<Flame> bFlame = new HashSet();
HashSet<Flame> rFlame = new HashSet();
HashSet<Poison> bPoison = new HashSet();
HashSet<Poison> rPoison = new HashSet();
HashSet<Troop> poisoned = new HashSet();
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
    if (mouseX>x&&mouseX<x+xs&&mouseY>y&&mouseY<y+ys) {
      toggle = !toggle;
    }
  } 

  void display() {
    rectMode(CORNER);
    rect(x, y, xs, ys);
  }
} 

abstract class Troop {
  float x, y, xSpd, ySpd, hp, atk, atkRange, atkSpd, initAtk, range, collRange, spd, ospd, def, pdef;
  boolean invisible;
  Troop e;

  Troop(float xx, float yy) {
    x = xx;
    y = yy;
  } 

  abstract void display(color c);

  abstract void attack();

  abstract void move();
  
  //abstract Troop death();
  
  void collide() {
    xSpd += random(-2, 2);
    ySpd += random(-2, 2);
    xSpd *= random(-2, 2);
    ySpd *= random(-2, 2);
  }
} 

abstract class Proj {
  float x, y, xSpd, ySpd, dmg, spd, range, targX, targY, angle;
  HashSet<Proj> projs;
  Proj(float xx, float yy, float tx, float ty) {
    x = xx;
    y = yy;
    targX = tx;
    targY = ty;
    angle = atan2(y-ty, x-tx);
  }
  abstract void display(color c);

  void setSpeed() {
    xSpd = -(x-targX)/(dist(x, y, targX, targY)/spd);
    ySpd = -(y-targY)/(dist(x, y, targX, targY)/spd);
  }

  void move() {
    x += xSpd;
    y += ySpd;
  }

  abstract Proj collide(Troop t);
}

class Blast {
  float x, y, range, dur, dmg;

  Blast(float xx, float yy, float r, float d, float ddmg) {
    x = xx;
    y = yy;
    range = r;
    dur = d;
    dmg = ddmg;
  }

  void display(color c) {
    noStroke();
    fill(c, 80);
    ellipse(x, y, range, range);
  }
}

class Flame {
  float x, y, range, dur, maxD, dmg, init, spd;

  Flame(float xx, float yy, float r, float d, float ddmg, float i, float s) {
    x = xx;
    y = yy;
    range = r;
    dur = d;
    maxD = d;
    dmg = ddmg;
    init = i;
    spd = s;
  }

  void display() {
    noStroke();
    colorMode(HSB);
    for (int i = 0; i < 7; i++) {
      fill(20+i * 4, 255, 122+122*dur/maxD, 255*dur/maxD);
      ellipse(x + random(-10, 10), y - i * range/10, range - i * 3, range - i * 3);
    }
    colorMode(RGB);
  }
}

class Arc {
  HashSet<Troop> targets;
  HashSet<Troop> visited;
  Troop cur;
  Troop next;
  float range, dmg;
  int charges;
  int initC;

  Arc(float d, float r, int c, HashSet<Troop> ts, Troop curr) {
    visited = new HashSet();
    dmg = d;
    range = r;
    charges = c;
    initC = c;
    targets = ts;
    cur = curr;
    visited = new HashSet();
  }

  void updateNext() {
    charges-=1;
    if (charges < 0) {
      return;
    }
    visited.add(cur);
    Troop min = new Dummy(-1000000, -1000000);
    for (Troop i : targets) {
      if (cur==i || visited.contains(i)) {
        continue;
      }
      if (dist(cur.x, cur.y, i.x, i.y) < dist(cur.x, cur.y, min.x, min.y)) {
        min = i;
      }
    }
    if (dist(cur.x, cur.y, min.x, min.y) < range) {
      next = min;
      displayAtk();
    } else {
      return;
    }
  }

  void displayAtk() {
    stroke(255, 200, 0);
    strokeWeight(8);
    line(cur.x, cur.y, next.x, next.y);
    fill(255, 200, 0, 100);
    noStroke();
    ellipse(cur.x, cur.y, 25, 25);
    cur.hp-=dmg/2+dmg/2*(charges/initC);
    cur.spd = 0;
    cur = next;
    updateNext();
  }
}

class Poison {
  Troop e;
  HashSet<Poison> ps;
  HashSet<Poison> toAdd;
  HashSet<Troop> es;
  float dmg, ticks, init, spd;
  float odmg, oticks, oinit, ospd;
  Poison(Troop e, float d, float t, float i, float s, HashSet<Poison> ps, HashSet<Troop> es) {
    toAdd = new HashSet();
    poisoned.add(e);
    this.e = e;
    this.ps = ps;
    this.es = es;
    dmg = d;
    odmg = d;
    ticks = t;
    oticks = t;
    init = i;
    spd = s;
    ospd = s;
  }

  void display() {
    stroke(0, 255, 0, 120);
    strokeWeight(6);
    fill(0, 255, 0, 120);
    ellipse(e.x, e.y, 25, 25);
    float temp = 25/sqrt(2);
    translate(e.x, e.y);
    line(-temp, temp, temp, -temp);
    line(temp, temp, -temp, -temp);
    resetMatrix();
  }
  void tick() {
    if (e.hp < 0) {
      ticks = -1;
      es.remove(e);
      //poisoned.remove(e);
      for (Troop i : es) {
        stroke(0, 255, 0);
        fill(0, 255, 0);
        ellipse(e.x, e.y, 40, 40);
        if (dist(e.x, e.y, i.x, i.y) < 40&&!poisoned.contains(i)) {
          int temp = (int)random(0, 1);
          if (temp == 0) {
            i.hp-=dmg;
            toAdd.add(new Poison(i, odmg, oticks-1, (int)random(0, ospd), ospd, ps, es));
          }
        }
      }
    }
    stroke(0, 255, 0);
    fill(0, 255, 0, 120);
    ellipse(e.x, e.y, 25, 25);
    float temp = 25/sqrt(2);
    translate(e.x, e.y);
    line(-temp, temp, temp, -temp);
    line(temp, temp, -temp, -temp);
    resetMatrix();
    e.hp-=dmg;
    ticks-=1;
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
  void move() {
  }
} 


/*
    e = new Dummy(-1000000000, -1000000000);
 hp =
 atk =
 atkRange =
 atkSpd =
 initAtk = (int)random(0, atkSpd);
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
    atkSpd = 15;
    initAtk = (int)random(0, atkSpd);
    range = 25;
    collRange = 25;
    spd = 4;
    ospd = spd;
    def = 0;
    pdef = 0;
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
  void move() {
    x += xSpd;
    y += ySpd;
    xSpd = -(x-e.x)/(dist(x, y, e.x, e.y)/spd);
    ySpd = -(y-e.y)/(dist(x, y, e.x, e.y)/spd);
  }
  
  Troop death() {
    return this;
  }
} 

class Spear extends Troop {
  float realAtkRange;
  int ammo;
  HashSet<Proj> projs;
  Spear(float x, float y, HashSet<Proj> p) {
    super(x, y);
    projs = p;
    e = new Dummy(-1000000000, -1000000000);
    hp = 700;
    atk = 150;
    atkRange = 1000;
    atkSpd = 30;
    initAtk = (int)random(0, atkSpd);
    range = 90;
    collRange = 25;
    spd = 2;
    ospd = spd;
    def = 0;
    pdef = 0;
    ammo = 5;
    realAtkRange = 130;
  } 

  void display(color c) {
    troopDispSettings(c);
    ellipse(x, y, 25, 25);
    translate(x, y);
    rotate(atan2(y-e.y, x-e.x));
    noStroke();
    rectMode(CORNER);
    rect(10, 12, -100, 2);
    rotate(4.5);
    if (ammo>4) {
      rotate(0.1);
      rect(10, 12, -100, 2);
    }
    if (ammo>3) {
      rotate(0.1);
      rect(10, 12, -100, 2);
    }
    if (ammo>2) {
      rotate(0.1);
      rect(10, 12, -100, 2);
    }
    if (ammo>1) {
      rotate(0.1);
      rect(10, 12, -100, 2);
    }
    if (ammo>0) {
      rotate(0.1);
      rect(10, 12, -100, 2);
    }
    resetMatrix();
  } 

  void attack() {
    if ((frameCount-initAtk)%atkSpd != 0) {
      return;
    } 
    if (ammo>0&&dist(x, y, e.x, e.y)>2*realAtkRange) {
      ammo-=1;
      TSpear temp = new TSpear(x, y, e.x+random(-50, 50), e.y+random(-50, 50));
      temp.setSpeed();
      projs.add(temp);
    }
    if (dist(x, y, e.x, e.y) < realAtkRange) {
      e.spd = 0;
      e.hp-=Math.max(0, atk-e.def);
    }
  }
  void move() {
    x += xSpd;
    y += ySpd;
    xSpd = -(x-e.x)/(dist(x, y, e.x, e.y)/spd);
    ySpd = -(y-e.y)/(dist(x, y, e.x, e.y)/spd);
  }
  
  Troop death() {
    return this;
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
    initAtk = (int)random(0, atkSpd);
    range = 25;
    collRange = 25;
    spd = 2;
    ospd = spd;
    def = 25;
    pdef = 50;
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
  void move() {
    x += xSpd;
    y += ySpd;
    xSpd = -(x-e.x)/(dist(x, y, e.x, e.y)/spd);
    ySpd = -(y-e.y)/(dist(x, y, e.x, e.y)/spd);
  }
  Troop death() {
    return this;
  }
} 

class Archer extends Troop {
  HashSet<Proj> projs;
  Archer(float x, float y, HashSet<Proj> p) {
    super(x, y);
    projs = p;
    e = new Dummy(-1000000000, -1000000000);
    hp = 500;
    atk = 0;
    atkRange = 1010;
    atkSpd = 30;
    initAtk = (int)random(0, atkSpd);
    range = 1000;
    collRange = 25;
    spd = 1;
    ospd = spd;
    def = 0;
    pdef = 0;
  }
  void display(color c) {
    troopDispSettings(c);
    ellipse(x, y, 25, 25);
    translate(x, y);
    rotate(atan2(y-e.y, x-e.x));
    noFill();
    strokeWeight(2);
    quad(-17, -3, -17, 5, -10, 20, -10, -15);
    resetMatrix();
  }

  void attack() {
    if ((frameCount-initAtk)%atkSpd != 0) {
      return;
    } 
    Arrow temp = new Arrow(x, y, e.x+random(-4, 4), e.y+random(-4, 4));
    temp.setSpeed();
    projs.add(temp);
  }

  void move() {
    x += xSpd;
    y += ySpd;
    xSpd = -(x-e.x)/(dist(x, y, e.x, e.y)/spd);
    ySpd = -(y-e.y)/(dist(x, y, e.x, e.y)/spd);
  }
  
  Troop death() {
    return this;
  }
}

class Wall extends Troop {
  HashSet<Proj> projs;
  Wall(float x, float y, HashSet<Proj> p) {
    super(x, y);
    projs = p;
    e = new Dummy(-1000000000, -1000000000);
    hp = 10000;
    atk = 0;
    atkRange = 1010;
    atkSpd = 40;
    initAtk = (int)random(0, atkSpd);
    range = 1000;
    collRange = 100;
    spd = 0;
    ospd = spd;
    def = 50;
    pdef = 100;
  }
  void display(color c) {
    troopDispSettings(c);
    rectMode(CENTER);
    rect(x, y, 100, 100);
    ellipse(x, y, 25, 25);
    translate(x, y);
    rotate(atan2(y-e.y, x-e.x));
    noFill();
    strokeWeight(2);
    quad(-17, -3, -17, 5, -10, 20, -10, -15);
    resetMatrix();
  }

  void attack() {
    if ((frameCount-initAtk)%atkSpd != 0) {
      return;
    } 
    Arrow temp = new Arrow(x, y, e.x+random(-4, 4), e.y+random(-4, 4));
    temp.setSpeed();
    projs.add(temp);
  }

  void move() {
    x += xSpd;
    y += ySpd;
    xSpd = -(x-e.x)/(dist(x, y, e.x, e.y)/spd);
    ySpd = -(y-e.y)/(dist(x, y, e.x, e.y)/spd);
  }
  
  Troop death() {
    return this;
  }
}

class Sword extends Troop {
  HashSet<Troop> targs;
  HashSet<Flame> flames;
  int cycle;
  Sword(float x, float y, HashSet<Flame> f, HashSet<Troop> ts) {
    super(x, y);
    cycle = (int) random(0,3);
    e = new Dummy(-1000000000, -1000000000);
    hp = 2000;
    atk = 200;
    atkRange = 45;
    atkSpd = 15;
    initAtk = (int)random(0, atkSpd);
    range = 35;
    collRange = 35;
    spd = 4;
    ospd = spd;
    def = 50;
    pdef = 50;
    flames = f;
    targs = ts;
  } 

  void display(color c) {
    troopDispSettings(c);
    ellipse(x, y, 35, 35);
    translate(x, y);
    rotate(atan2(y-e.y, x-e.x));
    strokeWeight(2);
    rectMode(CORNER);
    if(cycle == 0) {
      fill(255,120,0);
      stroke(255,120,0);
    }
    if(cycle == 1) {
      fill(255,255,0);
      stroke(255,255,0);
    }
    if(cycle == 2) {
      fill(0,200,255);
      stroke(0,200,255);
    }
    rect(-25, -10, 2, 60);
    resetMatrix();
  } 

  void attack() {
    if ((frameCount-initAtk)%atkSpd != 0) {
      return;
    } 
    e.hp-=atk;
    if(cycle == 0) {
      flames.add(new Flame(e.x + random(-20, 20), e.y + random(-20, 0), 30, 30, 5, frameCount, 5));
      for(Troop i : targs) {
        if(dist(e.x, e.y, i.x, i.y) < 75) {
          flames.add(new Flame(i.x + random(-20, 20), i.y + random(-20, 0), 30, 15, 5, frameCount, 5));
        }
      }
    }
    if(cycle == 1) {
      Arc arc = new Arc(100, 100, 10, targs, e);
      arc.updateNext();
    }
    if(cycle == 2) {
      frozen.put(e,60);
      for(Troop i : targs) {
        if(dist(e.x, e.y, i.x, i.y) < 30) {
          frozen.put(i,30);
        }
      }
    }
    cycle++;
    cycle %= 3;
  }

  void move() {
    x += xSpd;
    y += ySpd;
    xSpd = -(x-e.x)/(dist(x, y, e.x, e.y)/spd);
    ySpd = -(y-e.y)/(dist(x, y, e.x, e.y)/spd);
  }
  
  Troop death() {
    return this;
  }
}

class Heavy extends Troop {
  HashSet<Blast> blasts;
  Heavy(float x, float y, HashSet<Blast> b) {
    super(x, y);
    e = new Dummy(-1000000000, -1000000000);
    hp = 5000;
    atk = 0;
    atkRange = 80;
    atkSpd = 60;
    initAtk = (int)random(0, atkSpd);
    range = 55;
    collRange = 55;
    spd = 1.5;
    ospd = spd;
    def = 0;
    pdef = 0;
    blasts = b;
  } 

  void display(color c) {
    troopDispSettings(c);
    rectMode(CORNER);
    ellipse(x, y, 50, 50);
    translate(x, y);
    rotate(atan2(y-e.y, x-e.x));
    strokeWeight(2);
    rect(-30, -10, 4, 50);
    fill(c);
    ellipse(-26, 40, 25, 25);
    line(-26, 60, -26, 20);
    line(-6, 40, -46, 40);
    resetMatrix();
  }

  void attack() {
    if ((frameCount-initAtk)%atkSpd != 0) {
      return;
    } 
    blasts.add(new Blast(e.x, e.y, 60, 5, 100));
  }

  void move() {
    x += xSpd;
    y += ySpd;
    xSpd = -(x-e.x)/(dist(x, y, e.x, e.y)/spd);
    ySpd = -(y-e.y)/(dist(x, y, e.x, e.y)/spd);
  }
}

class Paladin extends Troop {
  HashSet<Proj> projs;
  HashSet<Proj> eprojs;
  Paladin(float x, float y, HashSet<Proj> p, HashSet<Proj> ep) {
    super(x, y);
    e = new Dummy(-1000000000, -1000000000);
    hp = 2000;
    atk = 5;
    atkRange = 900;
    atkSpd = 20;
    initAtk = (int)random(0, atkSpd);
    range = 55;
    collRange = 55;
    spd = 1;
    ospd = spd;
    def = 30;
    pdef = 20;
    projs = p;
    eprojs = ep;
  } 

  void display(color c) {
    troopDispSettings(c);
    ellipse(x, y, 50, 50);
    noFill();
    ellipse(x, y, 60, 60);
    //rectMode(CORNER);
    //translate(x, y);
    //rotate(atan2(y-e.y, x-e.x));
    //strokeWeight(2);
    //rect(-30, -10, 4, 50);
    //fill(c);
    //ellipse(-26, 40, 25, 25);
    //line(-26, 60, -26, 20);
    //line(-6, 40, -46, 40);
    //resetMatrix();
  }

  void attack() {
    if ((frameCount-initAtk)%atkSpd != 0) {
      return;
    } 
    for (int i = 55; i < 100; i++) {
      noFill();
      stroke(0, 255, 255);
      ellipse(x, y, i, i);
    }
    HashSet<Proj> toRemove = new HashSet();
    for (Proj i : eprojs) {
      if (dist(x, y, i.x, i.y) < 100) {
        Proj temp = i;
        toRemove.add(i);
        temp.xSpd*=-1;
        temp.ySpd*=-1;
        temp.xSpd+=random(-2, 2);
        temp.ySpd+=random(-2, 2);
        temp.angle = atan2(temp.ySpd, temp.xSpd);
        projs.add(temp);
      }
    }
    eprojs.removeAll(toRemove);
  }

  void move() {
    x += xSpd;
    y += ySpd;
    xSpd = -(x-e.x)/(dist(x, y, e.x, e.y)/spd);
    ySpd = -(y-e.y)/(dist(x, y, e.x, e.y)/spd);
  }
}

class Summoner extends Troop {
  float atkSpd2, atkSpd3, initAtk2, initAtk3;
  HashSet<Troop> ts;
  Summoner(float x, float y, HashSet<Troop> t) {
    super(x, y);
    e = new Dummy(-1000000000, -1000000000);
    hp = 2000;
    atk = 0;
    atkRange = 10000;
    atkSpd = 40;
    atkSpd2 = 90;
    atkSpd3 = 180;
    initAtk = (int)random(0, atkSpd);
    initAtk2 = (int)random(0, 59);
    initAtk3 = (int)random(0, 59);
    range = 600;
    collRange = 55;
    spd = 1;
    ospd = spd;
    def = 0;
    pdef = 0;
    ts = t;
  }

  void display(color c) {
    troopDispSettings(c);
    translate(x, y);
    triangle(0, -25, -10, 15, 10, 15);
    resetMatrix();
  }

  void attack() {
    if ((frameCount-initAtk)%atkSpd == 0) {
      Soldier temp = new Soldier(x, y);
      temp.hp=200;
      temp.atk=50;
      ts.add(temp);
    }
    if ((frameCount-initAtk2)%atkSpd2 == 0) {
      Shield temp = new Shield(x, y);
      temp.hp=500;
      temp.atk=25;
      ts.add(temp);
    }
    if ((frameCount-initAtk3)%atkSpd3 == 0) {
      Soldier temp = new Soldier(x, y);
      temp.hp=500;
      temp.atk=100;
      ts.add(temp);
    }
  }

  void move() {
    x += xSpd;
    y += ySpd;
    xSpd = -(x-e.x)/(dist(x, y, e.x, e.y)/spd);
    ySpd = -(y-e.y)/(dist(x, y, e.x, e.y)/spd);
  }
}

class Ewiz extends Troop {
  HashSet<Proj> projs;
  HashSet<Troop> targs;
  Ewiz(float x, float y, HashSet<Proj> p, HashSet<Troop> t) {
    super(x, y);
    projs = p;
    e = new Dummy(-1000000000, -1000000000);
    hp = 500;
    atk = 0;
    atkRange = 1010;
    atkSpd = 100;
    initAtk = (int)random(0, atkSpd);
    range = 1000;
    collRange = 25;
    spd = 1;
    ospd = spd;
    def = 0;
    pdef = 0;
    targs = t;
  }
  void display(color c) {
    troopDispSettings(c);
    ellipse(x, y, 25, 25);
    translate(x, y);
    rotate(atan2(y-e.y, x-e.x));
    strokeWeight(2);
    rectMode(CORNER);
    rect(-15, -10, 2, 50);
    fill(c);
    ellipse(-14, 40, 5, 5);
    resetMatrix();
  }

  void attack() {
    if ((frameCount-initAtk)%atkSpd != 0) {
      return;
    } 
    Bolt temp = new Bolt(x, y, e.x+random(-40, 40), e.y+random(-40, 40), targs);
    temp.setSpeed();
    projs.add(temp);
  }

  void move() {
    x += xSpd;
    y += ySpd;
    xSpd = -(x-e.x)/(dist(x, y, e.x, e.y)/spd);
    ySpd = -(y-e.y)/(dist(x, y, e.x, e.y)/spd);
  }
}

class Fwiz extends Troop {
  HashSet<Proj> projs;
  HashSet<Blast> blasts;
  HashSet<Flame> flames;
  Fwiz(float x, float y, HashSet<Proj> p, HashSet<Blast> b, HashSet<Flame> f) {
    super(x, y);
    projs = p;
    e = new Dummy(-1000000000, -1000000000);
    hp = 500;
    atk = 0;
    atkRange = 1010;
    atkSpd = 100;
    initAtk = (int)random(0, atkSpd);
    range = 1000;
    collRange = 25;
    spd = 1;
    ospd = spd;
    def = 0;
    pdef = 0;
    blasts = b;
    flames = f;
  }
  void display(color c) {
    troopDispSettings(c);
    ellipse(x, y, 25, 25);
    translate(x, y);
    rotate(atan2(y-e.y, x-e.x));
    strokeWeight(2);
    rectMode(CORNER);
    rect(-15, -10, 2, 50);
    fill(c);
    ellipse(-14, 40, 5, 5);
    resetMatrix();
  }

  void attack() {
    if ((frameCount-initAtk)%atkSpd != 0) {
      return;
    } 
    Fireball temp = new Fireball(x, y, e.x+random(-40, 40), e.y+random(-40, 40), blasts, flames);
    temp.setSpeed();
    projs.add(temp);
  }

  void move() {
    x += xSpd;
    y += ySpd;
    xSpd = -(x-e.x)/(dist(x, y, e.x, e.y)/spd);
    ySpd = -(y-e.y)/(dist(x, y, e.x, e.y)/spd);
  }
}

class Pwiz extends Troop {
  HashSet<Proj> projs;
  HashSet<Poison> poisons;
  HashSet<Troop> es;
  Pwiz(float x, float y, HashSet<Proj> p, HashSet<Poison> ps, HashSet<Troop> es) {
    super(x, y);
    projs = p;
    this.es = es;
    e = new Dummy(-1000000000, -1000000000);
    hp = 500;
    atk = 0;
    atkRange = 1010;
    atkSpd = 300;
    initAtk = (int)random(0, atkSpd);
    range = 1000;
    collRange = 25;
    spd = 1;
    ospd = spd;
    def = 0;
    pdef = 0;
    poisons = ps;
  }
  void display(color c) {
    troopDispSettings(c);
    ellipse(x, y, 25, 25);
    translate(x, y);
    rotate(atan2(y-e.y, x-e.x));
    strokeWeight(2);
    rectMode(CORNER);
    rect(-15, -10, 2, 50);
    fill(c);
    ellipse(-14, 40, 5, 5);
    resetMatrix();
  }

  void attack() {
    if ((frameCount-initAtk)%atkSpd != 0) {
      return;
    } 
    Parrow temp = new Parrow(x, y, e.x+random(-40, 40), e.y+random(-40, 40), poisons, es);
    temp.setSpeed();
    projs.add(temp);
  }

  void move() {
    x += xSpd;
    y += ySpd;
    xSpd = -(x-e.x)/(dist(x, y, e.x, e.y)/spd);
    ySpd = -(y-e.y)/(dist(x, y, e.x, e.y)/spd);
  }
}

class Iwiz extends Troop {
  HashSet<Proj> projs;
  HashSet<Flame> ef;
  Iwiz(float x, float y, HashSet<Proj> p, HashSet<Flame> ef) {
    super(x, y);
    projs = p;
    e = new Dummy(-1000000000, -1000000000);
    hp = 500;
    atk = 0;
    atkRange = 710;
    atkSpd = 10;
    initAtk = (int)random(0, atkSpd);
    range = 300;
    collRange = 25;
    spd = 2;
    ospd = spd;
    def = 0;
    pdef = 0;
    this.ef = ef;
  }
  void display(color c) {
    troopDispSettings(c);
    ellipse(x, y, 25, 25);
    translate(x, y);
    rotate(atan2(y-e.y, x-e.x));
    strokeWeight(2);
    rectMode(CORNER);
    rect(-15, -10, 2, 50);
    fill(c);
    ellipse(-14, 40, 5, 5);
    resetMatrix();
  }

  void attack() {
    if ((frameCount-initAtk)%atkSpd != 0) {
      return;
    } 
    for(int i = 0; i < 3; i++) {
      Icebolt temp = new Icebolt(x, y, e.x+random(-80, 80), e.y+random(-80, 80), ef);
      temp.setSpeed();
      projs.add(temp);
    }
  }

  void move() {
    x += xSpd;
    y += ySpd;
    xSpd = -(x-e.x)/(dist(x, y, e.x, e.y)/spd);
    ySpd = -(y-e.y)/(dist(x, y, e.x, e.y)/spd);
  }
}

void troopDispSettings(color c) {
  stroke(c);
  strokeWeight(4);
  fill(c, 120);
} 

class Dragon extends Troop {
  HashSet<Flame> flames;
  float angle, tAngle;
  Dragon(float x, float y, float a, HashSet<Flame> f) {
    super(x, y);
    angle = a;
    flames = f;
    e = new Dummy(-1000000000, -1000000000);
    hp = 5000;
    atk = 0;
    atkRange = 100;
    atkSpd = 4;
    initAtk = (int)random(0, atkSpd);
    range = 0;
    collRange = 1;
    spd = 3;
    ospd = spd;
    def = 0;
    pdef = -100;
  }

  void display(color c) {
    troopDispSettings(c);
    translate(x, y);
    rotate(angle);
    quad(-25, -10, -25, 10, 20, 5, 20, -5);
    quad(-25, -12, -25, 12, -50, 8, -50, -8);
    line(-30, -6, -40, -6);
    line(-30, 6, -40, 6);
    quad(-50, 5, -50, -5, -70, -4, -70, 4);
    quad(20, -7, 20, 7, 30, 4, 30, -4);
    quad(30, -7, 30, 7, 40, 4, 40, -4);
    quad(40, -7, 40, 7, 50, 4, 50, -4);
    quad(50, -7, 50, 7, 60, 4, 60, -4);
    quad(60, 3, 60, -3, 80, -2, 80, 2);
    quad(-15, -10, 0, -9, 10, -110, -16, -85);
    quad(-15, 10, 0, 9, 10, 110, -16, 85);
    resetMatrix();
  }

  void move() {
    tAngle = atan2(y-e.y, x-e.x);
    if (angle>PI) {
      angle = -PI;
    }
    if (angle < -PI) {
      angle = PI;
    }
    if (abs(angle-tAngle) > 0.5||abs(angle+tAngle) < 0.5) {
      if (turnDir(angle, tAngle)) {
        angle+=0.05;
      } else {
        angle-=0.05;
      }
    }
    xSpd = -cos(angle) * dist(x, y, e.x, e.y)/(dist(x, y, e.x, e.y)/spd);
    ySpd = -sin(angle) * dist(x, y, e.x, e.y)/(dist(x, y, e.x, e.y)/spd);
    x+=xSpd;
    y+=ySpd;
  }

  boolean turnDir(float angle, float tAngle) {
    if (tAngle > 0 && angle < 0) {
      if (angle < -PI/2 && tAngle > PI/2) {
        return false;
      } else if (angle > -PI/2 && tAngle < PI/2) {
        return true;
      } else {
        return true;
      }
    } else if (tAngle < 0 && angle > 0) {
      if (tAngle < -PI/2 && angle > PI/2) {
        return true;
      } else if (tAngle > -PI/2 && angle < PI/2) {
        return false;
      } else {
        return false;
      }
    } else {
      return angle < tAngle;
    }
  }

  void attack() {
    if ((frameCount-initAtk)%atkSpd != 0) {
      return;
    } 
    flames.add(new Flame(x + xSpd*20 + random(-25, 25), y + ySpd*20 + random(-25, 25), 50, random(30, 90), 4, frameCount, 1));
    flames.add(new Flame(x + xSpd*50 + random(-50, 50), y + ySpd*50 + random(-50, 50), 50, random(30, 90), 4, frameCount, 1));
  }
  
  Troop death() {
    return this;
  }
}


class TSpear extends Proj {
  TSpear(float x, float y, float tx, float ty) {
    super(x, y, tx, ty);
    dmg = 300;
    spd = 9;
    range = 50;
  }
  void display(color c) {
    troopDispSettings(c);
    noStroke();
    translate(x, y);
    rotate(angle);
    rectMode(CORNER);
    rect(0, 0, -90, 3);
    resetMatrix();
  }
  Proj collide(Troop t) {
    t.hp-=Math.max(0, dmg-t.pdef);
    return this;
  }
}

class Arrow extends Proj {
  Arrow(float x, float y, float tx, float ty) {
    super(x, y, tx, ty);
    dmg = 180;
    spd = 10;
    range = 15;
  }
  void display(color c) {
    stroke(c, 120);
    strokeWeight(4);
    translate(x, y);
    rotate(angle);
    line(0, 0, 20, 0);
    resetMatrix();
  }
  Proj collide(Troop t) {
    t.hp-=Math.max(0, dmg-t.pdef);
    return this;
  }
}

class Bolt extends Proj {
  HashSet<Troop> targs;
  Bolt(float x, float y, float tx, float ty, HashSet<Troop> t) {
    super(x, y, tx, ty);
    dmg = 200;
    spd = 30;
    range = 30;
    targs = t;
  }
  void display(color c) {
    stroke(c, 20);
    strokeWeight(1);
    translate(x, y);
    rotate(angle);
    //line(0, 0, 40, 0);
    for (int i = 0; i < 7; i++) {
      line(random(-3, 3), random(-3, 3), random(30, 70), random(-3, 3));
    }
    for (int i = 0; i < 7; i++) {
      line(random(95, 105), random(-3, 3), random(30, 70), random(-3, 3));
    }
    resetMatrix();
  }
  Proj collide(Troop t) {
    t.hp-=Math.max(0, dmg-t.pdef);
    Arc arc = new Arc(200, 150, 20, targs, t);
    arc.updateNext();
    return this;
  }
}

class Parrow extends Proj {
  HashSet<Poison> ps;
  HashSet<Troop> es;
  Parrow(float x, float y, float tx, float ty, HashSet<Poison> p, HashSet<Troop> es) {
    super(x, y, tx, ty);
    this.es = es;
    dmg = 180;
    spd = 10;
    range = 15;
    ps = p;
  }
  void display(color c) {
    stroke(0, 255, 0, 120);
    fill(0, 255, 0, 120);
    strokeWeight(4);
    translate(x, y);
    rotate(angle);
    triangle(0, 15, 0, -15, 20, 0);
    ellipse(0, 0, 15, 15);
    resetMatrix();
  }
  Proj collide(Troop t) {
    t.hp-=Math.max(0, dmg-t.pdef);
    if (!poisoned.contains(t)) {
      ps.add(new Poison(t, 50, 7, frameCount, 30, ps, es));
    }
    return this;
  }
}

class Fireball extends Proj {
  HashSet<Blast> blasts;
  HashSet<Flame> flames;
  Fireball(float x, float y, float tx, float ty, HashSet<Blast> b, HashSet<Flame> f) {
    super(x, y, tx, ty);
    dmg = 80;
    spd = 10;
    range = 15;
    blasts = b;
    flames = f;
  }

  void display(color c) {
    float temp2 = random(50, 150);
    stroke(255, temp2, 0);
    fill(255, temp2, 0);
    strokeWeight(4);
    translate(x, y);
    ellipse(0, 0, 15, 15);
    rotate(angle);
    line(random(-5, 5), random(-5, 5), 20, random(-5, 5));
    line(random(-5, 5), random(0, 10), 17, random(-5, 5));
    line(random(-5, 5), random(-10, 0), 17, random(-5, 5));
    resetMatrix();
  }
  Proj collide(Troop t) {
    for (int i = 0; i < 3; i++) {
      blasts.add(new Blast(x+random(-30, 30), y+random(-30, 30), random(30, 100), 3, 30));
      flames.add(new Flame(x + random(-50, 50), y + random(-50, 50), 40, random(30, 120), 5, frameCount, 5));
      flames.add(new Flame(x + random(-50, 50), y + random(-50, 50), 40, random(30, 120), 5, frameCount, 5));
    }
    return this;
  }
}

class Icebolt extends Proj {
  int charges;
  HashSet<Flame> ef;
  Icebolt(float x, float y, float tx, float ty, HashSet<Flame> ef) {
    super(x, y, tx, ty);
    dmg = 50;
    spd = 10;
    range = 15;
    charges = 5;
    this.ef = ef;
  }

  void display(color c) {
    float temp2 = random(100, 200);
    stroke(0, temp2, 255);
    //fill(0, temp2, 255);
    strokeWeight(4);
    translate(x, y);
    //ellipse(0, 0, 15, 15);
    //rotate(angle);
    line(random(-15,15),random(-15,15),random(-15,15),random(-15,15));
    line(random(-15,15),random(-15,15),random(-15,15),random(-15,15));
    line(random(-15,15),random(-15,15),random(-15,15),random(-15,15));
    line(random(-15,15),random(-15,15),random(-15,15),random(-15,15));
    line(random(-15,15),random(-15,15),random(-15,15),random(-15,15));
    line(random(-15,15),random(-15,15),random(-15,15),random(-15,15));
    resetMatrix();
  }
  
  Proj collide(Troop t) {
    HashSet<Flame> toRemove = new HashSet();
    for(Flame i : ef) {
      if(dist(x, y, i.x, i.y) < 100) {
        toRemove.add(i);
      }
    }
    ef.removeAll(toRemove);
    if(frozen.containsKey(t)) {
      t.hp-=dmg;
      charges+=2;
    }
    t.spd-=0.3;
    if(t.spd < 0) {
      frozen.put(t, 150);
      charges -= 1;
    }
    if(charges < 0) {
      return this;
    } else {
    charges -= 1;
      return null;
    }
  }
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
  //println(atan2(mouseY - height/2, mouseX - width/2));
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
    updateFlames(rFlame, blue);
    updateFlames(bFlame, red);
    if (blue.size() < red.size()) {
      update(blue, red, bToAdd, color(0, 0, 255));
      updateProj(bProj, red, color(0, 0, 255));
      updateBlasts(bBlast, red, color(0, 0, 255));
      updateFlames(rFlame, blue);
      update(red, blue, rToAdd, color(255, 0, 0));
      updateProj(rProj, blue, color(255, 0, 0));
      updateBlasts(rBlast, blue, color(255, 0, 0));
    } else {
      update(red, blue, rToAdd, color(255, 0, 0));
      updateProj(rProj, blue, color(255, 0, 0));
      updateBlasts(rBlast, blue, color(255, 0, 0));
      updateFlames(bFlame, red);
      update(blue, red, bToAdd, color(0, 0, 255));
      updateProj(bProj, red, color(0, 0, 255));
      updateBlasts(bBlast, red, color(0, 0, 255));
    }
    updatePoisons(bPoison);
    updatePoisons(rPoison);
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

void update(HashSet<Troop> a, HashSet<Troop> b, HashSet<Troop> toAdd, color c) {
  HashSet<Troop> toRemove = new HashSet();
  for (Troop i : a) {
    if (i.hp < 1) {
      toRemove.add(i);
    } 
    if(frozen.containsKey(i)) {
      if(frozen.get(i) < 0) {
        frozen.remove(i);
      } else {
        frozen.put(i, frozen.get(i)-1);
      }
      i.display(color(0,200,255));
      continue;
    }
    i.display(c);
    Troop min = i.e;
    if (!b.contains(min)) {
      min = new Dummy(-1000000000, -1000000000);
    } 
    float dist = dist(i.x, i.y, min.x, min.y);
    for (Troop j : b) {
      if (j.invisible) {
        continue;
      }
      float temp = dist(i.x, i.y, j.x, j.y);
      if (temp<dist) {
        dist = temp;
        min = j;
      } 
      i.e = min;
    } 
    if (dist>i.range) {
      if(i.spd < i.ospd) {
        i.spd += 0.01;
      }
      i.spd = Math.max(0, i.spd);
      i.move();
    } 
    if (dist<i.atkRange) {
      i.attack();
    } 
    for (Troop j : a) {
      if (i == j) continue;
      if (dist(i.x, i.y, j.x, j.y)<i.collRange) {
        i.collide();
        i.move();
      }
    }
  } 
  a.removeAll(toRemove);
  a.addAll(toAdd);
  toAdd.clear();
} 

void updateProj(HashSet<Proj> a, HashSet<Troop> b, color c) {
  HashSet<Proj> toRemove = new HashSet();
  for (Proj i : a) {
    i.display(c);
    i.move();
    if (i.x>width||i.x<0||i.y>height||i.y<0) {
      toRemove.add(i);
    }
    for (Troop j : b) {
      if (dist(i.x, i.y, j.x, j.y) < i.range) {
        toRemove.add(i.collide(j));
      }
    }
  }
  a.removeAll(toRemove);
}

void updateBlasts(HashSet<Blast> a, HashSet<Troop> b, color c) {
  HashSet<Blast> toRemove = new HashSet();
  for (Blast i : a) {
    i.dur-=1;
    if (i.dur<0) {
      toRemove.add(i);
    }
    i.display(c);
    for (Troop j : b) {
      float dist = dist(i.x, i.y, j.x, j.y);
      if (dist < i.range) {
        if (dist == 0) {
          j.hp-=i.dmg;
        }
        j.hp-=i.dmg*dist/i.range;
      }
    }
  }
  a.removeAll(toRemove);
}

void updateFlames(HashSet<Flame> a, HashSet<Troop> b) {
  HashSet<Flame> toRemove = new HashSet();
  for (Flame i : a) {
    if (i.dur < 0) {
      toRemove.add(i);
    }
    i.dur -= 1;
    i.display();
    if ((frameCount-i.init)%i.spd != 0) {
      continue;
    }
    for (Troop j : b) {
      if (dist(i.x, i.y, j.x, j.y) < i.range) {
        j.hp-=i.dmg;
      }
    }
  }
  a.removeAll(toRemove);
}

void updatePoisons(HashSet<Poison> a) {
  HashSet<Poison> toAdd = new HashSet();
  HashSet<Poison> toRemove = new HashSet();
  for (Poison i : a) {
    if (i.ticks < 0) {
      toRemove.add(i);
      poisoned.remove(i.e);
    }
    i.display();
    toAdd.addAll(i.toAdd);
    if ((frameCount - i.init) % i.spd == 0) {
      i.tick();
    }
  }
  a.addAll(toAdd);
  a.removeAll(toRemove);
}

void keyReleased() {
  if (key == '1') selected = 1;
  if (key == '2') selected = 2;
  if (key == '3') selected = 3;
  if (key == '4') selected = 4;
  if (key == '5') selected = 5;
  if (key == '6') selected = 6;
  if (key == '7') selected = 7;
  if (key == '8') selected = 8;
  if (key == '9') selected = 9;
  if (key == '0') selected = 10;
  if (key == 'q') rPreset(1);
  if (key == 'a') bPreset(1);
  if (key == 'w') rPreset(2);
  if (key == 's') bPreset(2);
  if (key == 'e') rPreset(3);
  if (key == 'd') bPreset(3);
  if (key == 'r') rPreset(4);
  if (key == 'f') bPreset(4);
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
  if (mouseButton != LEFT) return;
  for (Button i : buttons) {
    i.display();
    i.pressed();
  } 
  if (startGame) {
    return;
  }
  spawn();
} 

void mouseDragged() {
  if (mouseButton!=RIGHT) {
    return;
  }
  if (frameCount%2==0) {
    spawn();
  }
}

void spawn() { 
  HashSet<Troop> temp = new HashSet();
  HashSet<Troop> etemp = new HashSet(); 
  HashSet<Troop> toAdd = new HashSet();
  if (mouseY>height-100) {
    return;
  } 
  HashSet<Proj> ptemp = new HashSet();
  HashSet<Proj> ptemp2 = new HashSet();
  HashSet<Blast> btemp = new HashSet();
  HashSet<Flame> ftemp = new HashSet();
  if (mouseX<=width/2) {
    temp = blue;
    etemp = red;
    ptemp = bProj;
    btemp = bBlast;
    ptemp2 = rProj;
    ftemp = bFlame;
    toAdd = bToAdd;
  } else {
    temp = red;
    etemp = blue;
    ptemp = rProj;
    btemp = rBlast;
    ptemp2 = bProj;
    ftemp = rFlame;
    toAdd = rToAdd;
  } 
  if (selected == 1) {
    temp.add(new Soldier(mouseX, mouseY));
  } else if (selected == 2) {
    temp.add(new Spear(mouseX, mouseY, ptemp));
  } else if (selected == 3) {
    temp.add(new Shield(mouseX, mouseY));
  } else if (selected == 4) {
    temp.add(new Archer(mouseX, mouseY, ptemp));
  } else if (selected == 5) {
    temp.add(new Sword(mouseX, mouseY, ftemp, etemp));
  } else if (selected == 6) {
    temp.add(new Heavy(mouseX, mouseY, btemp));
  } else if (selected == 7) {
    temp.add(new Paladin(mouseX, mouseY, ptemp, ptemp2));
  } else if (selected == 8) {
    temp.add(new Summoner(mouseX, mouseY, toAdd));
  } else if (selected == 9) {
    temp.add(new Ewiz(mouseX, mouseY, ptemp, etemp));
  } else if (selected == 10) {
    temp.add(new Fwiz(mouseX, mouseY, ptemp, btemp, ftemp));
  }
}

void rPreset(int n) {
  if (n == 1) {
    for (int i = 25; i < height-75; i+=25) {
      red.add(new Shield(width/2+50, i));
    }
    for (int i = 0; i < height-100; i+=25) {
      red.add(new Shield(width/2+50, i));
    }
    for (int i = 25; i < height-75; i+=25) {
      red.add(new Spear(width/2+75, i, rProj));
      red.add(new Spear(width/2+100, i, rProj));
      red.add(new Heavy(width/2+150, i, rBlast));
    }
    for (int i = 25; i < height-75; i+=25) {
      red.add(new Archer(width-75, i, rProj));
      red.add(new Archer(width-100, i, rProj));
      //red.add(new Summoner(width-125, i, rToAdd));
    }
  } else if (n == 2) {
    for (int i = 50; i < height-100; i+=100) {
      red.add(new Ewiz(width-50, i, rProj, blue));
      red.add(new Fwiz(width-50, i+25, rProj, rBlast, rFlame));
      //red.add(new Pwiz(width-50, i+50, rProj, rPoison, blue));
    }
  } else if (n == 3) {
    for (int i = 50; i < height-100; i+=100) {
      red.add(new Dragon(width-100, i, 0, rFlame));
    }
  } else if (n == 4) {
    for (int i = 25; i < height-100; i+=25) {
      for (int j = width/2+150; j < width/2+750; j+=50) {
        red.add(new Soldier(j, i));
      }
    }
  }
}

void bPreset(int n) {
  if (n == 1) {
    for (int i = 25; i < height-75; i+=25) {
      blue.add(new Shield(width/2-50, i));
    }
    for (int i = 0; i < height-100; i+=25) {
      blue.add(new Shield(width/2-50, i));
    }
    for (int i = 25; i < height-75; i+=25) {
      blue.add(new Spear(width/2-75, i, bProj));
      blue.add(new Spear(width/2-100, i, bProj));
      blue.add(new Heavy(width/2-150, i, bBlast));
    }
    for (int i = 25; i < height-75; i+=25) {
      blue.add(new Archer(75, i, bProj));
      blue.add(new Archer(100, i, bProj));
      //blue.add(new Summoner(125, i, bToAdd));
    }
  } else if (n == 2) {
    for (int i = 50; i < height-100; i+=100) {
      blue.add(new Ewiz(50, i, bProj, red));
      blue.add(new Fwiz(50, i+25, bProj, bBlast, bFlame));
      //blue.add(new Pwiz(50, i+50, bProj, bPoison, red));
      blue.add(new Iwiz(50, i-25, bProj, rFlame));
    }
  } else if (n == 3) {
    for (int i = 50; i < height-100; i+=100) {
      //red.add(new Dragon(width-100, i, 0, rFlame));
      blue.add(new Dragon(100, i, PI, bFlame));
    }
  } else if (n == 4) {
    for (int i = 25; i < height-100; i+=25) {
      for (int j = width/2-150; j > width/2-750; j-=50) {
        blue.add(new Soldier(j, i));
      }
    }
  }
}
