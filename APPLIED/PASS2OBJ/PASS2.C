/* Erick Nave
   Applied Systems Programming
   Program 3 - Pass2
   Due: Oct 18
 
   Pass2.c contains the function pass2 which is the second pass of the
     assembler.  For program 3 Pass2 is to read from the ITF file and
     generate a listing file.
 
   Program 4 - Pass 2 with object file creation
   Due: Nov. 7
 
   Pass2.c will now create an object file corresponding to the MACASM
    and listing files. */
 
#include "common.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
 
               /* definition of MOD record list node */
 struct modnode {
  objrec modrec;
  struct modnode *next;
 };
 
void InsertMod(struct modnode **h, struct modnode **t,
               struct modnode *m)
  /* InsertMod inserts the mod record into the linked list of records */
{
 if (*h == NULL)
  *h = *t = m;
 else
  {
   (*t)->next = m;
   *t = m;
  }
} /* end InsertMod */
 
void ClearObjrec (char *p)
  /* ClearObjrec clears out object records */
{
 int i;
 for (i=0; i<80; i++)
  p[i] = 0;
} /* end ClearObjrec */
 
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
 char ITFName[45], ListName[45], ObjName[45];
   /* names of the files */
 FILE *ifile, *lfile, *ofile;
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
 objrec obj;
   /* object to be written to object file */
 struct modnode *modr;
   /* mod record to be inserted into list */
 int delflag = 0;
   /* flag to delete object file */
 struct modnode *head, *tail, *temp, *kill;
   /* mod record list pointers */
 
       /* append ITF, LIST, and OBJECT to file names and open them */
 strcpy(ITFName, fname);
 strcpy(ListName, fname);
 strcpy(ObjName, fname);
 strcat(ITFName," ITF (BIN RECFM F LRECL 86\0");
 strcat(ListName," LIST (TEXT RECFM V LRECL 99\0");
 strcat(ObjName, " OBJECT (BIN RECFM F LRECL 80\0");
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
 if ((ofile = fopen(ObjName, "w")) == NULL)
  {
   printf ("Unable to open %s\n", ObjName);
   exit (1);
  }
 
                 /* write header record */
 ClearObjrec(obj.init);
 strcpy(obj.hdr.rectype, "HDR\0");
 obj.hdr.proglen = proglen;
 fwrite(&obj, sizeof(objrec), 1, ofile);
 
     /* dump Symbol Table to Listing file and externals to DEF recs */
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
    if (sptr->type == EXT)
     {       /* write DEF record */
      ClearObjrec(obj.init);
      strcpy(obj.def.rectype, "DEF\0");
      strcpy(obj.def.symbol, tptr->key);
      obj.def.symaddr = symval;
      fwrite(&obj, sizeof(objrec), 1, ofile);
     }
   }
 fprintf(lfile,"\n\n");
 
                 /* create mod record linked list */
 head = tail = NULL;
 
                 /* create empty text record */
 ClearObjrec(obj.init);
 strcpy(obj.txt.rectype, "TXT\0");
 obj.txt.wordct = 0;
 
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
       if(strcmp(operation, dxstr) == 0)
        {
         instr = 0;
                /* create mod record for dx */
         modr = (struct modnode *)malloc(sizeof(struct modnode));
         modr->next = NULL;
         ClearObjrec(modr->modrec.init);
         strcpy(modr->modrec.mod.rectype, "MOD\0");
         strcpy(modr->modrec.mod.symbol, operand);
         modr->modrec.mod.symaddr = itf.locctr;
         InsertMod(&head, &tail, modr);
        }
       tptr = TRetrieve(optab,operation);
       optr = tptr->data;
       if(optr->format != 4)
        {
          /* format 3 -- no operand -- machine instr is the opcode */
         if (optr->format == 3) instr = optr->opcode;
            /* formats 1 and 2 need operand */
         else if(operand != NULL)
          {
           EvalExpr(operand, stab, &val, &typ, &err);
           if (strcmp(operation, dxstr) == 0) err = 0;
           if(!err)
             /* operand for format 1 must be relocatable */
            if(optr->format == 1)
             {
              op = optr->opcode;
              op <<= 12;
              if(typ != ABS) val -= (itf.locctr + 1);
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
            else if(optr->format == 2)
             {
              instr = optr->opcode;
              instr <<= 8;
              if((val >= 0)&&(val <= 255))/* local address boundaries */
               instr |= val;
              else err |= LOC_OUT_OF_RANGE;
             }
              /* if DC directive machine code is constant */
            else if (strcmp(operation, dcstr) == 0)
              if ((val >= -32768) && (val <= 65535))
               {
                instr = val;
                if(typ == REL)  /* create mod record for dx */
                 {
                  modr=(struct modnode *)malloc(sizeof(struct modnode));
                  modr->next = NULL;
                  ClearObjrec(modr->modrec.init);
                  strcpy(modr->modrec.mod.rectype, "MOD\0");
                  modr->modrec.mod.symaddr = itf.locctr;
                  InsertMod(&head, &tail, modr);
                 }
               }
              else err |= OVERFLOW;
 
          }
         else err |= OPERAND_MISS;
 
                 /* add on to text record */
         if(obj.txt.wordct == 0) obj.txt.txtaddr = itf.locctr;
         if((itf.locctr - obj.txt.txtaddr) < maxwords)
          {           /* fits in txt record */
           obj.txt.wordct = itf.locctr - obj.txt.txtaddr;
           obj.txt.code[obj.txt.wordct] = instr;
           obj.txt.wordct++;
          }
         else  /* doesn't fit so write buffer and clear for new one */
          {
           fwrite(&obj, sizeof(objrec), 1, ofile);
           ClearObjrec(obj.init);
           strcpy(obj.txt.rectype, "TXT\0");
           obj.txt.txtaddr = itf.locctr;
           obj.txt.code[0] = instr;
           obj.txt.wordct = 1;
          } /* end insert text */
        }  /* end if opcode type != 4 */
      } /* end if operation !=null */
    } /* end if not ITF.error and not comment */
 
                /* write listing line */
   err |= itf.error;
   if (err) delflag = 1;  /* set flag to delete object file */
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
   err2 = err;
   if (err2 & OVERFLOW)
    fprintf(lfile,"%17c *** Overflow in Expression\n",' ');
   err2 = err;
   if (err2 & UNEXPECTED_LABEL)
    fprintf(lfile,"%17c *** Unexpected Label\n",' ');
  } /* end while not eof */
 
                   /* write last txt record */
 if (obj.txt.wordct > 0)
  fwrite(&obj, sizeof(objrec), 1, ofile);
 
                   /* dump and kill mod record list */
 temp = head;
 while (temp != NULL)
  {
   fwrite(&(temp->modrec), sizeof(objrec), 1, ofile);
   kill = temp;
   temp = temp->next;
   free(kill);
  }
 
                    /* write end record */
 ClearObjrec(obj.init);
 strcpy(obj.end.rectype,"END\0");
 if (operand != NULL)
  {
   obj.end.flag = 1;
   if(tptr = TRetrieve(stab,operand))
    {
     sptr = tptr->data;
     if(sptr->type == REL || sptr->type == EXT)
      obj.end.startaddr = sptr->value;
     else
      {
       fprintf(lfile,"%17c *** Relocatable Symbol needed for END\n",' ');
       delflag = 1;
      }
    }
   else
    {
     fprintf(lfile,"%17c *** Undefined Symbol\n", ' ');
     delflag = 1;
    }
  }
 else obj.end.flag = 0;
 fwrite(&obj, sizeof(objrec), 1, ofile);
 
   /* close itf, list, and object files - delete object file if error */
 fclose(ifile);
 fclose(lfile);
 fclose(ofile);
 if (delflag) remove(ObjName);
} /* end pass2 */
