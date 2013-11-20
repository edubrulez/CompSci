segment Stack; {dynamic implementation of the Stack ADT}
{Erick Nave
 DSAI 11-30-93}
 
%include Stack
 
{Using dynamic memory for the Stack ADT makes for easy coding since all
   that must be kept track of is a pointer to the first node which also
   cuts down on the automatic memory used.  All operations on the stack
   are performed on this first pointer.  The following are the
   procedures and functions (with their duties explained) which are the
   operations on the stack ADT.}
 
Procedure CreateStack{var S:Stack};
 {CreateStack sets S to NIL}
 begin
   S:= NIL
 end; {CreateStack}
 
Procedure DestroyStack{var S:Stack};
 {Disposes of all dynamic memory associated with S}
 var temp, hold: Sptr; {TEMPorary storage of address. HOLDs address for
                            disposal.}
 begin
   temp:= S;
   WHILE temp <> NIL do
     BEGIN
       hold:= temp;
       temp:= temp@.next;
       dispose(hold)
     END;
  S:= NIL
 end; {DestroyStack}
 
Function EmptyStack{S:Stack):Boolean};
 {Stack is Empty when S is NIL}
  begin
    EmptyStack:= S = NIL
  end; {EmptyStack}
 
Function FullStack{S:Stack):Boolean};
  {with dynamic memory don't know when stack full so always false.}
  begin
    FullStack:= False
  end; {FullStack}
 
Procedure Push {var S:Stack; Item: StackData};
 {Push adds Item to the front of the stack}
 var temp: Sptr; {new node}
 begin
   IF not FullStack(S) then
     begin
       new(temp);
       temp@.data:= Item;
       Temp@.next:= S;
       S:= temp
     end
 end; {Push}
 
Procedure Pop{var S:Stack; var Item:StackData};
{Pop returns the first Item in the stack and then disposes the node.}
 var hold: Sptr; {HOLDs address to be disposed}
 begin
   IF not EmptyStack(S) then
     begin
       Item:= S@.Data;
       hold:= S;
       S:= S@.Next;
       Dispose(hold)
     end
 end; {Pop}
 
Procedure OnTop{S:Stack; var item: StackData};
 {OnTop returns the first item of the stack}
 begin
   item:= S@.Data
 end; {OnTop}
 
.
