program stats;
type
  inputtype= array [1..50] of integer;

var
  input: inputtype;
  ct,d,x,total,repeats,mostrepeat,repeatnum: integer;

procedure sort(var i:inputtype; ct:integer);
var a, temp: integer;
    swap: boolean;
begin
  repeat
    swap:= false;
    for a:= 1 to ct-1 do
      if i[a] > i[a+1] then begin
        temp:= i[a+1];
        i[a+1]:= i[a];
        i[a]:= temp;
        swap:= true;
        end;
    until not swap;
end;

begin
  ct:=0;
  repeat
    ct:= ct+1;
    read(input[ct]);
  until (input[ct]=0) or (ct=50);
  if input[ct] = 0 then ct:= ct -1;
  Sort(input, ct);
  writeln('Min: ',input[1]);
  writeln('Max: ',input[ct]);
  total:= 0;
  for x:= 1 to ct do
    total:= total + input[x];
  d:=0;
  mostrepeat:=0;
  while d < ct do begin
    d:= d + 1;
    repeats:= 0;
    while (input[d] = input[d+1]) and (d < ct) do begin
      repeats:= repeats +1;
      d:= d+1
    end;
    if mostrepeat < repeats then begin
      mostrepeat:= repeats;
      repeatnum:=input[d]
    end
  end;
  writeln('Mean: ',total/ct:1:1);
  if ct mod 2 = 0 then
    writeln('median: ',input[ct div 2]:1, input[ct div 2 +1]:3)
  else
    writeln('Median: ',input[ct div 2 +1]:1);
  if mostrepeat <> 0 then
    writeln('mode: ',repeatnum:1)
  else
    writeln('mode: ',input[1]);
end.