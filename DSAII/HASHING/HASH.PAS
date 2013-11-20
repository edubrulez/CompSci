Program Hashing;
 
{Erick Nave
 Program 4 - hash pascal
 DS&A II 1:00
 Start 4-19-94
 Last Update 5-4-94
 
 Hashing implements the ordered list adt with hashing to find a spot
   in an array to store a key and a link field in order to implement
   a linked list for traversals in order.  Blank positions in the
   array are designated with a key of -1.  Positions that were once
   occupied but have since been deleted have a value of -2 so that
   keys that have collided into the former one can be accessed.  Add
   however finds the first position with a negative value so that
   a new key can enter the space with either -1 or -2. The ordered
   list operations are add, delete, retrieve, and traverse.  A
   statistics operation has been added to report information involved
   with the hashing itself.}
 
Const
  TableSize = 199;
  Null = 0; {simulated dynamic memory nil}
 
Type
  Pointer = Integer; {For simulated dynamic memory}
  ListNode = Record
               Key: Integer;
               Next: Pointer
             End;
  Table = Array [1..TableSize] of ListNode;
 
Function LinearProbing (a: pointer; k: integer; var c: integer;
                        t: table; from: char): pointer;
{LinearProbing is a last resort if the collision resolution fails.
   Starting with the address found by the first hashing function (a),
   It searches the array in an increment of 1 for an open slot or
   the key value (k) in the table (t).  If it is neither, the collision
   count (c) is incremented.  From is a character code that tells
   the function where it was called from in order to perform the
   correct operation as explained in the program documentation.}
var
  pos: pointer; {position in table}
  done: boolean; {flag}
begin
  done:= false;
  if a = TableSize then pos:= 1
  else pos:= a;
  while not done do
    begin
      c:= c + 1;
      if pos = TableSize then pos:= 1
      else pos:= pos + 1;
      if (t[pos].key = k) then done:= true;
      if pos = a then done:= true;
      if from = 'a' then
        if t[pos].key < 0 then
          done:= true
      else
        if t[pos].key = -1 then
          done:= true
    end;
  LinearProbing:= pos
end; {LinearProbing}
 
Function ColRes (a: pointer; k: integer; var c: integer;
                 t: table; from: char): pointer;
{ColRes is the Collision Resolution which in this case is double
  hashing.  It applies the key (k) to the function k div TableSize
  to get the probe decrement, added to a which is the address
  determined by the original hashing function.  It is then checked
  against the key in the table (t) to see if it is the correct
  position.  If it isn't, the collision count (c) is incremented.
  If a slot has not been found by the time there has been 7 trips
  through the array, a linear probing function is called to find the
  location.  From is a character code that tells
  the function where it was called from in order to perform the
  correct operation as explained in the program documentation.}
var
  pos: pointer; {position in table}
  dh, trips: integer; {dh is the double hashed value.
                       trips is the number of trips through the table.}
  done: boolean; {flag}
Begin
  done:= false;
  trips:= 0;
  pos:= a; {start at original address so its collision can be counted}
  dh:= k div TableSize;
  if dh = 0 then dh:= 1;
  while not done do
    begin
      c:= c + 1;
      pos:= pos + dh;
      if pos > TableSize then
        begin
          pos:= pos - TableSize;
          trips:= trips + 1;
        end;
      if (t[pos].key = k) or (trips = 7) then done:= true;
      if from = 'a' then
        if t[pos].key < 0 then
          done:= true
      else
        if t[pos].key = -1 then
          done:= true
    end;
  if trips < 7 then
    colres:= pos
  else
    colres:= LinearProbing(a, k, c, t, from)
End; {ColRes}
 
Function Hash (k: integer; t: table; var c: integer;
               from: char): pointer;
{Hash takes the key (k) and mods it by the table size to find a
   possible address.  If the address contains the key or is empty
   then that is the address returned, otherwise it calls on a
   collision resolution to find the address and increment the collision
   counter (c).  From is a character code with information on where
   hash was called from in order to help searching where a node
   is deleted where a collision took place earlier so the keys that
   were placed via collision resolution can be found.}
