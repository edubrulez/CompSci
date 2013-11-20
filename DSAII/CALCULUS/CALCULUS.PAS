Program Calculus;
{Erick Nave
 DS&A II 1:00
 Start: 2-18-94
 Last Update: 3-4-94
 Calculus reads a stream of characters (prefix expression) from input
   and builds a tree.  It then takes the derivative of the expression
   and cleans it up.  The prefix and infix notation of the original
   expression and the infix notation of the derivative are output to
   the screen if the original expression is valid.  If it isn't
   then an error message is written to the screen.}
 
Type
  nodeptr = @nodetype;
  nodetype = record
               left, right: nodeptr; {left and right children/subtrees}
               data: char {operators and operands}
              end;
 
Var input: Text; {input file globally declared}
 
Function Build_Expression_Tree(var oper, opernd: integer): nodeptr;
{Build_Expression_Tree is a recursive function that reads characters
   until eoln and builds a binary expression tree.  The recursive call
   occurs when the character is an operator in order to match it with
   its operands (the leaves).  Oper (operators) and opernd (operands)
   are accumulators for error checking in main.}
var
  temp: nodeptr; {temporary address storage}
  ch: char; {character read from input}
begin
  If not eoln then
    begin
      read(ch);
      new (temp);
      If ch in ['+', '-', '*', '/', '^'] then {ch is operator}
        begin
          oper:= oper + 1;
          temp@.data:= ch;
          temp@.left:= Build_Expression_Tree(oper, opernd);
          temp@.right:= Build_Expression_Tree(oper, opernd);
        end {if operator}
      else {ch is operand}
        begin
          opernd:= opernd + 1;
          temp@.data:= ch;
          temp@.left:= nil;
          temp@.right:= nil;
        end; {else}
      Build_Expression_Tree:= temp
    end {if not eoln}
  else Build_Expression_Tree:= nil
end; {Build_Expression_Tree}
 
Procedure Destroy(p: nodeptr);
{Destroy disposes of dynamic memory using a postorder traversal.}
begin
  if p <> nil then
    begin
      Destroy(p@.left);
      Destroy(p@.right);
      Dispose(p)
  end {if}
end; {Destroy}
 
Function Copy(p:nodeptr): nodeptr;
{Copy copys trees using a preorder traversal.}
var temp: nodeptr; {temporaray address storage}
begin
  if p <> nil then
    begin
      new(temp);
      temp@.data:= p@.data;
      temp@.left:= Copy(p@.left);
      temp@.right:= Copy(p@.right)
    end {if}
  else temp:= nil;
 Copy:= temp
end; {Copy}
 
Function Diff(p: nodeptr): nodeptr;
{Diff is a recursive function determining the derivative of a binary
   expression tree.}
var temp: nodeptr; {temporaray address storage}
begin
 If p <> nil then
  begin
    new(temp);
    Case p@.data of  {L = left, R = right}
      '0'..'9': Begin  {constant}
                  temp@.data:= '0';
                  temp@.left:= nil;
                  temp@.right:= nil;
                end;
      'X', 'x': Begin   {just X}
                  temp@.data:= '1';
                  temp@.left:= nil;
                  temp@.right:= nil;
                end;
      '+': Begin  {Diff(L+R) = Diff(L) + Diff(R)}
             temp@.data:= '+';
             temp@.left:= Diff(p@.left);
             temp@.right:= Diff(p@.right);
           end;
      '-': Begin  {Diff(L-R) = Diff(L) - Diff(R)}
             temp@.data:= '-';
             temp@.left:= Diff(p@.left);
             temp@.right:= Diff(p@.right);
           end;
      '*': Begin  {Diff(L*R) = L * Diff(R) + R * Diff(T)}
             temp@.data:= '+';
             new(temp@.left);
             temp@.left@.data:= '*';
             temp@.left@.left:= Copy(p@.left);
             temp@.left@.right:= Diff(p@.right);
             new(temp@.right);
             temp@.right@.data:= '*';
             temp@.right@.left:= Copy(p@.right);
             temp@.right@.right:= Diff(p@.left);
           end;
      '/': Begin {Diff(L/R) = ((R * Diff(L)) - (L * Diff(R))) / (R^2)}
             temp@.data:= '/';
             new(temp@.left);
             temp@.left@.data:= '-';
             new(temp@.left@.left);
             temp@.left@.left@.data:= '*';
             temp@.left@.left@.left:= Copy(p@.right);
             temp@.left@.left@.right:= Diff(p@.left);
             new(temp@.left@.right);
             temp@.left@.right@.data:= '*';
             temp@.left@.right@.left:= Copy(p@.left);
             temp@.left@.right@.right:= Diff(p@.right);
             new(temp@.right);
             temp@.right@.data:= '^';
             temp@.right@.left:= Copy(p@.right);
             new(temp@.right@.right);
             temp@.right@.right@.data:= '2';
           end;
      '^': Begin  {Diff(L^const) = (const * L^(const - 1)) * Diff(L)}
             temp@.data:= '*';
             new(temp@.left);
             temp@.left@.data:= '*';
             temp@.left@.left:= Copy(p@.right);
             new (temp@.left@.right);
             temp@.left@.right@.data:= '^';
             temp@.left@.right@.left:= Copy(p@.left);
             new(temp@.left@.right@.right);
             temp@.left@.right@.right@.data:= pred(p@.right@.data);
             temp@.right:= Diff(p@.left);
           end
      end; {case}
      diff:= temp
    end {if p <> nil}
  else Diff:= nil
