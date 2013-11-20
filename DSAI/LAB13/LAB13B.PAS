Program Lab13B;  {Lab 13 B - Exam question}
{Erick Nave}
{You may view the contents of VStrType Copy to remind yourself of
 the VString operations and syntax}
 %include VStrType
 
 {Read a string from Lab13B.Data,
  write it to Lab13B.Out, in reverse order}
VAR
  Infile, Outfile: Text;
  V: Vstring;
  n: integer;
 
Begin
 Reset(Infile,'name=lab13b.data.*');
 Rewrite(Outfile,'name=lab13b.out.a');
 V:= VReadStr(Infile);
 n:=VLength(V);
 While n>0 do
  begin
   write(outfile,chat(v,n));
   n:=n-1
  end
End.
