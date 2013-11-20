unit Turtle;

interface
        uses graph;

   {IMPORTANT -- The constant PATH must reflect your current file
                 and directory configuration.  Your instructor 
                 will provide details.                           }
        const
          PATH = 'c:\TP\BGI';  { set to local path for graphic drivers }


        procedure TurtleGraphics;
        procedure back (dist: integer);
        procedure clear;
        procedure forwd (dist: integer);
        function heading: integer;
        procedure home;
        function OnScreen:boolean;
        procedure PenDown;
        procedure PenUp;
        procedure SetHeading (Angle: integer);     { angle in degrees  }
        procedure SetPosition (xpos, ypos: integer);
        procedure TurnLeft (Angle: integer);    {  angle in degrees  }
        procedure TurnRight (Angle: integer);  {  angle in degrees  }
        function Xcor: integer;
        function Ycor: integer;

implementation
        var
           home_x, home_y:integer;
           x, y: real;      {  Horiz, Vert coordinates of the Turtle  }
           Direction: integer;   {  Current direction of the Turtle  }
           IsPenUp: boolean;
           radian: real;

 function OnScreen:Boolean;
        begin
                OnScreen := (x>=0) and (Y>=0) 
                            and (X<=GetMaxX) and (Y<=GetMaxY)
        end; 

 procedure TurtleGraphics;
        var
           graphdriver, graphmode : integer;
        begin
                { initialize for graphic mode }
                GraphDriver := Detect;
                InitGraph(GraphDriver,GraphMode,PATH);
                home_x := GetMaxX div 2;
                home_y := GetMaxY div 2;
                x := home_x;
                y := home_y;
                radian := pi/180;
                Direction := 0;   {  Current direction of the Turtle  }
                IsPenUp := false;
        end;

        procedure clear;
        begin
          SetFillStyle(EmptyFill, black);
          Bar(0,0, GetMaxX, GetMaxY);
        end;

        procedure forwd (dist: integer);
                var
                        theta: real;
        begin
                MoveTo(round(x), round(y));
                theta := (90 - Direction) * RADIAN;
                x := x + (dist * cos(theta));
                y := y - (dist * sin(theta));
                if IsPenUp then
                        moveto(round(x), round(y))
                else
                        lineto(round(x), round(y));
        end;

        procedure back (dist: integer);
                var
                        theta: real;
        begin
                MoveTo(round(x), round(y));
                theta := (90 - Direction) * RADIAN;
                x := x - (dist * cos(theta));
                y := y + (dist * sin(theta));

                if IsPenUp then
                        moveto(round(x), round(y))
                else
                        lineto(round(x), round(y));
        end;

        function heading: integer;
        begin
                heading := Direction;
        end;

        procedure home;
        begin
                x := home_x;
                y := home_y;
                moveto(round(x), round(y));
        end;

        procedure PenDown;
        begin
                IsPenUp := false;
        end;

        procedure PenUp;
        begin
                IsPenUp := true;
        end;

        procedure SetHeading (Angle: integer);     { angle in degrees  }
        begin
                Direction := Angle;
        end;

        procedure SetPosition (xpos, ypos: integer);
        begin
                x := xpos + home_x;
                y := -ypos+ home_y;
                moveto(round(x), round(y));
        end;

        procedure TurnLeft (Angle: integer);    {  angle in degrees  }
        begin
                Direction := (Direction - Angle) mod 360;
        end;

        procedure TurnRight (Angle: integer);  {  angle in degrees  }
        begin
                Direction := (Direction + Angle) mod 360;
        end;

        function Xcor: integer;
        begin
                xcor := round(x-home_x);
        end;

        function Ycor: integer;
        begin
                ycor := -round(y-home_y);
        end;

 end.
