program initinv(input,output,binfil,txtfil);
 {initialize or display inventory file..
   reads from INITINV.DAT for initialization
   reads from INVENTRY.DAT for display
  written by Tim Margush for DSA-I, Program I, 8/30/93}
uses crt,dos;
 const
  DescriptionLength = 15;
  PartNumberLength = 7;
 type
  DescriptionType = Packed Array[1..DescriptionLength] of Char;
  PartNumberType = Packed Array[1..PartNumberLength] of Char;
  PartType = Record
              PartNumber:PartNumberType;
              Quantity:Integer;
              Price:Real;
              Description:DescriptionType
             end;

 var MainChoice:Char; {keypress for main menu}
 Procedure WaitKey;  {message and wait for keypress}
   var KP:Char;
  begin
   Writeln('Press a key... ');KP:=ReadKey;
  end;

 procedure MainMenu(var KP:Char);
 begin
  ClrScr;
  Writeln('Inventory Utility');
  Writeln(' Press ''I'' to Initialize inventory file');
  Writeln(' Press ''D'' to Display an existing inventory file');
  Writeln(' Press ''Q'' to Quit');
  Repeat
   KP:=upcase(ReadKey)
  Until KP in ['I','D','Q']
 end;

 procedure InitFile; {copy initial inventory text file to binary format}
  var binfil:file of PartType;
      txtfil:text;
      IOErr1,IOErr2:Integer;
      OnePart:PartType;
      RecCount,I:Integer;
  begin
   writeln('Opening files...');
   RecCount:=0;
   assign(txtfil,'initinv.dat');
   assign(binfil,'inventry.dat');
  {$I-} reset(txtfil);
        IOErr1:=IOResult;
        rewrite(binfil);
        IOErr2:=IOResult;
  {$I+}
   if IOErr1>0 then Writeln('Unable to access INITINV.DAT')
   else if IOErr2>0 then Writeln('Unable to create INVENTRY.DAT')
   else while not eof(txtfil) do begin
    RecCount:=RecCount+1;
    With OnePart do begin
     for i:=1 to PartNumberLength do Read(txtfil,PartNumber[i]);
     for i:=1 to DescriptionLength do Read(txtfil,Description[i]);
     readln(txtfil,quantity,price)
    end;
    write(BinFil,OnePart)
   end;
   close(binfil);close(txtfil);
   Write(RecCount,' records written... ');
   WaitKey
  end;

 procedure DisplayFile; {display records of inventory file}
  var binfil:file of PartType;
      RecCount,IOErr:Integer;
      OnePart:PartType;
  begin
   writeln('File Contents:');
   RecCount:=0;
   assign(binfil,'inventry.dat');
  {$I-}
        reset(binfil);
        IOErr:=IOResult;
  {$I+}
   if IOErr>0 then Writeln('Unable to access INITINV.DAT')
   else while not eof(binfil) do begin
    RecCount:=RecCount+1;
    if RecCount mod 20 = 0 then Writeln('Press a key... ',ReadKey);
    Read(binfil,OnePart);
    with OnePart do
     writeln(PartNumber,Quantity:10,Price:10:2,' ',Description)
   end;
   close(binfil);
   WaitKey
  end;

begin
 Repeat
  MainMenu(MainChoice);
  case MainChoice of
   'I':InitFile;
   'D':DisplayFile;
   'Q':
  end
 Until MainChoice = 'Q'
end.
