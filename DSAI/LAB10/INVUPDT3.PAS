program invupdt3;
{written by John Donaldson for DSA I - 11/93
 modifications by Tim Margush - 11/93
 and by ERICK NAVE 11/16
 
 This program solves the basic inventory update problem.
 It is intended to demonstrate the use of a list ADT to simplify
  the application code. The particular List implementation is
  a file based linked list.}
 
%include invupdt3
 
{ordering relation for the ordered list of parts}
function lessthan(p1,p2:parttype):boolean;
  begin
    lessthan:=p1.PartNumber<p2.PartNumber
  end;
 
{match relation for the ordered list of parts}
function MatchPartNum(Item1,Item2:PartType):boolean;
  begin
    MatchPartNum:=Item1.PartNumber=Item2.PartNumber
  end;
 
{Increase price of item by 15%}
procedure PriceHike(var Item:ListData);
  begin
    Item.Price:= Item.Price * 1.15
  end;
 
{Display item}
procedure PrintItem(var Item:ListData);
  begin
    With Item do
     Writeln(PartNumber,' ',Quantity:5,Price:10:2,' ',Description)
  end;
 
var
  dummy : PartType;
  Ok : boolean;
T,L  : List;
  com : char;
  amt : integer;
begin
 Termout(output);
 reset(input,'name='||parms||'.trn.*');
 ListCreate(L,'inventry dat a',Ok);
 while not eof do
   begin
     read(com,dummy.partnumber);
     case com of   {transaction results echoed to screen}
       'a','A' : begin
                   ListRetrieve(L,dummy,MatchPartNum,dummy,Ok);
                   if OK then write('Duplicate part ')
                   else begin
                     read(dummy.description);
                     dummy.quantity:=0; dummy.price:=0;
                     ListAdd(L,dummy,lessthan,Ok);
                     if Ok then write('Added part ')
                           else write('Unable to add part ')
                   end;
                 end;
       'd','D' : begin
                   ListDelete(L,dummy,MatchPartNum,Ok);
                   if Ok then write('Deleted part ')
                         else write('Unable to delete part ')
                 end;
       'p','P' : begin
                   ListRetrieve(L,dummy,MatchPartNum,dummy,Ok);
                   if Ok then
                     begin
                        read(dummy.price);
                        ListUpdate(L,dummy,MatchPartNum,dummy,Ok)
                     end;
                   if not Ok then
                    write('Unable to update price in part ')
                    else write('Updated price in part ')
                 end;
       'q','Q' : begin
                   ListRetrieve(L,dummy,MatchPartNum,dummy,Ok);
                   if Ok then
                     begin
                        read(amt);
                        dummy.quantity:=dummy.quantity+amt;
                        ListUpdate(L,dummy,MatchPartNum,dummy,Ok)
                     end;
                   if not Ok then
                      write('Unable to update quantity in part ')
                   else write('Updated quantity in part ')
                 end;
       'h','H' : begin
                  Writeln('Price hike going into effect');
                  Traverse(L,PriceHike);
                  dummy.partnumber:=''
                 end;
       's','S' : begin
                  Writeln('Current inventory contents');
                  Traverse(L,PrintItem);
                  dummy.partnumber:=''
                 end;
       otherwise
           write('Unknown command ',com,' -Part ');
       end;
     writeln(dummy.partnumber);
     readln;
   end;
 ListDestroy(L);
end.
