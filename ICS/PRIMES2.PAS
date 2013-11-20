PROGRAM Primes (input, ouput);
uses crt;

{Erick Nave
 9:00 ICS 4-1-93
 Primes asks the user to input a number.  Primes then determines if the #
    is already prime.  If it is, prime is printed.  If it isn't, the program
    then gets the prime factors of the number and they are displayed.}

VAR
   Number: LONGINT;

PROCEDURE GetNumber(var Num: LONGINT);
  {GetNumber asks the user for the number to see whether or not it is prime
     or if it isn't prime to get the prime factors of that number. Num is the
     value to be sent to the variable Number in main.}
  BEGIN
     REPEAT
       WRITELN('Give me a number >= 0 (0 to quit): ');
       READ(Num);
       IF Num < 0 then
          BEGIN
             WRITELN ('Number you entered is negative.  Try Again.');
             WRITELN
          END
     UNTIL (Num >= 0) AND (Num <= MAXLONGINT)
  END; {GetNumber}

FUNCTION IsPrime(N: LONGINT): BOOLEAN;
  {IsPrime determines whether N (short for number, any number in particular)
     is prime or not.}
  VAR
     temp: BOOLEAN; {temporary storage for value to be issued to IsPrime}
     i: LONGINT; {loop index}
  BEGIN
     temp:= true;
     for i:= 2 to trunc(sqrt(N)) do
         IF (N mod i) = 0 then
            temp:= false;
     IsPrime:= temp
  END; {IsPrime}

FUNCTION SmallestFactor(N: LONGINT): LONGINT;
  {SmallestFactor recursively finds the smallest prime factor of N, the
     number sent into the function, which will be printed}
  VAR
     PossibleFactor: LONGINT; {value incremented until it does factor N}
  BEGIN
     PossibleFactor:= 1;
     REPEAT
        PossibleFactor:= PossibleFactor + 1
     UNTIL (IsPrime(PossibleFactor)) and ((N mod PossibleFactor) = 0);
     SmallestFactor:= PossibleFactor
  END; {SmallestFactor}

PROCEDURE PrintPrimes(Num: LONGINT);
  {PrintPrimes is responisble for printing prime if the number is prime by
     using IsPrime or sending the number to SmallestFactor to print the
     factors.  Num is the value receive from the value Number in main.}
  VAR
     SPF: LONGINT; {value obtained from SmallestFactor}
  BEGIN
     IF IsPrime(Num) then
        WRITELN (Num:1, ' = prime')
     ELSE
         BEGIN
            WRITE(Num:1, ' = ');
            REPEAT
               SPF:=SmallestFactor(Num);
               WRITE(SPF:1,'*');
               Num:= Num div SPF
            UNTIL IsPrime(Num);
            WRITELN(Num:1)
         END;
     WRITELN;
     WRITELN;
  END; {PrintPrimes}

BEGIN {main}
     clrscr;
     GetNumber(Number);
     WHILE Number <> 0 do
        BEGIN
           PrintPrimes(Number);
           GetNumber(Number)
        END
END. {Program Primes}