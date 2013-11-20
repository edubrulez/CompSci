program lab6b;
{insert your name here}
 
{This program computes values of a function Z. Input comes from a
 data file, LAB6B DATA.}
 
function Z(m,n:integer) : Integer;
begin
  if (m<0) or (n<0) or (n>m) then
    Z := 0   {stub dummy return value}
  else if (n= 0) or (n=m) then
    Z:= 1
  else
    Z:= Z(m-1,n) + Z(m-1, n-1)
end;
 
var x,y:integer;
 
Begin
 Reset(input, 'Name=Lab6b.data.*');
 Termout(Output);
 While not eof do begin
   Readln(x, y);
   Writeln(x:5, y:5, z(x,y):10)
 end;
 writeln('End of file encountered normally.')
end.
