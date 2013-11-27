PROGRAM PaintWithFunctions (input, output);
uses crt;

{Erick Nave
 2-26-93 ICS 9:00
 Program PaintWithFunctions (paintfnt.pas) is designed to let the customer
    enter the dimensions of a room to be painted, along with the # of doors
    and windows.  The program then computes and prints out the surface area
    of the room, the amount of paint needed to cover the room, and the total
    cost of the paint.}

CONST
     DoorArea = 22;     {Standard area deduction for a door}
     WindowArea = 11;   {Standard area deduction for a window}

VAR
   TotalArea, PricePerGallon, CoveragePerGallon: REAL;
   TotalGallons: INTEGER;
   {These variables are needed to receive values from reference parameters
          and functions}

FUNCTION GetOneSize: Real;
 {GetOneSize takes feet and inches input values (integers) and converts them
       into a Real value for feet}
   VAR InFeet, InInches: Integer;
 BEGIN
      READLN (InFeet, InInches);
      GetOneSize:= InFeet + InInches/12.0
 END; {GetOneSize}

PROCEDURE GetSizes (var RL, RW, RH: REAL);
 {GetSizes asks for user input obtained from function GetOneSize.  The
       parameters are initials for RoomLength(RL), RoomWidth(RW), and
       RoomHeight(RH), the room's dimensions, to insure consistency}
 BEGIN
      WRITELN;
      WRITE ('Enter room length in feet and inches   : '); RL:= GetOneSize;
      WRITE ('Enter room width in feet and inches    : '); RW:= GetOneSize;
      WRITE ('Enter room height in feet and inches   : '); RH:= GetOneSize
 END; {GetSizes}

PROCEDURE GetOpenings (var D, W: INTEGER);
 {GetOpenings asks for the number of doors (D) and windows (W) for later
        deductions in surface area}
 BEGIN
      WRITELN;
      WRITE ('Enter the number of doors and windows, (doors windows): ');
      READLN (D,W)
 END; {GetOpenings}

FUNCTION RoomArea: REAL;
 {RoomArea calls on GetSizes to supply information to gain a total surface
       area for the room}
 VAR RL, RW, RH: REAL;
     {Room Length (RL), Room Width (RW), and Room Height (RH) are 3 value
           needed to compute surface area. These varibles are needed for the
           procedure call GetSizes (RL, RW, RH).}
 BEGIN
      GetSizes(RL, RW, RH); {for values of dimensions}
      RoomArea:= (RL * RW) + 2*(RL * RH) + 2*(RW * RH)
          {Combined area of ceiling and 4 walls}
 END; {RoomArea}

FUNCTION OpeningsArea: REAL;
 {OpeningsArea calls on GetOpenings to supply information on the # of doors
       and windows in order to figure the area deduction of RoomArea}
 VAR Doors, Windows: Integer;
     {Doors and Windows are variables needed to receive the values of the
            reference parameters in GetOpenings.  They are then used to
            figure the area deduction of RoomArea}
 BEGIN
      GetOpenings(Doors, Windows);
      OpeningsArea:= (Doors * DoorArea) + (Windows * WindowArea)
           {equation for amount of deduction}
 END; {OpeningsArea}

PROCEDURE GetPaintDetails(var PPG, CPG: REAL);
 {GetPaintDetails asks for the price per gallon (PPG) of paint and for the
      coverage per gallon (CPG) of a gallon of paint to be purchased.These
      values will be sent to the variables PricePerGallon and
      CoveragePerGallon in the procedure call.}
 BEGIN
      WRITELN;
      WRITE ('What is the price per gallon of paint  :$'); READLN (PPG);
      WRITE ('How much area does that gallon cover   : '); READLN (CPG)
 END; {GetPaintDetails}

FUNCTION PaintNeeded (TA, CPG: REAL): INTEGER;
 {PaintNeeded brings in the values of TotalArea into TA and
      CoveragePerGallon into CPG for figuring the amount of paint needed.}
 BEGIN
      PaintNeeded:= ROUND(TA / CPG + 0.499999999)
        {Equation for figuring paint needed.  Also the 0.499999999 is added
            to make sure there is ample paint when the value is rounded. A
            # plus 1E-9, or less, should be coverable}
 END;{PaintNeeded}

FUNCTION TotalCost (TG: INTEGER; PPG: REAL): REAL;
 {TotalCost brings in the values of TotalGallon into TG and PricePerGallon
       into PPG in order to determine the amount of the bill.}
 BEGIN
      TotalCost:= TG * PPG {Gallons * Price = Cost}
 END; {TotalCost}

PROCEDURE PrintResults (TG: INTEGER; TA, TC: REAL);
 {PrintResults is the output of the computations made earlier.  It displays
     TotalGallons (TG), TotalArea(TA), and TotalCost(TC).}
 BEGIN
      WRITELN;
      WRITELN ('The total area to be painted is ',TA:1:1,' square feet.');
      WRITELN ('You need ',TG:1,' gallons of paint to cover the room at');
      WRITELN ('   the price of $',TC:1:2,'.');
 END; {PrintResults}

BEGIN {main body}
      clrscr;
      WRITELN ('Leave a space between items of input, please.');
      WRITELN ('If an answer is zero, enter 0');
      TotalArea:= RoomArea - OpeningsArea;
      GetPaintDetails (PricePerGallon, CoveragePerGallon);
      TotalGallons:= PaintNeeded(TotalArea, CoveragePerGallon);
      PrintResults(TotalGallons, TotalArea, TotalCost(TotalGallons,
           PricePerGallon))
END. {program PaintWithFunctions}



