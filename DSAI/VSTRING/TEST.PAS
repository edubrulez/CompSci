  program Test;
  %include vstrtype
 
  var S,T,A:VString;
      i: integer;
  begin
   reset(input,'name=test.data.a'); termout(output);
   S := VReadStr(input);
   readln(input);
   writeln('Length of String S: ',VLength(S):1);
   Write('Contents [');VWriteStr(output,S);writeln(']');
   T := CopyOf(S); VDestroy(S);
   writeln('Length of String T: ',VLength(T):1);
   write('Contents of T [');
   for i:=1 to VLength(T) do write(CHat(T,i)); writeln(']');
   S := vSubStr(T,2,VLength(T)-1);
   writeln('Length of String: ',VLength(S):1);
   write('S = [');VWriteStr(output,S);writeln(']');
   vconcat(t,s);
   writeln('Length of Concat: ',VLength(T):1);
   Write('concat t,s = [');vwritestr(output,t);writeln(']');
   writeln('Length of String s: ',VLength(s):1);
   write('Contents of s ['); vwritestr(output, s); writeln(']');
   writeln('search for s in t :',VSearch(t,s,1):1);
   writeln ('vequal');
   writeln('t,t :',vequal(t,t));
   writeln('s,s :',Vequal(s,s));
   writeln('s,t :',vequal(s,t));
   writeln('t,s :',vequal(t,s));
   writeln('vlessthan');
   WRiteln('t,t :',vlessthan(t,t));
   writeln('s,s :',vlessthan(s,s));
   writeln('s,t :',vlessthan(s,t));
   writeln('t,s :',vlessthan(t,s));
   A:= VReadStr(input); readln(input);
   WRITELN ('Length of A: ',VLength(A):1);
   Write ('Contents of A ['); VWriteStr(output,A); Writeln(']');
   Writeln (VSearch(T,A,23));
   Writeln (VSearch(S,A,1));
   VConcat(s,a);
   Writeln (s.first@.strsegment);
   Writeln(s.first@.next@.strsegment);
   Writeln('Length of S: ',Vlength(s));
   Write('Contents of S [');VWriteStr(output,S); Writeln(']');
   Writeln (VSearch(S,A,21));
   VDestroy(S);VDestroy(T)
  End.
