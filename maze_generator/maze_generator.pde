/*
  Maze Generator
  --------------
  This program is able to generate and solve mazes.
  
  Controls:
    WASD - moves the player (player starts on the top left)
    SPACE - solve the maze from the player's position to the goal on the bottom right
    
    1 - generate a new maze
    2 - color the maze in rainbow colors!
    
  written by Adrian Margel, Winter Late 2017
 */


//a maze tile
public class Tile {
  int x;
  int y;

  //used for generating the maze
  boolean filled;

  //if there is a wall on each side of the tile
  boolean right;
  boolean left;
  boolean up;
  boolean down;
  
  public Tile(int x, int y) {
    this.x=x;
    this.y=y;
    filled=false;
    right=true;
    left=true;
    up=true;
    down=true;
  }
  
  public void display(float size) {
    stroke(0);
    if (right) {
      line(x*size+size, y*size, x*size+size, y*size+size);
    }
    if (left) {
      line(x*size, y*size, x*size, y*size+size);
    }
    if (up) {
      line(x*size, y*size, x*size+size, y*size);
    }
    if (down) {
      line(x*size, y*size+size, x*size+size, y*size+size);
    }
  }
}

//a maze solver tile that holds information used when solving the maze
public class TileSolver {
  //the number of tiles the tile is open/connected to that have not been marked as dead ends
  int value;
  public TileSolver(int value) {
    this.value=value;
  }
}

//a list of tiles that still need to be generated
ArrayList<Tile> tileBuffer = new ArrayList<Tile>();

//the maze
Tile[][] grid;

//a grid used to keep track of values while generating a solution to the maze
TileSolver[][] solveGrid;

//the maze generator's position
int fillerX=0;
int fillerY=0;

//the player's initial position
int solverX=0;
int solverY=0;

//if the maze is currently being solved or generated
boolean generating=true;
boolean solving=false;

//the display zoom
float zoom;
//if the player has just moved
boolean moved=false;

