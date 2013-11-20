/* Erick Nave
   Applied Systems Programming
   Program 2 - common.c
   Due: Mon. Oct 2
 
   Common.c contains the functions LoadOpcodeTable and ParseLine.
     LoadOpcodeTable reads the opcode file and places the records into
     the opcode table. ParseLine takes a string line and parses it into
     its label, operation, and operand.  Upper changes the characters
     in a line to all upper-case.
 
   Program 3 - add EvalExp
   Due: Oct. 18
 
   Added to common.c is the function EvalExp that evaluates the operand
     expression. */
 
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
 
void EvalExpr(char *operand, Table stab, int *val, char *type,
              unsigned *err)
  /* EvalExpr parses the operand, looks up the value of any symbols, and
       evaluates the operand expression.  It returns the value of the
       expression, its type, and any error flags encountered. */
{
 char *p1, *p2;         /* parts 1 and 2 of the expression */
 TableRecord *tr1, *tr2;  /* the records associated with p1 and p2 */
 SymbolData *s1, *s2;     /* symbols associated with the data in
                                 t1 and t2 */
 int v1,v2;               /* values associated with p1 and p2 */
 char t1,t2;              /* types associated with p1 and p2 */
 int plus, minus;         /* flags for type of expression encountered
                                 (addition or subtraction) */
 int num;                 /* flage to see if part of operand is a
                                 number */
 int i;                   /* loop index */
 
 plus = minus = *err = *val = 0;
 
                        /* evaluate operand */
 if (operand[0] == '-')    /* -term */
   if (isdigit(operand[1]))
    {
     num = 1;
       /* make sure number */
     for (i=2; i < strlen(operand); i++)
      if (!isdigit(operand[i])) num = 0;
     if (num)
      {
       *val = atoi(operand);
       *type = ABS;
      }
     else *err |= UNDEF_SYM;
    } /* end if isdigit operand[1] */
   else if (tr1 = TRetrieve(stab,operand+1))
    {
     s1 = tr1->data;
     if (s1->type != DXEXT)
      if (s1->type == ABS)
       {
        *val = s1->value;
        *val *= -1;
        *type = s1->type;
       }
      else *err |= ILL_EXPR;
     else *err |= ILL_EXT_REF_EXPR;
    }
   else *err |= UNDEF_SYM;
 else if (strchr(operand,'+') != NULL)  /* addition */
  {
   plus = 1;
                    /* parse operand according to + */
   p1 = strtok(operand,"+");
   p2 = strtok(NULL, "\0");
                          /* look up p1 */
   if (isdigit(p1[0]))
    {
     num = 1;
           /* make sure number */
     for (i=1; i < strlen(p1); i++)
      if (!isdigit(p1[i])) num = 0;
     if (num)
      {
       v1 = atoi(p1);
       t1 = ABS;
      }
     else *err |= UNDEF_SYM;
    }
   else if (tr1 = TRetrieve(stab,p1))
    {
     s1 = tr1->data;
     v1 = s1->value;
     t1 = s1->type;
     if (t1 == EXT) t1 = REL;
    }
   else *err |= UNDEF_SYM;
                          /* look up p2 */
   if (isdigit(p2[0]))
    {
     num = 1;
       /* make sure number */
     for (i=1; i < strlen(p2); i++)
      if (!isdigit(p2[i])) num = 0;
     if (num)
      {
       v2 = atoi(p2);
       t2 = ABS;
      }
     else *err |= UNDEF_SYM;
    }
   else if (tr2 = TRetrieve(stab,p2))
    {
     s2 = tr2->data;
     v2 = s2->value;
     t2 = s2->type;
     if(t2 == EXT) t2 = REL;
    }
   else *err |= UNDEF_SYM;
                         /* add values */
   if (!(*err))
    *val = v1 + v2;
  }
 else if (strchr(operand,'-') != NULL)  /* subtraction */
  {
   minus = 1;
                    /* parse operand according to - */
   p1 = strtok(operand,"-");
   p2 = strtok(NULL, "\0");
                          /* look up p1 */
   if (isdigit(p1[0]))
    {
     num = 1;
       /* make sure number */
     for (i=1; i < strlen(p1); i++)
      if (!isdigit(p1[i])) num = 0;
     if (num)
      {
       v1 = atoi(p1);
       t1 = ABS;
      }
     else *err |= UNDEF_SYM;
    }
   else if (tr1 = TRetrieve(stab,p1))
    {
     s1 = tr1->data;
     v1 = s1->value;
     t1 = s1->type;
     if(t1 == EXT) t1 = REL;
    }
   else *err |= UNDEF_SYM;
                          /* look up p2 */
   if (isdigit(p2[0]))
    {
     num = 1;
       /* make sure number */
     for (i=1; i < strlen(p2); i++)
      if (!isdigit(p2[i])) num = 0;
     if (num)
      {
       v2 = atoi(p2);
       t2 = ABS;
      }
     else *err |= UNDEF_SYM;
    }
   else if (tr2 = TRetrieve(stab,p2))
    {
     s2 = tr2->data;
     v2 = s2->value;
     t2 = s2->type;
     if (t2 == EXT) t2 = REL;
    }
   else *err |= UNDEF_SYM;
                         /* add values */
   if (!(*err))
    *val = v1 - v2;
  } /* end if subtraction */
 else              /* single-value expression */
  if (isdigit(operand[0]))
   {
    num = 1;
       /* make sure number */
    for (i=1; i < strlen(operand); i++)
     if (!isdigit(operand[i])) num = 0;
    if (num)
     {
      *val = atoi(operand);
      *type = ABS;
     }
    else *err |= UNDEF_SYM;
   }
  else if (tr1 = TRetrieve(stab,operand))
   {
    s1 = tr1->data;
    if (s1->type != DXEXT)
     {
      *val = s1->value;
      *type = s1->type;
      if (*type == EXT) *type = REL;
     }
    else *err |= ILL_EXT_REF_EXPR;
   }
  else *err |= UNDEF_SYM;
 
                      /* error check */
 if ((plus || minus) && !(*err))
  if ((t1 == DXEXT) || (t2 == DXEXT))
   *err |= ILL_EXT_REF_EXPR;
  else if (t1 == ABS)
   if (t2 == ABS)          /* A +- A = A */
    *type = ABS;
   else *err |= ILL_EXPR;   /* A +- R = illegal */
  else if ((t1 == REL) || (t1 == EXT))
   if (t2 == ABS)          /* R +- A = R */
    *type = REL;
   else if (minus)         /* R - R = A */
    *type = ABS;
   else *err |= ILL_EXPR;   /* R + R = illegal */
} /* end EvalExpr */
