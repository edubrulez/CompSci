PROGRAM PI (input, output);
uses crt;

{Erick Nave
 9:00 ICS 3-30-93
 PI asks the user for the number of terms in which he wants 3 different
    equations that figure the value of PI to be carried out to.  Then, the
    program uses the terms to calculate PI, interrupting it 20 times to print
    a progress report.  Then the value of PI for the final term is printed.}

VAR
   Terms: INTEGER; {needed for input by user}

PROCEDURE GetTerms(var Terms: INTEGER);
 {GetTerms asks the user for the number of terms that he wants the equations
           to be carried out to using the paramater Terms for the info.}
 BEGIN
    WRITELN('I have 3 equations that process the value of PI. What I need');
    WRITELN('  from you is the number of terms you want the equations');
    WRITELN('  to use.');
    WRITELN;
    REPEAT
          WRITELN('How many terms do you want (# > 0, please): ');
          READLN (Terms)
    UNTIL (Terms > 0)
 END; {GetTerms}

PROCEDURE Stop (Terms: INTEGER; var STP: INTEGER);
  {Stop figures the interval at which to interrupt the calculations in order
       to print a progress report. STP will be the value of the interval
       to be sent to StopToPrint in PIe.  Terms is needed to help figrure STP}
  BEGIN
       IF Terms <= 20 then
          STP:= 1
       ELSE
          IF (Terms mod 20) = 0 then
             STP:= (Terms div 20) - 1
          ELSE
             STP:= Terms div 20;
  END; {Stop}

FUNCTION P(Val: LONGINT): REAL;
  {P is the function used to figure the product of the fractions in method 2
     on the sheet proceeding the 1/(2n-1) value it will be sent to product in
     procedure PIe.  Val receives the value in Value for help.}
  VAR
     temp: REAL; {temporary storage for what will be P}
     i:integer; {needed for loop to determine temp if Val > 3}
  BEGIN
       temp:=1;
       CASE Val OF
          1: temp:= 2;
          2: temp:= 1;
          3: temp:= 0.75;
       END; {CASE Val OF}
       IF Val > 3 then
         FOR i:= 2 to (Val-1) do
            temp:= temp * (((2*i)-1)/(2*i));
       P:= temp
  END; {P}

PROCEDURE PrintProgress (V:LONGINT; STP, T:INTEGER; M1, M2, M3:REAL;
                         var C:INTEGER);
  {PrintProgress takes the values of Value(V), Count(C), StopToPrint(STP),
     Method1(M1), Method2(M2), and Method3(M3) from PIe and makes the decision
     on whether or not it is time to print out the progress or final printing
     of methods 1, 2, or 3.  If it is time, then it will print out the info.}
  BEGIN
       IF (V mod STP = 0) and (C <= 20) then
         BEGIN
            WRITELN(C:3, V:8, M1:20:10, M2:20:10, M3:20:10);
            C:=C+1
         END
       ELSE
           IF V = T THEN
              BEGIN
                WRITE('--------------------------------------------------');
                WRITELN('----------------------------');
                WRITELN(T:11, M1:20:10, M2:20:10, M3:20:10)
              END
  END; {PrintProgress}

PROCEDURE PIe (Terms:INTEGER);
  {PIe is the procedure that figures PI using the 3 equations together,
      interrupting occasionally for a progress report.  Terms is needed for
      a loop boundry}
  VAR
     Count, StopToPrint: INTEGER;
     Value:LONGINT;
     Method1, Method2, Meth3, Method3, Product: REAL;
       {Count is needed to keep track of the 20 interruptions.  StopToPrint
          is the number of how often to interrupt.  Value is the loop index.
          Method1 is PI according to the 1st equation on the assignment sheet.
          Methods2 & 3 are the 2nd and 3rd equations, respectively. Meth3 is
          the sum of the values needed to be square rooted to obtain Method3.
          Product receives the value determined in the function P to help get
          Method2.}
  BEGIN
     CLRSCR;
     Count:=1;
     Method1:=0;
     Method2:=0;
     Meth3:=0;
     Stop(Terms, StopToPrint);
     WRITELN ('Count', 'Terms':7, 'Method 1':17, 'Method 2':20,
              'Method 3':20);
     FOR Value:= 1 to Terms DO
         BEGIN
              IF (Value mod 2) = 0 then
                 Method1:= Method1 - (4/((2*Value)-1))
              ELSE
                  Method1:= Method1 + (4/((2*Value)-1));
              Product:= P(Value);
              Method2:= Method2 + (Product/((2*Value)-1));
              Meth3:= Meth3 + (6/sqr(Value));
              Method3:= sqrt(Meth3);
              PrintProgress (Value, StopToPrint, Terms, Method1, Method2,
                             Method3, Count)
         END; {FOR - DO loop}
  END; {PIe}

BEGIN {main body}
     CLRSCR;
     GetTerms(Terms);
     PIe(Terms);
END.{program PI}