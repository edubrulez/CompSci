PROGRAM FalconManufCo (input, output, Source, Business, Individual);
uses crt;

{Erick Nave
 9:00 ICS 4-27-93
 FalconManufCo reads a data file, specified by the user, of customers
     and throws a customer's name, address, a boolean value used to decide if
     the customer is a business or an individual, a description (blanks if
     an individual), and a credit limit (0 if a business) into a record which
     contains an array of records and the size of the array.  Individuals
     have credit limits but not descriptions and businesses have descriptions
     but not credit limits which is why the above in () occurs.  The array of
     records will be placed into 1 of 2 files specified by the user, 1 for
     businesses, and the other for individuals.  The business file contains
     businesses in alphabetical order.  The individual file contains the
     indivduals: first in alphabetical order and then by credit limit in
     descending order.  The array of records is sorted by name, then written
     to the proper files. The array is sorted again by credit limit, then the
     individuals are written to the individual file again.}

CONST
     InfoLength = 30;  {max length for name, street, and description}
     CityLength = 20;  {max length for city}
     StateLength = 2;  {max length for state}
     ZipLength = 10;   {max length for zip code}
     MaxEntries = 50;  {max number of customers in list}
     TabVal = 9;       {ascii value for tab character}

TYPE
    InfoType = Packed Array [1..InfoLength] of CHAR;
       {Names, Streets, and Descriptions all share these characteristics}
    CityType = Packed Array [1..CityLength] of CHAR;
    StateType = Packed Array [1..StateLength] of CHAR;
    ZipType = Packed Array [1..ZipLength] of CHAR;
    FalconRec = RECORD
                   Name, Street, Description: Infotype;
                   City: CityType;
                   State: StateType;
                   Zip: ZipType;
                   BusOrInd: BOOLEAN;
                   CreditLimit: LONGINT
                END;
    ListType = RECORD
                  Size: INTEGER; {size of array of records below}
                  Falcon: Array [1..MaxEntries] of FalconRec
               END;

VAR
   FalconList: ListType;
   FileName: STRING [40];                {used when asking for file names}
   Source, Business, Individual: TEXT;   {names for text files}

PROCEDURE GetInfo (var info: InfoType);
  {GetInfo is called by GetFalconData to retrieve Name, Street, and
      Description.  These 3 pieces of data share the same characteristics such
      as they are all of type InfoType (Packed Array [1..30] of CHAR) and are
      delimited by either tab characters or eoln markers. This means that
      they can all be sent to this procedure. The procedure removes all
      leading spaces and once it finds the first character, it reads the rest
      and places them into the packed array. If the last character is in a
      position that is less than InfoLength, the rest of the array is set
      to spaces to remove unwanted junk.}
  VAR
     ch: CHAR; {used to retrieve character from Source}
     position: INTEGER; {used for position inside packed array}
  BEGIN
     position:= 0;
     WHILE (not eoln(Source)) and (ord(ch) <> TabVal) do
        BEGIN
          READ (Source, ch);
          IF ch <> ' ' then
            BEGIN
              position:= position + 1;
              info[position]:= ch;
              WHILE (not eoln(Source)) and (ord(ch) <> TabVal) do
                BEGIN
                  READ (Source, ch);
                  position:= position + 1;
                  IF (position <= InfoLength) then
                    info[position]:= ch
                END
            END
        END;
     WHILE position < InfoLength do
        BEGIN
          position:= position + 1;
          info[position]:= ' '
        END
  END; {GetInfo}

PROCEDURE GetCity (var City: CityType);
  {GetCity is called by GetFalconData to retrieve the city.  The procedure
      removes all leading spaces and once it finds the first character, it
      reads the rest and places them into City. If the last character is in a
      position that is less than CityLength, the rest of the array is set
      to spaces to remove unwanted junk.}
  VAR
     ch: CHAR; {gets character from text file}
     position: INTEGER; {position within array}
  BEGIN
     position:= 0;
     WHILE (not eoln(Source)) and (ch <> ',') do
        BEGIN
          READ (Source, ch);
          IF ch <> ' ' then
             BEGIN
               position:= position + 1;
               City[position]:= ch;
               WHILE (not eoln(Source)) and (ch <> ',') do
                 BEGIN
                   READ (Source, ch);
                   position:= position + 1;
                   IF ch = ',' then
                      City[position]:= ' '
                   ELSE
                     IF (position <= CityLength) then
                       City[position]:= ch
                 END
             END
          END;
        WHILE position < CityLength do
          BEGIN
            position:= position + 1;
            City[position]:= ' '
          END
  END; {GetCity}

