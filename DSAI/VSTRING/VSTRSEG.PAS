segment vstrseg;
{Erick Nave
 DS&A I 10-26-93}
 
{The segment VSTRSEG enables a user to incorporate variable length
   strings into another program.  VSTRSEG contains functions and
   procedures that perform the operations performed on ADT Variable
   Length String}
 
{The include file defines constants and types used below. It also
 contains the function and procedure headings for the "external"
 subprograms below. Since parameters and function types have already
 been defined in this include file, they are not allowed to be
 when the subprogram is defined. The parameters and function types
 are included as comments for your reference}
% include vstrtype
 
{Local procedures and functions should be placed here. These would
 be called by the procedures and functions defined below, but would
 not be available to any application using this module.}
 
PROCEDURE NextChLoc (var SB: BPtr; var Loc: Integer);
  {NextChLoc finds the location of the next character in the string by
     either increasing the location by 1 (loc) or if it is at the end
     of a block, advances to the beginning of the next block.}
  BEGIN
    IF Loc < SB@.SegLength then Loc:= Loc + 1
    ELSE
      BEGIN
        SB:= SB@.Next;
        Loc:=1
      end
  end; {NextChLoc}
 
PROCEDURE FindPos (s:VString; Pos:Integer; Var Block:BPtr;
                      var NewPos:Integer);
{FindPos finds the block and position (newpos) within that block after
   being given the string (s) and the position in the entire string
   (pos).}
VAR
  temp: BPtr;  {temporary address storage}
  prevsize, size: INTEGER;  {used in computations to end the loop and
                                to find pos.}
BEGIN
  temp:= S.First;
  Block:= NIL;
  prevsize:=0;
  size:=0;
  WHILE (temp <> NIL) and (size < pos) do
    BEGIN
      prevsize:= size;
      Block:= temp;
      Size:= size + temp@.SegLength;
      temp:= temp@.next
    end;
  newpos:= pos - prevsize;
  IF Block = NIL then
    Block:= S.First
END; {FindPos}
 
{Below are the "external" subprograms that form the VString module.}
 
function VCreate{S:VString};
{VCreate returns an initialized variable length string of length 0
   and initializes the pointer first  to NIL.}
begin
  VCreate.Length:= 0;
  VCreate.First:= NIL
end; {VCreate}
 
procedure VDestroy{var S:VString};
{disposes of any dynamic memory associated with S and sets the length
   to -1 in order to error check for usage of disposed strings when
   necessary}
VAR
  Temp, Destroy: BPtr; {used in deletions}
begin
  IF S.Length <> -1 then
    BEGIN
      temp:= S.First;
      WHILE temp <> NIL do
        BEGIN
          destroy:= temp;
          temp:= temp@.Next;
          DISPOSE(destroy)
        END;
      S.Length:= -1
    END
  ELSE
    WRITELN ('ERROR - String already destroyed')
end; {VDestroy}
 
function VLength{var S:VString):Integer};
{return the current length of the string S and gives an error if a
   destroyed string is used.}
begin
  VLength:= S.Length;
  IF S.Length = -1 then
    WRITELN('ERROR - String previously destroyed.')
end; {VLength}
 
function VReadStr{var f:text):VString};
{returns a string of characters read from file f (up to end of line)
   It has an outer loop that creates nodes of string segments and
   an inner loop that builds the segment.  A VString with its proper
   length and pointer to the first node is returned.}
VAR
  head, temp, last: BPtr; {used to help build list}
  SegSize, TotSize: Integer; {Seg = segment, tot = total for string}
begin
  head:= NIL;
  totsize:= 0;
  WHILE (not eoln(f)) and (not eof(f)) do
    BEGIN
      SegSize:= 0;
      NEW (temp);
      WHILE (not eoln(f)) and (not eof(f)) and (SegSize < MaxBSize) do
        BEGIN
          SegSize:= SegSize + 1;
          Read (f, temp@.StrSegment[SegSize])
        END;
      totsize:= totsize + SegSize;
      temp@.SegLength:= SegSize;
      temp@.next:= NIL;
      IF head = NIL then
        head:= temp
      ELSE
        Last@.Next:= temp;
      Last:= temp
    END;
  VReadStr.Length:= totsize;
  VReadStr.First:= Head
