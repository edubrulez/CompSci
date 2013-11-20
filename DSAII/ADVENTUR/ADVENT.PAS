Program Adventure;
 
{Erick Nave
 DS&A II 1:00
 Start: 3-30-94
 Last Update: 4-11-94
 
 Adventure begins by reading a number and room name pair from input
   which builds a list of rooms.  Then 2 numbers and a character are
   read to build the adjacency list.  The list is then displayed by
   showing which 2 rooms are connected and from which direction.  The
   cave is then explored by reading first a number indicating the
   starting room and then a series of characters indicating the
   direction to head in out of the room.  Lastly a series of numbers
   is read, each 2 indicating a starting and ending room, to see if
   there is a path connecting the two.}
 
Type
  Direction = (H, N, S, E, W);
   {H = head of adjacency list, N= north, S= south, E = east, W = west}
  NameType = packed array [1..21] of char;
   {name is 20 char long with an extra for a dummy character, a | in
     order to print the name without extra spaces at the end}
  roomptr = @room;
  room = record
           num: integer; {room number}
           dir: direction;
           name: NameType; {room name}
           NextRoom, Passage: roomptr;
            {NextRoom in the list of rooms and the Passage(s) from them}
           visited: boolean  {see if room is visited during traversal}
         end;
  stack = @stacknode;
  stacknode = record
                data: room; {room placed in stack}
                next: stack
              end;
 
var input: text; {input file globally declared}
 
Function CreateRoomList: roomptr;
{CreateRoomList recursively builds a list of rooms from input}
var
  temp: roomptr; {for new.  Eventually becomes value of function}
  n, i: integer;
     {(n)umber read from input for test case.  May become room number
       i is loop index.}
  ch: char; {reads an unwanted space}
begin
  read(n);
  if (not eof) and (n <> 99) then
    begin
      new(temp);
      temp@.num:= n;
      temp@.dir:= H; {head of passage list}
      read(ch); {garbage space}
      i:= 0;
      while (not eoln) and (i < 20) do
        begin
          i:=i+1;
          read(temp@.name[i])
        end;
      temp@.name[i+1]:= '|';
      readln;
      temp@.passage:= NIL;
      temp@.NextRoom:= CreateRoomList;
      CreateRoomList:= temp
    end
  else
    begin
      readln;
      CreateRoomList:= NIL
    end
end; {CreateRoomList}
 
Function FindDir(D: char): Direction;
{FindDir takes a character D and assigns the proper direction according
   to the enumerated type direction.}
Begin
  Case D of
    'N': FindDir:= N;
    'S': FindDir:= S;
    'E': FindDir:= E;
    'W': FindDir:= W
  end {Case}
end; {FindDir}
 
Function locate(h: roomptr; n: integer): roomptr;
{locate, beginning with the head of the room list (h), room n and
   retrun the pointer to that room}
var
  r: roomptr; {for searching rooms}
  found: boolean; {flag}
begin
  r:= h;
  found:= false;
  while (r <> NIL) and (not found) do
    if r@.num = n then
      found:= true
    else
      r:= r@.NextRoom;
  locate:= r
end; {locate}
 
Function SeekDir(r: roomptr; d: char): roomptr;
{SeekDir searches the passages of room r for the direction d and returns
   the pointer to that room.}
var
  p: roomptr; {for searching passages}
  dir: direction; {to make d compatable to the direction type}
  found: boolean; {flag}
begin
  dir:= FindDir(d);
  found:= false;
  p:= r;
  while (p <> NIL) and (not found) do
    if p@.dir = dir then
      found:= true
    else
      p:= p@.passage;
  SeekDir:= p
end; {SeekDir}
 
Procedure WriteName(n: NameType);
{WriteName writes the contents of the packed array out until a dummy
  | is found to eliminate unneeded spaces at the end of the array.}
var i: integer; {counter}
begin
  i:= 1;
  while (i <= 20) and (n[i] <> '|') do
    begin
      write(n[i]);
      i:= i+ 1
    end
end; {WriteName}
 
Procedure writedir(d: direction);
{writedir writes the direction to output based on d}
begin
  Case d of
    N: write('north');
    S: write('south');
    E: write('east');
    W: write('west')
  end
end; {writedir}
 
