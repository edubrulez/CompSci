PROGRAM InventoryUpdate (input, output, InvFile, TransactionFile,
     TranscriptFile, ExceptionFile);

{Erick Nave
 DS&A1 9-3-93
 InventoryUpdate (invupdat.pas) accesses a binary inventory file and places
    its records into an array.  Next it accesses a text transaction file
    specified by the user and reads the first character, the transaction to be
    done, and the part number effected by the transaction.  If the transaction
    character is valid then it calls upon a binary search to see if the part
    number is in the array.  All errors (Illegal transactions, part number not
    found on a delete, price or quantity change, and duplicate part number on
    an add) are reported in an exception file with the same base name as the
    transaction file.  All valid transactions are reported in a transcript
    file with the same base name as the transaction file.  The new inventory
    (the updated array) is then written back to the inventory file.}

USES CRT;

CONST
     DescriptionLength = 15; {max # of characters the description can be}
     PartNumberLength = 7;
     MaxRecords = 50;

TYPE
    DescriptionType = Packed Array[1..DescriptionLength] of Char;
    PartNumberType = Packed Array[1..PartNumberLength] of Char;
    PartType = RECORD
                PartNumber:PartNumberType;
                Quantity:Integer;
                Price:Real;
                Description:DescriptionType
               END;
    InvFileType = FILE OF PartType;
    InventoryType = ARRAY[1..MaxRecords] of PartType;

VAR
   InvFile: InvFileType;   {binary file of inventory information}
   Inventory: InventoryType; {array of which data is read into and changed}
   TransactionFile, TranscriptFile, ExceptionFile: TEXT;
      {TransactionFile is the source file for the transactions. Transcript-
          File and ExceptionFile contain text information on legal and illegal
          transactions.}
   Size, Deletions, QuantitiesChanged, PricesChanged, Additions,
       Transactions: INTEGER;
     {Size is the size of the array.  Deletions is the number of items
        deleted.  QuantitiesChanged is the number of items whose quantities
        have been changed.  PricesChanged is the number of items whose prices
        have been changed.  Additions is the number of items added.  Trans-
        actions is the number of total legal and illegal transactions.}
   FileName: STRING[8]; {base name of the files}

PROCEDURE GetRecords(var inv:InventoryType; var size:integer);
  {GetRecords retreives the inventory records from inventry.dat and places
      them into the array (inv) and returns the size of the array (size).}
  BEGIN
    RESET (InvFile);
    WHILE not eof(InvFile) do
      BEGIN
        size:= size + 1;
        READ(InvFile, inv[size])
      END;
    CLOSE(InvFile)
  END; {GetRecords}

PROCEDURE ReadPartNumber(var PartNum:PartNumberType);
  {ReadPartNumber reads the next 7 characters of text from TransactionFile.
     This is the part number (PartNum).}
  VAR x: integer; {loop index}
  BEGIN
    FOR x:= 1 to 7 do
        READ(TransactionFile, PartNum[x])
  END; {ReadPartNumber}

PROCEDURE BinarySearch (var Inv:InventoryType; Part:PartNumberType; var Found:
                            boolean; Size:integer; var middle:integer);
  {BinarySearch searches the array for the part number (Part) and gives Found
      a boolean value to aid in the decision making in ReadTransactionType.
      It also returns the position of the part (middle) to be used when
      processing the transactions.}
  VAR
    first, last: integer; {used to aid in binary search}
  BEGIN
    found:= false;
    first:= 1;
    last:= Size;
    WHILE (first<=last) and not found do
      BEGIN
        middle:= (last + first) div 2;
        IF Inv[middle].PartNumber = Part then
          found:= true
        ELSE
          IF Inv[middle].PartNumber < Part
             then first:= middle + 1
          ELSE
            last:= middle - 1
      END
  END; {Binary Search}

PROCEDURE GetDescription(var d:DescriptionType);
  {GetDescription is called either by add to retrieve the description or when
      an illegal transaction occurs and the rest of the transaction needs to
      be read in order to write the transaction to the ExceptionFile. d is
      short for description and is the packed array that carries the info.}
  VAR loc: integer; {used for array subscript}
  BEGIN
    loc:= 0;
    WHILE not eoln(TransactionFile) do
      BEGIN
        loc:= loc + 1;
        READ(TransactionFile, d[loc])
      END;
    WHILE loc < DescriptionLength do
      BEGIN
        loc:= loc + 1;
        d[loc]:= ' '
      END;
    READLN (TransactionFile)
  END; {GetDescription}

PROCEDURE DeleteItem(var Inv:InventoryType; var size, deletenum:integer;
                         where:integer; part: PartNumberType);
  {DeleteItem takes the inventory array (inv), the position of the item
      to be deleted (where), and the size of the array (size) to shift all of
      the items above the one to be deleted down one position.  Size is then
      decreased to reflect the new number of items.  The part number (part)
      is used in writing the transcript.}
  VAR x:integer; {loop index}
  BEGIN
    deletenum:= deletenum + 1;
    FOR x:= where to size do
      Inv[x]:= Inv[x+1];
    size:= size - 1;
    WRITELN(TranscriptFile,'Part number ',part,' deleted.');
    READLN(TransactionFile);
  END; {DeleteItem}

PROCEDURE QuantityChange (var quant, quantnum:integer; Part: PartNumberType);
  {QuantityChange reads an integer into quant, which will be the future value
      of Inv[where].quantity in ReadTransactionType.  Quantnum is the running
      total of how many times QuantityChange has been called.  Part is the
      part number used in writing the transcript.}
  BEGIN
    quantnum:= quantnum + 1;
    READLN(TransactionFile, quant);
    WRITELN(TranscriptFile, 'Quantity of ',Part,' changed to ',quant)
  END; {QuantityChange}

PROCEDURE PriceChange (var price:real; var pricenum: integer; Part:
                           PartNumberType);
  {PriceChange reads a real value into price, the future value of
      Inv[where].price in ReadTransactionType.  Pricenum keeps track of how
      many times Price Change has been called.  Part is the part number used
      in the transcript}
  BEGIN
    pricenum:= pricenum + 1;
    READLN(TransactionFile, price);
    WRITELN(TranscriptFile, 'Price of ',Part,' changed to ',price:0:2 )
  END; {PriceChange}

PROCEDURE AddItem (var Inv:InventoryType; var size, addnum:integer; where:
                       integer; PartNum: PartNumberType);
  {AddItem takes the inventory array (inv) and uses size and where to shift
     the components of the array up one position to free up a space for the
     new item. Size is increased to reflect the added item.  The new item is
     added to the Spot position which is determined by seeing if the part
     number to be added is greater than the one at position where.  If it is
     then one has to be added to where in order to maintain order.  That value
     is given to spot.  If the part number is less than the one at where then
     spot is equal to where.  Addnum adds one to the number of times this
     procedure is called. PartNum is used in determining Spot and in the
     transcript.}
  VAR x, Spot:integer; {x is loop index. Spot is location of addition}
  BEGIN
    addnum:= addnum + 1;
    IF Inv[where].PartNumber < PartNum then
      Spot:= where + 1
    ELSE
      Spot:= where;
    size:= size + 1;
    FOR x:= size downto (spot + 1) do
      Inv[x]:= Inv[x-1];
    Inv[spot].PartNumber:= PartNum;
    Inv[spot].Quantity:= 0;
    Inv[spot].Price:= 0.0;
    GetDescription(Inv[spot].Description);
    WRITELN(TranscriptFile, 'Part number ',PartNum,' added with the ',
                            'descrpition ',Inv[spot].Description)
  END; {AddItem}

PROCEDURE ReadTransactionType(var Inv:InventoryType; var Size, deletenum,
          quantnum, pricenum, addnum, transnum:Integer);
  {ReadTransactionType reads the first character of the transaction, which is
      the transaction type.  It then takes the next 7 characters which is the
      part number (PartNum).  Then, through a sequence of decision statements,
      and possibly a binary search to aid in the decisions, it either sends
      the proper paramaters to the proper procedure to change the inventory
      array (Inv) or write an error message to the exception file.  Transnum
      is incremented one each time to get a total number of transactions. Size
      is changed or used by the procedures called by this one.  Deletenum,
      quantnum, pricenum, and addnum are accumulated in their respective
      procedures to be sent back to the main body to be displayed.}
  VAR
    TranType:char; {the transaction selected}
    PartNum:PartNumberType; {the Part number}
    found:boolean; {used in decisions}
    where:integer; {if found then it is location of component to be changed}
    desc:DescriptionType; {used in procedure call GetDescription to capture
                                the rest of the transaction in order to
                                write the transaction to the exception file
                                when there is an error}
  BEGIN
    transnum:= transnum + 1;
    READ(TransactionFile,TranType);
    ReadPartNumber(PartNum);
    IF TranType in ['A', 'D', 'Q', 'P'] then
      BEGIN
        BinarySearch(Inv, PartNum, found, Size, Where);
        IF found then
          CASE TranType of
            'A': BEGIN
                   GetDescription(Desc);
                   WRITELN(ExceptionFile,TranType,PartNum,Desc);
                   WRITELN(ExceptionFile,'Duplicate part number on an Add ',
                                                    'transaction.');
                   WRITELN(ExceptionFile)
                 END;
            'D': DeleteItem(Inv, size, deletenum, where, PartNum);
            'Q': QuantityChange(Inv[where].Quantity, quantnum, PartNum);
            'P': PriceChange(Inv[where].Price, pricenum, PartNum)
          END
        ELSE
          IF TranType <> 'A' then
            BEGIN
              GetDescription(Desc);
              WRITELN(ExceptionFile,TranType,PartNum,Desc);
              WRITELN(ExceptionFile,'Non-existing part number on a ',TranType,
                                                  ' transaction.');
              WRITELN(ExceptionFile)
            END
          ELSE AddItem(Inv, size, addnum, where, PartNum)
      END
    ELSE
      BEGIN
        GetDescription(Desc);
        WRITELN(ExceptionFile,TranType,PartNum,Desc);
        WRITELN(ExceptionFile,'Illegal transaction code.');
        WRITELN(ExceptionFile)
      END
  END; {ReadTransactionType}

PROCEDURE WriteUpdatedInventory(var inv:InventoryType; size:integer);
  {WriteUpdatedInventory writes the array with all changes to InvFile.}
  var x:integer; {loop index}
  BEGIN
    REWRITE (InvFile);
    FOR x:= 1 to size do
        write(InvFile, Inv[x]);
    CLOSE (InvFile)
  END; {WriteUpdatedInventory}

BEGIN {main}
     clrscr;
     Size:= 0;
     Deletions:= 0;
     QuantitiesChanged:= 0;
     PricesChanged:= 0;
     Additions:= 0;
     Transactions:= 0;
     ASSIGN (InvFile,'inventry.dat');
     WRITE('Enter the base of the transaction file name: ');
     READLN(FileName);
     ASSIGN (TransactionFile, CONCAT(FileName, '.TRN'));
     RESET(TransactionFile);
     WRITELN;
     ASSIGN (TranscriptFile, CONCAT(FileName, '.TRS'));
     REWRITE(TranscriptFile);
     ASSIGN (ExceptionFile, CONCAT(FileName, '.XCP'));
     REWRITE(ExceptionFile);
     GetRecords(Inventory, Size);
     WHILE not eof(TransactionFile) do
       ReadTransactionType(Inventory, Size, Deletions, QuantitiesChanged,
           PricesChanged, Additions, Transactions);
     WriteUpdatedInventory(Inventory, Size);
     WRITELN ('There were:');
     WRITELN (Additions:5,' Additions');
     WRITELN (Deletions:5,' Deletions');
     WRITELN (QuantitiesChanged:5,' Quantities Changed');
     WRITELN (PricesChanged:5, ' Prices Changed');
     WRITELN ('and a TOTAL of ',Transactions,' transactions');
     CLOSE(TransactionFile);
     CLOSE(TranscriptFile);
     CLOSE(ExceptionFile)
END. {InventoryUpdate}