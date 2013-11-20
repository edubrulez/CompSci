program Tree;
   uses
     turtle,   { imports necessary turtle graphics procedures }
     crt;

   const
    initiallength = 260;
    initialspread = 150;
   var
    delayfactor,              {milliseconds delay between edges}
    children,height:integer;

  procedure grow(children,height,length,spread,delayfactor:integer);
    var a,i:integer;
   begin
    if keypressed then halt; {in case you want to quit early}
    pendown;
    forwd(length);
    delay(delayfactor);
    penup;
    if height>1 then begin
      a:=spread div (children-1);    {angle between branches}
      turnleft(spread div 2);
      for i:= 1 to children do begin
       grow(children,height-1,length div 2,trunc(spread*0.8),delayfactor);
       turnright(a)
      end;
      turnleft(children*a-spread div 2)
    end;
    back(length); {back to starting point}
   end;


begin
     write('Enter the number of children at first level: ');
     read(children);
     write('Enter the number of levels: ');
     read(height);
     write('Enter the Delay Factor (milliseconds): ');
     readln(DelayFactor);
     TurtleGraphics;              {  initialize turtle and graphics }
     setposition(0, 300);setheading(180); {  sets starting position }
     penup;
     grow(children, height, initiallength, initialspread, delayfactor);
     repeat until KeyPressed   { to freeze screen until a key is pressed }
end.
 
