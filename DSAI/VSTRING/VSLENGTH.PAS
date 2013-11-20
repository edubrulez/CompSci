segment vslength;
{Erick Nave}
%include vstr2
 
function VLength;
 var i: integer;
 begin
  i:=s;
  IF (i > 0) and (i < avail) then
    BEGIN
      WHILE (i < avail) and (heap[i] <> chr(0)) do
        i:= i+1;
      IF (i = avail) then
        BEGIN
          VLength:=0;
          WRITELN ('Null character is out of bounds.')
        END
      ELSE
        VLength := i - s
    END
  ELSE
    BEGIN
      VLength:= 0;
      WRITELN('String is outside of bounds')
    END
 end;