Procedure GetPassages(h: roomptr);
{GetPassages receives the pointer to the first room and reads a series
  of 2 integers and 1 character to build arcs from the room identified
  by the first integer to the room identified by the second.}
var
  n1, n2: integer; {room numbers read from input}
  r1, r2, temp: roomptr; {pointers to the first and second rooms}
                         {temporary address storage}
  dir: char; {used to determine direction}
begin
  read(n1);
  while (not eof) and (n1 <> 99) do
    begin
      read(n2);
      read(dir); {unwanted space}
      readln(dir);
      r1:= locate(h, n1);
      r2:= locate(h, n2);
    {make adjacency node which is basically a copy of r2 attached to r1
       with an actual direction placed in the dir field}
      temp:= r1@.passage;
      new(r1@.passage);
      r1@.passage@.num:= n2;
      r1@.passage@.dir:= FindDir(dir);
      r1@.passage@.name:= r2@.name;
      r1@.passage@.NextRoom:= NIL;
      r1@.passage@.passage:= temp;
      read(n1)
    end; {while}
  writeln;
  readln
end; {GetPassages}
 
Procedure ShowArcs(h: roomptr);
{ShowArcs brings in the pointer to the first room (h) and traverses
  through the rooms, and for each room, traverses the passages and
  prints the arc between the room and the passage.}
var
  r, p: roomptr; {used to traverse rooms (r) and passages (p)}
begin
  r:= h;
  while r <> nil do
    begin
      p:= r@.passage;
      while p <> nil do
        begin
          WriteName(r@.name);
          write(' ');
          writedir(p@.dir);
          write(' to ');
          WriteName(p@.name);
          writeln;
          p:= p@.passage
        end;
      r:= r@.NextRoom
    end
end; {ShowArcs}
 
Procedure WriteRooms(h: roomptr);
{WriteRooms displays the rooms and their corresponding numbers in a
   menu-type format}
var
  r: roomptr; {for traversal}
begin
  r:= h;
  while r <> nil do
    begin
      write(r@.num,') ');
      WriteName(r@.name);
      writeln;
      r:= r@.NextRoom
    end
end;
 
Procedure Explore(h: roomptr);
{Explore gets an integer from input which is for the starting room. Then
   a series of directions is processed and explore gives the room that
   the direction leads to and moves into that room.  h is the pointer
   to the first room.}
var
  start: integer; {starting room number}
  r, p: roomptr; {room you are currently in and passage to be entered}
  dir: char; {direction to move}
begin
  writeln; writeln;
  writeln('Cave Exploration');
  WriteRooms(h);
  writeln;
 {get starting room}
  if not eof then
    repeat
      readln(start);
      writeln('Please enter starting room: ',start:1);
      r:= locate(h, start)
    until (r <> nil) or eof;
  writeln;
  write('You are in the ');
  WriteName(r@.name);
  writeln;
  {Begin processing directions}
  Repeat
    if not eof then
      readln(dir)
    else
      dir:= 'P';
    writeln('>> ',dir);
    if dir in ['N', 'S', 'E', 'W'] then
      begin
        p:= seekdir(r, dir);
        if p <> NIL then {can move to a new room}
          begin
            Write('You are in the ');
            WriteName(p@.name);
            writeln;
            r:= locate(h, p@.num)
          end
        else
          writeln('There is a wall there')
    end {if dir...}
  until dir = 'P';
end; {explore}
 
Procedure SetToFalse(h: roomptr);
{SetToFalse sets the visited field of all of the rooms to false}
var
  temp: roomptr; {for traversing list}
begin
  temp:= h;
  while temp <> nil do
    begin
      temp@.visited:= false;
      temp:= temp@.NextRoom
    end
end; {SetToFalse}
 
Procedure Push(var s: stack; item: room);
{Push sticks the room (item) at the beginning of the stack (s).}
var temp: stack; {temporaray address storage}
begin
  if s <> nil then
    temp:= s
  else
    temp:= nil;
  new(s);
  s@.data:= item;
  s@.next:= temp
end; {push}
 
Procedure WriteStack(s: stack);
{WriteStack prints the rooms listed in the stack}
var temp: stack; {temp traverses stack}
begin
  temp:= s;
  while temp <> nil do
    begin
      write('Walk ');
      writedir(temp@.data.dir);
      write(' to the ');
      WriteName(temp@.data.name);
      writeln;
      temp:= temp@.next
    end
