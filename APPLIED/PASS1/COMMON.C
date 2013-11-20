/* Erick Nave
   Applied Systems Programming
   Program 2 - common.c
   Due: Mon. Oct 2
 
   Common.c contains the functions LoadOpcodeTable and ParseLine.
     LoadOpcodeTable reads the opcode file and places the records into
     the opcode table. ParseLine takes a string line and parses it into
     its label, operation, and operand. */
 
#include "common.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
 
void LoadOpcodeTable(Table T, char *OpfileName)
  /* LoadOpcodeTable reads strings in from the opcode file (OpfileName).
       It then parses the string into an OpcodeData record and sends a
       pointer to the record, the pointer to the key, and the table to
       the table functions for placement of the record into the table.
       If the insertion fails, the reason for the failure is given. */
{
 FILE *Opfile;       /* opcode file */
 OpcodeData *record; /* record malloced to contain line */
 char monic[5];      /* mnemonic gained from sscanf of line */
 int opcde, fmt;     /* opcode and format gained from sscanf of line */
 int result;         /* result of success or failure of TInsert */
 
 if ((Opfile = fopen(OpfileName, "r")) == NULL)
   printf("Cannot open file %s \n",OpfileName);     /* bad file name */
 else
                /* good file name so process records */
    while(fscanf(Opfile,"%s %x %d",monic, &opcde, &fmt) != EOF)
     {
      record = (OpcodeData *)malloc(sizeof(OpcodeData));
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
 
void ParseLine(char *line, char **label, char **operation,
                 char **operand)
  /* ParseLine expects a string line to be passed in to be parsed into
       its lable, operation, and operand. The null terminated string
       of each will be assigned to its proper pointer for use in the
       calling function */
{
 if (!isspace(line[0]))  /* line has a label */
  {
   *label = strtok(line," ");
   *operation = strtok(NULL, " ");
   *operand = strtok(NULL, " ");
  }
 else                   /* line has no label*/
  {
   *label = NULL;
   *operation = strtok(line, " ");
   *operand = strtok(NULL, " ");
  }
}
 
void upper(char line[81])
  /* upper converts a string passed in to all upper case letters */
{
 int i; /* loop index */
 for (i=0; line[i] != '\0'; i++)
  line[i] = toupper(line[i]);
}
