/* Erick Nave
   Applied Systems Programming
   Programming Assignment 5 - Linking Loader
   Due: Dec. 4
 
   Macload.c is the 2-pass linking loader for the MAC-3 machine.  It
     will load and link one or more object files into the simulated
     MAC-3 memory and then call a simulator of the MAC-3 instruction
     set to execute the program */
 
#include "common.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
 
                      /* simulated MAC-3 memory */
#define memsize 0x10000
typedef short unsigned int MacWord;
static MacWord Memory[memsize];
 
                 /* external definition for Interpreter */
extern void Interpret(MacWord*,MacWord);
 
                  /* global flag for loader error */
int loaderr;
 
                /* Data Record for Global Symbol Table */
typedef struct {
  char symbol[9];
  unsigned short addr;
 } GSTData;
 
void LPass1(int flistlen, char**flist, int la, Table GST)
 /* LPass1 is the 1st pass of the linking loader.  It determines whether
      or not all of the code will fit into memory.  It also places all
      of the DEF symbols into the GST.  LPass1 expects as parameters the
      length of the list of files, the list of filenames, the load
      address, and the global symbol table. */
{
 char ObjName[45];  /* name of object file */
 FILE *ofile;       /* pointer to the object file */
 int i;             /* loop index */
 int CSAddr;        /* address of current segment */
 int NextCS;        /* address of next segment */
 int result;        /* result of TInsert */
 objrec obj;        /* object record read from object file */
 GSTData *sym;       /* symbol for the GST */
 
 CSAddr = la;
 for (i = 0; i < flistlen; i++)
  {                 /* open file */
   strcpy(ObjName, flist[i]);
   strcat(ObjName, " OBJECT (BIN RECFM F LRECL 80\0");
   if ((ofile = fopen(ObjName, "r")) == NULL)
    {
     printf("Unable to open %s\n", ObjName);
     exit(1);
    }
 
                 /* read HDR record */
   fread (&obj, sizeof(objrec), 1, ofile);
   NextCS = CSAddr + obj.hdr.proglen;
   if(NextCS >= memsize)
    {
     printf("Out of Memory.\n");
     exit(1);
    }
 
             /* read DEF records and place them into the GST */
   fread (&obj, sizeof(objrec), 1, ofile);
   while(strcmp(obj.def.rectype, "DEF\0") == 0)
    {
     sym = (GSTData *)malloc(sizeof(GSTData));
     strcpy(sym->symbol, obj.def.symbol);
     sym->symbol[8] = '\0';
     sym->addr = obj.def.symaddr + CSAddr;
     result = TInsert(GST, sym->symbol, sym);
     if (result == DUP)
      {
       printf("Multiply-Defined Symbol %s\n",sym->symbol);
       free(sym);
       loaderr = 1;
      }
     else if (result == FULL)
      {
       printf("Global Symbol Table Full.\n");
       loaderr = 1;
       free(sym);
      }
     fread (&obj, sizeof(objrec), 1, ofile);
    } /* end while */
 
   CSAddr = NextCS;
   fclose(ofile);
 
  } /* end for */
} /* end LPass1 */
 
 
short LPass2(int flistlen, char**flist, int la, Table GST)
 /* LPass2 is the 2nd pass of the linking loader.  It expects the
     length of the list of object files, the list of object files, the
     load address, and the global symbol table.  It then memcpys all of
     the text to the simulated MAC-3 memory and processes all of the MOD
     records.  It returns the entry address of the program */
{
 char ObjName[45];    /* name of object file */
 FILE *ofile;         /* pointer to the object file */
 int i;               /* loop index */
 int CSAddr;          /* address of current segment */
 int NextCS;          /* address of next segment */
 objrec obj;          /* object record read from object file */
 GSTData *sym;         /* symbol for the GST */
 TableRecord *t;      /* pointer to a table record */
 int startfound = 0;  /* starting address found */
 short entry = la;    /* entry address */
 char modsym[9];      /* symbol in mod record */
 
 CSAddr = la;
 for(i = 0; i < flistlen; i++)
  {               /* open file */
   strcpy(ObjName, flist[i]);
   strcat(ObjName, " OBJECT (BIN RECFM F LRECL 80\0");
   if ((ofile = fopen(ObjName, "r")) == NULL)
    {
     printf("Unable to open %s\n", ObjName);
     exit(1);
    }
 
                 /* read HDR record */
   fread (&obj, sizeof(objrec), 1, ofile);
   NextCS = CSAddr + obj.hdr.proglen;
 
                 /* skip DEF records */
   do
    fread (&obj, sizeof(objrec), 1, ofile);
   while (strcmp(obj.def.rectype, "DEF\0") == 0);
 
                 /* process TXT records */
   while(strcmp(obj.txt.rectype, "TXT\0") == 0)
    {
     memcpy(Memory+CSAddr+obj.txt.txtaddr, obj.txt.code,
             obj.txt.wordct * 2);
     fread(&obj, sizeof(objrec), 1, ofile);
    }
 
                 /* process mod records */
   while(strcmp(obj.mod.rectype, "MOD\0") == 0)
    {
     memset(modsym, NULL, 9);
     memcpy(modsym, obj.mod.symbol, 8);
     if(isalpha(modsym[0]))
         /* external reference */
      if(t = TRetrieve(GST, modsym))
       {
        sym = t->data;
        *(Memory + CSAddr + obj.mod.symaddr) += sym->addr;
       }
      else
       {
        printf("Undefined symbol %s.\n",obj.mod.symbol);
        loaderr = 1;
       }
     else *(Memory + CSAddr + obj.mod.symaddr) += CSAddr;
     fread(&obj, sizeof(objrec), 1, ofile);
    }
 
                  /* process end record */
   if(!startfound)
    if(obj.end.flag)
     {
      entry = obj.end.startaddr + CSAddr;
      startfound = 1;
     }
 
   CSAddr = NextCS;
   fclose(ofile);
  } /* end for */
 
 return entry;
} /* end LPass2 */
 
main(int argc, char**argv)
{
 Table GST;        /* Global Symbol Table */
 int flstart = 1;  /* position of first file in argv */
 int la = 0;     /* load address */
 MacWord entry;      /* entry point in code */
 int rc;
 
               /* check for valid command line */
 if (argc < 2)
  {
   printf("Usage: macload [-laddr] objfile1 [objfile2...]\n");
   exit(1);
  }
 
                  /* check for load address */
 if (argv[1][0] == '-')
  if (argc < 3)
   {
    printf("Usage: macload [-laddr] objfile1 [objfile2...]\n");
    exit(1);
   }
  else
   {
    flstart = 2;
    rc = sscanf(argv[1]+1, "%x", &la);
   }
 
                 /* check for valid load address */
 if (la >= memsize)
  {
   printf("Load Address Out of Bounds.  Use address < 0x10000.\n");
   exit(1);
  }
 
                /* create the Global Symbol Table */
 TCreate(&GST, 199);
 
                /* call Passes 1 and 2 of the Loader */
 LPass1(argc-flstart, argv+flstart, la, GST);
 entry = LPass2(argc-flstart, argv+flstart, la, GST);
 
                    /* call the Interpreter */
 if (!loaderr)
  Interpret(Memory, entry);
} /* end main */
