  program Test;
  %include vstrtype
 
  var S,T,A:VString;
      i: integer;
  begin
   reset(input,'name=test.data.a'); termout(output);
   S := VReadStr(input);
   t:= VStr('z');
   Writeln (VSearch(S,T,1));
   Writeln (vSearch(s,t,0));
   Writeln (VSearch(s,t,40));
   a:=VSubstr(s,0,3);
   vdestroy(A);
   a:= Vsubstr (s,40,1);
   vdestroy(A);
   a:= Vsubstr(s,1,-1);
   writeln (chat(s,0));
   writeln (chat(s,40));
   VDestroy(T); vdestroy(a);vdestroy(s);
  End.
