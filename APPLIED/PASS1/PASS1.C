/* Erick Nave
   Applied Systems Programming
   Program 2 - Pass1.c
   Due: Oct 2
 
   Pass1.c contains the function pass1 - the 1st pass of the 2 pass
     assembler. */
 
#include "common.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
 
 
void Pass1(char *fname, Table optab, Table stab)
  /* Pass1 expects a file name (fname), opcode table (optab), and
       symbol table (stab) from the caller.  It takes the fname and
       appends the file types to it so that the MACASM and ITF files
       can be opened.  Once opened, a line is read in one at a time
       and is parsed.  If there is a symbol and it is valid, it is
       placed in the symbol table.  The opcode is then checked to see
       if it is valid.  The line with its location counter and error
       code is then written to the ITF file */
{
 char MacName[45], ITFName[45];
   /* names of the MAC file and ITF file */
 FILE *mfile, *ifile;
   /* pointers to the MAC file and ITF file */
 char line[81];
   /* line read from input */
 char *label, *operation, *operand;
   /* values determined in ParseLine */
 short loc = 0;
   /* location counter */
 ITFline ITF;
   /* line to be sent to ITF */
 SymbolData *Sym;
   /* Symbol to be added to the symbol table */
 int result, good;
   /* result of TInsert and flag that label is good */
 int i;
   /* loop index */
 
 printf("Pass 1 of assembler\n\n");
 
          /* append MAC and ITF to filename and open them */
 strcpy(MacName, fname);
 strcpy(ITFName, fname);
 strcat(MacName," MACASM (TEXT RECFM F LRECL 80\0");
 strcat(ITFName," ITF (BIN RECFM F LRECL 86\0");
 if ((mfile = fopen(MacName, "r")) == NULL)
   printf("Unable to open %s\n", MacName);
 else if ((ifile = fopen(ITFName, "w")) == NULL)
   printf ("Unable to open %s\n", ITFName);
 else
 {
   operation = dummystr;
   while ((!feof(mfile)) && (strcmp(operation, endstr) != 0))
    {
                 /* get line and make a copy of it */
     fread(line, 1, 81, mfile);
                 /* initialize ITFLine for comment */
     strcpy(ITF.srcline, line);
     ITF.locctr = loc;
     ITF.error = 0;
 
                    /* check line for comment */
     if (line[0] != '*')
      {
                          /* Parse Line */
       upper(line);
       ParseLine(line, &label, &operation, &operand);
              /* check for label and process symbol */
       if ((strcmp(operation,equstr) != 0) &&
           (strcmp(operation,extstr) != 0))
        {
         good = 1;
         if (label != NULL)
              /* check to see if label is valid */
          if (isalpha(label[0]) && strlen(label) < 9)
           {
       /* valid so far, check for other problems with label */
            for (i=1; i < strlen(label); i++)
            if (!isalnum(label[i])) good = 0;
            if (good)
             {
              Sym = (SymbolData *)malloc(sizeof(SymbolData));
              strcpy(Sym->symbol, label);
              Sym->value = loc;
              Sym->type = REL;
              result = TInsert(stab, Sym->symbol, Sym);
              if (result == DUP)
               {
                ITF.error |= MULT_DEF_SYM;      /* duplicate symbol */
                free(Sym);
               }
              if (result == FULL)              /* symbol table full */
               {
                ITF.error |= SYM_TAB_OF;
                free(Sym);
               }
             }
            else ITF.error |= INVALID_LABEL;
           }
          else ITF.error |= INVALID_LABEL;
 
                 /* increment location counter */
          if(strcmp(operation, dsstr) != 0) loc++;
          else loc += atoi(operand);
        } /* end if not = or ext */
 
                /* check for valid opcode */
       if(!TRetrieve(optab, operation))
        {
         loc--;
         if(isalpha(operation[0]))
          ITF.error |= ILLEGAL_OPCODE;
        }
      } /* end if not * */
 
                     /* write ITF line */
     fwrite(&ITF, sizeof(ITFline), 1, ifile);
    } /* end while */
 
                /* close files */
  fclose(mfile);
  fclose(ifile);
 }
 printf("Pass 1 complete.\n\n");
} /* end Pass1 */
