segment QueueADT;
 
{Erick Nave
 DSAI 11-19-93}
 
{QueueADT uses dynamic memory to implement the queue in order to ease
  the process dequeueing the Queue since the first node is easy to
  get to and remove without costly data moves or complex code.  Dynamic
  memory also makes attaching 2 queues easier since all that has to be
  done is link the 2 lists together.  This segment Creates, Destroys,
  adds to the end of (Enqueue), removes from the beginning of (Dequeue)
  and links queues.  It also tells if the queue is empty or full.}
 
%Include Sorts
 
procedure QCreate{var Q:Queue};
 {QCreate sets the first and last pointers of the queue to NIL.}
 begin
   Q.First:= NIL;
   Q.Last:= Q.First
 end;
 
procedure QDestroy{var Q:Queue};
 {Disposes of all dynamic memory associated with Q}
 Var temp, hold: QPtr; {TEMPorary storage of address.  HOLDs address
                          for disposal.}
 begin
   Temp:= Q.First;
   WHILE temp <> NIL do
     BEGIN
       hold:= temp;
       temp:= temp@.next;
       dispose (hold)
     END;
   Q.First:= NIL;
   Q.Last:= NIL
 end;
 
function QEmpty{Q:Queue):boolean};
 {Queue is empty when Last is NIL.}
 begin
  QEmpty := Q.Last = NIL
 end;
 
function QFull{Q:Queue):boolean};
 begin {this one is done!}
  QFull:=false
 end;
 
procedure EnQueue{var Q:Queue; Item:QData};
 {EnQueue adds a member of the queue to the end of the list.}
 VAR
   Temp: Qptr;
 begin
   IF not QFull(Q) then
     BEGIN
       New (Temp);
       Temp@.Data:= Item;
       Temp@.Next:= NIL;
       IF Q.First = NIL then
         BEGIN
           Q.First:= Temp;
           Q.Last:= Q.First
         END
       ELSE
         BEGIN
           Q.Last@.Next:= Temp;
           Q.Last:= Temp
         END
     END
 end;
 
procedure DeQueue{var Q:Queue; var Item:QData};
 {DeQueue returns the first item of Q and then removes the node}
 VAR
   hold: Qptr; {holds address to be destroyed}
 begin
   IF not QEmpty(Q) then
     BEGIN
       Item:= Q.First@.Data;
       hold:= Q.First;
       Q.First:= Q.First@.Next;
       Dispose (Hold);
       IF Q.First = NIL then
         Q.Last:= Q.First
     END
 end;
 
procedure QAppend{var Q1,Q2:Queue};
 {QAppend attaches Q2 to the end of Q1 and then "destroys" Q2.
    It actually just makes Q2.First and Last NIL.}
 begin
   IF not Qempty(Q1) then
     Q1.Last@.Next:= Q2.First
   ELSE
     Q1.First:= Q2.First;
   IF not Qempty (Q2) then
     Q1.Last:= Q2.Last;
   Q2.First:= NIL;
   Q2.Last:= Q2.First
 end;
 
.
