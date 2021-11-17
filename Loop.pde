
import processing.video.*;
import drop.*;

import java.util.Arrays;
  
SDrop drop;

JSONObject json;

VMovie[] movies;
int MAXMOVIES=10; //

int selected = -1;
float hoffset=0;
float voffset=0;
int hex = 0;
Boolean full = false;


/* If you want fullscreen just tweak the data/prefs.json to match your displays size 
and run the sketch in PRESENT mode. (This is because in fullscreen Drop wont work)
*/

//WINDOWED
void settings() {
  json = loadJSONObject("prefs.json");
  int ww = json.getInt("window_width"); 
  int wh = json.getInt("window_height"); 
  size(ww,wh);
}


void setup() {
 if (!full) {
   int wx = json.getInt("window_x"); 
  int wy = json.getInt("window_y");
  surface.setLocation(wx, wy);
 }
  
  hex = json.getInt("color");
  background(hex);
 
  //////
  drop = new SDrop(this);
  movies = new VMovie[MAXMOVIES];
  cursor(CROSS);
}


void dropEvent(DropEvent theDropEvent) {
  println(theDropEvent);
  if(theDropEvent.isFile()) {
    File myFile = theDropEvent.file();
    println(myFile.getAbsolutePath());
    Movie tmovie = new Movie(this, myFile.getAbsolutePath()); //create the movie instance
    for (int i = 0; i < movies.length; i++) { // find an empty slot
       if (movies[i] == null){
          movies[i] = new VMovie(0, 0, 600,400, tmovie); // instantiate the class that controls it
          movies[i].hsize = tmovie.sourceWidth;
          movies[i].vsize = tmovie.sourceHeight;
          println(movies[i].xpos,movies[i].ypos, movies[i].hsize,movies[i].vsize);
          break;
       }
    }
  }
}


void mousePressed(){
    selected = intersects();
    println(selected);
     if (selected>=0){  
       hoffset = mouseX - movies[selected].xpos;
       voffset = mouseY - movies[selected].ypos;
     
       if (mouseButton==RIGHT){
         //movies[selected].toogle();
       }
     }
}

void mouseDragged(){
  if (selected>=0) {
    if (keyPressed && (keyCode==17)) {
      movies[selected].hsize -= pmouseX-mouseX;
      movies[selected].vsize -= pmouseY-mouseY;
    } else {
      if (selected>=0){
        movies[selected].xpos = mouseX - hoffset;
        movies[selected].ypos = mouseY - voffset;
      }
    }
  }
}

int intersects(){
  for (int i = movies.length-1; i >= 0; i--) { //reverse
  //for (int i = 0; i < movies.length; i++) {
    if (movies[i]!=null){
      if (mouseX > movies[i].xpos){
        if (mouseX < movies[i].xpos + movies[i].hsize){
          if (mouseY > movies[i].ypos){
            if (mouseY < movies[i].ypos + movies[i].vsize){
              return i;
            }
          }
        }
      }
    }
  }
  return -1;
}

void draw() {
   background(hex);
   for (int i = 0; i < movies.length; i++) {
      if (movies[i]!= null){
        movies[i].display();
      }
    }
}

void zAfter() {
  if (selected < movies.length){
  VMovie movethis = movies[selected+1];
  VMovie[] before = Arrays.copyOfRange(movies, 0, selected);
  VMovie[] after = Arrays.copyOfRange(movies, selected+2, movies.length);

  //Object source, int srcStartPosition, Object destination, int destStartPosition, int length
  System.arraycopy(before, 0, movies, 0, before.length);
  movies[selected+1] = movies[selected];
  movies[selected] = movethis;
  System.arraycopy(after, 0, movies, before.length+2, after.length);  
  selected = selected+1;
  }
}

void zBefore() { 
  if (selected>0){
    VMovie movethis = movies[selected-1];
    VMovie[] before = Arrays.copyOfRange(movies, 0, selected-1);
    VMovie[] after = Arrays.copyOfRange(movies, selected+1, movies.length);
    //Object source, int srcStartPosition, Object destination, int destStartPosition, int length
    System.arraycopy(before, 0, movies, 1, before.length);
    movies[selected-1] = movies[selected];
    movies[selected] = movethis;
    System.arraycopy(after, 0, movies, before.length+2, after.length);
    selected = selected-1;
  }
}

void keyPressed() {
  //println(keyCode);
  if (selected>=0){
    if (key=='x'){
      movies[selected].kill();
      movies[selected] = null;
      println("killing movie with X");
    } else if (key=='r'){ //RESET
      movies[selected].reset();
    }else if (key=='l'){ //LOOP
      movies[selected].loop();
    }else if (key=='p'){ //PLAY-PAUSE
      movies[selected].toogle();
    }else if (key=='a'){ //UP
      zAfter();
    }else if (key=='s'){ //DOWN
      zBefore();
    }
    
    if (keyCode==37){ // left --> bwd
      movies[selected].jump(-1);
    }else if (keyCode==39){ // right --> fwd
      movies[selected].jump(1);
    }else if (keyCode==38){ // SPEED UP
      movies[selected].speed(0.1);
    }else if (keyCode==40){ // SPEED DOWN
       movies[selected].speed(-0.1);
    }
  }
// left 37, right 39, up 38, down 40
}



 ////////////////////////////////////////////
 ////////////////////////////////////////////
 ////////////////////////////////////////////




class VMovie {
  float xpos;
  float ypos;
  float hsize;
  float vsize;
  Movie movie;
  int loopmode = 0;
  int playing = 1;
  float speed = 1;
  float vol = 1;

  VMovie(float tXpos, float tYpos, float thsize, float tvsize, Movie tmovie) {
    xpos = tXpos;
    ypos = tYpos;
    hsize = thsize;
    vsize = tvsize;
    movie = tmovie; 
    movie.play(); // loop() for loop playing
    //movie.noLoop();
    //    movie.volume(0.3);
  }
  
  void toogle(){
    if (playing==1){
      playing=0;
      movie.pause();
    }else{
     playing=1;
     movie.play();
    }
  }

  void display() {
    if (movie.available()) movie.read();
     image(movie, xpos, ypos, hsize, vsize);
  }
  
  void speed(float delta) {
    speed += delta;
    if (speed<=0) speed=0.01;
    movie.speed(speed);
  }
  
  void volume(int delta){
    vol += delta;
    if (vol>1) vol=1;
    if (vol<0) vol=0;
    movie.volume(vol);
  }
  
  void jump(int delta) {
    movie.jump( movie.time() + delta );
  }
  
  void reset(){
    movie.jump(0);
    movie.play();
  }
  
  void loop(){
    if (loopmode==1){
      loopmode=0;
      movie.noLoop();
     } else {
      float time = movie.time();
      loopmode=1;
      movie.stop();
      movie.jump(time);
      movie.loop();
     }
     println("loop", loopmode);
  }
   
  
  void kill(){
    movie.stop();
    movie.dispose();
  }
}
