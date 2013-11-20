Program KnightsTourRecursion;
 {Erick Nave
  DS&A II 1-27-94
  KnightsTourRecursion is a recursive backtracking algorithm using
     the one move look-ahead heuristic in order to solve the Knight's
     Tour problem.  From a current position on the board, the possible
     moves are examined.  If a move is legal, then it counts the number
     of legal moves that can be made from there.  That number is placed
     into an array that stores the number of moves from each move.  If
     the move is illegal, a 100 is placed in the array and if there is
     only one move, a 99 is placed in that move's slot.  The knight is
     to move to the spot that has the lowest number of moves from it.
     If the knight runs into a dead end, it backtracks and selects
     another move from there.}
 
Type
  BoardRows = 0..7;
  BoardColumns = 1..8;
  BoardType = Array [BoardRows, BoardColumns] of integer;
    {2-dim matrix representing board}
  Moves = (ul, ur, ru, rd, dr, dl, ld, lu);
    {the 8 moves: u = up, d = down, l = left, r = right, so
      ul = up and left, ru = right and up, etc.}
  BoardMoveType = record
              moverows, movecols: integer
             end;
  BoardMoves= Array[ul..lu] of BoardMoveType;
    {stores the number of rows and columns that have to be moved for
       each possible move of the knight.}
  NumberOfMovesType = Array [ul..lu] of integer;
    {array storing the number of moves from a possible next move.}
 
Procedure InitBoard(var b:boardtype);
  {InitBoard initializes the 2-dim array to zeros}
 var i, j: integer; {loop index}
 Begin
   for i:= 0 to 7 do
    for j:= 1 to 8 do
     b[i,j]:= 0;
 end; {InitBoard}
 
Procedure InitMoves(var BMove: BoardMoves);
  {InitMoves supplies the actual knight movements to the array}
 begin
   BMove[ul].moverows:= -2;
   BMove[ul].movecols:= -1;
   BMove[ur].moverows:= -2;
   BMove[ur].movecols:= 1;
   BMove[ru].moverows:= -1;
   BMove[ru].movecols:= 2;
   BMove[rd].moverows:= 1;
   BMove[rd].movecols:= 2;
   BMove[dr].moverows:= 2;
   BMove[dr].movecols:= 1;
   BMove[dl].moverows:= 2;
   BMove[dl].movecols:= -1;
   BMove[ld].moverows:= 1;
   BMove[ld].movecols:= -2;
   BMove[lu].moverows:= -1;
   BMove[lu].movecols:= -2
 end; {InitMoves}
 
Procedure GetInfo(var pos:integer);
  {GetInfo prompts for the position (pos) on the board for first move}
 Begin
   Repeat
     Writeln('Enter position on board (1 - 64, 0 to quit): ');
     Readln(pos)
   Until (pos >= 0) and (pos <= 64);
   Writeln
 End; {GetInfo}
 
 
Procedure FirstMove(var r,c,mnum:integer; var b:BoardType; pos:integer);
 {FirstMove places a 1 on the board (b) according to pos and returns the
    row and column (r & c) at pos and sets the move number (mnum) to 1)}
 Begin
   If (pos mod 8) = 0 then
     Begin
       r:= (pos div 8) - 1;
       c:= 8
     End
   Else
     Begin
       r:= pos div 8;
       c:= pos mod 8
     end;
   b[r,c]:= 1;
   mnum:= 1
 end; {FirstMove}
 
Function CanMove(row, col: Integer; BMv: BoardMoveType;
     var b:boardtype):Boolean;
  {CanMove takes the current row and column and applies the possible
    board move (BMv) to it to see if it is on the board.  If it is
    then it checks to see if the spot is open by checking to see if
    a zero occupies that spot in b (the board)}
  var OnBoard: boolean;  {Is the move on the board?}
  Begin
    With BMv do begin
      OnBoard:= ((row + moverows) >= 0) and ((row + moverows) <=7) and
           ((col + movecols) >= 1) and ((col + movecols) <=8);
      If OnBoard then
        CanMove:= b[row+moverows, col+movecols] = 0
      else CanMove:= OnBoard
    end
  End; {CanMove}
 
Procedure CountMoves(r,c:Integer; BMv:BoardMoveType; var B:BoardType;
                     var count: Integer; var BdMove: BoardMoves);
  {CountMoves counts all of the possible moves from a single location.
     The location is determined by appling the move (BMv) to the row
     current row and column (r and c). Count is incremented by 1 for
     each valid move.}
 Var PossMoves: Moves; {possible moves from ul to lu}
 Begin
   count:= 0;
   for possmoves:= ul to lu do
    If CanMove(r+BMv.moverows, c+BMv.movecols, BdMove[possmoves], b)
      then count:= count + 1;
   If count = 0 then count:= 99
 End; {CountMoves}
 