var
  h: pointer; {address from original hashing function}
Begin
  h:= (k mod TableSize) + 1;
  if (t[h].key = k) or (t[h].key < 0) then
    if from = 'a' then
      hash:= h
    else
     if t[h].key = -2 then
       hash:= ColRes (h, k, c, t, from)
     else
       hash:= h
  else
    hash:= ColRes (h, k, c, t, from);
End; {Hash}
 
Function Retrieve (k:integer; t:table): pointer;
{Retrieve find the address in table t of key k}
var
  position: pointer;
  dummy: integer; {collisions are counted in hash but the counter
                     is only needed for adds so dummy is passed to
                     hash for paramater matching}
begin
  position:= hash(k, t, dummy, 'r');
  if t[position].key = k then
    Retrieve:= position
  else
    Retrieve:= -1;
end; {Retrieve}
 
Procedure AddLink(k: integer; var t: table; p: pointer; var h: pointer);
{AddLink adds the key (k) at position p to the table (t) with the
   head pointer h.}
var
  temp, prev: pointer; {used to traverse links}
  done: boolean; {done with while loop when the proper spot is found}
begin
  temp:= h;
  prev:= null;
  done:= false;
                   {find position}
  while (temp <> null) and (not done) do
    if t[temp].key < k then
      begin
        prev:= temp;
        temp:= t[temp].next;
      end
    else
      done:= true;
                   {insert new item}
  if prev = null then
    h:= p
  else
    t[prev].next:= p;
  t[p].next:= temp
end; {AddLink}
 
Procedure Add (k: integer; var t: table; var h: pointer;
               var tk, col: integer);
{Add adds the key (k) to the table (t) with the head pointer h.
  It also increments the total number of keys (tk) by 1 and sends
  the collision counter col to hash for collision counting.
  Add first calls retrieve to see if the key is already in the list
  in case there is a -2 found before the actual key, in which case
  add alone would just replace the the -2 with the key which may
  yield duplicates.}
var
  position: pointer;
begin
  position:= Retrieve(k, t);
  if position = -1 then {add key to table}
    begin
      position:= Hash(k, t, col, 'a');
        {retrieve overlooks prior deletions so an open slot may be
           available before the prior position, so hash is called again
           to get that position}
      t[position].key:= k;
      AddLink(k, t, position, h);
      tk:= tk + 1
    end
  else
    Writeln ('Key ',k:1,' is a duplicate.')
end; {Add}
 
Procedure DeleteLink (k: integer; var t: table; var h: pointer);
{DeleteLink removes the link associated with the key}
var
  temp, prev: pointer; {traverses list}
  found: boolean; {flag}
begin
   temp:= h;
   prev:= null;
   found:= false;
                   {find key}
   while (temp <> null) and (not found) do
     begin
       if t[temp].key = k then
         found:= true
       else
         begin
           prev:= temp;
           temp:= t[temp].next
         end
     end;
                   {remove link}
   if (found) and (prev = null) then {beginning of the list}
     h:= t[temp].next
   else
     t[prev].next:= t[temp].next
end; {DeleteLink}
 
Procedure Delete (k: integer; var t: table; var h: pointer;
                  var tk: integer);
{Delete finds the position of the key and removes the link involved.
   It then removes the key itself by replacing it with a -2.}
var
  position: pointer; {position of key to be deleted}
begin
  position:= retrieve(k, t);
  if position <> -1 then {found the key}
    begin
      DeleteLink(k,t,h);
      t[position].key:= -2;
      tk:= tk - 1
    end
  else
    writeln ('Key ',k:1,' not found')
end; {Delete}
 
Procedure traverse (t: table; h: pointer);
{Traverse displays the ordered list from table t beginning with h}
var
  temp: pointer;