end; {WriteStack}
 
Procedure DestroyStack(s:stack);
{disposes of dynamic memory associated with s}
var temp, hold: stack; {temp traverses stack}
                       {hold holds address to be disposed}
begin
  temp:= s;
  while temp <> nil do
    begin
      hold:= temp;
      temp:= temp@.next;
      dispose(hold)
    end
end; {DestroyStack}
 
Procedure Traverse(h, start, stop: roomptr; var s: stack);
{Traverse implements a Depth-First Traversal to find a path from the
   starting room (start) to the ending room (stop).  h is the pointer
   to the first room node needed to use locate.  s is a stack hybrid
   needed to put the path in its proper order (the reverse of the
   reverse order of the recursive returns) to be displayed later.}
var temp, room: roomptr;  {to access passages and rooms}
  t:boolean;
begin
  t:= false;
  start@.visited:= true;
  if not stop@.visited then
    begin
      temp:= start@.passage;
      while (temp <> nil) and (not stop@.visited) do
        begin
          room:= locate(h, temp@.num);
          if not room@.visited then
            begin
              traverse(h, room, stop, s);
              if stop@.visited then
                push(s,temp@);
            end; {if}
          temp:= temp@.passage
        end {while}
    end {if}
end; {Traverse}
 
Procedure FindPath(h:roomptr);
{FindPath finds a path from one room to another. h is the pointer to
  the first room.  It finds the pointers to the enterance and exit rooms
  and sends them, along with h and a stack hybrid to a Depth-First
  Traversal procedure to get the actual path.  If a path exists, the
  path is displayed.  If one doesn't, a message indicating so is
  displayed.}
var
  n1, n2: integer; {room numbers}
  start, stop: roomptr; {pointers to starting and stopping rooms}
  ch: char; {character read or set to Q if eof is reached}
  s: stack; {used to print path in proper order}
Begin
  writeln;
  writeln('Find a path between 2 rooms');
  WriteRooms(h);
  Repeat
    If not eof then
      readln(n1)
    else ch:= 'Q'; {ending condition}
    If ch <> 'Q' then
      begin
        if not eof then
          begin
            readln(n2);
            writeln;
            writeln('Please enter entrance room: ', n1:1);
            writeln('Please enter exit room: ', n2:1);
            writeln;
          {locate rooms}
            start:= locate(h, n1);
            write('Starting at the ');
            WriteName(start@.name);
            writeln;
            stop:= locate(h, n2);
          {look for path}
            SetToFalse(h);
            s:= nil;
            Traverse(h, start, stop, s);
          {display results}
            if stop@.visited= true then
              begin
                WriteStack(s);
                writeln('You are there.')
              end
            else
              begin
                write('There is no path to the ');
                WriteName(stop@.name);
                writeln
              end;
            DestroyStack(s);
            writeln;
            if not eof then
              read(ch)
            else ch:= 'Q';
            writeln('>> ',ch)
          end {if not eof}
        else ch:= 'Q'
      end {if ch <> Q}
    Until (ch = 'Q')
end; {FindPath}
 
 
Procedure DestroyRoomList(h:roomptr);
{DestroyRoomList disposes of all dymamic memory associated with rooms
   and passages.}
var
  r, p, hold: roomptr; {(r)ooms and (p)assages to be traversed through
                          and address held (hold) for disposal}
begin
  r:= h;
  while r <> nil do
    begin
      p:= r@.passage;
      while p <> nil do
        begin
          hold:= p;
          p:= p@.passage;
          dispose(hold)
        end;
      hold:= r;
      r:= r@.NextRoom;
      dispose(hold)
    end
end; {DestroyRoomList}
 
{main resets the input file and calls the procedures defined above
  in order to play adventure}
 
Var
  HeadRoom: roomptr; {pointer to first room}
 
Begin
  termout(output);
  reset(input, 'name = cave.data.*');
  HeadRoom:= CreateRoomList;
  GetPassages(HeadRoom);
  ShowArcs(HeadRoom);
  Explore(HeadRoom);
  FindPath(HeadRoom);
  DestroyRoomList(HeadRoom);
  Writeln('Thank you for playing Adventure.')
End. {Adventure}
