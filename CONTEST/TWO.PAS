program repeating;
var
 number:string[50];
 len, temp, t,c,t1, l, moves, x, pos, temp2:integer;
 norep, found, done: boolean;

begin
 while not eof do begin
  readln(number);
  len:= length(number);
  temp:=len;
  found:= false;
  repeat
    temp:= temp - 1
  until (number[temp] = number[len]) or (temp = 0);
  if number[temp] = number[len] then found:= true;
  if found then begin
    t:=temp;
    l:=len;
    moves:= 1;
    norep:= false;
    if len - temp = 1 then norep:= true;
    while (t > 0) and (moves <= (len-temp)) and (not norep) do begin
      t:=t-1;
      l:=l-1;
      moves:= moves+1;
      if number[t] <> number[l] then norep:=true;
    end;
    if not norep or (len-temp = 1) then begin
      write('The pattern ');
      for x:= temp to len-1 do
        write(number[x]);
      pos:=temp;
      done:= false;
      t1:=len;
       while (number[pos]= number[t1]) and (pos>0) do begin
         pos:= pos - 1;
         t1:= t1-1;
       end;
            writeln(' begins in position ',pos+1:1);
      end
   end
  else
    writeln('The string has no repeating pattern.');
 end
end.



