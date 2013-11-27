PROGRAM WordIndex (input, output, SourceFile, IndexFile);
uses crt;

{Erick Nave
 4-23-93 ICS 9:00
 WordIndex asks the user for a file to be indexed and a file to write the
    index to.  The program scans the source file and sticks the packed array
    of words into another array for the list, if it is not a duplicate.  It
    also keeps track of the line numbers that the word is found on up to 11.
    The arrays are then sorted by word in alphabetical order.  The arrays are
    then printed to the index file given by the user separated by letter.
    Only 10 of the 11 references are printed.  The 11th serves to see if
    there are more than 10 references.  If there are, then a + is printed.}

CONST
     MaxWordLength = 15; {maximum number of characters taken from the word}
     MaxWords = 1000; {Maximum words allowed in index}
     MaxReferences = 11; {Maximum # of references indexed}
     UptoLow = 32; {for conversion of uppercase to lowercase}

TYPE
    ReferencesType = Array [1..MaxReferences] of INTEGER;
    ReferenceListType = Array [1..MaxWords] of ReferencesType;
    WordType = Packed Array [1..MaxWordLength] of CHAR;
    WordListType = Array [1..MaxWords] of WordType;
    FileNameType = STRING [40];

VAR
   InputName, OutputName: FileNameType; {file names given by user}
   Aword: WordType; {the word found in the source file}
   WordList: WordListType; {list of words}
   ReferenceList: ReferenceListType; {list of reference lists for a word}
   Success, Found: BOOLEAN; {Sucess if a word is found.  Found if duplicate
                             is found.}
   SourceFile, IndexFile: TEXT; {text file names}
   Location, ListSize, WordCount, LineNumber: INTEGER;
      {Location of word found.  ListSize = # of distinct words.  WordCount =
         # of all words, including duplicates.  LineNumber keeps track of the
         number of lines.}

FUNCTION LowerCase (ch: CHAR): CHAR;
  {LowerCase takes the character sent to it and if it is upper case
       ('A' <= ch <= 'Z'), it makes it lowercase.}
  BEGIN
     IF (ch >= 'A') and (ch <= 'Z') then
        LowerCase:= chr(ord(ch) + UptoLow)
     ELSE
         LowerCase:= ch
  END; {LowerCase}

PROCEDURE FinishWord (ch: CHAR; var Aword: WordType; var Success: BOOLEAN;
                      var LN: INTEGER);
  {FinishWord complete the word found by GetWord, if it actually is a word.
      To be a word, it must begin with a letter (predetermined in GetWord),
      must contain letters, digits, and _ (underscore), and have at least
      two characters.  Only the first 15 letters of long words are stored.
      LN helps GetWord count lines.}
  VAR
     position: INTEGER; {position in array}
  BEGIN
     position:= 0;
     WHILE ((ch >= 'a') and (ch <= 'z')) or (ch = '_') or ((ch >= '0') and
           (ch <= '9')) do
        BEGIN
          position:= position + 1;
          IF position <= MaxWordLength then
             Aword[position]:= ch;
          IF eoln (SourceFile) or eof (SourceFile) then
             ch:= ' '
          ELSE
            BEGIN
              READ (SourceFile, ch);
              ch:= LowerCase(ch)
            END
        END;
     IF position < 2 then
        Success:= false;
     WHILE position < MaxWordLength do
        BEGIN
          position:= position + 1;
          Aword[position]:= ' '
        END
  END; {FinishWord}

PROCEDURE GetWord (var Aword: WordType; var Success: BOOLEAN;
                   var LineNum: INTEGER);
  {GetWord reads characters from source and determines if the character
      begins the word.  If it does, we then go to FinishWord to get the
      entire word and Success is true. If it doesn't, then there are no words
      and success is false.  LineNum keeps track of the lines}
  VAR
     ch: char;
  BEGIN
     REPEAT
        IF eoln (SourceFile) then
           LineNum:= LineNum + 1;
        READ (SourceFile, ch);
        ch:= LowerCase(ch)
     UNTIL eof(SourceFile) or ((ch >= 'a') and (ch <= 'z'));
     IF eof (SourceFile) then
        Success:= false
     ELSE
         BEGIN
           Success:= true;
           FinishWord (ch, Aword, Success, LineNum)
         END
  END; {GetWord}

PROCEDURE Search (Aword: WordType; WordList: WordListType; Size: INTEGER;
                  var Location: INTEGER; var Found: BOOLEAN);
  {Search looks to see if Aword is in WordList.  Found represents the result
       of the search. Location is set if word is found. Size is needed for
       loop limits.}
  VAR
     i: INTEGER; {needed for loop}
  BEGIN
       Found:= false;
       FOR i:= 1 to Size do
          If WordList[i] = Aword then
            BEGIN
              Location:= i;
              Found:= true
            END
  END; {Search}

PROCEDURE AddNewWord (Aword: WordType; var WordList: WordListType; var size:
                      INTEGER; var ReferenceList: ReferenceListType);
  {Since found is false, Aword is not in WordList, so it must be added to
       Wordlist.  AddNewWord does this.  Size is incremented because one
       more word is being added.  ReferenceList[Size] is then initialized to
       all zeros to prepare it for line numbers to be thrown in later.}
  VAR
     i: INTEGER; {loop index to help initalize ReferenceList[Size]}
  BEGIN
     Size:= Size + 1;
     IF Size <= Maxwords then
       WordList[Size]:= Aword;
     FOR i:= 1 to MaxReferences do
         ReferenceList[Size,i]:= 0
  END; {AddNewWord}

PROCEDURE AddReference (LineNumber: INTEGER; var References: ReferencesType);
  {Once a word is found or added, the line number must be added to the list
        of references, if it isn't a duplicate.  AddReference does so.}
  VAR
     position: INTEGER;
  BEGIN
     position:= 0;
     REPEAT
       position:= position + 1
     UNTIL (position = MaxReferences) or (References[position] = 0) or
           (References[position] = LineNumber);
     IF (References[position] = 0) then
        References[position]:= LineNumber
  END; {AddReference}

PROCEDURE Sort (var WordList: WordListType; var ReferenceList:
                ReferenceListType; Size: INTEGER);
  {Sort sorts WordList into alphabetical order and at the same time sorts the
       corresponding references.  Size is needed for loop limits.}
  VAR
     last, largestspot, newword, x: INTEGER; {needed to help rearrange.}
     temp1: WordType; {for temporary storage of word}
     temp2: ReferencesType; {for temporary storage of references}
  BEGIN
     FOR last:= Size downto 2 do
        BEGIN
          largestspot:= 1;
          FOR newword:= 2 to last do
              if WordList[newword] > Wordlist[largestspot] then
                 largestspot:= newword;
              temp1:= WordList[largestspot];
              temp2:= ReferenceList[largestspot];
              WordList[largestspot]:= WordList[last];
              ReferenceList[largestspot]:= ReferenceList[last];
              WordList[last]:= temp1;
              ReferenceList[last]:= temp2
        END
  END; {Sort}

PROCEDURE PrintIndex (var WordList: WordListType; var ReferenceList:
                      ReferenceListType; Size: INTEGER; Name: FileNameType);
  {PrintIndex writes WordList, separated by letter, and ReferenceList to
       IndexFile.  Size is needed for loop limits.  IN stands for InputName,
       which is the name of the file to be indexed which was asked for in the
       beginning of main.  If there are 11 references, only 10 are printed.
       The 11th reference is to show that there ore more than 10 references
       in which case a + would be printed.}
  VAR
     i, z: INTEGER; {i keeps track of position WordList and ReferenceList.
                     z is needed to help access references.}
     character, charac: CHAR;
          {character is loop index.  charac is the lowercase of character,
              used in comparasions because the words are in lowercase.}
  BEGIN
     WRITELN(IndexFile,'Index for file ',Name);
     i:= 1;
     FOR character:= 'A' to 'Z' do
        BEGIN
          charac:= LowerCase (character);
          IF charac = Wordlist[i, 1] then
             BEGIN
               WRITELN (IndexFile);
               WRITELN (IndexFile, character)
             END;
          WHILE (i <= MaxWords) and (charac = Wordlist[i,1]) do
            BEGIN
              WRITE (IndexFile, Wordlist[i]:MaxWordLength + 1,' ');
              z:= 1;
              REPEAT
                WRITE (IndexFile, ReferenceList[i, z]);
                z:= z + 1;
                IF ReferenceList[i, z] <> 0 then WRITE (IndexFile, ', ');
              UNTIL (z = MaxReferences) or (ReferenceList[i, z] = 0);
              IF ReferenceList[i, MaxReferences] <> 0 then
                 WRITE (IndexFile, '+');
              WRITELN (IndexFile);
              i:= i + 1;
            END
        END
  END; {PrintIndex}

BEGIN {main}
     clrscr;
     LineNumber:= 1;
     WordCount:= 0;
     ListSize:= 0;
     WRITELN ('Enter the name of the file to be indexed:');
     READLN (InputName);
     ASSIGN (SourceFile, InputName);
     WRITELN;
     WRITELN ('Enter the name of the file that will contain the index:');
     READLN (OutputName);
     ASSIGN (IndexFile, OutputName);
     RESET (SourceFile);
     REWRITE (IndexFile);
     WRITELN;
     WRITELN ('Searching.');
     WHILE not eof (SourceFile) do
        BEGIN
           GetWord (Aword, Success, LineNumber);
           IF Success then
              BEGIN
                WordCount:=WordCount + 1;
                Search (Aword, WordList, ListSize, Location, Found);
                IF not found then
                  BEGIN
                    AddNewWord (Aword, WordList, ListSize, ReferenceList);
                    Location:= ListSize
                  END;
                AddReference(LineNumber, ReferenceList[location])
              END
        END;
     WRITELN;
     WRITELN ('Sorting.');
     Sort (WordList, ReferenceList, ListSize);
     WRITELN;
     WRITELN ('Writing to destination file.');
     PrintIndex (WordList, ReferenceList, ListSize, InputName);
     WRITELN;
     WRITELN ('There are ',LineNumber - 1,' lines');
     WRITELN ('    and ',WordCount,' words.');
     CLOSE (SourceFile);
     CLOSE (IndexFile)
END. {WordIndex}
