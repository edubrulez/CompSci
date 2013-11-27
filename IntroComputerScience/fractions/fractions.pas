PROGRAM FractionMath (input, output);
uses crt;

{Erick Nave
 9:00 ICS 3-9-93
 pg 124, prob. 28
 FractionMath (Fraction.pas) asks the user to input an equation involving
    fractions. The equation is then reduced.Then, through a course of decision
    statements, the proper answer is calculated according to the operation the
    user entered.  The equation with the rounded input and the unrounded
    output are then displayed. The program then prints the original problem
    and rounded answer in horizontal form.}

VAR
   Num1, Denom1, Num2, Denom2, AnsNum, AnsDenom: INTEGER;
      {Num (numerator) and Denom (denominator) 1&2 are input values for the
           problem. AnsNum (answer of numerator) and AnsDenom (answer of
           denominator) receive values from any of the procedures used to
           carry out the operations and will be used to display the answer.}
   Slash1, Slash2, Operation, s: CHAR;
      {Slash1 & 2 pick up / in fraction.  Operation picks up the +,-,*,/.
          s is a dummy variable for no purpose other than to pick up the
          spaces needed to avoid invalid numeric format error.}

PROCEDURE Add (N1, D1, N2, D2: INTEGER; var AN, AD: INTEGER);
  {ADD adds the fractions given by the user if a + is given in the problem.
       N1 & 2 and D1 & 2 are abbreviations of Num1 & 2 and Denom1 & 2 which
       contain the values to be passed into the paramaters.  AN and AD stand
       for AnsNum and AnsDem, the two variables receiving the answers.}
  BEGIN
       AN:= (N1 * D2) + (N2 * D1);
       AD:= D1 * D2
  END; {ADD}

PROCEDURE Subtract (N1, D1, N2, D2: INTEGER; VAR AN, AD: INTEGER);
  {Subtract subtracts the fraction given by the user if a - is given in the
     problem.N1 & 2 and D1 & 2 are abbreviations of Num1 & 2 and Denom1 & 2
     which contain the values to be passed into the paramaters.  AN and AD
     stand for AnsNum and AnsDem, the two variables receiving the answers.}
  BEGIN
       AN:= (N1 * D2) - (N2 * D1);
       AD:= D1 * D2
  END; {Subtract}

PROCEDURE Multiply (N1, D1, N2, D2: INTEGER; VAR AN, AD: INTEGER);
   {Multiply multiplies the fraction given by the user if a * is given in
      the problem. N1 & 2 and D1 & 2 are abbreviations of Num1 & 2 and Denom1
      & 2 which contain the values to be passed into the paramaters.  AN and
      AD stand for AnsNum and AnsDem, the two variables receiving the
      answers.}
   BEGIN
        AN:= (N1 * N2);
        AD:= (D1 * D2)
   END; {Multiply}

PROCEDURE Divide (N1, D1, N2, D2: INTEGER; VAR AN, AD: INTEGER);
  {Divide divides the fractions given by the user if a / is given in the
     problem.  N1 & 2 and D1 & 2 are abbreviations of Num1 & 2 and Denom1 & 2
     which contain the values to be passed into the paramaters.  AN and AD
     stand for AnsNum and AnsDem, the two variables receiving the answers.}
  BEGIN
       AN:= (N1 * D2);
       AD:= (D1 * N2)
  END; {Divide}

FUNCTION Greatest (N, D: INTEGER): INTEGER;
  {Greatest finds the greatest common divisor of the Numerator (N, which
     receives its value from Num in Reduce) and the Denominator (D, which
     receives its value from Denom in Reduce).  It will be sent back to
     Reduce in order to reduce the fraction to lowest terms.}
  BEGIN
       N:= ABS(N);
       D:= ABS(D);
       IF N < D THEN
          Greatest:= Greatest(D, N)
       ELSE
           IF (N mod D = 0) then
              Greatest:= D
           ELSE
               Greatest:= Greatest(D, N mod D);
  END; {Greatest}

PROCEDURE Reduce (var Num, Denom: INTEGER);
  {Reduce reduces the fraction to lowest terms with the help of the function
     greatest.  It also fixes negative signs to make the fraction look
     presentable.  Num receives either Num1, Num2, or AnsNum and Denom
     receives either Denom1, Denom2, or AnsDenom.}
  VAR GCD: INTEGER; {GCD is short for greatest common divisor, which will be
                         found in the function Greatest and will be used to
                         reduce the fraction.}
  BEGIN
       GCD:= Greatest(Num, Denom);
       Num:= Num div GCD;
       Denom:= Denom div GCD;
       IF (Num < 0) and (Denom < 0) THEN
          BEGIN
               Num:= ABS(Num);
               Denom:= ABS(Denom)
          END
       ELSE
           IF (Num < 0) or (Denom < 0) THEN
              BEGIN
                   Num:= -1 * ABS(Num);
                   Denom:= ABS(Denom)
              END
  END; {Reduce}


BEGIN  {main body}
     clrscr;
  {Instructions for entering fraction problem}
     WRITELN ('Enter a problem in fractional form using these symbols:');
     WRITELN ('     + (Add), - (Subtract), * (Multiply), and, / (Divide).');
     WRITELN ('Also, use the / to separate numerator and denominator.');
     WRITELN ('Type in input like this:  #_/#_<operation>#_/#');
     WRITELN ('     ( _ indicates space)');
     WRITELN;
  {Input of problem}
     READLN (Num1, s, Slash1, Denom1, s, Operation, Num2, s, Slash2,
             Denom2);
  {Is one of the fraction undefined?}
     IF (Denom1 <> 0) AND (Denom2 <> 0) THEN
        IF (Operation = '+') OR (Operation = '-') OR (Operation = '*') OR
             (Operation = '/') THEN
           BEGIN
              IF Num1 <> 0 then  
                 Reduce(Num1, Denom1);
              IF Num2 <> 0 then
                 Reduce(Num2, Denom2);
            {if Num1, Num2 or AnsNum = 0 then get a division by 0 error in the
                function Greatest}
              CASE Operation OF
                  '+': Add(Num1, Denom1, Num2, Denom2, AnsNum, AnsDenom);
                  '-': Subtract(Num1, Denom1, Num2, Denom2, AnsNum, AnsDenom);
                  '*': Multiply(Num1, Denom1, Num2, Denom2, AnsNum, AnsDenom);
                  '/': Divide(Num1, Denom1, Num2, Denom2, AnsNum, AnsDenom)
              END; {CASE Operation OF}
              WRITELN;
              WRITELN (Num1:1, Slash1, Denom1:1, Operation:2, Num2:2, Slash2,
                   Denom2:1,' = ', AnsNum:1,'/', AnsDenom:1);
              WRITELN;
              IF (AnsNum <>0) then
                  Reduce (AnsNum, AnsDenom);
              WRITELN(Num1:5,' ':4, Num2:5, ' ':4, AnsNum:5);
              WRITELN('------', Operation:2,' ------', ' =',' ------');
              WRITELN(Denom1:5, ' ':4, Denom2:5, ' ':4, AnsDenom:5)
           END {THEN part of nested loop}
        ELSE
            WRITELN('Invalid character for operation')
        {IF-THEN-ELSE for operation character error trap ends here.}
     ELSE
         BEGIN
              WRITELN ('Problem undefined. One of your fractions has a 0');
              WRITELN ('    in the denominator.')
         END {ELSE for IF-THEN-ELSE for 0 in denominator which ends here too.}
END. {program FractionMath}

