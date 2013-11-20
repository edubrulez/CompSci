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
   writeln('Length of String a: ',VLength(a):1);
   Write('Contents [');VWriteStr(output,a);writeln(']');
   VConcat(s,a);
   writeln('Length of String S: ',VLength(s):1);
   Write('Contents [');VWriteStr(output,s);writeln(']');
   VConcat(a,s);
   writeln('Length of String a: ',VLength(a):1);
   Write('Contents [');VWriteStr(output,a);writeln(']');
   VDestroy(a);
   writeln('Length of String a: ',VLength(a):1);
   Write('Contents [');VWriteStr(output,a);writeln(']');
   a:= Vsubstr(s,10,10);
   writeln('Length of String a: ',VLength(a):1);
   Write('Contents [');VWriteStr(output,a);writeln(']');
   t:= VStr(chat(s,21));
   writeln('length of string t: ',VLength(t):1);
   Write('contents[');VwriteStr(output,t);Writeln(']');
   VInsert(s,a,18);
   writeln('Length of String S: ',VLength(S):1);
   Write('Contents [');VWriteStr(output,S);writeln(']');
   VDelete(s,18,25);
   writeln('Length of String S: ',VLength(S):1);
   Write('Contents [');VWriteStr(output,S);writeln(']');
   VDestroy(S);VDestroy(T);VDestroy(A)
  End.