end; {VReadStr}
 
procedure VWriteStr{var f:text; var S:VString};
{write all of S to file f and checks to see if string has been prev-
   iously been destroyed so as not to write it.}
VAR
  temp: BPtr; {temporary address storage}
  loc: integer; {position of character to be written}
begin
  IF S.Length = -1 then
    WRITELN (f,'ERROR - String destroyed')
  ELSE
    BEGIN
      temp:=S.First;
      loc:= 1;
      WHILE temp <> NIL do
        BEGIN
          WRITE (f, temp@.StrSegment[loc]);
          NextChLoc(temp, loc)
        end
    end
end; {VWriteStr}
 
function CopyOf{var S:VString):VString};
{returns a copy of S.  S is copied block by block so as to give the
   new string the same list but with different addresses so the 2
   strings are independent of one another.  S is also checked to see
   if it has been previously destroyed and alerts the user if it has.
   Since CopyOf is a function though, a string with the length -1 and
   first being NIL is returned if S was destroyed.}
VAR
  Head, Stemp, Temp, last: BPtr; {needed to build the new list}
begin
  Head:= NIL;
  IF S.Length = -1 then
    WRITELN ('ERROR - String Destroyed')
  ELSE
    BEGIN
      Stemp:= S.First;
      WHILE Stemp <> NIL do
        BEGIN
          New(temp);
          temp@:= Stemp@;
          temp@.Next:= Nil;
          IF Head = NIL then
            Head:= temp
          ELSE
            last@.Next:= temp;
          Last:= temp;
          Stemp:= Stemp@.Next
        end
    end;
  CopyOf.length:= S.Length;
  CopyOf.First:= Head
end; {CopyOf}
 
function CHat{var S:VString; Pos:Integer):Char};
{return character at position Pos in string.  It checks for these error
    conditions: Destroyed string, Pos <= 0, or Pos > length of the
    S string brought in.  If one of these conditions are met, the
    appropriate error message is given and CHat returns a space since it
    must return something.}
var
  Sblock:BPtr; {block containing sloc}
  Sloc:Integer; {position in block where ch is}
begin
 IF S.Length = -1 then begin
   WRITELN('ERROR - String destroyed');
   CHat:= ' '
  end
 ELSE
  IF S.First <> NIL then
    IF (Pos <= 0) or (Pos > S.Length) then
      BEGIN
        WRITELN('INVALID POSITION');
        CHat:= ' '
      END
    ELSE
      BEGIN
        FindPos (S, pos, Sblock, Sloc);
        CHat:= Sblock@.StrSegment[Sloc]
      END
  ELSE
    BEGIN
      WRITELN('EMPTY STRING');
      CHat:= ' '
    END
end; {CHat}
 
function VStr{CH:Char):VString};
{return string of length one containing the character CH}
VAR
  head: BPtr; {temporarily holds record for VStr}
begin
  new(head);
  head@.StrSegment[1]:= ch;
  head@.SegLength:= 1;
  head@.Next:= NIL;
  VStr.Length:= 1;
  VStr.First:= head
end; {VStr}
 
procedure VConcat{var S,T:VString};
{Concatenates T to end of S. T is left unchanged. If block lengths of
   the last block in S and the first block in t total < 20 then the
   first and last blocks will be merged to be more memory efficient.
   if the total is > 20 then the lists will just be joined together.
   It also checks to see if one of the strings hs been destroyed
   so an improper concatenation doesn't occur and that the strings will
   be returned without changes.}
