Program Postfix;
{Erick Nave
 DSAI 11-30-93}
 
{Postfix reads an expression from a data file and places an assignment
   expression into a list or evaluates the expression using the
   procedures and functions of the Ordered List and Stack ADT's along
   with the procedures, functions, and main body below.  Each has a
   description stating its function in the scope of this program.}
 
%print off
%Include OList
%print on
 
{This includes the following definitions... you may not change them!
 You will have to live with these since you have no access to the
 ordered list source code.
 Const
  IDLength = 10;
 Type
  IdentifierType = Packed Array[1..IdLength] of char;
  ListData = Record Identifier:IdentifierType; IdValue:Real End;
}
 
%include Stack
 
TYPE
  TokenKind = (operand, assignment, operator, other);
  TokenType = Record
               Case TK: TokenKind of
                 operand: (Id: IdentifierType);
                 assignment, operator: (Oper: char)
               end;
 
VAR
  input: text; {file accessed globally}
 
Procedure NoErrorsYet(var a,b,c:Boolean);
  {NoErrorsYet sets a,b,c to false since no errors have been found yet}
 begin
  a:= false;
  b:= false;
  c:= false
 end; {NoErrorsYet}
 
Function MoreTokens: Boolean;
 {checks for eoln or eof}
 begin
   MoreTokens:= (not eoln) and (not eof)
 end; {MoreTokens}
 
Procedure GetToken(var tok: TokenType);
 {GetToken gets the next token from f.  Also, as a character is read,
    it is written to the screen as to echo the expression.}
 var
   n: Integer; {position in packed array}
   ch: char; {CHaracter read from text}
 begin
   read(ch);
   If ch in ['-', '+', '*', '/'] then
     begin
       tok.tk:= operator;
       tok.oper:= ch;
       IF not eoln then read(ch);
       write(tok.oper)
     end
   else
     IF ch = '=' then
       begin
         tok.tk:= assignment;
         tok.oper:= ch;
         write(tok.oper);
       end
     else
       begin
         tok.tk:= operand;
         for n:= 1 to idlength do
           if (ch <> ' ') then
             begin
               tok.id[n]:= ch;
               IF not eoln then
                 read(ch)
               else
                 ch:= ' ';
               write(tok.ID[n])
             end
           else
             tok.ID[n]:= ' '
       end;
   write(' ')
 end; {GetToken}
 
Function MatchIdentifiers(A, B: ListData): Boolean;
 {MatchIdentifiers checks to see if A's identifier field = B's}
 Begin
  MatchIdentifiers:= A.Identifier = B.Identifier
 end; {MatchIdentifiers}
 
Function Before (A, B: ListData): Boolean;
 {Before checks to see if A's identifier < B's}
 Begin
  Before:= A.Identifier < B.Identifier
 end; {Before}
 
Procedure RPN(var S:Stack; var L: list; var uv, bf, dz: boolean);
 {RPN gathers tokens while there are MoreTokens.  If the token is an
    operand then it retreives the item from the list.  If the item isn't
    in the list then there is an undefined variable error (uv = true).
    If it is then the value associated with it is pushed onto the stack.
    When an operator is found 2 numbers are popped and sent to Eval
    to get an answer to be pushed back on to the stack.  A bad form
    error (bf = true) occurs if the stack is empty before a pop.
    Division by zero (dz) is determined by eval.  The new stack
    and boolean values for the errors are returned.}
 Function Eval(X,Y:real; op:tokentype; var dz: boolean): Real;
  {Eval is the result of X and Y being subjected to the OPeration given.
     dz = true if a division by zero is attempted.}
  begin
    Case op.oper of
      '+': Eval:= X + Y;
      '-': Eval:= X - Y;
      '*': Eval:= X * Y;
      '/': if y <> 0 then
             Eval:= X / Y
           else begin
             dz:= true;
             eval:= 0
           end
    end
  end; {Eval}
 VAR
   x,y: real; {numbers popped from stack}
   token: tokentype; {token read}
   listitem: listdata; {item retreived from list}
   ok: boolean; {used in list operations.}
 Begin
   While MoreTokens do
     begin
       GetToken(Token);
         IF Token.TK = operator then
           begin
             IF not EmptyStack(S) then
               Pop(S, Y)
             else
               bf:= true;
             IF not EmptyStack(S) then
               begin
                 Pop(S, X);
                 Push(S, Eval(X,Y,token,dz))
               end
             else
               bf:= true;
           end
         else
           begin
             ListItem.Identifier:= Token.ID;
             ListRetrieve(L, ListItem, MatchIdentifiers, ListItem, ok);
             IF ok then
               Push(S, ListItem.IdValue)
             Else
               uv:= true;
           end
     end;
 end;{RPN}
 
