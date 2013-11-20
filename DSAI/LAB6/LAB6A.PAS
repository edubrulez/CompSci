program lab6a;
{insert your name here}
 
{This program is to read data from a text file and
 write it to a binary file.  When end of file is encountered,
 the number of records is displayed on the screen.}
 
{The file to be read from is called LAB6A DATA. The binary file
 is to be called LAB6A BINARY A. It is to be a file of
 datatype records. You do not need to check if the input file exists.}
 
type
 DataType = Record
             X, Y : Integer;
             Size : Real
            End;
 
var
  infile: TEXT;
  outfile: file of datatype;
  temp: datatype;
Begin
  reset (infile, 'name = LAB6A.DATA.D');
  rewrite(outfile, 'name= lab6a.binary.a');
  while not eof (infile) do begin
    readln(infile, temp.x, temp.y, temp.size);
    write(outfile, temp)
   end
end.