VAR
  Stemp, Sprev: BPtr; {used to find last block of s}
  copy: VString;   {makes a copy of t so t won't be bothered}
  NewSegLen, Spos, copypos: Integer;  {used to merge blocks}
begin
 IF (S.Length = -1) or (T.Length = -1) then
  WRITELN ('ERROR - Using a destroyed string')
 ELSE
  BEGIN
    copy:= CopyOf(T);
    IF S.First <> NIL then
     BEGIN
       Stemp:= S.First;
       WHILE Stemp <> NIL do
         BEGIN
           Sprev:= Stemp;
           Stemp:= Stemp@.Next
         END;
       IF copy.First <> NIL then
         BEGIN
           NewSegLen:= Sprev@.SegLength + Copy.First@.SegLength;
           IF NewSegLen <= MaxBSize then
             BEGIN
               Copypos:= 1;
               FOR Spos:= (Sprev@.SegLength + 1) to NewSegLen do
                 BEGIN
                   Sprev@.StrSegment[Spos]:= Copy.First@.StrSegment
                                                       [Copypos];
                   Copypos:= Copypos+1
                 END;
               Sprev@.SegLength:= NewSegLen;
               Sprev@.Next:= copy.First@.next;
               Dispose(copy.first)
             END
           ELSE
             Sprev@.next:= copy.First;
         END
       else {needed to match next else with proper if}
     END
    ELSE
      S.First:= copy.First;
    S.Length:= S.Length + copy.Length
 end
end; {VConcat}
 
function VSubstr{var S:VString; Start,Len:Integer):VString};
{returns a string composed of the Len characters of S starting
    at position Start.  Error conditions exist when start <= 0 or
    or len < 0. The user is alerted of the error and the empty string
    is returned since VSubstr is a function.  If Len exceeds the size
    of string, then the characters from start to the end of S are put
    in the substring, if start > length of S then the empty string is
    returned due to the loop conditions. There is no consequence to
    passing a destroyed string here because of the loop conditions
    due to the fact that since it is only executed when start and len
    are valid and because of the if structure finish will be -1 so
    start will always be > finish in this case.  An empty string will
    be returned.}
VAR
  sub, temp, last: BPtr; {Sub is head of list built by temp and last}
  finish, segsize, totsize: Integer; {finish is ending position}
      {seg= segment, tot = total for string}
begin
  sub:= NIL;
  totsize:= 0;
  IF (start <= 0) or (len < 0) then
    WRITELN ('INVALID START OR LENGTH')
  ELSE
    BEGIN
      IF (start + len) > S.length then
        finish:= s.length
      ELSE
        finish:= start + len - 1;
      WHILE start <= finish do
        BEGIN
          segsize:= 0;
          NEW(temp);
          WHILE (segsize < MaxBSize) and (start <= finish) do
            BEGIN
              segsize:= segsize + 1;
              temp@.StrSegment[segsize]:= CHat(S, start);
              start:= start + 1
            END;
          totsize:= totsize + segsize;
          temp@.seglength:= segsize;
          temp@.next:= NIL;
          IF sub = NIL then
             sub:= temp
          ELSE
             last@.next:= temp;
          last:= temp
        end
      end;
  VSubstr.First:= sub;
  VSubstr.Length:= totsize
end; {VSubstr}
 
procedure VInsert{var S,T:VString; Place:Integer};
{inserts string T in S starting at position Place. T is not altered
    VInsert uses VSubstr to break the string apart and then uses
    VConcat to join the first part to what is to be inserted and then to
    join that to the last part.}
var
  left, right: VString; {substrings to break s apart}
begin
  Left:= VSubstr(S, 1, Place - 1);
  Right:= VSubstr(s, Place, VLength(s));
  VConcat(Left, T);
  VConcat(Left, Right);
  VDestroy(S);
  VDestroy(Right);
  S:= Left
end; {VInsert}
 
procedure VDelete{var S:VString; Start,Len:Integer};
{deletes the Len characters of S starting at position Start.  It uses
   VSubstring to take the substrings of the parts that the user wants
   to keep and then rejoins them using VConcat.}
var
  left, right: VString; {substrings to break s apart}