PROCEDURE GetState (var State: StateType);
  {GetState is called by GetFalconData to get state from the text file.
       All leading spaces are skipped over until it comes to a character.
       that and the next non space (which should be the next character) are
       placed into state.  OK terminates the loop when position = StateLength
       which means the 2 initials of the state have been found.}
  VAR
     ch: CHAR; {read character from text}
     position: INTEGER; {position of array}
     OK: BOOLEAN;  {used to terminate loop when position = StateLength}
  BEGIN
     position:= 0;
     OK:= TRUE;
     WHILE (not eoln(Source)) and OK do
        BEGIN
          READ(Source, ch);
          IF (ch <> ' ')  then
            BEGIN
              position:= position + 1;
              IF position <= StateLength then
                State[position]:= ch;
              IF position = StateLength then
                 OK:= false
            END
        END
  END; {GetState}

PROCEDURE GetZip (var Zip: ZipType);
  {GetZip is called by GetFalconData to get zip code.  It skips over leading
      spaces till it finds a character.  Then the rest of the characters up
      until the tab character are placed into Zip.  If position is less than
      ZipLength, the rest of Zip if filled with ' ' to remove junk.}
  VAR
     ch: CHAR; {gets character from text file}
     position: INTEGER; {position within array}
  BEGIN
     position:= 0;
     WHILE (not eoln(Source)) and (ord(ch) <> TabVal) do
        BEGIN
          READ (Source, ch);
          IF ch <> ' ' then
             BEGIN
               position:= position + 1;
               Zip[position]:= ch;
               WHILE (not eoln(Source)) and (ord(ch) <> TabVal) do
                 BEGIN
                   READ (Source, ch);
                   position:= position + 1;
                   IF (position <= ZipLength) then
                      Zip[position]:= ch
                 END
             END
        END;
        WHILE position < ZipLength do
          BEGIN
            position:= position + 1;
            Zip[position]:= ' '
          END
  END; {GetZip}


PROCEDURE GetTorF (var TorF: BOOLEAN);
  {GetTorF reads a character T or F and assigns the according boolean value
     to TorF.  This is how we know if it is a business (T = true) or an
     individual (F = false).}
  VAR
     ch: CHAR; {read character from text}
  BEGIN
     WHILE (not eoln(Source)) and (ch <> 'T') and (ch <> 'F') do
        BEGIN
          READ(Source, ch);
          IF (ch <> ' ')  then
            IF ch = 'T' then
               TorF:= true
            ELSE
              TorF:= false;
        END
  END; {GetTorF}


PROCEDURE GetFalconData (var FL: ListType);
  {GetFalconData is called to retrieve vital information on Falcon's
      customers.  It then delegates the duty to other procedures to find
      the Name, Street, City, State, Zip, and whether it is a business or an
      individual.  It then uses the boolean value of BusOrInd to set the
      Credit Limit to 0 and find the description (if a business) or set the
      description to ' ' and find the Credit Limit (if an individual).}
  VAR
     x: INTEGER; {loop index to make description blank if individual.}
  BEGIN
     WITH FL do
         WHILE (not eof(Source)) and (Size < MaxEntries) do
           BEGIN
             Size:= Size + 1;
             GetInfo (Falcon[Size].Name);
             GetInfo (Falcon[Size].Street);
             GetCity (Falcon[Size].City);
             GetState (Falcon[Size].State);
             GetZip (Falcon[Size].Zip);
             GetTorF (Falcon[Size].BusOrInd);
             IF Falcon[Size].BusOrInd then
                BEGIN
                  GetInfo (Falcon[Size].Description);
                  Falcon[Size].CreditLimit:= 0
                END
             ELSE
                BEGIN
                  FOR x:= 1 to InfoLength do
                      Falcon[Size].Description[x]:= ' ';
                  READ (Source, Falcon[Size].CreditLimit)
                END;
             READLN (Source)
           END
  END; {GetFalconData}

