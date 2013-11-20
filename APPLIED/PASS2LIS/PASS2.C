/* Erick Nave
   Applied Systems Programming
   Program 3 - Pass2
   Due: Oct 18
 
   Pass2.c contains the function pass2 which is the second pass of the
     assembler.  For program 3 Pass2 is to read from the ITF file and
     generate a listing file. */
 
#include "common.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
 
void Pass2(char *fname, Table optab, Table stab, int proglen)
  /* Pass2 expects as parameters a file name, opcode table, symbol
       table, and the length of the macasm program.  It begins by
       assigning the filenames to the necessary files and opening them.
       It then dumps the symbol table to the listing file.  Then for
       each source line, the machine code is generated (if any) and
       is sent to the text record.  The machice code, along with the
       location counter and source line are then written to the listing
       file. */
{
 char ITFName[45], ListName[45], TextName[45];
   /* names of the files */
 FILE *ifile, *lfile, *tfile;
   /* pointers to the files */
 TableRecord *tptr;
   /* pointer to table record for symbol table dump */
 SymbolData *sptr;
   /* pointer to symbol record for symbol table dump */
 OpcodeData *optr;
   /* pointer to opcode record for opcode's information */
 ITFline itf;
   /* itf record read from the ITF */
 int i;
   /* loop index */
 unsigned short instr, op, symval;
   /* machine instruction */
 char line[81];
   /* copy of source line */
 char *label, *operation, *operand;
   /* values determined in ParseLine */
 int val;
 unsigned err, err2;
   /* val and err are determined in EvalExpr */
 char typ;
   /* type of expression determined in EvalExpr */
 
          /* append ITF and LISTING to file names and open them */
 strcpy(ITFName, fname);
 strcpy(ListName, fname);
 strcat(ITFName," ITF (BIN RECFM F LRECL 86\0");
 strcat(ListName," LIST (TEXT RECFM V LRECL 99\0");
 if ((ifile = fopen(ITFName, "r")) == NULL)
  {
   printf("Unable to open %s\n", ITFName);
   exit(1);
  }
 if ((lfile = fopen(ListName, "w")) == NULL)
  {
   printf ("Unable to open %s\n", ListName);
   exit(1);
  }
 
                   /* dump Symbol Table to Listing file */
 fprintf(lfile,"Symbol Table\n");
 fprintf(lfile,"%-10s %-10s %s\n", "Symbol", "Value", "Type");
 fprintf(lfile,"%-10s %-10s %s\n", "------", "-----", "----");
 for (i=0, tptr=stab.data; i<stab.tsize; ++i, ++tptr)
  if (sptr = tptr->data)
   {
    fprintf(lfile,"%-10s ", tptr->key);
    symval = 0 | sptr->value;
    fprintf(lfile,"%04X %6c", symval, ' ');
    fprintf(lfile,"%3c\n",sptr->type);
   }
 fprintf(lfile,"\n\n");
 
                    /* write column headings */
 fprintf(lfile,"%-9s %-7s Source Code\n", "Counter", "Code");
 fprintf(lfile,"%-9s %-7s -----------\n", "-------", "----");
                        /* process ITF file */
 operation = dummystr;
 while (!feof(ifile) && (strcmp(operation, endstr) != 0))
  {
                   /* initialize instruction and error to 0 */
   instr = err = 0;
                        /* read ITF record */
   fread(&itf, sizeof(ITFline), 1, ifile);
 
              /* if no pass 1 errors or comment process line */
   err2 = itf.error;
   if(!(err2 & ILLEGAL_OPCODE) && (itf.srcline[0] != '*'))
    {
                /* make a copy of srcline and parse it */
     strcpy(line, itf.srcline);
     line[81] = '\0';
     upper(line);
     ParseLine(line, &label, &operation, &operand);
 
                 /* retrieve opcode to check format */
     if(operation != NULL)
      {
       tptr = TRetrieve(optab,operation);
       optr = tptr->data;
       if(optr->format != 4)
          /* format 3 -- no operand -- machine instr is the opcode */
        if (optr->format == 3) instr = optr->opcode;
          /* formats 1 and 2 need operand */
        else if(operand != NULL)
         {
          EvalExpr(operand, stab, &val, &typ, &err);
          if(!err)
             /* operand for format 1 must be relocatable */
           if((optr->format == 1) && (typ == REL))
            {
             op = optr->opcode;
             op <<= 12;
             val -= (itf.locctr + 1);
             if((val >= -2048) && (val <= 2047)) /* address boundaries*/
              {
               instr |= val;
               instr <<= 4;
               instr >>= 4;
              }
             else err |= REL_OUT_OF_RANGE;
             instr |= op;
            }
            /* operand for format 2 must be absolute */
           else if((optr->format == 2) && (typ == ABS))
            {
             instr = optr->opcode;
             instr <<= 8;
             if((val >= 0) && (val <= 255))/* local address boundaries */
               instr |= val;
             else err |= LOC_OUT_OF_RANGE;
            }
              /* if DC directive machine code is constant */
           else if (strcmp(operation, dcstr) == 0)
            instr = val;
           else err |= WRONG_EXP_TYPE;
        } /* end if operand !=null */
       else err |= OPERAND_MISS;
      } /* end if operation !=null */
    } /* end if not ITF.error and not comment */
 
                /* write listing line */
   err |= itf.error;
   err2 = err;
   if (!(err2 & ILLEGAL_OPCODE) &&
       (strcmp(operation,equstr) != 0) && (strcmp(operation,extstr)!=0)
       && (itf.srcline[0] != '*'))
    if (strcmp(operation, dsstr) !=0 && operation != NULL &&
        strcmp(operation, endstr) != 0)
     {
      fprintf(lfile, "  %04hX",itf.locctr);
      fprintf(lfile, "    %04hX", instr);
      fprintf(lfile, "    %s\n", itf.srcline);
     }
    else
     {
      fprintf(lfile,"  %04hX %11c", itf.locctr, ' ');
      fprintf(lfile,"%s\n", itf.srcline);
     }
   else fprintf(lfile, "%17c %s\n", ' ', itf.srcline);
 
                /* write error lines */
   err2 = err;
   if (err2 & MULT_DEF_SYM)
    fprintf(lfile,"%17c *** Multiply Defined Symbol\n", ' ');
   err2 = err;
   if (err2 & INVALID_LABEL)
    fprintf(lfile,"%17c *** Invalid Label\n", ' ');
   err2 = err;
   if (err2 & ILLEGAL_OPCODE)
    fprintf(lfile,"%17c *** Illegal Opcode\n", ' ');
   err2 = err;
   if (err2 & SYM_TAB_OF)
    fprintf(lfile,"%17c *** Symbol Table Overflow\n", ' ');
   err2 = err;
   if (err2 & UNDEF_SYM)
    fprintf(lfile,"%17c *** Undefined Symbol\n", ' ');
   err2 = err;
   if (err2 & ILL_EXT_REF_EXPR)
     fprintf(lfile,"%17c *** Illegal External Reference\n", ' ');
   err2 = err;
   if (err2 & ILL_EXPR)
    fprintf(lfile,"%17c *** Illegal Expression\n", ' ');
   err2 = err;
   if (err2 & OPERAND_MISS)
    fprintf(lfile,"%17c *** Operand Missing\n", ' ');
   err2 = err;
   if (err2 & REL_OUT_OF_RANGE)
    fprintf(lfile,"%17c *** Relative Address Out of Range\n", ' ');
   err2 = err;
   if (err2 & LOC_OUT_OF_RANGE)
    fprintf(lfile,"%17c *** Local Address Out of Range\n", ' ');
   err2 = err;
   if (err2 & BAD_SYM_DX)
    {
     fprintf(lfile,"%17c *** Bad Operand Symbol",' ');
     fprintf(lfile," Declaration for DX\n");
    }
   err2 = err;
   if (err2 & WRONG_EXP_TYPE)
    fprintf(lfile,"%17c *** Expression Wrong Type for Operation\n",' ');
  } /* end while not eof */
 
                   /* close itf and listing files */
 fclose(ifile);
 fclose(lfile);
} /* end pass2 */
