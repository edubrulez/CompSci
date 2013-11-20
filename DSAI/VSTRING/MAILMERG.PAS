program mailmerg;
{Written by Tim Margush - Mail Merge program for DSA-I Fall 1993
 Reads data strings from mailmerg data and substitutes in substitution
  fields found in mailmerg form. Letters are written to mailmerg
  letters. The letter file contains carriage control characters.
  This application uses the VString segment.}
 
%include vstrtype;
 const letterfilename = 'name=mailmerg.letters.a lrecl=30000 recfm=v';
       datafilename = 'name=mailmerg.data.*';
       formfilename = 'name=mailmerge.form.*';
       MaxSubs = 50; {maximum number of substitution fields}
 
 type SListType = Array[1..MaxSubs] of VString; {data to be substituted}
 
function VNum(var S:Vstring):Integer;
  var i,d,n : integer;
 begin
  N := 0;
  for i:=1 to vlength(S) do begin
   D := ord(Chat(S,i)) - ord('0');
   if D in [0..9] then N := N * 10 + D;
  end;
  VNum := N
 end;
 
Procedure Substitute(var Paragraph:VString;
                     var SS:SListType; NF:Integer);
   var left,right,submarker,subending,subnumber:vstring;
       sf,substart,subend:integer;
 Begin
  SubMarker := VStr('<');
  SubEnding := VStr('>');
  SubStart := VSearch(Paragraph,SubMarker,1);
  While SubStart>0 do begin
   if CHat(Paragraph,SubStart+1)='<' then begin {remove duplicate <}
     left:=VSubstr(Paragraph,1,SubStart-1);
     right:=VSubstr(Paragraph,SubStart+1,vlength(Paragraph));
     VDestroy(Paragraph);     vconcat(left,right);
     Paragraph:=CopyOf(left); VDestroy(right);VDestroy(Left);
     SubStart:=SubStart+1;
   end else begin {look for end of field}
     SubEnd := VSearch(Paragraph,SubEnding,SubStart);
     If Subend=0 then begin
        Writeln('error - unclosed substitution field:');
        SubStart:=SubStart+1
     end else begin {perform substitution}
        SubNumber := VSubstr(Paragraph,SubStart+1,Subend-SubStart-1);
        left:=vsubstr(Paragraph,1,SubStart-1);
        right:=vsubstr(Paragraph,Subend+1,vlength(Paragraph));
        SF := VNum(SubNumber);
        if (sf>0) and (sf<=NF) then VConcat(left,SS[sf]);
        VConcat(left,right);  VDestroy(Paragraph);
        Paragraph:=CopyOf(left); VDestroy(left);VDestroy(right)
     end
   end;
   SubStart := VSearch(Paragraph,SubMarker,SubStart);
  end;
  VDestroy(SubMarker); VDestroy(SubEnding)
 end;
 
Procedure WriteLetter(var Lf:text; var SS:SlistType; NF:Integer);
  var formfile:text;
      Temp,Paragraph, CCCS : VString;
 Begin
   Reset(formfile,formfilename);
   CCCS := VStr('1'); {form feed carriage control character}
   While not eof(formfile) do begin
      Paragraph:=VReadStr(formfile);
      Substitute(Paragraph,SS,NF);
      VConcat(CCCS,Paragraph);
      VWriteStr(LF,CCCS);
      VDestroy(Paragraph);
      VDestroy(CCCS);
      CCCS := VStr(' ');  {single spacing from here on}
      Readln(formfile); Writeln(LF)
   End;
   VDestroy(CCCS);
 End;
 
Procedure ReadSubs(var DF:text; var SS:SListType; var NF:Integer);
  var EndofRec, NextString : VString;
 Begin
  EndofRec := VStr('*');
  NF := 0;
  NextString := VReadStr(DF);
  Readln(DF);
  While not VEqual(NextString, EndOfRec) do begin
   NF := NF + 1;
   SS[NF] := NextString;
   NextString := VReadStr(DF);
   Readln(DF)
  end;
  VDestroy(EndOfRec)
End;
 
{main program variables}
 var
     letterfile,datafile:text;
     NumFields:integer;
     SubStrings:SListType;
begin
 termin(input);termout(output);
 reset(datafile,datafilename);
 rewrite(letterfile,letterfilename);
 While not eof(datafile) do begin
   ReadSubs(datafile,SubStrings,NumFields);
   WriteLetter(letterfile,SubStrings,NumFields);
   While NumFields>0 do begin
      Vdestroy(SubStrings[NumFields]);
      NumFields:=NumFields-1
   End
 End;
end.
