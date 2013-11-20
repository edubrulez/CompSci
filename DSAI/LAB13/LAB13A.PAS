Program Lab13A;
 {Erick Nave}
 {Lab 13 A - Exam question}
 type
   DataType = Real;
   NodeKind = (Header, Regular);
   FileNode = Record
               Next : Integer;
               Case NodeKind of
                Header : (Free : Integer);
                Regular: (Data : DataType);
              End;
   FileType = File of FileNode;
 
 {Display list of numbers found in the file LAB13A.DATA}
 
VAR
  InFile: FileType;
  Temp: integer;
Begin
 termout(output);
 reset(infile,'name=lab13a.data.*');
 temp:= infile@.next;
 while temp <> 0 do
  begin
   seek(infile, temp);
   get(infile);
   writeln(infile@.data:1:2);
   temp:= infile@.next
  end;
End.
