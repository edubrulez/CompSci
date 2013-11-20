PROGRAM TextFileBreakdown (input, output);

{Erick Nave
 9:00 ICS 4-2-93
 TextFileBreakdown receives its input from prog7.pas (this program).  Then,
    the source code is broken down into the # of characters, vowels,
    consonants, digits, words, and lines.  This information will then be
    output to prog7.dat}

VAR
   ch, vowels, consonants, digits, words, lines: INTEGER;
      {used to tally the amount of each}

PROCEDURE Tally (charac: CHAR; var vow, con, dig: INTEGER);
  {Tally brings in the character (charac) read from input and through a case
     statement, increments the values of vow, con, and dig.  These values will
     be sent back to Count.}
  BEGIN
     CASE charac OF
          'A','E','I','O','U': vow:= vow + 1;
          'a','e','i','o','u': vow:= vow + 1;
          'B','C','D','F','G','H','J','K','L','M','N','P','Q','R',
               'S','T','V','W','X','Y','Z': con:= con + 1;
          'b','c','d','f','g','h','j','k','l','m','n','p','q','r',
               's','t','v','w','x','y','z': con:= con + 1;
          '0','1','2','3','4','5','6','7','8','9': dig:= dig + 1
     END
  END; {tally}

PROCEDURE Count (var ch, vow, con, dig, word, line: INTEGER);
  {Count brings in a character from input. It then keeps track of the number
      of characters (ch), words (word), and lines (line) while going to
      Tally to get the number of vowels (vow), consonants (con) and digits
      (dig).  These values will be sent to main to be written to prog7.dat.}
  VAR
     character: CHAR; {used to read characters from input}
  BEGIN
     WHILE not eof(input) DO
        BEGIN
           WHILE not eoln(input) DO
              BEGIN
                 READ (character);
                 ch:= ch + 1;
                 IF character <> ' ' THEN
                    BEGIN
                       Tally (character, vow, con, dig);
                       WHILE (not eoln(input)) and (character <> ' ') DO
                          BEGIN
                            READ (character);
                            ch:= ch + 1;
                            Tally (character, vow, con, dig)
                          END;
                       word:= word + 1
                    END
              END;
           READLN;
           line:= line + 1
        END
  END; {Count}

PROCEDURE RecordResults(c, vow, con, dig, word, line: INTEGER);
  {RecordResults writes the totals of the characters (c), vowels (vow),
     consonants (con), digits (dig), words (word), and lines (line), to the
     text file prog7.dat.}
  BEGIN
       WRITELN ('The total number of characters is : ',c:1);
       WRITELN (' "    "      "   "  vowels is     : ',vow:1);
       WRITELN (' "    "      "   "  consonants is : ',con:1);
       WRITELN (' "    "      "   "  digits is     : ',dig:1);
       WRITELN (' "    "      "   "  words is      : ',word:1);
       WRITELN (' "    "      "   "  lines is      : ',line:1)
  END; {RecordResults}

BEGIN {main}
     ASSIGN (input, 'prog7.pas');
     ASSIGN (output, 'prog7.dat');
     RESET (input);
     REWRITE (output);
     ch:= 0;
     vowels:= 0;
     consonants:= 0;
     digits:= 0;
     words:= 0;
     lines:= 0;
     Count (ch, vowels, consonants, digits, words, lines);
     RecordResults (ch, vowels, consonants, digits, words, lines);
     CLOSE (input);
     CLOSE (output)
END. {TextFileBreakdown}
