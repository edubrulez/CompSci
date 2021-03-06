program sorttest;
 
{modified by Erick Nave 10-20-93}
 
const datalen = 1;
      maxarr = 1000;
      seed = 12;
      LengthConstant = 25;{number of records added for each data point}
      maxfiles = 9;
      maxpoints = 30;
 
type datatype = record
                  key:integer;
                  data:packed array[1..datalen] of char;
                end;
     arraytype = array[1..maxarr] of datatype;
     ordertype = (ASCENDING,DESCENDING,UNORDERED);
 
 
procedure InsertionSort(var a:arraytype;len:integer);
var i,j:integer;
    temp:datatype;
begin
  for i:=2 to len do
    begin
      temp:=a[i];
      j:=i-1;
      while (j>=1) and (a[j].key>temp.key) do
        begin
          a[j+1]:=a[j];
          j:=j-1
        end;
      a[j+1]:=temp;
    end
end;
 
procedure SelectionSort(var a:arraytype;len:integer);
var i,j,min:integer;
    temp:datatype;
begin
  for i:=1 to len-1 do
    begin
      min:=i;
      for j:=i+1 to len do
        if a[j].key<a[min].key then
          min:=j;
      temp:=a[min];
      a[min]:=a[i];
      a[i]:=temp
    end
end;
 
procedure BubbleSort(var a:arraytype;len:integer);
var i,j:integer;
    temp:datatype;
    swap:boolean;
begin
  repeat
    swap:=false;
    for i:=1 to len-1 do
      if a[i].key>a[i+1].key then
        begin
          temp:=a[i+1];
          a[i+1]:=a[i];
          a[i]:=temp;
          swap:=true
        end
  until not swap
end;
 
procedure GenerateList(var a:arraytype;len:integer;order:ordertype);
var k:integer;
    s:integer;
begin
  s:=seed;
  for k:=1 to len do
    case order of
      ASCENDING : a[k].key:=k;
      DESCENDING : a[k].key:=len+1-k;
      UNORDERED : begin
                 a[k].key:=trunc(1000000*random(s));
                 s:=0;
               end
    end
end;
 
procedure print_array(var a:arraytype;len:integer);
  var k:integer;
begin
  for k:= 1 to len do
    writeln(a[k].key);
end;
 
function ordered(var a:arraytype;len:integer):boolean;
  var k:integer;
      ok:boolean;
begin
  ok:=true;
  k:=1;
  while ok and (k<len) do
    begin
      ok := a[k].key <= a[k+1].key;
      k:=k+1
    end;
  ordered:=ok
end;
 
var
  length, files, points, StartingTime, ElapsedMicroSeconds: integer;
  list: arraytype;
  order: ordertype;
  outfile: TEXT;
 
begin
  termin(input);termout(output);
  for files:= 1 to maxfiles do begin
    CASE files of
      1: REWRITE(outfile, 'name=ias.data.a');
      2: REWRITE(outfile, 'name=sas.data.a');
      3: REWRITE(outfile, 'name=bas.data.a');
      4: REWRITE(outfile, 'name=ids.data.a');
      5: REWRITE(outfile, 'name=sds.data.a');
      6: REWRITE(outfile, 'name=bds.data.a');
      7: REWRITE(outfile, 'name=ius.data.a');
      8: REWRITE(outfile, 'name=sus.data.a');
      9: REWRITE(outfile, 'name=bus.data.a')
    end;
    for points:= 1 to maxpoints do begin
      length:= LengthConstant * points;
      IF files in [1..3] then
        order:= ASCENDING
      ELSE IF files in [4..6] then
        order:= DESCENDING
      ELSE
        order:= UNORDERED;
      GenerateList(list, length, order);
      StartingTime:= Clock;
      CASE files mod 3 of
        1: InsertionSort(list, length);
        2: SelectionSort(list, length);
        0: BubbleSort(list, length)
       end;
      ElapsedMicroSeconds:= (Clock - StartingTime);
      IF ordered(list, length) then
        WRITELN (outfile, length:3, ElapsedMicroSeconds:10)
      ELSE
        WRITELN ('LIST NOT IN ORDER')
    end;
    close(outfile)
  end
end.
