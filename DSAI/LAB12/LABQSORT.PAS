segment Quiksort;
 
{Erick Nave
 DSAI 11-23-93}
 
%include labsorts
%include quiksort
 
Procedure QuickSort{var Q:Queue; var TimeSort:integer};
 {quicksort using the Queue ADT }
 
 procedure QS(var Q:Queue);
 var pivot, item: QData;
     small, large:Queue;
 Begin
   If not Qempty(q) then
     BEGIN
       Dequeue(Q,pivot);
       Qcreate(small);
       Qcreate(large);
       while not Qempty(Q) do
         begin
           Dequeue(Q,item);
           IF item <= pivot then
             Enqueue(Small,item)
           else
             Enqueue(large,item);
         end;
       QS(Small); QS(Large);
       Enqueue(Small,pivot);
       QAppend(Small,large);
       QAppend(Q,small)
   end
 End;
 
begin
  TimeSort := Clock;
  QS(Q); {actual quicksort call}
  TimeSort := Clock - TimeSort;
end;
.