void setup() {
  //size of the window
  size(800, 800);
  
  //setup the maze to a specific size
  grid = new Tile[200][200];
  for (int x=0; x<grid.length; x++) {
    for (int y=0; y<grid[x].length; y++) {
      grid[x][y]=new Tile(x, y);
    }
  }
  
  //calculate the zoom to have the maze fit on screen
  zoom=min(width/(float)grid.length, height/(float)grid[0].length);
  
  //draw a white background
  background(255);
  
  //set really high framerate to max it out
  frameRate(300);
  //set color mode to use hue
  colorMode(HSB);
}
void draw() {
  moved=false;
  
  //generate the maze
  while (generating) {
    
    //these booleans keep track of which directions the grid generator is able to move in
    boolean PX=((fillerX+1<grid.length&&fillerX+1>=0)
      &&(fillerY<grid[fillerX+1].length&&fillerY>=0)
      &&!grid[fillerX+1][fillerY].filled);
    boolean NX=((fillerX-1<grid.length&&fillerX-1>=0)
      &&(fillerY<grid[fillerX-1].length&&fillerY>=0)
      &&!grid[fillerX-1][fillerY].filled);
    boolean PY=((fillerX<grid.length&&fillerX>=0)
      &&(fillerY+1<grid[fillerX].length&&fillerY+1>=0)
      &&!grid[fillerX][fillerY+1].filled);
    boolean NY=((fillerX<grid.length&&fillerX>=0)
      &&(fillerY-1<grid[fillerX].length&&fillerY-1>=0)
      &&!grid[fillerX][fillerY-1].filled);
    
    //if the maze generator is able to move then pick a random available direction and create a new path branching in that direction
    if (PX||NX||PY||NY) {
      
      //quick and dirty way of picking a random direction and then shifting the direction if it is not available until an available direction is found
      int rand=(int)random(0, 4);
      boolean loop=true;
      while (loop) {
        if (rand==0) {
          if (!PX) {
            rand=1;
          } else {
            loop=false;
          }
        }
        if (rand==1) {
          if (!NX) {
            rand=2;
          } else {
            loop=false;
          }
        }
        if (rand==2) {
          if (!PY) {
            rand=3;
          } else {
            loop=false;
          }
        }
        if (rand==3) {
          if (!NY) {
            rand=0;
          } else {
            loop=false;
          }
        }
      }
      
      //once the random direction is decided create the new path
      if (rand==0) {
        grid[fillerX][fillerY].filled=true;
        grid[fillerX][fillerY].right=false;
        fillerX++;
        grid[fillerX][fillerY].left=false;
      }
      if (rand==1) {
        grid[fillerX][fillerY].filled=true;
        grid[fillerX][fillerY].left=false;
        fillerX--;
        grid[fillerX][fillerY].right=false;
      }
      if (rand==2) {
        grid[fillerX][fillerY].filled=true;
        grid[fillerX][fillerY].down=false;
        fillerY++;
        grid[fillerX][fillerY].up=false;
      }
      if (rand==3) {
        grid[fillerX][fillerY].filled=true;
        grid[fillerX][fillerY].up=false;
        fillerY--;
        grid[fillerX][fillerY].down=false;
      }
      
      //add the newly created path tile to the list of tiles that still need to be tested by the generator
      tileBuffer.add(grid[fillerX][fillerY]);
      
    } else {
      //if the generator cannot move generate a new tile from the buffer. If there are no tiles that still need to be generated the maze is done generating.
      
      //display the generated maze
      if (tileBuffer.size()==0) {
        generating=false;
        background(255);
        for (int x=0; x<grid.length; x++) {
          for (int y=0; y<grid[x].length; y++) {
            grid[x][y].display(zoom);
          }
        }
        //initSolver();
      } else {
        
        //pick a new tile to generate
        grid[fillerX][fillerY].filled=true;
        int rand=(int)random(0, tileBuffer.size());
        fillerX=tileBuffer.get(rand).x;
        fillerY=tileBuffer.get(rand).y;
        tileBuffer.remove(rand);
      }
    }
  }

  //allow the player to see themselves and reach the goal
  if (!generating&&!solving) {
    
    //display goal
    noStroke();
    fill(35, 255, 220);
    rect(grid[grid.length-1][grid[grid.length-1].length-1].x*zoom, grid[grid.length-1][grid[grid.length-1].length-1].y*zoom, zoom, zoom);
    grid[grid.length-1][grid[grid.length-1].length-1].display(zoom);
    
    //display player
    noStroke();
    fill(85, 255, 200);
    rect(solverX*zoom, solverY*zoom, zoom, zoom);
    grid[solverX][solverY].display(zoom);
    
    //if the player reaches the goal then regenerate the maze
    if (solverX==grid.length-1&&solverY==grid[grid.length-1].length-1) {
      regen();
    }
  }
  
  //solve the maze by filling all dead ends until only the correct path remains
  //it will create a path from the player's current position to the end goal
  while (solving) {
    
    //temp variable to store if the solution has been found yet
    boolean temp=false;
    
    //for all tiles in the maze
    for (int x=0; x<grid.length; x++) {
      for (int y=0; y<grid[x].length; y++) {
        
        //if the tile is not at the goal or at the player's position
        if (!(x==solverX&&y==solverY)&&!(x==grid.length-1&&y==grid[x].length-1)) {
          
          //if the tile has not yet been marked as a dead end
          if (solveGrid[x][y].value!=1) {
            
            //find number of tiles it is open to
            //start off with the number of tiles it was initially open to
            int paths=solveGrid[x][y].value;
            
            //for every open path check if the tile it is open to has been marked by the maze solver as closed off
            //if the path is now closed then subtract one off of the paths count
            if (!grid[x][y].right) {
              if (x+1<grid.length) {
                if (solveGrid[x+1][y].value==1) {
                  paths--;
                }
              }
            }
            if (!grid[x][y].left) {
              if (x-1>=0) {
                if (solveGrid[x-1][y].value==1) {
                  paths--;
                }
              }
            }
            if (!grid[x][y].down) {
              if (y+1<grid[0].length) {
                if (solveGrid[x][y+1].value==1) {
                  paths--;
                }
              }
            }
            if (!grid[x][y].up) {
              if (y-1>=0) {
                if (solveGrid[x][y-1].value==1) {
                  paths--;
                }
              }
            }
            
            //if the number of tiles still open is one or less then mark the tile as a dead end
            if (paths==0||paths==1) {
              //mark that a solution is still being generated
              temp=true;
              
              //set to dead end
              solveGrid[x][y].value=1;
              
              //display the tile as a dead end
              noStroke();
              fill(0, 50);
              rect(x*zoom, y*zoom, zoom, zoom);
            }
          }
        }
      }
    }
    //only continue looking for a solution if a solution has not been found yet
    solving=temp;
  }
}

