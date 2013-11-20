program lab13c;
{Erick Nave}
type
     nodeptr = @QNode;
     Queue = record
               front,rear:nodeptr
             end;
     QData = integer;
     QNode = record
               data:QData;
               next:nodeptr
             end;
procedure QDriver; external;
procedure QRotate(var Q:Queue;n:integer); external;
procedure QRotate;
{  Insert your code here  }
 var x: integer;
 begin
   for x:= 1 to n do
     if q.front <> NIL then begin
      Q.rear@.Next:= Q.Front;
      Q.rear:= Q.Front;
      Q.front:= Q.Front@.next;
      Q.rear@.Next:= NIL;
    end
end;
 
begin
 QDriver
end.
