/* Erick Nave
   Applied Systems Programming
   Program 1 - Table.c
 
   Table.c implements a "table" ADT to be used for the opcode and symbol
     tables for subsequent programs.  The functions in Table.c create
     table, insert records into the table, and retrieve records from
     the table. */
 
#include "table.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
 
char *DummyStr = "0";  /* global dummy string for initializing keys
                           in order to check for empty slots */
 
 
void TCreate(Table *tptr, int size)
  /* TCreate is given a Table pointer (tptr) to be initialized and the
       size of the desired table.  TCreate mallocs an array based on
       the size of TableRecord and the Table size passed in. It then
       initializes the pointers of the keys to point to DummyStr so
       a check for empty slots can be performed. */
{
 int i;    /* loop index */
 
                    /* initialize the table */
 tptr->tsize = size;
 tptr->data = (TableRecord *)malloc(sizeof(TableRecord) * size);
 
                 /* initialize key to DummyStr */
 for (i=0; i < size; i++)
   {
    tptr->data[i].key = DummyStr;
   }
}  /* end TCreate */
 
 
static int Hash(char *key, int tablesize)
  /* Hash is the hashing function that determines the position in the
      table of the character string key */
{
 int hval = 0;
 
 while (*key)
   hval = (hval << 3) + *key++;
 return hval % tablesize;
}  /* end Hash */
 
 
int TInsert (Table T, char *key, void *data)
  /* TInsert inserts a record pointed to by data into the table T.  key
       points to a character string within the data record used for
       hashing purposes and retrieval. TInsert returns an integer
       based upon success, full table, or duplicate key. */
{
 int pos;        /* position within array determined by hashing */
 int origin;     /* initial position for linear probe to test for full */
 int filled = 0; /* done with probe if table is full */
 int dble = 0;   /* done with probe if duplicate is found */
 int space = 0;  /* done with probe if empty slot found */
 int result;     /* integer to be returned from function */
 
 origin = pos = Hash(key, T.tsize);         /* determine position */
 
                      /* linear probe */
 dble = (strcmp(T.data[pos].key, key) == 0);
 space = (strcmp(T.data[pos].key, DummyStr) == 0);
 while (!filled && !dble && !space)
   {
    pos++;
    pos = pos % T.tsize;
    filled = (pos == origin);
    dble = (strcmp(T.data[pos].key, key) == 0);
    space = (strcmp(T.data[pos].key, DummyStr) == 0);
   }
 
        /* place record into array if not full or duplicate  */
        /*   and/or set result indicator to OK, DUP, or FULL */
 if (space)
   {
    T.data[pos].key = key;
    T.data[pos].data = data;
    result = OK;
   }
 else if (dble) result = DUP;
      else if (filled) result = FULL;
 
 return result;
}  /* end TInsert */
 
 
TableRecord *TRetrieve (Table T, char *key)
  /* TableRecord searches Table (T) for the record containing key.  If
      found, the pointer to the record is returned.  If not, then a 0
      is returned. */
{
 int pos;        /* position within array determined by hashing */
 int origin;     /* initial position for linear probe to test for done */
 int found = 0;  /* exits probe when key found */
 int done = 0;   /* exits probe after complete cycle through table */
 
 origin = pos = Hash(key, T.tsize);         /* determine position */
 
                      /* linear probe */
 found = (strcmp(T.data[pos].key, key) == 0);
 while (!found && !done)
   {
    pos++;
    pos = pos % T.tsize;
    done = (pos == origin);
    found = (strcmp(T.data[pos].key, key) == 0);
   }
 
 if (found) return &(T.data[pos]);
 else return 0;
}  /* end TRetrieve */
