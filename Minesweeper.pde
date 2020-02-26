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

//num Rows/Cols, num Mines
private int[][] difficultySettings = {
    {6, 10},
    {10, 25},
    {15, 60}
};

private int numRows = 5;
private int numCols = 5;
private int numMines = 4;

private int difficulty = 0;

Interactive manager;

public final static int BUTTON_TEXT_SIZE = 12;
public final static int WIN_FUN_DELAY = 3;

private int currFunMine = 0;

private PImage flagImage;

void setup ()
{
    size(400, 400);
    textAlign(CENTER,CENTER);
    background(0);

    numRows = difficultySettings[difficulty][0];
    numCols = difficultySettings[difficulty][0];
    numMines = difficultySettings[difficulty][1];
    
    // make the manager
    manager = Interactive.make( this );
    
    //your code to initialize buttons goes here

    buttons = new MSButton[numRows][numCols];

    mines = new ArrayList<MSButton>();

    for (int row = 0; row < numRows; row++) {
        for (int col = 0; col < numCols; col++) {
            buttons[row][col] = new MSButton(row, col);
        }
    }

    flagImage = loadImage("Minesweeper_flag.png");
    
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

    if (isWon()) {
        if (frameCount % WIN_FUN_DELAY == 0) {
            buttons[currFunMine / numCols][currFunMine % numCols].useCustomColor(false);
            currFunMine++;
            currFunMine = currFunMine % ((numRows * numCols)-1);
            buttons[currFunMine / numCols][currFunMine % numCols].useCustomColor(true);
        }
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

public void onWin() {
    displayWinningMessage();
    for (MSButton[] row : buttons) {
        for (MSButton button : row) {
            if (!mines.contains(button)) {
                button.setCustomColor(color(255, 255, 0));
            }
            else {
                button.setCustomColor(color(255, 0, 0));
            }
        }
    }
}

public boolean isLost() {
    for (MSButton mine: mines) {
        if (mine.isClicked()) {
            return true;
        }
    }
    return false;
}
public void onLose() {
    displayLosingMessage();
    for (MSButton mine : mines) {
        mine.setClicked(true);
    }
}

public void displayLosingMessage()
{
    //your code here
    new MSText("You Lose", width/2, height/2).setTextSize(50);
}
public void displayWinningMessage()
{
    new MSText("You Win", width/2, height/2).setTextSize(50);
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
    private color customClr;
    private boolean clicked, flagged, useCustomClr;
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
        customClr = -1;
        useCustomClr = false;
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
            if (isWon()) {
                onWin();
            }
        }
        //left click
        else {
            clicked = true;
            if (mines.contains(this)) {
                onLose();
            }
            else {
                this.flagged = false;

                this.setLabel(countMines(this.myRow, this.myCol));

                for (int[] offset : adjacentOffsets) {
                    if (isValid(this.myRow+offset[0], this.myCol+offset[1]) &&
                        !buttons[this.myRow+offset[0]][this.myCol+offset[1]].isClicked() && //don't click on already clicked values to prevent infinite recursion
                        //countMines(this.myRow+offset[0], this.myCol+offset[1]) == 0 && //mine has no numbers
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
        if (useCustomClr) {
            fill(this.customClr);
        }
        else if(clicked && mines.contains(this)) 
             fill(255,0,0);
        else if(clicked)
            fill( 200 );
        else 
            fill( 100 );

        rect(x, y, width, height);
        fill(0);
        textSize(BUTTON_TEXT_SIZE);
        text(myLabel,x+width/2,y+height/2);

        if (flagged) {
            image(flagImage, this.x+this.width/4, this.y+this.height/4, this.width/1.5, this.height/1.5);
        }
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
    public void setClicked(boolean clicked) { this.clicked = clicked; }
    public boolean isClicked() { return clicked; }
    public void setCustomColor(color clr)  {
        this.customClr = clr;
    }
    public void useCustomColor(boolean use) {
        this.useCustomClr = use;
    }
}

public class MSText
{
    private String txt;
    //width, height variable needed for guido
    private int x, y, width, height, txtSiz;
    private color fillClr, strokeClr;
    public MSText() {}
    public MSText(String txt, int x, int y, int fillClr, int strokeClr) {
        this.txt = txt;
        this.x = x;
        this.y = y;
        width = 1;
        height = 1;
        this.fillClr = fillClr;
        this.strokeClr = strokeClr;
        this.txtSiz = 12;
        Interactive.add( this ); // register it with the manager
    }
    public MSText(String txt, int x, int y) {
        this(txt, x, y, color(0, 0, 0), -1);
    }
    public void draw() {
        fill(this.fillClr);
        if (this.strokeClr >= 0) {
            stroke(this.strokeClr);
        }
        textSize(this.txtSiz);
        text(this.txt, this.x, this.y);
    }
    public void setTextSize(int siz) {
        this.txtSiz = siz;
    }

    public void mousePressed() {}
}

private void removeButtons() {
    for (MSButton[] row : buttons) {
        for (MSButton button : row) {
            Interactive.setActive(button, false);
        }
    }
}

public void keyPressed() {
    switch(key) {
        case '1':
            difficulty = 0;
            removeButtons();
            setup();
            break;
        case '2':
            difficulty = 1;
            removeButtons();
            setup();
            break;
        case '3':
            difficulty = 2;
            removeButtons();
            setup();
            break;
    }
}