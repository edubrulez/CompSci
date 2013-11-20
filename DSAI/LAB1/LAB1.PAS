Program Lab1;
{Data Structures & Algorithms I - Lab 1
 Written by Tim Margush
 
 This program copies data from a sequential text file into
 a file of records.
 }
 
 type
  SexType = (male, female, undetermined);
  RecordType = Record
                Age:     Integer;
                Code:    Char;
                Size:    Real;
                Initial: Char;
                Sex:     SexType;
                Active:  Boolean;
                RNum:    String[2];
               End;
 var
  FileOut : File of RecordType;
  OneRec  : RecordType;
  Garbage, BooleanCharacter, SexCharacter : Char;
 
 Begin
  Assign(input,'Lab1.dat');
  Reset(input);
  Assign(fileout,'Lab1.bin');
  Rewrite(fileout);
  While not eof do begin
   With OneRec do begin
    Readln(Code,SexCharacter,Initial,
           BooleanCharacter,Age,Size,Garbage,RNum);
    Writeln(Code,SexCharacter,Initial,BooleanCharacter,
            Age:6,Size:6:1,Rnum);
    {convert to sextype}
    if SexCharacter = 'M' then Sex := male
     else if SexCharacter = 'F' then Sex := female
     else Sex := undetermined;
    {convert T-true anything else-false}
    Active := BooleanCharacter='T';
   End; {with onerec}
   Write(fileout,OneRec)
  End;
  Close(fileout);
 End.
