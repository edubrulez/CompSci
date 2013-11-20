program Lab12; {application to call quicksort}
 
{Erick Nave
 DSAI 11-23-93}
 
%include labsorts
%include quiksort
 
 var qstime,size:integer;
     f:file of qdata;
     Q:Queue;
 
procedure FillQfromFile(var Q:Queue; size:Integer);
  var i:integer; item:Qdata;
 begin
  reset(f,'name=radix.data.*');
  for i:= 1 to size do
   BEGIN
     read(f,Item);
     enqueue(q, item)
   end
 end;
 
procedure WriteQtoFile(var Q:Queue);
  var item:qdata;
 begin
  rewrite(f,'name=radix.data.a');
  while not Qempty(Q) do
   begin
     dequeue(q,item);
     write(f,item)
   end
 end;
 
begin
 termout(output);
 ReadStr(Parms, Size);
 Writeln('Size specified: ',size:1);
 QCreate(Q);
 FillQFromFile(Q,Size);
 QuickSort(Q,qstime);
 Writeln('QuickSort Sorting Time:',qstime:10);
{WriteQToFile(Q);}
 QDestroy(Q)
end;
