Program Lab14B; {written by Tim Margush, 12/93 for DSA-I Lab}
uses crt,dos;
const
 maxdim = 20;
 empty= ' ';
 Barrier=#219;
 smile = #1;
 up    = #30;
 down  = #31;
 left  = #17;
 right = #16;
 boy   = #12;
 girl  = #11;

type
  MazeType = record
     c:Array[0..maxdim,0..maxdim] of char;
     rows,cols:integer
     end;

 HeadingType = (PrelimHeading, North, South, East, West);
 CellType = Record x,y:integer end;

var speed:integer; {globally modified and accessed value}

function samespot(a,b:Celltype):boolean;
 begin samespot:=(a.x=b.x) and (a.y=b.y) end;

Procedure PrintLoc(c:Celltype);
begin
 write(c.x:1,',',c.y:1,'->')
end;

procedure pause;
 var ch:char;
 i:integer; h,s,s1:word; x,y:integer;
begin
 gotoxy(1,25);clreol;
 if speed=0 then begin
   write('Single Step - Press a key  (Press 0(single step) - 6(fast) for other speeds');
   repeat until keypressed;
   end
 else begin
   write('Speed: ',Speed:1, ' (Press 0(single step) - 6(fast) for other speeds');
   for i:=1 to 1*(6-speed) do begin
    GetTime(h,h,h,s);
    repeat GetTime(h,h,h,s1); until s1<>s;
   end;
 end;
 gotoxy(1,25);clreol;
 if keypressed then ch:=readkey else ch:=' ';
 if ch in ['0'..'6'] then speed:=ord(ch)-ord('0')
end;

procedure MakeMove(C:CellType; Heading:HeadingType; var N:CellType);
 begin
  N:=C;
  with N do
   case heading of
    North:x:=x-1;
    South:x:=x+1;
    East:y:=y+1;
    West:y:=y-1;
   end;
 end;

procedure Mark(var M:MazeType; Cell:CellType; c:char);
  var x,y:integer;
 begin
  M.c[cell.x,cell.y]:=c;
  x:=Wherex;y:=Wherey;
  gotoxy(cell.y+4,cell.x+1);
  write(c);
  pause;
  gotoxy(x,y);
 end;

function CanMove(var M:MazeType; CS:CellType; H:HeadingType):Boolean;
 begin
   MakeMove(CS,H,CS);
   CanMove:=M.c[CS.x,CS.y] in [empty,boy,girl]
 end;

procedure printmaze(var M:Mazetype);
var i,j:integer;
begin
 gotoxy(1,1);
 write('Maz ');
 for i:=1 to m.cols do write(i mod 10:1);writeln;
 for i:=1 to m.rows do begin
  write(i:3,'-');
  for j:=1 to m.cols do write(m.c[i,j]);
  writeln('-',i:1);
 end;
 write('    ');for i:=1 to m.cols do write(i mod 10:1);writeln;
 writeln;
end;

function DirSymbol(h:headingType):Char;
 var c:string;
begin
 c:=' '+up+down+right+left;
 DirSymbol:=c[ord(h)+1]
end;

Procedure SolveMaze(var Maze:MazeType; 
                        StartLoc, StopLoc: CellType;
                    var Possible : Boolean {return result of search});
 var
     Heading:HeadingType;
     NewLoc:CellType;
Begin
 If SameSpot(StartLoc, StopLoc) then begin {successful base case}
   Possible := True; Mark(Maze, StartLoc, Smile);
 end
 Else begin {try to extend path}
   Possible := False; {pessimistic outlook}
   Heading := PrelimHeading; {dummy heading to get started}
   While not Possible and (Heading<West) do begin {try moving each direction}
    Heading := Succ(Heading);
    Mark(Maze, StartLoc, DirSymbol(Heading));
    If CanMove(Maze, StartLoc, Heading) then begin
      MakeMove(StartLoc, Heading, NewLoc); {One small step}
      SolveMaze(Maze, NewLoc, StopLoc, Possible);
      NewLoc:=NewLoc {stupid...but it gives a place for a breakpoint}
    end
   end;
   if Possible then
    PrintLoc(NewLoc) {print location to follow StartLoc on path}
   else
    Mark(Maze,StartLoc,empty); {unmark Starting location}
 End {try to extend}
End;

procedure GetLoc(var L:CellType;i:integer);
 var x,y:integer;
begin
 x:=wherex;y:=wherey;gotoxy(30,3+i);
 if i=2 then Write(' Stop at ') else Write('Start at ');;
 write(' x y coords --> ');readln(L.x,L.y);
 gotoxy(x,y)
end;

procedure GetSpeed(var Speed:Integer);
 var x,y:integer;
begin
 x:=wherex;y:=wherey;gotoxy(30,6);
 write('Select Speed factor');
 gotoxy(30,6);write(' 0(single step) .. 6(fast)) -> ');Readln(speed);
 gotoxy(x,y)
end;

procedure ReadMaze(var M:MazeType);
 var f:text; fn:string[20];
     i,j:integer; ch:char; loc:celltype;
begin
 write('Name of maze data file: ');Readln(fn);
 assign(f,fn);reset(f);
 for i:=0 to maxdim do for j:=0 to maxdim do M.c[i,j]:=BARRIER;
 m.rows:=0;m.cols:=0;
 while not eof(f) do begin
   m.rows:=m.rows+1;loc.y:=0;loc.x:=m.rows;
   while not eoln(f) or (loc.y<M.cols) do with m do begin
     loc.y:=loc.y+1;
     if eoln(f) then ch:=empty else read(f,ch);
     if ch=empty then c[loc.x,loc.y]:=empty else c[loc.x,loc.y]:=barrier;
   end;
   IF loc.y>M.cols then M.Cols:=loc.y;
   readln(f)
 end;
 close(f);
 PrintMaze(M);
end;

var Maze:MazeType;
    StartLoc,StopLoc:CellType;
    ch:char;
    Heading:HeadingType; Possible:Boolean;

begin
 randomize; clrscr; speed:=20;
 if random<0.5 then ch:=boy else ch:=girl;
 ReadMaze(Maze);
 GetLoc(StartLoc,1);
 Mark(Maze, StartLoc,ch);
 GetLoc(StopLoc,2);
 if ch=boy then ch:=girl else ch:=boy;
 Mark(Maze, StopLoc,ch);
 GetSpeed(Speed);
 SolveMaze(Maze,StartLoc,StopLoc,Possible);
 if Possible then
  Writeln(StartLoc.x:1,',',StartLoc.y:1)
 else
  Writeln('Not Possible');
 gotoxy(1,25);
 while keypressed do ch:=readkey;
 write('Finished - Press Q');
 repeat ch:=readkey until ch in ['q','Q']
end.