//regenerate the maze
void regen() {
  
  //reset all maze tiles
  for (int x=0; x<grid.length; x++) {
    for (int y=0; y<grid[x].length; y++) {
      grid[x][y]=new Tile(x, y);
    }
  }
  //reset the player's position
  solverX=0;
  solverY=0;
  
  //set boolean to generate the maze
  generating=true;
}


//render the maze in rainbow colours!
//this is basically a flood fill but where the hue changes as more tiles are filled
void rainbow() {
  //temp variable to store if the maze is till being rendered
  boolean temp=false;
  
  //setup a grid of integers to hold the hue of each tile
  int[][] colorGrid = new int[grid.length][grid[0].length];
  for (int x=0; x<colorGrid.length; x++) {
    for (int y=0; y<colorGrid[x].length; y++) {
      //default the hue to -1 to mark it as unset
      colorGrid[x][y]=-1;
    }
  }
  
  //start flood fill from the point 0 0
  colorGrid[0][0]=1;
  //counter to keep track of the number of tiles filled in order to figure out the hue change
  int counter=0;
  //how fast the hue changes (smaller = faster change)
  int hueChange=4;
  do {
    //default to the render being finished
    temp=false;
    
    //for all tiles flood fill
    for (int x=0; x<grid.length; x++) {
      for (int y=0; y<grid[x].length; y++) {
        //if the tile is filled
        if (colorGrid[x][y]!=-1) {
          
          //fill all tiles the tile is connected to that are not already filled
          
          if (!grid[x][y].right) {
            if (x+1<grid.length) {
              if (colorGrid[x+1][y]==-1) {
                //mark the rendering as incomplete
                temp=true;
                //increase the counter
                counter++;
                
                //set the new filled tile's hue
                //every number of filled tiles increase the hue by one
                if(counter%hueChange==0){
                  colorGrid[x+1][y]=(colorGrid[x][y]+1)%256;
                }else{
                  colorGrid[x+1][y]=(colorGrid[x][y])%256;
                }
              }
            }
          }
          if (!grid[x][y].left) {
            if (x-1>=0) {
              if (colorGrid[x-1][y]==-1) {
                temp=true;
                counter++;
                if(counter%hueChange==0){
                  colorGrid[x-1][y]=(colorGrid[x][y]+1)%256;
                }else{
                  colorGrid[x-1][y]=(colorGrid[x][y])%256;
                }
              }
            }
          }
          if (!grid[x][y].down) {
            if (y+1<grid[0].length) {
              if (colorGrid[x][y+1]==-1) {
                temp=true;
                counter++;
                if(counter%hueChange==0){
                  colorGrid[x][y+1]=(colorGrid[x][y]+1)%256;
                }else{
                  colorGrid[x][y+1]=(colorGrid[x][y])%256;
                }
              }
            }
          }
          if (!grid[x][y].up) {
            if (y-1>=0) {
              if (colorGrid[x][y-1]==-1) {
                temp=true;
                counter++;
                if(counter%hueChange==0){
                  colorGrid[x][y-1]=(colorGrid[x][y]+1)%256;
                }else{
                  colorGrid[x][y-1]=(colorGrid[x][y])%256;
                }
              }
            }
          }
          
        }
      }
    }
  } while (temp);
  
  //after all tiles have been filled display the tiles based on their hues
  for (int x=0; x<colorGrid.length; x++) {
    for (int y=0; y<colorGrid[x].length; y++) {
      noStroke();
      fill(colorGrid[x][y], 255, 255);
      rect(x*zoom, y*zoom, zoom, zoom);
    }
  }
  
  //disabled code to overlay the maze overtop of the rainbow tiles
  /*for (int x=0; x<grid.length; x++) {
   for (int y=0; y<grid[x].length; y++) {
   grid[x][y].display(zoom);
   }
   }*/
}

