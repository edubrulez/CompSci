Program KnightsTourOneMoveLookAhead;
 {Erick Nave
  DS&A II 1-27-94
  OneMoveLookAhead is a heuristic approach to solving the Knight's
     Tour problem.  From a current position on the board, the possible
     moves are examined.  If a move is legal, then it counts the number
     of legal moves that can be made from there.  The Knight is to move
     to the spot that has the lowest number of moves from it.  A legal
     move is one that is on the board and to a space that has not
     been touched.}
 
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
 
Procedure CountMoves(r,c:Integer; BMv:BoardMoveType; var b:BoardType;
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
     then count:= count + 1
 End; {CountMoves}
 
Procedure MakeMove(var r,c,mn:Integer; BMv:BoardMoveType; var
    b:boardtype);
  {MakeMove places the the next move number (mn + 1) in the new
     row and column (r&c) determined by the next board move (BMv).}
 Begin
   r:= r + BMv.moverows;
   c:= c + BMv.movecols;
   mn:= mn + 1;
   B[r,c]:= mn
 End; {MakeMove}
 
Procedure Tour (r,c:integer; var mnum:integer;var t:real;
                var b: boardtype);
  {Tour is the one move look-ahead algorithm.  It uses the initial
     row and column (r & c) along with initialize the array of moves
     to begin and then there is a Repeat-Until loop that terminates
     when there are no more moves.  Within the loop, the moves on the
     board (b) are made.  To determine each move, a for-do loop
     examines each possible move from a particular spot.  If you
     CanMove to a certain position, then CountMoves is called to
     count the number of moves that can be made from that position.
     If the count is the smallest, then the move is saved to be used
     when MakeMove is called.  Tour returns the number of moves made,
     the new board, and the time it took for the tour.}
 Var
   row, col, MoveCount, LowMoveCount: integer;
     {row and column (col).  MoveCount is the number of moves that can
        be made from the next possible position.  LowMoveCount keeps
        track of the lowest number of moves from a certain position.}
   possmoves, nextmove: Moves;
     {possible moves (ul-lu) and the nextmove determined when Movecount
        is less than LowMoveCount.}
   BoardMove: BoardMoves; {list of matirx moves}
   NoMoves: Boolean; {Any moves left?}
 Begin
   InitMoves(BoardMove);
   row:= r;
   col:= c;
   t:= clock;
   Repeat
     NoMoves:= true;
     LowMoveCount:= 100;
     for possmoves:= ul to lu do
       If CanMove(row, col, BoardMove[possmoves], b) then
         Begin
           NoMoves:= false;
           CountMoves(row, col, BoardMove[possmoves], b, MoveCount,
             BoardMove);
           If MoveCount < LowMoveCount then
             Begin
               nextmove:= possmoves;
               LowMoveCount:= MoveCount
             End
          End;
     IF not NoMoves then MakeMove(row, col, mnum, BoardMove[nextmove],
            b)
   Until NoMoves;
   t:= clock - t;
   t:= t / 1000000
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
  time: real; {time it took for complete tour}
 
Begin {main}
  termin(input);
  termout(output);
  GetInfo (position);
  While position <> 0 do
    Begin
     InitBoard(Board);
     FirstMove(row, col, movenum, board, position);
     Tour(row, col, movenum, time, board);
     If Movenum = 64 then
       PrintBoard(board, time)
     Else
       Writeln('No solution found.');
     GetInfo(position)
    End
End. {KnightsTourOneMoveLookAhead}
 