begin
  Left:= VSubstr(S, 1, Start - 1);
  Right:= VSubstr(s, Start + Len, VLength(s));
  VConcat(Left, Right);
  VDestroy(S);
  VDestroy(Right);
  S:= Left
end; {VDelete}
 
function VSearch{var S,T:VString; Start:Integer):Integer};
{returns location of first occurrence of pattern T in string S
    at or after position Start. Zero is returned if T is not located.
    Error conditions exist when one of the strings has been destroyed
    or when start <= 0.  The user is then alerted and a 0 is returned
    If start > length of S then a 0 is returned also. VSearch looks for
    when the first character in T matched with one in S. Then the
    characters in T are compared to the characters in S while they
    match.  If Tblock becomes NIL then it is found.  If not then it
    continues searching S till a character = the first character in
    T again.  This continues until a match is found or Sblock becomes
    NIL in which case a zero is returned.}
VAR
  Sblock, Tblock: BPtr; {current blocks of t and s}
  Sloc, Tloc, equalloc, Pos: Integer; {s & tloc are location in block}
       {equalloc is position in string where char at sloc = one at tloc}
       {pos is position in entire string}
  Equal, done: Boolean; {used in decision making}
begin
 IF (S.Length = -1) or (T.Length = -1) then
  BEGIN
   WRITELN ('ERROR - using a destroyed string');
   VSearch:= 0
  END
 ELSE
  IF start <= 0 then
    BEGIN
      VSearch:= 0;
      WRITELN ('Invalid Start Number.');
    END
  ELSE
    IF (Start > S.Length) or (T.Length > S.Length) then
      VSearch:= 0
    ELSE
      BEGIN
        FindPos (S, Start, Sblock, Sloc);
        Pos:= Start;
        Tblock:= T.First;
        equalloc:= 0;
        WHILE (Sblock <> NIL) and (Tblock <> NIL) do
          BEGIN
            Tloc:= 1;
            IF (Sblock@.StrSegment[Sloc] = Tblock@.StrSegment[Tloc])
              then BEGIN
                equalloc:= Pos;
                equal:= true;
                WHILE (Sblock <> NIL) and (Tblock <> NIL) and equal do
                  IF Sblock@.StrSegment[Sloc]=Tblock@.StrSegment[Tloc]
                    THEN BEGIN
                      NextChLoc(Sblock, sloc);
                      Pos:= Pos + 1;
                      NextChLoc(Tblock, Tloc)
                    END
                  ELSE equal:= false
              END;
            IF (Sblock <> NIL) and (Tblock <> NIL) then
              BEGIN
                NextChLoc(Sblock, Sloc);
                Pos:= Pos + 1
              END
          END;
        IF Tblock = NIL then VSearch:= equalloc
        ELSE VSearch:= 0
      END
end; {VSearch}
 
function VEqual{var S,T:VString):Boolean};
{compares strings for equality}
begin
  VEqual:= (VSearch(S, T, 1) = 1) and (S.Length = T.Length)
end; {VEqual}
 
function VLessThan{var S,T:VString):Boolean};
{compares strings to see if S < T}
VAR
  Sblock, Tblock: BPtr; {current blocks of s and t}
  Sloc, Tloc: Integer;  {locations in blocks s and t}
  equal: boolean;    {used in decision making}
begin
  Sblock:= S.First;
  Tblock:= T.First;
  SLoc:= 1;
  TLoc:= 1;
  Equal:= true;
  WHILE (Sblock <> NIL) and (Tblock <> NIL) and equal do
    IF Sblock@.StrSegment[Sloc] <> Tblock@.StrSegment[TLoc] then
      Equal:= false
    ELSE
      BEGIN
        NextChLoc(Sblock, Sloc);
        NextChLoc(Tblock, Tloc)
      END;
  IF not equal then
    VLessThan:= (SBlock@.StrSegment[Sloc] < Tblock@.StrSegment[Tloc])
  ELSE
    VLessThan:= (SBlock = NIL) and (TBlock <> NIL)
end; {VLessThan}
 
. {marks end of segment file}
