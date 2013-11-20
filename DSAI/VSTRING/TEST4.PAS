  program Test;
  %include vstrtype
 
  var S,T,A:VString;
      i: integer;
  begin
   reset(input,'name=test.data.a'); termout(output);
   S := VReadStr(input);
   writeln('Length of String S: ',VLength(S):1);
   Write('Contents [');VWriteStr(output,S);writeln(']');
   a:= VCreate;
   VDestroy(a); VDestroy(a);
   writeln('Length of String a: ',VLength(a):1);
   Write('Contents [');VWriteStr(output,a);writeln(']');
   Writeln ('copy');t:= copyof(a);
   Writeln(chat(a,4));
   Vconcat (S,A);
   writeln('Length of String S: ',VLength(S):1);
   Write('Contents [');VWriteStr(output,S);writeln(']');
   writeln('substr');t:=vsubStr(a,1,1);
   writeln('search');
   writeln (vsearch(s,a,1));
   writeln (vsearch (a,s,1));
   VDestroy(S);VDestroy(T);VDestroy(A)
  End.