Procedure MakeMove(var r,c,mn:Integer; BMv:BoardMoveType; var
    b:boardtype; var done: boolean);
  {MakeMove places the the next move number (mn + 1) in the new
     row and column (r&c) determined by the next board move (BMv).}
 Begin
   r:= r + BMv.moverows;
   c:= c + BMv.movecols;
   mn:= mn + 1;
   B[r,c]:= mn;
   done:= mn = 64
 End; {MakeMove}
 
Procedure Retreat(var r,c,mn:Integer; BMv:BoardMoveType; var
    b:boardtype; var CancelMove: Integer);
 {Retreat is just the opposite of MakeMove.  It decrements the move
    number (mn) by 1, places a 0 in the spot it is currently in to
    reset the board, moves the knight back to its previous position
    by subtracting the board move (BMv) from the row and column (r&c),
    and lastly Cancels the move from the MoveArray by returning a 100
    from CancelMove.}
 Begin
   B[r,c]:= 0;
   r:= r - BMv.moverows;
   c:= c - BMv.movecols;
   mn:= mn - 1;
   CancelMove:= 100
 End; {Retreat}
 
Procedure GetNextMove(MoveArray:NumberOfMovesType; var NextMove:Moves;
                      var StillMoves:Boolean);
{GetNextMove takes the Array with the number of moves (MoveArray) and
   determines the next move (NextMove) by finding the move with
   the least number of possble moves from it.}
var
  LowMoveCount: integer; {keeps track of the lowest # of moves}
  possmoves: Moves; {loop index for possible moves}
Begin
  LowMoveCount:= 100;
  for possmoves:= ul to lu do
    If MoveArray[possmoves] < LowMoveCount then
      Begin
        nextmove:= possmoves;
        LowMoveCount:= MoveArray[possmoves]
      End;
  If LowMoveCount = 100 then StillMoves:= false
End; {GetNextMove}
 
Procedure Tour (r,c:integer; var mnum:integer;var b:boardtype;
                var BoardMove: BoardMoves; var done: Boolean);
{Tour is the recursive procedure taking advantage of the one move
   look-ahead algorithm.  It uses the row and column (r&c) along with
   the array of moves (BoardMove) to begin.  It then fills the array
   of moves by going through each possible move and if it is valid,
   calls CountMove, and if not, places a 100 in that slot. A while
   loop is then entered in which the next move is selected by calling
   GetNextMove.  If GetNextMove says that there are still moves then
   the move is made and Tour is called again.  If the tour ends and
   the board isn't full, then retreat is called to backtrack.}
 Var
   row, col, MoveCount: integer;
     {row and column (col).  MoveCount is the number of moves that can
        be made from the next possible position.}
   possmoves, nextmove: Moves;
     {possible moves (ul-lu) and the nextmove determined when Movecount
        is less than LowMoveCount.}
   StillMoves: Boolean; {Any moves left?}
   MoveArray: NumberOfMovesType;
      {keeps track of # of moves for each possible next move}
 Begin
   row:= r;
   col:= c;
   StillMoves:= false;
   for possmoves:= ul to lu do
     If CanMove(row, col, BoardMove[possmoves], b) then
       Begin
         StillMoves:= true;
         CountMoves(row, col, BoardMove[possmoves], b, MoveCount,
            BoardMove);
         MoveArray[possmoves]:= MoveCount
        End
     Else MoveArray[possmoves]:= 100;
   While StillMoves and not done do
     Begin
       GetNextMove(MoveArray, nextmove, StillMoves);
       IF StillMoves then
         Begin
           MakeMove(row, col, mnum, BoardMove[nextmove], b, done);
           Tour(row, col, mnum, b, BoardMove, done);
           If not done then
               Retreat(row, col, mnum, BoardMove[nextmove], b,
                     MoveArray[nextmove])
         end
     end
 End; {Tour}
 
Procedure PrintBoard(board: BoardType; time: real);
  {PrintBoard prints the 2-dim matrix and the time.}
 var i,j: integer; {loop index}
 Begin
   for i:= 0 to 7 do
     Begin
       for j:= 1 to 8 do
         Write (board[i,j]:3);
       writeln
     End;
   Writeln;
   Writeln('Time: ',time:1:4,' seconds');
   Writeln
 End; {PrintBoard}
 
Var
  Board: BoardType; {2-dim matrix to serve as chess board}
  row, col, movenum, position: integer;
    {row and column, number of moves,  position on board}
  time: Real; {time it took for complete tour}
  BoardMove: BoardMoves; {array of matrix movements}
  Done: Boolean; {initialized to false for when tour is called}
 
Begin {main}
  termin(input);
  termout(output);
  GetInfo (position);
  While position <> 0 do
    Begin
      InitBoard(Board);
      InitMoves(BoardMove);
      FirstMove(row, col, movenum, board, position);
      done:= false;
      Time:= clock;
      Tour(row, col, movenum, board, BoardMove, done);
      Time:= clock - time;
      time:= time / 1000000;
      PrintBoard(board, time);
      GetInfo(position)
    End
End. {KnightsTourRecursion}
 
