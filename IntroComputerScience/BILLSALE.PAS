PROGRAM BillOfSale (input, output);

{Erick Nave
 2-3-93 ICS 9:00
 program #14, page 83
 BillOfSale (billsale.pas) is to retreive input from a "customer" in order to
    fill out a bill of sale of computer items to be purchased. Output is
    designed to give a listing of the items, the price, and the total amount
    of money spent.}

{The constant section gives the cost of 1 of each item.}
CONST
     NWPC = 675.0;
     MemExpCard = 69.95;
     DiskDrive = 198.5;
     Software = 34.98;
     Space = ' ';

{The variables are for input and calculations of purchase price}
VAR
   NWPCnum, MemExpCardnum, DiskDrivenum, Softwarenum: INTEGER;
   NWPCcost, MemExpCardcost, DiskDrivecost, Softwarecost, Totalcost: REAL;

BEGIN
{This part is for customer input}
     WRITELN;
     WRITE ('Please enter the number of NW-PCs that you want: ');
     READLN (NWPCnum);
     WRITE ('Number of memory expansion cards               : ');
     READLN (MemExpCardnum);
     WRITE ('Number of disk drives                          : ');
     READLN (DiskDrivenum);
     WRITE ('And the number of Software packages            : ');
     READLN (Softwarenum);

{This part is for price computations}
     NWPCcost:= NWPC * NWPCnum;
     MemExpCardcost:= MemExpCard * MemExpCardnum;
     DiskDrivecost:= DiskDrive * DiskDrivenum;
     Softwarecost:= Software * Softwarenum;
     Totalcost:= NWPCcost + MemExpCardcost + DiskDrivecost + Softwarecost;

{This is the output}
     WRITELN;
     WRITELN ('*************************************');
     WRITELN (Space:10,'New Wave Computers');
     WRITELN; WRITELN;
     WRITELN (Space:4,'ITEM',Space:21,'COST');
     WRITELN (NWPCnum:1,'   NW-PC','$':17,NWPCcost:8:2);
     WRITELN (MemExpCardnum:1,'   Memory card',Space:11,MemExpCardcost:8:2);
     WRITELN (DiskDrivenum:1,'   Disk Drive',Space:12,DiskDrivecost:8:2);
     WRITELN (Softwarenum:1,'   Software',Space:14,Softwarecost:8:2);
     WRITELN ('---------':35);
     WRITELN ('TOTAL':15,Space:8,'$',Totalcost:10:2);
     WRITELN
END.




