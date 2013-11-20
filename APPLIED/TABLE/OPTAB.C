/* Erick Nave
   Applied Systems Programming
   Program 1 - Optab.c
   Due: Mon. Sept 18
 
   Optab.c contains the function LoadOpcodeTable in order to read from
     the data file and place the records into the opcode table. */
 
#include "table.h"
#include "optab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
 
void LoadOpcodeTable(Table T, char *OpfileName)
  /* LoadOpcodeTable reads strings in from the opcode file (OpfileName).
       It then parses the string into an OpcodeData record and sends a
       pointer to the record, the pointer to the key, and the table to
       the table functions for placement of the record into the table.
       If the insertion fails, the reason for the failure is given. */
{
 FILE *Opfile;       /* opcode file */
 char *line;         /* line read from Opfile */
 OpcodeData *record; /* record malloced to contain line */
 char monic[5];      /* mnemonic gained from sscanf of line */
 int opcde, fmt;     /* opcode and format gained from sscanf of line */
 int result;         /* result of success or failure of TInsert */
 
 if ((Opfile = fopen(OpfileName, "r")) == NULL)
   printf("Cannot open file %s \n",OpfileName);     /* bad file name */
 else
                /* good file name so process records */
    while(fgets(line, 80, Opfile) != NULL)
     {
      record = (OpcodeData *)malloc(sizeof(OpcodeData));
              /* parse the string into OpcodeData record */
      sscanf(line,"%s %x %d",monic, &opcde, &fmt);
      strcpy(record->mnemonic, monic);
      record->opcode = opcde;
      record->format = fmt;
 
                   /* insert the record */
      result = TInsert(T, record->mnemonic, record);
 
                /* check for error */
      if (result == DUP)
        printf ("Duplicate opcode %s.\n\n", record->mnemonic);
      else if (result == FULL)
        printf ("Table Full. %s not inserted.\n\n", record->mnemonic);
     }
}
