import de.bezier.guido.*;
//Declare and initialize constants numRows and numCols = 20
private MSButton[][] buttons; //2d array of minesweeper buttons
private ArrayList <MSButton> mines; //ArrayList of just the minesweeper buttons that are mined
private int[][] adjacentOffsets = { //x, y offsets used to find adjacent cells
    {-1, 0},
    {0, 1},
    {0, -1},
    {1, 0},
};

private int numRows = 5;
private int numCols = 5;
private int numMines = 10;

void setup ()
{
    size(400, 400);
    textAlign(CENTER,CENTER);
    
    // make the manager
    Interactive.make( this );
    
    //your code to initialize buttons goes here

    buttons = new MSButton[numRows][numCols];

    mines = new ArrayList<MSButton>();

    for (int row = 0; row < numRows; row++) {
        for (int col = 0; col < numCols; col++) {
            buttons[row][col] = new MSButton(row, col);
        }
    }
    
    setMines();
}
public void setMines()
{
    //your code
    int i = 0;
    while (i < numMines) {
        int row = (int)(Math.random() * numRows);
        int col = (int)(Math.random() * numCols);
        if (!mines.contains(buttons[row][col])) {
            mines.add(buttons[row][col]);
            i++;
        }
    }
}

public void draw ()
{
    background( 0 );
    if(isWon() == true)
        displayWinningMessage();
    else if (isLost()) {
        displayLosingMessage();
    }
}

public boolean isWon()
{
    for (MSButton mine: mines) {
        if (!mine.isFlagged()) {
            return false;
        }
    }
    return true;
}
public boolean isLost() {
    for (MSButton mine: mines) {
        if (mine.isClicked()) {
            return true;
        }
    }
    return false;
}
public void displayLosingMessage()
{
    //your code here
    System.out.println("LOSING");
    text("You Lose", width/2, height/2);
}
public void displayWinningMessage()
{
    text("You Win", width/2, height/2);
}
public boolean isValid(int r, int c)
{
    return r >= 0 && r < numRows && c >= 0 && c < numCols;
}
public int countMines(int row, int col)
{
    int numMines = 0;
    //your code here
    for (int i = -1; i < 2; i++) {
        for (int j = -1; j < 2; j++) {
            if (isValid(row+i, col+j) &&
                (i != 0 || j != 0) && //dont't check the given cell, which is at i=0, j=0
                mines.contains(buttons[row+i][col+j])
            ) {
                numMines++;
            }
        }
    }

    return numMines;
}
public class MSButton
{
    private int myRow, myCol;
    private float x,y, width, height;
    private boolean clicked, flagged;
    private String myLabel;
    
    public MSButton ( int row, int col )
    {
        width = 400/numCols;
        height = 400/numRows;
        myRow = row;
        myCol = col; 
        x = myCol*width;
        y = myRow*height;
        myLabel = "";
        flagged = clicked = false;
        Interactive.add( this ); // register it with the manager
    }

    // called by manager
    public void mousePressed () 
    {
        //your code here
        //player clicked a mine
        if (mouseButton == RIGHT) {
            this.flagged = !this.flagged;
            //if this.flagged was set to false
            if (!this.flagged) {
                this.clicked = false;
            }
        }
        //left click
        else {
            clicked = true;
            if (mines.contains(this)) {
                System.out.println("LOST");
                System.out.println(this.isClicked());
                displayLosingMessage();
            }
            else {
                this.setLabel(countMines(this.myRow, this.myCol));

                for (int[] offset : adjacentOffsets) {
                    if (isValid(this.myRow+offset[0], this.myCol+offset[1]) &&
                        !buttons[this.myRow+offset[0]][this.myCol+offset[1]].isClicked() && //don't click on already clicked values to prevent infinite recursion
                        !mines.contains(buttons[this.myRow+offset[0]][this.myCol+offset[1]])
                    ) {
                        buttons[this.myRow+offset[0]][this.myCol+offset[1]].mousePressed();
                    }
                }
            }
            
        }
    }

    public void draw () 
    {    
        if (flagged)
            fill(0);
         else if( clicked && mines.contains(this) ) 
             fill(255,0,0);
        else if(clicked)
            fill( 200 );
        else 
            fill( 100 );

        rect(x, y, width, height);
        fill(0);
        text(myLabel,x+width/2,y+height/2);
    }
    public void setLabel(String newLabel)
    {
        myLabel = newLabel;
    }
    public void setLabel(int newLabel)
    {
        myLabel = ""+ newLabel;
    }
    public boolean isFlagged()
    {
        return flagged;
    }
    public boolean isClicked() {return clicked;}
}
