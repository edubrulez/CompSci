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
 
 
int Pass1(char *fname, Table optab, Table stab)
  /* Pass1 expects a file name (fname), opcode table (optab), and
       symbol table (stab) from the caller.  It takes the fname and
       appends the file types to it so that the MACASM and ITF files
       can be opened.  Once opened, a line is read in one at a time
       and is parsed.  If there is a symbol and it is valid, it is
       placed in the symbol table.  The opcode is then checked to see
       if it is valid.  The line with its location counter and error
       code is then written to the ITF file.  The program length is
       returned.  */
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
 int result, good, good2;
   /* result of TInsert and flag that label is good */
 int i;
   /* loop index */
 int val;
 unsigned err;
   /* value and err from EvalExpr */
 char typ;
   /* type from EvalExpr */
 TableRecord *tptr;
   /* used for TRetrieve */
 int ok, inc; /* opcode ok  and go ahead and increment */
 
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
 
                    /* check for valid opcode */
       ok = inc = 1;
       if (isalnum(operation[0]) || ispunct(operation[0]))
        if(TRetrieve(optab,operation)) ok = 1;
        else
         {
          ITF.error |= ILLEGAL_OPCODE;
          ok = 0;
         }
       else inc = 0;    /* no opcode so don't increment locctr */
 
       if (ok)
        {
         if ((strcmp(operation,equstr) != 0))
          {
              /* check for label and process symbol */
           good = 1;
           if (label != NULL)
            if (strcmp(operation, extstr) == 0)
             ITF.error |= UNEXPECTED_LABEL;
              /* check to see if label is valid */
            else if (isalpha(label[0]) && strlen(label) < 9)
             {
       /* valid so far, check for other problems with label */
              for (i=1; i < strlen(label); i++)
               if (!isalnum(label[i])) good = 0;
              if (good)
               {
                       /* process label */
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
               } /* end if good */
              else ITF.error |= INVALID_LABEL;
             } /* end if alpha and len < 9 */
            else ITF.error |= INVALID_LABEL;
 
            /* if DX directive,  create operand symbol */
            if (strcmp(operation,dxstr) == 0)
             {
              good2 = 1;
              if(isalpha(operand[0]) && strlen(operand) < 9)
               {
                for (i=1; i < strlen(operand); i++)
                 if(!isalnum(operand[i])) good2 = 0;
               }
              else good2 = 0;
              if (good2 != 0)
               {
                Sym = (SymbolData *)malloc(sizeof(SymbolData));
                strcpy(Sym->symbol, operand);
                Sym->value = 0;
                Sym->type = DXEXT;
                result = TInsert(stab, Sym->symbol, Sym);
                if (result == DUP)
                 {
                  ITF.error |= MULT_DEF_SYM;   /* duplicate symbol */
                  free(Sym);
                 }
                if (result == FULL)         /* symbol table full */
                 {
                  ITF.error |= SYM_TAB_OF;
                  free(Sym);
                 }
               } /* end if good2 */
              else ITF.error |= BAD_SYM_DX;
             } /* end if dxstr */
 
      /* if extstr check for operand symbol and don't increment loc */
            if(strcmp(operation, extstr) == 0)
             if (tptr = TRetrieve(stab,operand))
              {
               Sym = tptr->data;
               if (Sym->type == REL)
                Sym->type = EXT;
               else ITF.error |= ILL_EXPR;
              }
             else ITF.error |= UNDEF_SYM;
                 /* increment location counter */
            else if (inc)
             if(strcmp(operation, dsstr) != 0) loc++;
             else
              {
               EvalExpr(operand,stab,&val,&typ,&err);
               if (typ == ABS && val >= 0 && !err)
                loc += val;
               else ITF.error |= err | ILL_EXPR;
              }
          }       /* end if not =  */
         else /* operation is = directive */
          {
              /* check to see if label is valid */
           good = 1;
           if ((label!=NULL) && (isalpha(label[0])) && (strlen(label)<9))
            for (i=1; i < strlen(label); i++)
             if (!isalnum(label[i])) good = 0;
             else good = good;
           else good = 0;
           if (good)
            {
             val = err = 0;
             EvalExpr(operand,stab,&val,&typ,&err);
             if (!err)
              {
               Sym = (SymbolData *)malloc(sizeof(SymbolData));
               strcpy(Sym->symbol, label);
               Sym->value = val;
               Sym->type = typ;
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
              } /* end if !err */
             else ITF.error |= err;
            } /* end if good */
           else ITF.error |= INVALID_LABEL;
          }    /* end if eqstr */
        } /* end if ok */
       else ITF.error |= ILLEGAL_OPCODE;
      } /* end if not * */
 
                     /* write ITF line */
     fwrite(&ITF, sizeof(ITFline), 1, ifile);
    } /* end while */
 
                /* close files */
  fclose(mfile);
  fclose(ifile);
 }
 
 return loc - 1;
} /* end Pass1 */
