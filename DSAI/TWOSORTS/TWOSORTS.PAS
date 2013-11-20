program TwoSorts;
 
{Erick Nave
 DSAI 11-23-93}
 
{TwoSorts uses a queue ADT and a quicksort procedure supplied to me to
  build a queue and sort it using radix sort and rebuild the old queue
  to use with quick sort.  The times for each sort is written to the
  screen and the queue sorted by radix sort is sent to an output file.}
 
%include sorts {Type declarations and call to queue adt}
%include quiksort {quick sort procedure}
 
TYPE
  DataFile = File of QData; {QData defined in sorts.  File type for
                               input and output files.}
 
PROCEDURE GetQ (var Q:queue; Size:Integer);
  {GetQ makes a queue of size Size from a DataFile}
  VAR
    count: Integer; {counts iterations of loop}
    item: QData; {item read from input file}
    Infile: DataFile; {input file}
  BEGIN
    WRITELN ('Reading from input file');
    reset(Infile, 'name = radix.data.*');
    count:= 0;
    WHILE (not eof(infile)) and (count < size) do
      BEGIN
        count:= count + 1;
        READ (infile, item);
        Enqueue(q,item)
      end
  END; {GetQ}
 
PROCEDURE WriteQ(var Q:Queue);
  {WriteQ writes the queue to a DataFile.}
  VAR
   Item: QData; {item to be written to DataFile}
   Outfile: DataFile; {output file}
  BEGIN
    WRITELN ('Writing to output file');
    Rewrite(outfile,'name= radix.sorted.a');
    While not Qempty(Q) do
      BEGIN
        dequeue(Q,item);
        write(outfile, item)
      end
  end; {WriteQ}
 
PROCEDURE RadixSort(var Q:queue; n:integer; var timesort:integer);
  {RadixSort sorts Q using radix sort of n character precision and
     returns the new queue and the time it took to sort Q}
  VAR
    SubList: Array [char] of Queue; {array of queues of data beginning
                                       with a certain character}
    ch: char; {loop index}
    Item: QData; {item enqueued/dequeued from queue}
    start: integer; {start time}
  BEGIN
    WRITELN('Using Radix Sort');
    IF n > DataLength then n:= 50;
    IF not QEmpty(Q) then
      BEGIN
        start:= clock;
        WHILE n > 0 do
          BEGIN
            for ch:= chr(0) to chr(255) do
             QCreate(SubList[ch]);
            WHILE not QEmpty(q) do
              BEGIN
                Dequeue(Q,Item);
                Enqueue(SubList[Item[n]], item)
              END;
            QDestroy(Q);
            QCreate(Q);
            for ch:= chr(0) to chr(255) do
              BEGIN
                WHILE not QEmpty(SubList[ch]) do
                  BEGIN
                    Dequeue(Sublist[ch], item);
                    Enqueue(Q, item)
                  END;
                QDestroy(Sublist[ch])
              END;
            n:= n-1
          end;
        timesort:= clock - start
      end
    ELSE
      timesort:= 0
  END; {RadixSort}
 
 
 var n,size, time:integer; {TIME of sorts}
      master: queue; {master list}
 
{the main body obtains size and n from the rexx program used to start
  this program.  It writes size and n to the screen. It then calls the
  proper procedures to build, sort with radix sort, re-build, and sort
  queues with quick sort.  It writes the times of the sorts to the
  screen.}
 
begin
 termout(output);
 ReadStr(Parms, Size, N);
 Writeln('Size: ',size:1);
 Writeln('N: ',n:1);
 QCreate(master);
 GetQ(master,Size);
 RadixSort(master,n,time);
 Writeln ('Radix Sort Time: ',Time:1);
 WriteQ(master);
 QDestroy(Master);
 QCreate(Master);
 GetQ(Master, Size);
 Writeln('Using Quick Sort');
 QuickSort(Master,time);
 Writeln('Quick Sort Time: ',Time:1);
 QDestroy(master)
end;