PROCEDURE SortByName (var FL: ListType);
  {SortByName sorts FalconList (FL) by name in alphabetical order using a
       selection sort with the name field.}
  VAR
     LargestSpot, Last, NewName: INTEGER;  {used in rearranging process}
     TempRec: FalconRec;  {temporary storage of record}
  BEGIN
     WITH FL do
       FOR Last:= Size downto 2 do
          BEGIN
            LargestSpot:= 1;
            FOR NewName:= 2 to Last do
               BEGIN
                 IF Falcon[NewName].Name > Falcon[LargestSpot].Name then
                    LargestSpot:= NewName;
                 TempRec:= Falcon[LargestSpot];
                 Falcon[LargestSpot]:= Falcon[Last];
                 Falcon[Last]:= TempRec
               END
          END
  END; {SortByName}

PROCEDURE SortByCreditLimit (var FL: ListType);
  {SortByCreditLimit sorts FalconList (FL) in by Credit Limit in descending
       order using the selection sort with CreditLimit.}
  VAR
     SmallestSpot, Last, NewLimit: INTEGER;  {used in rearranging process}
     TempRec: FalconRec;  {temporary storage of record}
  BEGIN
     WITH FL do
       FOR Last:= Size downto 2 do
          BEGIN
            SmallestSpot:= 1;
            FOR NewLimit:= 2 to Last do
               BEGIN
                 IF Falcon[NewLimit].CreditLimit <
                           Falcon[SmallestSpot].CreditLimit then
                    SmallestSpot:= NewLimit;
                 TempRec:= Falcon[SmallestSpot];
                 Falcon[SmallestSpot]:= Falcon[Last];
                 Falcon[Last]:= TempRec
              END
          END
  END; {SortByCreditLimit}

PROCEDURE WriteFalconData (var FL: ListType; Check: BOOLEAN);
  {WriteFalconData writes the data contained in the records (FL) to either
      the Business or Individual text files determined by the boolean value
      in FL.Falcon[x].BusOrInd.  Check comes into play in the IF-THEN
      structure.  Since the businesses need to be printed only once in
      alphabetical order, check makes sure it is not printed again after
      the SortByCreditLimit procedure.  That way, both the alphabetized and
      credit limit ordered lists of individuals are both printed to the
      individual file.  Because of Check, a second write procedure for
      credit limits is not necessary.  Check is also used to write to the
      files whether the list is in alphabetical or descending order.}
  VAR
     x: INTEGER; {loop index for array position}
  BEGIN
     IF Check then
        BEGIN
          WRITELN (Individual, '** Individuals in Alphabetical Order **':60);
          WRITELN (Business, '** Businesses in Alphabetical Order **':59)
        END
     ELSE
        WRITELN (Individual, '** Individuals - Descending Order By Credit Limit **':65);
     WRITELN (Individual);
     WRITELN (Business);
     FOR x:= 1 to FL.Size do
        BEGIN
          WITH FL.Falcon[x] do
            IF BusOrInd AND Check THEN
              BEGIN
                WRITELN (Business, Name);
                WRITELN (Business, Street);
                WRITE (Business, City,', ');
                WRITE (Business, State,' ');
                WRITELN (Business, Zip);
                WRITELN (Business, Description);
                WRITELN (Business)
              END
            ELSE
              IF not (BusOrInd) then
                BEGIN
                  WRITELN (Individual, Name);
                  WRITELN (Individual, Street);
                  WRITE (Individual, City,', ');
                  WRITE (Individual, State,' ');
                  WRITELN (Individual, Zip);
                  WRITELN (Individual, '$',CreditLimit);
                  WRITELN (Individual)
                END
        END
  END; {WriteFalconData}

BEGIN {main}
     clrscr;
     FalconList.Size:= 0;
     WRITELN ('Enter name of file to be opened: ');
     READLN (FileName);
     ASSIGN (Source, FileName);
     RESET (Source);
     WRITELN;
     WRITELN ('Enter name of file to be written to for businesses:');
     READLN (FileName);
     ASSIGN (Business, FileName);
     REWRITE (Business);
     WRITELN;
     WRITELN ('Enter name of file to be written to for individuals:');
     READLN (FileName);
     ASSIGN (Individual, FileName);
     REWRITE (Individual);
     GetFalconData (FalconList);
     SortByName (FalconList);
     WriteFalconData (FalconList, true);
     SortByCreditLimit (FalconList);
     WriteFalconData (FalconList, false);
     CLOSE (Business);
     CLOSE (Individual)
END. {FalconManufCo}