//start solving the maze
void initSolver() {
  //set solving to true
  solving=true;
  
  //reset solving grid
  solveGrid = new TileSolver[grid.length][grid[0].length];
  
  //setup all tiles for the solver
  for (int x=0; x<grid.length; x++) {
    for (int y=0; y<grid[x].length; y++) {
      
      //mark the number of openings each tile has
      if (!(x==solverX&&y==solverY)&&!(x==grid.length-1&&y==grid[x].length-1)) {
        
        //find number of tiles the tile is open to
        int openings=0;
        if (!grid[x][y].right) {
          openings++;
        }
        if (!grid[x][y].left) {
          openings++;
        }
        if (!grid[x][y].up) {
          openings++;
        }
        if (!grid[x][y].down) {
          openings++;
        }
        //set solver tile to store the number of openings
        solveGrid[x][y]=new TileSolver(openings);
        
        //if the tile is a dead end then display it as a dead end
        if (openings==0||openings==1) {
          noStroke();
          fill(0, 50);
          rect(x*zoom, y*zoom, zoom, zoom);
        }
      } else {
        
        //if the tile is at the goal or the player position set a defualt value of 2 openings
        //this is done to keep the tile marked as open to avoid being filled by the maze solver
        solveGrid[x][y]=new TileSolver(2);
      }
    }
  }
}

//user inputs
void keyPressed() {
  //if the maze is not being generated or solved allow the player to move unless they have already moved this frame
  if (!generating&&!moved&&!solving) {
    //check which directions the player is able to move in
    boolean PX=((solverX+1<grid.length&&solverX+1>=0)
      &&(solverY<grid[solverX+1].length&&solverY>=0)
      &&!grid[solverX+1][solverY].left);
    boolean NX=((solverX-1<grid.length&&solverX-1>=0)
      &&(solverY<grid[solverX-1].length&&solverY>=0)
      &&!grid[solverX-1][solverY].right);
    boolean PY=((solverX<grid.length&&solverX>=0)
      &&(solverY+1<grid[solverX].length&&solverY+1>=0)
      &&!grid[solverX][solverY+1].up);
    boolean NY=((solverX<grid.length&&solverX>=0)
      &&(solverY-1<grid[solverX].length&&solverY-1>=0)
      &&!grid[solverX][solverY-1].down);
    
    //fade out the player (this is done so that when the player moves they leave a slight trail)
    noStroke();
    fill(255, 200);
    rect(solverX*zoom, solverY*zoom, zoom, zoom);
    //display the maze tile overtop of the faded player tile
    grid[solverX][solverY].display(zoom);
    noFill();
    
    //allow the player to move
    if ((key=='A'||key=='a')&&NX) {
      solverX--;
    } else if ((key=='D'||key=='d')&&PX) {
      solverX++;
    } else if ((key=='W'||key=='w')&&NY) {
      solverY--;
    } else if ((key=='S'||key=='s')&&PY) {
      solverY++;
    }
    moved=true;
  }
  
  //generate a solution to the maze
  if (key==' ') {
    if(!generating&&!solving){
      //redraw the maze
      background(255);
      for (int x=0; x<grid.length; x++) {
        for (int y=0; y<grid[x].length; y++) {
          grid[x][y].display(zoom);
        }
      }
      //set the maze solver to generate a solution to the maze
      initSolver();
    }
  } else if (key=='1') {
    if(!generating&&!solving){
    //regenerate the maze
    regen();
    }
    
  } else if (key=='2') {
    if(!generating&&!solving){
    //render the maze as a rainbow
    rainbow();
    }
  }
  /*else if (key=='3') {
    //save a screenshot of the maze
    save("Maze.png");
    println("Maze saved");
  }*/
}