begin
   temp:= h;
   while temp <> null do
     begin
       writeln (t[temp].key);
       temp:= t[temp].next
     end
end; {Traverse}
 
Procedure Init(var t: table; var tk, col: integer);
{InitTable sets all key values within the table to -1 and sets the
   total keys (tk) and collisions (col) to 0}
var
  i: integer; {loop index}
begin
  for i:= 1 to TableSize do
    t[i].key:= -1
end; {InitTable}
 
Procedure GetInfo(var t: table; var h: pointer; var tk, c: integer);
{GetInfo reads keys from a file and places them into the table t.
  It returns the new table and the address of the first node in the
  ordered list.}
var
  infile: text; {input file}
  k: integer; {key}
  ch: char; {dummy character}
begin
  reset(infile, 'name = hash.data.*');
  while not eof (infile) do
    if eoln (infile) then
      readln(infile)
    else
      if infile@ in ['0'..'9'] then
        begin
          read(infile, k);
          if (k >= 0) and (k <= 999) then
            add(k, t, h, tk, c)
        end
      else read(infile, ch)
end; {GetInfo}
 
Procedure DisplayMenu;
{Displaymenu gives the menu of options for the program}
begin
  writeln;
  writeln('A)dd a key');
  writeln('D)elete a key');
  writeln('R)etrieve the address of a key');
  writeln('S)tatistics');
  writeln('T)raverse the list');
  writeln('Q)uit');
  writeln;
  writeln('choose 1:')
end; {menu}
 
Procedure Statistics (tk, c: integer);
{Statistics reports the final results of the program.  It supplies the
   user with the table size, the total number of keys (tk) in the
   table, the hashing function used, the collision resolution used,
   and the number of collisions (c).}
begin
  writeln;
  writeln('Statistics:');
  writeln('     Table Size: ',TableSize:1);
  writeln('     Number of Keys: ',tk:1);
  writeln('     Load Factor: ',(tk / TableSize):1:3);
  writeln('     Hash Function: k mod ',TableSize:1);
  writeln('     Collision Resolution: Double Hashing');
  writeln('     Number of Collisions: ', c:1)
end; {Statistics}
 
{main begins by initializing the table and other variables to their
   proper values. Then it calls a procedure to obtain keys from an
   input file.  Then a loop is processed containing a menu of
   options for the user until the user decides to quit.  The proper
   procedures and functions are called depending on the user's
   decision.  After quitting, a statistics procedure is called
   and main ends.}
 
var
  head: pointer; {address of the first node in the ordered list}
  choice: char; {selection from menu}
  k, totkeys, collisions, position: integer;
           {k is the key given by user}
           {totkeys is the total number of keys}
           {collisions in the number of collisions}
           {position is address found by retrieval}
  KeyTable: table; {table of keys}
 
Begin {main}
  termin(input);
  termout(output);
  Init(KeyTable, totkeys, collisions);
  head:= null;
  GetInfo(KeyTable, head, totkeys, collisions);
  Repeat
    DisplayMenu;
    readln(choice);
    if choice in ['A', 'a', 'D', 'd', 'R', 'r'] then
      repeat
        writeln('Give the key: ');
        readln(k);
      until (k >= 0) and (k <= 999);
    if choice in ['A', 'a', 'D', 'd', 'R', 'r', 'T', 't', 'S','s'] then
      case choice of
         'A', 'a': add(k, KeyTable, head, totkeys, collisions);
         'D', 'd': delete(k, KeyTable, head, totkeys);
         'R', 'r': begin
                     position:= retrieve(k, KeyTable);
                     if position <> -1 then {found key}
                       writeln ('Address: ',position:1)
                     else
                       writeln ('Key ',k:1,' not found')
                   end;
         'T', 't': traverse(KeyTable, head);
         'S', 's': Statistics(totkeys, collisions)
        end
  Until choice in ['q', 'Q'];
  Writeln; writeln('Final Stats:');
  Statistics(totkeys, collisions)
End; {Hashing}
