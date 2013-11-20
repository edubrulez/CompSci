  program Test;
  %include vstrtype
 
  var S,T,A:VString;
      i: integer;
  begin
   reset(input,'name=test.data.a'); termout(output);
   S := VReadStr(input);
   writeln('Length of String S: ',VLength(S):1);
   Write('Contents [');VWriteStr(output,S);writeln(']');
   T := CopyOf(S); VDestroy(S);
   writeln('Length of String T: ',VLength(T):1);
   write('Contents of T [');
   for i:=1 to VLength(T) do write(CHat(T,i)); writeln(']');
   a:= vsubstr(t, 21, 1);
   write('[');vwritestr(output, a); writeln(']');
   VDestroy(T); vdestroy(a);
  End.
