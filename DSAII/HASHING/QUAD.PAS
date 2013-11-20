Program Hashing;
 
{Erick Nave
 DS&A II 1:00
 Start 4-19-94
 Last Update 4-21-94
 
 Hashing............ }
 
Const
  TableSize = 113;
  Null = 0;
 
Type
  Pointer = Integer; {For simulated dynamic memory}
  ListNode = Record
               Key: Integer;
               Next: Pointer
             End;
  Table = Array [1..TableSize] of ListNode;
 
Function LinearProbing (a: pointer; k: integer; var c: integer;
                        t: table): pointer;
{LinearProbing is a last resort....}
var
  pos: pointer;
begin
  if a = TableSize then pos:= 1
  else pos:= a;
  while (t[pos].key <> k) and (t[pos].key <> -1) do
    begin
      c:= c + 1;
      if pos = TableSize then pos:= 1
      else pos:= pos + 1
    end;
  LinearProbing:= pos
end; {LinearProbing}
 
Function ColRes (a: pointer; k: integer; var c: integer;
                 t: table): pointer;
{ColRes is the Collision Resolution...........}
var
  pos: pointer;
  done: boolean; {flag}
  x,i: integer;
Begin
  done:= false;
  i:= 1;
  while not done do
    begin
      c:= c + 1;
      pos:= a + (i * i);
      if pos > TableSize then pos:= (pos mod TableSize) + 1;
      if (t[pos].key = k) or (t[pos].key = -1) or (i = 25) then
        done:= true
      else i:= i + 1
    end;
  if i <> 25 then
    colres:= pos
  else
    colres:= LinearProbing(a, k, c, t)
End; {ColRes}
 
Function Hash (k: integer; t: table; var c: integer): pointer;
{Hash ...........}
var
  h: pointer; {address from original hashing function}
Begin
  h:= (k mod TableSize) + 1;
  if (t[h].key = k) or (t[h].key = -1) then
    hash:= h
  else
    hash:= ColRes (h, k, c, t)
End; {Hash}
 
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
  the collision counter col to hash for collision counting.}
var
  position: pointer;
begin
  position:= Hash(k, t, col);
  if t[position].key = -1 then
    begin
      t[position].key:= k;
      AddLink(k, t, position, h);
      tk:= tk + 1
    end
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
   It then removes the key itself by replacing it with a -1.}
var
  position: pointer; {position of key to be deleted}
  dummy: integer; {collisions are counted in hash but the counter
                     is only needed for adds so dummy is passed to
                     hash for paramater matching}
begin
  position:= hash(k, t, dummy);
  if t[position].key = k then {found the key}
    begin
      DeleteLink(k,t,h);
      t[position].key:= -1;
      tk:= tk - 1
    end
  else
    writeln('Key ',k:1,' not found.  Cannot delete.')
end; {Delete}
 
Procedure Retrieve (k:integer; t:table);
{Retrieve find the address in table t of key k}
var
  position: pointer;
  dummy: integer; {collisions are counted in hash but the counter
                     is only needed for adds so dummy is passed to
                     hash for paramater matching}
begin
  position:= hash(k, t, dummy);
  if t[position].key = k then
    writeln('Address: ',position:1)
  else
    writeln ('Key ',k:1,' not found')
end; {Retrieve}
 
Procedure traverse (t: table; h: pointer);
{Traverse displays the ordered list from table t beginning with h}
var
  temp: pointer;
begin
   temp:= h;
   while temp <> null do
     begin
       writeln (t[temp].key, temp);
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
  ch: char;
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
{menu gives the menu of options for the program}
begin
  writeln;
  writeln('A)dd a key');
  writeln('D)elete a key');
  writeln('R)etrieve the address of a key');
  writeln('T)raverse the list');
  writeln('Q)uit');
  writeln;
  writeln('choose 1:')
end; {menu}
 
Procedure Statistics (tk, c: integer);
begin
  writeln;
  writeln('Statistics:');
  writeln('     Table Size: ',TableSize:1);
  writeln('     Number of Keys: ',tk:1);
  writeln('     Load Factor: ',(tk / TableSize):1:3);
  writeln('     Hash Function: k mod ',TableSize:1);
  writeln('     Collision Resolution: Quadratic Resolution');
  writeln('     Number of Collisions: ', c:1)
end; {Statistics}
 
{main...........}
 
var
  head: pointer; {address of the first node in the ordered list}
  choice: char; {selection from menu}
  k, totkeys, collisions: integer; {k is the key given by user}
           {totkeys is the total number of keys}
           {collisions in the number of collisions}
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
    if choice in ['A', 'a', 'D', 'd', 'R', 'r', 'T', 't'] then
      case choice of
         'A', 'a': add(k, KeyTable, head, totkeys, collisions);
         'D', 'd': delete(k, KeyTable, head, totkeys);
         'R', 'r': retrieve(k, KeyTable);
         'T', 't': traverse(KeyTable, head)
        end
  Until choice in ['q', 'Q'];
  Statistics(totkeys, collisions)
End; {Hashing}
