program lab6c;
{insert name here}
 
{This program is to read data from a file and place it in a linked
 list. The list is printed, then modified, then printed again. You
 need to complete the printing and modification procedures}
 
type
 Npointer = @Listnode;
 ListNode = Record
             X : Integer;
             Next : Npointer
            End;
 
Procedure ReadList(var L:Npointer);
 var temp:Npointer;
Begin
 Reset(input,'Name=Lab6C.Data.*');
 L:=nil;
 While not eof do begin
  temp:=L;
  New(L);
  Readln(L@.X);
  L@.next := temp
 end
End;
 
Procedure ChangeList(var L:Npointer);
var last, temp, prev: npointer;
Begin {Change list per specifications}
  if l <> nil then begin
    last:=l;
    while last <> nil do begin
      prev:= last;
      last:= last@.next
     end;
    temp:= l;
    new(prev@.next);
    prev@.next@.x:= temp@.x;
    prev@.next@.next:= nil;
    l:= l@.next;
    dispose(temp)
   end
  ELSE
   writeln('empty list')
End;
 
Procedure DisplayList(L:Npointer);
 
Begin {write out contents of list, one item per line}
  WHILE l <> nil do begin
    writeln (l@.x);
    l:= l@.next
  end
End;
 
 
var List : NPointer;
Begin
 termout(output);
 ReadList(List);
 writeln('List contents before change...');
 DisplayList(List);
 ChangeList(List);
 writeln('List contents after change...');
 DisplayList(List);
End.
