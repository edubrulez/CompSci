PROGRAM Paint (input, output);
uses crt;

{Erick Nave
 2-16-93 ICS 9:00
 Program paint (paint.pas) computes the surface area of a room, how much
    paint is needed to cover that area, and the total cost of the paint}

CONST
     DoorArea = 22;
     WindowArea= 11;

VAR
   RoomLength, RoomHeight, RoomWidth, RoomArea, PricePerGallon,
      CoveragePerGallon, TotalCost: REAL;
   Windows, Doors, GallonsNeeded: INTEGER;

PROCEDURE GetOneSize (var Feet: REAL);
    VAR InFeet, InInches: INTEGER; {user input}
  BEGIN
       READLN(InFeet, InInches);
       Feet:= InFeet + InInches/12
  END; {GetOneSize}

PROCEDURE GetSizes (var RL, RW, RH: REAL);
BEGIN {ask user for the dimensions of the room}
      WRITELN ('Leave a space between items of input, please.');
      WRITELN ('If answer is zero, enter 0.');
      WRITELN;
      WRITE ('Enter room length in feet and inches   : '); GetOneSize(RL);
      WRITE ('Enter room width in feet and inches    : '); GetOneSize(RW);
      WRITE ('Enter room height in feet and inches   : '); GetOneSize(RH)
END; {GetSizes}

PROCEDURE GetOpenings (var D, W:INTEGER);
BEGIN {Ask user for the # of doors and windows in the room}
      WRITELN;
      WRITE('Enter the number of doors and windows, (doors windows): ');
      READLN(D, W)
END; {GetOpenings}

PROCEDURE ComputeArea (RL, RW, RH:REAL; var RoomArea: REAL);
BEGIN {Compute combined area of 4 walls and ceiling}
      RoomArea:= (RL * RW) + 2*(RL * RH) + 2*(RW * RH)
END; {ComputeArea}

PROCEDURE DeductOpenings (Doors, Windows:INTEGER; var RoomArea: REAL);
BEGIN {Deduct standard amounts for each door and window}
      RoomArea:= RoomArea - (Doors * DoorArea + Windows * WindowArea)
END; {DeductOpenings}

PROCEDURE GetPaintDetails(var PPG, CPG: REAL);
BEGIN {ask user for price per gallon and how much area is covered by a gallon}
      WRITELN;
      WRITE ('What is the price per gallon of paint :$');
      READLN(PPG);
      WRITE ('How much area does that gallon cover  : ');
      READLN(CPG)
END; {GetPaintDetails}

PROCEDURE ComputeNeedsAndCost (RA, CPG, PPG: REAL; var GN:INTEGER;
           var TC: REAL);
BEGIN {compute # of gallons needed and total cost of paint}
      GN:= round(RA / CPG + 0.499999999);
 {gal. needed = room area / coverage per gallon.  Also any area with a # plus
    1E-9 or less should be coverable.  So, round (..... + 0.499999999) can
    bump the gallons needed to the next integer to ensure coverage}
      TC:= GN * PPG {total cost = gal. needed * price per gallon}
END; {ComputeNeedsAndCost}

PROCEDURE PrintResults (GallonsNeeded: INTEGER; RoomArea, TotalCost: REAL);
BEGIN {Display the results}
      WRITELN;
      WRITELN ('The total area to be painted is ',RoomArea:1:1,' square feet.');
      WRITELN ('You need ',GallonsNeeded:1,' gallons to cover the room at');
      WRITELN ('    the price of $',TotalCost:1:2,'.')
END; {PrintResults}

BEGIN {main body}
      clrscr;
      GetSizes(RoomLength, RoomWidth, RoomHeight);
      GetOpenings(Doors, Windows);
      ComputeArea(RoomLength, RoomWidth, RoomHeight, RoomArea);
      DeductOpenings(Doors, Windows, RoomArea);
      GetPaintDetails(PricePerGallon, CoveragePerGallon);
      ComputeNeedsAndCost(RoomArea, CoveragePerGallon, PricePerGallon,
              GallonsNeeded, TotalCost);
      PrintResults(GallonsNeeded, RoomArea, TotalCost)
END. {program Paint}