end;{Diff}
 
Procedure CleanUp (var p: nodeptr);
{CleanUp removes +, -, * 0 and *, ^ 1 from tree to make the expression
   more readable}
Var hold: nodeptr; {holds address to be destroyed}
Begin
  If p <> nil then
    begin
      CleanUp(p@.left);
      CleanUp(p@.right);
    {if + with a 0 as its left child or * with a 1 as left
        then replace p with a copy of its right subtree.}
      If ((p@.data = '+') and (p@.left@.data = '0')) or
         ((p@.data = '*') and (p@.left@.data = '1')) then
        begin
          hold:= p;
          p:= Copy(p@.right);
          destroy(hold)
        end;
    {if +, - with 0 as right child or *, ^  with a 1 as right child
        then replace p with a copy of its left subtree.}
      if ((p@.data in ['+', '-']) and (p@.right@.data = '0')) or
         ((p@.data in ['*', '^']) and (p@.right@.data = '1')) then
        begin
          hold:= p;
          p:= Copy(p@.left);
          destroy(hold)
        end;
    {if * by 0 then replace b with 0 and destroy its right and left
        subtrees.}
      if p@.data = '*' then
        if (p@.left@.data = '0') or (p@.right@.data = '0') then
          begin
            destroy(p@.right);
            destroy(p@.left);
            p@.data:= '0';
            p@.left:= nil;
            p@.right:= nil
          end
    end
end; {CleanUp}
 
Procedure Preorder(p:nodeptr);
{Preorder writes the prefix expression to the screen}
begin
  if p <> nil then
    begin
      Write(p@.data);
      Preorder(p@.left);
      Preorder(p@.right);
    end {if}
end; {Preorder}
 
Procedure InorderWithParenthesis(p: nodeptr);
{Inorder writes the fully parenthesized infix expression to the screen.}
begin
  if p <> nil then
    begin
      if p@.data in ['+', '-', '*', '/', '^'] then
        write('(');
      InorderWithParenthesis(p@.left);
      write(p@.data);
      InorderWithParenthesis(p@.right);
      if p@.data in ['+', '-', '*', '/', '^'] then
        write(')');
    end {if}
end; {InorderWithParenthesis}
 
Var
  RootOfOriginal, RootOfDerivative: nodeptr;
    {Roots of 2 expressions}
  operators, operands: integer;
    {number of each for error checking}
 
{An expression is valid if there is one more operand than operator. So
    if operators >= operands or if the tree is completely built before
    eoln is reached, meaning all operators were matched to operands
    but there are some characters left over, then the expression is
    invalid.}
 
Begin {main}
  termout(output);
  Reset(input, 'name = prefix.data.*');
  While not eof do
    Begin
      operators:= 0;
      operands:= 0;
      RootOfOriginal:= Build_Expression_Tree(operators, operands);
      if (operators < operands) and eoln then begin {valid equation}
        writeln('Prefix:');
        Preorder(RootOfOriginal);
        writeln;
        writeln('Infix of original expression:');
        InorderWithParenthesis(RootOfOriginal);
        writeln;
        RootOfDerivative:= diff(RootOfOriginal);
        CleanUp(RootOfDerivative);
        Writeln('Infix of derivative:');
        InorderWithParenthesis(RootofDerivative);
        writeln;
        Destroy(RootOfDerivative)
       end {if}
      else writeln('invalid expression');
      readln;
      writeln;
      Destroy(RootOfOriginal)
    end {while}
End. {Calculus}
