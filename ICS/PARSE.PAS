PROGRAM PARSE (input, output);
uses crt;

VAR
   Num1, Denom1, Num2, Denom2: INTEGER;
   Slash1, Slash2, Operation, s: CHAR;

BEGIN
     clrscr;
     WRITELN ('Enter a problem in fractional form using these symbols:');
     WRITELN ('     + (Add), - (Subtract), * (Multiply), and / (Divide).');
     WRITELN ('Also, use the / to separate numerator and denominator.');
     WRITELN ('Use this format: #_/#_ <operation>#_/#');
     READLN (Num1, s, Slash1, Denom1, s, Operation, Num2, s, Slash2,
             Denom2);
     WRITELN (Num1:1, Slash1, Denom1:1, Operation, Num2:1, Slash2, Denom2:1);
END.