VAR
  NumberStack: Stack; {stack used to obtain answers}
  FirstToken, SecondToken: TokenType; {tokens to be read}
  ListItem, dummy: ListData; {items inserted into list, dummy value
                                 used in retrieval to fill a parameter}
  ok, UndefVarErr, BadFormErr, DivZeroErr: Boolean;
    {error checking conditions}
  L: List;  {Variable list}
  Answer: Real; {final number popped from stack}
 
{Since the expression is determined by the second token, main reads the
   first two tokens of the line are read with the first being placed
   into the list or stack, depending on the second which could be either
   a '=' or something else.  If it is a '=' then the number associated
   with the first token along with the token are placed into the list,
   otherwise the postfix evaluation occurs: The first token and second
   tokens are located in the list and the values are pushed onto the
   stack (if valid) and RPN is called. Then the proper message is
   produced according to the errors or answer.}
 
begin
  termout(output);
  Reset(input,'name= postfix.data.*');
  WHILE not eof do begin
    NoErrorsYet(UndefVarErr, BadFormErr, DivZeroErr);
    IF MoreTokens then
      GetToken(FirstToken);
    IF MoreTokens then
      GetToken(SecondToken)
    else
      SecondToken.TK:= other;
    IF SecondToken.TK = assignment then
      begin
        ListItem.Identifier:= FirstToken.ID;
        Read(ListItem.IDValue);
        Writeln(ListItem.IDValue:1:3);
        ListRetrieve(L, ListItem, MatchIdentifiers, dummy, ok);
        IF ok then
          begin
            ListUpdate(L, ListItem, MatchIdentifiers, ListItem, ok);
            IF ok then
              Writeln('Re-assignment')
            else
              Writeln('Update unsuccessful')
          end
        else
          begin
            ListAdd(L, ListItem, Before, ok);
            IF ok then
              Writeln('New Variable')
            else
              Writeln('Add unsuccessful')
          end
      end
    else
      begin
        CreateStack(NumberStack);
        IF (firsttoken.tk = operator) or (SecondToken.tk = operator)
          then BadFormErr:= true
        else
          begin
            ListItem.Identifier:= Firsttoken.ID;
            ListRetrieve(L, ListItem, MatchIdentifiers, ListItem, OK);
            If ok then
              Push(NumberStack, ListItem.IdValue)
            else
              UndefVarErr:= true
          end;
        IF SecondToken.TK = operand then
          begin
            ListItem.Identifier:= SecondToken.ID;
            ListRetrieve(L,ListItem,MatchIdentifiers,ListItem,OK);
            If ok then
              Push(NumberStack, ListItem.IdValue)
            else
              UndefVarErr:= true
          end;
        RPN(NumberStack,L,UndefVarErr,BadFormErr,DivZeroErr);
        writeln;
        Pop(NumberStack, Answer);
        IF not EmptyStack(NumberStack) then
          BadFormErr:= True;
        IF DivZeroErr then
          Writeln('Division By Zero')
        Else If UndefVarErr then
          Writeln('Undefined Variable')
        else If BadFormErr then
          Writeln('Badly Formed Expression')
        else writeln (Answer:1:3);
        DestroyStack(NumberStack)
      end;
    Readln;
    writeln;
  end;
end.
