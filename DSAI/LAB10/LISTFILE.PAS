segment listfile;
{Erick Nave 11/16}
{Ordered List ADT - implementation based on random access files}
 
%include cms
%include invupdt3
%include listpub
 
{local support routines}
 
function RefNode (var L:List; p:integer): ListNode;
  begin
    seek(L.FileID,p);
    get(L.FileID);
    RefNode:= L.FileId@
  end;
 
procedure PutNode(var L:List; p:integer; var x:ListNode);
  begin
    seek(L.FileId,p);
    write(L.FileID,x)
  end;
 
function NewNode(var L:List): integer;
  var p: integer;
      temp:ListNode;
  begin
    If l.Head.avail <> 0 then
      begin
        p:=L.Head.avail;
        temp:= RefNode(L,p);
        L.Head.avail:= temp.next
      end
    else
      begin
        p:= L.Head.FileSize+1;
        L.Head.FileSize:= p
      end;
    NewNode:= p
  end;
 
procedure DisposeNode(var L:List; p:integer);
  var temp:ListNode;
  begin
    temp:= RefNode(L,p);
    temp.next:= L.Head.avail;
    PutNode(L,p,temp);
    L.Head.avail:=p
  end;
 
{Ordered list ADT operations}
 
procedure ListCreate;
  var rc:integer;
  static index:integer;
  value  index:=0;
  begin
    index:=index+1;
    writestr(L.ddname,'FL',index:1);
    cms('FILEDEF '||L.ddname||' DISK '||Fname||'(XTENT 10000',rc);
    if rc>0 then
      Success:=false
    else
      with L do
        begin
          cms('estate '||Fname,rc); {test if file exists}
          if rc>0 then
            begin
              rewrite(FileID,'ddname='||L.ddname);
              with Head do
                begin
                  next:=0;
                  avail:=0;
                  ListSize:=0;
                  FileSize:=1;
                end;
              write(FileID,Head);
              close(FileID);
            end;
          update(FileID,'ddname='||L.ddname);
          FileName:=FName;
          Head:=RefNode(L,1);
          Success:=true;
        end
  end;
 
procedure ListDestroy;
  var rc:integer;
  begin
    PutNode(L,1,L.Head);
    close(L.FileID);
    cms('FILEDEF '||L.DDName||' CLEAR',rc);
  end;
{
procedure ListAssign;
  var rc:integer;
      Ok:boolean;
  begin
    ListDestroy(Source);
    cms('copy '||Source.Filename||' '||DestName||' (replace',rc);
    ListCreate(Dest,DestName,Ok);
    ListCreate(Source,Source.Filename,Ok);
  end;
 }
procedure ListAdd;
  var Prior,Current:integer;
      PriorNode,CurrentNode:ListNode;
      Temp:ListNode;
      ptr:integer;
      Found:boolean;
  begin
    Prior:=1;
    Current:=L.Head.Next;
    Found:=false;
    while (Current<>0) and not Found do
      begin
        CurrentNode:=RefNode(L,Current);
        if Precedes(Item,CurrentNode.Data) then
          Found:=true
        else
          begin
            PriorNode:=CurrentNode;
            Prior:=Current;
            Current:=CurrentNode.next;
          end
      end;
    Temp.data:=Item;
    Temp.next:=Current;
    ptr:=NewNode(L);
    Success:=true;
    PutNode(L,ptr,Temp);
    if Prior=1 then
      L.Head.Next:=ptr
    else
      begin
        PriorNode.Next:=ptr;
        PutNode(L,Prior,PriorNode);
      end;
    L.Head.ListSize:=L.Head.ListSize+1
  end;
 
 
procedure ListDelete;
  {ListDelete deletes Target from list L and returns the new list and
     whether or not the deletion was successful}
  var
    Prior,Current: integer;
    PriorNode,CurrentNode: ListNode;
    Found: boolean;
  begin
    Prior:= 1;
    Current:= L.Head.Next;
    Found:= false;
    while (current <> 0) and not Found do
      begin
        CurrentNode:= RefNode(l,current);
        if Match(Target, CurrentNode.Data) then
          Found:= True
        else
          Begin
            PriorNode:= CurrentNode;
            Prior:= Current;
            Current:= CurrentNode.next
          end
      end;
    IF found then
      begin
        success:= true;
        IF prior <> 1 then
          begin
            PriorNode.next:= CurrentNode.next;
            PutNode(l,prior, priornode);
          end
        ELSE
            L.Head.Next:= CurrentNode.next;
        DisposeNode(L,Current);
      end
    else Success:= false
  end;
 
procedure ListRetrieve;
  var ptr:integer;
      temp:ListNode;
  begin
    Success:=false;
    ptr:=L.Head.Next;
    while (ptr<>0) and not Success do
      begin
        temp:=RefNode(L,ptr);
        if Match(Target,temp.data) then
          begin
            Success:=true;
            Item:=temp.data
          end
        else
          ptr:=temp.next
      end
  end;
 
 
procedure ListUpdate;
  {ListUpdate updates the list by replacing the Target with NewValue}
  var
    ptr: Integer;
    temp: ListNode;
  begin
    Success:= False;
    ptr:= L.Head.Next;
    while (ptr <> 0) and (not Success) do
      begin
        temp:= refnode(L,ptr);
        if match(Target, temp.data) then
          Success:= true
        else
          ptr:= temp.next
      end;
    temp.data:= NewValue;
    PutNode(L,ptr,temp)
  end;
 
procedure Traverse;
  {Traverse passes through the list once and applies the data to the
     function provided in the application}
  var
    temp: integer;
    item: listnode;
  begin
    temp:=l.head.next;
    while temp <> 0 do
      begin
        item:= refnode(L,temp);
        ProcessNode(item.data);
        PutNode(L,temp,item);
        temp:= item.next
      end
  end;
 
.
