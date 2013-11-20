program drops;
var
 x1,x2,y1,y2,rad: longint;
 distance: real;

begin
 while not eof do begin
  readln(x1,y1,rad,x2,y2);
  distance:= sqrt(sqr(x1-x2) + sqr(y1-y2));
  if distance < rad then begin
    writeln('The drip at (',x2:1,',',y2:1,') is inside the bucket of radius');
    writeln(rad:1,' centered at (',x1:1,',',y1:1,')')
  end
  else if distance = rad then begin
    writeln('The drip at (',x2:1,',',y2:1,') is on the rim of the bucket of');
    writeln('radius ',rad:1,' centered at (',x1:1,',',y1:1,')')
  end
  else begin
    writeln('The drip at (',x2:1,',',y2:1,') is outside of the bucket of');
    writeln('radius ',rad:1,' centered at (',x1:1,',',y1:1,')')
  end
 end
end.
